-- Prop HP System - Core Server Side
-- Dosya Yolu: lua/autorun/server/sv_prophp_core.lua
-- Versiyon: 3.0 - Tüm sorunlar düzeltildi

PropHP = PropHP or {}
PropHP.PartyData = PropHP.PartyData or {}
PropHP.UpdateQueue = PropHP.UpdateQueue or {}
PropHP.UpdateCache = PropHP.UpdateCache or {}
PropHP.NetworkThrottle = PropHP.NetworkThrottle or {}

-- Network strings
util.AddNetworkString("PropHP_UpdatePool")
util.AddNetworkString("PropHP_UpdatePropHP")
util.AddNetworkString("PropHP_DamageNumber")
util.AddNetworkString("PropHP_PropDestroyed")
util.AddNetworkString("PropHP_OpenRaidMenu")

-- ============================
-- NETWORK RATE LIMITING
-- ============================
function PropHP.CanSendNetwork(ply, actionType)
    local steamID = ply:SteamID64()
    PropHP.NetworkThrottle[steamID] = PropHP.NetworkThrottle[steamID] or {}
    
    local throttle = PropHP.NetworkThrottle[steamID]
    throttle[actionType] = throttle[actionType] or 0
    
    if CurTime() - throttle[actionType] < 0.1 then
        return false
    end
    
    throttle[actionType] = CurTime()
    return true
end

-- ============================
-- PARTİ HP HAVUZ YÖNETİMİ
-- ============================
function PropHP.GetPartyHPPool(partyID)
    if not partyID then return 0 end
    
    -- Parti liderini bul
    local leader = player.GetBySteamID64(partyID)
    if not IsValid(leader) then return 0 end
    
    -- Lider usergroup'una göre HP havuzu
    local usergroup = leader:GetUserGroup()
    return PropHP.Config.PartyHPPool[usergroup] or PropHP.Config.PartyHPPool["user"]
end

function PropHP.InitializeParty(partyID)
    local pool = PropHP.GetPartyHPPool(partyID)
    PropHP.PartyData[partyID] = {
        totalPool = pool,
        props = {},
        ghostProps = {}, -- Ghost propları ayrı tut
        raidStatus = nil,
        lastUpdate = CurTime(),
        propsDestroyed = 0,
        cacheValid = false
    }
    PropHP.UpdatePartyPool(partyID)
end

function PropHP.GetPartyData(partyID)
    if not PropHP.PartyData[partyID] then
        PropHP.InitializeParty(partyID)
    end
    return PropHP.PartyData[partyID]
end

-- ============================
-- CLEANUP FONKSİYONU
-- ============================
function PropHP.CleanupPartyData(partyID)
    if not partyID then return end
    
    -- Timer'ları temizle
    timer.Remove("PropHP_UpdateCache_" .. partyID)
    timer.Remove("PropHP_NetworkUpdate_" .. partyID)
    
    -- Cache'i temizle
    PropHP.UpdateCache[partyID] = nil
    
    -- Parti verisini temizle
    PropHP.PartyData[partyID] = nil
    
    -- Log
    if PropHP.Config.Debug.Enabled then
        print("[PropHP] Parti temizlendi: " .. partyID)
    end
end

-- ============================
-- HP DAĞITIM SİSTEMİ - OPTİMİZE EDİLDİ
-- ============================
function PropHP.RecalculatePropHP(partyID)
    local data = PropHP.GetPartyData(partyID)
    if not data then return end
    
    -- Cache kontrolü
    if data.cacheValid and CurTime() - data.lastUpdate < 0.5 then
        return -- Çok sık güncelleme yapma
    end
    
    -- Geçerli prop'ları temizle ve say
    local validProps = {}
    local totalActivePropCount = 0  -- Sadece SAĞLAM prop'lar
    
    for _, prop in pairs(data.props) do
        if IsValid(prop) then
            table.insert(validProps, prop)
            if not prop:GetNWBool("PropDestroyed", false) then
                totalActivePropCount = totalActivePropCount + 1
            end
        end
    end
    data.props = validProps
    
    -- Ghost propları temizle
    local validGhosts = {}
    for _, prop in pairs(data.ghostProps) do
        if IsValid(prop) then
            table.insert(validGhosts, prop)
        end
    end
    data.ghostProps = validGhosts
    
    if totalActivePropCount == 0 then 
        data.cacheValid = true
        data.lastUpdate = CurTime()
        PropHP.UpdatePartyPool(partyID)
        return 
    end
    
    -- HP'yi SADECE SAĞLAM PROP'LAR arasında böl
    local hpPerProp = math.floor(data.totalPool / totalActivePropCount)
    
    -- Minimum HP kontrolü
    if hpPerProp < PropHP.Config.MinPropHP then
        hpPerProp = PropHP.Config.MinPropHP
    end
    
    -- Her prop'a HP ata
    for _, prop in pairs(data.props) do
        if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
            local oldHP = prop:GetNWInt("PropHP", 0)
            local oldMaxHP = prop:GetNWInt("PropMaxHP", 0)
            
            -- HP oranını koru
            local healthPercent = 1
            if oldMaxHP > 0 then
                healthPercent = oldHP / oldMaxHP
            end
            
            prop:SetNWInt("PropMaxHP", hpPerProp)
            prop:SetNWInt("PropHP", math.floor(hpPerProp * healthPercent))
            prop:SetNWInt("PropReservedHP", hpPerProp)
            
            -- Renk güncelle
            PropHP.UpdatePropColor(prop)
        end
    end
    
    -- Cache'i güncelle
    data.cacheValid = true
    data.lastUpdate = CurTime()
    
    -- Network update (throttled)
    timer.Create("PropHP_NetworkUpdate_" .. partyID, 0.5, 1, function()
        PropHP.UpdatePartyPool(partyID)
    end)
end

-- ============================
-- PROP RENK SİSTEMİ - OPTİMİZE
-- ============================
function PropHP.UpdatePropColor(prop)
    if not IsValid(prop) then return end
    
    -- Yok edilmiş prop'ların rengini değiştirme
    if prop:GetNWBool("PropDestroyed", false) then return end
    
    local hp = prop:GetNWInt("PropHP", 0)
    local maxHP = prop:GetNWInt("PropMaxHP", 1)
    local percent = hp / maxHP
    
    -- Renk cache kontrolü
    local lastPercent = prop:GetNWFloat("LastColorPercent", -1)
    if math.abs(lastPercent - percent) < 0.05 then
        return -- Küçük değişikliklerde renk güncelleme
    end
    
    prop:SetNWFloat("LastColorPercent", percent)
    
    if percent > 0.75 then
        prop:SetColor(Color(255, 255, 255, 255))
    elseif percent > 0.5 then
        prop:SetColor(Color(255, 255, 200, 255))
    elseif percent > 0.25 then
        prop:SetColor(Color(255, 200, 100, 255))
    else
        prop:SetColor(Color(255, 100, 100, 255))
    end
    
    prop:SetRenderMode(RENDERMODE_TRANSCOLOR)
end

-- ============================
-- NETWORK GÜNCELLEME - THROTTLED
-- ============================
function PropHP.UpdatePartyPool(partyID)
    local data = PropHP.GetPartyData(partyID)
    if not data then return end
    
    -- Rate limiting
    if data.lastNetworkUpdate and CurTime() - data.lastNetworkUpdate < 0.5 then
        return
    end
    data.lastNetworkUpdate = CurTime()
    
    -- Parti üyelerini bul
    local members = {}
    if parties and parties[partyID] and parties[partyID].members then
        for _, steamID in pairs(parties[partyID].members) do
            local ply = player.GetBySteamID64(steamID)
            if IsValid(ply) then
                table.insert(members, ply)
            end
        end
    end
    
    if #members == 0 then return end
    
    -- Toplam ve sağlam prop sayılarını hesapla
    local totalProps = #data.props
    local aliveProps = 0
    
    for _, prop in pairs(data.props) do
        if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
            aliveProps = aliveProps + 1
        end
    end
    
    -- HP/Prop hesabı - SADECE SAĞLAM prop'lar baz alınır
    local hpPerProp = aliveProps > 0 and math.floor(data.totalPool / aliveProps) or data.totalPool
    
    net.Start("PropHP_UpdatePool")
        net.WriteString(partyID)
        net.WriteUInt(data.totalPool, 32)
        net.WriteUInt(totalProps, 16)
        net.WriteUInt(hpPerProp, 32)
        net.WriteUInt(data.propsDestroyed, 16)
    net.Send(members)
end

-- ============================
-- RAID OYUNCU KONTROLÜ
-- ============================
function PropHP.IsPlayerInRaid(ply, raidID)
    if not IsValid(ply) or not raidID then return false end
    
    local participants = PropHP.RaidParticipants[raidID]
    if not participants then return false end
    
    local steamID = ply:SteamID64()
    
    -- Saldıran veya savunan tarafta mı?
    return participants.attackers[steamID] ~= nil or participants.defenders[steamID] ~= nil
end

function PropHP.GetPlayerRaidSide(ply, raidID)
    if not IsValid(ply) or not raidID then return nil end
    
    local participants = PropHP.RaidParticipants[raidID]
    if not participants then return nil end
    
    local steamID = ply:SteamID64()
    
    if participants.attackers[steamID] then
        return "attacker"
    elseif participants.defenders[steamID] then
        return "defender"
    end
    
    return nil
end

-- ============================
-- RAID'DE Mİ KONTROLÜ
-- ============================
function PropHP.IsPlayerInAnyRaid(ply)
    if not IsValid(ply) then return false, nil end
    
    local steamID = ply:SteamID64()
    
    for raidID, participants in pairs(PropHP.RaidParticipants) do
        if participants.attackers[steamID] or participants.defenders[steamID] then
            return true, raidID
        end
    end
    
    return false, nil
end

-- ============================
-- NLR KONTROLÜ
-- ============================
function PropHP.IsPlayerNLR(ply)
    if not IsValid(ply) then return false end
    
    local steamID = ply:SteamID64()
    
    for raidID, participants in pairs(PropHP.RaidParticipants) do
        -- Saldıran tarafta ve ölü mü?
        if participants.attackers[steamID] and not participants.attackers[steamID].alive then
            return true
        end
        -- Savunan tarafta ve ölü mü?
        if participants.defenders[steamID] and not participants.defenders[steamID].alive then
            return true
        end
    end
    
    return false
end

-- ============================
-- RAID AKTİF Mİ KONTROLÜ
-- ============================
function PropHP.IsRaidActive(raidID)
    if not raidID then return false end
    
    local raid = PropHP.ActiveRaids and PropHP.ActiveRaids[raidID]
    if not raid then return false end
    
    -- Raid AKTIF mi? (hazırlık aşaması değil, gerçekten başlamış mı?)
    return raid.active and not raid.preparation
end

-- ============================
-- OYUNCU HASAR KONTROLÜ - GÜVENLİK İYİLEŞTİRMELERİ
-- ============================
hook.Add("PlayerShouldTakeDamage", "PropHP_RaidPlayerDamage", function(victim, attacker)
    if not IsValid(victim) or not IsValid(attacker) then return end
    if not victim:IsPlayer() or not attacker:IsPlayer() then return end
    if victim == attacker then return end
    
    -- NLR KONTROLÜ
    if PropHP.IsPlayerNLR(attacker) then
        -- NLR'de olan oyuncu kimseye hasar veremez
        return false
    end
    
    local victimParty = victim:GetParty()
    local attackerParty = attacker:GetParty()
    
    if not victimParty or not attackerParty then return end
    
    -- Aynı parti kontrolü
    if victimParty == attackerParty then
        return false
    end
    
    -- RAID İÇİ/DIŞI İZOLASYON
    local victimInRaid, victimRaidID = PropHP.IsPlayerInAnyRaid(victim)
    local attackerInRaid, attackerRaidID = PropHP.IsPlayerInAnyRaid(attacker)
    
    -- Farklı raid'lerde veya biri raid'de diğeri değilse
    if victimInRaid or attackerInRaid then
        -- İkisi de aynı raid'de değilse hasar veremez
        if victimRaidID ~= attackerRaidID then
            return false
        end
        
        -- İkisi de aynı raid'deyse
        if victimRaidID == attackerRaidID then
            -- HAZIRLIK AŞAMASI KONTROLÜ
            if not PropHP.IsRaidActive(victimRaidID) then
                -- Raid aktif değilse (hazırlık aşamasındaysa) hasar veremez
                return false
            end
            
            -- Aynı taraftaysa hasar veremez
            local victimSide = PropHP.GetPlayerRaidSide(victim, victimRaidID)
            local attackerSide = PropHP.GetPlayerRaidSide(attacker, attackerRaidID)
            
            if victimSide == attackerSide then
                return false
            end
            
            -- NLR kontrolü (kurban için)
            if PropHP.IsPlayerNLR(victim) then
                -- NLR'deki oyuncu hasar alamaz
                return false
            end
        end
    end
    
    -- Diğer durumlar için varsayılan davranış
    return
end)

-- ============================
-- PROP SPAWN HOOK - LİDERLİK DEVRİ DESTEĞİ
-- ============================
hook.Add("PlayerSpawnedProp", "PropHP_OnPropSpawn", function(ply, model, ent)
    -- Validasyon
    if not IsValid(ply) or not IsValid(ent) then return end
    
    local partyID = ply:GetParty()
    
    -- Prop'a sahip bilgisini ekle
    ent:SetNWEntity("PropOwner", ply)
    
    -- PARTİSİ YOKSA SADECE SAHİP BİLGİSİNİ KAYDET
    if not partyID then 
        ent:SetNWBool("WaitingForParty", true)
        return
    end
    
    local data = PropHP.GetPartyData(partyID)
    
    -- RAID KONTROLÜ
    if data.raidStatus then
        -- Hazırlık aşaması hariç prop koyma engeli
        if data.raidStatus.active or data.raidStatus.lootingPhase then
            ent:Remove()
            ply:ChatPrint("Raid sırasında yeni prop koyamazsınız!")
            return false
        end
    end
    
    -- Maksimum prop kontrolü - Düşürüldü
    local maxProps = PropHP.Config.Performance.MaxPropsPerParty or 50
    if #data.props >= maxProps then
        ent:Remove()
        ply:ChatPrint("Maksimum prop limitine ulaştınız! (" .. maxProps .. " prop)")
        return false
    end
    
    -- Prop'u partiye kaydet
    ent:SetNWString("PropOwnerParty", partyID)
    ent:SetNWBool("WaitingForParty", false)
    table.insert(data.props, ent)
    
    -- HP'leri yeniden hesapla
    PropHP.RecalculatePropHP(partyID)
    
    -- Bilgi mesajı
    local aliveProps = 0
    for _, prop in pairs(data.props) do
        if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
            aliveProps = aliveProps + 1
        end
    end
    
    local hpPerProp = math.floor(data.totalPool / aliveProps)
    ply:ChatPrint("Prop yerleştirildi | Sağlam prop: " .. aliveProps .. "/" .. #data.props .. " | HP/Prop: " .. string.Comma(hpPerProp))
end)

-- ============================
-- PARTİ KURULDUĞUNDA ESKİ PROP'LARI EKLE
-- ============================
function PropHP.AddExistingPropsToParty(ply, partyID)
    if not IsValid(ply) then return 0 end
    
    local data = PropHP.GetPartyData(partyID)
    local addedCount = 0
    local maxProps = PropHP.Config.Performance.MaxPropsPerParty or 50
    
    -- Oyuncunun sahip olduğu tüm prop'ları bul
    for _, ent in pairs(ents.FindByClass("prop_physics")) do
        if IsValid(ent) then
            local owner = ent:GetNWEntity("PropOwner")
            
            -- Bu prop bu oyuncunun mu ve henüz partiye eklenmemiş mi?
            if IsValid(owner) and owner == ply and ent:GetNWBool("WaitingForParty", false) then
                -- Maksimum prop kontrolü
                if #data.props < maxProps then
                    -- Prop'u partiye ekle
                    ent:SetNWString("PropOwnerParty", partyID)
                    ent:SetNWBool("WaitingForParty", false)
                    table.insert(data.props, ent)
                    addedCount = addedCount + 1
                else
                    break -- Limit doldu
                end
            end
        end
    end
    
    -- Eğer prop eklendiyse HP'leri yeniden hesapla
    if addedCount > 0 then
        PropHP.RecalculatePropHP(partyID)
        ply:ChatPrint("Parti kuruldu! " .. addedCount .. " eski prop'unuz HP havuzuna eklendi.")
        
        local aliveProps = 0
        for _, prop in pairs(data.props) do
            if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
                aliveProps = aliveProps + 1
            end
        end
        
        local hpPerProp = math.floor(data.totalPool / aliveProps)
        ply:ChatPrint("Toplam: " .. #data.props .. " prop | HP/Prop: " .. string.Comma(hpPerProp))
    end
    
    return addedCount
end

-- ============================
-- PROP HASAR SİSTEMİ - VALİDASYON İYİLEŞTİRMELERİ
-- ============================
hook.Add("EntityTakeDamage", "PropHP_PropDamage", function(target, dmginfo)
    if not IsValid(target) then return end
    if target:GetClass() != "prop_physics" then return end
    
    -- Partiye ait olmayan prop'ları kontrol et
    local targetParty = target:GetNWString("PropOwnerParty", "")
    if targetParty == "" then
        dmginfo:SetDamage(0)
        return true
    end
    
    local propHP = target:GetNWInt("PropHP", 0)
    if propHP <= 0 then return end
    
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
    -- Rate limiting
    if not PropHP.CanSendNetwork(attacker, "damage") then
        dmginfo:SetDamage(0)
        return true
    end
    
    local attackerParty = attacker:GetParty()
    
    -- Kendi partine hasar veremezsin
    if targetParty == attackerParty then
        dmginfo:SetDamage(0)
        return true
    end
    
    -- Raid kontrolü
    local targetData = PropHP.GetPartyData(targetParty)
    local attackerData = PropHP.GetPartyData(attackerParty)
    
    local inRaid = false
    local raidID = nil
    
    -- Hedefin raid'de olup olmadığını kontrol et
    if targetData and targetData.raidStatus then
        raidID = targetData.raidStatus.raidID
        
        -- Saldırgan bu raid'de mi?
        if PropHP.IsPlayerInRaid(attacker, raidID) then
            inRaid = true
        end
    end
    
    -- Raid yoksa veya saldırgan raid'de değilse hasar veremez
    if not inRaid then
        attacker:ChatPrint("Bu partiye hasar verebilmek için raid'de olmalısınız!")
        dmginfo:SetDamage(0)
        return true
    end
    
    -- HAZIRLIK AŞAMASI KONTROLÜ
    local raid = PropHP.ActiveRaids[raidID]
    if raid and not raid.active and not raid.lootingPhase then
        -- Hazırlık aşamasında prop'lara hasar verilemez
        attacker:ChatPrint("Hazırlık aşamasında prop'lara hasar veremezsiniz!")
        dmginfo:SetDamage(0)
        return true
    end
    
    -- NLR kontrolü
    local participants = PropHP.RaidParticipants[raidID]
    if participants then
        local steamID = attacker:SteamID64()
        
        -- Saldıran tarafta mı ve ölü mü?
        if participants.attackers[steamID] and not participants.attackers[steamID].alive then
            attacker:ChatPrint("NLR kuralı nedeniyle hasar veremezsiniz!")
            dmginfo:SetDamage(0)
            return true
        end
        
        -- Savunan tarafta mı ve ölü mü?
        if participants.defenders[steamID] and not participants.defenders[steamID].alive then
            attacker:ChatPrint("NLR kuralı nedeniyle hasar veremezsiniz!")
            dmginfo:SetDamage(0)
            return true
        end
    end
    
    -- Silah hasarını hesapla
    local weapon = attacker:GetActiveWeapon()
    local damage = PropHP.Config.WeaponDamage["default"]
    
    if IsValid(weapon) then
        damage = PropHP.Config.WeaponDamage[weapon:GetClass()] or damage
    end
    
    -- Savunma bonusu
    if targetData and targetData.raidStatus and targetData.raidStatus.isDefender then
        damage = math.floor(damage * PropHP.Config.Raid.DefenderBonus)
    end
    
    -- Hasarı uygula
    propHP = math.max(0, propHP - damage)
    target:SetNWInt("PropHP", propHP)
    
    -- Renk güncelle
    PropHP.UpdatePropColor(target)
    
    -- Hasar numarası göster (throttled)
    if PropHP.Config.Visual.ShowDamageNumbers then
        net.Start("PropHP_DamageNumber")
            net.WriteVector(target:GetPos() + Vector(0, 0, 50))
            net.WriteInt(damage, 16)
            net.WriteColor(Color(255, 255, 0))
        net.Send(attacker)
    end
    
    -- Prop yok edildi mi?
    if propHP <= 0 then
        PropHP.DestroyProp(target, attacker)
    end
    
    dmginfo:SetDamage(0)
    return true
end)

-- ============================
-- PROP YOK ETME (GHOST MODU) - OPTİMİZE
-- ============================
function PropHP.DestroyProp(ent, attacker)
    if not IsValid(ent) then return end
    
    local partyID = ent:GetNWString("PropOwnerParty", "")
    local data = PropHP.GetPartyData(partyID)
    
    if not data then 
        ent:Remove()
        return 
    end
    
    -- Prop'u ghost listesine taşı
    for i, prop in ipairs(data.props) do
        if prop == ent then
            table.remove(data.props, i)
            table.insert(data.ghostProps, ent)
            break
        end
    end
    
    data.propsDestroyed = data.propsDestroyed + 1
    
    -- Ghost moduna al
    ent:SetNWBool("PropDestroyed", true)
    ent:SetNWInt("PropHP", 0)
    
    -- COLLISION'I TAMAMEN KAPAT
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    ent:SetColor(Color(255, 255, 255, 50))
    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    
    -- Fizik objesini pasif yap
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
        phys:SetMass(1)
        phys:EnableCollisions(false)
    end
    
    -- Trigger oluştur
    ent:SetTrigger(true)
    ent:SetNotSolid(true)
    
    -- Yıkım sesi
    ent:EmitSound("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav")
    
    -- Saldırgana bilgi
    if IsValid(attacker) then
        local aliveProps = #data.props
        attacker:ChatPrint("Prop yok edildi! İçinden geçebilirsiniz! Sağlam: " .. aliveProps .. "/" .. (aliveProps + #data.ghostProps))
    end
    
    -- Network update
    if PropHP.Config.Visual.ShowDamageNumbers then
        net.Start("PropHP_PropDestroyed")
            net.WriteVector(ent:GetPos())
        net.Broadcast()
    end
    
    -- HP'leri yeniden hesapla
    PropHP.RecalculatePropHP(partyID)
end

-- ============================
-- PROP TAMİR SİSTEMİ
-- ============================
function PropHP.RepairProp(ent, repairer)
    if not IsValid(ent) then return false end
    if not ent:GetNWBool("PropDestroyed", false) then return false end
    
    local partyID = ent:GetNWString("PropOwnerParty", "")
    local data = PropHP.GetPartyData(partyID)
    
    if not data then return false end
    
    -- Ghost listesinden çıkar, normal listeye ekle
    for i, prop in ipairs(data.ghostProps) do
        if prop == ent then
            table.remove(data.ghostProps, i)
            table.insert(data.props, ent)
            break
        end
    end
    
    -- Tamir et
    ent:SetNWBool("PropDestroyed", false)
    data.propsDestroyed = math.max(0, data.propsDestroyed - 1)
    
    -- Fizik ve görünümü geri getir
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)
    ent:SetColor(Color(255, 255, 255, 255))
    ent:SetRenderMode(RENDERMODE_NORMAL)
    ent:SetTrigger(false)
    ent:SetNotSolid(false)
    
    -- Fizik objesini aktif et
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(true)
        phys:EnableCollisions(true)
        phys:Wake()
    end
    
    -- HP'leri yeniden hesapla
    PropHP.RecalculatePropHP(partyID)
    
    if IsValid(repairer) then
        repairer:ChatPrint("Prop tamir edildi!")
    end
    
    return true
end

-- ============================
-- RAID BİTİNCE OTOMATİK TAMİR
-- ============================
function PropHP.RepairAllDestroyedProps(partyID)
    local data = PropHP.GetPartyData(partyID)
    if not data then return end
    
    local repairedCount = 0
    
    -- Tüm ghost propları tamir et
    for _, prop in ipairs(data.ghostProps) do
        if IsValid(prop) then
            PropHP.RepairProp(prop)
            repairedCount = repairedCount + 1
        end
    end
    
    -- Ghost listesini temizle
    data.ghostProps = {}
    data.propsDestroyed = 0
    
    -- HP'leri yeniden hesapla
    PropHP.RecalculatePropHP(partyID)
    
    -- Parti üyelerine bildir
    if parties and parties[partyID] and parties[partyID].members then
        for _, steamID in pairs(parties[partyID].members) do
            local ply = player.GetBySteamID64(steamID)
            if IsValid(ply) then
                if repairedCount > 0 then
                    ply:ChatPrint("Raid sona erdi! " .. repairedCount .. " prop otomatik tamir edildi.")
                end
            end
        end
    end
    
    return repairedCount
end

-- ============================
-- LİDERLİK DEVRİ SİSTEMİ
-- ============================
function PropHP.TransferLeadership(oldLeaderID, newLeaderID)
    if not oldLeaderID or not newLeaderID then return false end
    
    local data = PropHP.PartyData[oldLeaderID]
    if not data then return false end
    
    -- Veriyi yeni lidere transfer et
    PropHP.PartyData[newLeaderID] = data
    PropHP.PartyData[oldLeaderID] = nil
    
    -- Tüm prop'ların parti ID'sini güncelle
    for _, prop in pairs(data.props) do
        if IsValid(prop) then
            prop:SetNWString("PropOwnerParty", newLeaderID)
        end
    end
    
    for _, prop in pairs(data.ghostProps) do
        if IsValid(prop) then
            prop:SetNWString("PropOwnerParty", newLeaderID)
        end
    end
    
    -- Yeni HP havuzunu hesapla
    local newPool = PropHP.GetPartyHPPool(newLeaderID)
    if newPool != data.totalPool then
        data.totalPool = newPool
        PropHP.RecalculatePropHP(newLeaderID)
    end
    
    -- Log
    if PropHP.Config.Debug.Enabled then
        print("[PropHP] Liderlik devredildi: " .. oldLeaderID .. " -> " .. newLeaderID)
    end
    
    return true
end

-- ============================
-- HOOKLAR
-- ============================
hook.Add("SPSStartParty", "PropHP_PartyStarted", function(ply, partyData)
    local partyID = ply:SteamID64()
    PropHP.InitializeParty(partyID)
    PropHP.AddExistingPropsToParty(ply, partyID)
end)

hook.Add("SPSJoinParty", "PropHP_MemberJoined", function(ply, partyData)
    local partyID = ply:GetParty()
    if partyID then
        PropHP.AddExistingPropsToParty(ply, partyID)
    end
end)

hook.Add("SPSDisbandedParty", "PropHP_PartyDisbanded", function(ply, partyData)
    for partyID, data in pairs(PropHP.PartyData) do
        if not parties[partyID] then
            PropHP.CleanupPartyData(partyID)
        end
    end
end)

hook.Add("SPSLeaveParty", "PropHP_MemberLeft", function(ply, partyData)
    -- Üye ayrıldığında prop'larını parti HP havuzundan çıkar
    local partyID = ply:GetParty()
    if partyID then
        local data = PropHP.GetPartyData(partyID)
        if data then
            local removedProps = 0
            
            -- Oyuncunun prop'larını bul ve kaldır
            for i = #data.props, 1, -1 do
                local prop = data.props[i]
                if IsValid(prop) then
                    local owner = prop:GetNWEntity("PropOwner")
                    if owner == ply then
                        table.remove(data.props, i)
                        prop:SetNWString("PropOwnerParty", "")
                        prop:SetNWBool("WaitingForParty", true)
                        removedProps = removedProps + 1
                    end
                end
            end
            
            if removedProps > 0 then
                PropHP.RecalculatePropHP(partyID)
            end
        end
    end
    
    -- Katılım zamanını temizle
    PropHP.ClearPlayerJoinTime(ply)
end)

-- Oyuncu disconnect olduğunda
hook.Add("PlayerDisconnected", "PropHP_PlayerDisconnect", function(ply)
    -- Katılım zamanını temizle
    PropHP.ClearPlayerJoinTime(ply)
end)

-- Lider değişimi hook'u (party sistemi tarafından çağrılmalı)
hook.Add("SPSLeaderChanged", "PropHP_LeaderChanged", function(oldLeader, newLeader, partyData)
    if oldLeader and newLeader then
        local oldID = oldLeader:SteamID64()
        local newID = newLeader:SteamID64()
        PropHP.TransferLeadership(oldID, newID)
    end
end)

-- Sistem yüklendi bildirimi
print("[PropHP] Core sistem yüklendi - v3.0 Tüm sorunlar düzeltildi")