local function L(phrase)
    return VoidCases.Lang.GetPhrase(phrase)
end

local PANEL = {}

function PANEL:Init()
    self:SSetSize(1400, 800)
    self:Center()

    self:SetTitle("VOIDCASES")

    self.sidebar = self:Add("VoidUI.Sidebar")
    self.sidebar:SetAccentColor(VoidCases.AccentColor)

    self.home = self:Add("VoidCases.Home")
    self.shop = self:Add("VoidCases.Shop")
    if (!VoidCases.Config.DisableMarketplace) then
        self.market = self:Add("VoidCases.Market")
    end
    self.inventory = self:Add("VoidCases.Inventory")
    self.settings = self:Add("VoidCases.Settings")
    if (!VoidCases.Config.DisableTrading) then
        self.trading = self:Add("VoidCases.Trading")
    end


    self.refreshItems = function ()
        self.home.refreshItems()
        self.shop.refreshItems()

        if (self.settings.items) then
            self.settings.items.refreshItems()
        end

        if (self.settings.featuredItems) then
            self.settings.featuredItems:UpdateItems()
        end

        if (self.settings.options and self.settings.options.ccPanels) then
            local rarities = self.settings.options.ccPanels["VoidCases.Rarities"]
            if (rarities and rarities.refreshRarities) then
                rarities.refreshRarities()
            end
        end

        self.inventory.refreshItems()
        if (self.trading and self.trading.refreshInventory) then
            local tradingInv = self.trading.inv
            for k, v in pairs(VoidCases.Inventory) do
                local diff = v - (self.trading.tradeObj.items[k] or 0)
                tradingInv[k] = diff
            end
            if (!VoidCases.Config.DisableTrading) then
                self.trading.refreshInventory()
            end
        end
    end

    self.refreshMarketplace = function ()
        if (self.market) then
            self.market.refreshItems()
        end
    end


    self.sidebar:AddTab("HOME", VoidCases.Icons.Home, self.home, false, VoidCases.IconSizes.Home)
    self.sidebar:AddTab("SHOP", VoidCases.Icons.Shop, self.shop, false, VoidCases.IconSizes.Shop)
    if (!VoidCases.Config.DisableMarketplace) then
        self.sidebar:AddTab("MARKET", VoidCases.Icons.Market, self.market, false, VoidCases.IconSizes.Market)
    end
    self.invButton = self.sidebar:AddTab("INVENTORY", VoidCases.Icons.Inventory, self.inventory, false, VoidCases.IconSizes.Inventory)
    if (!VoidCases.Config.DisableTrading) then
        self.tradingButton = self.sidebar:AddTab("TRADING", VoidCases.Icons.Trade, self.trading, false, VoidCases.IconSizes.Trade)
    end

    if (CAMI.PlayerHasAccess(LocalPlayer(), "VoidCases_EditSettings") or CAMI.PlayerHasAccess(LocalPlayer(), "VoidCases_CreateItems") or CAMI.PlayerHasAccess(LocalPlayer(), "VoidCases_EditInventories")) then
        self.sidebar:AddTab("SETTINGS", VoidCases.Icons.Settings, self.settings, true, VoidCases.IconSizes.Settings)
    end

end

function PANEL:OnKeyCodeReleased(key)
    if (key == KEY_ESCAPE) then
        gui.HideGameUI()
        self:Remove()
    end
end

vgui.Register("VoidCases.MainPanel", PANEL, "VoidUI.Frame")
