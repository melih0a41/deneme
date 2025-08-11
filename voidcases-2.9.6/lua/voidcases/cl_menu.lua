
VoidCases.Menu = VoidCases.Menu or nil
VoidCases.CurrentNotification = nil

VoidCases.TradeInvites = {}

local L = VoidCases.Lang.GetPhrase

concommand.Add("voidcases", function ()
    VoidCases.OpenMenu()
end)

function VoidCases.OpenMenu()

    if (IsValid(VoidCases.Menu)) then return end
    if (IsValid(VoidCases.CaseEntity)) then
        VoidCases.DeleteCrateBP()
    end

    VoidCases.Menu = vgui.Create("VoidCases.MainPanel")
    VoidCases.Menu:MakePopup()
end

net.Receive("VoidCases.TradeEnd", function ()
    if (IsValid(VoidCases.Menu) and VoidCases.Menu.trading.plyReq) then
        VoidCases.Menu:Remove()
    end
end)

net.Receive("VoidCases.AnnounceItemUnlock", function (len, ply)
    local nick = net.ReadString()
    local item = net.ReadString()
    local color = net.ReadColor()

    local msg = string.format(L"annouce_win", nick, item)

    chat.AddText(VoidUI.Colors.LightGray, "[", VoidCases.AccentColor, "VoidCases", VoidUI.Colors.LightGray, "] ", color, msg)
end)

net.Receive("VoidCases.SyncTrade", function ()
    if (!IsValid(VoidCases.Menu) or !VoidCases.Menu.trading.plyReq) then
        return
    end

    local tradeObj = net.ReadTable()

    local ply = LocalPlayer()

    local partnerItems = ply == VoidCases.Menu.trading.plyReq and tradeObj.receiverItems or tradeObj.requesterItems
    local partnerMoney = ply == VoidCases.Menu.trading.plyReq and tradeObj.receiverMoney or tradeObj.requesterMoney
    local partnerCurrency = ply== VoidCases.Menu.trading.plyReq and tradeObj.receiverCurrency or tradeObj.requesterCurrency

    VoidCases.Menu.trading.refreshReceive(partnerItems, partnerMoney, partnerCurrency)

end)

net.Receive("VoidCases.TradeSendReady", function ()
    if (!IsValid(VoidCases.Menu) or !VoidCases.Menu.trading.plyReq) then
        return
    end

    local isReady = net.ReadBool()
    VoidCases.Menu.trading.setPartnerReady(isReady)
end)

net.Receive("VoidCases_NetworkAdminInventory", function ()
    if (!IsValid(VoidCases.Menu)) then return end

    local inv = net.ReadTable()
    local sid = net.ReadString()

    local invPanel = VoidCases.Menu.settings.invs

    invPanel.panelTitle = invPanel:SetTitle(L("viewing_inventory", {
        name = "Loading..",
    }))

    steamworks.RequestPlayerInfo(sid, function (name)
        invPanel.panelTitle = invPanel:SetTitle(L("viewing_inventory", {
            name = name,
        }))
    end)

    invPanel.selectionPanel:SetVisible(false)
    invPanel.inventoryPanel:SetVisible(true)
    invPanel.inventoryPanel:ViewAsPlayer(sid, inv)
end)

net.Receive("VoidCases.StartTrade", function ()
    if (!IsValid(VoidCases.Menu)) then
        VoidCases.OpenMenu()
    end

    local plyReq = net.ReadEntity()

    VoidCases.Menu.trading:Remove()
    VoidCases.Menu.trading = VoidCases.Menu:Add("VoidCases.TradingPanel")

    if (VoidCases.Menu.sidebar.selectedPanel) then
        VoidCases.Menu.sidebar.selectedPanel:SetVisible(false)
    end

    VoidCases.Menu.trading:SetVisible(true)
    VoidCases.Menu.tradingButton:Remove() 
    VoidCases.Menu.trading.plyReq = plyReq

    VoidCases.Menu.tradingButton = VoidCases.Menu.sidebar:AddTab("TRADING", VoidCases.Icons.Trade, VoidCases.Menu.trading)
    VoidCases.Menu.sidebar.selectedPanel = VoidCases.Menu.trading
    VoidCases.Menu.sidebar.selectedBtn = VoidCases.Menu.tradingButton

    // Disable inventory, and marketplace
    VoidCases.Menu.invButton:SetCursor("no")
    VoidCases.Menu.invButton:SetEnabled(false)

    VoidCases.Menu.market.sellItem:SetCursor("no")
    VoidCases.Menu.market.sellItem:SetEnabled(false)

    function VoidCases.Menu:OnRemove()
        net.Start("VoidCases.LeaveTrade")
        net.SendToServer()
    end
    
end)

function VoidCases.CreateTradeInvite(ply)

    local tradeInvite = vgui.Create("VoidCases.TradeInvite")
    tradeInvite:SetSize(280,110)
    
    tradeInvite:SetPos(20, 20)

    tradeInvite:SetWorldClicker(true)

    tradeInvite:CreateInvite(ply)

    table.insert(VoidCases.TradeInvites, tradeInvite)
end

net.Receive("VoidCases.ReceiveTradeRequest", function ()
    local ply = net.ReadEntity()
    local b = net.ReadBool()

    if (b) then
        for k, panel in pairs(VoidCases.TradeInvites) do
            if (IsValid(panel) and panel.ply == ply or !IsValid(panel.ply)) then
                panel:Remove()
            end
        end
    else
        if (!IsValid(ply)) then return end
        VoidCases.CreateTradeInvite(ply)
    end
end)

local function handleContextOpen()
    for k, parentPanel in pairs(VoidCases.TradeInvites) do
        if (IsValid(parentPanel)) then
            timer.Simple(0, function ()
                if (IsValid(g_ContextMenu)) then
                    parentPanel:SetParent(g_ContextMenu)
                end
            end)
        end
    end
end

local function handleContextClose()
    for k, parentPanel in pairs(VoidCases.TradeInvites) do
        if (IsValid(parentPanel)) then
            parentPanel:SetParent(NULL)
        end
    end
end

hook.Add("OnContextMenuOpen", "VoidCases.ContextMenuOpen", function ()
    handleContextOpen()
end)

hook.Add("OnContextMenuClose", "VoidCases.ContextMenuClose", function ()
    handleContextClose()
end)

hook.Add("VoidCases_ConfigDataReceived", "VoidCases.RefreshMenuData", function ()
    if (!IsValid(VoidCases.Menu)) then return end

    VoidCases.Menu.refreshItems()
end)


hook.Add("PlayerButtonDown", "VoidCases.KeyBind", function (ply, key)
	if (IsValid(VoidCases.Menu)) then return end

	local keyStr = VoidCases.Config.MenuBind
	local _key = keyStr and input.GetKeyCode(keyStr) or nil
	if (keyStr and key == _key) then
		LocalPlayer():ConCommand("voidcases")
	end 
end)

hook.Add("HUDPaint", "VoidCases.NotifyMarketpalceSold", function ()
    local ply = LocalPlayer()

    if (!IsValid(ply)) then return end
    local soldItems = ply:GetNWInt("VoidCases.SoldWhileOffline")

    if (!soldItems or soldItems == 0) then return end
    if (!VoidCases.Config.Language) then return end

    VoidLib.Notify(L"marketplace", L("sold_offline", soldItems), VoidUI.Colors.Green, 20)
    hook.Remove("HUDPaint", "VoidCases.NotifyMarketpalceSold")
end)