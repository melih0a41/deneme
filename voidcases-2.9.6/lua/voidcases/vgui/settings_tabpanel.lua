local L = VoidCases.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    local tabs = self:Add("VoidUI.Tabs")
    tabs:SetAccentColor(VoidCases.AccentColor)

    local canCreateItems = CAMI.PlayerHasAccess(LocalPlayer(), "VoidCases_CreateItems")

    if (canCreateItems) then
        local editItems = tabs:Add("VoidCases.Items")
        tabs:AddTab(string.upper(L"edit_items"), editItems)

        self.items = editItems
    end

    if (CAMI.PlayerHasAccess(LocalPlayer(), "VoidCases_EditSettings")) then
        local options = tabs:Add("VoidCases.Options")
        tabs:AddTab(string.upper(L"options"), options)

        self.options = options
    end

    if (CAMI.PlayerHasAccess(LocalPlayer(), "VoidCases_EditInventories")) then
        local invs = tabs:Add("VoidCases.InventoryAdmin")
        tabs:AddTab(string.upper(L"inventories"), invs)

        self.invs = invs
    end

    if (canCreateItems) then
        local featuredItems = tabs:Add("VoidCases.Home")
        featuredItems:SetNonInteractive()
        tabs:AddTab(string.upper(L"featured_items"), featuredItems)

        self.featuredItems = featuredItems
    end
end

vgui.Register("VoidCases.Settings", PANEL, "Panel")