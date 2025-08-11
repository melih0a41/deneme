
local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale

// Inventory

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)

    self.panelTitle = self:SetTitle(L"inventory")

    local searchCard = self:Add("VoidUI.BackgroundPanel")
    searchCard:Dock(TOP)
    searchCard:SSetTall(50)
    searchCard:MarginTop(5)
    searchCard:MarginSides(45)
    searchCard:DockPadding(30,8,10,8)

    self.searchCard = searchCard

    local searchInput = searchCard:Add("VoidUI.Search")
    searchInput:Dock(LEFT)
    searchInput:SSetWide(260)

    searchInput.OnSearch = function (s, str)
        self.refreshItems(str)
    end

    local sortContainer = searchCard:Add("Panel")
    sortContainer:Dock(RIGHT)
    sortContainer:SSetWide(340)
    sortContainer:MarginRight(30)

    self.sortContainer = sortContainer
    
    local rarityFilter = sortContainer:Add("VoidUI.Dropdown")
    rarityFilter:Dock(RIGHT)
    rarityFilter:SSetWide(160)
    rarityFilter:SetText("Rarity Filter")
    rarityFilter.color = VoidUI.Colors.BackgroundTransparent
    rarityFilter:SetFont("VoidUI.R24")

    rarityFilter:AddChoice(L"none")
    for rarityName, id in SortedPairsByValue(VoidCases.Rarities) do
        rarityFilter:AddChoice(rarityName)
    end

    rarityFilter.OnSelect = function (s, i, val)
        self.refreshItems(searchInput:GetValue())
    end

    local itemFilter = sortContainer:Add("VoidUI.Dropdown")
    itemFilter:Dock(LEFT)
    itemFilter:SSetWide(160)
    itemFilter:SetText("Item Filter")
    itemFilter.color = VoidUI.Colors.BackgroundTransparent
    itemFilter:SetFont("VoidUI.R24")
    
    itemFilter:AddChoice(L"none")
    itemFilter:AddChoice(L"cases")
    itemFilter:AddChoice(L"keys")
    itemFilter:AddChoice(L"weapons")
    itemFilter:AddChoice(L"skins")
    itemFilter:AddChoice(L"money")
    itemFilter:AddChoice(L"other")

    itemFilter.OnSelect = function (s, i, val)
        self.refreshItems(searchInput:GetValue())
    end

    local itemContainer = self:Add("VoidUI.BackgroundPanel")
    itemContainer:Dock(FILL)
    itemContainer:SDockMargin(45, 15, 45, 30)

    local itemWrapper = itemContainer:Add("VoidUI.Grid")
    itemWrapper:Dock(FILL)
    itemWrapper:DockMargin(0, 0, 0, 0)

    itemWrapper:InvalidateParent(true)

    itemWrapper:SetColumns(5)
    itemWrapper:SetHorizontalMargin(ScrW() * 0.0078)
    itemWrapper:SetVerticalMargin(20)

    self.refreshItems = function(str)

        itemWrapper:Clear()
    
        local itemAmount = 0
        for id, amount in pairs(self.invTbl or VoidCases.Inventory) do
            local item = VoidCases.Config.Items[tonumber(id)]
            if (!VoidCases.IsItemValid(item)) then continue end

            if (tonumber(amount) < 1) then continue end

            itemAmount = itemAmount + 1
        end

        
        
        local isAdmin = self.invTbl and true or false

        for id, amount in pairs(self.invTbl or VoidCases.Inventory) do
            if (!tonumber(amount) or tonumber(amount) < 1) then continue end

            local item = VoidCases.Config.Items[tonumber(id)]
            if (!VoidCases.IsItemValid(item)) then continue end

            local rarityName = nil
            for k, v in pairs(VoidCases.Rarities) do
                if (v == tonumber(item.info.rarity)) then
                    rarityName = k
                end
            end

            if (str and (!item.name:lower():find(str:lower(), 1, true) and !rarityName:lower():find(str:lower(), 1, false)) ) then continue end
            if ((rarityFilter:GetSelected() and rarityFilter:GetSelected() != "" and rarityFilter:GetSelected() != L"none") and rarityFilter:GetSelected() != rarityName) then continue end
            
            if (itemFilter:GetSelected() and itemFilter:GetSelected() != "" and itemFilter:GetSelected() != L"none") then
                local currFilter = itemFilter:GetSelected()

                if (currFilter == L"weapons" and item.info.actionType != "weapon") then continue end
                if (currFilter == L"cases" and item.type != VoidCases.ItemTypes.Case) then continue end
                if (currFilter == L"keys" and item.type != VoidCases.ItemTypes.Key) then continue end
                if (currFilter == L"skins" and item.info.actionType != "weapon_skin") then continue end
                if (currFilter == L"money" and item.info.actionType != "money") then continue end

                if (currFilter == L"other" and (!item.info.actionType or (!item.info.actionType:find("pointshop") and item.info.actionType != "concommand"))) then continue end
            end

            local itemPanel = vgui.Create("VoidCases.Item")
            itemPanel:SSetTall(230)
            itemPanel:SSetWide(230)
            itemPanel.isList = true

            local hasKey = true
            if (item.info.requiresKey) then
                hasKey = false
                for k, v in pairs(VoidCases.Inventory) do
                    if (tonumber(v) < 1) then continue end
                    local item = VoidCases.Config.Items[k]
                    if (!item) then continue end
                    if (item.type != VoidCases.ItemTypes.Key) then continue end

                    if (item.info.unlocks[id]) then
                        hasKey = true
                    end
                end
            end

            local transparentCol = Color(0,0,0,170)
            local stripeCol = Color(0,0,0,210)

            itemPanel.Paint = function (self, w, h)
                local x, y = self:LocalToScreen(0, 0)
            
                if (self:IsHovered() or itemPanel.itemOverlay:IsHovered() or (itemPanel.b and itemPanel.b:IsHovered())) then
                    BSHADOWS.BeginShadow()
                        draw.RoundedBox(8, x, y, w, h, VoidCases.RarityColors[tonumber(self.item.info.rarity)])
                    BSHADOWS.EndShadow(3, 2, 2, 200, 1, 1)
                else
                    draw.RoundedBox(8, 0, 0, w, h, VoidCases.RarityColors[tonumber(self.item.info.rarity)])
                end
            
                surface.SetDrawColor(255,255,255)
                surface.SetMaterial(tonumber(self.item.info.rarity) != 1 && VoidCases.Icons.LayerItem || VoidCases.Icons.LayerItemNormal)
                surface.DrawTexturedRect(0,10,w,h-20)
            end

            itemPanel.itemOverlay.Paint = function (self, w, h)
                local x, y = self:LocalToScreen(0,0)

                self.item = self:GetParent().item

                if (!self.item) then return end

                local rarityNum = tonumber(self.item.info.rarity)
                local rarityColor = VoidCases.RarityColors[rarityNum]

                draw.RoundedBoxEx(8, 0, 0, w, w*0.14, rarityColor, true, true, false, false)
                draw.RoundedBoxEx(0, 0, h-sc(50), w, sc(40), stripeCol, false, false, true, true)

                -- Count start

                local strAmount = tostring(amount)

                surface.SetFont("VoidUI.B20")
                local amountWidth = surface.GetTextSize(strAmount) + 25
                local amountHeight = 24
                local amountX = w-amountWidth-sc(5)
                local amountY = w*0.14+sc(5)

                draw.RoundedBox(8, amountX, amountY, amountWidth, amountHeight, VoidUI.Colors.GrayOverlay)
                draw.SimpleText(strAmount .. "x", "VoidUI.B20", w-amountWidth-sc(5)+amountWidth/2, w*0.14+sc(5)+amountHeight/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Count end

                -- Key icon start

                if (self.item.type == VoidCases.ItemTypes.Case) then
                    local caseWidth = sc(45)
                    local keyWidth = caseWidth * 0.6

                    draw.RoundedBox(8, amountX-sc(5)-caseWidth, amountY, caseWidth, amountHeight, VoidUI.Colors.GrayOverlay)

                    local addY = (self.item.info.requiresKey and 3) or 0

                    surface.SetMaterial( (self.item.info.requiresKey and VoidCases.Icons.Key) or VoidCases.Icons.NoKey )
                    surface.SetDrawColor(VoidUI.Colors.White)
                    surface.DrawTexturedRect(amountX-sc(5)-caseWidth/2-keyWidth/2, amountY + addY + sc(5), keyWidth, (self.item.info.requiresKey and ScrH() * 0.01018) or ScrH() * 0.01296)
                end

                -- Key icon end

                -- Status start

                local statusText = ""
                local statusColor = VoidUI.Colors.Red
                local statusX = sc(5)

                -- Status set

                if (self.item.type == VoidCases.ItemTypes.Case and self.item.info.requiresKey and !hasKey) then
                    statusText = "NO KEY"
                    statusColor = VoidUI.Colors.Red
                end

                local statusWidth = surface.GetTextSize(statusText) + 5

                if (isAdmin) then
                    statusText = ""
                    statusWidth = 0
                end

                if (self.item.type == VoidCases.ItemTypes.Unboxable) then
                    if (self.item.info.actionType == "weapon" and self.item.info.isPermanent) then
                        if (VoidCases.Equipped[tonumber(id)]) then
                            statusText = "EQUIPPED"
                            statusColor = VoidUI.Colors.Green
                        else
                            statusText = "UNEQUIPPED"
                            statusColor = VoidUI.Colors.Red
                        end

                        statusWidth = surface.GetTextSize(statusText) - 5
                        if (isAdmin) then
                            statusText = ""
                            statusWidth = 0
                        end

                        local permaWidth = sc(60)
                        draw.RoundedBox(8, statusX+statusWidth+sc(5), amountY, permaWidth, amountHeight, VoidUI.Colors.GrayOverlay)
                        draw.SimpleText("PERMA", "VoidUI.R16", statusX+permaWidth/2+statusWidth+sc(5), amountY+amountHeight/2-1, VoidUI.Colors.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end

                if (statusText and statusText != "") then
                    draw.RoundedBox(8, statusX, amountY, statusWidth, amountHeight, VoidUI.Colors.GrayOverlay)
                    draw.SimpleText(statusText, "VoidUI.R16", statusX+statusWidth/2, amountY+amountHeight/2-1, statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                -- Status end

                -- Rarity start

                draw.SimpleText(L"rarity", "VoidUI.R16", sc(20), h-sc(30), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                surface.SetFont("VoidUI.R20")
                local rarityText = rarityName
                local rarityStart = w-sc(20)
                local rarityWidth = surface.GetTextSize(rarityText) + 30
                local rarityBoxX = rarityStart - rarityWidth
                local rarityBoxHeight = sc(30)

                draw.RoundedBox(14, rarityBoxX, h-sc(30)-rarityBoxHeight/2, rarityWidth, rarityBoxHeight, transparentCol)
                draw.SimpleText(rarityText, "VoidUI.R20", rarityBoxX + rarityWidth/2, h-sc(30), rarityColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Rarity end

                local itemNameFont = "VoidUI.R24"
                if (#self.item.name > 19) then
                    itemNameFont = "VoidUI.R18"
                end

                draw.SimpleText(self.item.name, itemNameFont, w/2, w*0.14/2-2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
            end


            itemPanel:SetItem(item)
            itemWrapper:AddCell(itemPanel, nil, sc(230))

            local itemPanelB = itemPanel:Add("DButton")
            itemPanelB:Dock(FILL)
            itemPanelB:SetText("")
            itemPanelB.Paint = function (self, w, h) end
            itemPanelB:SetZPos(30)

            itemPanel.b = itemPanelB

            local function delOnePopup(askMuch)
                local popup = vgui.Create(askMuch and "VoidUI.ValuePopup" or "VoidUI.Popup")
                popup:SetText(L"delete_confirm", L(askMuch and "delete_confirm_ask" or "delete_confirm_text", item.name))
                popup:SetDanger()

                if (askMuch) then
                    popup:SetNumeric()
                end

                popup:Continue(L"delete", function (val)
                    if (askMuch and val == nil) then return end

                    local num = askMuch and tonumber(val) or 1
                    net.Start("VoidCases_DeleteInventoryItem")
                        net.WriteUInt(item.id, 32)
                        net.WriteUInt(num, 32)
                        net.WriteBool(isAdmin)
                        if (isAdmin) then
                            net.WriteString(self.sidPlayer)
                        end
                    net.SendToServer()

                    if (isAdmin) then
                        self.invTbl[id] = self.invTbl[id] - num
                        self.refreshItems()
                    end
                end)
                popup:Cancel(L"cancel")
            end

            local function useAllPopup()
                local popup = vgui.Create("VoidUI.Popup")
                popup:SetText(L"equip_all", L("equip_all_confirm", item.name))

                popup:Continue(L"yes", function (val)
                    net.Start("VoidCases_EquipItem")
                        net.WriteUInt(id, 32)
                        net.WriteUInt(amount, 32)
                    net.SendToServer()
                end)
                popup:Cancel(L"cancel")
            end

            local function useMultiplePopup()
                local popup = vgui.Create("VoidUI.ValuePopup")
                popup:SetText(L"equip_multiple", L("equip_multiple_confirm", { item = item.name }))
                popup:SetNumeric()

                popup:Continue(L"yes", function (val)
                    net.Start("VoidCases_EquipItem")
                        net.WriteUInt(id, 32)
                        net.WriteUInt(tonumber(val), 32)
                    net.SendToServer()
                end)
                popup:Cancel(L"cancel")
            end

            local origPress = itemPanelB.OnMousePressed
            itemPanelB.OnMousePressed = function (s, keycode)
                origPress(s, keycode)
                if (keycode == MOUSE_RIGHT) then
                    -- open context menu
                    local ctxMenu = VoidUI:CreateDropdownPopup()

                    if (item.type == VoidCases.ItemTypes.Unboxable) then
                        local useMultiple = ctxMenu:AddOption(L"equip_multiple", function ()
                            useMultiplePopup()
                        end)

                        local useAll = ctxMenu:AddOption(L"equip_all", function ()
                            useAllPopup()
                        end)
                    end

                    local deleteOption = ctxMenu:AddOption(L"delete_lower", function ()
                        delOnePopup(amount != 1)
                    end)

                    ctxMenu.y = ctxMenu.y - 15
                    ctxMenu.x = ctxMenu.x + 10

                end
            end

            if (!isAdmin) then
                if (!hasKey) then
                    itemPanelB:SetCursor("no")
                    itemPanelB:SetEnabled(false)
                end

                if (DarkRP and LocalPlayer():isArrested()) then
                    itemPanelB:SetCursor("no")
                    itemPanelB:SetEnabled(false)
                end
            end

            itemPanelB.DoClick = function ()

                if (isAdmin) then
                    local ctxMenu = VoidUI:CreateDropdownPopup()

                    local deleteOption = ctxMenu:AddOption(L"delete_lower", function ()
                        delOnePopup(amount != 1)
                    end)
                    -- deleteOption:SetIcon("icon16/delete.png")

                    -- ctxMenu:Open()
                    ctxMenu.y = ctxMenu.y - 15
                    ctxMenu.x = ctxMenu.x + 10

                    return
                end

                if (item.type == VoidCases.ItemTypes.Unboxable and item.info.isPermanent) then
                    net.Start("VoidCases_EquipPerma")
                        net.WriteUInt(id, 32)
                    net.SendToServer()
                    return
                end

                if (item.type == VoidCases.ItemTypes.Case) then

                    local csgoPanelSizeX, csgoPanelSizeY = 1000, 700

                    if (!item.info.forceUnboxing) then
                        -- Ask for unbox type
                        local unboxMenu = VoidUI:CreateDropdownPopup()
                        unboxMenu:AddOption("Unbox in World", function ()
                            if (!IsValid(self)) then return end

                            VoidCases.StartCasePlace(id, item)
                            self:GetParent():Remove()
                        end)
                        unboxMenu:AddOption("Unbox in CS:GO Unboxing", function ()

                            if (!IsValid(self)) then return end

                            local panel = vgui.Create("VoidCases.2DUnboxing")
                            panel:SSetSize(csgoPanelSizeX, csgoPanelSizeY)
                            panel:MakePopup()
                            panel:Center()

                            if (!IsValid(panel)) then return end

                            panel:InitUnbox(item, tonumber(id), self:GetParent())
                        end)

                        -- unboxMenu:Open()
                    end
                    
                    if (item.info.forceUnboxing == "world") then
                        VoidCases.StartCasePlace(id, item)
                        self:GetParent():Remove()
                    end

                    if (item.info.forceUnboxing == "csgo") then
                        local panel = vgui.Create("VoidCases.2DUnboxing")
                        panel:SSetSize(csgoPanelSizeX, csgoPanelSizeY)
                        panel:MakePopup()
                        panel:Center()

                        panel:InitUnbox(item, tonumber(id), self:GetParent())
                    end
                end

                if (item.type == VoidCases.ItemTypes.Unboxable) then
                    net.Start("VoidCases_EquipItem")
                        net.WriteUInt(id, 32)
                        net.WriteUInt(1, 32)
                    net.SendToServer()
                end
            end
    end
    

    if (table.Count(VoidCases.Inventory) < 1) then
        itemWrapper.Paint = function (self, w, h)
            draw.SimpleText(L"no_items", "VoidUI.B50", w/2, h/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end 

    end

    self.refreshItems()


end

function PANEL:ViewAsPlayer(sid, inv)
    self.invTbl = inv
    self.sidPlayer = sid

    self.panelTitle:Remove()
    self.refreshItems()

    local panelTitle = VoidCases.Menu.settings.invs.panelTitle

    local backButton = panelTitle:Add("DButton")
	backButton:Dock(LEFT)
	backButton:SetText("")
    backButton:MarginLeft(10)
	backButton.Paint = function (self, w, h)
		local color = self:IsHovered() and VoidUI.Colors.Orange or VoidUI.Colors.Gray
		draw.SimpleText("<  " .. string.upper(L"back"), "VoidUI.R20", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	backButton.DoClick = function ()
		self:SetVisible(false)
        self:GetParent().selectionPanel:SetVisible(true)
        VoidCases.Menu.settings.invs:SetTitle(L"inventories")

        self.backButton:Remove()
        self.addButton:Remove()
	end

	self.backButton = backButton

    local addButton = self.searchCard:Add("VoidUI.Button")
    addButton:Dock(RIGHT)
    addButton:SSetWide(150)
    addButton:SetMedium()
    addButton:MarginRight(20)
    addButton:SetText("+ " .. L"add_item")
    addButton:SetZPos(-200)

    addButton.DoClick = function ()
        -- item selector
        local selector = vgui.Create("VoidUI.ItemSelect")
        selector:SetParent(self)

        local itemTbl = {}
        for id, item in pairs(VoidCases.Config.Items) do
            if (!VoidCases.IsItemValid(item)) then continue end

            itemTbl[id] = item.name
        end

        selector:InitItems(itemTbl, function (id, v)
            -- network
            if (!self.invTbl[id]) then
                self.invTbl[id] = 1
            else
                self.invTbl[id] = self.invTbl[id] + 1
            end

            net.Start("VoidCases_AddAdminItem")
                net.WriteString(sid)
                net.WriteUInt(id, 32)
            net.SendToServer()

            self.refreshItems()
        end)
    end

    self.addButton = addButton
end

vgui.Register("VoidCases.Inventory", PANEL, "VoidUI.PanelContent")
