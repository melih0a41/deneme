// Select worker menu

local c = Corporate_Takeover.Config.Colors.Primary
local primary_transparent = Color(c.r, c.g, c.b, 100)

local function GetWorkerList(scroll, CorpID, btn, cb)
	-- Since the IDs move when workers are hired, ipairs is no option
	for k, v in pairs(Corporate_Takeover.Corps[CorpID].hireableWorkers) do
		local worker_name = v.name.." "..v.lastname

		local worker = vgui.Create("cto_button", scroll)
		worker:SetText("")
		worker:Dock(TOP)
		worker:SetHeight(Corporate_Takeover.Scale(100))
		worker:DockMargin(0, 0, 0, Corporate_Takeover.Scale(5))
		worker:DockPadding(Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10))
		function worker:DoClick()
			worker.active = true
			scroll.selected = k

			if IsValid(btn) then
				local text = Corporate_Takeover:Lang("hire_worker")
				text = string.Replace(text, "%s", worker_name)
				btn:SetText(text)
			end

			surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
		end

		local worker_model = vgui.Create("DModelPanel", worker)
		worker_model:Dock(LEFT)
		worker_model:SetWide(Corporate_Takeover.Scale(80))
		worker_model:SetModel(v.model)

		local name = vgui.Create("DLabel", worker)
		name:SetText(worker_name)
		name:SetFont("cto_20")
		name:SetTextColor(Corporate_Takeover.Config.Colors.Text)
		name:SetContentAlignment(4)
		name:Dock(TOP)
		name:SetTall(Corporate_Takeover.Scale(25))

		local age = vgui.Create("DLabel", worker)
		age:SetText(Corporate_Takeover:Lang("age")..": "..v.age)
		age:SetFont("cto_18")
		age:SetTextColor(Corporate_Takeover.Config.Colors.TextMuted)
		age:SetContentAlignment(4)
		age:Dock(TOP)
		age:SetTall(Corporate_Takeover.Scale(20))

		local level = vgui.Create("DLabel", worker)
		level:SetText(Corporate_Takeover:Lang("level")..": "..v.level)
		level:SetFont("cto_18")
		level:SetTextColor(Corporate_Takeover.Config.Colors.TextMuted)
		level:SetContentAlignment(4)
		level:Dock(TOP)
		level:SetTall(Corporate_Takeover.Scale(20))

		local wage = vgui.Create("DLabel", worker)
		wage:SetText(Corporate_Takeover:Lang("wage")..": "..DarkRP.formatMoney(v.wage))
		wage:SetFont("cto_18")
		wage:SetTextColor(Corporate_Takeover.Config.Colors.TextMuted)
		wage:SetContentAlignment(4)
		wage:Dock(TOP)
		wage:SetTall(Corporate_Takeover.Scale(20))
	end

	if cb then
		cb()
	end
end

local function SelectWorkerMenu(CorpID)
	local Corp = Corporate_Takeover.Corps[CorpID]
	if(!Corp) then
		return false
	end

	local w, h = ScrW() * 0.2, ScrH() * 0.5

	local main = vgui.Create("cto_main")
	main:SetSize(w, h)
	main:Center()
	main:SetWindowTitle(Corporate_Takeover:Lang("select_worker"))
	main.Submitting = false
	function main:OnRemove()
		if(!self.Submitting) then
			net.Start("cto_WorkerSelection")
			net.SendToServer()
		end
	end

	local loading = vgui.Create("DLabel", main)
	loading:SetPos(Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(50))
	loading:SetText("Loading")
	loading:SetFont("cto_20")
	loading:SetTextColor(Corporate_Takeover.Config.Colors.Text)
	loading:SetContentAlignment(5)
	local dots = ""
	local delay = CurTime()
	function loading:Think()
		if(delay < CurTime()) then
			delay = CurTime() + .5

			dots = dots.."."
			if(#dots > 3) then
				dots = ""
			end

			self:SetText("Loading"..dots)
		end
	end


	local scroll = vgui.Create("DScrollPanel", main)
	scroll:Dock(FILL)
	Corporate_Takeover:DrawScrollbar(scroll)
	scroll.ThinkDelay = CurTime()
	scroll.Workers = Corp.hireableWorkers
	scroll.selected = -1

	local dismantle = vgui.Create("cto_button", main)
	dismantle:Dock(BOTTOM)
	dismantle:SetText(Corporate_Takeover:Lang("dismantle"))
	dismantle:DangerTheme()
	dismantle:DockMargin(0, Corporate_Takeover.Scale(10), 0, 0)
	function dismantle:DoClick()
		net.Start("cto_dismantleDesk")
		net.SendToServer()
		main:Remove()
		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end

	local hire = vgui.Create("cto_button", main)
	hire:Dock(BOTTOM)
	hire:SetText(Corporate_Takeover:Lang("select_worker"))
	function hire:DoClick()
		if(scroll.selected != -1) then
			main.Submitting = true
			net.Start("cto_WorkerManagement")
				net.WriteBit(1)
				net.WriteUInt(scroll.selected, 6)
			net.SendToServer()
			main:Remove()
			surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
		else
			chat.AddText("[Corporate Takeover] "..Corporate_Takeover:Lang("select_worker_first"))
			surface.PlaySound(Corporate_Takeover.Config.Sounds.General["error"])
		end
	end

	local heading = vgui.Create("DLabel", main)
	heading:Dock(BOTTOM)
	heading:SetTall(Corporate_Takeover.Scale(40))
	heading:SetTextColor(Corporate_Takeover.Config.Colors.Text)
	heading:SetFont("cto_20")
	heading:SetContentAlignment(5)
	heading:SetText("")
	local cooldown = CurTime()
	local text = Corporate_Takeover:Lang("new_workers_in")
	function heading:Think()
		if(cooldown > CurTime()) then return end
		cooldown = CurTime() + 1
		
		self:SetText(text.." ".. string.FormattedTime(math.Round((Corporate_Takeover.Corps[Corp.CorpID].GenerateWorkerDelay - CurTime()), 1), "%02i:%02i"))
	end

	function scroll:Think()
		if(scroll.ThinkDelay < CurTime()) then
			scroll.ThinkDelay = CurTime() + .5

			local tCorp = Corporate_Takeover.Corps[CorpID]
			if(tCorp) then
				if(tCorp.hireableWorkers != scroll.Workers) then
					scroll:Clear()
					scroll.selected = -1
					scroll.Workers = tCorp.hireableWorkers
					GetWorkerList(scroll, CorpID, hire)
				end
			end
		end
	end

	GetWorkerList(scroll, CorpID, hire, function()
		loading:Remove()
	end)
end

net.Receive("cto_WorkerSelection", function()
	SelectWorkerMenu(net.ReadUInt(8))
end)