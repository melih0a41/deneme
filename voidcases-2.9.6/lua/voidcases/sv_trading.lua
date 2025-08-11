

/*
    VoidCases.TradeRequests = {
        [pRequester] = pReceiver,
    }

    VoidCases.Trades = {
        [pRequester] = pReceiver
    }

    VoidCases.TradeInfo = {
        [pRequester] = {
            requesterItems = {2 = 5, 4 = 1, 9 = 2}, // key: value -> itemid: amount
            receiverItems = {1 = 1, 5 = 3, 6 = 1},

            requesterMoney = 2000,
            receiverMoney = 0,

            reqFinish = {}, // key value table of players
        }

        if (25380729255894037 > 110488718581373973) then
            print("correct!")
        end
    }
*/

util.AddNetworkString("VoidCases.SyncTrade")
util.AddNetworkString("VoidCases.UpdateTrade")

util.AddNetworkString("VoidCases.SendTradeRequest")
util.AddNetworkString("VoidCases.ReceiveTradeRequest")
util.AddNetworkString("VoidCases.AcceptTradeRequest")

util.AddNetworkString("VoidCases.StartTrade")

util.AddNetworkString("VoidCases.TradeReady")
util.AddNetworkString("VoidCases.TradeFinish")

util.AddNetworkString("VoidCases.TradeEnd")
util.AddNetworkString("VoidCases.LeaveTrade")

util.AddNetworkString("VoidCases.TradeSendReady")

util.AddNetworkString("VoidCases.TradeChat")
util.AddNetworkString("VoidCases.TradeChatSync")

local L = VoidCases.Lang.GetPhrase

local function netCooldownPly(ply, time)
    if (ply.voidcases_netcooldown and ply.voidcases_netcooldown > SysTime()) then return true end
    ply.voidcases_netcooldown = SysTime() + (time or 1)
    return false
end

VoidCases.TradeRequests = {}
VoidCases.Trades = {}
VoidCases.TradeInfo = {}

function VoidCases.GetTradeInfo(ply)
    if (VoidCases.Trades[ply]) then return VoidCases.TradeInfo[ply], true, ply end

    for k, v in pairs(VoidCases.Trades) do
        if (v == ply) then return VoidCases.TradeInfo[k], false, k end
    end

    return false
end

function VoidCases.GetTradeRequester(ply)
    for k, v in pairs(VoidCases.TradeRequests) do
        if (v == ply) then
            return k
        end
    end

    return false
end

function VoidCases.IsInTrade(ply)
    return VoidCases.GetTradeInfo(ply) and true or false
end

function VoidCases.SendTradeRequest(plyReq, plyRec)

    if (VoidCases.Config.DisableTrading) then return end

    if (plyReq == plyRec) then return end

    if (VoidCases.TradeRequests[plyRec]) then return end

    if (VoidCases.TradeRequests[plyReq]) then
        VoidLib.Notify(plyReq, L"trading_error", L"trading_inprogress", Color(206, 83, 83), 3)
        return
    end
    VoidCases.TradeRequests[plyReq] = plyRec

    VoidLib.Notify(plyReq, L"trading_requestsent", string.format(L("trading_toply"), plyRec:Nick()), Color(35, 145, 71), 3)
    VoidLib.Notify(plyRec, L"trading_requestreceived", string.format(L("trading_fromply"), plyReq:Nick()), Color(68, 172, 199), 3)

    timer.Create("VoidCases.TradeRequest" .. plyReq:SteamID64(), VoidCases.Config.TradeRequestExpiration or 30, 1, function ()
        if (!IsValid(plyReq)) then return end
        if (!VoidCases.TradeRequests[plyReq]) then return end

        VoidCases.TradeRequests[plyReq] = nil
        VoidLib.Notify(plyReq, L"trading_error", L"trading_requestexpired", Color(206,83,83), 5)

        if (IsValid(plyRec)) then
            net.Start("VoidCases.ReceiveTradeRequest")
                net.WriteEntity(plyReq)
                net.WriteBool(true)
            net.Send(plyRec)
        end
    end)

    net.Start("VoidCases.ReceiveTradeRequest")
        net.WriteEntity(plyReq)
        net.WriteBool(false)
    net.Send(plyRec)
end

net.Receive("VoidCases.SendTradeRequest", function (len, ply)
    local receiver = net.ReadEntity()
    if (!receiver:IsPlayer()) then return end

    VoidCases.SendTradeRequest(ply, receiver)
end)

net.Receive("VoidCases.TradeChat", function (len, ply)
    local tradeInfo, isReq, req = VoidCases.GetTradeInfo(ply)
    if (!tradeInfo) then return end

    local msg = net.ReadString()
    local deliverTo = isReq and VoidCases.Trades[req] or req

    if (msg == "" or msg == " ") then return end
    if (netCooldownPly(ply, 0.5)) then return end

    net.Start("VoidCases.TradeChatSync")
        net.WriteString(msg)
    net.Send(deliverTo)
end)

function VoidCases.AcceptTradeRequest(ply, requester)

    local tradeRequest = VoidCases.TradeRequests[requester]
    if (!tradeRequest) then return end
    if (tradeRequest != ply) then return end

    if (VoidCases.Trades[ply]) then
        VoidCases.EndTrade(ply)
    end

    VoidCases.Trades[requester] = ply
    VoidCases.TradeInfo[requester] = {
        requesterItems = {},
        receiverItems = {},

        requesterMoney = 0,
        receiverMoney = 0,

        requesterCurrency = table.GetKeys(VoidCases.Currencies)[1],
        receiverCurrency = table.GetKeys(VoidCases.Currencies)[1],

        reqFinish = {},
    }

    timer.Remove("VoidCases.TradeRequest" .. requester:SteamID64())
    VoidCases.TradeRequests[ply] = nil

    net.Start("VoidCases.StartTrade")
        net.WriteEntity(requester)
    net.Send({ply, requester})
end

net.Receive("VoidCases.AcceptTradeRequest", function (len, ply)
    local requester = net.ReadEntity()
    if (!requester:IsPlayer()) then return end

    VoidCases.AcceptTradeRequest(ply, requester)
end)

function VoidCases.SyncTrade(plyReq)
    local tradeInfo = VoidCases.GetTradeInfo(plyReq)
    if (!tradeInfo) then return end

    local players = {plyReq, VoidCases.Trades[plyReq]}

    net.Start("VoidCases.SyncTrade")
        net.WriteTable(tradeInfo)
    net.Send(players)
end

function VoidCases.UpdateTrade(ply, items, money, currency)
    local tradeInfo, isRequester, requester = VoidCases.GetTradeInfo(ply)
    if (!tradeInfo) then return end

    local itemsValid = true
    for k, v in pairs(items) do
        local item = VoidCases.Config.Items[tonumber(k)]
        if (!item or item.info.marketplaceBlacklist) then
            itemsValid = false
        end
    end

    VoidCases.PlayerHasAllItemsTable(ply, items, function (resultRec)
	    if (!resultRec) then
	        itemsValid = false
	    end

	    if (!itemsValid) then
	        VoidCases.NotifyTraders(requester, L"trading_error", L"trading_mismatch", Color(206, 83, 83), 4)
	        VoidCases.EndTrade(requester)
	        return
	    end
	
	    if (!VoidCases.Currencies[currency]) then
	        currency = table.GetKeys(VoidCases.Currencies)[1]
	    end
	
	    local currencyObj = VoidCases.Currencies[currency]
	    if (currencyObj.getFunc(ply) < money) then
	        money = 0
	    end
	
	    if (isRequester) then
	        tradeInfo.requesterMoney = money
	        tradeInfo.requesterItems = items
	        tradeInfo.requesterCurrency = currency
	    else
	        tradeInfo.receiverMoney = money
	        tradeInfo.receiverItems = items
	        tradeInfo.receiverCurrency = currency
	    end
	
	    VoidCases.SyncTrade(requester)
    end)
end

net.Receive("VoidCases.UpdateTrade", function (len, ply)
    if (netCooldownPly(ply, 0.15)) then return end
		
    local itemCount = net.ReadUInt(12)
    local items = {}
    for i = 1, itemCount do
        local itemId = net.ReadUInt(20)
        local amount = net.ReadUInt(32)
                
        items[itemId] = amount
    end

    local money = net.ReadUInt(32)
    local currency = net.ReadString()

    VoidCases.UpdateTrade(ply, items, money, currency)
end)

function VoidCases.TradeReady(ply)
    local tradeInfo, b, req = VoidCases.GetTradeInfo(ply)
    if (!tradeInfo) then return end

    tradeInfo.reqFinish[ply] = !tradeInfo.reqFinish[ply]

    local otherPlayer = (ply == req and VoidCases.Trades[ply]) or req

    net.Start("VoidCases.TradeSendReady")
        net.WriteBool(tradeInfo.reqFinish[ply])
    net.Send(otherPlayer)

    if (tradeInfo.reqFinish[otherPlayer] and tradeInfo.reqFinish[ply]) then
        -- trade!
        VoidCases.FinishTrade(req)
    end
end

net.Receive("VoidCases.TradeReady", function (len, ply)
    VoidCases.TradeReady(ply)
end)

function VoidCases.NotifyTraders(plyReq, title, msg, col, time)
    local tradeInfo = VoidCases.GetTradeInfo(plyReq)
    if (!tradeInfo) then return end

    local players = {plyReq, VoidCases.Trades[plyReq]}
    for k, v in pairs(players) do
        VoidLib.Notify(v, title, msg, col, time)
    end

    -- 25380729255894037

end

function VoidCases.GetPlayerItemsTable(ply, callback)
    VoidCases.GetPlayerInventory(ply:SteamID64(), function (result)
		if (result and #result > 0) then
			local itemTable = {}
			for k, v in pairs(result) do
				itemTable[tonumber(v.item)] = tonumber(v.amount)
			end

            callback(itemTable)
        else
            callback({})
        end
    end)
end

function VoidCases.PlayerHasAllItemsTable(ply, items, callback)
    VoidCases.GetPlayerItemsTable(ply, function (inv)
        local hasItems = true
        for id, amount in pairs(items) do
            if (!inv[id]) then 
                hasItems = false
            end

            if (inv[id] and inv[id] < amount) then
                hasItems = false
            end
        end

        callback(hasItems)
    end)
end

function VoidCases.FinishTrade(plyReq)


    local tradeInfo = VoidCases.GetTradeInfo(plyReq)
    if (!tradeInfo) then return end

    local players = {plyReq, VoidCases.Trades[plyReq]}

    local plyRec = VoidCases.Trades[plyReq]



    VoidCases.PlayerHasAllItemsTable(plyRec, tradeInfo.receiverItems, function (resultRec)

        if (!resultRec) then
            VoidCases.NotifyTraders(plyReq, L"trading_error", L"trading_mismatch", Color(206, 83, 83), 4)
            VoidCases.EndTrade(plyReq)
            return
        end



        VoidCases.PlayerHasAllItemsTable(plyReq, tradeInfo.requesterItems, function (resultReq)
            if (!resultReq) then
                VoidCases.NotifyTraders(plyReq, L"trading_error", L"trading_mismatch", Color(206, 83, 83), 4)
                VoidCases.EndTrade(plyReq)
                return
            end
					
	    if (!IsValid(plyRec) or !IsValid(plyReq)) then return end

            for k, v in pairs(tradeInfo.requesterItems) do
                k = tonumber(k)
                v = tonumber(v)
                VoidCases.AddItem(plyRec:SteamID64(), k, v)
                VoidCases.NetworkItem(plyRec, k, v)

                VoidCases.AddItem(plyReq:SteamID64(), k, -v)
                VoidCases.NetworkItem(plyReq, k, -v)
            end

            for k, v in pairs(tradeInfo.receiverItems) do
                k = tonumber(k)
                v = tonumber(v)
                VoidCases.AddItem(plyRec:SteamID64(), k, -v)
                VoidCases.NetworkItem(plyRec, k, -v)

                VoidCases.AddItem(plyReq:SteamID64(), k, v)
                VoidCases.NetworkItem(plyReq, k, v)
            end

            if (tradeInfo.requesterMoney != 0) then
                local reqCurrency = VoidCases.Currencies[tradeInfo.requesterCurrency]
                if (!reqCurrency) then
                    VoidCases.NotifyTraders(plyReq, L"error_occured", L"no_currency", Color(206, 83, 83), 4)
                    VoidCases.EndTrade(plyReq)
                    return
                end

                local reqMoney = reqCurrency.getFunc(plyReq)
                if (tonumber(reqMoney) < tradeInfo.requesterMoney) then
                    VoidCases.NotifyTraders(plyReq, L"trading_error", L"trading_mismatch", Color(206, 83, 83), 4)
                    VoidCases.EndTrade(plyReq)
                    return
                end

                reqCurrency.addFunc(plyReq, -tradeInfo.requesterMoney)
                reqCurrency.addFunc(plyRec, tradeInfo.requesterMoney)
            end

            if (tradeInfo.receiverMoney != 0) then
                local recCurrency = VoidCases.Currencies[tradeInfo.receiverCurrency]
                if (!recCurrency) then
                    VoidCases.NotifyTraders(plyReq, L"error_occured", L"no_currency", Color(206, 83, 83), 4)
                    VoidCases.EndTrade(plyReq)
                    return
                end

                local recMoney = recCurrency.getFunc(plyRec)
                if (tonumber(recMoney) < tradeInfo.receiverMoney) then
                    VoidCases.NotifyTraders(plyReq, L"trading_error", L"trading_mismatch", Color(206, 83, 83), 4)
                    VoidCases.EndTrade(plyReq)
                    return
                end

                recCurrency.addFunc(plyRec, -tradeInfo.receiverMoney)
                recCurrency.addFunc(plyReq, tradeInfo.receiverMoney)
            end

            for k, v in pairs(players) do
                local otherPlayer = plyReq == v and plyRec or plyReq
                if (IsValid(v) and IsValid(otherPlayer)) then
                    VoidLib.Notify(v, L"trading_end", string.format(L"trading_success", otherPlayer:Nick()), Color(35, 145, 71), 5)
                end
            end

            hook.Run("VoidCases.TradeCompleted", plyRec, plyReq, tradeInfo)

            VoidCases.EndTrade(plyReq)


        end)
    end)

    
end



function VoidCases.EndTrade(plyReq)
    local otherPlayer = VoidCases.Trades[plyReq]

    VoidCases.Trades[plyReq] = nil
    VoidCases.TradeInfo[plyReq] = nil
    VoidCases.TradeRequests[plyReq] = nil

    net.Start("VoidCases.TradeEnd")
    net.Send({plyReq, otherPlayer})
end

net.Receive("VoidCases.LeaveTrade", function (len, ply)
    local tradeInfo, b, req = VoidCases.GetTradeInfo(ply)
    if (tradeInfo) then

        local otherPlayer = (ply == req and VoidCases.Trades[ply]) or req
        local players = {ply, otherPlayer}

        for k, v in pairs(players) do
            local nick = ply == v and "You" or ply:Nick()
            VoidLib.Notify(v, L"trading_end", string.format(L"trading_playerend", nick), Color(206, 83, 83), 5)
        end

        VoidCases.EndTrade(req)
    end 
end)

hook.Add("PlayerDisconnected", "VoidCases.TradeDisconnect", function (ply)

    if (VoidCases.TradeRequests[ply]) then
        timer.Remove("VoidCases.TradeRequest" .. ply:SteamID64())
    end

    local tradeInfo, b, req = VoidCases.GetTradeInfo(ply)
    if (tradeInfo) then
        local otherPlayer = (ply == req and VoidCases.Trades[ply]) or req

        VoidLib.Notify(otherPlayer, L"trading_end", L"trading_playerdisconnect", Color(206, 83, 83), 5) 

        VoidCases.EndTrade(req)
    end
end)
