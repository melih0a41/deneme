-- Prop HP System - Core Server Side
-- Dosya Yolu: lua/autorun/server/sv_prophp_core.lua

PropHP = PropHP or {}
PropHP.PartyData = PropHP.PartyData or {}
PropHP.UpdateQueue = PropHP.UpdateQueue or {}

-- Network strings
util.AddNetworkString("PropHP_UpdatePool")
util.AddNetworkString("PropHP_UpdatePropHP")
util.AddNetworkString("PropHP_DamageNumber")
util.AddNetworkString("PropHP_PropDestroyed")

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
    -- Bu sayede ghost prop'lar hala HP havuzunu meşgul eder
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
                prop:SetNWInt("PropMaxHP", hpPerProp)  -- Tamir için gerekli
                prop:SetNWInt("PropReservedHP", hpPerProp)  -- Havuzdan ayrılan pay
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
        net.WriteUInt(totalProps, 16)      -- Toplam prop (ghost dahil)
        net.WriteUInt(hpPerProp, 32)       -- HP/Prop (tüm prop'lar baz alınır)
        net.WriteUInt(data.propsDestroyed, 16)
    net.Send(members)
end

-- ============================
-- PROP SPAWN HOOK
-- ============================
hook.Add("PlayerSpawnedProp", "PropHP_OnPropSpawn", function(ply, model, ent)
    local partyID = ply:GetParty()
    if not partyID then return end
    
    local data = PropHP.GetPartyData(partyID)
    
    -- Maksimum prop kontrolü
    if #data.props >= PropHP.Config.Performance.MaxPropsPerParty then
        ent:Remove()
        ply:ChatPrint("⚠️ Maksimum prop limitine ulaştınız! (" .. PropHP.Config.Performance.MaxPropsPerParty .. " prop)")
        return false
    end
    
    -- Prop'u kaydet
    ent:SetNWString("PropOwnerParty", partyID)
    ent:SetNWEntity("PropOwner", ply)
    table.insert(data.props, ent)
    
    -- HP'leri yeniden hesapla
    PropHP.RecalculatePropHP(partyID)
    
    -- Bilgi mesajı
    local hpPerProp = math.floor(data.totalPool / #data.props)
    ply:ChatPrint("📦 Prop yerleştirildi | Prop sayısı: " .. #data.props .. " | HP/Prop: " .. string.Comma(hpPerProp))
end)

-- ============================
-- PROP HASAR SİSTEMİ
-- ============================
hook.Add("EntityTakeDamage", "PropHP_PropDamage", function(target, dmginfo)
    if not IsValid(target) then return end
    if target:GetClass() != "prop_physics" then return end
    
    local propHP = target:GetNWInt("PropHP", 0)
    if propHP <= 0 then return end
    
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
    local targetParty = target:GetNWString("PropOwnerParty", "")
    local attackerParty = attacker:GetParty()
    
    -- Kendi partine hasar veremezsin
    if targetParty == attackerParty then
        dmginfo:SetDamage(0)
        return true
    end
    
    -- Raid kontrolü
    if not PropHP.IsInRaid(attackerParty, targetParty) then
        attacker:ChatPrint("❌ Bu partiye raid başlatmadan hasar veremezsiniz!")
        dmginfo:SetDamage(0)
        return true
    end
    
    -- Silah hasarını hesapla
    local weapon = attacker:GetActiveWeapon()
    local damage = PropHP.Config.WeaponDamage["default"]
    
    if IsValid(weapon) then
        damage = PropHP.Config.WeaponDamage[weapon:GetClass()] or damage
    end
    
    -- Savunma bonusu
    local defenderData = PropHP.GetPartyData(targetParty)
    if defenderData and defenderData.raidStatus and defenderData.raidStatus.isDefender then
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
-- PROP YOK ETME (GHOST MODU)
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
    
    -- Fizik ve görünüm ayarları
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    ent:SetColor(Color(255, 255, 255, 100))
    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    
    -- Fizik objesini ghost yap
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
    end
    
    -- Efekt oluştur
    local effectdata = EffectData()
    effectdata:SetOrigin(ent:GetPos())
    effectdata:SetScale(0.5)
    util.Effect("Smoke", effectdata)
    
    -- Saldırgana bilgi
    if IsValid(attacker) then
        local aliveProps = 0
        for _, prop in pairs(data.props) do
            if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
                aliveProps = aliveProps + 1
            end
        end
        attacker:ChatPrint("💥 Prop yok edildi! Sağlam prop: " .. aliveProps .. "/" .. #data.props)
    end
    
    -- Network update
    net.Start("PropHP_PropDestroyed")
        net.WriteVector(ent:GetPos())
    net.Broadcast()
    
    -- HP'leri yeniden hesapla - AMA ghost prop hala HP havuzundan pay alır!
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
    
    -- Fizik ve görünümü geri getir
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)
    ent:SetColor(Color(255, 255, 255, 255))
    ent:SetRenderMode(RENDERMODE_NORMAL)
    
    -- Fizik objesini aktif et
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(true)
        phys:Wake()
    end
    
    -- Prop'a full HP ver (ayrılan payın tamamı)
    local reservedHP = ent:GetNWInt("PropReservedHP", 0)
    if reservedHP > 0 then
        ent:SetNWInt("PropHP", reservedHP)
        ent:SetNWInt("PropMaxHP", reservedHP)
    else
        -- Eğer rezerve HP yoksa yeniden hesapla
        PropHP.RecalculatePropHP(partyID)
    end
    
    -- Tamir efekti
    local effectdata = EffectData()
    effectdata:SetOrigin(ent:GetPos())
    effectdata:SetScale(1)
    util.Effect("ManhackSparks", effectdata)
    
    if IsValid(repairer) then
        repairer:ChatPrint("🔧 Prop tamir edildi!")
    end
    
    -- HP güncelleme
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
            
            -- Fizik objesini aktif et
            local phys = prop:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(true)
                phys:Wake()
            end
            
            repairedCount = repairedCount + 1
        end
    end
    
    -- Yok edilen sayacını sıfırla
    data.propsDestroyed = 0
    
    -- HP'leri yeniden hesapla (tüm prop'lar sağlam olduğu için)
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

-- ============================
-- PROP CLEANUP
-- ============================
hook.Add("EntityRemoved", "PropHP_CleanupProp", function(ent)
    if not IsValid(ent) then return end
    if ent:GetClass() != "prop_physics" then return end
    
    local partyID = ent:GetNWString("PropOwnerParty", "")
    if partyID == "" then return end
    
    local data = PropHP.GetPartyData(partyID)
    if not data then return end
    
    -- Prop'u listeden çıkar
    table.RemoveByValue(data.props, ent)
    
    -- HP'leri yeniden hesapla (delay ile)
    timer.Simple(PropHP.Config.Performance.HPUpdateDelay, function()
        if PropHP.PartyData[partyID] then
            PropHP.RecalculatePropHP(partyID)
        end
    end)
end)

-- ============================
-- HP REGENERASYON
-- ============================
timer.Create("PropHP_Regeneration", 60, 0, function()
    for partyID, data in pairs(PropHP.PartyData) do
        -- Raid'de değilse ve hasar almış prop'lar varsa
        if not data.raidStatus then
            local needsRegen = false
            
            for _, prop in pairs(data.props) do
                if IsValid(prop) and not prop:GetNWBool("PropDestroyed", false) then
                    -- Sadece yok edilmemiş prop'ları regen et
                    local hp = prop:GetNWInt("PropHP", 0)
                    local maxHP = prop:GetNWInt("PropMaxHP", 0)
                    
                    if hp < maxHP then
                        needsRegen = true
                        local regenAmount = math.floor(maxHP * PropHP.Config.Performance.HPRegenRate)
                        local newHP = math.min(maxHP, hp + regenAmount)
                        prop:SetNWInt("PropHP", newHP)
                        PropHP.UpdatePropColor(prop)
                    end
                end
            end
            
            if needsRegen then
                PropHP.UpdatePartyPool(partyID)
            end
        end
    end
end)

-- ============================
-- PARTİ SİSTEMİ HOOK'LARI
-- ============================
hook.Add("SPSStartParty", "PropHP_PartyCreated", function(ply, partyData)
    local partyID = ply:SteamID64()
    PropHP.InitializeParty(partyID)
    ply:ChatPrint("✅ Parti HP havuzu aktif! Toplam: " .. string.Comma(PropHP.GetPartyHPPool(partyID)) .. " HP")
end)

hook.Add("SPSJoinParty", "PropHP_PlayerJoinedParty", function(ply, partyData)
    local partyID = ply:GetParty()
    if partyID then
        PropHP.UpdatePartyPool(partyID)
    end
end)

hook.Add("SPSDisbandedParty", "PropHP_PartyDisbanded", function(ply, partyData)
    local partyID = ply:SteamID64()
    
    if PropHP.PartyData[partyID] then
        -- Tüm prop'ları temizle
        for _, prop in pairs(PropHP.PartyData[partyID].props) do
            if IsValid(prop) then
                prop:Remove()
            end
        end
        PropHP.PartyData[partyID] = nil
    end
end)

-- ============================
-- DEBUG KOMUTLARI
-- ============================
concommand.Add("prophp_debug", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    local partyID = ply:GetParty()
    if not partyID then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Partiniz yok!")
        return
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
    
    ply:PrintMessage(HUD_PRINTCONSOLE, "=== PARTI HP DEBUG ===")
    ply:PrintMessage(HUD_PRINTCONSOLE, "Toplam Havuz: " .. string.Comma(data.totalPool))
    ply:PrintMessage(HUD_PRINTCONSOLE, "Toplam Prop: " .. #data.props)
    ply:PrintMessage(HUD_PRINTCONSOLE, "Sağlam Prop: " .. aliveProps)
    ply:PrintMessage(HUD_PRINTCONSOLE, "Ghost Prop: " .. ghostProps)
    ply:PrintMessage(HUD_PRINTCONSOLE, "HP/Prop: " .. string.Comma(math.floor(data.totalPool / math.max(#data.props, 1))))
    
    if data.raidStatus then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Raid Durumu: " .. (data.raidStatus.active and "AKTİF" or "HAZIRLIK"))
    end
end)

concommand.Add("prophp_reset", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    local partyID = ply:GetParty()
    if not partyID then return end
    
    if PropHP.PartyData[partyID] then
        for _, prop in pairs(PropHP.PartyData[partyID].props) do
            if IsValid(prop) then
                prop:Remove()
            end
        end
        PropHP.InitializeParty(partyID)
        ply:ChatPrint("✅ Parti HP havuzu sıfırlandı!")
    end
end)

-- Test için manuel tamir komutu
concommand.Add("prophp_repair", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    local trace = ply:GetEyeTrace()
    if IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_physics" then
        if trace.Entity:GetNWBool("PropDestroyed", false) then
            PropHP.RepairProp(trace.Entity, ply)
        else
            ply:ChatPrint("Bu prop zaten sağlam!")
        end
    else
        ply:ChatPrint("Bir prop'a bakın!")
    end
end)

-- Tüm yok edilmiş prop'ları tamir et
concommand.Add("prophp_repairall", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    local partyID = ply:GetParty()
    if not partyID then 
        ply:ChatPrint("Partiniz yok!")
        return 
    end
    
    local repaired = PropHP.RepairAllDestroyedProps(partyID)
    ply:ChatPrint("✅ " .. repaired .. " prop tamir edildi!")
end)