local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale

// Edit Items

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)

    self:SetVisible(false)

    self.modelsToHide = {}


	self.itemPanel = self:Add("VoidUI.ScrollPanel")
    self.itemPanel:Dock(FILL)
    self.itemPanel:DockMargin(0, 0, 0, 0)

    self.refreshItems = function ()

    self.itemPanel:Clear()

	local items = table.Copy(VoidCases.Config.Items)
	local categories = table.Copy(VoidCases.Config.Categories)
    local largestIndex = table.maxn(categories)

    categories[largestIndex + 1] = "ADD NEW CATEGORY..."

    local totalCategories = 0
    for k, v in SortedPairs(categories) do
        table.insert(items, {info = {shopCategory = k, newItem = true}}) // loop one more time for each category

        local categoryItems = 0
        for _, item in pairs(items) do
            if (item.info.shopCategory == k) then
                categoryItems = categoryItems + 1
            end
        end

        if (categoryItems == 0) then continue end

        local totalCategoryItems = 0

        local catWrapper = self.itemPanel:Add("VoidCases.EditableCategory")
        catWrapper:Dock(TOP)
        catWrapper:SetTall(sc(230) * math.ceil(categoryItems / 5) + math.Round(ScrH() * 0.074))
        catWrapper:DockMargin(ScrW() * 0.039, 30, 20, 0)

        if (k == largestIndex + 1) then
			// Add new category, set gray (new)
			catWrapper:SetNew(true)
		end

		catWrapper:SetValue(string.upper(v))

        function catWrapper.entry:OnFocusChanged(gained)
            if (!gained) then
                // Modify/create category
                if (catWrapper.isNew) then
                    net.Start("VoidCases_CreateCategory")
                        net.WriteString(catWrapper.entry:GetValue())
                    net.SendToServer()

                    catWrapper:SetNew(false)
                else
                    if (#catWrapper.entry:GetValue() == 0 and categoryItems == 1 and k != table.Count(categories)) then
                        // Delete category
                        net.Start("VoidCases_DeleteCategory")
                            net.WriteUInt(k, 16)
                        net.SendToServer()

                        catWrapper:Remove()
                    else
                        net.Start("VoidCases_ModifyCategory")
                            net.WriteUInt(k, 16)
                            net.WriteString(catWrapper.entry:GetValue())
                        net.SendToServer()
                    end
                end
            end
        end


        catWrapper.Paint = function (self, w, h)
           // draw.RoundedBox(0, 0, 0, w, h, VoidUI.Colors.White)
        end
    

        local category = catWrapper:Add("VoidCases.ThreeGrid")
        category:Dock(FILL)
        category:DockMargin(0, 10, 0, 0)

        category:InvalidateParent(true)

        category:SetColumns(5)
        category:SetHorizontalMargin(25)
        category:SetVerticalMargin(25)

        
        local openType = {
            [VoidCases.ItemTypes.Case] = "VoidCases.CaseCreate",
            [VoidCases.ItemTypes.Key] = "VoidCases.KeyCreate",
            [VoidCases.ItemTypes.Unboxable] = "VoidCases.ItemCreate",
        }
        

        local currColumn = 0
        local i = 0

        VoidCases.LoadTableGradually(items, 50, 0.05, function (loopItems, index)
            if (!IsValid(category)) then return end

            for _, item in pairs(loopItems) do
                i = i + 1

                if (item.info.shopCategory != k) then continue end
                if (!VoidCases.IsItemValid(item) and !item.info.newItem) then continue end

                currColumn = currColumn + 1
                if (currColumn > 5) then
                    currColumn = 1
                end

                if (!item.info.newItem) then
                    local itemPanel = vgui.Create("VoidCases.Item")
                    itemPanel:Dock(LEFT)
                    itemPanel:SSetSize(215, 215)
                    itemPanel:SetItem(item)

                    local itemPanelB = itemPanel:Add("DButton")
                    itemPanelB:Dock(FILL)
                    itemPanelB:SetZPos(15)
                    itemPanelB.Paint = function (self, w, h)
                        return true
                    end
                    itemPanelB.DoClick = function ()
                        local panel = vgui.Create(openType[item.type])
                        panel:Center()

                        panel.setCategory(self.category) 
                        panel:SetParent(self)
                        panel.setEditing(item, _)

                    end

                    local function moveCategoryPopup(id, val)
                        local popup = vgui.Create("VoidUI.Popup")
                        popup:SetText(L"move_to_category", L("select_category", { item = item.name }))
                        popup:SSetTall(210)
                    
                        local categorySelector = popup:Add("VoidUI.SelectorButton")
                        categorySelector:Dock(BOTTOM)
                        categorySelector:MarginSides(50)
                        categorySelector:SSetTall(30)
                        categorySelector:MarginTops(20)
                        if (id) then
                            categorySelector:Select(id, val)
                        end

                        categorySelector.DoClick = function ()
                            local selector = vgui.Create("VoidUI.ItemSelect") 
                            selector:SetParent(parent)

                            popup:Remove()

                            local tbl = {}
                            for k, _v in pairs(categories) do
                                if (_v == "ADD NEW CATEGORY..." or v == _v) then continue end
                                tbl[k] = _v
                            end

                            selector.SearchFunc = function (item, str, name)
                                return name:lower():find(str:lower(), 1, true) or item:find(str:lower(), 1, true)
                            end

                            selector:InitItems(tbl, function (id, v)
                                moveCategoryPopup(id, v)
                            end)

                            selector.y = selector.y - 120
                        end

                        popup:Continue(L"change", function (val)
                            net.Start("VoidCases_ChangeItemCategory")
                                net.WriteUInt(item.id, 32)
                                net.WriteUInt(categorySelector.value, 16)
                            net.SendToServer()
                        end)
                        
                        popup:Cancel(L"cancel")
                    end

                    local function duplicatePopup()
                        local popup = vgui.Create("VoidUI.Popup")
                        popup:SetText(L"duplicate", L("duplicate_confirm", { item = item.name }))

                        popup:Continue(L"duplicate", function (val)
                            local tblCopy = table.Copy(item)
                            tblCopy.name = tblCopy.name .. " (COPY)"

                            net.Start("VoidCases_CreateItem")
                                net.WriteTable(tblCopy)
                            net.SendToServer()
                        end)
                        
                        popup:Cancel(L"cancel")
                    end

                    local origPress = itemPanelB.OnMousePressed
                    itemPanelB.OnMousePressed = function (s, keycode)
                        origPress(s, keycode)
                        if (keycode == MOUSE_RIGHT) then
                            local ctxMenu = VoidUI:CreateDropdownPopup()

                            local moveCategory = ctxMenu:AddOption(L"move_to_category", function ()
                                moveCategoryPopup()
                            end)

                            local duplicate = ctxMenu:AddOption(L"duplicate", function ()
                                duplicatePopup()
                            end)

                            ctxMenu.y = ctxMenu.y - 15
                            ctxMenu.x = ctxMenu.x + 10
                        end
                    end

                    if (currColumn == 4) then
                        table.insert(self.modelsToHide, itemPanel)
                    end
                    
                    category:AddCell(itemPanel)
                else
                    
                end

            end
        end, function ()
            
        end)
        


        // add new item
        local itemPanel = vgui.Create("DButton")
        itemPanel:Dock(LEFT)
        itemPanel:SetText("")
        itemPanel:SSetSize(215, 215)
        itemPanel.Paint = function (self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.Primary)

            surface.SetMaterial(VoidCases.Icons.AddCase)
            surface.SetDrawColor(VoidUI.Colors.White)
            surface.DrawTexturedRect(w/2-110/2, h/2-110/2, 110, 110)
        end

        if (!VoidCases.Config.Categories[k]) then
            --itemPanel:SetDisabled(true)
            itemPanel:SetCursor("no")
            itemPanel.Paint = function (self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.Hover)

                surface.SetMaterial(VoidCases.Icons.AddCase)
                surface.SetDrawColor(VoidUI.Colors.GrayDarker)
                surface.DrawTexturedRect(w/2-110/2, h/2-110/2, 110, 110)
            end

            itemPanel.DoClick = function ()
                catWrapper.entry:RequestFocus()
                catWrapper.entry:SetFocusTopLevel(true)

                local x, y = catWrapper.entry:LocalToScreen(0,0)
                input.SetCursorPos(x + 10, y + 10)
            end
        else

            itemPanel.DoClick = function ()
                local cursorX, cursorY = input.GetCursorPos()

                local popup = vgui.Create("VoidCases.CreatePopup")
                popup:SetPos(cursorX-40, cursorY-180)

                popup.category = k

                popup:SetParent(self)
            end

        end

        category:AddCell(itemPanel)

       totalCategories = totalCategories + 1
    end

    end

    self.refreshItems()

end

vgui.Register("VoidCases.Items", PANEL, "Panel")
