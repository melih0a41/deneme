local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale

// Item purchase panel

local PANEL = {}

function PANEL:InitItem(id, item, isMarketplace, amount, sid64, price, listingID)
    self:MakePopup()

    local rarityColor = VoidCases.RarityColors[tonumber(item.info.rarity)]

    self.sellInfo = self:Add("Panel")
    self.sellInfo:Dock(LEFT)
    self.sellInfo:SSetWide(260)
    self.sellInfo.Paint = function(self, w, h)
        local x, y = self:LocalToScreen(0, 0)

        BSHADOWS.BeginShadow()
            surface.SetDrawColor(VoidUI.Colors.Primary)
            surface.DrawRect(x,y,w,h)
        BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)

        BSHADOWS.BeginShadow()
            surface.SetDrawColor(VoidUI.Colors.Primary)
            surface.DrawRect(x,y,w,60)
        BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)

        draw.SimpleText(L"item_info", "VoidUI.R24", w / 2, 30, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.infoPanel = self.sellInfo:Add("Panel")
    self.infoPanel:Dock(FILL)
    self.infoPanel:SDockMargin(0, 105, 0, 0)

    local bulkBuyPanel = self.infoPanel:Add("Panel")

    local priceEntry = self.infoPanel:Add("Panel")
    priceEntry:Dock(TOP)
    priceEntry:SDockMargin(24, 35, 24, 5)
    priceEntry:SSetTall(50)

    priceEntry.Paint = function (self, w, h)
        draw.SimpleText(L"price", "VoidUI.R26", 0, 0, VoidUI.Colors.GrayDarker, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local price = (!isMarketplace and item.info.shopPrice) or price
        local amountStr = bulkBuyPanel.entry.entry:GetValue()
        local amount = tonumber(amountStr)

        if (amountStr == "") then return end
        if !tonumber(amount) then return end

        local text = VoidCases.FormatMoney(price, item.info.currency)

        if amount != 1 then

            local priceAdd = " (" .. VoidCases.FormatMoney(math.Round(price * amount), item.info.currency) .. ")"
            text = text .. priceAdd
        end 

        draw.SimpleText(text, "VoidCases.I26", 0, sc(24), VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    if (isMarketplace) then
        local amountEntry = self.infoPanel:Add("Panel")
        amountEntry:Dock(TOP)
        amountEntry:SDockMargin(24, 35, 24, 5)
        amountEntry:SSetTall(50)

        amountEntry.Paint = function (self, w, h)
            draw.SimpleText(L"available_amount", "VoidUI.R26", 0, 0, VoidUI.Colors.GrayDarker, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(amount, "VoidCases.I26", 0, sc(24), VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    local itemType = (item.type == VoidCases.ItemTypes.Case and L"case") or (item.type == VoidCases.ItemTypes.Key and L"key") or string.upper(L(item.info.actionType))

    local typeEntry = self.infoPanel:Add("Panel")
    typeEntry:Dock(TOP)
    typeEntry:SDockMargin(24, 35, 24, 5)
    typeEntry:SSetTall(50)

    typeEntry.Paint = function (self, w, h)
        draw.SimpleText(L"item_type", "VoidUI.R26", 0, 0, VoidUI.Colors.GrayDarker, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(itemType, "VoidCases.I26", 0, sc(24), VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local rarity = item.info.rarity
    for k, v in pairs(VoidCases.Rarities) do
        if (v == rarity) then
            rarity = k
            break
        end
    end

    if (!isMarketplace) then
        local rarityEntry = self.infoPanel:Add("Panel")
        rarityEntry:Dock(TOP)
        rarityEntry:SDockMargin(24, 35, 24, 5)
        rarityEntry:SSetTall(50)

        rarityEntry.Paint = function (self, w, h)
            draw.SimpleText(L"rarity", "VoidUI.R26", 0, 0, VoidUI.Colors.GrayDarker, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(rarity, "VoidCases.I26", 0, sc(24), rarityColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    if (item.type == VoidCases.ItemTypes.Case) then
        local keyEntry = self.infoPanel:Add("Panel")
        keyEntry:Dock(TOP)
        keyEntry:SDockMargin(24, 35, 24, 5)
        keyEntry:SSetTall(50)

        keyEntry.Paint = function (self, w, h)
            draw.SimpleText(L"requires_key", "VoidUI.R26", 0, 0, VoidUI.Colors.GrayDarker, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(item.info.requiresKey and L"yes" or L"no", "VoidCases.I26", 0, sc(24), VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    if (item.type == VoidCases.ItemTypes.Key) then
        local opensEntry = self.infoPanel:Add("Panel")
        opensEntry:Dock(TOP)
        opensEntry:SDockMargin(24, 35, 24, 5)
        opensEntry:SSetTall(250)

        opensEntry.Paint = function (self, w, h)
            draw.SimpleText(L"unlocks_cases", "VoidUI.R26", 0, 0, VoidUI.Colors.GrayDarker, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            local currY = sc(24)
            local i = 1
            for k, v in pairs(item.info.unlocks) do
                if (!VoidCases.Config.Items[k]) then continue end

                local currText = (i < 8 and VoidCases.Config.Items[k].name) or "and " .. table.Count(item.info.unlocks) - i + 1 .. " more.."
                draw.SimpleText("- " .. currText, "VoidCases.I26", 0, currY, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                if (i >= 8) then break end

                currY = currY + sc(28)
                i = i + 1
            end
        end
    end

    bulkBuyPanel:Dock(BOTTOM)
    bulkBuyPanel:SDockMargin(24, 35, 24, 10)
    bulkBuyPanel:SSetTall(80)

    bulkBuyPanel.Paint = function (self, w, h)
        draw.SimpleText(L"bulk_purchase", "VoidUI.R24", 0, 0, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    bulkBuyPanel.entry = bulkBuyPanel:Add("VoidUI.TextInput")
    bulkBuyPanel.entry:Dock(BOTTOM)
    bulkBuyPanel.entry:SSetTall(40)
    bulkBuyPanel.entry:SDockMargin(0, 30, 0, 8)
    bulkBuyPanel.entry:SetNumeric(true)
    bulkBuyPanel.entry:SetValue(1)

    self.nav = self:Add("Panel")
    self.nav:Dock(TOP)
    self.nav:SSetTall(60)

    self.nav.Paint = function (self, w, h)
        local x, y = self:LocalToScreen(0, 0)

        BSHADOWS.BeginShadow()
            surface.SetDrawColor(rarityColor.r, rarityColor.g, rarityColor.b, 255)
            surface.DrawRect(x,y,w,h)
        BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)

        draw.SimpleText(item.name, "VoidUI.R48", w/2, h/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.close = self.nav:Add("DButton")
    self.close:Dock(RIGHT)
    self.close:SDockMargin(0, 15, 15, 15)
    self.close:SetText("")
    self.close:SSetWide(30)

    self.close.Paint = function (self, w, h)
        surface.SetDrawColor(VoidUI.Colors.White)
        surface.SetMaterial(VoidCases.Icons.CloseX)
        surface.DrawTexturedRect(0,0,w,h)
    end

    self.close.DoClick = function ()
        for k, v in pairs(self:GetParent().modelsToHide or {}) do
            if (IsValid(v) and v.icon) then
                v.icon:SetVisible(true)
            end
        end

        self:Remove()
    end

    self.panel = self:Add("Panel")
    self.panel:Dock(FILL)
    
    self.panel.Paint = function (self, w, h)
        surface.SetDrawColor(rarityColor.r, rarityColor.g, rarityColor.b, 100)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(VoidUI.Colors.White)
        surface.SetMaterial(VoidCases.Icons.Layer)
        surface.DrawTexturedRect(0,0,w,h)

        if (item.type == VoidCases.ItemTypes.Case) then
            draw.SimpleText(L"winnable_items", "VoidUI.B32", 34, 35, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    if (VoidCases.IsModel(item.info.icon) and item.type != VoidCases.ItemTypes.Case) then
        self.icon = self.panel:Add("DModelPanel")
        self.icon:Dock(FILL)
        self.icon:SDockMargin(80, 80, 80, 80)

        self.icon:SetModel(item.info.icon or "models/voidcases/plastic_crate.mdl")

        function self.icon:LayoutEntity() end

        local mn, mx = self.icon.Entity:GetRenderBounds()
        local size = 0
        size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
        size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
        size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

        self.icon:SetFOV( item and item.info.zoom or 55 )
        self.icon:SetCamPos( Vector( size, size, size ) )
        self.icon:SetLookAt( ( mn + mx ) * 0.5 )

        local isSkin = (item.info.actionType and item.info.actionType == "weapon_skin") or false
        local skinMat = nil
        if (isSkin and SH_EASYSKINS) then
            skinMat = SH_EASYSKINS.GetSkin(tonumber(item.info.weaponSkin)).material.path

            SH_EASYSKINS.ApplySkinToModel(self.icon.Entity, skinMat)
        end

        -- this fixes the depth issue
        function self.icon:DrawModel()
            local curparent = self
            local leftx, topy = self:LocalToScreen( 0, 0 )
            local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
            while ( curparent:GetParent() != nil ) do
                curparent = curparent:GetParent()

                local x1, y1 = curparent:LocalToScreen( 0, 0 )
                local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

                leftx = math.max( leftx, x1 )
                topy = math.max( topy, y1 )
                rightx = math.min( rightx, x2 )
                bottomy = math.min( bottomy, y2 )
                previous = curparent
            end

            -- Causes issues with stencils, but only for some people?
            render.ClearDepth() -- this is uncommented

            render.SetScissorRect( leftx, topy, rightx, bottomy, true )

            local ret = self:PreDrawModel( self.Entity )
            if ( ret != false ) then
                self.Entity:DrawModel()
                self:PostDrawModel( self.Entity )
            end

            render.SetScissorRect( 0, 0, 0, 0, false )
        end

        if (item and item.info.caseColor) then
            local c = item.info.caseColor
            local color = Color(c.r, c.g, c.b)

            self.icon.Entity:SetNWVector("CrateColor", color:ToVector())
            self.icon.Entity:SetNWString("CrateLogo", item.info.caseIcon)
        end
    elseif (item.type != VoidCases.ItemTypes.Case) then
        self.icon = self:Add("DImage")
		self.icon:Dock(FILL)
		self.icon:SDockMargin(180, 110, 180, 110)
		self.icon:SetZPos(5)

		VoidCases.FetchImage(item.info.icon, function (res)
			self.icon:SetImage("data/voidcases/"..item.info.icon..".png")
		end)
    else
		
	if (item and item.info.actionType == "weapon") then
		-- csgo knives skin compatibility
		local wepInfo = weapons.Get(item.info.actionValue)
		if (wepInfo and wepInfo.SkinIndex and isnumber(wepInfo.SkinIndex)) then
			self.icon.Entity:SetSkin(wepInfo.SkinIndex)
		end
	end
        // Show available items
        self.itemGrid = self.panel:Add("VoidCases.ThreeGrid")
        self.itemGrid:Dock(FILL)
        self.itemGrid:SDockMargin(35, 85, 7, 55)
        self.itemGrid:InvalidateParent(true)
        self.itemGrid:SetColumns(5)
        self.itemGrid:SetHorizontalMargin(30)
        self.itemGrid:SetVerticalMargin(25)

        local prevItem = item

        local chanceSum = VoidCases.GetChanceSum(item.info.unboxableItems)

        for k, v in SortedPairsByValue(item.info.unboxableItems) do
            local item = VoidCases.Config.Items[k]
            if (!item) then continue end

            local rarityColor = VoidCases.RarityColors[tonumber(item.info.rarity)]
            local chancePercentage = VoidCases.GetChance(v, chanceSum, true)

            if (!item or !item.info) then continue end

            local isMystery = (prevItem.info.mysteryItems and prevItem.info.mysteryItems[k]) or false

            local itemPanel = vgui.Create("VoidCases.Item")
            itemPanel:SSetSize(120, 120)

            if (isMystery) then
                local mysteryItemTbl = table.Copy(item)
                mysteryItemTbl.info.icon = "3Brc7ft"
                itemPanel:SetItem(mysteryItemTbl, true, true)
            else
                itemPanel:SetItem(item, nil, true)
            end

            itemPanel.itemOverlay.Paint = function (self, w, h)
                local panelW, panelH = sc(1600), sc(900)

                draw.RoundedBoxEx(6, 0, w-w*0.18, w, w*0.18, rarityColor, false, false, true, true)

                local nameFont = "VoidUI.R20"
                if (#item.name > 15 && !isMystery) then
                    nameFont = "VoidUI.R14"
                end

                local itemName = item.name
                if (isMystery) then
                    itemName = L"mystery_item"
                end
                draw.SimpleText(itemName, nameFont, w/2, w - w*0.18/2-2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                if VoidCases.Config.PublicChances then
                    local statusColor = VoidUI.Colors.Gray
                    local statusY = w*0.14 + sc(5)
                    local statusWidth = surface.GetTextSize(chancePercentage) + 5
    
                    if (chancePercentage and chancePercentage != "") then
                        draw.RoundedBox(8, sc(5), sc(5), statusWidth, sc(24), VoidUI.Colors.GrayOverlay)
                        draw.SimpleText(chancePercentage, "VoidUI.R16", sc(5) + statusWidth / 2, statusY / 2 + sc(7), statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end

            itemPanel.Paint = function (self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, rarityColor)
                surface.SetDrawColor(255,255,255)
                surface.SetMaterial(tonumber(item.info.rarity) != 1 && VoidCases.Icons.LayerItem || VoidCases.Icons.LayerItemNormal)
                surface.DrawTexturedRect(4,4,w-8,h-8)
            end

            self.itemGrid:AddCell(itemPanel)
        end
    end

    self.buttonBar = self.panel:Add("Panel")
    self.buttonBar:Dock(BOTTOM)
    self.buttonBar:SSetTall(58)
    self.buttonBar:SDockMargin(0, 0, 45, 30)

    local isOwn = sid64 and sid64 == LocalPlayer():SteamID64()

    --cancel_listing

    self.purchaseButton = self.buttonBar:Add("VoidUI.Button")
    self.purchaseButton:Dock(RIGHT)
    self.purchaseButton:SSetWide(180)
    self.purchaseButton:SetText(isOwn and L"cancel_listing" or L"purchase") 

    if (isOwn) then
        self.purchaseButton:SetColor(VoidUI.Colors.Red)
        self.purchaseButton:SSetWide(260)
    end

    self.purchaseButton.DoClick = function ()
        local amountStr = bulkBuyPanel.entry.entry:GetValue()
        if (amountStr == "") then return end
        
        local amount = tonumber(amountStr)

        if (!isOwn) then
            if (isMarketplace) then
                net.Start("VoidCases_PurchaseMarketplaceItem")
                    net.WriteUInt(listingID, 32)
                    net.WriteUInt(amount, 32)
                net.SendToServer()
            else
                net.Start("VoidCases_PurchaseItem")
                    net.WriteUInt(id or item.id, 32)
                    net.WriteUInt(amount, 32)
                net.SendToServer()
            end
        else
            net.Start("VoidCases.CancelListing")
                net.WriteUInt(listingID, 32)
            net.SendToServer()
        end

        for k, v in pairs(self:GetParent().modelsToHide or {}) do
            if (IsValid(v) and v.icon) then
                v.icon:SetVisible(true)
            end
        end

        self:Remove()
    end
end

function PANEL:Think()
    self:MoveToFront()
end

function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen(0, 0)

    BSHADOWS.BeginShadow()
        surface.SetDrawColor(VoidUI.Colors.Primary)
        surface.DrawRect(x,y,w,h)
    BSHADOWS.EndShadow(1, 1, 1, 150, 0, 0)
end

vgui.Register("VoidCases.ItemPurchase", PANEL, "EditablePanel")
