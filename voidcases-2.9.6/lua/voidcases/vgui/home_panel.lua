local L = VoidCases.Lang.GetPhrase

// Home

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1300, 750)
    local titlePanel = self:SetTitle(L"featured_items")

    self.bestSellerItems = {}

    local container = self:Add("Panel")
    container:Dock(FILL)

    local featuredItems = VoidCases.Config.HomeFeaturedItems or {}
    local featuredItemsOne = featuredItems[1]
    local featuredItemsTwo = featuredItems[2]

    local leftContainer = container:Add("VoidUI.BackgroundPanel")
    leftContainer:Dock(LEFT)
    leftContainer:SetTitle(featuredItemsOne.name and featuredItemsOne.name:upper() or "CATEGORY #1")
    self:AddFeaturedItems(leftContainer, 1)

    local bestSellerContainer = container:Add("VoidUI.BackgroundPanel")
    bestSellerContainer:Dock(FILL)
    bestSellerContainer:SetTitle( (L"best_sellers"):upper() )

    for i = 1, 2 do
        local featuredItem = VoidCases.Config.FeaturedItems[i]
        if (!featuredItem) then continue end

        local item = featuredItem[1]
        if (!item) then continue end

        if (!VoidCases.IsItemValid(item)) then continue end

        local hasAccess = true
        if (item.info.requiredUsergroups and table.Count(item.info.requiredUsergroups) > 0) then
            hasAccess = false
            for k, v in pairs(item.info.requiredUsergroups or {}) do
                if (CAMI.UsergroupInherits(LocalPlayer():GetUserGroup(), k)) then
                    hasAccess = true
                end
            end
            if (!hasAccess and item.info.requiredUsergroups and !item.info.showIfCannotPurchase) then continue end
        end

        local itemElement = bestSellerContainer:Add("VoidCases.Item")
        itemElement:SetItem(item)
        itemElement:Dock(i == 1 and LEFT or RIGHT)
        itemElement:MarginSides(10)
        itemElement:SSetWide(290)

        local itemPanelB = itemElement:Add("DButton")
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

        itemElement.b = itemPanelB

        itemPanelB.DoClick = function ()

            if (IsValid(VoidCases.PreviewPanel)) then return end

            local panel = vgui.Create("VoidCases.ItemPurchase")
            panel:SetSize(ScrW() * 0.5448, ScrH() * 0.648)
            panel:Center()

            panel:SetParent(self)
            panel:InitItem(item.id, item)

            VoidCases.PreviewPanel = panel
        end

        self.bestSellerItems[#self.bestSellerItems + 1] = itemElement
    end
    
    local rightContainer = container:Add("VoidUI.BackgroundPanel")
    rightContainer:Dock(RIGHT)
    rightContainer:SetTitle(featuredItemsTwo.name or "CATEGORY #2")
    self:AddFeaturedItems(rightContainer, 2)

    self.container = container
    self.leftContainer = leftContainer
    self.rightContainer = rightContainer
    self.bestSeller = bestSellerContainer
    self.titlePanel = titlePanel

    self.refreshItems = function ()
        self:AddFeaturedItems(leftContainer, 1)
        self:AddFeaturedItems(rightContainer, 2)
    end
end

function PANEL:AddFeaturedItems(container, id)

    container:Clear()

    for slot = 1, 2 do
        local featuredItem = VoidCases.Config.HomeFeaturedItems[id].items[slot]
        local item = VoidCases.Config.Items[tonumber(featuredItem)]

        if (!VoidCases.IsItemValid(item)) then continue end

        local hasAccess = true
        if (item.info.requiredUsergroups and table.Count(item.info.requiredUsergroups) > 0) then
            hasAccess = false
            for k, v in pairs(item.info.requiredUsergroups or {}) do
                if (CAMI.UsergroupInherits(LocalPlayer():GetUserGroup(), k)) then
                    hasAccess = true
                end
            end
            if (!hasAccess and item.info.requiredUsergroups and !item.info.showIfCannotPurchase) then continue end
        end

        itemPanel = container:Add("VoidCases.Item")
        itemPanel:Dock(slot == 1 and TOP or BOTTOM)
        itemPanel:SSetTall(260)
        itemPanel:SetItem(item)

        if (slot == 2) then
            itemPanel:MarginBottom(5)
        else
            itemPanel:MarginBottom(10)
            itemPanel:MarginTop(35)
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
            panel:InitItem(item.id, item)

            VoidCases.PreviewPanel = panel
        end

    end


end

local function createItemButton(container, slot, id)

    local function createSelector()
        local selector = vgui.Create("VoidUI.ItemSelect")
        selector:SetParent(self)

        local itemTbl = {}
        for id, item in pairs(VoidCases.Config.Items) do
            if (!item.info.sellInShop) then continue end

            itemTbl[tonumber(item.id)] = item.name
        end

        selector:InitItems(itemTbl, function (k, v)
            -- update here
            net.Start("VoidCases_UpdateFeaturedItems")
                net.WriteBool(false)
                net.WriteUInt(id, 2)
                net.WriteUInt(slot, 2)
                net.WriteUInt(k, 20)
            net.SendToServer()
        end)
    end

    local featuredItem = VoidCases.Config.HomeFeaturedItems[id].items[slot]
    local item = VoidCases.Config.Items[tonumber(featuredItem)]

    local itemPanel = nil
    if (featuredItem == nil or !VoidCases.IsItemValid(item)) then

        itemPanel = container:Add("DButton")
        itemPanel:Dock(slot == 1 and TOP or BOTTOM)
        itemPanel:SetText("")
        itemPanel:SSetTall(245)
        itemPanel.Paint = function (self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.Hover)

            surface.SetMaterial(VoidCases.Icons.AddCase)
            surface.SetDrawColor(VoidUI.Colors.White)
            surface.DrawTexturedRect(w/2-110/2, h/2-110/2, 110, 110)
        end

        itemPanel.DoClick = function ()
            createSelector()
        end

    else
        itemPanel = container:Add("VoidCases.Item")
        itemPanel:Dock(slot == 1 and TOP or BOTTOM)
        itemPanel:SSetTall(245)
        itemPanel:SetItem(item)

        local itemPanelB = itemPanel:Add("DButton")
        itemPanelB:Dock(FILL)
        itemPanelB:SetText("")
        itemPanelB.Paint = nil
        itemPanelB:SetZPos(30)
        itemPanelB.DoClick = function ()
            createSelector()
        end
    end

    if (slot == 2) then
        itemPanel:MarginBottom(5)
    else
        itemPanel:MarginTop(5)
        -- itemPanel:MarginBottom(10)
    end

end

local function createCategoryInput(container, id)

    container:SetTitle("")

    local featuredItemsOne = VoidCases.Config.HomeFeaturedItems[id]
    
    local leftCategory = container:Add("VoidCases.EditableCategory")
    leftCategory:Dock(TOP)
    leftCategory:SSetTall(30)
    leftCategory.entry:SetFont("VoidUI.R24")
    leftCategory.pencilSpacing = 15

    leftCategory.entry:SetValue(featuredItemsOne.name and featuredItemsOne.name:upper() or "")

    function leftCategory.entry:OnFocusChanged(gained)
        if (!gained) then
            net.Start("VoidCases_UpdateFeaturedItems")
                net.WriteBool(true)
                net.WriteUInt(id, 2)
                net.WriteString(leftCategory.entry:GetValue():upper())
            net.SendToServer()
        end
    end

    createItemButton(container, 1, id)
    createItemButton(container, 2, id)
end

function PANEL:UpdateItems()

    local leftContainer = self.leftContainer
    local rightContainer = self.rightContainer

    leftContainer:Clear()
    rightContainer:Clear()

    createCategoryInput(leftContainer, 1)
    createCategoryInput(rightContainer, 2)
end

function PANEL:SetNonInteractive()

    local leftContainer = self.leftContainer
    local rightContainer = self.rightContainer

    leftContainer:Clear()
    rightContainer:Clear()

    for k, v in ipairs(self.bestSellerItems) do
        v.b:Remove()
    end

    createCategoryInput(leftContainer, 1)
    createCategoryInput(rightContainer, 2)

end

function PANEL:PerformLayout(w, h)
    self.titlePanel:MarginSides(25, self)
    self.titlePanel:MarginTop(35, self)
    self.container:SDockMargin(25,10,25,40,self)

    self.leftContainer:SSetWide(290, self)
    self.rightContainer:SSetWide(290, self)

    self.bestSeller:MarginSides(15, self)
    self.bestSeller:SDockPadding(10, 50, 10, 20)
end

vgui.Register("VoidCases.Home", PANEL, "VoidUI.PanelContent")
