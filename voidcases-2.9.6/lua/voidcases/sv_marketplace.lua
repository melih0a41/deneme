
util.AddNetworkString("VoidCases_CreateMarketplaceListing")
util.AddNetworkString("VoidCases_PurchaseMarketplaceItem")

util.AddNetworkString("VoidCases.CancelListing")

VoidCases.MarketplaceListings = VoidCases.MarketplaceListings or {}

local L = VoidCases.Lang.GetPhrase

local function netCooldownPly(ply, time)
    if (!VoidCases.HasTLoaded) then return true end

    local sysTime = SysTime()
    if (ply.voidcases_netcooldown and ply.voidcases_netcooldown > sysTime) then return true end
    ply.voidcases_netcooldown = sysTime + (time or 1)
    return false
end


local function netCreateListing(len, ply)

    if (netCooldownPly(ply, 1)) then return end

    if (VoidCases.Config.DisableMarketplace) then return end

    local itemID = net.ReadUInt(32)
    local amount = net.ReadUInt(32)
    local price  = net.ReadUInt(32)

    local item = VoidCases.Config.Items[itemID]
    if (!item) then return end

    if (item.info.marketplaceBlacklist) then return end

    if (amount == 0) then return end
    if (price < 0 or price > 4294967294) then return end
    // local maxPrice = 25380729255894037 (64bit max)

    VoidCases.GetMarketplaceListings(function (listings)
        local maxListings = tonumber(VoidCases.Config.MaxMarketplaceListings)
        if (maxListings and table.Count(listings) + 1 > maxListings and maxListings != 0) then
            VoidLib.Notify(ply, L"error", L("too_many_listings", maxListings), VoidUI.Colors.Red, 5)
            return
        end
        local result = VoidCases.GetPlayerInventoryItem(ply:SteamID64(), itemID)
        // Has the item and the amount?
        if (result >= amount) then
            // Take items
            VoidCases.AddItem(ply:SteamID64(), itemID, -amount)

            // Network
            VoidCases.NetworkItem(ply, itemID, -amount)

            // Add to DB
            VoidCases.InsertMarketplaceListing(ply:SteamID64(), itemID, amount, price)

            // Notify the player
            VoidLib.Notify(ply, L"just_listed", item.name, VoidCases.RarityColors[tonumber(item.info.rarity)], 5)

            // Hook
            hook.Run("VoidCases.MarketplaceListingCreated", ply, item, itemID, amount, price)

        else
            VoidLib.Notify(ply, L"error_occured", L"not_enough_items", Color(255,0,0), 5)
        end
    end, ply)

end

net.Receive("VoidCases_CreateMarketplaceListing", netCreateListing)




local function netPurchaseMarketplaceItem(len, ply)

    if (netCooldownPly(ply, 1)) then return end

    local listingID = net.ReadUInt(32)
    local amount = net.ReadUInt(32)

    if (amount == 0) then return end


    local info = VoidCases.GetMarketplaceListingInfo(listingID)
    if (!info) then return end
    if (info.sid == ply:SteamID64()) then return end


    local itemInfo = VoidCases.Config.Items[tonumber(info.item)]
    if (!itemInfo) then return end

    local itemCurrency = itemInfo.info.currency or VoidCases.Config.Currency or "DarkRP"

    local currency = VoidCases.Currencies[itemCurrency]
    if (!currency) then
        VoidLib.Notify(ply, L"error_occured", L"no_currency", Color(206, 83, 83), 4)
        return
    end


    local money = currency.getFunc(ply)
    if (tonumber(money) < tonumber(info.price * amount)) then
        VoidLib.Notify(ply, L"couldnt_purchase", L"not_enough_money", Color(206, 83, 83), 4)
        return
    end

    if (tonumber(info.amount) < tonumber(amount)) then
        VoidLib.Notify(ply, L"couldnt_purchase", L"mp_not_enough_items", Color(206, 83, 83), 4)
        return
    end

    if (tonumber(info.amount) == tonumber(amount)) then
        // Delete listing
        VoidCases.RemoveMarketplaceListing(listingID)
    else
        VoidCases.ModifyMarketplaceListingAmount(listingID, info.amount - amount)
    end

    VoidCases.NetworkBroadcastMarketplace()

    // Notify the player
    VoidLib.Notify(ply, L"just_bought", itemInfo.name, VoidCases.RarityColors[tonumber(itemInfo.info.rarity)], 5)

    if (!isnumber(info.price)) then
        info.price = tonumber(info.price or 0) or 0
    end

    // Take money from purchaser
    currency.addFunc(ply, -(info.price * amount))
    
    // Give money to seller
    local plySeller = player.GetBySteamID64(info.sid)
    if (IsValid(plySeller)) then
        // Is online?
        currency.addFunc(plySeller, info.price * amount)

        VoidLib.Notify(plySeller, L"just_got_bought", itemInfo.name, VoidCases.RarityColors[tonumber(itemInfo.info.rarity)], 5)
    else
        // Add to pendingmoney DB
        VoidCases.AddToPendingMoney(tostring(info.sid), info.price * amount, itemCurrency)
    end
    
    // Give item to purchaser
    VoidCases.AddItem(ply:SteamID64(), tonumber(info.item), amount)

    // Network
    VoidCases.NetworkItem(ply, tonumber(info.item), amount)

    // Hook
    hook.Run("VoidCases.MarketplaceListingPurchase", ply, tostring(info.sid), itemInfo, tonumber(info.item), amount, info.price * amount)



end
net.Receive("VoidCases_PurchaseMarketplaceItem", netPurchaseMarketplaceItem)

local function netCancelListing(len, ply)
    local listingID = net.ReadUInt(32)

    local info = VoidCases.GetMarketplaceListingInfo(listingID)
    if (!info) then return end
    if (info.sid != ply:SteamID64()) then return end

    -- Give back items
    local item = tonumber(info.item)
    local amount = tonumber(info.amount)

    local itemInfo = VoidCases.Config.Items[item]
    if (!itemInfo) then return end

    VoidCases.RemoveMarketplaceListing(listingID, true)

    VoidCases.AddItem(ply:SteamID64(), item, amount)
    VoidCases.NetworkItem(ply, item, amount)

    VoidLib.Notify(ply, L"just_unlisted", itemInfo.name, VoidCases.RarityColors[tonumber(itemInfo.info.rarity)], 5)

    hook.Run("VoidCases.MarketplaceListingRemoved", ply, itemInfo, item, amount, listingID)
end
net.Receive("VoidCases.CancelListing", netCancelListing)

local function handlePendingMoney(ply)
    if (!IsValid(ply)) then return end
    VoidCases.GetPendingMoney(ply:SteamID64(), function (result)
        timer.Simple(2, function ()
            if (!IsValid(ply)) then return end
            if (result and #result > 0) then
                -- Give pending money
                for k, v in pairs(result) do
                    local moneyToGive = tonumber(v.money or 0) or 0
                    local currencyStr = v.currency or VoidCases.Config.Currency or "DarkRP"

                    local currency = VoidCases.Currencies[currencyStr]
                    if (!currency) then
                        VoidLib.Notify(ply, L"error_occured", L"no_currency", Color(206, 83, 83), 4)
                        return
                    end
                    
                    if (!moneyToGive or !isnumber(moneyToGive)) then
                        continue
                    end

                    currency.addFunc(ply, moneyToGive)
                end

                ply:SetNWInt("VoidCases.SoldWhileOffline", #result)

                local strSteamId = ply:SteamID64()
                timer.Simple(2, function ()
                    VoidCases.ClearPendingMoney(strSteamId)
                end)
            end
        end)
    end)
end

hook.Add("PlayerInitialSpawn", "VoidCases.ClaimPendingMoney", function (ply)
    if (VoidChar) then return end

    timer.Simple(8, function ()
        handlePendingMoney(ply)
    end)
end)

hook.Add("VoidChar.CharacterSelected", "VoidCases.ClaimPendingMoney.VoidChar", function (ply)
    if (!VoidChar) then return end

    handlePendingMoney(ply)
end)


function VoidCases.AddToPendingMoney(sid64, money, currency)
    local query = VoidLib.SQL:Insert("voidcases_pendingmoney")
		query:Insert("sid", sid64)
		query:Insert("money", money)
        query:Insert("currency", currency)
	query:Execute()
end

function VoidCases.GetPendingMoney(sid64, callback)
    local query = VoidLib.SQL:Select("voidcases_pendingmoney")
		query:Where("sid", sid64)
		query:Callback(function (result, status, lastID)
            callback(result)
		end)

	query:Execute()
end

function VoidCases.ClearPendingMoney(sid64)
    local query = VoidLib.SQL:Delete("voidcases_pendingmoney")
		query:Where("sid", sid64)
	query:Execute()
end

function VoidCases.GetMarketplaceListings(callback, ply)
    local query = VoidLib.SQL:Select("voidcases_marketplace")
        if (ply) then
            query:Where("sid", ply:SteamID64())
        end
		query:Callback(function (result, status, lastID)
            callback(result or {})
		end)

	query:Execute()
end

function VoidCases.GetMarketplaceListingInfo(listingID, callback)
    if (callback) then
        local query = VoidLib.SQL:Select("voidcases_marketplace")
            query:Where("listingid", listingID)
            query:Callback(function (result, status, lastID)
                if (result and #result > 0 and istable(result)) then
                    callback(result[1])
                end
            end)

        query:Execute()
    else
        return VoidCases.MarketplaceListings[listingID]
    end
end

function VoidCases.ModifyMarketplaceListingAmount(listingID, amount)

    VoidCases.MarketplaceListings[listingID].amount = amount

    local query = VoidLib.SQL:Update("voidcases_marketplace")
        query:Update("amount", amount)
        query:Where("listingid", listingID)
    query:Execute()
end


function VoidCases.RemoveMarketplaceListing(listingID, shouldNetwork)

    VoidCases.MarketplaceListings[listingID] = nil

    local query = VoidLib.SQL:Delete("voidcases_marketplace")
        query:Where("listingid", listingID)

        query:Callback(function ()
            if (shouldNetwork) then
                VoidCases.NetworkBroadcastMarketplace()
            end
        end)
    query:Execute()
end

function VoidCases.InsertMarketplaceListing(sid64, item, amount, price)
    
    
    local query = VoidLib.SQL:Insert("voidcases_marketplace")
		query:Insert("sid", sid64)
		query:Insert("item", item)
		query:Insert("amount", amount)
        query:Insert("price", price)
        query:Insert("timestamp", os.time())

        query:Callback(function (res, d, id)
            // Network the stuff
            VoidCases.MarketplaceListings[id] = {
                sid = sid64,
                item = item,
                amount = amount,
                price = price
            }

            VoidCases.NetworkBroadcastMarketplace()
        end)

	query:Execute()
end

function VoidCases.NetworkBroadcastMarketplace()
    VoidCases.GetMarketplace(function (result)
        local data = nil
        if (result and #result > 0) then
            data = util.TableToJSON(result)
            data = util.Compress(data)
        else
            data = util.Compress("[]")
        end

        net.Start("VoidCases_NetworkMarketplace")
            net.WriteUInt(#data, 32)
            net.WriteData(data, #data)
        net.Broadcast()
    end)
end

function VoidCases.NetworkMarketplace(ply)
    VoidCases.GetMarketplace(function (result)
        local data = nil
        if (result and #result > 0) then
            data = util.TableToJSON(result)
            data = util.Compress(data)
        else
            data = util.Compress("[]")
        end


        net.Start("VoidCases_NetworkMarketplace")
            net.WriteUInt(#data, 32)
            net.WriteData(data, #data)
        net.Send(ply)
    end)
end

function VoidCases.DeleteOldListings()
    local query = VoidLib.SQL:Delete("voidcases_marketplace")
        query:WhereLT("timestamp", os.time() - VoidCases.Config.ListingTime * 60 * 60 * 60)
    query:Execute()

    VoidCases.NetworkBroadcastMarketplace()
end

timer.Create("VoidCases.MarketplaceTime", 600, 0, function ()
    VoidCases.DeleteOldListings()
end)

hook.Add("Initialize", "VoidCases.LoadMarketplace", function ()
    //VoidCases.MarketplaceListings
    VoidCases.GetMarketplaceListings(function (result)
        local market = {}
        for k, v in pairs(result or {}) do
            market[tonumber(v.listingid)] = v
        end

        VoidCases.MarketplaceListings = market
    end)
end)


