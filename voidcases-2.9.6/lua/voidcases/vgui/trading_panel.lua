local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale

local function paintItemSmall(itemPanel, item, bLower)
    itemPanel.itemOverlay.Paint = function (self, w, h)
        local x, y = self:LocalToScreen(0,0)
        local panelW, panelH = ScrW() * 0.842, ScrH() * 0.834

        if ( !bLower and (y > math.ceil(ScrH() * 0.18518) and y < math.ceil(ScrH() * 0.3796)) or (y > math.ceil(ScrH() * 0.509) and y < math.ceil(ScrH() * 0.68)) ) then
            BSHADOWS.BeginShadow()
                    draw.RoundedBoxEx(6, x, y+w-w*0.18, w, w*0.18, VoidCases.RarityColors[tonumber(item.info.rarity)], false, false, true, true)
            BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)
        else
            draw.RoundedBoxEx(6, x, y+w-w*0.18, w, w*0.18, VoidCases.RarityColors[tonumber(item.info.rarity)], false, false, true, true)
        end


        local nameFont = "VoidUI.R18"
        if (#item.name > 13) then
            nameFont = "VoidUI.R14"
        end

        local itemName = item.name
        draw.SimpleText(itemName, nameFont, w/2, w - w*0.18/2-2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    itemPanel.Paint = function (self, w, h)

        local x, y = self:LocalToScreen(0,0)


        if ( !bLower and (y > math.ceil(ScrH() * 0.2685) and y < math.ceil(ScrH() * 0.3768)) or (y > math.ceil(ScrH() * 0.6527) and y < math.ceil(ScrH() * 0.6787)) ) then
            BSHADOWS.BeginShadow()
                draw.RoundedBox(6, x, y, w, h, VoidCases.RarityColors[tonumber(item.info.rarity)])
            BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)
        else
            draw.RoundedBox(6, 0, 0, w, h, VoidCases.RarityColors[tonumber(item.info.rarity)])
        end

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(tonumber(item.info.rarity) != 1 && VoidCases.Icons.LayerItem || VoidCases.Icons.LayerItemNormal)
        surface.DrawTexturedRect(4,4,w-8,h-8)
        
    end
end

local function drawCircleAmount(itemBack, amount)
    local circOffset = ScrW() * 0.013

    local x, y = itemBack:LocalToScreen(0, 0)
    local amountCircle = draw.drawCircle(x + circOffset, y + circOffset, ScrW() * 0.01, 5, true)
    if (amount != 1) then
        itemBack.PaintOver = function (self, w, h)
            draw.NoTexture()
            surface.SetDrawColor(VoidUI.Colors.Gray)
            surface.DrawPoly(amountCircle)

            local fontSize = (#tostring(amount) > 2 and "VoidUI.B20") or "VoidUI.B22"
            
            draw.SimpleText(amount .. "x", fontSize, ScrW() * 0.013*2/2-1, ScrW() * 0.013*2/2-2, VoidUI.Colors.Black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

local fakeMoneyItemTable = {
    name = "Money (currency)",
    info = {
        rarity = 2,
        type = VoidCases.ItemTypes.Unboxable,
    }
}

local function addItem(item, amount, ignore)
    if (!VoidCases.IsItemValid(item) and !ignore) then return end

    local itemPanel = vgui.Create("VoidCases.Item")
    itemPanel:SSetTall(132)
    itemPanel:SSetWide(132)

    itemPanel:SetItem(item)
    itemPanel.isShowcase = true
    itemPanel.showMoney = false
    itemPanel.isTrading = true
    itemPanel.amount = amount

    if (ignore) then
        itemPanel.isShowcase = false
    end

    local itemPanelB = itemPanel:Add("DButton")
    itemPanelB:Dock(FILL)
    itemPanelB:SetText("")
    itemPanelB.Paint = function (self, w, h) end
    itemPanelB:SetZPos(30)

    itemPanel.b = itemPanelB

    return itemPanel
end

local tradeChat = {}
local tradePanel = nil

net.Receive("VoidCases.TradeChatSync", function ()
    if (IsValid(tradePanel)) then
        local msg = net.ReadString()

        tradeChat[#tradeChat + 1] = {"partner", msg}
        tradePanel.addChatMsg({"partner", msg})
    end
end)

// Trading panel

local PANEL = {}

function PANEL:Init()
    local titlePanel = self:SetTitle(L("trading"):upper())

    tradePanel = self
    tradeChat = {}
    
    local chatButton = titlePanel:Add("VoidUI.Button")
    chatButton:Dock(RIGHT)
    chatButton:SSetWide(150)
    chatButton:SetSmallerMedium()
    chatButton:SetText(L"trade_chat")
    chatButton:SDockMargin(10,5,10,5)
    chatButton:SetColor(VoidUI.Colors.Blue)

    local function colVA(col)
        return col.r, col.g, col.b, col.a
    end

    self.addChatMsg = function (v)
        if (!self.textChat) then return end
        if (v[1] == "you") then
            self.textChat:InsertColorChange(colVA(VoidUI.Colors.Green))
            self.textChat:AppendText(L("trading_you"):upper() .. ": ")
        else
            self.textChat:InsertColorChange(colVA(VoidUI.Colors.Orange))
            self.textChat:AppendText(L("trading_partner"):upper() .. ": ")
        end

        self.textChat:InsertColorChange(colVA(VoidUI.Colors.Gray))
        self.textChat:AppendText(v[2] .. "\n")
    end

    chatButton.DoClick = function ()

        local origX = VoidCases.Menu.x

        local chatPanel = vgui.Create("VoidUI.Frame")
        chatPanel:SSetSize(370, 550)
        chatPanel:Center()
        chatPanel:SetTitle(L"trade_chat")

        chatPanel:SetParent(self)
    
        chatPanel:MakePopup()
        chatPanel.x = ScrW() - sc(410)
        
        chatPanel.OnRemove = function ()
            VoidCases.Menu.x = origX
        end

        VoidCases.Menu.x = VoidCases.Menu.x - 200

        local container = chatPanel:Add("Panel")
        container:Dock(FILL)
        container:SDockMargin(10,10,10,10)

        local chatContent = container:Add("VoidUI.BackgroundPanel")
        chatContent:Dock(FILL)

        local text = chatContent:Add("RichText")
        text:Dock(FILL)

        for k, v in ipairs(tradeChat) do
            self.addChatMsg(v)
        end

        function text:PerformLayout()
            self:SetFontInternal("VoidUI.R24")
        end

        local inputText = container:Add("VoidUI.TextInput")
        inputText:Dock(BOTTOM)
        inputText:SSetTall(60)
        inputText:MarginTop(10)

        function inputText.entry:OnEnter()
            text:InsertColorChange(colVA(VoidUI.Colors.Green))
            text:AppendText(L("trading_you"):upper() .. ": ")

            text:InsertColorChange(colVA(VoidUI.Colors.Gray))
            text:AppendText(inputText:GetValue() .. "\n")

            tradeChat[#tradeChat + 1] = {"you", inputText:GetValue()}

            net.Start("VoidCases.TradeChat")
                net.WriteString(inputText:GetValue())
            net.SendToServer()

            inputText.entry:SetText("")

            inputText.entry:RequestFocus()
        end

        self.textChat = text
    end

    self.tradeObj = {
        items = {},
        money = 0,
        isReady = false,
        currency = nil
    }
    
    self.inv = table.Copy(VoidCases.Inventory)
    local refSend, refInv

    self.partnerReady = false

    local container = self:Add("Panel")
    container:Dock(FILL)
    container:MarginSides(45)
    container:MarginTops(5)

    local invWrapper = container:Add("VoidUI.BackgroundPanel")
    invWrapper:Dock(FILL)
    invWrapper:SSetTall(400)
    invWrapper:SetTitle(L("inventory"):upper())
    invWrapper:MarginTop(0)

    local itemWrapper = invWrapper:Add("VoidUI.Grid")
    itemWrapper:Dock(FILL)
    itemWrapper:MarginTop(30)

    itemWrapper:InvalidateLayout(true)
    itemWrapper:InvalidateParent(true)

    itemWrapper:SetColumns(8)
    itemWrapper:SetHorizontalMargin(sc(15))
    itemWrapper:SetVerticalMargin(sc(15))

    self.refreshInventory = function ()

        itemWrapper:Clear()

        for id, amount in pairs(self.inv) do
            if (!tonumber(amount) or tonumber(amount) < 1) then continue end

            local item = VoidCases.Config.Items[tonumber(id)]
            if (!VoidCases.IsItemValid(item)) then continue end
            if (item.info.marketplaceBlacklist) then continue end

            local itemPanel = addItem(item, amount)

            itemPanel.b.DoClick = function ()
                if (self.tradeObj.items[id]) then
                    self.tradeObj.items[id] = self.tradeObj.items[id] + 1
                else
                    self.tradeObj.items[id] = 1
                end

                self.inv[id] = self.inv[id] - 1
                refInv()
                refSend()
            end

            itemWrapper:AddCell(itemPanel, sc(132))
        end
    end

    refInv = self.refreshInventory
    refInv()

    local statusContainer = container:Add("VoidUI.BackgroundPanel")
    statusContainer:Dock(BOTTOM)
    statusContainer:SSetTall(60)
    statusContainer:MarginBottom(15)
    statusContainer:SDockPadding(8,8,8,8)

    local confirmTrade = statusContainer:Add("VoidUI.Button")
    confirmTrade:Dock(LEFT)
    confirmTrade:SSetWide(160)
    confirmTrade:SetText(L"confirm_trade")
    confirmTrade:SetSmallerMedium()
    confirmTrade.rounding = 20
    confirmTrade.selectStr = L("unconfirm_trade"):upper()

    local statusButton = statusContainer:Add("VoidUI.Button")
    statusButton:Dock(LEFT)
    statusButton:MarginLeft(340)
    statusButton:SSetWide(190)
    statusButton:SetSmallerMedium()
    statusButton.rounding = 20
    statusButton:SetEnabled(false)
    statusButton.isSelected = true
    statusButton.enableShow = true

    statusButton.font = "VoidUI.R16"
    statusButton.selectStr = L("waiting_for_both"):upper()

    local function refreshReady()
        confirmTrade:SetText(self.tradeObj.isReady and L"unconfirm_trade" or L"confirm_trade")
        confirmTrade.isSelected = self.tradeObj.isReady
        statusButton.selectStr = self.tradeObj.isReady and L("waiting_for_partner"):upper() or L("waiting_for_both"):upper()

        if (self.partnerReady and !self.tradeObj.isReady) then
            statusButton.selectStr = L("partner_ready"):upper()
        end
    end

    self.setPartnerReady = function (b)
        self.partnerReady = b
        refreshReady()
    end

    confirmTrade.DoClick = function ()
        self.tradeObj.isReady = !self.tradeObj.isReady
        refreshReady()

        net.Start("VoidCases.TradeReady")
        net.SendToServer()
    end

    local tradeFinished = statusContainer:Add("VoidUI.Button")
    tradeFinished:Dock(RIGHT)
    tradeFinished:SSetWide(190)
    tradeFinished:SetSmallerMedium()
    tradeFinished.rounding = 20
    tradeFinished:SetEnabled(false)
    
    tradeFinished.font = "VoidUI.R20"
    tradeFinished:SetText(L("trade_complete"):upper())

    statusContainer.Paint = function (self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, VoidUI.Colors.Primary)

        surface.SetDrawColor(VoidUI.Colors.BackgroundTransparent)
        surface.DrawRect(sc(160), h / 2-1, sc(360), 2)

        local progressPercent = confirmTrade.isSelected and 1 or 0
        surface.SetDrawColor(VoidUI.Colors.Green)
        surface.DrawRect(sc(160), h / 2-1, sc(360) * progressPercent, 2)

        surface.SetDrawColor(VoidUI.Colors.BackgroundTransparent)
        surface.DrawRect(sc(160+360+130), h / 2-1, sc(360), 2)
    end

    local bottomWrapper = container:Add("Panel")
    bottomWrapper:Dock(BOTTOM)
    bottomWrapper:SSetTall(250)
    bottomWrapper:MarginTops(15)

    local sendWrapper = bottomWrapper:Add("VoidUI.BackgroundPanel")
    sendWrapper:Dock(LEFT)
    sendWrapper:SetTitle(L("send"):upper())
    sendWrapper:SSetWide(595)
    sendWrapper:SDockPadding(15,10,15,5)


    local sendButtonContainer = sendWrapper:Add("Panel")
    sendButtonContainer:Dock(TOP)
    sendButtonContainer:SSetTall(35)

    local sendMoney = sendButtonContainer:Add("VoidUI.Button")
    sendMoney:Dock(RIGHT)
    sendMoney:SSetWide(130)
    sendMoney:SetMedium()
    sendMoney:SetText("+ " .. L"add_money")
    sendMoney.font = "VoidUI.R20"

    sendMoney.DoClick = function ()
        local frame = vgui.Create("VoidUI.Frame")
        frame:SSetSize(320, 330)
        frame:Center()

        frame:SetParent(self)
    
        frame:MakePopup()
        frame:StayOnTop()

        frame:SetTitle(L"add_money")

        local container = frame:Add("Panel")
        container:Dock(FILL)
        container:SDockMargin(30, 20, 30, 20)

        local grid = container:Add("VoidUI.ElementGrid")
        grid:Dock(FILL)
        grid:SetColumns(1)

        frame.currency = grid:AddElement(L"currency", "VoidUI.Dropdown")
        for k, v in pairs(VoidCases.Currencies) do
            frame.currency:AddChoice(k)
        end

        frame.currency:ChooseOptionID(1)

        frame.amount = grid:AddElement(L"amount", "VoidUI.TextInput")
        frame.amount:SetNumeric(true)

        local addButton = container:Add("VoidUI.Button")
        addButton:Dock(BOTTOM)
        addButton:SSetTall(45)
        addButton:SetText(L"add_money")
        addButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)
        
        addButton.DoClick = function ()

            frame:Remove()

            local currency = VoidCases.Currencies[frame.currency:GetValue()]
            local didSucceed, totalMoney = pcall(currency.getFunc, LocalPlayer())

            local enteredMoney = tonumber(frame.amount:GetValue() or 0) or 0

            if (didSucceed and tonumber(totalMoney) < enteredMoney) then
                VoidLib.Notify(L"error", L"not_enough_money", VoidUI.Colors.Red, 5)
                return
            end

            self.tradeObj.money = enteredMoney
            self.tradeObj.currency = frame.currency:GetValue()

            self.refreshSend()
        end

    end

    local sendItems = sendWrapper:Add("VoidUI.Grid")
    sendItems:Dock(FILL)
    sendItems:MarginTop(15)
    sendItems:InvalidateLayout(true)
    sendItems:InvalidateParent(true)
    sendItems:SetColumns(4)
    sendItems:SetHorizontalMargin(sc(7))
    sendItems:SetVerticalMargin(sc(10))

    self.refreshSend = function (g)
        sendItems:Clear()

        net.Start("VoidCases.UpdateTrade")
            net.WriteUInt(table.Count(self.tradeObj.items), 12)
            for id, amount in pairs(self.tradeObj.items) do
                net.WriteUInt(tonumber(id), 20)
                net.WriteUInt(tonumber(amount), 32)
            end
            net.WriteUInt(self.tradeObj.money, 32)
            net.WriteString(self.tradeObj.currency or "none")
        net.SendToServer()

        for id, amount in pairs(self.tradeObj.items) do
            if (!tonumber(amount) or tonumber(amount) < 1) then continue end
            local item = VoidCases.Config.Items[tonumber(id)]
            if (item.info.marketplaceBlacklist) then continue end

            local itemPanel = addItem(item, amount)
            itemPanel.b.DoClick = function ()
                self.tradeObj.items[id] = self.tradeObj.items[id] - 1
                self.inv[id] = self.inv[id] + 1
                refInv()
                refSend()
            end

            sendItems:AddCell(itemPanel, sc(132))
        end 

        local tradeBool = !DarkRP
        if (self.tradeObj.money > 0 and (tradeBool or LocalPlayer():canAfford(self.tradeObj.money)) ) then
            local item = table.Copy(fakeMoneyItemTable)
            item.name = "Money (" .. VoidCases.FormatMoney(self.tradeObj.money, self.tradeObj.currency) .. ")"

            local itemPanel = addItem(item, 1, self, true)
            itemPanel:SetItemIcon("y2cMWoX", "icon", true)

            sendItems:AddCell(itemPanel)
        end

    end
    
    refSend = self.refreshSend

    local receiveWrapper = bottomWrapper:Add("VoidUI.BackgroundPanel")
    receiveWrapper:Dock(RIGHT)
    receiveWrapper:SetTitle(L("receive"):upper())
    receiveWrapper:SSetWide(595)

    local receiveItems = receiveWrapper:Add("VoidUI.Grid")
    receiveItems:Dock(FILL)
    receiveItems:MarginTop(30)
    receiveItems:InvalidateLayout(true)
    receiveItems:InvalidateParent(true)
    receiveItems:SetColumns(4)
    receiveItems:SetHorizontalMargin(sc(7))
    receiveItems:SetVerticalMargin(sc(10))

    self.refreshReceive = function (items, money, currency)
        if (self.tradeObj.isReady) then
            net.Start("VoidCases.TradeReady")
            net.SendToServer()

            self.tradeObj.isReady = false
            refreshReady()

            VoidLib.Notify(L"trading_itemchanged", L"trading_confirmagain", Color(221, 151, 45), 3)
        end

        receiveItems:Clear()

        for id, amount in pairs(items) do
            if (!tonumber(amount) or tonumber(amount) < 1) then continue end
            local item = VoidCases.Config.Items[tonumber(id)]

            if (!VoidCases.IsItemValid(item)) then continue end
            if (item.info.marketplaceBlacklist) then continue end

            local itemPanel = addItem(item, tonumber(amount))
            receiveItems:AddCell(itemPanel)
        end


        if (money > 0) then
            local item = table.Copy(fakeMoneyItemTable)
            item.name = "Money (" .. VoidCases.FormatMoney(money, currency) .. ")"

            local itemPanel = addItem(item, 1, true)
            itemPanel:SetItemIcon("y2cMWoX", "icon", true)
            receiveItems:AddCell(itemPanel)
        end
    end

end

vgui.Register("VoidCases.TradingPanel", PANEL, "VoidUI.PanelContent")
