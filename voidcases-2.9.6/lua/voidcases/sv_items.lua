
-- Why is this network string format used only here??
util.AddNetworkString("VoidCases_CreateCategory")
util.AddNetworkString("VoidCases_ModifyCategory")
util.AddNetworkString("VoidCases_DeleteCategory")

util.AddNetworkString("VoidCases_CreateItem")
util.AddNetworkString("VoidCases_ModifyItem")
util.AddNetworkString("VoidCases_DeleteItem")

util.AddNetworkString("VoidCases_ChangeItemCategory")

util.AddNetworkString("VoidCases_PurchaseItem")
util.AddNetworkString("VoidCases_EquipItem")

util.AddNetworkString("VoidCases_CreateRarity")
util.AddNetworkString("VoidCases_MoveRarity")

util.AddNetworkString("VoidCases_NetworkFeaturedItems")


// Concommands

concommand.Add("voidcases_giveitem", function(ply, cmd, args)
    if (ply != NULL and !ply:IsSuperAdmin()) then return end

    local sid = tostring(args[1])
    local id = tonumber(args[2])
    local amount = tonumber(args[3] or 1)

    local item = VoidCases.Config.Items[id]
    if (!item) then print("invalid item (", id, ")") return end

    VoidCases.AddItem(sid, id, amount)

    local pPly = player.GetBySteamID64(sid)

    if tostring(sid):lower():StartWith("steam_") then
		pPly = player.GetBySteamID(sid)
	end

    if (IsValid(pPly)) then
        VoidCases.NetworkItem(pPly, id, amount)
    end

end)

concommand.Add("voidcases_giveitem_allonline", function (ply, cmd, args)
    if (ply != NULL and !ply:IsSuperAdmin()) then return end

    local id = tonumber(args[1])
    local amount = tonumber(args[2] or 1)

    local item = VoidCases.Config.Items[id]
    if (!item) then return end

    for k, v in ipairs(player.GetAll()) do
        VoidCases.AddItem(v:SteamID64(), id, amount)
        VoidCases.NetworkItem(v, id, amount)
    end
end)


// End

local function netCooldownPly(ply, time)

    local sysTime = SysTime()

    if (ply.voidcases_netcooldown and ply.voidcases_netcooldown > sysTime) then return true end
    ply.voidcases_netcooldown = sysTime + (time or 1)
    return false
end

local function L(phrase)
    return VoidCases.Lang.GetPhrase(phrase)
end

function VoidCases.AutomaticItemsFeature()

    VoidCases.GetMostPurchasedItems(5, function (result)
        if (result and #result > 0) then
            local featuredItems = {}
            local i = 0
            for k, v in pairs(result) do
                if (i > 3) then break end
                local item = VoidCases.Config.Items[tonumber(v.item)]
                if (!item or !item.info.sellInShop) then continue end
                table.insert(featuredItems, {item, v.item})
                i = i + 1
            end

            VoidCases.Config.FeaturedItems = featuredItems
            VoidCases.NetworkFeaturedItems()
        end
    end)

end

function VoidCases.NetworkFeaturedItems()
    local data = util.TableToJSON(VoidCases.Config.FeaturedItems or {})
    data = util.Compress(data)
    
    net.Start("VoidCases_NetworkFeaturedItems")
        net.WriteUInt(#data, 32)
        net.WriteData(data, #data)
    net.Broadcast()
end


function VoidCases.GetPlayerPurchases(sid64, callback)
	local query = VoidLib.SQL:Select("voidcases_purchases")
		query:Where("sid", sid64)
		query:Callback(function (result, status, lastID)
			callback(result)
		end)

	query:Execute()
end

function VoidCases.InsertPurchase(sid64, item, amount)
    local query = VoidLib.SQL:Insert("voidcases_purchases")
        query:Insert("sid", sid64)
        query:Insert("item", item)
        query:Insert("timestamp", os.time())
        query:Insert("amount", amount or 1)
        query:Callback(function ()
            VoidCases.AutomaticItemsFeature()
        end)
    query:Execute()
end

function VoidCases.GetMostPurchasedItems(limit, callback)
    local query = VoidLib.SQL:Select("voidcases_purchases")
        query:Select("item")
        query:GroupBy("item")
        query:OrderByDesc("COUNT(`item`)", true)
        query:Limit(limit)
		query:Callback(function (result, status, lastID)
			callback(result)
		end)

	query:Execute()
end



hook.Add("PlayerLoadout", "VoidCases.GivePermaWeapons", function (ply)

    VoidCases.GetPermaWeapons(ply, function (result)
        if (!IsValid(ply)) then return end
        VoidCases.EquippedPermas[ply] = 0
        for k, v in pairs(result) do
            local item = VoidCases.Config.Items[tonumber(v.item)]
            if (!item) then continue end

            if (item.type != VoidCases.ItemTypes.Unboxable or item.info.actionType != "weapon") then continue end
            if (item.info.isPermanent) then
                local wep = ply:Give(item.info.actionValue)
                if (IsValid(wep)) then
                    wep.isPermanent = true
                    VoidCases.EquippedPermas[ply] = VoidCases.EquippedPermas[ply] + 1
                end
            end
            
        end
    end)

    
end)

hook.Add("canDropWeapon", "VoidCases.CanDropPermaWep", function (ply, wep)
    if (wep.isPermanent) then return false end
end)

local function netPurchaseItem(len, ply)

    if (netCooldownPly(ply, 0.5)) then return end

    local itemID = net.ReadUInt(32)
    local item = VoidCases.Config.Items[itemID]
    if (!item or !item.info.sellInShop) then return end

    local amount = net.ReadUInt(32)
    if (amount == 0) then return end

    // Has money?
    local currency = VoidCases.Currencies[item.info.currency or VoidCases.Config.Currency or table.GetKeys(VoidCases.Currencies)[1] or "DarkRP"]
    if (!currency) then
        VoidLib.Notify(ply, L"error_occured", L"no_currency", Color(206, 83, 83), 4)
        return
    end

    local money = currency.getFunc(ply)
    if (tonumber(money) < tonumber(item.info.shopPrice * amount)) then
        VoidLib.Notify(ply, L"couldnt_purchase", L"not_enough_money", Color(206, 83, 83), 4)
        return
    end

    // Usergroup check
    if (item.info.requiredUsergroups and table.Count(item.info.requiredUsergroups) > 0) then
        local hasAccess = false
        for k, v in pairs(item.info.requiredUsergroups or {}) do
            if (VoidCases.Config.UseInheritance) then
                if (CAMI.UsergroupInherits(ply:GetUserGroup(), k)) then
                    hasAccess = true
                end
            else
                if (ply:GetUserGroup() == k) then
                    hasAccess = true
                end
            end
        end
        if (!hasAccess and item.info.requiredUsergroups) then return end
    end

    // Cooldown check
    VoidCases.IsOnCooldown(ply, itemID, amount, function (result, time)
        if (result) then 
            VoidLib.Notify(ply, L"couldnt_purchase", (isstring(time) and time) or string.format(L"buy_cooldown", string.NiceTime(time)), Color(206, 83, 83), 4)
            return
        end
		
        if (tonumber(money) < tonumber(item.info.shopPrice * amount)) then
            VoidLib.Notify(ply, L"couldnt_purchase", L"not_enough_money", Color(206, 83, 83), 4)
            return
        end

        local formattedItemName = (amount == 1 and item.name) or amount .. "x " .. item.name

        // Take money
        currency.addFunc(ply, -tonumber(item.info.shopPrice * amount))

        // Notify player
        VoidLib.Notify(ply, L"just_bought", formattedItemName, VoidCases.RarityColors[tonumber(item.info.rarity)], 4)

        // Network player inventory
        VoidCases.NetworkItem(ply, itemID, amount)

        // Give item
        VoidCases.AddItem(ply:SteamID64(), itemID, amount, function ()
            // Equip item if auto equip

            if (item.info.autoEquip and IsValid(ply)) then
                VoidCases.EquipItem(ply, itemID, true)
            end
        end)

        // Log purchase
        hook.Run("VoidCases.ItemPurchased", ply, item, itemID, amount, tonumber(item.info.shopPrice * amount))


        // Insert to purchases table
        VoidCases.InsertPurchase(ply:SteamID64(), itemID, amount)
    end)

    
end
net.Receive("VoidCases_PurchaseItem", netPurchaseItem)

function VoidCases.EquipItem(ply, itemID, dontNotify, count)
    count = count or 1
    if (count < 1) then return end

    local item = VoidCases.Config.Items[itemID]
    if (!item or item.type != VoidCases.ItemTypes.Unboxable) then return end

    local action = VoidCases.Actions[item.info.actionType]
    if (!action) then return end

    if (item.info.actionType == "weapon" and item.info.isPermanent) then return end

    if (ply.vc_lockedEquip) then return end

    if (DarkRP and ply:isArrested()) then return end

    local sid64 = ply:SteamID64()

    // Check if has item
    local result = VoidCases.GetPlayerInventoryItem(sid64, itemID)
    if (!result) then return end

    if (result and result >= count) then

        if (ply.vc_lockedEquip) then return end

        local func = action.action
        if (action.configData.supportCount) then
            func(ply, item.info.actionValue, item, count)
        else
            for i = 1, count do
                func(ply, item.info.actionValue, item)
            end
        end

        ply.vc_lockedEquip = true
        // Take item
        VoidCases.AddItem(sid64, itemID, -count, function ()
            ply.vc_lockedEquip = false
        end)

        // Network player inventory
        VoidCases.NetworkItem(ply, itemID, -count)

        // Notify player
        if (!dontNotify) then
            VoidLib.Notify(ply, L"equipped_item", item.name, VoidCases.RarityColors[tonumber(item.info.rarity)], 4)
        end
    end

end

function VoidCases.IsOnCooldown(ply, itemID, _amount, cb)

    local item = VoidCases.Config.Items[itemID]
    if (!item) then return end

    if (!item.info.cooldownType or item.info.cooldownType == 0) then 
        cb(false)
        return 
    end

    if (_amount > item.info.cooldownTime) then
        cb(true, string.format(L"buy_max_cooldown", item.info.cooldownTime))
        return
    end


    local timestamp = os.time() - item.info.cooldownType

    local query = VoidLib.SQL:Select("voidcases_purchases")
        query:Where("item", itemID)
        query:Where("sid", ply:SteamID64())
        query:WhereGT("timestamp", timestamp)
        query:Callback(function (result)
            local amount = 0

            for k, v in ipairs(result or {}) do
                local intIncrement = tonumber(v.amount) or 1
                if (intIncrement == 0) then
                    intIncrement = 1
                end
                amount = amount + intIncrement
            end

            local highestTimestamp = 0
            for k, v in pairs(result or {}) do
                if (tonumber(v.timestamp) > highestTimestamp) then
                    highestTimestamp = tonumber(v.timestamp)
                end
            end

            if (amount + _amount > item.info.cooldownTime) then
                cb(true, highestTimestamp - timestamp)
            else
                cb(false)
            end
        end)

	query:Execute()
end

net.Receive("VoidCases_CreateRarity", function (len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end
    
    local rarityName = net.ReadString()
    local isEditing = net.ReadBool()
    local rarityOld = nil

    if (isEditing) then
        rarityOld = net.ReadString()
    end

    local shouldDelete = net.ReadBool()

    if (!shouldDelete) then
        local color = net.ReadColor()
        VoidCases.EditRarity(rarityName, color, rarityOld)
    else
        VoidCases.DeleteRarity(rarityName)
    end
end)

net.Receive("VoidCases_MoveRarity", function (len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local rarityName = net.ReadString()
    local moveUp = net.ReadBool()

    VoidCases.MoveRarity(rarityName, moveUp)
end)

local function netEquipItem(len, ply)

    if (netCooldownPly(ply, 0.2)) then return end

    local itemID = net.ReadUInt(32)
    local itemCount = net.ReadUInt(32)

    VoidCases.EquipItem(ply, itemID, false, itemCount)

end
net.Receive("VoidCases_EquipItem", netEquipItem)

local function netCreateItem(len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local itemTable = net.ReadTable()

    VoidCases.CreateItem(itemTable.name, itemTable.type, itemTable.info)
    VoidCases.AutomaticItemsFeature()
end
net.Receive("VoidCases_CreateItem", netCreateItem)

local function netModifyItem(len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local itemID = net.ReadUInt(32)
    local itemTable = net.ReadTable()

    VoidCases.ModifyItem(itemID, itemTable)
    VoidCases.AutomaticItemsFeature()
end
net.Receive("VoidCases_ModifyItem", netModifyItem)

local function netDeleteItem(len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local itemID = net.ReadUInt(32)

    VoidCases.DeleteItem(itemID)
    VoidCases.AutomaticItemsFeature()
end
net.Receive("VoidCases_DeleteItem", netDeleteItem)

local function netCreateCategory(len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local category = net.ReadString()
    if (#category < 1 || #category > 100) then return end
    // 102488709990390805

    VoidCases.CreateCategory(category)
end
net.Receive("VoidCases_CreateCategory", netCreateCategory)

local function netDeleteCategory(len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local existingCategory = net.ReadUInt(16)
    VoidCases.DeleteCategory(existingCategory)
end
net.Receive("VoidCases_DeleteCategory", netDeleteCategory)

local function netModifyCategory(len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local existingCategory = net.ReadUInt(16)
    local newName = net.ReadString()
    VoidCases.ModifyCategory(existingCategory, newName)
end
net.Receive("VoidCases_ModifyCategory", netModifyCategory)

local function netChangeItemCategory(len, ply)
    if (!CAMI.PlayerHasAccess(ply, "VoidCases_CreateItems")) then return end

    local itemID = net.ReadUInt(32)
    local newCategory = net.ReadUInt(16)

    if (!VoidCases.Config.Categories[newCategory]) then return end

    local item = VoidCases.Config.Items[itemID]
    item.info.shopCategory = newCategory

    VoidCases.SaveConfig()
end
net.Receive("VoidCases_ChangeItemCategory", netChangeItemCategory)
