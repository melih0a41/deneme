
local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale


VoidCases.UnboxingPanel = VoidCases.UnboxingPanel or nil


// 2D unbox panel

local PANEL = {}

function PANEL:Init()
    local csgoPanel = self:Add("VoidCases.CSGOUnbox")
    csgoPanel:Dock(TOP)
    csgoPanel:SSetTall(250)
    csgoPanel:MarginTop(10)

    local container = self:Add("VoidUI.BackgroundPanel")
    container:Dock(FILL)
    container:MarginSides(20)
    container:MarginTops(10)
    container:MarginBottom(20)

    container.Paint = function (self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, VoidUI.Colors.Primary)
        draw.SimpleText(L"winnable_items", "VoidUI.R24", sc(20), sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local itemsGrid = vgui.Create("VoidUI.Grid", container)
    itemsGrid:Dock(FILL)

    itemsGrid:InvalidateParent(true)

    itemsGrid:SetColumns(6)
    itemsGrid:SetHorizontalMargin(sc(10))
    itemsGrid:SetVerticalMargin(20)

    itemsGrid:MarginTop(30)

    VoidCases.UnboxingPanel = self

    timer.Simple(9, function ()
        if (!IsValid(self)) then return end
        if (!self.unboxedItem) then
            self:Remove()
            return
        end

        self.alreadyUnboxed = true
        VoidLib.Notify(L"just_unboxed", self.unboxedItem.name, VoidCases.RarityColors[tonumber(self.unboxedItem.info.rarity)], 4)

        -- play sound
        local raritySound = VoidCases.RaritySounds[tonumber(self.unboxedItem.info.rarity)]
        if (raritySound) then
            surface.PlaySound(raritySound)
        end

        timer.Simple(2, function ()
            if (!IsValid(self)) then return end
            self:Remove()
        end)
    end)

    self.csgoPanel = csgoPanel

    self.close.DoClick = function ()
        if (!self.alreadyUnboxed) then
            if (!self.unboxedItem) then return end
            VoidLib.Notify(L"just_unboxed", self.unboxedItem.name, VoidCases.RarityColors[tonumber(self.unboxedItem.info.rarity)], 4)
        end
        self:Remove()
    end

    self.itemsGrid = itemsGrid
end

function PANEL:InitUnbox(item)
    self.case = item

    net.Start("VoidCases.Open2DCase")
        net.WriteUInt(item.id, 32)
    net.SendToServer()

    if (self.unboxedItem) then
        self.csgoPanel:Open(self.case, self.unboxedItem)
    end

    for k, v in SortedPairsByValue(item.info.unboxableItems, false) do
        local item = VoidCases.Config.Items[k]
        if (!item) then continue end

        local itemPanel = vgui.Create("VoidCases.Item")
        itemPanel:SSetTall(150)
        itemPanel.isShowcase = true
        itemPanel.showMoney = false

        local isMystery = (self.case.info.mysteryItems and self.case.info.mysteryItems[item.id]) or false
        if (isMystery) then
            local mysteryItemTbl = table.Copy(item)
            mysteryItemTbl.name = L"mystery_item"
            mysteryItemTbl.info.icon = "3Brc7ft"
            itemPanel:SetItem(mysteryItemTbl, true, true)
        else
            itemPanel:SetItem(item)
        end
            
        self.itemsGrid:AddCell(itemPanel, nil, sc(150))
    end

    self:SetTitle(string.format(L"opening_case", self.case.name))
end

net.Receive("VoidCases.SendCaseUnboxed", function ()
    local unboxed = net.ReadUInt(32)

    local unboxPanel = VoidCases.UnboxingPanel
    if (IsValid(unboxPanel)) then
        if (unboxPanel.case) then
            unboxPanel.unboxedItem = VoidCases.Config.Items[unboxed]
            unboxPanel.csgoPanel:Open(unboxPanel.case, unboxPanel.unboxedItem)
        end
    end
end)

net.Receive("VoidCases.CaseOpenError", function (intLen)
    local unboxPanel = VoidCases.UnboxingPanel
    if (IsValid(unboxPanel)) then
        unboxPanel:Remove()
    end
end)

function PANEL:Think()
    self:MoveToFront()
end


vgui.Register("VoidCases.2DUnboxing", PANEL, "VoidUI.Frame")
