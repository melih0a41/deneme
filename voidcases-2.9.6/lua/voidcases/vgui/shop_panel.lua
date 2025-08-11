local function L(phrase)
    return VoidCases.Lang.GetPhrase(phrase)
end

// Shop

local sc = VoidUI.Scale

VoidCases.PreviewPanel = nil

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)

    self:SetTitle(L"shop")

    local searchCard = self:Add("VoidUI.BackgroundPanel")
    searchCard:Dock(TOP)
    searchCard:SSetTall(50)
    searchCard:MarginTop(5)
    searchCard:MarginSides(45)
    searchCard:DockPadding(30,8,10,8)

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

    self.rarityFilter = rarityFilter

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

    self.itemFilter = itemFilter

    self.itemPanel = self:Add("VoidUI.ScrollPanel")
    self.itemPanel:Dock(FILL)
    self.itemPanel:SDockMargin(45, 15, 45, 30)

    self.refreshItems = function (str)
        self:LoadItems(str)
    end

    self.refreshItems()
end

local function getItemsSortedByCategory()
    local sortedItems = {}

    for itemId, itemData in pairs(VoidCases.Config.Items) do
        local categoryId = itemData.info.shopCategory
        local categoryName = VoidCases.Config.Categories[categoryId]

        sortedItems[categoryName] = sortedItems[categoryName] or {}
        sortedItems[categoryName][itemId] = itemData
    end

    return sortedItems
end

function PANEL:LoadItems(str)
    self.itemPanel:Clear()

    self.modelsToHide = {}

    local itemFilter = self.itemFilter
    local rarityFilter = self.rarityFilter

    local function checkItemPass(item)
        local rarityName = nil
        for k, v in pairs(VoidCases.Rarities) do
            if (v == tonumber(item.info.rarity)) then
                rarityName = k
            end
        end

        if (str and (!item.name:lower():find(str:lower(), 1, true) and !rarityName:lower():find(str:lower(), 1, false)) ) then return false end
        if ((rarityFilter:GetSelected() and rarityFilter:GetSelected() != "" and rarityFilter:GetSelected() != L"none") and rarityFilter:GetSelected() != rarityName) then return false end
        
        if (itemFilter:GetSelected() and itemFilter:GetSelected() != "" and itemFilter:GetSelected() != L"none") then
            local currFilter = itemFilter:GetSelected()

            if (currFilter == L"weapons" and item.info.actionType != "weapon") then return false end
            if (currFilter == L"cases" and item.type != VoidCases.ItemTypes.Case) then return false end
            if (currFilter == L"keys" and item.type != VoidCases.ItemTypes.Key) then return false end
            if (currFilter == L"skins" and item.info.actionType != "weapon_skin") then return false end
            if (currFilter == L"money" and item.info.actionType != "money") then return false end

            if (currFilter == L"other" and (!item.info.actionType or (!item.info.actionType:find("pointshop") and item.info.actionType != "concommand"))) then return false end
        end

        return true
    end

    local function itemVisibleByRank(item)
        if item.info.showIfCannotPurchase then return true end
        if (table.Count(item.info.requiredUsergroups or {}) == 0) then return true end

        local playerGroup = LocalPlayer():GetUserGroup()

        for requiredGroup, b in pairs(item.info.requiredUsergroups) do
            local hasInheritedGroup = VoidCases.Config.UseInheritance and CAMI.UsergroupInherits(playerGroup, requiredGroup)
            if ((requiredGroup == playerGroup) or hasInheritedGroup) then
                return true
            end
        end

        return false
    end

    local totalCategories = 0

    for categoryName, itemTbl in pairs(getItemsSortedByCategory()) do
        local itemsInCategory = table.Count(itemTbl)
        if (itemsInCategory == 0) then continue end

        local totalCategoryItems = 0
        local currColumn = 0

        local tblFilteredItems = {}
        for itemId, item in pairs(itemTbl) do
            if not VoidCases.IsItemValid(item) then continue end
            if not checkItemPass(item) then continue end
            if not itemVisibleByRank(item) then continue end
            if not item.info.sellInShop then continue end

            tblFilteredItems[itemId] = item
        end

        if table.Count(tblFilteredItems) == 0 then continue end

        local catWrapper = vgui.Create("DCollapsibleCategory", self.itemPanel)
        catWrapper:Dock(TOP)
        catWrapper:SetTall(sc(250) * math.ceil(itemsInCategory / 5) + sc(55))
        catWrapper:MarginBottom(15)
        catWrapper:SDockPadding(15, 5, 15, 15)
        catWrapper:SetHeaderHeight(sc(45))
        catWrapper:SetLabel("")
        catWrapper.Paint = function (self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
            draw.SimpleText(string.upper(categoryName), "VoidUI.R28", sc(15), sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local category = vgui.Create("VoidUI.Grid", catWrapper)
        category:Dock(FILL)
        category:DockMargin(0, 0, 0, 0)
        category:InvalidateParent(true)
        category:SetColumns(5)
        category:SetHorizontalMargin(sc(10))
        category:SetVerticalMargin(20)

        VoidCases.LoadTableGradually(tblFilteredItems, 50, 0.05, function (items, index)
            if (!IsValid(category)) then return end

            -- Load
            for _, item in pairs(items) do

                local hasAccess = true
                if (item.info.requiredUsergroups and table.Count(item.info.requiredUsergroups) > 0) then
                    hasAccess = false
                    for k, v in pairs(item.info.requiredUsergroups or {}) do
                        if (CAMI.UsergroupInherits(LocalPlayer():GetUserGroup(), k)) then
                            hasAccess = true
                        end
                    end
                end

                currColumn = currColumn + 1
                if (currColumn > 5) then
                    currColumn = 1
                end
     
    
                local itemPanel = vgui.Create("VoidCases.Item")
                itemPanel:SSetTall(230)
                itemPanel:SSetWide(230)
                itemPanel.isList = true
    
                itemPanel:SetItem(item)
                
                category:AddCell(itemPanel, nil, sc(230))
    
                if (currColumn == 2 || currColumn == 3 || currColumn == 4) then
                    table.insert(self.modelsToHide, itemPanel)
                end
    
                local itemPanelB = itemPanel:Add("DButton")
                itemPanelB:Dock(FILL)
                itemPanelB:SetText("")
                itemPanelB.Paint = function (self, w, h) 
                    if (!hasAccess and item.info.showIfCannotPurchase) then
                        draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.DarkGrayTransparent)
    
                        surface.SetDrawColor(VoidUI.Colors.GrayDarker)
                        surface.SetMaterial(VoidCases.Icons.Lock)
                        surface.DrawTexturedRect(w/2 - 41, h/2-97/2, 82, 97)
    
                        surface.SetDrawColor(VoidUI.Colors.Primary)
                        surface.DrawRect(w/2-math.Round(ScrW() * 0.052), 20, math.Round(ScrW() * 0.10416), 32)
    
                        draw.SimpleText(L"incorrect_usergroup", "VoidUI.R20", w/2, 20+32/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
                itemPanelB:SetZPos(30)
    
                if (!hasAccess and item.info.showIfCannotPurchase) then
                    itemPanelB:SetCursor("no")
                    itemPanelB:SetEnabled(false)
                end
    
                itemPanel.b = itemPanelB
     
                itemPanelB.DoClick = function ()
                    if (IsValid(VoidCases.PreviewPanel)) then return end
    
                    local panel = vgui.Create("VoidCases.ItemPurchase")
                    panel:SetSize(ScrW() * 0.5448, ScrH() * 0.648)
                    panel:Center()
    
                    panel:SetParent(self)
                    panel:InitItem(_, item)
    
                    VoidCases.PreviewPanel = panel
                end
    
                totalCategoryItems = totalCategoryItems + 1
    
            end
        end, function ()
            -- Finish
            if (totalCategoryItems == 0) then
                category:Remove()            
            else
                totalCategories = totalCategories + 1
            end
        end)

    end
    
    if (totalCategories < 1 and #VoidCases.Config.Items < 1) then
        self.itemPanel.Paint = function (self, w, h)
            draw.SimpleText(L"no_items_avail", "VoidUI.B50", w/2, h/2-100, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(L"create_items_shop", "VoidUI.B50", w/2, h/2-30, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end 
end

vgui.Register("VoidCases.Shop", PANEL, "VoidUI.PanelContent")
