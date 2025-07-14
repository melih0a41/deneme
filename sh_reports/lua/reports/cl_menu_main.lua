local matBack = Material("shenesis/general/back.png")

function SH_REPORTS:ShowReport(report)
	if (IsValid(_SH_REPORTS_VIEW)) then
		_SH_REPORTS_VIEW:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5
	local ss = self:GetScreenScale()

	local frame = self:MakeWindow(SH_REPORTS:L("view_report"))
	frame:SetSize(500 * ss, 400 * ss)
	frame:Center()
	frame:MakePopup()
	_SH_REPORTS_VIEW = frame

		frame:AddHeaderButton(matBack, function()
			frame:Close()
			self:ShowReports()
		end)

		local body = vgui.Create("DPanel", frame)
		body:SetDrawBackground(false)
		body:DockPadding(m, m, m, m)
		body:Dock(FILL)

			local players = vgui.Create("DPanel", body)
			players:SetDrawBackground(false)
			players:SetWide(frame:GetWide() - m * 2)
			players:Dock(TOP)

				local lbl1 = self:QuickLabel(SH_REPORTS:L("reporter"), "{prefix}Large", styl.text, players)
				lbl1:SetContentAlignment(7)
				lbl1:SetTextInset(m2, m2)
				lbl1:SetWide(frame:GetWide() * 0.5 - m2)
				lbl1:Dock(LEFT)
				lbl1:DockPadding(m2, lbl1:GetTall() + m * 1.5, m2, m2)
				lbl1.Paint = function(me, w, h)
					draw.RoundedBox(4, 0, 0, w, h, styl.inbg)
				end

					local avi = self:Avatar(report.reporter_id, 32, lbl1)
					avi:Dock(LEFT)
					avi:DockMargin(0, 0, m2, 0)

					local nic = self:QuickButton(report.reporter_name, function()
						SetClipboardText(report.reporter_name)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl1)
					nic:SetContentAlignment(4)
					nic:Dock(TOP)

					local s1 = util.SteamIDFrom64(report.reporter_id)
					local steamid = self:QuickButton(s1, function()
						SetClipboardText(s1)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl1)
					steamid:SetContentAlignment(4)
					steamid:Dock(TOP)

				local lbl = self:QuickLabel(SH_REPORTS:L("reported_player"), "{prefix}Large", styl.text, players)
				lbl:SetContentAlignment(9)
				lbl:SetTextInset(m2, m2)
				lbl:Dock(FILL)
				lbl:DockPadding(m2, lbl1:GetTall() + m * 1.5, m2, m2)
				lbl.Paint = lbl1.Paint

					local avi = self:Avatar(report.reported_id, 32, lbl)
					avi:Dock(RIGHT)
					avi:DockMargin(m2, 0, 0, 0)

					local nic = self:QuickButton(report.reported_name, function()
						SetClipboardText(report.reported_name)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl)
					nic:SetContentAlignment(6)
					nic:Dock(TOP)
					nic.Think = function(me)
						me:SetTextColor(IsValid(player.GetBySteamID64(report.reported_id)) and styl.text or styl.failure)
					end

					local s2 = util.SteamIDFrom64(report.reported_id)
					local steamid = self:QuickButton(s2, function()
						SetClipboardText(s2)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl)
					steamid:SetContentAlignment(6)
					steamid:Dock(TOP)

					if (report.reported_id == "0") then
						nic.Think = function() end
						nic:Dock(FILL)
						steamid:SetVisible(false)
						avi:SetVisible(false)
					end

				players:SetTall(lbl1:GetTall() + m * 2.5 + 32)

			local reason = self:QuickLabel(SH_REPORTS:L("reason") .. ":", "{prefix}Medium", styl.text, body)
			reason:Dock(TOP)
			reason:DockMargin(0, m, 0, 0)
			reason:DockPadding(reason:GetWide() + m2, 0, 0, 0)

				local reasonData = self.ReportReasons[report.reason_id]
				local reasonText = reasonData
				if type(reasonData) == "table" then
					reasonText = reasonData.reason
				end
				
				local r = self:QuickEntry(reasonText, reason)
				r:SetEnabled(false)
				r:SetContentAlignment(6)
				r:Dock(FILL)
				
				-- Yetkili şikayeti uyarısı
				if type(reasonData) == "table" and reasonData.disabled then
					local warning = self:QuickLabel("⚠️ Bu rapor Discord üzerinden işleme alınmalıdır!", "{prefix}Medium", styl.failure, body)
					warning:SetContentAlignment(5)
					warning:Dock(TOP)
					warning:DockMargin(0, m2, 0, 0)
				end

			local comment = self:QuickLabel(SH_REPORTS:L("comment") .. ":", "{prefix}Medium", styl.text, body)
			comment:SetContentAlignment(7)
			comment:Dock(FILL)
			comment:DockMargin(0, m, 0, m2)

				local tx = self:QuickEntry("", comment)
				tx:SetEnabled(false)
				tx:SetMultiline(true)
				tx:SetValue(report.comment)
				tx:Dock(FILL)
				tx:DockMargin(0, comment:GetTall() + m2, 0, 0)

			local actions = vgui.Create("DPanel", body)
			actions:SetDrawBackground(false)
			actions:Dock(BOTTOM)

				if (self:IsAdmin(LocalPlayer())) then
					if (report.admin_id == "") then
						-- Otomatik sit başladığı için sadece Claim butonu göster
						local claim = self:QuickButton(SH_REPORTS:L("claim_report"), function()
							easynet.SendToServer("SH_REPORTS.Claim", {id = report.id})
						end, actions)
						claim:Dock(LEFT)
						
						-- Info butonu ekle
						local info = self:QuickLabel("(30 saniye sonra sit başlar)", "{prefix}Small", styl.text, actions)
						info:SetContentAlignment(4)
						info:Dock(LEFT)
						info:DockMargin(m2, 0, 0, 0)
						
						-- GÜNCELLENMİŞ KISIM: Manuel başlatma seçenekleri (gizli)
						if (false and not self.AutoStartSit) then -- Devre dışı
							if (self.ClaimNoTeleport) then
								-- Zaten yukarıda claim var
							else
								local lbl = self:QuickLabel(SH_REPORTS:L("claim_report") .. ":", "{prefix}Medium", styl.text, actions)
								lbl:SetContentAlignment(4)
								lbl:Dock(LEFT)
								lbl:DockMargin(0, 0, m2, 0)

								local goto = self:QuickButton(SH_REPORTS:L("goto"), function()
									if (IsValid(player.GetBySteamID64(report.reported_id))) then
										local m = self:Menu()
										m:AddOption("bring_reported_player"):SetMouseInputEnabled(false)
										m:AddOption("yes", function()
											easynet.SendToServer("SH_REPORTS.ClaimAndTeleport", {id = report.id, bring = false, bring_reported = true})
										end)
										m:AddOption("no", function()
											easynet.SendToServer("SH_REPORTS.ClaimAndTeleport", {id = report.id, bring = false, bring_reported = false})
										end)
										m:Open()
									else
										easynet.SendToServer("SH_REPORTS.ClaimAndTeleport", {id = report.id, bring = false, bring_reported = false})
									end
								end, actions)
								goto:Dock(LEFT)

								local bring = self:QuickButton(SH_REPORTS:L("bring"), function()
									if (IsValid(player.GetBySteamID64(report.reported_id))) then
										local m = self:Menu()
										m:AddOption("bring_reported_player"):SetMouseInputEnabled(false)
										m:AddOption("yes", function()
											easynet.SendToServer("SH_REPORTS.ClaimAndTeleport", {id = report.id, bring = true, bring_reported = true})
										end)
										m:AddOption("no", function()
											easynet.SendToServer("SH_REPORTS.ClaimAndTeleport", {id = report.id, bring = true, bring_reported = false})
										end)
										m:Open()
									else
										easynet.SendToServer("SH_REPORTS.ClaimAndTeleport", {id = report.id, bring = true, bring_reported = false})
									end
								end, actions)
								bring:Dock(LEFT)
								bring:DockMargin(m2, 0, 0, 0)
							end

							-- GÜNCELLENMİŞ KISIM: GmodAdminSuite desteği eklendi
							if (sitsys or (GAS and GAS.AdminSit)) then
								local session = self:QuickButton(SH_REPORTS:L("start_sit_session"), function()
									easynet.SendToServer("SH_REPORTS.ClaimAndCSit", {id = report.id})
								end, actions)
								session:Dock(LEFT)
								session:DockMargin(m2, 0, 0, 0)
							end
						end
					else
						local lbl = self:QuickLabel(SH_REPORTS:L("claimed_by_x", ""), "{prefix}Medium", styl.text, actions)
						lbl:SetContentAlignment(4)
						lbl:Dock(LEFT)
						lbl:DockMargin(0, 0, m2, 0)

						self:GetName(report.admin_id, function(nick)
							if (IsValid(lbl)) then
								lbl:SetText(SH_REPORTS:L("claimed_by_x", nick))
								lbl:SizeToContents()
							end
						end)
					end
				end

				if (report.reporter_id == LocalPlayer():SteamID64()) or (report.admin_id == "" and self.CanDeleteWhenUnclaimed) or (report.admin_id == LocalPlayer():SteamID64()) then
					local close = self:QuickButton(SH_REPORTS:L("close_report"), function()
						easynet.SendToServer("SH_REPORTS.CloseReport", {id = report.id})
						frame:Close()
					end, actions, nil, self.Style.close_hover)
					close:Dock(RIGHT)
				end

	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.1)
end

local matStats = Material("shenesis/reports/stats.png")
local matAdd = Material("shenesis/reports/add.png")

function SH_REPORTS:ShowReports()
	-- Superadmin kontrolü
	if (self.OnlySuperadminCanSeeList and LocalPlayer():GetUserGroup() ~= "superadmin") then
		chat.AddText(self.Style.header, "[", SH_REPORTS:L("reports"), "] ", Color(255, 255, 255), "Rapor listesini görme yetkiniz yok. ", self.NextReportCommand, " komutunu kullanın.")
		return
	end

	if (IsValid(_SH_REPORTS)) then
		_SH_REPORTS:Remove()
	end
	if (IsValid(_SH_REPORTS_VIEW)) then
		_SH_REPORTS_VIEW:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local ss = self:GetScreenScale()

	local delay = 0
	if (self.ServerTime) then
		delay = self.ServerTime - os.time()
	end

	local frame = self:MakeWindow(self:IsAdmin(LocalPlayer()) and SH_REPORTS:L("report_list") or SH_REPORTS:L("your_reports"))
	frame:SetSize(900 * ss, 600 * ss)
	frame:Center()
	frame:MakePopup()
	_SH_REPORTS = frame

		if (self.UsergroupsPerformance[LocalPlayer():GetUserGroup()]) then
			local btn = frame:AddHeaderButton(matStats, function()
				easynet.SendToServer("SH_REPORTS.RequestPerfReports")
				frame:Close()
			end)
			btn:SetToolTip(SH_REPORTS:L("performance_reports"))
		end
		if (!self:IsAdmin(LocalPlayer()) or self.StaffCanReport) then
			local btn = frame:AddHeaderButton(matAdd, function()
				self:ShowMakeReports()
				frame:Close()
			end)
			btn:SetToolTip(SH_REPORTS:L("new_report"))
		end

		local ilist = vgui.Create("DListView", frame)
		ilist:SetSortable(false)
		ilist:SetDrawBackground(false)
		ilist:SetDataHeight(32)
		ilist:Dock(FILL)
		ilist:AddColumn(SH_REPORTS:L("reporter"))
		ilist:AddColumn(SH_REPORTS:L("reported_player"))
		ilist:AddColumn(SH_REPORTS:L("reason"))
		ilist:AddColumn(SH_REPORTS:L("waiting_time"))
		ilist:AddColumn(SH_REPORTS:L("claimed"))
		ilist:AddColumn(SH_REPORTS:L("actions"))
		self:PaintList(ilist)

			-- Önce mevcut satırları temizle
			ilist:Clear()
			
			-- Yeni satırları ekle
			for _, report in SortedPairsByMemberValue (self.ActiveReports, "time", true) do
				local reporter = vgui.Create("DPanel", frame)
				reporter:SetDrawBackground(false)

					local avi = self:Avatar(report.reporter_id, 24, reporter)
					avi:SetPos(4, 4)

					local name = self:QuickLabel(report.reporter_name, "{prefix}Medium", styl.text, reporter)
					name:Dock(FILL)
					name:SetTextInset(ilist:GetDataHeight(), 0)

				local reported = vgui.Create("DPanel", frame)
				reported:SetDrawBackground(false)

					local avi = self:Avatar(report.reported_id, 24, reported)
					avi:SetPos(4, 4)

					local name = self:QuickLabel(report.reported_name, "{prefix}Medium", styl.text, reported)
					name:Dock(FILL)
					name:SetTextInset(32, 0)

					if (report.reported_id ~= "0") then
						name.Think = function(me)
							me:SetTextColor(IsValid(player.GetBySteamID64(report.reported_id)) and styl.text or styl.failure)
						end
					else
						avi:SetVisible(false)
						name:SetContentAlignment(5)
						name:SetTextInset(0, 0)
					end

				local claimed = vgui.Create("DPanel", frame)
				claimed:SetDrawBackground(false)

					local avi = self:Avatar("", 24, claimed)
					avi:SetPos(4, 4)
					claimed.avi = avi

					local name = self:QuickLabel(SH_REPORTS:L("unclaimed"), "{prefix}Medium", styl.text, claimed)
					name:Dock(FILL)
					name:SetTextInset(32, 0)
					claimed.name = name

					if (report.admin_id ~= "") then
						avi:SetSteamID(report.admin_id)

						self:GetName(report.admin_id, function(nick)
							if (IsValid(name)) then
								name:SetText(nick)
							end
						end)
					else
						avi:SetVisible(false)
						name:SetContentAlignment(5)
						name:SetTextInset(0, 0)
					end

				local actions = vgui.Create("DPanel", frame)
				actions:SetDrawBackground(false)
				actions:SetTall(32)
				actions:DockPadding(4, 4, 4, 4)

					local act_view = self:QuickButton(SH_REPORTS:L("view"), function() end, actions)
					act_view:Dock(LEFT)
					act_view:DockMargin(0, 0, 4, 0)
					act_view.DoClick = function()
						frame:Close()
						self:ShowReport(report)
					end

					local act_delete
					if (report.admin_id == "" and self.CanDeleteWhenUnclaimed) or (report.admin_id == LocalPlayer():SteamID64()) then
						act_delete = self:QuickButton(SH_REPORTS:L("close_report"), function() end, actions, nil, self.Style.close_hover)
						act_delete:Dock(LEFT)
						act_delete.DoClick = function()
							easynet.SendToServer("SH_REPORTS.CloseReport", {id = report.id})
						end
					end

				local time = self:QuickLabel("", "{prefix}Medium", styl.text, frame)
				time:SetContentAlignment(5)
				time.Think = function(me)
					if (!me.m_fNextRefresh or RealTime() >= me.m_fNextRefresh) then
						me.m_fNextRefresh = RealTime() + 5
						me:SetText(self:FullFormatTime(os.time() + delay - report.time))
					end
				end
				
				-- Rapor sebebini göster
				local reasonData = self.ReportReasons[report.reason_id]
				local reasonText = reasonData
				local isDisabled = false
				
				if type(reasonData) == "table" then
					isDisabled = reasonData.disabled
					reasonText = reasonData.reason
				end
				
				-- Disabled kategoriler için işaret
				if isDisabled then
					reasonText = "[Discord] " .. reasonText
					-- Satır rengini değiştir
					line.Paint = function(me, w, h)
						-- Önce normal paint
						if (!me:GetAltLine()) then
							surface.SetAlphaMultiplier(math.min(me:GetAlpha() / 255, 0.5))
								surface.SetDrawColor(styl.failure) -- Kırmızımsı arka plan
								surface.DrawRect(0, 0, w, h)
							surface.SetAlphaMultiplier(me:GetAlpha() / 255)
						end

						if (me:IsSelectable() and me:IsLineSelected()) then
							surface.SetDrawColor(styl.hover)
							surface.DrawRect(0, 0, w, h)
						elseif (me.Hovered or me:IsChildHovered()) then
							surface.SetDrawColor(styl.hover2)
							surface.DrawRect(0, 0, w, h)
						end
					end
				end

			local line = ilist:AddLine(reporter, reported, reasonText, time, claimed, actions)
			-- line:SetSelectable(false)
			line.claimed = claimed
			line.delete = act_delete
			line.Close = function(me)
				me:AlphaTo(0, 0.2, nil, function()
					if (!ilist.Lines[me:GetID()]) then
						return end

					ilist:RemoveLine(me:GetID())
				end)
			end
			self:LineStyle(line)

			report.line = line
		end

	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.1)
end

function SH_REPORTS:MakeTab(report)
	if (IsValid(_SH_REPORTS_TAB)) then
		_SH_REPORTS_TAB:Close()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5

	local rep = vgui.Create("DButton")
	rep:SetText("")
	rep:SetSize(160, 32 + m)
	-- DEĞİŞTİRİLDİ: Sol alt köşeye taşındı
	rep:SetPos(10, ScrH())
	rep:MoveToFront()
	rep:DockPadding(m2, m2, m2, m2)
	rep.Paint = function(me, w, h)
		draw.RoundedBoxEx(4, 0, 0, w, h, styl.header, true, true, false, false)
	end
	rep.DoClick = function(me)
		if (me.m_bClosing) then
			return end

		self:ShowReport(report)
	end
	rep.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:Stop()
		me:MoveTo(10, ScrH(), 0.2, 0, -1, function()
			me:Remove()
		end)
	end
	rep.id = report.id
	_SH_REPORTS_TAB = rep

		local avi = self:Avatar(report.reporter_id, 32, rep)
		avi:SetMouseInputEnabled(false)
		avi:Dock(LEFT)
		avi:DockMargin(0, 0, m2, 0)

		local name = self:QuickLabel(SH_REPORTS:L("report_of_x", report.reporter_name), "{prefix}Large", styl.text, rep)
		name:Dock(FILL)

	rep:SetWide(name:GetWide() + avi:GetWide() + m * 1.5)
	-- DEĞİŞTİRİLDİ: Sol alt köşeden yukarı çıkıyor
	rep:MoveTo(10, ScrH() - rep:GetTall(), 0.2)
end

function SH_REPORTS:MakeNotification(report)
	if (IsValid(report.notif)) then
		report.notif:Close()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5

	local rep = vgui.Create("DButton")
	rep:SetText("")
	rep:SetSize(160, 32 + m)
	-- DEĞİŞTİRİLDİ: Sol üst köşeye taşındı (party HUD'ı sağda)
	rep:SetPos(10, -rep:GetTall())
	rep:MoveToFront()
	rep:DockPadding(m2, m2, m2, m2)
	rep.Paint = function(me, w, h)
		draw.RoundedBoxEx(4, 0, 0, w, h, styl.header, false, false, true, true)
	end
	rep.DoClick = function(me)
		if (me.m_bClosing) then
			return end

		self:ShowReport(report)
		me:Close()
	end
	rep.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:Stop()
		me:MoveTo(10, -me:GetTall(), 0.2, 0, -1, function()
			me:Remove()
		end)
	end
	report.notif = rep

		local avi = self:Avatar(report.reporter_id, 32, rep)
		avi:SetMouseInputEnabled(false)
		avi:Dock(LEFT)
		avi:DockMargin(0, 0, m2, 0)

		local reasonText = self.ReportReasons[report.reason_id]
		local isDisabled = false
		if type(reasonText) == "table" then
			isDisabled = reasonText.disabled
			reasonText = reasonText.reason
		end
		
		-- Disabled kategoriler için özel renk veya işaret
		if isDisabled then
			reasonText = "[Discord] " .. reasonText
		end
		
		local name = self:QuickLabel(SH_REPORTS:L("report_received", report.reporter_name, report.reported_name, reasonText), "{prefix}Large", styl.text, rep)
		name:Dock(FILL)

	rep:SetWide(name:GetWide() + avi:GetWide() + m * 1.5)
	-- DEĞİŞTİRİLDİ: Sol üst köşeden aşağı iniyor
	rep:MoveTo(10, 0, 0.2, nil, nil, function()
		rep:MoveTo(10, -rep:GetTall(), 0.2, 7.5, nil, function()
			rep:Remove()
		end)
	end)
end

SH_REPORTS.PendingPanels = SH_REPORTS.PendingPanels or {}

function SH_REPORTS:ClosePendingPanel(id)
	local cleaned = {}
	
	-- Clean closed reports
	for k, v in pairs (self.PendingPanels) do
		if (!IsValid(v)) then
			continue end

		local found = false
		for _, rep in pairs (SH_REPORTS.ActiveReports) do
			if (rep.id == v.m_iReportID) then
				found = true
			end
		end

		if (!found) or (v.m_iReportID == id) then
			v:Close()
			continue
		end

		table.insert(cleaned, v)
	end

	self.PendingPanels = cleaned
end

function SH_REPORTS:MakePending(report)
	if (IsValid(report.pending)) then
		report.pending:Remove()
	end

	local num = 0
	for _, w in pairs (self.PendingPanels) do
		if (IsValid(w) and !w.m_bClosing) then
			num = num + 1
		end
	end

	if (num >= self.PendingReportsDispNumber) then
		return end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local hh = th * 0.66
	local m2, m3 = m * 0.5, m * 0.66
	local ss = self:GetScreenScale()

	local wnd = vgui.Create("DPanel")
	wnd:SetSize(300 * ss, 112 * ss)
	wnd:DockPadding(m3, hh + m3, m3, m3)
	wnd.Paint = function(me, w, h)
		draw.RoundedBoxEx(4, 0, 0, w, hh, styl.header, true, true, false, false)
		draw.RoundedBoxEx(4, 0, hh, w, h - hh, styl.inbg, false, false, true, true)
		draw.SimpleText("[" .. SH_REPORTS:L("unclaimed") .. "] " .. SH_REPORTS:L("report_of_x", report.reporter_name), "SH_REPORTS.MediumB", m2, hh * 0.5, styl.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	wnd.m_iReportID = report.id
	report.pending = wnd

		local lbl = self:QuickLabel(SH_REPORTS:L("reported_player") .. ":", "{prefix}Medium", styl.text, wnd)
		lbl:Dock(TOP)

			local reported = self:QuickLabel(report.reported_name, "{prefix}Medium", styl.text, lbl)
			reported:Dock(RIGHT)

		local lbl = self:QuickLabel(SH_REPORTS:L("reason") .. ":", "{prefix}Medium", styl.text, wnd)
		lbl:Dock(TOP)
		lbl:DockMargin(0, m3, 0, 0)

			local reasonData = self.ReportReasons[report.reason_id]
			local reasonText = reasonData
			local isDisabled = false
			
			if type(reasonData) == "table" then
				isDisabled = reasonData.disabled
				reasonText = reasonData.reason
			end
			
			-- Disabled kategoriler için özel işaret
			if isDisabled then
				reasonText = "[Discord] " .. reasonText
			end
			
			local reason = self:QuickLabel(reasonText, "{prefix}Medium", styl.text, lbl)
			reason:Dock(RIGHT)

		local buttons = vgui.Create("DPanel", wnd)
		buttons:SetDrawBackground(false)
		buttons:SetTall(20 * ss)
		buttons:Dock(BOTTOM)

			local close = self:QuickButton("✕", function()
				wnd:Close()
				report.ignored = true
			end, buttons)
			close:SetWide(buttons:GetTall())
			close:Dock(LEFT)
			close.m_Background = styl.close_hover

			local view = self:QuickButton(SH_REPORTS:L("view"), function()
				self:ShowReport(report)
			end, buttons)
			view:Dock(RIGHT)
			view.m_Background = styl.header

	local i = table.insert(self.PendingPanels, wnd)
	-- DEĞİŞTİRİLDİ: Sağ alt köşeye taşındı
	wnd:SetPos(ScrW() - wnd:GetWide() - m, ScrH() - (i * wnd:GetTall()) - (i * m))
	wnd:SetAlpha(0)
	wnd:AlphaTo(255, 0.1)

	wnd.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, 0.1, 0, function()
			local ma = #self.PendingPanels
			table.RemoveByValue(self.PendingPanels, me)
			me:Remove()

			local o = 0
			for j = i - 1, ma do
				local w = self.PendingPanels[j]
				if (IsValid(w) and w ~= me) then
					w:Stop()
					-- DEĞİŞTİRİLDİ: Sağ alt köşeye yeniden pozisyonlandır
					w:MoveTo(ScrW() - w:GetWide() - m, ScrH() - ((o + 1) * wnd:GetTall()) - ((o + 1) * m), 0.2)
					o = o + 1
				end
			end

			-- Display any hidden panels
			for _, r in pairs (self.ActiveReports) do
				if (!IsValid(r.pending) and !r.ignored and r.admin_id == "") then
					self:MakePending(r)
				end
			end
		end)
	end
end