-- Raid System - Server Side
-- Dosya Yolu: lua/autorun/server/sv_prophp_raid.lua
-- Versiyon: 2.4 - E tuşu ile raid eklendi

PropHP.RaidSystem = PropHP.RaidSystem or {}
PropHP.ActiveRaids = PropHP.ActiveRaids or {}
PropHP.RaidCooldowns = PropHP.RaidCooldowns or {}
PropHP.RaidParticipants = PropHP.RaidParticipants or {}

-- Network strings
util.AddNetworkString("PropHP_RaidRequest")
util.AddNetworkString("PropHP_RaidStart")
util.AddNetworkString("PropHP_RaidEnd")
util.AddNetworkString("PropHP_RaidTimer")
util.AddNetworkString("PropHP_UpdateRaidParticipants")
util.AddNetworkString("PropHP_LootingPhase")
util.AddNetworkString("PropHP_CancelRaid")
util.AddNetworkString("PropHP_PropRaidPrompt") -- Yeni: E tuşu onay menüsü için

-- ============================
-- RAID FONKSİYONLARI
-- ============================
function PropHP.IsInRaid(attackerParty, defenderParty)
    if not attackerParty or not defenderParty then return false end
    
    local attackerData = PropHP.GetPartyData(attackerParty)
    local defenderData = PropHP.GetPartyData(defenderParty)
    
    if not attackerData or not defenderData then return false end
    
    -- Raid aktif mi veya yağma aşamasında mı kontrol et
    if attackerData.raidStatus then
        if attackerData.raidStatus.targetParty == defenderParty then
            return attackerData.raidStatus.active or attackerData.raidStatus.lootingPhase
        end
    end
    
    return false
end

function PropHP.RaidSystem.CanStartRaid(attackerParty, defenderParty)
    -- Temel kontroller
    if not attackerParty or not defenderParty then
        return false, "Geçersiz parti!"
    end
    
    if attackerParty == defenderParty then
        return false, "Kendi partinize raid yapamazsınız!"
    end
    
    -- Parti verileri
    local attackerPartyData = parties[attackerParty]
    local defenderPartyData = parties[defenderParty]
    
    if not attackerPartyData or not defenderPartyData then
        return false, "Parti bulunamadı!"
    end
    
    -- Online ve yaşayan üye kontrolü
    local attackerAlive = 0
    local defenderAlive = 0
    
    for _, steamID in pairs(attackerPartyData.members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) and member:Alive() then
            attackerAlive = attackerAlive + 1
        end
    end
    
    for _, steamID in pairs(defenderPartyData.members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) and member:Alive() then
            defenderAlive = defenderAlive + 1
        end
    end
    
    -- Minimum üye kontrolü
    if attackerAlive < PropHP.Config.Raid.MinPartyMembers then
        return false, "En az " .. PropHP.Config.Raid.MinPartyMembers .. " yaşayan üye gerekli!"
    end
    
    if defenderAlive < 1 then
        return false, "Savunan partide en az 1 yaşayan üye olmalı!"
    end
    
    -- Üye farkı kontrolü
    if math.abs(attackerAlive - defenderAlive) > PropHP.Config.Raid.MaxMemberDifference then
        return false, "Üye sayıları çok dengesiz! (" .. attackerAlive .. "v" .. defenderAlive .. ")"
    end
    
    -- Cooldown kontrolü
    local cooldownKey = attackerParty .. "_" .. defenderParty
    if PropHP.RaidCooldowns[cooldownKey] then
        if CurTime() - PropHP.RaidCooldowns[cooldownKey] < PropHP.Config.Raid.RaidCooldown then
            local remaining = math.ceil((PropHP.Config.Raid.RaidCooldown - (CurTime() - PropHP.RaidCooldowns[cooldownKey])) / 60)
            return false, "Bu partiye tekrar raid için " .. remaining .. " dakika bekleyin!"
        end
    end
    
    -- Aktif raid kontrolü
    local attackerData = PropHP.GetPartyData(attackerParty)
    local defenderData = PropHP.GetPartyData(defenderParty)
    
    if attackerData.raidStatus then
        return false, "Zaten aktif bir raid'iniz var!"
    end
    
    if defenderData.raidStatus then
        return false, "Bu parti zaten raid altında!"
    end
    
    -- Prop kontrolü
    local aliveProps = 0
    for _, prop in pairs(defenderData.props) do
        if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
            aliveProps = aliveProps + 1
        end
    end
    
    if aliveProps < 1 then
        return false, "Savunan partinin sağlam prop'u yok!"
    end
    
    return true, "OK"
end

-- ============================
-- RAID BAŞLATMA
-- ============================
function PropHP.RaidSystem.StartRaid(attackerParty, defenderParty)
    local attackerData = PropHP.GetPartyData(attackerParty)
    local defenderData = PropHP.GetPartyData(defenderParty)
    
    -- Parti isimleri
    local attackerName = parties[attackerParty] and parties[attackerParty].name or "???"
    local defenderName = parties[defenderParty] and parties[defenderParty].name or "???"
    
    -- TEK MESAJ - SADECE SAVAŞ AÇMA BİLDİRİMİ
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("[RAID] " .. attackerName .. " partisi " .. defenderName .. " partisine savaş açtı!")
    end
    
    -- Raid ID
    local raidID = "raid_" .. CurTime()
    
    -- Raid katılımcılarını kaydet (NLR için)
    PropHP.RaidParticipants[raidID] = {
        attackers = {},
        defenders = {}
    }
    
    -- Saldıran parti üyelerini ekle
    for _, steamID in pairs(parties[attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            PropHP.RaidParticipants[raidID].attackers[steamID] = {
                nick = member:Nick(),
                alive = member:Alive(),
                deaths = 0,
                initialAlive = member:Alive()
            }
        end
    end
    
    -- Savunan parti üyelerini ekle
    for _, steamID in pairs(parties[defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            PropHP.RaidParticipants[raidID].defenders[steamID] = {
                nick = member:Nick(),
                alive = member:Alive(),
                deaths = 0,
                initialAlive = member:Alive()
            }
        end
    end
    
    -- Raid verisi
    attackerData.raidStatus = {
        raidID = raidID,
        targetParty = defenderParty,
        isAttacker = true,
        isDefender = false,
        active = false,
        preparation = true,
        lootingPhase = false,
        startTime = CurTime(),
        endTime = CurTime() + PropHP.Config.Raid.PreparationTime + PropHP.Config.Raid.RaidDuration
    }
    
    defenderData.raidStatus = {
        raidID = raidID,
        targetParty = attackerParty,
        isAttacker = false,
        isDefender = true,
        active = false,
        preparation = true,
        lootingPhase = false,
        startTime = CurTime(),
        endTime = CurTime() + PropHP.Config.Raid.PreparationTime + PropHP.Config.Raid.RaidDuration
    }
    
    -- Global raid
    PropHP.ActiveRaids[raidID] = {
        attackerParty = attackerParty,
        defenderParty = defenderParty,
        startTime = CurTime(),
        active = false,
        lootingPhase = false,
        lootingStartTime = nil,
        preparation = true
    }
    
    -- Bildirimleri gönder
    PropHP.RaidSystem.NotifyRaidStart(attackerParty, defenderParty, true)
    PropHP.RaidSystem.UpdateParticipants(raidID)
    
    -- Hazırlık timer'ı
    timer.Create("PropHP_PrepTimer_" .. raidID, PropHP.Config.Raid.PreparationTime, 1, function()
        PropHP.RaidSystem.ActivateRaid(raidID)
    end)
    
    -- Update timer (her saniye)
    timer.Create("PropHP_UpdateTimer_" .. raidID, 1, 0, function()
        PropHP.RaidSystem.UpdateRaidTimer(raidID)
    end)
end

-- ============================
-- RAID İPTAL FONKSİYONU
-- ============================
function PropHP.RaidSystem.CancelRaid(ply)
    -- Oyuncu parti lideri mi?
    local partyID = ply:GetParty()
    if not partyID or partyID != ply:SteamID64() then
        ply:ChatPrint("Sadece parti lideri raid'i iptal edebilir!")
        return false
    end
    
    -- Aktif raid var mı?
    local raidID = nil
    local raid = nil
    
    for id, raidData in pairs(PropHP.ActiveRaids) do
        if raidData.attackerParty == partyID then
            raidID = id
            raid = raidData
            break
        end
    end
    
    if not raid then
        ply:ChatPrint("Aktif bir raid bulunamadı!")
        return false
    end
    
    -- Tüm oyunculara bildir
    local attackerName = parties[raid.attackerParty] and parties[raid.attackerParty].name or "???"
    for _, p in pairs(player.GetAll()) do
        p:ChatPrint("[RAID] " .. attackerName .. " partisi raid'i iptal etti!")
    end
    
    -- Prop'ları tamir et (savunanlar için)
    if PropHP.PartyData[raid.defenderParty] then
        local repairedCount = PropHP.RepairAllDestroyedProps(raid.defenderParty)
        
        if parties[raid.defenderParty] then
            for _, steamID in pairs(parties[raid.defenderParty].members) do
                local member = player.GetBySteamID64(steamID)
                if IsValid(member) then
                    member:ChatPrint("Raid iptal edildi! " .. repairedCount .. " prop tamir edildi.")
                end
            end
        end
    end
    
    -- Raid verilerini temizle
    local attackerData = PropHP.GetPartyData(raid.attackerParty)
    local defenderData = PropHP.GetPartyData(raid.defenderParty)
    
    if attackerData then
        attackerData.raidStatus = nil
        attackerData.propsDestroyed = 0
    end
    
    if defenderData then
        defenderData.raidStatus = nil
        defenderData.propsDestroyed = 0
    end
    
    -- Katılımcıları temizle
    PropHP.RaidParticipants[raidID] = nil
    
    -- Timer'ları temizle
    timer.Remove("PropHP_PrepTimer_" .. raidID)
    timer.Remove("PropHP_UpdateTimer_" .. raidID)
    timer.Remove("PropHP_EndTimer_" .. raidID)
    
    -- Network - Raid sonu bildirimi
    net.Start("PropHP_RaidEnd")
        net.WriteString("canceled")
        net.WriteString("")
        net.WriteString("")
    net.Broadcast()
    
    -- Global raid'i kaldır
    PropHP.ActiveRaids[raidID] = nil
    
    -- Log
    ServerLog("[PropHP] Raid iptal edildi - Lider: " .. ply:Nick() .. " (" .. ply:SteamID() .. ")\n")
    
    return true
end

-- ============================
-- RAID KATILIMCI GÜNCELLEMESİ
-- ============================
function PropHP.RaidSystem.UpdateParticipants(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then return end
    
    local participants = PropHP.RaidParticipants[raidID]
    if not participants then return end
    
    -- SADECE CANLANMA DURUMUNU KONTROL ET
    for steamID, data in pairs(participants.attackers) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            -- Eğer bir kere öldüyse, alive = false kalmalı (NLR)
            if data.deaths > 0 then
                data.alive = false
            end
            -- İlk başta ölüyse de ölü kalmalı
            if not data.initialAlive then
                data.alive = false
            end
        else
            data.alive = false
        end
    end
    
    for steamID, data in pairs(participants.defenders) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            -- Eğer bir kere öldüyse, alive = false kalmalı (NLR)
            if data.deaths > 0 then
                data.alive = false
            end
            -- İlk başta ölüyse de ölü kalmalı
            if not data.initialAlive then
                data.alive = false
            end
        else
            data.alive = false
        end
    end
    
    -- Tüm raid üyelerine gönder
    local allMembers = {}
    
    if parties[raid.attackerParty] then
        for _, steamID in pairs(parties[raid.attackerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                table.insert(allMembers, member)
            end
        end
    end
    
    if parties[raid.defenderParty] then
        for _, steamID in pairs(parties[raid.defenderParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                table.insert(allMembers, member)
            end
        end
    end
    
    net.Start("PropHP_UpdateRaidParticipants")
        net.WriteTable(participants.attackers)
        net.WriteTable(participants.defenders)
    net.Send(allMembers)
end

-- ============================
-- RAID AKTİVASYONU
-- ============================
function PropHP.RaidSystem.ActivateRaid(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then return end
    
    raid.active = true
    raid.preparation = false
    
    local attackerData = PropHP.GetPartyData(raid.attackerParty)
    local defenderData = PropHP.GetPartyData(raid.defenderParty)
    
    if attackerData and attackerData.raidStatus then
        attackerData.raidStatus.active = true
        attackerData.raidStatus.preparation = false
    end
    
    if defenderData and defenderData.raidStatus then
        defenderData.raidStatus.active = true
        defenderData.raidStatus.preparation = false
    end
    
    -- Bildirimleri gönder
    PropHP.RaidSystem.NotifyRaidStart(raid.attackerParty, raid.defenderParty, false)
    
    -- TEK MESAJ - RAID BAŞLADI
    local attackerName = parties[raid.attackerParty] and parties[raid.attackerParty].name or "???"
    local defenderName = parties[raid.defenderParty] and parties[raid.defenderParty].name or "???"
    
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("[RAID] " .. attackerName .. " partisi ile " .. defenderName .. " partisi arasında raid başladı!")
    end
    
    -- Bitiş timer'ı
    timer.Create("PropHP_EndTimer_" .. raidID, PropHP.Config.Raid.RaidDuration, 1, function()
        PropHP.RaidSystem.EndRaid(raidID)
    end)
end

-- ============================
-- RAID BİLDİRİMLERİ
-- ============================
function PropHP.RaidSystem.NotifyRaidStart(attackerParty, defenderParty, preparation)
    local allMembers = {}
    
    -- Saldırgan parti
    if parties[attackerParty] then
        for _, steamID in pairs(parties[attackerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                table.insert(allMembers, member)
                if preparation then
                    member:ChatPrint("[RAID] Hazırlık süresi başladı! " .. PropHP.Config.Raid.PreparationTime/60 .. " dakikanız var.")
                else
                    member:ChatPrint("[RAID] Savaş başladı! Saldırıya geçin!")
                    member:EmitSound("buttons/button17.wav")
                end
            end
        end
    end
    
    -- Savunan parti
    if parties[defenderParty] then
        for _, steamID in pairs(parties[defenderParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                table.insert(allMembers, member)
                if preparation then
                    member:ChatPrint("[RAID] Size raid açıldı! " .. PropHP.Config.Raid.PreparationTime/60 .. " dakika hazırlanın!")
                else
                    member:ChatPrint("[RAID] Savaş başladı! Savunma pozisyonu alın!")
                    member:EmitSound("ambient/alarms/warningbell1.wav")
                end
            end
        end
    end
    
    -- Network
    net.Start("PropHP_RaidStart")
        net.WriteBool(preparation)
        net.WriteString(attackerParty)
        net.WriteString(defenderParty)
    net.Send(allMembers)
end

-- ============================
-- RAID TIMER UPDATE & PARTİ ÖLÜM KONTROLÜ
-- ============================
function PropHP.RaidSystem.UpdateRaidTimer(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then 
        timer.Remove("PropHP_UpdateTimer_" .. raidID)
        return 
    end
    
    -- Katılımcı kontrolü (parti tamamen öldü mü?)
    local participants = PropHP.RaidParticipants[raidID]
    if participants and raid.active and not raid.lootingPhase then
        local attackerAlive = 0
        local defenderAlive = 0
        
        -- Yaşayan saldıranları say
        for steamID, data in pairs(participants.attackers) do
            if data.alive then
                attackerAlive = attackerAlive + 1
            end
        end
        
        -- Yaşayan savunanları say
        for steamID, data in pairs(participants.defenders) do
            if data.alive then
                defenderAlive = defenderAlive + 1
            end
        end
        
        -- Scoreboard güncelle
        PropHP.RaidSystem.UpdateParticipants(raidID)
        
        -- Eğer bir taraf tamamen ölmüşse raid'i bitir
        if attackerAlive == 0 or defenderAlive == 0 then
            local winner = attackerAlive > 0 and "attacker" or "defender"
            local reason = attackerAlive == 0 and "Tüm saldıran parti öldürüldü!" or "Tüm savunan parti öldürüldü!"
            
            -- Tüm oyunculara bildir
            for _, ply in pairs(player.GetAll()) do
                ply:ChatPrint("[RAID] " .. reason)
            end
            
            -- Raid sonucu
            PropHP.RaidSystem.EndRaid(raidID, winner)
            return
        end
    end
    
    -- Normal timer güncellemesi
    local allMembers = {}
    
    if parties[raid.attackerParty] then
        for _, steamID in pairs(parties[raid.attackerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                table.insert(allMembers, member)
            end
        end
    end
    
    if parties[raid.defenderParty] then
        for _, steamID in pairs(parties[raid.defenderParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                table.insert(allMembers, member)
            end
        end
    end
    
    local timeLeft = 0
    local isPrep = not raid.active
    
    if raid.lootingPhase then
        -- Yağma aşaması timer'ı
        timeLeft = PropHP.Config.Raid.LootingDuration - (CurTime() - raid.lootingStartTime)
        if timeLeft <= 0 then
            PropHP.RaidSystem.FinalizeRaid(raidID)
            return
        end
    elseif isPrep then
        timeLeft = PropHP.Config.Raid.PreparationTime - (CurTime() - raid.startTime)
    else
        timeLeft = PropHP.Config.Raid.RaidDuration - (CurTime() - raid.startTime - PropHP.Config.Raid.PreparationTime)
    end
    
    net.Start("PropHP_RaidTimer")
        net.WriteFloat(math.max(0, timeLeft))
        net.WriteBool(isPrep)
    net.Send(allMembers)
end

-- ============================
-- RAID BİTİŞİ
-- ============================
function PropHP.RaidSystem.EndRaid(raidID, forceWinner)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then return end
    
    local attackerData = PropHP.GetPartyData(raid.attackerParty)
    local defenderData = PropHP.GetPartyData(raid.defenderParty)
    
    -- Kazananı belirle
    local winner = "defender"
    
    if forceWinner then
        winner = forceWinner
    else
        -- Prop bazlı kazanan
        if defenderData and defenderData.propsDestroyed >= PropHP.Config.Raid.MinPropsToWin then
            winner = "attacker"
        end
    end
    
    -- Saldıranlar kazandıysa yağma aşaması başlat
    if winner == "attacker" and not raid.lootingPhase then
        raid.lootingPhase = true
        raid.lootingStartTime = CurTime()
        raid.active = false
        
        -- Yağma bildirimi
        local allMembers = {}
        
        if parties[raid.attackerParty] then
            for _, steamID in pairs(parties[raid.attackerParty].members) do
                local member = player.GetBySteamID64(steamID)
                if IsValid(member) then
                    member:ChatPrint("[RAID] Yağma başladı! 3 dakikanız var!")
                    table.insert(allMembers, member)
                end
            end
        end
        
        if parties[raid.defenderParty] then
            for _, steamID in pairs(parties[raid.defenderParty].members) do
                local member = player.GetBySteamID64(steamID)
                if IsValid(member) then
                    member:ChatPrint("[RAID] Saldıranlar yağmalıyor! 3 dakika sonra prop'lar tamir olacak.")
                    table.insert(allMembers, member)
                end
            end
        end
        
        -- Raid verisini güncelle
        if attackerData and attackerData.raidStatus then
            attackerData.raidStatus.lootingPhase = true
            attackerData.raidStatus.active = false
        end
        
        if defenderData and defenderData.raidStatus then
            defenderData.raidStatus.lootingPhase = true
            defenderData.raidStatus.active = false
        end
        
        net.Start("PropHP_LootingPhase")
            net.WriteBool(true)
        net.Send(allMembers)
        
        return -- Timer devam ediyor, 3 dakika sonra FinalizeRaid çağrılacak
    end
    
    -- Direkt bitir (savunanlar kazandı)
    PropHP.RaidSystem.FinalizeRaid(raidID, winner)
end

-- ============================
-- RAID TAMAMEN BİTİR
-- ============================
function PropHP.RaidSystem.FinalizeRaid(raidID, overrideWinner)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then return end
    
    local winner = overrideWinner or (raid.lootingPhase and "attacker" or "defender")
    
    -- Para transferi YOK - Sadece bildirim
    PropHP.RaidSystem.DistributeRewards(raid, winner)
    
    -- Prop'ları tamir et
    timer.Simple(1, function()
        if PropHP.PartyData[raid.attackerParty] then
            PropHP.RepairAllDestroyedProps(raid.attackerParty)
        end
        if PropHP.PartyData[raid.defenderParty] then
            PropHP.RepairAllDestroyedProps(raid.defenderParty)
        end
    end)
    
    -- Raid verilerini temizle
    local attackerData = PropHP.GetPartyData(raid.attackerParty)
    local defenderData = PropHP.GetPartyData(raid.defenderParty)
    
    if attackerData then
        attackerData.raidStatus = nil
        attackerData.propsDestroyed = 0
    end
    
    if defenderData then
        defenderData.raidStatus = nil
        defenderData.propsDestroyed = 0
    end
    
    -- Katılımcıları temizle
    PropHP.RaidParticipants[raidID] = nil
    
    -- Cooldown ekle
    local cooldownKey = raid.attackerParty .. "_" .. raid.defenderParty
    PropHP.RaidCooldowns[cooldownKey] = CurTime()
    
    -- Timer'ları temizle
    timer.Remove("PropHP_PrepTimer_" .. raidID)
    timer.Remove("PropHP_UpdateTimer_" .. raidID)
    timer.Remove("PropHP_EndTimer_" .. raidID)
    
    -- Bildirim
    local winnerParty = winner == "attacker" and raid.attackerParty or raid.defenderParty
    local loserParty = winner == "attacker" and raid.defenderParty or raid.attackerParty
    
    local winnerName = parties[winnerParty] and parties[winnerParty].name or "???"
    local loserName = parties[loserParty] and parties[loserParty].name or "???"
    
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("[RAID] Raid sona erdi! Kazanan: " .. winnerName .. " | Kaybeden: " .. loserName)
    end
    
    -- Network
    net.Start("PropHP_RaidEnd")
        net.WriteString(winner)
        net.WriteString(winnerParty)
        net.WriteString(loserParty)
    net.Broadcast()
    
    -- Global raid'i kaldır
    PropHP.ActiveRaids[raidID] = nil
end

-- ============================
-- ÖDÜL SİSTEMİ (SADECE BİLDİRİM)
-- ============================
function PropHP.RaidSystem.DistributeRewards(raid, winner)
    local winnerParty = winner == "attacker" and raid.attackerParty or raid.defenderParty
    local loserParty = winner == "attacker" and raid.defenderParty or raid.attackerParty
    
    -- Sadece kazananı bildir, para transferi yok
    if parties[winnerParty] then
        for _, steamID in pairs(parties[winnerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                member:ChatPrint("Tebrikler! Raid'i kazandınız!")
            end
        end
    end
    
    if parties[loserParty] then
        for _, steamID in pairs(parties[loserParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                member:ChatPrint("Raid'i kaybettiniz!")
            end
        end
    end
end

-- ============================
-- OYUNCU ÖLÜM KONTROLÜ (NLR)
-- ============================
hook.Add("PlayerDeath", "PropHP_RaidDeathCheck", function(victim, inflictor, attacker)
    local victimSteamID = victim:SteamID64()
    
    -- Aktif raid'leri kontrol et
    for raidID, raid in pairs(PropHP.ActiveRaids) do
        local participants = PropHP.RaidParticipants[raidID]
        if participants then
            -- Saldıran mı?
            if participants.attackers[victimSteamID] then
                participants.attackers[victimSteamID].alive = false
                participants.attackers[victimSteamID].deaths = (participants.attackers[victimSteamID].deaths or 0) + 1
                victim:ChatPrint("Raid'den çıkarıldınız! (NLR Kuralı)")
                victim:ChatPrint("Raid bitene kadar kimseye hasar veremezsiniz!")
                
                -- Güncelle
                PropHP.RaidSystem.UpdateParticipants(raidID)
                
                -- Parti tamamen öldü mü kontrol et
                timer.Simple(0.5, function()
                    if PropHP.ActiveRaids[raidID] then
                        PropHP.RaidSystem.UpdateRaidTimer(raidID)
                    end
                end)
            end
            
            -- Savunan mı?
            if participants.defenders[victimSteamID] then
                participants.defenders[victimSteamID].alive = false
                participants.defenders[victimSteamID].deaths = (participants.defenders[victimSteamID].deaths or 0) + 1
                victim:ChatPrint("Raid'den çıkarıldınız! (NLR Kuralı)")
                victim:ChatPrint("Raid bitene kadar kimseye hasar veremezsiniz!")
                
                -- Güncelle
                PropHP.RaidSystem.UpdateParticipants(raidID)
                
                -- Parti tamamen öldü mü kontrol et
                timer.Simple(0.5, function()
                    if PropHP.ActiveRaids[raidID] then
                        PropHP.RaidSystem.UpdateRaidTimer(raidID)
                    end
                end)
            end
        end
    end
end)

-- ============================
-- OYUNCU SPAWN KONTROLÜ (NLR UYARI)
-- ============================
hook.Add("PlayerSpawn", "PropHP_PreventNLR", function(ply)
    local steamID = ply:SteamID64()
    
    -- Aktif raid'leri kontrol et
    for raidID, raid in pairs(PropHP.ActiveRaids) do
        local participants = PropHP.RaidParticipants[raidID]
        if participants then
            -- Ölen kişi raid'e katılamaz
            if participants.attackers[steamID] and not participants.attackers[steamID].alive then
                ply:ChatPrint("NLR kuralı nedeniyle raid'e katılamazsınız!")
                ply:ChatPrint("Raid bitene kadar kimseye hasar veremezsiniz!")
            end
            if participants.defenders[steamID] and not participants.defenders[steamID].alive then
                ply:ChatPrint("NLR kuralı nedeniyle raid'e katılamazsınız!")
                ply:ChatPrint("Raid bitene kadar kimseye hasar veremezsiniz!")
            end
        end
    end
end)

-- ============================
-- E TUŞU İLE PROP'DAN RAID BAŞLATMA
-- ============================
local propUseRaidCooldown = {}

hook.Add("PlayerUse", "PropHP_RaidOnUse", function(ply, ent)
    -- Temel kontroller
    if not IsValid(ent) or ent:GetClass() != "prop_physics" then return end
    
    -- Prop'un partisi var mı?
    local targetParty = ent:GetNWString("PropOwnerParty", "")
    if targetParty == "" then return end
    
    -- Oyuncunun partisi var mı ve lider mi?
    local attackerParty = ply:GetParty()
    if not attackerParty then
        ply:ChatPrint("Raid başlatmak için bir partiye üye olmalısınız!")
        return
    end
    
    if attackerParty != ply:SteamID64() then
        ply:ChatPrint("Sadece parti lideri raid başlatabilir!")
        return
    end
    
    -- Kendi partisine raid açmasın
    if targetParty == attackerParty then
        return
    end
    
    -- Cooldown kontrolü (spam önleme)
    local cooldownKey = ply:SteamID64() .. "_prop_raid"
    if propUseRaidCooldown[cooldownKey] and CurTime() - propUseRaidCooldown[cooldownKey] < 3 then
        return
    end
    propUseRaidCooldown[cooldownKey] = CurTime()
    
    -- Raid atılabilir mi kontrol et
    local canRaid, reason = PropHP.RaidSystem.CanStartRaid(attackerParty, targetParty)
    
    if not canRaid then
        ply:ChatPrint(reason)
        return
    end
    
    -- Parti isimlerini al
    local targetPartyName = parties[targetParty] and parties[targetParty].name or "???"
    local attackerPartyName = parties[attackerParty] and parties[attackerParty].name or "???"
    
    -- Client'a onay menüsü gönder
    net.Start("PropHP_PropRaidPrompt")
        net.WriteString(targetParty)
        net.WriteString(targetPartyName)
        net.WriteEntity(ent)
    net.Send(ply)
end)

-- ============================
-- CHAT KOMUTLARI
-- ============================
hook.Add("PlayerSay", "PropHP_ChatCommands", function(ply, text)
    local args = string.Explode(" ", text:lower())
    
    if args[1] == "!raid" then
        -- Parti menüsünü aç ve raid sekmesine git
        net.Start("PropHP_OpenRaidMenu")
        net.Send(ply)
        
        return ""
        
    elseif args[1] == "!raidiptal" then
        PropHP.RaidSystem.CancelRaid(ply)
        return ""
        
    elseif args[1] == "!prophp" then
        local partyID = ply:GetParty()
        
        if not partyID then
            ply:ChatPrint("Bir partiye üye değilsiniz!")
            return ""
        end
        
        local data = PropHP.GetPartyData(partyID)
        
        -- Sağlam ve ghost prop sayılarını hesapla
        local aliveProps = 0
        local ghostProps = 0
        
        for _, prop in pairs(data.props) do
            if IsValid(prop) then
                if prop:GetNWBool("PropDestroyed", false) then
                    ghostProps = ghostProps + 1
                else
                    aliveProps = aliveProps + 1
                end
            end
        end
        
        ply:ChatPrint("HP Havuzu: " .. string.Comma(data.totalPool))
        ply:ChatPrint("Toplam Prop: " .. #data.props .. " (Sağlam: " .. aliveProps .. ", Ghost: " .. ghostProps .. ")")
        ply:ChatPrint("HP/Prop: " .. string.Comma(math.floor(data.totalPool / math.max(#data.props, 1))))
        
        -- Raid durumu
        if data.raidStatus then
            if data.raidStatus.preparation then
                ply:ChatPrint("Raid hazırlık aşamasında! (Prop koyabilirsiniz)")
            elseif data.raidStatus.active then
                ply:ChatPrint("Raid aktif! (Prop koyamazsınız)")
            elseif data.raidStatus.lootingPhase then
                ply:ChatPrint("Yağma aşamasında! (Prop koyamazsınız)")
            end
        end
        
        return ""
        
    elseif args[1] == "!raidstatus" and ply:IsSuperAdmin() then
        -- Admin debug komutu
        ply:ChatPrint("=== AKTİF RAID'LER ===")
        for raidID, raid in pairs(PropHP.ActiveRaids) do
            local status = raid.lootingPhase and "YAĞMA" or (raid.active and "AKTİF" or "HAZIRLIK")
            ply:ChatPrint(raidID .. ": " .. status)
            
            local participants = PropHP.RaidParticipants[raidID]
            if participants then
                local attackerAlive = 0
                local defenderAlive = 0
                
                for _, data in pairs(participants.attackers) do
                    if data.alive then attackerAlive = attackerAlive + 1 end
                end
                
                for _, data in pairs(participants.defenders) do
                    if data.alive then defenderAlive = defenderAlive + 1 end
                end
                
                ply:ChatPrint("  Saldıran: " .. attackerAlive .. " yaşıyor")
                ply:ChatPrint("  Savunan: " .. defenderAlive .. " yaşıyor")
            end
        end
        return ""
    end
end)

-- ============================
-- NETWORK RECEIVERS
-- ============================
net.Receive("PropHP_RaidRequest", function(len, ply)
    local targetParty = net.ReadString()
    local attackerParty = ply:GetParty()
    
    if not attackerParty or attackerParty != ply:SteamID64() then
        ply:ChatPrint("Parti lideri değilsiniz!")
        return
    end
    
    local canRaid, reason = PropHP.RaidSystem.CanStartRaid(attackerParty, targetParty)
    
    if canRaid then
        PropHP.RaidSystem.StartRaid(attackerParty, targetParty)
        ply:ChatPrint("Raid başlatıldı!")
    else
        ply:ChatPrint(reason)
    end
end)

-- RAID İPTAL NETWORK RECEIVER
net.Receive("PropHP_CancelRaid", function(len, ply)
    PropHP.RaidSystem.CancelRaid(ply)
end)

-- Sistem yüklendi bildirimi
print("[PropHP] Raid sistemi yüklendi - v2.4 E tuşu ile raid")