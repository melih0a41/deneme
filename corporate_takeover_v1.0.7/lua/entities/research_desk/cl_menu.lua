local function ResearchMenu(CorpID, researchClass)
	local Corp = Corporate_Takeover.Corps[CorpID]
	if(!Corp) then return false end
	local owner = player.GetBySteamID(Corp.owner)
	if(!owner || !IsValid(owner) || owner != LocalPlayer()) then return false end
	local Corp = Corporate_Takeover.Corps[CorpID]

	local w, h = ScrW() * 0.2, ScrH() * 0.4

	local main = vgui.Create("cto_main")
	main:SetSize(w, h)
	main:Center()
	main:SetWindowTitle(Corporate_Takeover:Lang("research_desk"))

	function main:Think()
		// Only update Corp here, saves performance.

		if(!Corporate_Takeover.Corps[CorpID]) then
			main:Remove()
			return false
		end

		Corp = Corporate_Takeover.Corps[CorpID]
	end
	local can = false
	local research_name = ""

	local text = vgui.Create("RichText", main)
	text:Dock(TOP)
	text:SetTall(Corporate_Takeover.Scale(60))
	text:SetText(Corporate_Takeover:Lang("research_description"))
	function text:PerformLayout()
		self:SetFontInternal("cto_18")
		self:SetFGColor(Corporate_Takeover.Config.Colors.Text)
	end

	local scroll = vgui.Create("DScrollPanel", main)
	scroll:Dock(FILL)
	Corporate_Takeover:DrawScrollbar(scroll)

	local options = {}

	for k, v in SortedPairs(Corporate_Takeover.Researches) do
		if(Corp.researches[v.class]) then
			continue
		end

		if(v.class == researchClass) then continue end

		local material = Material("materials/corporate_takeover/"..v.icon..".png")



		local option = vgui.Create("cto_button", scroll)
		option:Dock(TOP)
		option:DockMargin(0,0,0,Corporate_Takeover.Scale(5))
		option:SetTall(Corporate_Takeover.Scale(80))
		option:SetText("")
		function option:DoClick()
			can = true
			research_name = v.class

			text:SetText(v.description)
			surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
		end

		local level_needed = v.level
		local money_needed = v.price

		local icon = vgui.Create("DImage", option)
		icon:Dock(LEFT)
		icon:SetWide(Corporate_Takeover.Scale(60))
		icon:SetKeepAspect(true)
		icon:SetImage("corporate_takeover/"..v.icon..".png")
		icon:DockMargin(Corporate_Takeover.Scale(10), 0, 0, 0)

		local name = vgui.Create("DLabel", option)
		name:Dock(TOP)
		name:SetTall(Corporate_Takeover.Scale(25))
		name:DockMargin(Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10), 0, 0)
		name:SetFont("cto_22")
		name:SetTextColor(Corporate_Takeover.Config.Colors.Text)

		local requirements = vgui.Create("DLabel", option)
		requirements:SetText("")
		requirements:Dock(BOTTOM)
		requirements:SetTall(Corporate_Takeover.Scale(25))
		requirements:DockMargin(Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10), 0, Corporate_Takeover.Scale(10))
	
		local money = vgui.Create("DLabel", requirements)
		money:Dock(LEFT)
		money:SetText(money_needed)
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
		level:SetText(level_needed)
		level:SetFont("cto_20")
		level:SetTextColor(Corporate_Takeover.Config.Colors.Text)
		level:SizeToContents()

		local cooldown = CurTime()
		local lang_level = Corporate_Takeover:Lang("level")
		function option:Think()
			if(cooldown > CurTime()) then return end
			cooldown = CurTime() + 0.5

			local level_needed = v.level
			local money_needed = v.price
			local time = v.time

			if(Corp.researches["research_price_drop"]) then
				money_needed = math.Round(money_needed * .9, 1)
			end
			if(Corp.researches["research_efficiency"]) then
				time = math.Round(time * .9, 1)
			end

			name:SetText(v.name.." ("..string.FormattedTime(math.Round(time, 1), "%02i:%02i")..")")
			level:SetText(lang_level.." "..level_needed)
			money:SetText(DarkRP.formatMoney(money_needed))

			if(Corp.level >= level_needed) then
				level:SetTextColor(Corporate_Takeover.Config.Colors.TextMuted)
			else
				level:SetTextColor(Corporate_Takeover.Config.Colors.Red)
			end

			if(Corp.money >= money_needed) then
				level:SetTextColor(Corporate_Takeover.Config.Colors.TextMuted)
			else
				level:SetTextColor(Corporate_Takeover.Config.Colors.Red)
			end

			level:SizeToContents()
			money:SizeToContents()
		end
	end

	local research = vgui.Create("cto_button", main)
	research:Dock(BOTTOM)
	research:SetText(Corporate_Takeover:Lang("start_research"))
	function research:DoClick()
		if(can && research_name != "") then
			net.Start("cto_startResearch")
				net.WriteString(research_name)
			net.SendToServer()
			main:Remove()
		else
			chat.AddText("[Corporate Takeover] "..Corporate_Takeover:Lang("select_research_first"))
			surface.PlaySound(Corporate_Takeover.Config.Sounds.General["error"])
		end
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end

	local buttonContainer = vgui.Create("DPanel", main)
	buttonContainer:Dock(BOTTOM)
	buttonContainer:SetTall(Corporate_Takeover.Scale(40))
	buttonContainer:DockMargin(0, Corporate_Takeover.Scale(10), 0, Corporate_Takeover.Scale(10))
	function buttonContainer:Paint() end

	local fire = vgui.Create("cto_button", buttonContainer)
	fire:DangerTheme()
	fire:Dock(LEFT)
	fire:SetWide(main:GetWide()/2 - Corporate_Takeover.Scale(15))
	fire:SetText(Corporate_Takeover:Lang("fire_worker"))
	function fire:DoClick()
		net.Start("cto_WorkerManagement")
			net.WriteBit(0)
		net.SendToServer()
		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end

	local dismantle = vgui.Create("cto_button", buttonContainer)
	dismantle:DangerTheme()
	dismantle:Dock(RIGHT)
	dismantle:SetWide(main:GetWide()/2 - Corporate_Takeover.Scale(15))
	dismantle:SetText(Corporate_Takeover:Lang("dismantle"))
	function dismantle:DoClick()
		net.Start("cto_dismantleDesk")
		net.SendToServer()
		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
end
net.Receive("cto_openResearcher", function()
	ResearchMenu(net.ReadUInt(8), net.ReadString())
end)