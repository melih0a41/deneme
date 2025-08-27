AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("Dex_OpenBuyHUD")
util.AddNetworkString("Dex_BuySWEP_ClearGhost")
util.AddNetworkString("Dex_SelectedBuyItem")
util.AddNetworkString("Dex_SpawnGhost")
util.AddNetworkString("Dex_BuySWEP_Notify")
util.AddNetworkString("Dex_BuySWEP_Clear")
util.AddNetworkString("Dex_SwipeLeft")
util.AddNetworkString("Dex_SwipeRight")
util.AddNetworkString("Dex_SelectItem")

SelectedBuyIndex = {}
PlayerJobEntities = {}

local function RegisterPurchasedEntity(ply, entity, jobTeam, itemType)
    if not IsValid(ply) or not IsValid(entity) then return end
    
    local steamID = ply:SteamID()
    local teamID = jobTeam or ply:Team()
    
    if not PlayerJobEntities[steamID] then
        PlayerJobEntities[steamID] = {}
    end
    
    if not PlayerJobEntities[steamID][teamID] then
        PlayerJobEntities[steamID][teamID] = {}
    end
    
    -- Item tipine göre kaydet
    PlayerJobEntities[steamID][teamID][itemType] = entity
end

local function HasItemOfType(ply, itemType)
    local steamID = ply:SteamID()
    local teamID = ply:Team()
    
    if not PlayerJobEntities[steamID] then return false end
    if not PlayerJobEntities[steamID][teamID] then return false end
    
    local existingItem = PlayerJobEntities[steamID][teamID][itemType]
    
    -- Entity geçerliyse true döndür
    if IsValid(existingItem) then
        return true
    else
        -- Geçersizse tablodan temizle
        PlayerJobEntities[steamID][teamID][itemType] = nil
        return false
    end
end

local function RemoveJobEntities(ply, jobTeam)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID()
    
    if not PlayerJobEntities[steamID] or not PlayerJobEntities[steamID][jobTeam] then
        return
    end
    
    local removedCount = 0
    
    for itemType, entity in pairs(PlayerJobEntities[steamID][jobTeam]) do
        if IsValid(entity) then
            entity:Remove()
            removedCount = removedCount + 1
        end
    end
    
    PlayerJobEntities[steamID][jobTeam] = {}
end

function SWEP:Initialize()    
    if SERVER then
        self:SetUseType(SIMPLE_USE)
    end
end

function SWEP:Deploy()
    if SERVER then
        local ply = self:GetOwner()
        if IsValid(ply) then
            SelectedBuyIndex[ply:SteamID()] = nil
            
            net.Start("Dex_BuySWEP_ClearGhost")
            net.Send(ply)
        end
        return true
    end
    
    self:SendItemsToClient()
    return true
end

function SWEP:Holster()
    if SERVER then
        local ply = self:GetOwner()
        if IsValid(ply) then
            SelectedBuyIndex[ply:SteamID()] = nil
            
            net.Start("Dex_BuySWEP_ClearGhost")
            net.Send(ply)
        end
    end
    return true
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.2)
    
    if SERVER then
        local ply = self:GetOwner()
        SelectedBuyIndex[ply:SteamID()] = nil
        
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        local vm = self:GetOwner():GetViewModel()
        if IsValid(vm) then
            vm:SetPlaybackRate(2.0)
        end        
        net.Start("Dex_SwipeLeft")
        net.Send(ply)
    end
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    self:SetNextSecondaryFire(CurTime() + 0.2)
    
    if SERVER then
        local ply = self:GetOwner()
        SelectedBuyIndex[ply:SteamID()] = nil

        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        local vm = self:GetOwner():GetViewModel()
        if IsValid(vm) then
            vm:SetPlaybackRate(2.0)
        end        
        
        net.Start("Dex_SwipeRight")
        net.Send(ply)
    end
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if self.NextUseR and self.NextUseR > CurTime() then return end
    
    self.NextUseR = CurTime() + 0.3
    
    if SERVER then
        local ply = self:GetOwner()
        local steamID = ply:SteamID()
        local selectedIndex = SelectedBuyIndex[steamID]
        
        if not selectedIndex then
            net.Start("Dex_SelectItem")
            net.Send(ply)
            return
        end
        
        if self.ItemsToBuy and self.ItemsToBuy[selectedIndex] then
            self:DoPurchase(selectedIndex)
        else
            return
        end
    end
end

function SWEP:SendItemsToClient()
    if not SERVER then return end
    
    local items = self.ItemsToBuy or {}
    local ply = self:GetOwner()
    
    net.Start("Dex_OpenBuyHUD")
        net.WriteUInt(#items, 8)
        for _, item in ipairs(items) do
            net.WriteString(item.name or "")
            net.WriteString(item.model or "")
            net.WriteString(item.entidade or "")
            net.WriteUInt(item.price or 0, 16)
            net.WriteInt(item.offset or 0, 8)
            net.WriteBool(item.isSWEP or false)
        end
    net.Send(ply)
end

function SWEP:ValidateSpawnPosition(ply, item, hitPos)
    local mins, maxs = Vector(-16, -16, -16), Vector(16, 16, 16)
    if item.model then
        local modelBounds = {
            ["models/blood/box.mdl"] = {Vector(-20, -20, -10), Vector(20, 20, 20)},
            ["models/blood/table.mdl"] = {Vector(-40, -40, -5), Vector(40, 40, 40)},
            ["models/blood/c_syringe.mdl"] = {Vector(-8, -8, -8), Vector(8, 8, 8)},
            ["models/weapons/cstrike/c_knife_t.mdl"] = {Vector(-12, -12, -8), Vector(12, 12, 8)},
        }
        
        if modelBounds[item.model] then
            mins, maxs = modelBounds[item.model][1], modelBounds[item.model][2]
        end
    end
    
    local offset = item.offset or 20
    local finalPos = hitPos + ply:EyeAngles():Right() * offset
    
    if item.isSWEP then
        finalPos = finalPos + Vector(0, 0, 20)
    end
    
    local tr = util.TraceHull({
        start = finalPos + Vector(0, 0, 50),
        endpos = finalPos,
        mins = mins,
        maxs = maxs,
        filter = ply
    })
    
    return not tr.Hit or tr.HitWorld, finalPos
end

function SWEP:DoPurchase(itemIndex)
    local ply = self:GetOwner()
    if not self.ItemsToBuy or not self.ItemsToBuy[itemIndex] then return end

    local item = self.ItemsToBuy[itemIndex]
    
    -- SINIR KONTROLÜ - YENİ!
    local itemLimits = {
        ["dex_bed"] = {max = 1, message = "Zaten bir masan var!"},
        ["dex_box"] = {max = 1, message = "Zaten bir kutun var!"},
        ["dex_syringe"] = {max = 1, message = "Zaten bir şırıngan var!"},
        ["dex_butcher_knife"] = {max = 1, message = "Zaten bir kasap bıçağın var!"}
    }
    
    -- Silah kontrolü
    if item.isSWEP then
        if ply:HasWeapon(item.entidade) then
            net.Start("Dex_BuySWEP_Notify")
                net.WriteUInt(1, 8)
                net.WriteString(itemLimits[item.entidade] and itemLimits[item.entidade].message or "Zaten bu silaha sahipsin!")
            net.Send(ply)
            return
        end
    else
        -- Entity kontrolü - Zaten var mı?
        if HasItemOfType(ply, item.entidade) then
            net.Start("Dex_BuySWEP_Notify")
                net.WriteUInt(1, 8)
                net.WriteString(itemLimits[item.entidade] and itemLimits[item.entidade].message or "Zaten bu eşyaya sahipsin!")
            net.Send(ply)
            return
        end
    end
    
    local tr = ply:GetEyeTrace()
    if not tr.Hit then
        net.Start("Dex_BuySWEP_Notify")
            net.WriteUInt(1, 8)
            net.WriteString(DEX_LANG.Get("look_surface"))
        net.Send(ply)
        return
    end

    local money = ply.getDarkRPVar and ply:getDarkRPVar("money") or 0
    if money < item.price then
        net.Start("Dex_BuySWEP_Notify")
            net.WriteUInt(1, 8)
            net.WriteString(DEX_LANG and DEX_LANG.Get("chat_insufficient_money"))
        net.Send(ply)
        return
    end

    local isValid, finalPos = true, tr.HitPos
    if not item.isSWEP then
        isValid, finalPos = self:ValidateSpawnPosition(ply, item, tr.HitPos)
        if not isValid then
            net.Start("Dex_BuySWEP_Notify")
                net.WriteUInt(1, 8)
                net.WriteString(DEX_LANG.Get("not_enough_space"))
            net.Send(ply)
            return
        end
    end

    if DEX_CONFIG.OnlyJob and not DEX_CONFIG.IsSerialKiller(ply) then
        net.Start("Dex_BuySWEP_Notify")
            net.WriteUInt(1, 8)
            net.WriteString(DEX_LANG.Get("job_restricted"))
        net.Send(ply)
        return
    end

    if ply.addMoney then 
        ply:addMoney(-item.price) 
    end

    if item.isSWEP then
        ply:Give(item.entidade)
    else
        local ent = ents.Create(item.entidade or "prop_physics")
        if not IsValid(ent) then
            if ply.addMoney then 
                ply:addMoney(item.price) 
            end
            
            net.Start("Dex_BuySWEP_Notify")
                net.WriteUInt(1, 8)
                net.WriteString(DEX_LANG and DEX_LANG.Get("chat_entity_error"))
            net.Send(ply)
            return
        end

        ent:SetModel(item.model)
        ent:SetPos(finalPos)
        ent:SetAngles(Angle(0, ply:EyeAngles().y + 90, 0))
        ent:Spawn()

        -- Item tipine göre kaydet - GÜNCELLENDİ!
        RegisterPurchasedEntity(ply, ent, ply:Team(), item.entidade)

        if ent.CPPISetOwner then
            ent:CPPISetOwner(ply)
        end

        if DEX_CONFIG.EnableUndoForPurchasedProps then
            undo.Create("Purchased Item")
                undo.AddEntity(ent)
                undo.SetPlayer(ply)
            undo.Finish()
        end

        ply:AddCleanup("dex_purchased_items", ent)

        if ent:IsValid() then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
                phys:Sleep()
            end
        end
    end

    SelectedBuyIndex[ply:SteamID()] = nil
    
    net.Start("Dex_BuySWEP_ClearGhost")
    net.Send(ply)

    local successMessage = string.format(
        DEX_LANG and DEX_LANG.Get("chat_success_buy"),
        item.name,
        DarkRP and DarkRP.formatMoney(item.price) or "$" .. item.price
    )
    
    net.Start("Dex_BuySWEP_Notify")
        net.WriteUInt(0, 8)
        net.WriteString(successMessage)
    net.Send(ply)
end

hook.Add("OnPlayerChangedTeam", "Dex_JobChangeCleanup", function(ply, oldTeam, newTeam)
    if not IsValid(ply) then return end
    if DEX_CONFIG.DisableDespawnOnJobChange then return end

    if oldTeam and oldTeam ~= newTeam then
        RemoveJobEntities(ply, oldTeam)
    end
end)

hook.Add("playerChangedTeam", "Dex_JobChangeCleanup_Alt", function(ply, before, after)
    if not IsValid(ply) then return end
    if DEX_CONFIG.DisableDespawnOnJobChange then return end

    if before and before ~= after then
        RemoveJobEntities(ply, before)
    end
end)

net.Receive("Dex_SelectedBuyItem", function(len, ply)
    local itemIndex = net.ReadUInt(8)
    local wep = ply:GetActiveWeapon()
    
    if not IsValid(wep) or wep:GetClass() ~= "dex_phone" then return end
    if not wep.ItemsToBuy or not wep.ItemsToBuy[itemIndex] then return end
    
    SelectedBuyIndex[ply:SteamID()] = itemIndex
    
    local item = wep.ItemsToBuy[itemIndex]
    local message = string.format(
        DEX_LANG and DEX_LANG.Get("chat_selected_item"),
        item.name
    )
    
    net.Start("Dex_BuySWEP_Notify")
        net.WriteUInt(2, 8)
        net.WriteString(message)
    net.Send(ply)
end)

net.Receive("Dex_SpawnGhost", function(len, ply)
    local modelPath = net.ReadString()
    local offset = net.ReadInt(8)
    
    net.Start("Dex_SpawnGhost")
        net.WriteString(modelPath)
        net.WriteInt(offset, 8)
    net.Send(ply)
end)

hook.Add("PlayerDisconnected", "Dex_CleanupPlayerData", function(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID()
    
    if PlayerJobEntities[steamID] then
        for jobTeam, items in pairs(PlayerJobEntities[steamID]) do
            for itemType, entity in pairs(items) do
                if IsValid(entity) then
                    entity:Remove()
                end
            end
        end
        PlayerJobEntities[steamID] = nil
    end
    
    if SelectedBuyIndex[steamID] then
        SelectedBuyIndex[steamID] = nil
    end
end)

hook.Add("PlayerSwitchWeapon", "Dex_CleanupOnWeaponSwitch", function(ply, oldWeapon, newWeapon)
    if IsValid(oldWeapon) and oldWeapon:GetClass() == "dex_phone" then
        SelectedBuyIndex[ply:SteamID()] = nil
        
        net.Start("Dex_BuySWEP_ClearGhost")
        net.Send(ply)
    end
end)

net.Receive("Dex_BuySWEP_Clear", function(len, ply)
    SelectedBuyIndex[ply:SteamID()] = nil
    
    net.Start("Dex_BuySWEP_ClearGhost")
    net.Send(ply)
end)