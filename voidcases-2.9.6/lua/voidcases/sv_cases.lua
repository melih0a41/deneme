util.AddNetworkString("VoidCases.SendCaseUnboxed")
util.AddNetworkString("VoidCases.SpawnCase")
util.AddNetworkString("VoidCases.Open2DCase")
util.AddNetworkString("VoidCases.AnnounceItemUnlock")
util.AddNetworkString("VoidCases.CaseOpenError")

local function netCooldownPly(ply, time)
    if (!VoidCases.HasTLoaded) then return true end
    if (ply.voidcases_netcooldown and ply.voidcases_netcooldown > SysTime()) then return true end
    ply.voidcases_netcooldown = SysTime() + (time or 1)
    return false
end

local L = VoidCases.Lang.GetPhrase

function VoidCases.IsModel(model)
	if (model == nil) then return false end
	local result = string.find(model, "models/") and string.find(model, ".mdl")
	return result
end

function VoidCases.InitCaseOpen(ply, case, casePos, caseAng, is2D)

    if (ply.vcases_spawnedCases and #ply.vcases_spawnedCases >= tonumber(VoidCases.Config.MaxCasesAtOnce)) then
        VoidLib.Notify(ply, L"error_occured", L"max_items_once", Color(255,0,0), 5)
        return
    end

    local caseItem = VoidCases.Config.Items[tonumber(case)]
    if (!caseItem) then return end

    local inventory = VoidCases.GetPlayerInventory(ply:SteamID64())
    if (inventory and table.Count(inventory) > 0) then

        local hasCase = false
        local hasKey  = false
        local keyToTake = nil

        if (!caseItem.info.requiresKey) then
            hasKey = true
        end

        for k, v in pairs(inventory) do

            if (tonumber(k) == tonumber(case)) then
                hasCase = true
                continue
            end

            if (!caseItem.info.requiresKey and hasCase) then
                break
            end

            local item = VoidCases.Config.Items[tonumber(k)]
            if (!item) then continue end

            if (item.type != VoidCases.ItemTypes.Key) then continue end
            
            if (item.info.unlocks[case]) then
                keyToTake = k
                hasKey = true

                if (hasCase) then
                    break
                end
            end
        end


        if (!hasCase or !hasKey) then return end

        if (keyToTake) then
            VoidCases.AddItem(ply:SteamID64(), keyToTake, -1)
            VoidCases.NetworkItem(ply, keyToTake, -1)
        end

        VoidCases.AddItem(ply:SteamID64(), case, -1)
        VoidCases.NetworkItem(ply, case, -1)

        if (!is2D) then
            VoidCases.SpawnCase(ply, VoidCases.Config.Items[tonumber(case)], casePos, caseAng)
        else
            VoidCases.Open2DCase(ply, VoidCases.Config.Items[tonumber(case)])
        end

    end

    return true

end

local function netSpawnCrate(len, ply)

    if (netCooldownPly(ply, 0.6)) then return end

    // Check if the player has the case
    local case = net.ReadUInt(32)
    local casePos = net.ReadVector()
    local caseAng = net.ReadAngle()

    if (!VoidCases.Config.Items[case]) then return end
    if (VoidCases.Config.Items[case].type != VoidCases.ItemTypes.Case) then return end

    if (ply:GetPos():Distance(casePos) > 600) then return end

    VoidCases.InitCaseOpen(ply, case, casePos, caseAng, false)
    
end
net.Receive("VoidCases.SpawnCase", netSpawnCrate)

local function weightedPick(tab)

    math.randomseed(os.clock() * 100000000000)
    math.random()
    math.random()
    math.random()

    local sum = 0

	for _, chance in pairs(tab) do
		sum = sum + chance
	end

	local select = math.random() * sum

	for key, chance in pairs(tab) do
		select = select - chance
		if select < 0 then return key end
	end
    
end

function VoidCases.UnboxItem(case)
    // make it more random - b81955005623d0c8db8898e716d007d1b35748d17039ba702b2afd2cf5014729
    math.random()
    math.random()

    local unboxableItems = case.info.unboxableItems
    for k, v in pairs(unboxableItems) do
        if (!VoidCases.Config.Items[k]) then
            unboxableItems[k] = nil
        end
    end

    local unboxedItem = weightedPick(unboxableItems)

    return VoidCases.Config.Items[unboxedItem], unboxedItem
    
end

function VoidCases.Open2DCase(ply, case)
    local unboxedCase, unboxedID = VoidCases.UnboxItem(case)

    if (!unboxedCase) then
        VoidCases.PrintError("No items configured for case " .. case.name .. "!")
        VoidLib.Notify(ply, L"error_occured", L"no_items_avail", Color(255,0,0), 5)
        return
    end

    net.Start("VoidCases.SendCaseUnboxed")
        net.WriteUInt(unboxedID, 32)
    net.Send(ply)

    timer.Simple(9, function ()
        if (unboxedCase.info.autoEquip and IsValid(ply)) then
            VoidCases.EquipItem(ply, unboxedID, true)
        end

        if (VoidCases.Config.AnnouceWin and ply:IsValid()) then
            
            local currRarity = VoidCases.GetRarityById(tonumber(unboxedCase.info.rarity))
            local reqRarity = VoidCases.Config.CustomRarities[VoidCases.Config.AnnouceWinRarity]

            if (currRarity[3] >= reqRarity[3]) then
                net.Start("VoidCases.AnnounceItemUnlock")
                    net.WriteString(ply:Nick())
                    net.WriteString(unboxedCase.name)
                    net.WriteColor(VoidCases.RarityColors[tonumber(unboxedCase.info.rarity)])
                net.Broadcast()
            end
        end

	hook.Run("VoidCases.CaseUnboxed", ply, unboxedCase, unboxedID, case)
    end)

    // Give item
    VoidCases.AddItem(ply:SteamID64(), unboxedID, 1)

    // Network
    VoidCases.NetworkItem(ply, unboxedID, 1)

end



local function netOpenCase(len, ply)

    if (netCooldownPly(ply, 0.5)) then return end

    local case = net.ReadUInt(32)

    local item = VoidCases.Config.Items[case]
    if (!item or item.type != VoidCases.ItemTypes.Case) then return end

    local bSuccess = VoidCases.InitCaseOpen(ply, case, nil, nil, true)
    if (!bSuccess) then
        net.Start("VoidCases.CaseOpenError")
        net.Send(ply)
    end

end
net.Receive("VoidCases.Open2DCase", netOpenCase)

function VoidCases.SpawnCase(ply, case, pos, ang)
    if (!case or !case.info) then return end

    if (!ply.vcases_spawnedCases) then
        ply.vcases_spawnedCases = {}
    end



    local caseEnt = ents.Create("voidcases_crate")
    caseEnt:SetModel(case.info.icon)
    caseEnt:SetPos(pos)

    ang:RotateAroundAxis(Vector(0,0,1), 180)

    caseEnt:SetAngles(ang)

    local caseColor = Color(case.info.caseColor.r, case.info.caseColor.g, case.info.caseColor.b)

    caseEnt:SetNWString("CrateLogo", case.info.caseIcon)
    caseEnt:SetNWVector("CrateColor", caseColor:ToVector())

    caseEnt:Spawn()
    caseEnt:SetModel(case.info.icon)

    table.insert(ply.vcases_spawnedCases, caseEnt)

    // Network the logo
    net.Start("VoidCases_BroadcastLogoDL")
        net.WriteString(case.info.caseIcon)
    net.Broadcast()


    local phys = caseEnt:GetPhysicsObject()
    phys:EnableMotion(false)

    if (VoidCases.Config.DisableUnboxCollision) then
        caseEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    end

    timer.Simple(VoidCases.Config.UnboxDespawn, function ()
        if (IsValid(caseEnt)) then
            if (IsValid(ply)) then
                table.RemoveByValue(ply.vcases_spawnedCases, caseEnt)
            end
            caseEnt:Remove()
        end
    end)

    // Algorithm for choosing the item here
    local unboxedItem, unboxedID = VoidCases.UnboxItem(case)

    caseEnt:SetNWInt("CaseID", case.id)
    caseEnt:SetNWInt("UnboxedID", unboxedID)

    if (!unboxedItem) then
        VoidCases.PrintError("No items configured for case " .. case.name .. "!")
        VoidLib.Notify(ply, L"error_occured", L"no_items_avail", Color(255,0,0), 5)

        return
    end

    hook.Run("VoidCases.CaseUnboxed", ply, unboxedItem, unboxedID, case)

    timer.Simple(5, function ()
        VoidLib.Notify(ply, L"just_unboxed", unboxedItem.name, VoidCases.RarityColors[tonumber(unboxedItem.info.rarity)], 4)

        if (unboxedItem.info.autoEquip and IsValid(ply)) then
            VoidCases.EquipItem(ply, unboxedID, true)
        end

        if (VoidCases.Config.AnnouceWin) then
            if (!IsValid(ply)) then return end

            local currRarity = VoidCases.GetRarityById(tonumber(unboxedItem.info.rarity))
            local reqRarity = VoidCases.Config.CustomRarities[VoidCases.Config.AnnouceWinRarity]
            if (!reqRarity or !currRarity) then return end

            if (currRarity[3] >= reqRarity[3]) then
                net.Start("VoidCases.AnnounceItemUnlock")
                    net.WriteString(ply:Nick())
                    net.WriteString(unboxedItem.name)
                    net.WriteColor(VoidCases.RarityColors[tonumber(unboxedItem.info.rarity)])
                net.Broadcast()
            end
        end
    end)


    local isWeaponSkin = (unboxedItem.info.weaponSkin and unboxedItem.type == VoidCases.ItemTypes.Unboxable and unboxedItem.info.actionType == "weapon_skin")

    //unboxedItem.info.weaponSkin

    local wepSkin = nil
    local wepMaterial = nil

    if (SH_EASYSKINS and isWeaponSkin) then
        wepSkin = SH_EASYSKINS.GetSkin(tonumber(unboxedItem.info.weaponSkin))
        wepMaterial = (wepSkin and wepSkin.material.path) or nil
        if (!wepMaterial) then
            isWeaponSkin = false 
        end
    end

    if (VoidCases.IsModel(unboxedItem.info.icon)) then
        caseEnt:PerformAnimation(unboxedItem.info.icon, false, isWeaponSkin, wepMaterial, tonumber(unboxedItem.info.rarity))
    else
        // Icon??
        caseEnt:PerformAnimation(unboxedItem.info.icon, true, false, nil, tonumber(unboxedItem.info.rarity))
    end

    // Give item
    VoidCases.AddItem(ply:SteamID64(), unboxedID, 1)

    // Network
    VoidCases.NetworkItem(ply, unboxedID, 1)
end
