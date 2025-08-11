
local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale

// Create Item panel

local PANEL = {}

function PANEL:Init()

    self:MakePopup()
    self:SSetSize(960, 648)
    self:Center()

    local frame = self:Add("VoidUI.Frame")
    frame:Dock(FILL)
    frame:MarginRight(30)


    self.itemPreview = self:Add("Panel")
    self.itemPreview:Dock(RIGHT)
    self.itemPreview:SSetWide(290)

    self.itemPreview.Paint = function (self, w, h)
        local x, y = self:LocalToScreen(0, 0)

        BSHADOWS.BeginShadow()
            draw.RoundedBox(0, x, y, w, sc(350), VoidUI.Colors.Primary)
        BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)

        draw.SimpleText(L"item_preview", "VoidUI.B28", w/2, sc(35), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function frame:OnRemove()
        self:GetParent():Remove()
    end

    self.itemP = self.itemPreview:Add("VoidCases.Item")
    self.itemP:Dock(TOP)
    self.itemP:MarginSides(15)
    self.itemP:MarginTops(15)
    self.itemP:MarginTop(60)

    self.itemP:SSetTall(260)

    local itemP = self.itemP

    self.currCategory = 1
	
    local intDefaultRarity = VoidCases.Rarities.Common
    if (!intDefaultRarity) then
        for k, v in SortedPairsByValue(VoidCases.Rarities) do
            if (v == 1) then
                intDefaultRarity = v
            end
        end
    end

    if (!intDefaultRarity) then
        intDefaultRarity = VoidCases.Rarities[table.GetKeys(VoidCases.Rarities)[1]]
    end

    self.itemObj = {
        name = "Item",
        type = VoidCases.ItemTypes.Unboxable,
        info = {
            shopCategory = self.currCategory,
            rarity = intDefaultRarity,
            icon = nil,

            sellInShop = false,
            isMarketable = true,
            shopPrice = 0,

            actionType = "weapon",
            actionValue = "",

            weaponSkin = nil,
            isPermanent = false,

            autoEquip = false,

            cooldownType = 0,
            cooldownTime = 0,
        
            currency = table.GetKeys(VoidCases.Currencies)[1]
        },
    }

    local itemObj = self.itemObj

    self.itemP:SetItem(itemObj)

    self.setCategory = function (cat)
        self.currCategory = cat
        itemObj.info.shopCategory = cat
    end

    frame:SetTitle(L"creating_item")

    self.isEditing = false
    self.editCrate = nil

    self.tabs = frame:Add("VoidUI.Tabs")
    self.tabs:SetAccentColor(VoidCases.AccentColor)

    local buttonContainer = frame:Add("Panel")
    buttonContainer:Dock(BOTTOM)
    buttonContainer:SSetTall(100)
    buttonContainer:SDockPadding(100,30,100,30)

    self.create = buttonContainer:Add("VoidUI.Button")
    self.create.text = L"save"
    self.create:Dock(LEFT)
    self.create:SSetWide(200)
    self.create:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)

    self.create.DoClick = function ()
        if (!VoidCases.IsItemValid(itemObj)) then return end

        if (self.isEditing) then
            net.Start("VoidCases_ModifyItem")
                net.WriteUInt(self.editID, 32)
                net.WriteTable(itemObj)
            net.SendToServer()
        else
            net.Start("VoidCases_CreateItem")
                net.WriteTable(itemObj)
            net.SendToServer()
        end

        for k, v in pairs(self:GetParent().modelsToHide or {}) do
            if (IsValid(v) and v.icon) then
                v.icon:SetVisible(true)
            end
        end

        self:Remove()
    end


    self.itemDetails = self.tabs:Add("Panel")
    self.itemDetails:Dock(LEFT)
    self.itemDetails:SetWide(ScrW() * 0.315)
    self.itemDetails:DockMargin(0, 0, 0, 0)

    local entryPanel = self.itemDetails:Add("VoidUI.Grid")
    entryPanel:Dock(FILL)
    entryPanel:DockMargin(18, 10, 0, 10)

    entryPanel:InvalidateParent(true)

    entryPanel:SetColumns(2)
    entryPanel:SetHorizontalMargin(45)
    entryPanel:SetVerticalMargin(40)

    self.entryPanel = entryPanel

    // Name

    local nameEntry = vgui.Create("Panel")
    nameEntry:SSetWide(250)
    nameEntry:SetTall(sc(75))
    
    nameEntry.Paint = function (self, w, h)
        draw.SimpleText(L"name", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    nameEntry.input = nameEntry:Add("VoidUI.TextInput")
    nameEntry.input:Dock(TOP)
    nameEntry.input:DockMargin(0, sc(30), 0, 0)
    nameEntry.input:SetTall(sc(45))

    function nameEntry.input.entry:OnValueChange(val)
		itemObj.name = val   
	end

    entryPanel:AddCell(nameEntry)

    self.nameEntry = nameEntry

    // Rarity

    local rarityEntry = vgui.Create("Panel")
    rarityEntry:SetWide(ScrW() * 0.124)
    rarityEntry:SetTall(sc(75))
    
    rarityEntry.Paint = function (self, w, h)
        draw.SimpleText(L"rarity", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    rarityEntry.input = rarityEntry:Add("VoidUI.Dropdown")
    rarityEntry.input:Dock(TOP)
    rarityEntry.input:DockMargin(0, sc(30), 0, 0)
    rarityEntry.input:SetTall(sc(45))

    rarityEntry.input:SetValue("Select rarity")

    for k, v in SortedPairsByValue(VoidCases.Rarities) do
        rarityEntry.input:AddChoice(k)
        if (v == 1) then
            rarityEntry.input:ChooseOption(k)
        end
    end

    function rarityEntry.input:OnSelect(index, val)
        itemObj.info.rarity = index
    end

    entryPanel:AddCell(rarityEntry)

    // Type choose

    local loadActionValues = self:CreateActionSelectors(entryPanel, function() return itemObj end, function (val) itemObj.info.actionType = val end, function (val) itemObj.info.actionValue = val end, function (obj)
        itemObj = obj(itemObj)
    end)
    loadActionValues(itemObj)

    // Icon type

    local iconChooseEntry = vgui.Create("Panel")
    local iconValueEntry = vgui.Create("Panel")
    
    iconChooseEntry:SetWide(ScrW() * 0.124)
    iconChooseEntry:SetTall(sc(75))
    
    iconChooseEntry.Paint = function (self, w, h)
        draw.SimpleText(L"item_icon", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    iconChooseEntry.input = iconChooseEntry:Add("VoidUI.Dropdown")
    iconChooseEntry.input:Dock(TOP)
    iconChooseEntry.input:DockMargin(0, sc(30), 0, 0)
    iconChooseEntry.input:SetTall(sc(45))

    iconChooseEntry.input:AddChoice("Imgur Image")
    iconChooseEntry.input:AddChoice("Model")

    iconChooseEntry.input:ChooseOptionID(2)

    local zoomEntry = vgui.Create("Panel")

    function iconChooseEntry.input:OnSelect(index, val)
        if (index == 1) then
            // Icon
            iconValueEntry.input.Paint = function (self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Gray)
                local text = VoidCases.ImageProvider
                text = string.Replace(text, ".png", "")
                text = string.Replace(text, "%s", "")
                text = string.Replace(text, "https://", "")
                text = string.Replace(text, "http://", "")

                draw.SimpleText(text, "VoidUI.R26", sc(10), h/2, VoidUI.Colors.TextGray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            iconValueEntry.input:Remove()

            iconValueEntry.input = iconValueEntry:Add("VoidCases.TextInputLogo")
            iconValueEntry.input:Dock(TOP)
            iconValueEntry.input:DockMargin(0, sc(30), 0, 0)
            iconValueEntry.input:SetTall(sc(45))

            function iconValueEntry.input.entry:OnValueChange(val)
		        itemObj.info.icon = val
                itemP:SetItem(itemObj, iconChooseEntry.input:GetSelectedID() == 2 and "model" or "icon")
	        end

            
        else
            // Model
            iconValueEntry.input.Paint = function (self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.White)
            end

            

            iconValueEntry.input:Remove()

            iconValueEntry.input = iconValueEntry:Add("VoidUI.TextInput")
            iconValueEntry.input:Dock(TOP)
            iconValueEntry.input:DockMargin(0, sc(30), 0, 0)
            iconValueEntry.input:SetTall(sc(45))

            iconValueEntry.input.entry:SetFont("VoidUI.R18")

            function iconValueEntry.input.entry:OnValueChange(val)
		        itemObj.info.icon = val
                itemP:SetItem(itemObj, iconChooseEntry.input:GetSelectedID() == 2 and "model" or "icon")
                
	        end
            
        end

        if (index == 2) then
            zoomEntry:SetVisible(true)
        else
            zoomEntry:SetVisible(false)
        end
    end

    entryPanel:AddCell(iconChooseEntry)

    // Icon value entry

    
    iconValueEntry:SetWide(ScrW() * 0.124)
    iconValueEntry:SetTall(sc(75))
    
    iconValueEntry.Paint = function (self, w, h)
        if (iconChooseEntry.input:GetSelectedID() == 1) then
            draw.SimpleText(L"custom_image_id", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(L"model_path", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    iconValueEntry.input = iconValueEntry:Add("VoidUI.TextInput")
    iconValueEntry.input:Dock(TOP)
    iconValueEntry.input:DockMargin(0, sc(30), 0, 0)
    iconValueEntry.input:SetTall(sc(45))
 

    function iconValueEntry.input.entry:OnValueChange(val)
		itemObj.info.icon = val
        itemP:SetItem(itemObj, iconChooseEntry.input:GetSelectedID() == 2 and "model" or "icon")

    end

    entryPanel:AddCell(iconValueEntry)

    self.iconChooseEntry = iconChooseEntry
    self.iconValueEntry = iconValueEntry

    // Zoom entry
    
    zoomEntry:SetWide(ScrW() * 0.124)
    zoomEntry:SetTall(sc(75))
    
    zoomEntry.Paint = function (self, w, h)
        draw.SimpleText(L"item_fov", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    zoomEntry.input = zoomEntry:Add("VoidUI.TextInput")
    zoomEntry.input:Dock(TOP)
    zoomEntry.input:DockMargin(0, sc(30), 0, 0)
    zoomEntry.input:SetTall(sc(45))
    zoomEntry.input.entry:SetNumeric(true)

    zoomEntry.input.entry:SetValue(55)

    function zoomEntry.input.entry:OnValueChange(val)
        if (val and isnumber(tonumber(val)) and VoidCases.IsModel(itemObj.info.icon)) then
            itemObj.info.zoom = tonumber(val)
            itemP.icon:SetFOV(tonumber(val)) 
        end
	end

    //zoomEntry:SetVisible(false)


    entryPanel:AddCell(zoomEntry)

    self.itemLimits = self.tabs:Add("Panel")
    self.itemLimits:Dock(LEFT)
    self.itemLimits:SetWide(ScrW() * 0.315)
    self.itemLimits:DockMargin(0, 0, 0, 0)

    self.itemLimits:SetVisible(false)

    local entryLimitsPanel = self.itemLimits:Add("VoidUI.Grid")
    entryLimitsPanel:Dock(FILL)
    entryLimitsPanel:DockMargin(18, 24, 0, 18)

    entryLimitsPanel:InvalidateParent(true)

    entryLimitsPanel:SetColumns(2)
    entryLimitsPanel:SetHorizontalMargin(45)
    entryLimitsPanel:SetVerticalMargin(35)

    // Sell in shop

    local sellShopEntry = vgui.Create("Panel")
    sellShopEntry:SetWide(ScrW() * 0.124)
    sellShopEntry:SetTall(sc(75))
    
    sellShopEntry.Paint = function (self, w, h)
        draw.SimpleText(L"sell_in_shop", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    sellShopEntry.input = sellShopEntry:Add("VoidUI.Switch")
    sellShopEntry.input:Dock(TOP)
    sellShopEntry.input:DockMargin(0, sc(30), 0, 0)
    sellShopEntry.input:SetTall(sc(45))
    sellShopEntry.input:DropdownCompat()

    local priceEntry = vgui.Create("Panel")
    function sellShopEntry.input:OnSelect(index, val)
        if (index == 1) then
            priceEntry:SetVisible(true)
            itemObj.info.sellInShop = true
        else
            priceEntry:SetVisible(false)
            itemObj.info.shopPrice = 0
            itemObj.info.sellInShop = false
        end
    end

    entryLimitsPanel:AddCell(sellShopEntry)

    // Price (if sellinshop true)

    priceEntry:SetWide(ScrW() * 0.124)
    priceEntry:SetTall(sc(75))
    
    priceEntry.Paint = function (self, w, h)
        draw.SimpleText(L"price", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    priceEntry.input = priceEntry:Add("VoidUI.TextInput")
    priceEntry.input:Dock(TOP)
    priceEntry.input:DockMargin(0, sc(30), 0, 0)
    priceEntry.input:SetTall(sc(45))
    priceEntry.input.entry:SetNumeric(true)

    function priceEntry.input.entry:OnValueChange(val)
		itemObj.info.shopPrice = val   
	end

    priceEntry:SetVisible(false)

    entryLimitsPanel:AddCell(priceEntry)
    

    // Permanent Item

    local permaEntry = vgui.Create("Panel")
    permaEntry:SetWide(ScrW() * 0.124)
    permaEntry:SetTall(sc(75))
    
    permaEntry.Paint = function (self, w, h)
        draw.SimpleText(L"is_permanent", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    permaEntry.input = permaEntry:Add("VoidUI.Switch")
    permaEntry.input:Dock(TOP)
    permaEntry.input:DockMargin(0, sc(30), 0, 0)
    permaEntry.input:SetTall(sc(45))
    permaEntry.input:DropdownCompat()

    function permaEntry.input:OnSelect(index, val)
        if (index == 1) then
            itemObj.info.isPermanent = true
        else
            itemObj.info.isPermanent = false
        end
    end

    entryLimitsPanel:AddCell(permaEntry)

    // Auto equip item

    local autoEquip = vgui.Create("Panel")
    autoEquip:SetWide(ScrW() * 0.124)
    autoEquip:SetTall(sc(75))
    
    autoEquip.Paint = function (self, w, h)
        draw.SimpleText(L"auto_equip", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    autoEquip.input = autoEquip:Add("VoidUI.Switch")
    autoEquip.input:Dock(TOP)
    autoEquip.input:DockMargin(0, sc(30), 0, 0)
    autoEquip.input:SetTall(sc(45))
    autoEquip.input:DropdownCompat()


    function autoEquip.input:OnSelect(index, val)
        if (index == 1) then
            itemObj.info.autoEquip = true
        else
            itemObj.info.autoEquip = false
        end
    end

    entryLimitsPanel:AddCell(autoEquip)

    // Usergroup restriction

    local groupEntry = vgui.Create("Panel")
    groupEntry:SetWide(ScrW() * 0.124)
    groupEntry:SetTall(sc(75))
    
    groupEntry.Paint = function (self, w, h)
        draw.SimpleText(L"usergroups", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    groupEntry.input = groupEntry:Add("VoidUI.Dropdown")
    groupEntry.input:Dock(TOP)
    groupEntry.input:DockMargin(0, sc(30), 0, 0)
    groupEntry.input:SetTall(sc(45))

    groupEntry.input.multiple = true
    groupEntry.input.selectedItems = {}
    groupEntry.input:SetText("...")

    for k, v in pairs(CAMI.GetUsergroups()) do
        groupEntry.input:AddChoice(v.Name)
    end

    function groupEntry.input:OnSelect( index, val ) 
        if (self.selectedItems[val]) then
            self.selectedItems[val] = nil
        else
            self.selectedItems[val] = true
        end

        itemObj.info.requiredUsergroups = self.selectedItems

    end 
    
    entryLimitsPanel:AddCell(groupEntry)

    // Display if not correct usergroup

    local displayGroupEntry = vgui.Create("Panel")
    displayGroupEntry:SetWide(ScrW() * 0.124)
    displayGroupEntry:SetTall(sc(75))
    
    displayGroupEntry.Paint = function (self, w, h)
        draw.SimpleText(L"show_if_cant_purchase", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    displayGroupEntry.input = displayGroupEntry:Add("VoidUI.Switch")
    displayGroupEntry.input:Dock(TOP)
    displayGroupEntry.input:DockMargin(0, sc(30), 0, 0)
    displayGroupEntry.input:SetTall(sc(45))
    displayGroupEntry.input:DropdownCompat()

    function displayGroupEntry.input:OnSelect(index, val)
        if (index == 1) then
            itemObj.info.showIfCannotPurchase = true
        else
            itemObj.info.showIfCannotPurchase = false
        end
    end

    entryLimitsPanel:AddCell(displayGroupEntry)

    // Limits per x

    local purchaseCooldownEntry = vgui.Create("Panel")
    purchaseCooldownEntry:SetWide(ScrW() * 0.124)
    purchaseCooldownEntry:SetTall(sc(75))
    
    purchaseCooldownEntry.Paint = function (self, w, h)
        draw.SimpleText(L"purchase_cooldown", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    purchaseCooldownEntry.input = purchaseCooldownEntry:Add("VoidUI.Dropdown")
    purchaseCooldownEntry.input:Dock(TOP)
    purchaseCooldownEntry.input:DockMargin(0, sc(30), 0, 0)
    purchaseCooldownEntry.input:SetTall(sc(45))

    local intervals = {
        ["none"] = 0,
        ["minute"] = 60,
        ["hour"] = 3600,
        ["day"] = 86400,
        ["week"] = 604800,
        ["month"] = 2628000
    }

    for k, v in SortedPairsByValue(intervals) do
        purchaseCooldownEntry.input:AddChoice(L(k), v)
    end
    
    purchaseCooldownEntry.input:ChooseOptionID(1)

    function purchaseCooldownEntry.input:OnSelect(index, val, data)
        itemObj.info.cooldownType = data
    end

    entryLimitsPanel:AddCell(purchaseCooldownEntry)


    // Item limits per x value
    local purchaseCooldownTimeEntry = vgui.Create("Panel")
    purchaseCooldownTimeEntry:SetWide(ScrW() * 0.124)
    purchaseCooldownTimeEntry:SetTall(sc(75))
    
    purchaseCooldownTimeEntry.Paint = function (self, w, h)
        draw.SimpleText(L"purchase_cooldown_time", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    purchaseCooldownTimeEntry.input = purchaseCooldownTimeEntry:Add("VoidUI.TextInput")
    purchaseCooldownTimeEntry.input:Dock(TOP)
    purchaseCooldownTimeEntry.input:DockMargin(0, sc(30), 0, 0)
    purchaseCooldownTimeEntry.input:SetTall(sc(45))
    purchaseCooldownTimeEntry.input.entry:SetNumeric(true)


    function purchaseCooldownTimeEntry.input.entry:OnValueChange(val)
        if (val and isnumber(tonumber(val))) then
            itemObj.info.cooldownTime = tonumber(val)
        end
	end


    entryLimitsPanel:AddCell(purchaseCooldownTimeEntry)
    
    // Currency
    local currencyEntry = vgui.Create("Panel")
    currencyEntry:SetWide(ScrW() * 0.124)
    currencyEntry:SetTall(sc(75))
    
    currencyEntry.Paint = function (self, w, h)
        draw.SimpleText(string.upper(L"settings_currency"), "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    currencyEntry.input = currencyEntry:Add("VoidUI.Dropdown")
    currencyEntry.input:Dock(TOP)
    currencyEntry.input:DockMargin(0, sc(30), 0, 0)
    currencyEntry.input:SetTall(sc(45))

    local currencyIndex = 0
    for k, v in pairs(VoidCases.Currencies) do
        currencyIndex = currencyIndex + 1
        currencyEntry.input:AddChoice(k)
        if (VoidCases.Config.Currency and k == VoidCases.Config.Currency) then
            currencyEntry.input:ChooseOptionID(currencyIndex)
        end
    end

    if (!VoidCases.Config.Currency) then
        currencyEntry.input:ChooseOptionID(1)
    end

    function currencyEntry.input:OnSelect(index, val)
        itemObj.info.currency = val
    end
    
    entryLimitsPanel:AddCell(currencyEntry)

    -- marketplace_blacklist
    local marketplaceBlacklistEntry = vgui.Create("Panel")
    marketplaceBlacklistEntry:SetWide(ScrW() * 0.124)
    marketplaceBlacklistEntry:SetTall(sc(75))
    
    marketplaceBlacklistEntry.Paint = function (self, w, h)
        draw.SimpleText(L"marketplace_blacklist", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    marketplaceBlacklistEntry.input = marketplaceBlacklistEntry:Add("VoidUI.Switch")
    marketplaceBlacklistEntry.input:Dock(TOP)
    marketplaceBlacklistEntry.input:DockMargin(0, sc(30), 0, 0)
    marketplaceBlacklistEntry.input:SetTall(sc(45))
    marketplaceBlacklistEntry.input:DropdownCompat()

    function marketplaceBlacklistEntry.input:OnSelect(index, val)
        if (index == 1) then
            itemObj.info.marketplaceBlacklist = true
        else
            itemObj.info.marketplaceBlacklist = false
        end
    end

    entryLimitsPanel:AddCell(marketplaceBlacklistEntry)
    

    self.tabs:AddTab(L"item_details", self.itemDetails)
    self.tabs:AddTab(L"item_limitations", self.itemLimits)

    local caseModels = {
        ["models/voidcases/plastic_crate.mdl"] = 1,
        ["models/voidcases/wooden_crate.mdl"] = 2,
        ["models/voidcases/scifi_crate.mdl"] = 3
    }

    self.setEditing = function (item, id)
        self.isEditing = true
        self.editCrate = item
        self.editID = id

        frame:SetTitle(string.format(L"editing", self.editCrate.name) .. " (" .. self.editID .. ")")

        self.delete = buttonContainer:Add("VoidUI.Button")
        self.delete.text = L"delete"
        self.delete:Dock(RIGHT)
        self.delete:SSetWide(200)

        self.delete:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)

        self.delete.DoClick = function ()
            Derma_Query(string.format(L"delete_confirmation", item.name), string.format(L"delete_confirm_title", item.name), L"delete", function ()
                net.Start("VoidCases_DeleteItem")
                    net.WriteUInt(self.editID, 32)
                net.SendToServer()

                for k, v in pairs(self:GetParent().modelsToHide or {}) do
                    if (IsValid(v) and v.icon) then
                        v.icon:SetVisible(true)
                    end
                end

                self:Remove()
            end, L"cancel")
        end

        itemObj = table.Copy(item)
        itemP:SetItem(itemObj)

        loadActionValues(itemObj)

        local actionValue = itemObj.info.actionValue

        nameEntry.input.entry:SetValue(item.name)
        rarityEntry.input:ChooseOptionID(item.info.rarity)

        iconChooseEntry.input:ChooseOptionID(VoidCases.IsModel(itemObj.info.icon) and 2 or 1)
        iconValueEntry.input.entry:SetValue(itemObj.info.icon)
        zoomEntry.input.entry:SetValue(itemObj.info.zoom or 55)
        sellShopEntry.input:ChooseOptionID(itemObj.info.sellInShop and 1 or 2)
        if (itemObj.info.sellInShop) then
            priceEntry.input.entry:SetValue(tonumber(itemObj.info.shopPrice))
        end

        if (itemObj.info.weaponSkin) then
            -- skinChooseEntry.refreshSkins(true)
        end

        -- skinTypeChooseEntry.input:ChooseOptionID(itemObj.info.skinsForAll and 1 or 2)

        -- typeChooseValueEntry.input.entry:SetValue(actionValue)
        permaEntry.input:ChooseOptionID(itemObj.info.isPermanent and 1 or 2)

        groupEntry.input.selectedItems = itemObj.info.requiredUsergroups or {}
        displayGroupEntry.input:ChooseOptionID(item.info.showIfCannotPurchase and 1 or 2)

        local i = 0
        for k, v in pairs(VoidCases.Currencies) do
            i = i + 1
            if (k == itemObj.info.currency) then
                currencyEntry.input:ChooseOptionID(i)
            end
        end
        

        local intervalIDs = {
            [0] = 1,
            [60] = 2,
            [3600] = 3,
            [86400] = 4,
            [604800] = 5,
            [2628000] = 6
        }

        purchaseCooldownEntry.input:ChooseOptionID(intervalIDs[itemObj.info.cooldownType or 0] or 1)
        purchaseCooldownTimeEntry.input.entry:SetValue(itemObj.info.cooldownTime or "")

        marketplaceBlacklistEntry.input:ChooseOptionID(itemObj.info.marketplaceBlacklist and 1 or 2)

        autoEquip.input:ChooseOptionID(item.info.autoEquip and 1 or 2)
    end

end

function PANEL:CreateActionSelectors(entryPanel, getItemObj, setActionType, setActionValue, updateItemObj)
    local itemObj = getItemObj()
    local activeCustomPanel = NULL
    local additionalPanel = NULL
    local fAdditional = nil
    local fAdditionalRefresh = function () fAdditional(getItemObj) end

    timer.Simple(0, function ()
        additionalPanel = vgui.Create("VoidUI.Grid")
        additionalPanel:DockMargin(18, 10, 0, 10)
        additionalPanel:InvalidateParent(true)
        additionalPanel:SetColumns(1)
        additionalPanel:SetHorizontalMargin(45)
        additionalPanel:SetVerticalMargin(40)
        additionalPanel:SSetTall(200)

        entryPanel:AddCell(additionalPanel)
    end)

    self.additionalPanel = additionalPanel
    
    local typeChooseEntry = vgui.Create("Panel")
    typeChooseEntry:SetWide(ScrW() * 0.124)
    typeChooseEntry:SetTall(sc(75))
    
    typeChooseEntry.Paint = function (self, w, h)
        draw.SimpleText(L"item_type", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    typeChooseEntry.input = typeChooseEntry:Add("VoidUI.Dropdown")
    typeChooseEntry.input:Dock(TOP)
    typeChooseEntry.input:DockMargin(0, sc(30), 0, 0)
    typeChooseEntry.input:SetTall(sc(45))

    local valuesIndex = {}

    local fFunc = function (_itemObj)
        itemObj = _itemObj

        -- This is hell, but the shortest solution
        for k, v in pairs(VoidCases.Actions) do
            local index = typeChooseEntry.input:AddChoice(L(k))
            if (k == itemObj.info.actionType) then
                timer.Simple(0, function ()
                    typeChooseEntry.input:ChooseOptionID(index)

                    timer.Simple(0, function ()
                        local tblAction = VoidCases.Actions[itemObj.info.actionType]
                        local varType = tblAction.configData.varType
                
                        if (tblAction.configData.setActive) then
                            tblAction.configData.setActive(activeCustomPanel, itemObj.info.actionValue)
                        else
                            if (varType == 'string' or varType == 'text' or varType == 'number' or varType == 'numeric') then
                                activeCustomPanel.entry:SetValue(itemObj.info.actionValue)
                            else

                            end
                        end
                    end)
                end)
            end

            valuesIndex[k] = index
        end
    end

    local typeChooseValueEntry = vgui.Create("Panel")
    typeChooseValueEntry:SetWide(ScrW() * 0.124)
    typeChooseValueEntry:SetTall(sc(75))

    typeChooseValueEntry.Paint = function (self, w, h)
        local tblAction = VoidCases.Actions[itemObj.info.actionType]
        if (tblAction) then
            draw.SimpleText(L(tblAction.configData.title):upper(), "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    self.typeChooseValueEntry = typeChooseValueEntry

    local this = self

    function typeChooseEntry.input:OnSelect(index, val)
        local actionType = table.KeyFromValue(valuesIndex, index)
        if (!actionType) then return end

        itemObj.info.actionType = actionType
        setActionType(actionType)

        -- Create the custom panel here
        local tblAction = VoidCases.Actions[itemObj.info.actionType]
        if (!tblAction) then
            ErrorNoHalt("Action type " .. itemObj.info.actionType .. " is not loaded!")
            return
        end

        if (IsValid(activeCustomPanel)) then
            activeCustomPanel:Remove()
        end

        if (IsValid(additionalPanel)) then
            additionalPanel:Clear()
        end

        if (tblAction.configData.varType == 'custom') then
            if (!tblAction.configData.customPanel) then
                ErrorNoHalt("Custom panel of type " .. itemObj.info.actionType .. " doesn't have a customPanel function!")
                return
            end

            activeCustomPanel = tblAction.configData.customPanel(typeChooseValueEntry, this, setActionValue, getItemObj, fAdditionalRefresh)
            if (!IsValid(activeCustomPanel)) then
                ErrorNoHalt("Custom panel of type " .. itemObj.info.actionType .. " didnt return anything!")
            end

            if (tblAction.configData.additionalPanel) then
                fAdditional = tblAction.configData.additionalPanel(additionalPanel, this, getItemObj, updateItemObj, this.itemP)
            end
        else
            local varType = tblAction.configData.varType
            -- string is textinput, number is textinput with setnumeric
            if (varType == 'string' or varType == 'text' or varType == 'number' or varType == 'numeric') then
                activeCustomPanel = typeChooseValueEntry:Add("VoidUI.TextInput")
                
                if (varType == 'number' or varType == 'numeric') then
                    activeCustomPanel.entry:SetNumeric(true)
                end

                if (tblAction.configData.fontSize) then
                    activeCustomPanel.entry:SetFont(tblAction.configData.fontSize)
                end

                function activeCustomPanel.entry:OnValueChange(val)
                    setActionValue(val)
                end
            else
                VoidLib.Notify(L"error", string.format("Action %s has an invalid varType of %s!", itemObj.info.actionType, varType), VoidUI.Colors.Red, 5)
            end
        end

        activeCustomPanel:Dock(TOP)
        activeCustomPanel:DockMargin(0, sc(30), 0, 0)
        activeCustomPanel:SetTall(sc(45))
    end

    entryPanel:AddCell(typeChooseEntry)
    entryPanel:AddCell(typeChooseValueEntry)
    
    return fFunc
end


function PANEL:Paint(w, h)
    
end

vgui.Register("VoidCases.ItemCreate", PANEL, "EditablePanel")
