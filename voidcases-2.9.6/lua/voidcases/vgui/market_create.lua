
local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale



// Create market listing panel

local PANEL = {}

function PANEL:Init()
    local itemObj = {
        item = nil,
        amount = 0,
        cost = 0,
    }

    self:SetTitle(L"sell_item")
    self:MakePopup()
    self.activeItem = nil

    local container = self:Add("Panel")
    container:Dock(FILL)
    container:SDockMargin(30, 20, 30, 20)

    local grid = container:Add("VoidUI.ElementGrid")
    grid:Dock(FILL)

    self.price = grid:AddElement(L"price_per_item", "VoidUI.TextInput")
    self.price.entry:SetNumeric(true)

    function self.price.entry:OnValueChange(val)
		itemObj.cost = tonumber(val)
	end

    self.amount = grid:AddElement(L"amount", "VoidUI.TextInput")
    self.amount.entry:SetNumeric(true)

    function self.amount.entry:OnValueChange(val)
		itemObj.amount = tonumber(val)
	end
    self.amount.entry:SetValue(1)

    local buttonContainer = container:Add("Panel")
    buttonContainer:Dock(BOTTOM)
    buttonContainer:SetTall(50)
    buttonContainer:SDockMargin(40, 20, 40, 0)

    local itemsPanel = container:Add("Panel")
    itemsPanel:Dock(BOTTOM)
    itemsPanel:SetTall(320)
    itemsPanel:DockMargin(0, 0, 0, 0)

    itemsPanel.Paint = function (self, w, h)
        local curr = table.GetKeys(VoidCases.Currencies)[1]
        if (itemObj.item and VoidCases.Config.Items[itemObj.item].info.currency) then
            curr = VoidCases.Config.Items[itemObj.item].info.currency
        end
        local strCurr = itemObj.item and "(" .. curr .. " " .. L("settings_currency"):lower() .. ")" or ""

        draw.SimpleText(L"choose_item" .. " " .. strCurr, "VoidUI.B24", 0, 10, VoidUI.Colors.GrayText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    
    itemsPanel.items = itemsPanel:Add("VoidUI.Grid")
    itemsPanel.items:Dock(FILL)
    itemsPanel.items:DockMargin(0, 30, 0, 0)

    itemsPanel.items:InvalidateParent(true)

    itemsPanel.items:SetColumns(5)
    itemsPanel.items:SetHorizontalMargin(12)
    itemsPanel.items:SetVerticalMargin(15)

    for k, v in pairs(VoidCases.Inventory) do

        if (!tonumber(v) or tonumber(v) < 1) then continue end

        local it = VoidCases.Config.Items[k]
        if (!it) then continue end

        if (it.info.marketplaceBlacklist) then continue end

        // Existing
        local item = itemsPanel.items:Add("VoidCases.Item")
        item:SetSize(95, 95)

        item:SetItem(it, !VoidCases.IsModel(it.info.icon), true)

        item.Paint = function (self, w, h)
            local x, y = self:LocalToScreen(0,0)

            local selCol = VoidCases.RarityColors[tonumber(it.info.rarity)]
            if (itemObj.item == k) then
                selCol = VoidUI.Colors.White
            end

            draw.RoundedBox(6, 0, 0, w, h, selCol)

            surface.SetDrawColor(255,255,255)
            surface.SetMaterial(tonumber(it.info.rarity) != 1 && VoidCases.Icons.LayerItem || VoidCases.Icons.LayerItemNormal)
            surface.DrawTexturedRect(4,4,w-8,h-8)
        end


        item.itemOverlay.Paint = function (self, w, h)

            local selCol = VoidCases.RarityColors[tonumber(it.info.rarity)]
            local textCol = VoidUI.Colors.White
            if (itemObj.item == k) then
                selCol = VoidUI.Colors.White
                textCol = VoidUI.Colors.Black
            end

            draw.RoundedBoxEx(4, 0, h-w*0.2, w, w*0.2, selCol, false, false, true, true)
            
            local name = it.name
            local nameFont = "VoidUI.R16"
            if (#it.name > 11) then
                nameFont = "VoidUI.R14"

                if (#it.name > 15) then
                    name = string.sub(name, 1, 13) .. ".."
                end
            end

            draw.SimpleText(name, nameFont, w/2, h-w*0.2 + w*0.1-1, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local itemB = item:Add("DButton")
        itemB:SetZPos(30)
        itemB:Dock(FILL)
        itemB:SetText("")
        itemB.Paint = function (self, w, h)

        end

        itemB.DoClick = function ()
            itemObj.item = tonumber(k)
            self.activeItem = tonumber(k)
        end

        itemsPanel.items:AddCell(item, 95, 95)
    end

    local sellButton = buttonContainer:Add("VoidUI.Button")
    sellButton:Dock(LEFT)
    sellButton:SetWide(200)
    sellButton.text = L"sell_item"
    sellButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)

    sellButton.Think = function ()
        sellButton:SetDisabled(!itemObj.cost or itemObj.cost == 0 or itemObj.amount == 0 or !itemObj.item or itemObj.amount > VoidCases.Inventory[itemObj.item] )
    end
    
    sellButton.DoClick = function ()
        if (!itemObj.item) then return end
        if (itemObj.cost == 0) then return end
        if (itemObj.amount == 0) then return end
        
        // Net message thing
        net.Start("VoidCases_CreateMarketplaceListing")
            net.WriteUInt(itemObj.item, 32)
            net.WriteUInt(itemObj.amount, 32)
            net.WriteUInt(itemObj.cost, 32)
        net.SendToServer()

        self:Remove() 
    end

    local cancelButton = buttonContainer:Add("VoidUI.Button")
    cancelButton:Dock(RIGHT)
    cancelButton:SetWide(200)
    cancelButton.text = L"cancel"
    cancelButton:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)
    
    cancelButton.DoClick = function ()
        self:Remove() 
    end


end

function PANEL:PaintOver(w, h)
    if (!self.activeItem) then return end

    local count = VoidCases.Inventory[self.activeItem]
    if (count) then
        draw.SimpleText(L("available_amount") .. ": " .. count, "VoidUI.B20", sc(315), sc(170), VoidUI.Colors.GrayText, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end
end


function PANEL:Think()
    //self:MoveToFront()
end

vgui.Register("VoidCases.MarketCreate", PANEL, "VoidUI.Frame")