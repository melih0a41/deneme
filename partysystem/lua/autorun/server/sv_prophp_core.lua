-- Prop HP System - Core Server Side
-- Dosya Yolu: lua/autorun/server/sv_prophp_core.lua
-- Versiyon: 2.2 NO EFFECTS

PropHP = PropHP or {}
PropHP.PartyData = PropHP.PartyData or {}
PropHP.UpdateQueue = PropHP.UpdateQueue or {}

-- Network strings
util.AddNetworkString("PropHP_UpdatePool")
util.AddNetworkString("PropHP_UpdatePropHP")
util.AddNetworkString("PropHP_DamageNumber")
util.AddNetworkString("PropHP_PropDestroyed")
util.AddNetworkString("PropHP_OpenRaidMenu")

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
        raidStatus = nil,
        lastUpdate = CurTime(),
        propsDestroyed = 0
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
-- HP DAĞITIM SİSTEMİ
-- ============================
function PropHP.RecalculatePropHP(partyID)
    local data = PropHP.GetPartyData(partyID)
    if not data then return end
    
    -- Geçerli prop'ları temizle ve say
    local validProps = {}
    local totalPropCount = 0  -- TÜM prop'lar (ghost dahil)
    
    for _, prop in pairs(data.props) do
        if IsValid(prop) then
            table.insert(validProps, prop)
            totalPropCount = totalPropCount + 1
        end
    end
    data.props = validProps
    
    if totalPropCount == 0 then 
        PropHP.UpdatePartyPool(partyID)
        return 
    end
    
    -- HP'yi TÜM PROP'LAR arasında böl (ghost dahil)
    local hpPerProp = math.floor(data.totalPool / totalPropCount)
    
    -- Minimum HP kontrolü
    if hpPerProp < PropHP.Config.MinPropHP then
        hpPerProp = PropHP.Config.MinPropHP
    end
    
    -- Her prop'a HP ata
    for _, prop in pairs(data.props) do
        if IsValid(prop) then
            if prop:GetNWBool("PropDestroyed", false) then
                -- Ghost prop'lar HP havuzundan payını alır ama HP'si 0 kalır
                prop:SetNWInt("PropHP", 0)
                prop:SetNWInt("PropMaxHP", hpPerProp)
                prop:SetNWInt("PropReservedHP", hpPerProp)
            else
                -- Sağlam prop'lar normal HP alır
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
    end
    
    -- Network update
    PropHP.UpdatePartyPool(partyID)
end

-- ============================
-- PROP RENK SİSTEMİ
-- ============================
function PropHP.UpdatePropColor(prop)
    if not IsValid(prop) then return end
    
    -- Yok edilmiş prop'ların rengini değiştirme (zaten ghost modunda)
    if prop:GetNWBool("PropDestroyed", false) then return end
    
    local hp = prop:GetNWInt("PropHP", 0)
    local maxHP = prop:GetNWInt("PropMaxHP", 1)
    local percent = hp / maxHP
    
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
-- NETWORK GÜNCELLEME
-- ============================
function PropHP.UpdatePartyPool(partyID)
    local data = PropHP.GetPartyData(partyID)
    if not data then return end
    
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
    
    -- Toplam ve sağlam prop sayılarını hesapla
    local totalProps = #data.props
    local aliveProps = 0
    
    for _, prop in pairs(data.props) do
        if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
            aliveProps = aliveProps + 1
        end
    end
    
    -- HP/Prop hesabı - TÜM prop'lar baz alınır (ghost dahil)
    local hpPerProp = totalProps > 0 and math.floor(data.totalPool / totalProps) or data.totalPool
    
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
    if not ply or not raidID then return false end
    
    local participants = PropHP.RaidParticipants[raidID]
    if not participants then return false end
    
    local steamID = ply:SteamID64()
    
    -- Saldıran veya savunan tarafta mı?
    return participants.attackers[steamID] ~= nil or participants.defenders[steamID] ~= nil
end

function PropHP.GetPlayerRaidSide(ply, raidID)
    if not ply or not raidID then return nil end
    
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
-- RAID'DE Mİ KONTROLÜ (YENİ)
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
-- NLR KONTROLÜ (YENİ)
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
-- PROP SPAWN HOOK - GÜNCELLEME
-- ============================
hook.Add("PlayerSpawnedProp", "PropHP_OnPropSpawn", function(ply, model, ent)
    local partyID = ply:GetParty()
    
    -- Prop'a sahip bilgisini ekle (parti olsa da olmasa da)
    ent:SetNWEntity("PropOwner", ply)
    
    -- PARTİSİ YOKSA SADECE SAHİP BİLGİSİNİ KAYDET
    if not partyID then 
        -- Parti yok, sadece işaretle (sonra parti kurulursa eklenecek)
        ent:SetNWBool("WaitingForParty", true)
        return
    end
    
    local data = PropHP.GetPartyData(partyID)
    
    -- RAID KONTROLÜ - YENİ
    if data.raidStatus then
        -- Hazırlık aşaması hariç prop koyma engeli
        if data.raidStatus.active or data.raidStatus.lootingPhase then
            ent:Remove()
            ply:ChatPrint("❌ Raid sırasında yeni prop koyamazsınız!")
            return false
        end
        -- Hazırlık aşamasında koyulabilir
    end
    
    -- Maksimum prop kontrolü
    if #data.props >= PropHP.Config.Performance.MaxPropsPerParty then
        ent:Remove()
        ply:ChatPrint("⚠️ Maksimum prop limitine ulaştınız! (" .. PropHP.Config.Performance.MaxPropsPerParty .. " prop)")
        return false
    end
    
    -- Prop'u partiye kaydet
    ent:SetNWString("PropOwnerParty", partyID)
    ent:SetNWBool("WaitingForParty", false)
    table.insert(data.props, ent)
    
    -- HP'leri yeniden hesapla
    PropHP.RecalculatePropHP(partyID)
    
    -- Bilgi mesajı
    local hpPerProp = math.floor(data.totalPool / #data.props)
    ply:ChatPrint("📦 Prop yerleştirildi | Prop sayısı: " .. #data.props .. " | HP/Prop: " .. string.Comma(hpPerProp))
end)

-- ============================
-- PARTİ KURULDUĞUNDA ESKİ PROP'LARI EKLE
-- ============================
function PropHP.AddExistingPropsToParty(ply, partyID)
    local data = PropHP.GetPartyData(partyID)
    local addedCount = 0
    
    -- Oyuncunun sahip olduğu tüm prop'ları bul
    for _, ent in pairs(ents.FindByClass("prop_physics")) do
        if IsValid(ent) then
            local owner = ent:GetNWEntity("PropOwner")
            
            -- Bu prop bu oyuncunun mu ve henüz partiye eklenmemiş mi?
            if IsValid(owner) and owner == ply and ent:GetNWBool("WaitingForParty", false) then
                -- Maksimum prop kontrolü
                if #data.props < PropHP.Config.Performance.MaxPropsPerParty then
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
        ply:ChatPrint("✅ Parti kuruldu! " .. addedCount .. " eski prop'unuz HP havuzuna eklendi.")
        
        local hpPerProp = math.floor(data.totalPool / #data.props)
        ply:ChatPrint("📊 Toplam: " .. #data.props .. " prop | HP/Prop: " .. string.Comma(hpPerProp))
    end
    
    return addedCount
end

-- ============================
-- PROP HASAR SİSTEMİ - GÜNCELLEME
-- ============================
hook.Add("EntityTakeDamage", "PropHP_PropDamage", function(target, dmginfo)
    if not IsValid(target) then return end
    if target:GetClass() != "prop_physics" then return end
    
    -- Partiye ait olmayan prop'ları kontrol et
    local targetParty = target:GetNWString("PropOwnerParty", "")
    if targetParty == "" then
        -- Partisiz prop, hasar verilemez
        dmginfo:SetDamage(0)
        return true
    end
    
    local propHP = target:GetNWInt("PropHP", 0)
    if propHP <= 0 then return end
    
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
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
        attacker:ChatPrint("❌ Bu partiye hasar verebilmek için raid'de olmalısınız!")
        dmginfo:SetDamage(0)
        return true
    end
    
    -- HAZIRLIK AŞAMASI KONTROLÜ - YENİ
    local raid = PropHP.ActiveRaids[raidID]
    if raid and not raid.active and not raid.lootingPhase then
        -- Hazırlık aşamasında prop'lara hasar verilemez
        attacker:ChatPrint("⏰ Hazırlık aşamasında prop'lara hasar veremezsiniz!")
        dmginfo:SetDamage(0)
        return true
    end
    
    -- NLR kontrolü - Ölü oyuncular hasar veremez
    local participants = PropHP.RaidParticipants[raidID]
    if participants then
        local steamID = attacker:SteamID64()
        
        -- Saldıran tarafta mı ve ölü mü?
        if participants.attackers[steamID] and not participants.attackers[steamID].alive then
            attacker:ChatPrint("❌ NLR kuralı nedeniyle hasar veremezsiniz!")
            dmginfo:SetDamage(0)
            return true
        end
        
        -- Savunan tarafta mı ve ölü mü?
        if participants.defenders[steamID] and not participants.defenders[steamID].alive then
            attacker:ChatPrint("❌ NLR kuralı nedeniyle hasar veremezsiniz!")
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
    
    -- Hasar numarası göster
    net.Start("PropHP_DamageNumber")
        net.WriteVector(target:GetPos() + Vector(0, 0, 50))
        net.WriteInt(damage, 16)
        net.WriteColor(Color(255, 255, 0))
    net.Broadcast()
    
    -- Prop yok edildi mi?
    if propHP <= 0 then
        PropHP.DestroyProp(target, attacker)
    end
    
    dmginfo:SetDamage(0)
    return true
end)

-- ============================
-- OYUNCU HASAR KONTROLÜ - GÜNCELLEME
-- ============================
hook.Add("PlayerShouldTakeDamage", "PropHP_RaidPlayerDamage", function(victim, attacker)
    if not IsValid(victim) or not IsValid(attacker) then return end
    if not victim:IsPlayer() or not attacker:IsPlayer() then return end
    if victim == attacker then return end
    
    -- NLR KONTROLÜ - YENİ
    if PropHP.IsPlayerNLR(attacker) then
        -- NLR'de olan oyuncu kimseye hasar veremez
        return false
    end
    
    local victimParty = victim:GetParty()
    local attackerParty = attacker:GetParty()
    
    if not victimParty or not attackerParty then return end
    
    -- Aynı parti kontrolü (parti sistemi zaten kontrol ediyor ama emin olalım)
    if victimParty == attackerParty then
        return false
    end
    
    -- RAID İÇİ/DIŞI İZOLASYON - YENİ
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
            -- Aynı taraftaysa hasar veremez
            local victimSide = PropHP.GetPlayerRaidSide(victim, victimRaidID)
            local attackerSide = PropHP.GetPlayerRaidSide(attacker, attackerRaidID)
            
            if victimSide == attackerSide then
                return false
            end
            
            -- NLR kontrolü (kurban için)
            if PropHP.IsPlayerNLR(victim) then
                -- NLR'deki oyuncu hasar alamaz (güvenlik için)
                return false
            end
        end
    end
    
    -- Diğer durumlar için varsayılan davranış
    return
end)

-- ============================
-- PROP YOK ETME (GHOST MODU) - İÇİNDEN GEÇİLEBİLİR - EFEKTSİZ
-- ============================
function PropHP.DestroyProp(ent, attacker)
    local partyID = ent:GetNWString("PropOwnerParty", "")
    local data = PropHP.GetPartyData(partyID)
    
    if not data then 
        ent:Remove()
        return 
    end
    
    -- Prop'u listeden ÇIKARMA! Sadece ghost yap
    data.propsDestroyed = data.propsDestroyed + 1
    
    -- Ghost moduna al
    ent:SetNWBool("PropDestroyed", true)
    ent:SetNWInt("PropHP", 0)
    
    -- ÖNEMLİ: COLLISION'I TAMAMEN KAPAT - İÇİNDEN GEÇİLEBİLİR
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER) -- İçinden geçilebilir
    ent:SetColor(Color(255, 255, 255, 50)) -- Daha saydam
    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    
    -- Fizik objesini pasif yap ama collision'ı kapat
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
        phys:SetMass(1) -- Hafiflet
        phys:EnableCollisions(false) -- Fizik collision'ı da kapat
    end
    
    -- Trigger oluştur (içinden geçerken bile algılansın)
    ent:SetTrigger(true)
    ent:SetNotSolid(true) -- Katı değil, içinden geçilebilir
    
    -- EFEKTLER KALDIRILDI - ARTIK DUMAN YOK
    
    -- Yıkım sesi
    ent:EmitSound("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav")
    
    -- Saldırgana bilgi
    if IsValid(attacker) then
        local aliveProps = 0
        for _, prop in pairs(data.props) do
            if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
                aliveProps = aliveProps + 1
            end
        end
        attacker:ChatPrint("💥 Prop yok edildi! İçinden geçebilirsiniz! Sağlam: " .. aliveProps .. "/" .. #data.props)
    end
    
    -- Network update
    net.Start("PropHP_PropDestroyed")
        net.WriteVector(ent:GetPos())
    net.Broadcast()
    
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
    
    -- Tamir et
    ent:SetNWBool("PropDestroyed", false)
    data.propsDestroyed = math.max(0, data.propsDestroyed - 1)
    
    -- Fizik ve görünümü geri getir - COLLISION'I AKTİFLEŞTİR
    ent:SetCollisionGroup(COLLISION_GROUP_NONE) -- Normal collision
    ent:SetColor(Color(255, 255, 255, 255))
    ent:SetRenderMode(RENDERMODE_NORMAL)
    ent:SetTrigger(false)
    ent:SetNotSolid(false) -- Tekrar katı yap
    
    -- Fizik objesini aktif et
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(true)
        phys:EnableCollisions(true) -- Collision'ı aç
        phys:Wake()
    end
    
    -- Prop'a full HP ver
    local reservedHP = ent:GetNWInt("PropReservedHP", 0)
    if reservedHP > 0 then
        ent:SetNWInt("PropHP", reservedHP)
        ent:SetNWInt("PropMaxHP", reservedHP)
    else
        PropHP.RecalculatePropHP(partyID)
    end
    
    -- Tamir efekti - BASİT
    -- DUMAN YERİNE SADECE SES
    
    if IsValid(repairer) then
        repairer:ChatPrint("🔧 Prop tamir edildi!")
    end
    
    PropHP.UpdatePartyPool(partyID)
    
    return true
end

-- ============================
-- RAID BİTİNCE OTOMATİK TAMİR
-- ============================
function PropHP.RepairAllDestroyedProps(partyID)
    local data = PropHP.GetPartyData(partyID)
    if not data then return end
    
    local repairedCount = 0
    
    for _, prop in pairs(data.props) do
        if IsValid(prop) and prop:GetNWBool("PropDestroyed", false) then
            -- Tamir et
            prop:SetNWBool("PropDestroyed", false)
            
            -- Fizik ve görünümü geri getir
            prop:SetCollisionGroup(COLLISION_GROUP_NONE)
            prop:SetColor(Color(255, 255, 255, 255))
            prop:SetRenderMode(RENDERMODE_NORMAL)
            prop:SetTrigger(false)
            prop:SetNotSolid(false)
            
            -- Fizik objesini aktif et
            local phys = prop:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(true)
                phys:EnableCollisions(true)
                phys:Wake()
            end
            
            repairedCount = repairedCount + 1
        end
    end
    
    data.propsDestroyed = 0
    PropHP.RecalculatePropHP(partyID)
    
    -- Parti üyelerine bildir
    if parties and parties[partyID] and parties[partyID].members then
        for _, steamID in pairs(parties[partyID].members) do
            local ply = player.GetBySteamID64(steamID)
            if IsValid(ply) then
                ply:ChatPrint("🔧 Raid sona erdi! " .. repairedCount .. " prop otomatik tamir edildi.")
            end
        end
    end
    
    return repairedCount
end

-- Hook'lar aynı kalıyor, sadece SPSStartParty hook'u ekleniyor
hook.Add("SPSStartParty", "PropHP_PartyStarted", function(ply, partyData)
    local partyID = ply:SteamID64()
    PropHP.InitializeParty(partyID)
    PropHP.AddExistingPropsToParty(ply, partyID)
end)

-- Parti üye ekleme hook'u
hook.Add("SPSJoinParty", "PropHP_MemberJoined", function(ply, partyData)
    local partyID = ply:GetParty()
    if partyID then
        PropHP.AddExistingPropsToParty(ply, partyID)
    end
end)

-- Parti dağılma hook'u
hook.Add("SPSDisbandedParty", "PropHP_PartyDisbanded", function(ply, partyData)
    for partyID, data in pairs(PropHP.PartyData) do
        if not parties[partyID] then
            PropHP.PartyData[partyID] = nil
        end
    end
end)

-- Sistem yüklendi bildirimi
print("[PropHP] Core sistem yüklendi - v2.2 NO EFFECTS")