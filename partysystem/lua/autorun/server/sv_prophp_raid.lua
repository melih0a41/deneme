-- Raid System - Server Side
-- Dosya Yolu: lua/autorun/server/sv_prophp_raid.lua

PropHP.RaidSystem = PropHP.RaidSystem or {}
PropHP.ActiveRaids = PropHP.ActiveRaids or {}
PropHP.RaidCooldowns = PropHP.RaidCooldowns or {}
PropHP.RaidParticipants = PropHP.RaidParticipants or {}  -- Raid'e katılanlar

util.AddNetworkString("PropHP_RaidRequest")
util.AddNetworkString("PropHP_RaidStart")
util.AddNetworkString("PropHP_RaidEnd")
util.AddNetworkString("PropHP_RaidTimer")
util.AddNetworkString("PropHP_OpenRaidMenu")
util.AddNetworkString("PropHP_UpdateRaidParticipants")
util.AddNetworkString("PropHP_LootingPhase")

-- ============================
-- RAID FONKSİYONLARI
-- ============================
function PropHP.IsInRaid(attackerParty, defenderParty)
    if not attackerParty or not defenderParty then return false end
    
    local attackerData = PropHP.GetPartyData(attackerParty)
    local defenderData = PropHP.GetPartyData(defenderParty)
    
    if not attackerData or not defenderData then return false end
    
    if attackerData.raidStatus and attackerData.raidStatus.targetParty == defenderParty then
        return attackerData.raidStatus.active
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
    
    -- Online üye kontrolü
    local attackerOnline = 0
    local defenderOnline = 0
    
    for _, steamID in pairs(attackerPartyData.members) do
        if IsValid(player.GetBySteamID64(steamID)) then
            attackerOnline = attackerOnline + 1
        end
    end
    
    for _, steamID in pairs(defenderPartyData.members) do
        if IsValid(player.GetBySteamID64(steamID)) then
            defenderOnline = defenderOnline + 1
        end
    end
    
    -- Minimum üye kontrolü
    if attackerOnline < PropHP.Config.Raid.MinPartyMembers then
        return false, "En az " .. PropHP.Config.Raid.MinPartyMembers .. " online üye gerekli!"
    end
    
    if defenderOnline < 1 then
        return false, "Savunan partide en az 1 online üye olmalı!"
    end
    
    -- Üye farkı kontrolü
    if math.abs(attackerOnline - defenderOnline) > PropHP.Config.Raid.MaxMemberDifference then
        return false, "Üye sayıları çok dengesiz!"
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
    if #defenderData.props < 1 then
        return false, "Savunan partinin prop'u yok!"
    end
    
    return true, "OK"
end

-- ============================
-- RAID BAŞLATMA
-- ============================
function PropHP.RaidSystem.StartRaid(attackerParty, defenderParty)
    local attackerData = PropHP.GetPartyData(attackerParty)
    local defenderData = PropHP.GetPartyData(defenderParty)
    
    -- Raid ID
    local raidID = "raid_" .. CurTime()
    
    -- Raid katılımcılarını kaydet
    PropHP.RaidParticipants[raidID] = {
        attackers = {},
        defenders = {}
    }
    
    -- Saldıran parti üyelerini ekle
    for _, steamID in pairs(parties[attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) and member:Alive() then
            PropHP.RaidParticipants[raidID].attackers[steamID] = {
                nick = member:Nick(),
                alive = true
            }
        end
    end
    
    -- Savunan parti üyelerini ekle
    for _, steamID in pairs(parties[defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) and member:Alive() then
            PropHP.RaidParticipants[raidID].defenders[steamID] = {
                nick = member:Nick(),
                alive = true
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
        startTime = CurTime(),
        endTime = CurTime() + PropHP.Config.Raid.PreparationTime + PropHP.Config.Raid.RaidDuration
    }
    
    -- Global raid
    PropHP.ActiveRaids[raidID] = {
        attackerParty = attackerParty,
        defenderParty = defenderParty,
        startTime = CurTime(),
        active = false,
        lootingPhase = false  -- Yağma aşaması
    }
    
    -- Bildirimleri gönder
    PropHP.RaidSystem.NotifyRaidStart(attackerParty, defenderParty, true)
    PropHP.RaidSystem.UpdateParticipants(raidID)
    
    -- Hazırlık timer'ı
    timer.Create("PropHP_PrepTimer_" .. raidID, PropHP.Config.Raid.PreparationTime, 1, function()
        PropHP.RaidSystem.ActivateRaid(raidID)
    end)
    
    -- Update timer
    timer.Create("PropHP_UpdateTimer_" .. raidID, 1, 0, function()
        PropHP.RaidSystem.UpdateRaidTimer(raidID)
    end)
end

-- ============================
-- RAID KATILIMCI GÜNCELLEMESİ
-- ============================
function PropHP.RaidSystem.UpdateParticipants(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then return end
    
    local participants = PropHP.RaidParticipants[raidID]
    if not participants then return end
    
    -- Tüm raid üyelerine gönder
    local allMembers = {}
    
    for _, steamID in pairs(parties[raid.attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
        end
    end
    
    for _, steamID in pairs(parties[raid.defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
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
    for _, steamID in pairs(parties[attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
            if preparation then
                member:ChatPrint("⏰ RAID HAZIRLANIYOR! " .. PropHP.Config.Raid.PreparationTime/60 .. " dakika hazırlık süresi!")
            else
                member:ChatPrint("⚔️ RAID BAŞLADI! Saldırıya geçin!")
                member:EmitSound("buttons/button17.wav")
            end
        end
    end
    
    -- Savunan parti
    for _, steamID in pairs(parties[defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
            if preparation then
                member:ChatPrint("⚠️ RAID UYARISI! " .. PropHP.Config.Raid.PreparationTime/60 .. " dakika hazırlanın!")
            else
                member:ChatPrint("🛡️ RAID BAŞLADI! Savunma pozisyonu!")
                member:EmitSound("ambient/alarms/warningbell1.wav")
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
-- RAID TIMER UPDATE
-- ============================
function PropHP.RaidSystem.UpdateRaidTimer(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then 
        timer.Remove("PropHP_UpdateTimer_" .. raidID)
        return 
    end
    
    -- Katılımcı kontrolü
    local participants = PropHP.RaidParticipants[raidID]
    if participants then
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
        
        -- Eğer bir taraf tamamen ölmüşse raid'i bitir
        if raid.active and not raid.lootingPhase and (attackerAlive == 0 or defenderAlive == 0) then
            local winner = attackerAlive > 0 and "attacker" or "defender"
            local reason = attackerAlive == 0 and "💀 Saldıran parti yok edildi!" or "💀 Savunan parti yok edildi!"
            
            -- Bildirim
            for _, ply in pairs(player.GetAll()) do
                ply:ChatPrint(reason)
            end
            
            PropHP.RaidSystem.EndRaid(raidID, winner)
            return
        end
    end
    
    -- Normal timer güncellemesi
    local allMembers = {}
    
    for _, steamID in pairs(parties[raid.attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
        end
    end
    
    for _, steamID in pairs(parties[raid.defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
        end
    end
    
    local timeLeft = 0
    local isPrep = not raid.active
    
    if raid.lootingPhase then
        -- Yağma aşaması timer'ı
        timeLeft = 180 - (CurTime() - raid.lootingStartTime)  -- 3 dakika
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
    
    -- Eğer yağma aşaması yoksa başlat
    if not raid.lootingPhase and forceWinner == "attacker" then
        raid.lootingPhase = true
        raid.lootingStartTime = CurTime()
        raid.active = false  -- Raid bitti ama yağma başladı
        
        -- Yağma bildirimi
        for _, steamID in pairs(parties[raid.attackerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                member:ChatPrint("💰 YAĞMA BAŞLADI! 3 dakikanız var!")
            end
        end
        
        for _, steamID in pairs(parties[raid.defenderParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                member:ChatPrint("⏰ Saldıranlar yağmalıyor! 3 dakika sonra prop'lar tamir olacak.")
            end
        end
        
        -- Network bildirimi
        local allMembers = {}
        for _, steamID in pairs(parties[raid.attackerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then table.insert(allMembers, member) end
        end
        for _, steamID in pairs(parties[raid.defenderParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then table.insert(allMembers, member) end
        end
        
        net.Start("PropHP_LootingPhase")
            net.WriteBool(true)
        net.Send(allMembers)
        
        -- 3 dakika sonra tamamen bitir
        timer.Create("PropHP_LootingTimer_" .. raidID, 180, 1, function()
            PropHP.RaidSystem.FinalizeRaid(raidID)
        end)
        
        return
    end
    
    -- Direkt bitir (savunanlar kazandı veya yağma bitti)
    PropHP.RaidSystem.FinalizeRaid(raidID)
end

-- ============================
-- RAID TAMAMEN BİTİR
-- ============================
function PropHP.RaidSystem.FinalizeRaid(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then return end
    
    local attackerData = PropHP.GetPartyData(raid.attackerParty)
    local defenderData = PropHP.GetPartyData(raid.defenderParty)
    
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
    timer.Remove("PropHP_LootingTimer_" .. raidID)
    
    -- Bildirim
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("📢 RAID TAMAMEN SONA ERDİ!")
    end
    
    -- Global raid'i kaldır
    PropHP.ActiveRaids[raidID] = nil
end

-- ============================
-- OYUNCU ÖLÜM KONTROLÜ (NLR)
-- ============================
hook.Add("PlayerDeath", "PropHP_CheckRaidOnDeath", function(victim, inflictor, attacker)
    -- Aktif raid'leri kontrol et
    for raidID, raid in pairs(PropHP.ActiveRaids) do
        local participants = PropHP.RaidParticipants[raidID]
        if participants and raid.active then
            local victimSteamID = victim:SteamID64()
            
            -- Saldıran mı?
            if participants.attackers[victimSteamID] then
                participants.attackers[victimSteamID].alive = false
                victim:ChatPrint("☠️ Raid'den çıkarıldınız! (NLR Kuralı)")
                PropHP.RaidSystem.UpdateParticipants(raidID)
            end
            
            -- Savunan mı?
            if participants.defenders[victimSteamID] then
                participants.defenders[victimSteamID].alive = false
                victim:ChatPrint("☠️ Raid'den çıkarıldınız! (NLR Kuralı)")
                PropHP.RaidSystem.UpdateParticipants(raidID)
            end
        end
    end
end)

-- ============================
-- OYUNCU SPAWN KONTROLÜ (NLR ENGELLEME)
-- ============================
hook.Add("PlayerSpawn", "PropHP_PreventNLR", function(ply)
    local steamID = ply:SteamID64()
    
    -- Aktif raid'leri kontrol et
    for raidID, raid in pairs(PropHP.ActiveRaids) do
        local participants = PropHP.RaidParticipants[raidID]
        if participants and (raid.active or raid.lootingPhase) then
            -- Ölen kişi raid'e katılamaz
            if participants.attackers[steamID] and not participants.attackers[steamID].alive then
                ply:ChatPrint("⚠️ NLR kuralı nedeniyle raid'e katılamazsınız!")
            end
            if participants.defenders[steamID] and not participants.defenders[steamID].alive then
                ply:ChatPrint("⚠️ NLR kuralı nedeniyle raid'e katılamazsınız!")
            end
        end
    end
end)

-- ============================
-- CHAT KOMUTLARI
-- ============================
hook.Add("PlayerSay", "PropHP_ChatCommands", function(ply, text)
    local args = string.Explode(" ", text:lower())
    
    if args[1] == "!raid" then
        local partyID = ply:GetParty()
        
        if not partyID then
            ply:ChatPrint("❌ Bir partiye üye değilsiniz!")
            return ""
        end
        
        if partyID != ply:SteamID64() then
            ply:ChatPrint("❌ Sadece parti lideri raid başlatabilir!")
            return ""
        end
        
        net.Start("PropHP_OpenRaidMenu")
        net.Send(ply)
        return ""
        
    elseif args[1] == "!prophp" then
        local partyID = ply:GetParty()
        
        if not partyID then
            ply:ChatPrint("❌ Bir partiye üye değilsiniz!")
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
        
        ply:ChatPrint("📊 HP Havuzu: " .. string.Comma(data.totalPool))
        ply:ChatPrint("📦 Toplam Prop: " .. #data.props .. " (Sağlam: " .. aliveProps .. ", Ghost: " .. ghostProps .. ")")
        ply:ChatPrint("💗 HP/Prop: " .. string.Comma(math.floor(data.totalPool / math.max(#data.props, 1))))
        
        return ""
    end
end)

-- Raid isteği
net.Receive("PropHP_RaidRequest", function(len, ply)
    local targetParty = net.ReadString()
    local attackerParty = ply:GetParty()
    
    if not attackerParty or attackerParty != ply:SteamID64() then
        ply:ChatPrint("❌ Parti lideri değilsiniz!")
        return
    end
    
    local canRaid, reason = PropHP.RaidSystem.CanStartRaid(attackerParty, targetParty)
    
    if canRaid then
        PropHP.RaidSystem.StartRaid(attackerParty, targetParty)
        ply:ChatPrint("✅ Raid başlatıldı!")
    else
        ply:ChatPrint("❌ " .. reason)
    end
end)-- Raid System - Server Side
-- Dosya Yolu: lua/autorun/server/sv_prophp_raid.lua

PropHP.RaidSystem = PropHP.RaidSystem or {}
PropHP.ActiveRaids = PropHP.ActiveRaids or {}
PropHP.RaidCooldowns = PropHP.RaidCooldowns or {}

util.AddNetworkString("PropHP_RaidRequest")
util.AddNetworkString("PropHP_RaidStart")
util.AddNetworkString("PropHP_RaidEnd")
util.AddNetworkString("PropHP_RaidTimer")
util.AddNetworkString("PropHP_OpenRaidMenu")

-- ============================
-- RAID FONKSİYONLARI
-- ============================
function PropHP.IsInRaid(attackerParty, defenderParty)
    if not attackerParty or not defenderParty then return false end
    
    local attackerData = PropHP.GetPartyData(attackerParty)
    local defenderData = PropHP.GetPartyData(defenderParty)
    
    if not attackerData or not defenderData then return false end
    
    if attackerData.raidStatus and attackerData.raidStatus.targetParty == defenderParty then
        return attackerData.raidStatus.active
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
    
    -- Online üye kontrolü
    local attackerOnline = 0
    local defenderOnline = 0
    
    for _, steamID in pairs(attackerPartyData.members) do
        if IsValid(player.GetBySteamID64(steamID)) then
            attackerOnline = attackerOnline + 1
        end
    end
    
    for _, steamID in pairs(defenderPartyData.members) do
        if IsValid(player.GetBySteamID64(steamID)) then
            defenderOnline = defenderOnline + 1
        end
    end
    
    -- Minimum üye kontrolü
    if attackerOnline < PropHP.Config.Raid.MinPartyMembers then
        return false, "En az " .. PropHP.Config.Raid.MinPartyMembers .. " online üye gerekli!"
    end
    
    if defenderOnline < 1 then
        return false, "Savunan partide en az 1 online üye olmalı!"
    end
    
    -- Üye farkı kontrolü
    if math.abs(attackerOnline - defenderOnline) > PropHP.Config.Raid.MaxMemberDifference then
        return false, "Üye sayıları çok dengesiz!"
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
    if #defenderData.props < 1 then
        return false, "Savunan partinin prop'u yok!"
    end
    
    return true, "OK"
end

-- ============================
-- RAID BAŞLATMA
-- ============================
function PropHP.RaidSystem.StartRaid(attackerParty, defenderParty)
    local attackerData = PropHP.GetPartyData(attackerParty)
    local defenderData = PropHP.GetPartyData(defenderParty)
    
    -- Raid ID
    local raidID = "raid_" .. CurTime()
    
    -- Raid verisi
    attackerData.raidStatus = {
        raidID = raidID,
        targetParty = defenderParty,
        isAttacker = true,
        isDefender = false,
        active = false,
        preparation = true,
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
        startTime = CurTime(),
        endTime = CurTime() + PropHP.Config.Raid.PreparationTime + PropHP.Config.Raid.RaidDuration
    }
    
    -- Global raid
    PropHP.ActiveRaids[raidID] = {
        attackerParty = attackerParty,
        defenderParty = defenderParty,
        startTime = CurTime(),
        active = false
    }
    
    -- Bildirimleri gönder
    PropHP.RaidSystem.NotifyRaidStart(attackerParty, defenderParty, true)
    
    -- Hazırlık timer'ı
    timer.Create("PropHP_PrepTimer_" .. raidID, PropHP.Config.Raid.PreparationTime, 1, function()
        PropHP.RaidSystem.ActivateRaid(raidID)
    end)
    
    -- Update timer
    timer.Create("PropHP_UpdateTimer_" .. raidID, 1, 0, function()
        PropHP.RaidSystem.UpdateRaidTimer(raidID)
    end)
end

-- ============================
-- RAID AKTİVASYONU
-- ============================
function PropHP.RaidSystem.ActivateRaid(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then return end
    
    raid.active = true
    
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
    for _, steamID in pairs(parties[attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
            if preparation then
                member:ChatPrint("⏰ RAID HAZIRLANIYOR! " .. PropHP.Config.Raid.PreparationTime/60 .. " dakika hazırlık süresi!")
            else
                member:ChatPrint("⚔️ RAID BAŞLADI! Saldırıya geçin!")
                member:EmitSound("buttons/button17.wav")
            end
        end
    end
    
    -- Savunan parti
    for _, steamID in pairs(parties[defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
            if preparation then
                member:ChatPrint("⚠️ RAID UYARISI! " .. PropHP.Config.Raid.PreparationTime/60 .. " dakika hazırlanın!")
            else
                member:ChatPrint("🛡️ RAID BAŞLADI! Savunma pozisyonu!")
                member:EmitSound("ambient/alarms/warningbell1.wav")
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
-- RAID TIMER UPDATE
-- ============================
function PropHP.RaidSystem.UpdateRaidTimer(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid then 
        timer.Remove("PropHP_UpdateTimer_" .. raidID)
        return 
    end
    
    -- Parti üyelerini kontrol et
    local attackerAlive = false
    local defenderAlive = false
    
    -- Saldıran parti kontrolü
    for _, steamID in pairs(parties[raid.attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) and member:Alive() then
            attackerAlive = true
            break
        end
    end
    
    -- Savunan parti kontrolü
    for _, steamID in pairs(parties[raid.defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) and member:Alive() then
            defenderAlive = true
            break
        end
    end
    
    -- Eğer bir taraf tamamen öldüyse raid'i bitir
    if raid.active and (not attackerAlive or not defenderAlive) then
        local reason = ""
        local winner = nil
        
        if not attackerAlive and not defenderAlive then
            reason = "Her iki parti de yok edildi! Berabere!"
            winner = "defender" -- Berabere durumunda savunan kazanır
        elseif not attackerAlive then
            reason = "Saldıran parti yok edildi! Savunanlar kazandı!"
            winner = "defender"
        else
            reason = "Savunan parti yok edildi! Saldıranlar kazandı!"
            winner = "attacker"
        end
        
        -- Tüm üyelere bildir
        for _, steamID in pairs(parties[raid.attackerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                member:ChatPrint("⚠️ " .. reason)
            end
        end
        
        for _, steamID in pairs(parties[raid.defenderParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) then
                member:ChatPrint("⚠️ " .. reason)
            end
        end
        
        -- Raid'i bitir (kazananı belirterek)
        PropHP.RaidSystem.EndRaid(raidID, winner)
        return
    end
    
    -- Normal timer güncellemesi
    local allMembers = {}
    
    for _, steamID in pairs(parties[raid.attackerParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
        end
    end
    
    for _, steamID in pairs(parties[raid.defenderParty].members) do
        local member = player.GetBySteamID64(steamID)
        if IsValid(member) then
            table.insert(allMembers, member)
        end
    end
    
    local timeLeft = 0
    local isPrep = not raid.active
    
    if isPrep then
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
        -- Zorla kazanan belirlendi (parti yok edildi)
        winner = forceWinner
    else
        -- Normal kazanan belirleme (prop bazlı)
        if defenderData and defenderData.propsDestroyed >= PropHP.Config.Raid.MinPropsToWin then
            winner = "attacker"
        end
    end
    
    -- Ödülleri dağıt
    PropHP.RaidSystem.DistributeRewards(raid, winner)
    
    -- Yok edilmiş prop'ları tamir et (2 saniye sonra)
    timer.Simple(2, function()
        if PropHP.PartyData[raid.attackerParty] then
            PropHP.RepairAllDestroyedProps(raid.attackerParty)
        end
        if PropHP.PartyData[raid.defenderParty] then
            PropHP.RepairAllDestroyedProps(raid.defenderParty)
        end
    end)
    
    -- Raid verilerini temizle
    if attackerData then
        attackerData.raidStatus = nil
        attackerData.propsDestroyed = 0
    end
    
    if defenderData then
        defenderData.raidStatus = nil
        defenderData.propsDestroyed = 0
    end
    
    -- Cooldown ekle
    local cooldownKey = raid.attackerParty .. "_" .. raid.defenderParty
    PropHP.RaidCooldowns[cooldownKey] = CurTime()
    
    -- Timer'ları temizle
    timer.Remove("PropHP_PrepTimer_" .. raidID)
    timer.Remove("PropHP_UpdateTimer_" .. raidID)
    timer.Remove("PropHP_EndTimer_" .. raidID)
    
    -- Global raid'i kaldır
    PropHP.ActiveRaids[raidID] = nil
end

-- ============================
-- ÖDÜL SİSTEMİ
-- ============================
function PropHP.RaidSystem.DistributeRewards(raid, winner)
    local winnerParty = winner == "attacker" and raid.attackerParty or raid.defenderParty
    local loserParty = winner == "attacker" and raid.defenderParty or raid.attackerParty
    
    -- DarkRP para transferi
    if DarkRP then
        local totalLoot = 0
        
        -- Kaybeden partinin parasını hesapla
        for _, steamID in pairs(parties[loserParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) and member.getDarkRPVar then
                local money = member:getDarkRPVar("money") or 0
                local loss = math.floor(money * (PropHP.Config.Raid.WinnerTakesPercent / 100))
                totalLoot = totalLoot + loss
                
                if member.addMoney then
                    member:addMoney(-loss)
                    member:ChatPrint("💸 Raid kaybı: $" .. string.Comma(loss))
                end
            end
        end
        
        -- Kazananlara dağıt
        local winnerCount = 0
        for _, steamID in pairs(parties[winnerParty].members) do
            if IsValid(player.GetBySteamID64(steamID)) then
                winnerCount = winnerCount + 1
            end
        end
        
        if winnerCount > 0 then
            local perPlayer = math.floor(totalLoot / winnerCount)
            
            for _, steamID in pairs(parties[winnerParty].members) do
                local member = player.GetBySteamID64(steamID)
                if IsValid(member) and member.addMoney then
                    member:addMoney(perPlayer)
                    member:ChatPrint("💰 Raid kazancı: $" .. string.Comma(perPlayer))
                end
            end
        end
    end
    
    -- Sonuç bildirimi
    local winnerName = parties[winnerParty].name
    local loserName = parties[loserParty].name
    
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("📢 RAID BİTTİ! Kazanan: " .. winnerName .. " | Kaybeden: " .. loserName)
    end
    
    -- Network
    net.Start("PropHP_RaidEnd")
        net.WriteString(winner)
        net.WriteString(winnerParty)
        net.WriteString(loserParty)
    net.Broadcast()
end

-- ============================
-- CHAT KOMUTLARI
-- ============================
hook.Add("PlayerSay", "PropHP_ChatCommands", function(ply, text)
    local args = string.Explode(" ", text:lower())
    
    if args[1] == "!raid" then
        local partyID = ply:GetParty()
        
        if not partyID then
            ply:ChatPrint("❌ Bir partiye üye değilsiniz!")
            return ""
        end
        
        if partyID != ply:SteamID64() then
            ply:ChatPrint("❌ Sadece parti lideri raid başlatabilir!")
            return ""
        end
        
        net.Start("PropHP_OpenRaidMenu")
        net.Send(ply)
        return ""
        
    elseif args[1] == "!prophp" then
        local partyID = ply:GetParty()
        
        if not partyID then
            ply:ChatPrint("❌ Bir partiye üye değilsiniz!")
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
        
        ply:ChatPrint("📊 HP Havuzu: " .. string.Comma(data.totalPool))
        ply:ChatPrint("📦 Toplam Prop: " .. #data.props .. " (Sağlam: " .. aliveProps .. ", Ghost: " .. ghostProps .. ")")
        ply:ChatPrint("💗 HP/Prop: " .. string.Comma(math.floor(data.totalPool / math.max(#data.props, 1))))
        
        return ""
    end
end)

-- ============================
-- OYUNCU ÖLÜM KONTROLÜ
-- ============================
hook.Add("PlayerDeath", "PropHP_CheckRaidOnDeath", function(victim, inflictor, attacker)
    -- Victim'in partisi var mı kontrol et
    local victimParty = victim:GetParty()
    if not victimParty then return end
    
    -- Aktif raid var mı kontrol et
    for raidID, raid in pairs(PropHP.ActiveRaids) do
        -- Bu parti raid'de mi?
        if raid.active and (raid.attackerParty == victimParty or raid.defenderParty == victimParty) then
            -- 0.5 saniye sonra kontrol et (respawn olabilir)
            timer.Simple(0.5, function()
                if PropHP.ActiveRaids[raidID] then
                    PropHP.RaidSystem.CheckPartyStatus(raidID)
                end
            end)
            break
        end
    end
end)

-- ============================
-- PARTİ DURUMU KONTROLÜ
-- ============================
function PropHP.RaidSystem.CheckPartyStatus(raidID)
    local raid = PropHP.ActiveRaids[raidID]
    if not raid or not raid.active then return end
    
    -- Parti üyelerini kontrol et
    local attackerAlive = false
    local defenderAlive = false
    
    -- Saldıran parti kontrolü
    if parties[raid.attackerParty] then
        for _, steamID in pairs(parties[raid.attackerParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) and member:Alive() then
                attackerAlive = true
                break
            end
        end
    end
    
    -- Savunan parti kontrolü
    if parties[raid.defenderParty] then
        for _, steamID in pairs(parties[raid.defenderParty].members) do
            local member = player.GetBySteamID64(steamID)
            if IsValid(member) and member:Alive() then
                defenderAlive = true
                break
            end
        end
    end
    
    -- Eğer bir taraf tamamen öldüyse raid'i bitir
    if not attackerAlive or not defenderAlive then
        local reason = ""
        local winner = nil
        
        if not attackerAlive and not defenderAlive then
            reason = "💀 Her iki parti de yok edildi! Berabere!"
            winner = "defender"
        elseif not attackerAlive then
            reason = "💀 Saldıran parti yok edildi! Savunanlar kazandı!"
            winner = "defender"
        else
            reason = "💀 Savunan parti yok edildi! Saldıranlar kazandı!"
            winner = "attacker"
        end
        
        -- Tüm oyunculara bildir
        for _, ply in pairs(player.GetAll()) do
            ply:ChatPrint(reason)
        end
        
        -- Raid'i bitir
        PropHP.RaidSystem.EndRaid(raidID, winner)
    end
end

-- ============================
-- OYUNCU DISCONNECT KONTROLÜ
-- ============================
hook.Add("PlayerDisconnected", "PropHP_CheckRaidOnDisconnect", function(ply)
    local partyID = ply:GetParty()
    if not partyID then return end
    
    -- Aktif raid var mı kontrol et
    for raidID, raid in pairs(PropHP.ActiveRaids) do
        -- Bu parti raid'de mi?
        if raid.active and (raid.attackerParty == partyID or raid.defenderParty == partyID) then
            -- Biraz bekle sonra kontrol et
            timer.Simple(1, function()
                if PropHP.ActiveRaids[raidID] then
                    PropHP.RaidSystem.CheckPartyStatus(raidID)
                end
            end)
            break
        end
    end
end)

-- ============================
-- OYUNCU SPAWN KONTROLÜ
-- ============================
hook.Add("PlayerSpawn", "PropHP_CheckRaidOnSpawn", function(ply)
    local partyID = ply:GetParty()
    if not partyID then return end
    
    -- Aktif raid var mı kontrol et
    for raidID, raid in pairs(PropHP.ActiveRaids) do
        -- Bu parti raid'de mi?
        if raid.active and (raid.attackerParty == partyID or raid.defenderParty == partyID) then
            -- Parti üyelerine spawn bildirimi
            for _, steamID in pairs(parties[partyID].members) do
                local member = player.GetBySteamID64(steamID)
                if IsValid(member) then
                    member:ChatPrint("👥 " .. ply:Nick() .. " yeniden doğdu!")
                end
            end
            break
        end
    end
end)

-- Raid isteği
net.Receive("PropHP_RaidRequest", function(len, ply)
    local targetParty = net.ReadString()
    local attackerParty = ply:GetParty()
    
    if not attackerParty or attackerParty != ply:SteamID64() then
        ply:ChatPrint("❌ Parti lideri değilsiniz!")
        return
    end
    
    local canRaid, reason = PropHP.RaidSystem.CanStartRaid(attackerParty, targetParty)
    
    if canRaid then
        PropHP.RaidSystem.StartRaid(attackerParty, targetParty)
        ply:ChatPrint("✅ Raid başlatıldı!")
    else
        ply:ChatPrint("❌ " .. reason)
    end
end)