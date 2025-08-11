
VoidCases.Icons = {
	Home = Material("voidcases/home.png"),
	Shop = Material("voidcases/shop.png"),
	Market = Material("voidcases/market.png"),
	Inventory = Material("voidcases/inventory.png"),
	Settings = Material("voidcases/settings.png"),
	Close = Material("voidcases/close.png"),
	CloseX = Material("voidcases/close-x.png"),
	Layer = Material("voidcases/layer.png"),
	LayerItem = Material("voidcases/layeritem.png"),
	LayerItemNormal = Material("voidcases/layeritemn.png"),
	Key = Material("voidcases/key.png"),
	NoKey = Material("voidcases/key-no.png"),
	EditCases = Material("voidcases/edit-cases.png"),
	AddCase = Material("voidcases/add-circle.png"),
	PlusCircle = Material("voidcases/add-circle-sm.png"),
	Lock = Material("voidcases/lock.png"),
	PlusSmall = Material("voidcases/plus.png"),
	Rename = Material("voidcases/rename.png"),
	Trade = Material("voidcases/trade.png")
}

VoidCases.AccentColor = Color(188, 136, 45)

// Too much work to export them in same size :D
VoidCases.IconSizes = {
	Home = {35,34},
	Shop = {36,36},
	Market = {35,32},
	Settings = {40,40},
	Inventory = {35,35},
	Settings = {40,40},
	EditCases = {35,34},
	Trade = {33,34}
}

VoidCases.CurrencySymbols = {
	["Basewars"] = "$",
	["NutScript"] = "$",
	["Helix"] = "$",
	["xStore"] = "$",
	["Pointshop 1"] = "Pts",
	["Pointshop 2 (Standard)"] = "Pts",
	["Pointshop 2 (Premium)"] = "PPts",
	["mTokens"] = "Tok",
	["Bricks Credits"] = "Pts",
	["Pulsar Credits"] = "Pts", -- Legacy Pulsar Credits
	["Pulsar Store Credits"] = "Pts",
}

function draw.drawCircle(x, y, r, step, cache)
    local positions = {}

    for i = 0, 360, step do
        table.insert(positions, {
            x = x + math.cos(math.rad(i)) * r,
            y = y + math.sin(math.rad(i)) * r
        })
    end

	draw.NoTexture()

    return (cache and positions) or surface.DrawPoly(positions)
end

function VoidCases.FormatMoney(money, currency)
	local priceFont = "VoidUI.R24"
	local priceText = tostring(money)

	money = tonumber(money) or 0 -- fallback in case something bad happend

	if (money <= 0) then
		return "FREE", priceFont
	end

	if (!currency) then
		currency = VoidCases.Config.Currency or table.GetKeys(VoidCases.Currencies)[1]
	end

	local abbreviation = ""

	-- Trillions / Billions / Millions
	if (#priceText > 12) then
		priceFont = "VoidUI.R20"
		priceText = math.Round(money / 1000000000000, 2)
		abbreviation = " Tril"
	elseif (#priceText > 9) then
		priceFont = "VoidUI.R22"
		priceText = math.Round(money / 1000000000, 2)
		abbreviation = " Bil"
	elseif (#priceText > 6) then
		priceText = math.Round(money / 1000000, 2)
		abbreviation = " Mil"
	end
	
	if currency == "DarkRP" then
		priceText = DarkRP.formatMoney(money)
	else
		local currencySymbol = VoidCases.CurrencySymbols[currency] or "$"
		priceText = priceText .. abbreviation .. " " .. currencySymbol 
	end

	return priceText, priceFont
end

surface.CreateFont("VoidCases.I" .. 24, {
	font = "Montserrat",
	size = ScrH() * 24/1080,
	italic = true,
})

surface.CreateFont("VoidCases.I" .. 26, {
	font = "Montserrat",
	size = ScrH() * 26/1080,
	italic = true,
})

surface.CreateFont("VoidCases.I" .. 30, {
	font = "Montserrat",
	size = ScrH() * 30/1080,
	italic = true,
})

surface.CreateFont("VoidCases.I" .. 34, {
	font = "Montserrat",
	size = ScrH() * 30/1080,
	italic = true,
})

local L = VoidCases.Lang.GetPhrase

function VoidCases.IsModel(model)
	if (model == nil) then return false end
	local result = string.find(model, "models/") and string.find(model, ".mdl")
	return result
end


//////////////////
///  Elements  ///
//////////////////

local placeholderMat = "models/voidcases/plastic_crate/logo"

local sc = VoidUI.Scale

// Item

local PANEL = {}

function PANEL:Init()
	self:SetWide(250) //250

	self.item = nil

	local intervals = {
        [60] = "minute",
        [3600] = "hour",
        [86400] = "day",
        [604800] = "week",
        [2628000] = "month"
    }

	local transparentCol = Color(0,0,0,190)
	local stripeCol = Color(0,0,0,210)

	local green = VoidUI.Colors.Green
	local goodColor = Color(green.r, green.g, green.b, 170)
	local goodHoveredColor = Color(green.r, green.g, green.b, 240)

	local this = self

	self.canAfford = true

	self.itemOverlay = self:Add("Panel")
	self.itemOverlay:Dock(FILL)
	self.itemOverlay:SetZPos(10)
	self.itemOverlay.Paint = function (self, w, h)
		local x, y = self:LocalToScreen(0,0)

		self.item = self:GetParent().item

		if (!self.item) then return end

		local rarityName = nil
        for k, v in pairs(VoidCases.Rarities) do
            if (v == tonumber(self.item.info.rarity)) then
                rarityName = k
            end
        end
		local rarityNum = tonumber(self.item.info.rarity)
		local rarityColor = VoidCases.RarityColors[rarityNum]
		if (!rarityColor) then
			ErrorNoHalt("Rarity color is nil! Fallbacking to default color!")
			rarityColor = VoidUI.Colors.Primary
		end

		draw.RoundedBoxEx(8, 0, 0, w, w*0.14, rarityColor, true, true, false, false)
		if (this.showMoney != false or this.isShowcase) then
			draw.RoundedBoxEx(0, 0, h-sc(50), w, sc(40), stripeCol, false, false, true, true)
		end

		-- Count start

		local strAmount = tostring(this.amount)

		surface.SetFont("VoidUI.B20")
		local amountWidth = surface.GetTextSize(strAmount) + 25
		local amountHeight = 24
		local amountX = w-amountWidth-sc(5)
		local amountY = w*0.14+sc(5)

		if (this.isTrading) then
			draw.RoundedBox(8, amountX, amountY, amountWidth, amountHeight, VoidUI.Colors.GrayOverlay)
            draw.SimpleText(strAmount .. "x", "VoidUI.B20", w-amountWidth-sc(5)+amountWidth/2, w*0.14+sc(5)+amountHeight/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			amountX = amountX - sc(45)
		end

		-- Count end

		-- Key icon start

		if (self.item.type == VoidCases.ItemTypes.Case) then
			local caseWidth = sc(45)
			local keyWidth = caseWidth * 0.6

			draw.RoundedBox(8, amountX-sc(5), amountY, caseWidth, amountHeight, VoidUI.Colors.GrayOverlay)

			local addY = (self.item.info.requiresKey and 3) or 0

			surface.SetMaterial( (self.item.info.requiresKey and VoidCases.Icons.Key) or VoidCases.Icons.NoKey )
			surface.SetDrawColor(VoidUI.Colors.White)
			surface.DrawTexturedRect(amountX-sc(5)-caseWidth/2-keyWidth/2+caseWidth, amountY + addY + sc(5), keyWidth, (self.item.info.requiresKey and ScrH() * 0.01018) or ScrH() * 0.01296)
		end

		-- Key icon end

		-- Status start

		local statusText = this.statusText or ""
		local statusColor = this.statusColor or VoidUI.Colors.Red
		local statusX = this.statusX or sc(5)
		local statusY = this.statusY or amountY

		-- Status set

		local statusWidth = surface.GetTextSize(statusText) + 5

		if (self.item.type == VoidCases.ItemTypes.Unboxable) then
			if (self.item.info.actionType == "weapon" and self.item.info.isPermanent and this.showMoney != false) then
				statusWidth = surface.GetTextSize(statusText) + 5

				local permaWidth = sc(60)
				draw.RoundedBox(8, statusX+statusWidth+sc(5), statusY, permaWidth, amountHeight, VoidUI.Colors.GrayOverlay)
				draw.SimpleText("PERMA", "VoidUI.R16", statusX+permaWidth/2+statusWidth+sc(5), statusY+amountHeight/2-1, VoidUI.Colors.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		if (statusText and statusText != "") then
			draw.RoundedBox(8, statusX, statusY, statusWidth, amountHeight, VoidUI.Colors.GrayOverlay)
			draw.SimpleText(statusText, "VoidUI.R16", statusX+statusWidth/2, statusY+amountHeight/2, statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- Status end

		-- Rarity start

		if (this.showMoney != false or this.isShowcase) then

		if (!this.isShowcase) then
			draw.SimpleText(L"rarity", "VoidUI.R16", sc(20), h-sc(30), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		surface.SetFont("VoidUI.R20")
		local rarityText = rarityName
		local rarityStart = w-sc(20)
		local rarityWidth = surface.GetTextSize(rarityText) + 30
		local rarityBoxX = rarityStart - rarityWidth
		local rarityBoxHeight = sc(30)

		if (this.isShowcase) then
			rarityBoxX = w / 2 - rarityWidth / 2
		end

		draw.RoundedBox(14, rarityBoxX, h-sc(30)-rarityBoxHeight/2, rarityWidth, rarityBoxHeight, transparentCol)
		draw.SimpleText(rarityText, "VoidUI.R20", rarityBoxX + rarityWidth/2, h-sc(30), rarityColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		end

		-- Rarity end

		local itemNameFont = "VoidUI.R24"
		if (#self.item.name > 19) then
			itemNameFont = "VoidUI.R18"
		end

		if (w < sc(150)) then
			itemNameFont = "VoidUI.R18"

			if (#self.item.name > 19) then
				itemNameFont = "VoidUI.R16"
			end
		end

		draw.SimpleText(self.item.name, itemNameFont, w/2, w*0.14/2-2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- Money start

		if (this.showMoney != false and self.item.info.sellInShop and isnumber(tonumber(self.item.info.shopPrice)) or this.marketMoney) then
			local moneyStr, moneyFont = VoidCases.FormatMoney(this.marketMoney or self.item.info.shopPrice, self.item.info.currency)

			surface.SetFont(moneyFont)
			local moneyTall = sc(30)
			local moneySize = surface.GetTextSize(moneyStr) + 10
			local moneyX = w - sc(10) - moneySize
			local moneyY = h - sc(50) - sc(5) - moneyTall

			local moneyColor = (this.b and this.b:IsHovered()) and goodHoveredColor or goodColor
			if (!this.canAfford) then
				moneyColor = VoidUI.Colors.Red
			end

			draw.RoundedBox(8, moneyX, moneyY, moneySize, moneyTall, moneyColor)
			draw.SimpleText(moneyStr, moneyFont, moneyX + moneySize / 2, moneyY + moneyTall / 2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- Money end

	end
end

function PANEL:InitItemIcon(model)
	self.icon = nil
end

function PANEL:SetItemIcon(model, typ, smIcon)
	if (!model or model == "") then return end
	if (!typ or typ == nil) then
		typ = "model"
	end
	if (typ == "model") then
		if (self.icon and IsValid(self.icon)) then
			self.icon:Remove()
		end
		
		if (self.d2dunbox) then
			-- self.icon = self:Add("Panel")
			-- self.icon:Dock(FILL)

			-- self.icon.entModel = ClientsideModel(model, RENDERGROUP_OTHER)
			-- self.icon.entModel:SetNoDraw(true)

			--self.icon.Entity:DrawModel()
		else
			self.icon = self:Add("DModelPanel")
			self.icon:Dock(FILL)
			if (smIcon) then
				self.icon:DockMargin(2,2,2,2)
			else
				self.icon:DockMargin(10,30,10,10)
			end
			self.icon:SetZPos(5)

			self.icon:SetModel(model or "models/voidcases/plastic_crate.mdl")
			if (!IsValid(self.icon.Entity)) then 
				VoidCases.Print("Tried to set model, but model not valid! (" .. model .. ")")
				return
			end
			
			
			local this = self
			function self.icon:LayoutEntity(ent) 
				if (this.b and this.b:IsHovered()) then
					local ang = ent:GetAngles().y + RealFrameTime() * 100
					if (ang > 360) then
						ang = 0
					end
					ent:SetAngles( Angle(0, ang, 0) )
				end
			end

			local mn, mx = self.icon.Entity:GetRenderBounds()
			local size = 0
			size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
			size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
			size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

			self.icon:SetFOV( self.item.info.zoom or 55 )
			self.icon:SetCamPos( Vector( size, size, size ) )
			self.icon:SetLookAt( ( mn + mx ) * 0.5 )

			if (self.item.type == VoidCases.ItemTypes.Case) then
				self.icon.Entity:SetAngles(Angle(0, 25, 0))
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
			
			if (self.item and self.item.info.actionType == "weapon") then
				-- csgo knives skin compatibility
				local wepInfo = weapons.Get(self.item.info.actionValue)
				if (wepInfo and wepInfo.SkinIndex and isnumber(wepInfo.SkinIndex)) then
					self.icon.Entity:SetSkin(wepInfo.SkinIndex)
				end
			end

			if (self.item and self.item.info.caseColor) then
				local c = self.item.info.caseColor
				local color = Color(c.r, c.g, c.b)
				
				if (!VoidCases.CachedMaterials[self.item.info.caseIcon]) then
					VoidCases.FetchImage(self.item.info.caseIcon, function () 
					end)
				end

				self.icon.Entity:SetNWVector("CrateColor", color:ToVector())
				self.icon.Entity:SetNWString("CrateLogo", self.item.info.caseIcon)
			end

			if (self.item.info.actionType == "weapon_skin") then
				local easySkin = SH_EASYSKINS.GetSkin(self.item.info.weaponSkin)
				if (easySkin) then
					SH_EASYSKINS.ApplySkinToModel(self.icon.Entity, easySkin.material.path)
				end
			end
		end


	else
		if (self.icon and IsValid(self.icon)) then
			self.icon:Remove()
		end

		self.icon = self:Add("DImage")
		self.icon:Dock(FILL)
		if (smIcon) then
			self.icon:DockMargin(15,15,15,15)
		else
			self.icon:DockMargin(45,45,45,45)
		end
		self.icon:SetZPos(5)

		VoidCases.FetchImage(model, function (res)
			self.icon:SetImage("data/voidcases/"..model..".png" or placeholderMat)
		end)

		
	end
	
end


function PANEL:SetItem(item, typ, smIcon)
	self.item = item

	if (!typ) then
		if (VoidCases.IsModel(item.info.icon)) then
			typ = "model"
		else
			typ = "icon"
		end
	end

	timer.Simple(0, function ()
		if (!IsValid(self)) then return end

		local currency = VoidCases.Currencies[item.info.currency]
		if (currency) then
			local didSucceed, totalMoney = pcall(currency.getFunc, LocalPlayer())
			local enteredMoney = tonumber(self.marketMoney or item.info.shopPrice or 0) or 0

			if (didSucceed and tonumber(totalMoney) < enteredMoney) then
				self.canAfford = false
			end
		end
	end)

	self:SetItemIcon(item.info.icon, typ, smIcon)
end

function PANEL:Paint(w, h)
	if (!self.item) then return end
	local x, y = self:LocalToScreen(0, 0)

	
	if (self.showMoney != false and (self:IsHovered() or self.itemOverlay:IsHovered() or (self.b and self.b:IsHovered())) and ((y > 335 and y < 900-230) or !self.isList)) then
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


vgui.Register("VoidCases.Item", PANEL, "DPanel")

-- local PANEL = {}

-- function PANEL:Init()
-- 	self:Dock(FILL)

-- 	local sbar = self:GetVBar()

-- 	sbar.Paint = function (self, w, h) end

-- 	sbar.btnGrip.Paint = function (self, w, h)
-- 		surface.SetDrawColor(VoidUI.Colors.Primary)
-- 		surface.DrawRect(0,0,w,h)
-- 	end

-- 	sbar:SetHideButtons(true)
-- end

-- vgui.Register("VoidUI.ScrollPanel", PANEL, "DScrollPanel")

// Editable category name

local PANEL = {}

function PANEL:Init()

	self.isNew = false
	self.placeholderValue = ""

	self.pencilSpacing = 15

	self.entry = self:Add("DTextEntry")
	self.entry:Dock(TOP)
	self.entry:SetTall(34)

	self.entry:SetFont("VoidUI.R32")
	self.entry:SetTextColor(VoidUI.Colors.Gray)
	self.entry:SetCursorColor(VoidUI.Colors.White)

	self.entry:SetPaintBackground(false)

	function self.entry:OnFocusChanged(gained)
		local textCol = (gained and VoidUI.Colors.White) or VoidUI.Colors.Gray
		self:SetTextColor(textCol)
	end

	local paintFunc = self.entry.Paint

	local this = self

	self.entry.Paint = function (self, w, h)
		paintFunc(self, w, h)

		surface.SetFont(this.entry:GetFont())
		local intTextWidth, intTextHeight = surface.GetTextSize(self:GetValue())

		if (self:GetParent().isNew or self:GetValue() == "") then
			intTextWidth = surface.GetTextSize("ADD NEW CATEGORY...")
		end

		local intIconX = intTextWidth + this.pencilSpacing
		surface.SetMaterial(VoidCases.Icons.Rename)
		surface.SetDrawColor(VoidUI.Colors.White)
		surface.DrawTexturedRect(intIconX, h/2-7, 16, 16)
	end
end

function PANEL:SetNew(bool)
	self.isNew = bool
end

function PANEL:Paint() end

function PANEL:SetValue(val)
	if (self.isNew) then
		self.entry:SetPlaceholderText(val)
	else
		self.entry:SetValue(val)
	end
end

vgui.Register("VoidCases.EditableCategory", PANEL, "DPanel")

// Create new popup

local PANEL = {}

function PANEL:Init()
	self:SetSize(280,180)
	self:MakePopup()

	self.category = 0

	local btnPanel = self:Add("Panel")
	btnPanel:Dock(FILL)
	btnPanel:DockMargin(0, 70, 0, 0)

	local tbl = {}
	tbl[1] = {"CASE", "VoidCases.CaseCreate"}
	tbl[2] = {"KEY", "VoidCases.KeyCreate"}
	tbl[3] = {"ITEM", "VoidCases.ItemCreate"}
	
	for i=1,3 do
		local button = btnPanel:Add("DButton")
		button:Dock(LEFT)
		button:SetText("")
		button:SetWide(280/3)

		local el = tbl[i]

		button.Paint = function (self, w, h)
			surface.SetDrawColor(!self:IsHovered() and VoidUI.Colors.Primary or VoidUI.Colors.Hover)
			surface.DrawRect(0,0,w,h)

			surface.SetDrawColor(self:IsHovered() and VoidUI.Colors.White or VoidUI.Colors.GrayDarker)
			surface.SetMaterial(VoidCases.Icons.PlusCircle)
			surface.DrawTexturedRect(w/2-20, 15, 40, 40)

			draw.SimpleText(el[1], "VoidUI.R28", w/2, h-22, self:IsHovered() and VoidUI.Colors.White or VoidUI.Colors.GrayDarker, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end

		button.DoClick = function ()

			local cursorX, cursorY = input.GetCursorPos()

			local panel = vgui.Create(el[2])
			panel:Center()

			panel.setCategory(self.category) 

			panel:SetParent(self:GetParent())
			self:Remove()
		end
		
	end
end

function PANEL:Paint(w, h)

	local x, y = self:LocalToScreen(0,0)

	BSHADOWS.BeginShadow()
		surface.SetDrawColor(VoidUI.Colors.Primary)
		surface.DrawRect(x,y,w,h)
	BSHADOWS.EndShadow(2, 2, 2, 200, 1, 1)

	draw.SimpleText(L"create_new", "VoidUI.R30", w/2, 20, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

vgui.Register("VoidCases.CreatePopup", PANEL, "EditablePanel")

// Tabs

local PANEL = {}

function PANEL:Init()
	
end


vgui.Register("VoidCases.Tabs", PANEL, "VoidUI.Tabs")

// Input entry

-- local PANEL = {}

-- function PANEL:Init()
-- 	self.entry = self:Add("DTextEntry")
-- 	self.entry:Dock(FILL)
-- 	self.entry:DockMargin(10, 0, 10, 0)

-- 	self.entry:SetFont("VoidUI.R28")
-- 	self.entry:SetTextColor(VoidUI.Colors.Black)
-- 	self.entry:SetCursorColor(VoidUI.Colors.Black)

-- 	self.entry:SetPaintBackground(false)

-- 	self.entry:SetUpdateOnType(true)

	
-- end

-- function PANEL:PerformLayout(w, h)
-- 	self.entry:Dock(FILL)
-- 	self.entry:DockMargin(10, 0, 10, 0)
-- end

-- function PANEL:Paint(w, h)
-- 	draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.White)
-- end

-- vgui.Register("VoidUI.TextInput", PANEL, "DPanel")

// Dropdown

-- local PANEL = {}

-- function PANEL:Init()
-- 	self:SetFont("VoidUI.R28")
-- 	self:SetTextColor(VoidUI.Colors.TextGray)

-- 	-- self.DropButton.Paint = function (self, w, h)
-- 	--     // Dropdown arrow goes here
-- 	-- end


-- end



// Taken from the gmod lua source code


// Textinput image

local PANEL = {}

function PANEL:Init()
	self.entry:SetTextColor(VoidUI.Colors.Gray)
end

function PANEL:PerformLayout(w, h)
	self.entry:Dock(FILL)
	self.entry:DockMargin(ScrW() * 0.0675, 8, 10, 8)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.InputDark)

	local text = VoidCases.ImageProvider
	text = string.Replace(text, ".png", "")
	text = string.Replace(text, "%s", "")
	text = string.Replace(text, "https://", "")
	text = string.Replace(text, "http://", "")

	draw.SimpleText(text, "VoidUI.R24", 10, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	draw.RoundedBox(8, self.entry.x, self.entry.y, self.entry:GetWide(), self.entry:GetTall(), self.borderColor)
	draw.RoundedBox(8, self.entry.x+1, self.entry.y+1, self.entry:GetWide()-2, self.entry:GetTall()-2, self.backgroundColor)
end

vgui.Register("VoidCases.TextInputLogo", PANEL, "VoidUI.TextInput")

-- // Color mixer

-- local PANEL = {}

-- local function CreateWangFunction( self, colindex )
-- 	local function OnValueChanged( ptxt, strvar )
-- 		if ( ptxt.notuserchange ) then return end

-- 		self:GetColor()[ colindex ] = tonumber( strvar ) or 0
-- 		if ( colindex == "a" ) then
-- 			self.Alpha:SetBarColor( ColorAlpha( self:GetColor(), 255 ) )
-- 			self.Alpha:SetValue( self:GetColor().a / 255 )
-- 		else
-- 			self.HSV:SetColor( self:GetColor() )

-- 			local h, s, v = ColorToHSV( self.HSV:GetBaseRGB() )
-- 			self.RGB.LastY = ( 1 - h / 360 ) * self.RGB:GetTall()
-- 		end

-- 		self:UpdateColor( self:GetColor() )
-- 	end

-- 	return OnValueChanged
-- end

-- function PANEL:Init()
-- 	self:SetPalette(false)
-- 	self:SetAlphaBar(false)
-- 	self:SetWangs(false)

-- 	self.RGB:Remove()

-- 	// Taken from gmod source
-- 	self.WangsPanel = vgui.Create( "Panel", self )
-- 	self.WangsPanel:SetTall(23)
-- 	self.WangsPanel:Dock( BOTTOM )
-- 	self.WangsPanel:DockMargin( 0, 4, 0, 0 )

-- 	self.txtR = self.WangsPanel:Add( "DNumberWang" )
-- 	self.txtR:SetFont("VoidUI.R22")
-- 	self.txtR:SetDecimals( 0 )
-- 	self.txtR:SetMinMax( 0, 255 )
-- 	self.txtR:Dock( LEFT )
-- 	self.txtR:DockMargin( math.ceil(ScrW() * 0.01145), 0, 0, 0 )
-- 	self.txtR:SetTextColor( Color( 150, 0, 0, 255 ) )
-- 	self.txtR:SetWide(34)
-- 	self.txtR.Up:SetVisible(false)
-- 	self.txtR.Down:SetVisible(false)

-- 	self.txtG = self.WangsPanel:Add( "DNumberWang" )
-- 	self.txtG:SetFont("VoidUI.R22")
-- 	self.txtG:SetDecimals( 0 )
-- 	self.txtG:SetMinMax( 0, 255 )
-- 	self.txtG:Dock( LEFT )
-- 	self.txtG:DockMargin( math.ceil(ScrW() * 0.027), 0, 0, 0 )
-- 	self.txtG:SetTextColor( Color( 0, 150, 0, 255 ) )
-- 	self.txtG:SetWide(34)
-- 	self.txtG.Up:SetVisible(false)
-- 	self.txtG.Down:SetVisible(false)
	

-- 	self.txtB = self.WangsPanel:Add( "DNumberWang" )
-- 	self.txtB:SetFont("VoidUI.R22")
-- 	self.txtB:SetDecimals( 0 )
-- 	self.txtB:SetMinMax( 0, 255 )
-- 	self.txtB:Dock( LEFT )
-- 	self.txtB:DockMargin( math.ceil(ScrW() * 0.026), 0, 0, 0 )
-- 	self.txtB:SetWide(34)
-- 	self.txtB:SetTextColor( Color( 0, 0, 150, 255 ) )
-- 	self.txtB.Up:SetVisible(false)
-- 	self.txtB.Down:SetVisible(false)

-- 	self.txtR.OnValueChanged = CreateWangFunction( self, "r" )
-- 	self.txtG.OnValueChanged = CreateWangFunction( self, "g" )
-- 	self.txtB.OnValueChanged = CreateWangFunction( self, "b" )

-- 	self.RGB = vgui.Create( "DRGBPicker", self )
-- 	self.RGB:Dock( RIGHT )
-- 	self.RGB:SetWidth( 26 )
-- 	self.RGB:DockMargin( 4, 0, 0, 0 )
-- 	self.RGB.OnChange = function( ctrl, color )
-- 		self:SetBaseColor( color )
-- 	end

-- 	self:InvalidateLayout()
-- end



-- vgui.Register("VoidCases.ColorMixer", PANEL, "DColorMixer")

// Add item to case - selection

local PANEL = {}


function PANEL:InitItems(isKey)
	self.panel = self:Add("Panel")
	self.panel:Dock(FILL)
	self.panel:DockMargin(14, 14, 14, 14)

	self.search = self.panel:Add("VoidUI.TextInput")
	self.search:Dock(TOP)
	self.search:SetTall(36)
	self.search.entry:SetPlaceholderText(L"search_for_items")
	self.search.entry:SetFont("VoidCases.I24")


	function self.search.entry:OnFocusChanged(res)
		timer.Simple(0, function ()
			if (!IsValid(self)) then return end
			if (!res and !self:GetParent():GetParent():GetParent():HasFocus()) then
				self:GetParent():GetParent():GetParent():Remove()
			end
		end)
	end

	self.items = self.panel:Add("VoidUI.ScrollPanel")
	self.items:Dock(TOP)
	self.items:DockMargin(0, 22, 0, 0)
	self.items:SetTall(250)



	self.performSearch = function (str)

		self.items:Clear()

		self.items.Paint = function (self, w, h) end

		local totalItems = 0
		for k, v in pairs(VoidCases.Config.Items) do
			if (!string.find(string.lower(v.name), string.lower(str))) then continue end
			if (self:GetParent().caseItems[k] and self:GetParent().caseItems[k] != "s") then continue end
			if (isKey and v.type != VoidCases.ItemTypes.Case) then continue end
			if (isKey and !v.info.requiresKey) then continue end
			if (!isKey and v.type == VoidCases.ItemTypes.Case) then continue end

			totalItems = totalItems + 1

			local item = self.items:Add("DButton")
			item:Dock(TOP)
			item:DockMargin(0, 0, 0, 6)
			item:SetTall(37)
			item:SetText("")

			item.Paint = function (self, w, h)
				local color = (self:IsHovered() and VoidUI.Colors.Gray) or VoidUI.Colors.White
				draw.RoundedBox(6, 0, 0, w, h, color)
				draw.RoundedBoxEx(6, w-8, 0, 8, h, VoidCases.RarityColors[v.info.rarity], false, true, false, true)

				draw.SimpleText(v.name, "VoidUI.R24", 10, h/2, VoidUI.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			item.DoClick = function ()

				if (!isKey) then
			
					local panel = vgui.Create("VoidCases.AddCaseItem")
					panel:SSetSize(380, 350)
					panel:MakePopup()

					panel:Center()

					panel:SetParent(self:GetParent())

					panel:SetItem(v, k, self:GetParent())

				else

					self:GetParent().caseItems[k] = 1
					self:GetParent().refreshCaseItems()

				end

				self:Remove()
			end
		end
		

		if (totalItems == 0) then
			self.items.Paint = function (self, w, h) 
				draw.SimpleText(L"no_items_avail", "VoidUI.R24", w/2, h/2-60, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(L"create_items_shop", "VoidUI.R14", w/2, h/2-30, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end

	self.performSearch("")

	function self.search.entry:OnValueChange(val)
		self:GetParent():GetParent():GetParent().performSearch(val)
	end
end

function PANEL:OnFocusChanged(res)
	timer.Simple(0, function ()
		if (!IsValid(self)) then return end
		if (self.search.entry:HasFocus()) then return end
		if (!res) then self:Remove() end
	end)
end

function PANEL:Paint(w, h)

	local x, y = self:LocalToScreen(0, 0)

	BSHADOWS.BeginShadow()
		surface.SetDrawColor(VoidUI.Colors.Primary)
		surface.DrawRect(x,y,w,h)
	BSHADOWS.EndShadow(1, 1, 1, 140, 1, 1)
end


vgui.Register("VoidCases.ItemSelection", PANEL, "EditablePanel")

// Item add

local PANEL = {}

function PANEL:Init()
	self.calcPercentage = "X"
	self.caseItems = {}

	self.chance = 10
end

function PANEL:CalculateChance(editing)
	// (100 / sumOfAllChances) * thisChance
	// 76561198381307896 / 10^8 * sumOfAllChances
	local chanceSum = 0
	for k, v in pairs(self.caseItems) do
		if (!isstring(v) and k != self.id) then
			chanceSum = chanceSum + v
		end
	end

	local currChance = self.chance
	if (!currChance) then return end

	chanceSum = chanceSum + currChance

	local percentage = math.Round((100 / chanceSum) * currChance, 1)
	self.calcPercentage = percentage
end

function PANEL:SetItem(item, id, casePanel, isEditing, chance, mystery, isKey)
	self.chosenItem = item
	self.caseItems = casePanel.caseItems
	self.id = id
	self.isEditing = isEditing

	self:SetTitle(item.name)

	self.panel = self:Add("Panel")
	self.panel:Dock(FILL)
	self.panel:SDockMargin(30, 30, 30, 30)

	// Is mystery item

	local chanceEntry = nil
	local mysteryEntry = nil

	if (!isKey) then

		mysteryEntry = self.panel:Add("Panel")
		mysteryEntry:Dock(TOP)
		mysteryEntry:SetTall(30)
		mysteryEntry:DockMargin(0, 0, 0, 20)
		
		mysteryEntry.Paint = function (self, w, h)
			draw.SimpleText(L"is_mystery", "VoidUI.B28", 0, h/2, VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		mysteryEntry.input = mysteryEntry:Add("VoidUI.Switch")
		mysteryEntry.input:Dock(RIGHT)
		mysteryEntry.input:SSetWide(80)

		// Chance

		chanceEntry = self.panel:Add("Panel")
		chanceEntry:Dock(TOP)
		chanceEntry:SetTall(75)
		chanceEntry:DockMargin(0, 0, 0, 20)
		chanceEntry:MarginTop(20)
		
		chanceEntry.Paint = function (self, w, h)
			draw.SimpleText(L"drop_chance", "VoidUI.B28", 0, 10, VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.RoundedBox(8, 0, 30, w, h-30, VoidUI.Colors.Primary)

			draw.SimpleText("= " .. self:GetParent():GetParent().calcPercentage .. "% " .. L"win_chance", "VoidUI.R26", 110, (h+30)/2, VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		chanceEntry.input = chanceEntry:Add("VoidUI.TextInput")
		chanceEntry.input:Dock(TOP)
		chanceEntry.input:DockMargin(10, 35, 220, 0)
		chanceEntry.input:SetTall(35)

		chanceEntry.input.entry:SetNumeric(true)

		function chanceEntry.input.entry:OnValueChange(val)
			self:GetParent():GetParent():GetParent():GetParent().chance = tonumber(val)
			self:GetParent():GetParent():GetParent():GetParent():CalculateChance(isEditing)
		end

	end

	// Button panels

	local buttonPanel = self.panel:Add("Panel")
	buttonPanel:Dock(BOTTOM)
	buttonPanel:SSetTall(45)

	if (isEditing) then
		if (!isKey) then
			chanceEntry.input.entry:SetValue(chance)
		end
		if (!isKey and mystery) then
			mysteryEntry.input:ChooseOptionID(1)
		end

		// Add delete button
		local deleteButton = buttonPanel:Add("VoidUI.Button")
		deleteButton:Dock(RIGHT)
		deleteButton:SSetWide(140)
		deleteButton.font = "VoidUI.R34"

		deleteButton.color = VoidUI.Colors.Red
		deleteButton.hoveredColor = VoidUI.Colors.Red

		deleteButton:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)

		deleteButton.DoClick = function ()
			self:GetParent().caseItems[id] = nil
			if (!isKey) then
				self:GetParent().mysteryItems[id] = nil
			end

			self:GetParent().refreshCaseItems()
			self:Remove()
		end

		deleteButton.text = L"delete"
	end

	local saveButton = buttonPanel:Add("VoidUI.Button")
	saveButton:Dock(LEFT)
	saveButton:SSetWide(140)
	saveButton.font = "VoidUI.R34"

	saveButton.text = L"save"
	saveButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)

	saveButton.DoClick = function ()
		self:GetParent().caseItems[id] = (!isKey and tonumber(chanceEntry.input.entry:GetValue())) or 1
		if (!isKey) then
			self:GetParent().mysteryItems[id] = mysteryEntry.input:GetChecked()
		end

		self:GetParent().refreshCaseItems()

		self:Remove()
	end



end


vgui.Register("VoidCases.AddCaseItem", PANEL, "VoidUI.Frame")

// Trading invite

local PANEL = {}

function PANEL:CreateInvite(ply)

	if (!IsValid(ply)) then return end

    self.title = L"trading_request"
    self.plyName = string.format(L("trading_fromply"), ply:Nick())

	self.ply = ply

    self.nav = self:Add("Panel")
    self.nav:Dock(TOP)
    self.nav:SetTall(25)
    self.nav.Paint = function (self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, VoidUI.Colors.Primary, true, true, false, false)

        draw.SimpleText(self:GetParent().title, "VoidUI.R26", 5, h/2-2, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    self.accept = self:Add("VoidUI.Button")
    self.accept:SetColor(VoidUI.Colors.Green)
    self.accept:SetPos(35, 60)
    self.accept:SetSize(94,38)
    self.accept.font = "VoidUI.R28"
    self.accept.text = "Accept"

    self.accept.DoClick = function ()
        // net message to accept
        net.Start("VoidCases.AcceptTradeRequest")
            net.WriteEntity(ply)
        net.SendToServer()
        self:Remove()
    end


    self.decline = self:Add("VoidUI.Button")
    self.decline.color = VoidUI.Colors.Red
    self.decline:SetPos(280-35-94, 60)
    self.decline:SetSize(94,38)
    self.decline.font = "VoidUI.R28"
    self.decline.text = "Decline"
	self.decline.hoveredColor = Color(216, 93, 93)

    self.decline.DoClick = function ()
        self:Remove()
    end
    


    self:InvalidateLayout(true)

end



function PANEL:Paint(w,h)
    draw.RoundedBox(6, 0, 0, w, h, VoidUI.Colors.Background)

    draw.SimpleText(self.plyName, "VoidUI.R26", w/2, 40, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("VoidCases.TradeInvite", PANEL, "EditablePanel")
