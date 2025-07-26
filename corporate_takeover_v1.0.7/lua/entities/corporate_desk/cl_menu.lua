-- Deposit / withdraw money
local function moneyAction(withdraw, CorpID)
	local Corp = Corporate_Takeover.Corps[CorpID]
	if(!Corp) then return false end
	local owner = player.GetBySteamID(Corp.owner)
	if(!owner || !IsValid(owner) || owner != LocalPlayer()) then return false end

	local w, h = ScrW() * .2, ScrH() * .16

	local main = vgui.Create("cto_main")
	main:SetSize(w, h)
	main:Center()
	main:SetWindowTitle(Corporate_Takeover:Lang(withdraw and "withdraw_money" or "deposit_money"))

	local nameLabel = vgui.Create("DLabel", main)
	nameLabel:Dock(TOP)
	nameLabel:SetTall(Corporate_Takeover.Scale(20))
	nameLabel:SetText(Corporate_Takeover:Lang("money_amount"))
	nameLabel:SetFont("cto_20")

	local money = vgui.Create("cto_textentry", main)
	money:Dock(TOP)
	money:DockMargin(0, Corporate_Takeover.Scale(5), 0, Corporate_Takeover.Scale(10))
	money:SetValue("")
	local can = false
	function money:OnChange()
		local num = tonumber(self:GetValue())
		local isnum = isnumber(num)

		if(isnum && num > 0) then
			can = true
		else
			can = false
		end
	end
	money:RequestFocus()

	local buttonContainer = vgui.Create("DPanel", main)
	buttonContainer:Dock(BOTTOM)
	buttonContainer:SetTall(Corporate_Takeover.Scale(40))
	buttonContainer:DockMargin(0, Corporate_Takeover.Scale(10), 0, 0)
	function buttonContainer:Paint() end

	local save = vgui.Create("cto_button", buttonContainer)
	save:Dock(FILL)
	save:SetText(Corporate_Takeover:Lang(withdraw and "withdraw_money" or "deposit_money"))
	function save:DoClick()
		if(can) then
			net.Start("cto_MoneyAction")
				net.WriteBit(withdraw and 1 or 0)
				net.WriteBit(0)
				net.WriteUInt(tonumber(money:GetValue()), 32)
			net.SendToServer()
			main:Remove()
		end
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
	money.OnEnter = save.DoClick

	local max = vgui.Create("cto_button", buttonContainer)
	max:Dock(RIGHT)
	max:SetWide(Corporate_Takeover.Scale(100))
	max:DockMargin(Corporate_Takeover.Scale(10), 0, 0, 0)
	max:SetText(Corporate_Takeover:Lang("max"))
	function max:DoClick()
		net.Start("cto_MoneyAction")
			net.WriteBit(withdraw and 1 or 0)
			net.WriteBit(1)
		net.SendToServer()

		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
end

-- Displays desks & coffee
local function displayBuyableItems(main, scroll, Corp, k, v, desk)
	local buy = vgui.Create("DButton", scroll)
	buy:Dock(TOP)
	buy:DockMargin(0, 0, 0, Corporate_Takeover.Scale(10))
	buy:SetTall(Corporate_Takeover.Scale(65))
	function buy:DoClick()
		net.Start("cto_BuyItem")
			net.WriteBit(desk and 1 or 0)
			if desk then
				net.WriteString(v.deskclass)
			else
				net.WriteUInt(k, 5)
			end
		net.SendToServer()

		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
		main:Remove()
	end
	buy:SetText("")

	local price = DarkRP.formatMoney(v.price)

	function buy:Paint(w, h)
		draw.RoundedBox(0,0,0,w,h, self:IsHovered() and Corporate_Takeover.Config.Colors.BrightBackgroundHover or Corporate_Takeover.Config.Colors.BrightBackground)
	end

	local icon = vgui.Create("DImage", buy)
	icon:Dock(LEFT)
	icon:SetWide(Corporate_Takeover.Scale(60))
	icon:SetKeepAspect(true)
	icon:SetImage("corporate_takeover/"..(desk and v.deskclass or v.icon)..".png")

	if desk then
		local amount = vgui.Create("DLabel", buy)
		amount:Dock(RIGHT)
		amount:DockMargin(0, 0, 0, 0)
		amount:SetText((Corp.desks[v.deskclass] || 0).."/"..v.max)
		amount:SetContentAlignment(5)
		amount:SetFont("cto_20")
		amount:SetTextColor(Corporate_Takeover.Config.Colors.Text)
	end

	local name = vgui.Create("DLabel", buy)
	name:Dock(TOP)
	name:DockMargin(Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10), 0, 0)
	name:SetText(v.name)
	name:SetFont("cto_22")
	name:SetTextColor(Corporate_Takeover.Config.Colors.Text)

	local requirements = vgui.Create("DLabel", buy)
	requirements:SetText("")
	requirements:Dock(BOTTOM)
	requirements:DockMargin(Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10), 0, Corporate_Takeover.Scale(10))

	local money = vgui.Create("DLabel", requirements)
	money:Dock(LEFT)
	money:SetText(price)
	money:SetFont("cto_20")
	money:SetTextColor(Corporate_Takeover.Config.Colors.Text)
	money:SizeToContents()

	local divider = vgui.Create("DLabel", requirements)
	divider:Dock(LEFT)
	divider:SetText("·")
	divider:SetContentAlignment(5)
	divider:DockMargin(Corporate_Takeover.Scale(5), 0, Corporate_Takeover.Scale(5), 0)
	divider:SetFont("cto_20")
	divider:SetTextColor(Corporate_Takeover.Config.Colors.Text)
	divider:SizeToContents()

	local level = vgui.Create("DLabel", requirements)
	level:Dock(LEFT)
	level:SetText("Level "..v.level)
	level:SetFont("cto_20")
	level:SetTextColor(Corporate_Takeover.Config.Colors.Text)
	level:SizeToContents()

	local cooldown = CurTime()
	function buy:Think()
		if(cooldown > CurTime()) then return end
		
		cooldown = CurTime() + .5
		local can = true

		if(Corp.money < v.price) then
			money:SetTextColor(Corporate_Takeover.Config.Colors.Red)
			can = false
		else
			money:SetTextColor(Corporate_Takeover.Config.Colors.Text)
		end

		if(Corp.level < v.level) then
			level:SetTextColor(Corporate_Takeover.Config.Colors.Red)
			can = false
		else
			level:SetTextColor(Corporate_Takeover.Config.Colors.Text)
		end

		if(!can) then
			name:SetTextColor(Corporate_Takeover.Config.Colors.Red)
		else
			name:SetTextColor(Corporate_Takeover.Config.Colors.Text)
		end
	end

	return buy
end

-- Corporate menu
local function CorpMenu(CorpID)
	local Corp = Corporate_Takeover.Corps[CorpID]
	if(!Corp) then return false end
	local owner = player.GetBySteamID(Corp.owner)
	if(!owner || !IsValid(owner) || owner != LocalPlayer()) then return false end

	local w, h = ScrW(), ScrH()
	local scaleW, scaleH = w * .5, h * .55

	local main = vgui.Create("cto_main")
	main:SetSize(scaleW, scaleH)
	main:Center()
	main:MinimalPadding()
	main:SetWindowTitle(Corporate_Takeover:Lang("corporate_desk"))

	local Corp = Corporate_Takeover.Corps[CorpID]
	local cooldown = CurTime()
	function main:Think()
		if(!Corporate_Takeover.Corps[CorpID]) then
			self:Remove()
			return false
		end

		if(cooldown < CurTime()) then
			cooldown = CurTime() + .5

			Corp = Corporate_Takeover.Corps[CorpID]
		end
	end

	local bgHeight = (main:GetTall() - Corporate_Takeover.Scale(60)) * .25
	local background = vgui.Create("DImage", main)
	background:Dock(TOP)
	background:DockMargin(0, 0, 0, Corporate_Takeover.Scale(10))
	background:SetTall(bgHeight)
	background:SetKeepAspect(true)	
	background:SetImage("corporate_takeover/corporatemenu_background")

	local heading = vgui.Create("DLabel", background)
	heading:Dock(FILL)
	heading:SetText(Corp.name)
	heading:SetContentAlignment(5)
	heading:SetFont("cto_50")
	heading:SetTextColor(Corporate_Takeover.Config.Colors.Text)

	local bars = vgui.Create("DPanel", main)
	bars:Dock(TOP)
	bars:DockMargin(Corporate_Takeover.Scale(10), 0, Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10))
	bars:SetTall(Corporate_Takeover.Scale(40))
	function bars:Paint() end

	local moneybox = vgui.Create("cto_bar", bars)
	moneybox:Dock(LEFT)
	moneybox:SetWide(main:GetWide() * .5 - Corporate_Takeover.Scale(15))
	moneybox:DockMargin(0, 0, Corporate_Takeover.Scale(5), 0)
	function moneybox:FormatText(text)
		return DarkRP.formatMoney(text)
	end
	function moneybox:FetchValues()
		self:UpdateValues(Corp.money, Corp.maxMoney)
	end

	local levelbox = vgui.Create("cto_bar", bars)
	levelbox:Dock(RIGHT)
	levelbox:SetWide(main:GetWide() * .5 - Corporate_Takeover.Scale(15))
	levelbox:DockMargin(Corporate_Takeover.Scale(5), 0, 0, 0)
	local lang = Corporate_Takeover:Lang("level")
	function levelbox:FormatText(text)
		return text.." XP"
	end
	function levelbox:FetchValues()
		self:AddText(lang.." "..Corp.level.." - ")
		self:UpdateValues(Corp.xp, Corp.xpNeeded)
	end

	local canvas = vgui.Create("DPanel", main)
	canvas:Dock(FILL)
	canvas:DockMargin(Corporate_Takeover.Scale(10), 0, Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10))
	function canvas:Paint() end

	local DesksByLevel = {}
	for k, v in pairs(Corporate_Takeover.Desks) do
		local level = v.level || 1
		if(DesksByLevel[level] == nil) then
			DesksByLevel[level] = {}
		end

		DesksByLevel[level][#DesksByLevel[level] + 1] = v
	end

	local left_panel = vgui.Create("DPanel", canvas)
	left_panel:Dock(LEFT)
	left_panel:SetWide(main:GetWide() * .5 - Corporate_Takeover.Scale(15))
	function left_panel:Paint() end

	local left = vgui.Create("DScrollPanel", left_panel)
	left:Dock(FILL)
	Corporate_Takeover:DrawScrollbar(left)

	local right = vgui.Create("DScrollPanel", canvas)
	right:Dock(RIGHT)
	right:SetWide(main:GetWide() * .5 - Corporate_Takeover.Scale(15))
	Corporate_Takeover:DrawScrollbar(right)

	for a, b in SortedPairs(DesksByLevel) do
		for k, v in ipairs(b) do
			if(v.buyable) then
				local button = displayBuyableItems(main, right, Corp, k, v, true)
			end
		end
	end

	local coffees = Corporate_Takeover.Config.DefaultCoffee
	for k, v in ipairs(coffees) do
		local button = displayBuyableItems(main, left, Corp, k, v, false)
	end

	local buttonContainer = vgui.Create("DPanel", left_panel)
	buttonContainer:Dock(BOTTOM)
	buttonContainer:SetTall(Corporate_Takeover.Scale(40))
	buttonContainer:DockMargin(0, Corporate_Takeover.Scale(10), 0, 0)
	function buttonContainer:Paint() end

	local deposit = vgui.Create("cto_button", buttonContainer)
	deposit:Dock(LEFT)
	deposit:SetWide(left_panel:GetWide() * .5 - Corporate_Takeover.Scale(5))
	deposit:DockMargin(0, 0, Corporate_Takeover.Scale(5), 0)
	deposit:SetText(Corporate_Takeover:Lang("deposit_money"))
	function deposit:DoClick()
		moneyAction(false, CorpID)
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end

	local withdraw = vgui.Create("cto_button", buttonContainer)
	withdraw:Dock(RIGHT)
	withdraw:SetWide(left_panel:GetWide() * .5 - Corporate_Takeover.Scale(5))
	withdraw:DockMargin(Corporate_Takeover.Scale(5), 0, 0, 0)
	withdraw:SetText(Corporate_Takeover:Lang("withdraw_money"))
	function withdraw:DoClick()
		moneyAction(true, CorpID)
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
end

-- Corporate menu for creating a company
local function CreateCorpMenu() 
	local w, h = ScrW() * .2, ScrH() * .21

	local main = vgui.Create("cto_main")
	main:SetSize(w, h)
	main:Center()
	main:SetWindowTitle(Corporate_Takeover:Lang("create_corp"))

	local nameLabel = vgui.Create("DLabel", main)
	nameLabel:Dock(TOP)
	nameLabel:SetTall(Corporate_Takeover.Scale(20))
	nameLabel:SetTextColor(Corporate_Takeover.Config.Colors.Text)
	nameLabel:SetText(Corporate_Takeover:Lang("corp_name"))
	nameLabel:SetFont("cto_20")

	local name = vgui.Create("cto_textentry", main)
	name:Dock(TOP)
	name:DockMargin(0, Corporate_Takeover.Scale(5), 0, Corporate_Takeover.Scale(10))
	name:SetValue(Corporate_Takeover:Lang("placeholder_name"))


	local message = Corporate_Takeover:Lang("create_corp_button")
	message = string.Replace(message, "%price", DarkRP.formatMoney(Corporate_Takeover.Config.CompanyFee))

	local save = vgui.Create("cto_button", main)
	save:SetText(message)
	save:Dock(TOP)
	save:DockMargin(0, 0, 0, Corporate_Takeover.Scale(10))
	function save:DoClick()
		net.Start("cto_CreateCorp")
			net.WriteString(name:GetValue())
		net.SendToServer()
		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end

	local dismantle = vgui.Create("cto_button", main)
	dismantle:Dock(TOP)
	dismantle:SetText(Corporate_Takeover:Lang("dismantle"))
	dismantle:DangerTheme()
	function dismantle:DoClick()
		net.Start("cto_dismantleDesk")
		net.SendToServer()
		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
end

net.Receive("cto_CreateCorp", function()
	local corpMenu = net.ReadBit() == 1

	if(corpMenu) then
		local id = net.ReadUInt(8)
		CorpMenu(id)
	else
		CreateCorpMenu()
	end
end)