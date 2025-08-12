-- cl_main.lua - TAM GÜNCELLENMİŞ HALİ

if (!SH_REPORTS.ActiveReports) then
	SH_REPORTS.ActiveReports = {}
end

-- PendingPanels tablosunu başlat
SH_REPORTS.PendingPanels = SH_REPORTS.PendingPanels or {}

-- ClosePendingPanel fonksiyonu (güvenlik için ekledik)
function SH_REPORTS:ClosePendingPanel(id)
	local cleaned = {}
	
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

function SH_REPORTS:ReportCreated(data)
	-- Rapor sebebini doğru şekilde al
	local reasonText = self.ReportReasons[data.reason_id]
	if type(reasonText) == "table" then
		reasonText = reasonText.reason
	end
	
	-- CHAT MESAJI KALDIRILDI!
	-- chat.AddText(self.Style.header, "[" .. self:L("reports") .. "] ", color_white, self:L("report_received", data.reporter_name, data.reported_name, reasonText))

	if (self.NewReportSound.enabled) then
		surface.PlaySound(self.NewReportSound.path)
	end

	-- BİLDİRİM KALDIRILDI!
	-- self:MakeNotification(data)
	
	if (!self.ActiveReports) then
		self.ActiveReports = {}
	end
	table.insert(self.ActiveReports, data)
end

hook.Add("Think", "SH_REPORTS.Ready", function()
	if (IsValid(LocalPlayer())) then
		hook.Remove("Think", "SH_REPORTS.Ready")
		easynet.SendToServer("SH_REPORTS.PlayerReady")
	end
end)

-- Periyodik senkronizasyon kontrolü
timer.Create("SH_REPORTS.SyncCheck", 5, 0, function()
	if (IsValid(LocalPlayer()) and IsValid(_SH_REPORTS)) then
		-- Sunucudan güncel listeyi iste
		easynet.SendToServer("SH_REPORTS.RequestList")
	end
end)

-- RAPOR LİSTESİ MENÜSÜ
local matAdd = Material("shenesis/reports/add.png", "noclamp smooth")
local matStats = Material("shenesis/reports/stats.png", "noclamp smooth")

function SH_REPORTS:ShowReports()
	if (IsValid(_SH_REPORTS)) then
		_SH_REPORTS:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5
	local ss = self:GetScreenScale()

	local frame = self:MakeWindow(self:L("report_list"))
	frame:SetSize(800 * ss, 600 * ss)
	frame:Center()
	frame:MakePopup()
	_SH_REPORTS = frame

		-- YENİ RAPOR BUTONU
		if (!self:IsAdmin(LocalPlayer()) or self.StaffCanReport) then
			frame:AddHeaderButton(matAdd, function()
				frame:Close()
				self:ShowMakeReports()
			end)
		end

		-- PERFORMANS RAPORLARI BUTONU (sadece yetkili usergroup'lar için)
		if (self.UsergroupsPerformance[LocalPlayer():GetUserGroup()]) then
			frame:AddHeaderButton(matStats, function()
				frame:Close()
				easynet.SendToServer("SH_REPORTS.RequestPerfReports")
			end)
		end

		local ilist = vgui.Create("DListView", frame)
		ilist:SetSortable(false)
		ilist:SetDrawBackground(false)
		ilist:SetDataHeight(64 * ss)
		ilist:Dock(FILL)
		ilist:AddColumn(self:L("reporter"))
		ilist:AddColumn(self:L("reported_player"))
		ilist:AddColumn(self:L("reason"))
		ilist:AddColumn(self:L("waiting_time"))
		ilist:AddColumn(self:L("claimed"))
		ilist:AddColumn(self:L("actions"))
		self:PaintList(ilist)

		frame.RefreshReports = function(me)
			ilist:Clear()
			
			-- Raporları ekle
			local i = 0
			for id, report in pairs(self.ActiveReports) do
				local reporter = vgui.Create("DPanel", frame)
				reporter:SetDrawBackground(false)

					local avi = self:Avatar(report.reporter_id, 24, reporter)
					avi:SetPos(4, 4)

					local name = self:QuickLabel(report.reporter_name, "{prefix}Medium", styl.text, reporter)
					name:Dock(FILL)
					name:SetTextInset(ilist:GetDataHeight() * 0.5, 0)
					name:SetContentAlignment(4)

				local reported = vgui.Create("DPanel", frame)
				reported:SetDrawBackground(false)

					local avi = self:Avatar(report.reported_id, 24, reported)
					avi:SetPos(4, 4)

					local name = self:QuickLabel(report.reported_name, "{prefix}Medium", styl.text, reported)
					name:Dock(FILL)
					name:SetTextInset(ilist:GetDataHeight() * 0.5, 0)
					name:SetContentAlignment(4)
					name.Think = function(me)
						me:SetTextColor(IsValid(player.GetBySteamID64(report.reported_id)) and styl.text or styl.failure)
					end

					if (report.reported_id == "0") then
						avi:SetVisible(false)
						name:SetText("[" .. self:L("other") .. "]")
						name:SetTextInset(0, 0)
						name:SetContentAlignment(5)
					end

				-- Sebep
				local reasonData = self.ReportReasons[report.reason_id]
				local reasonText = reasonData
				if type(reasonData) == "table" then
					reasonText = reasonData.reason
				end
				
				-- Bekleme süresi
				local wait_time = self:FullFormatTime(os.time() - report.time)

				-- Üstlenildi mi?
				local claimed = vgui.Create("DPanel", frame)
				claimed:SetDrawBackground(false)

					if (report.admin_id ~= "") then
						local avi = self:Avatar(report.admin_id, 24, claimed)
						avi:SetPos(4, 4)

						local name = self:QuickLabel("...", "{prefix}Medium", styl.text, claimed)
						name:Dock(FILL)
						name:SetTextInset(ilist:GetDataHeight() * 0.5, 0)
						name:SetContentAlignment(4)

						self:GetName(report.admin_id, function(nick)
							if (IsValid(name)) then
								name:SetText(nick)
							end
						end)
					else
						local name = self:QuickLabel(self:L("unclaimed"), "{prefix}Medium", styl.failure, claimed)
						name:Dock(FILL)
						name:SetContentAlignment(5)
					end

				-- Aksiyonlar
				local actions = vgui.Create("DPanel", frame)
				actions:SetDrawBackground(false)

					local view = self:QuickButton(self:L("view"), function()
						self:ShowReport(report)
					end, actions)
					view:Dock(LEFT)
					view:SetWide(60 * ss)
					view:DockMargin(0, m, m2, m)

					-- Kapat butonu (sadece yetkililere veya rapor sahibine)
					if (self:IsAdmin(LocalPlayer()) and (report.admin_id == "" or report.admin_id == LocalPlayer():SteamID64())) or 
					   (report.reporter_id == LocalPlayer():SteamID64()) then
						local delete = self:QuickButton("×", function()
							easynet.SendToServer("SH_REPORTS.CloseReport", {id = report.id})
						end, actions, "{prefix}Larger", styl.failure)
						delete:Dock(RIGHT)
						delete:SetWide(30 * ss)
						delete:DockMargin(m2, m, 0, m)
						delete:SetToolTip(self:L("close_report"))
					end

				local line = ilist:AddLine(reporter, reported, reasonText, wait_time, claimed, actions)
				line:SetAlpha(0)
				line:AlphaTo(255, 0.1, 0.1 * i)
				self:LineStyle(line)
				
				report.line = line

				i = i + 1
			end
		end

		-- İlk yükleme
		frame:RefreshReports()

	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.1)
	
	-- Sunucudan güncel listeyi iste
	easynet.SendToServer("SH_REPORTS.RequestList")
end

-- NETWORK CALLBACKS
easynet.Callback("SH_REPORTS.SendList", function(data)
	local pendings = {}
	for _, report in pairs (SH_REPORTS.ActiveReports) do
		if (IsValid(report.pending)) then
			pendings[report.id] = report.pending
		end
	end

	SH_REPORTS.ServerTime = data.server_time
	SH_REPORTS.ActiveReports = data.struct_reports

	for _, report in pairs (SH_REPORTS.ActiveReports) do
		report.pending = pendings[report.id]
	end
	
	-- Eğer rapor listesi açıksa güncelle
	if (IsValid(_SH_REPORTS)) then
		_SH_REPORTS:RefreshReports()
	end
end)

-- ESKİ SİSTEMDEKİ MinimizeReport CALLBACK'İ
easynet.Callback("SH_REPORTS.MinimizeReport", function(data)
	if (IsValid(_SH_REPORTS_VIEW)) then
		_SH_REPORTS_VIEW:Close()
	end

	local report
	for _, rep in pairs (SH_REPORTS.ActiveReports) do
		if (rep.id == data.report_id) then
			report = rep
			break
		end
	end

	if (report) then
		SH_REPORTS:MakeTab(report)
	end
end)

easynet.Callback("SH_REPORTS.ReportClosed", function(data)
	-- Debug log ekleyelim
	print("[SH_REPORTS] Closing report #" .. data.report_id)
	
	for k, rep in pairs (SH_REPORTS.ActiveReports) do
		if (rep.id == data.report_id) then
			-- UI elementlerini kapat
			if (IsValid(rep.line)) then
				rep.line:Remove()  -- Close yerine Remove kullan
				rep.line = nil
			end

			if (IsValid(rep.pending)) then
				rep.pending:Close()
				rep.pending = nil
			end

			-- Raporu listeden sil
			SH_REPORTS.ActiveReports[k] = nil
			break -- Önemli: Döngüden çık
		end
	end

	-- Tab'ı kapat
	if (IsValid(_SH_REPORTS_TAB) and _SH_REPORTS_TAB.id == data.report_id) then
		_SH_REPORTS_TAB:Close()
		_SH_REPORTS_TAB = nil
	end

	-- Pending panel'i kapat (güvenli çağrı)
	if SH_REPORTS.ClosePendingPanel then
		SH_REPORTS:ClosePendingPanel(data.report_id)
	end
	
	-- Eğer rapor listesi açıksa, yenile
	if (IsValid(_SH_REPORTS)) then
		-- Liste açıksa güncelle
		timer.Simple(0.1, function()
			if (IsValid(_SH_REPORTS)) then
				_SH_REPORTS:RefreshReports()
			end
		end)
	end
end)

easynet.Callback("SH_REPORTS.ReportClaimed", function(data)
	for _, rep in pairs (SH_REPORTS.ActiveReports) do
		if (rep.id == data.report_id) then
			rep.admin_id = data.admin_id

			-- Eğer rapor listesi açıksa güncelle
			if (IsValid(_SH_REPORTS)) then
				_SH_REPORTS:RefreshReports()
			end

			if (IsValid(rep.pending)) then
				rep.pending:Close()
			end
		end
	end

	-- GÜVENLİ ÇAĞRI
	if SH_REPORTS.ClosePendingPanel then
		SH_REPORTS:ClosePendingPanel(data.report_id)
	end
end)

easynet.Callback("SH_REPORTS.Notify", function(data)
	-- do NOT do this
	SH_REPORTS:Notify(SH_REPORTS:L(unpack(string.Explode("\t", data.msg))), nil, data.positive and SH_REPORTS.Style.success or SH_REPORTS.Style.failure)
end)

easynet.Callback("SH_REPORTS.Chat", function(data)
	chat.AddText(SH_REPORTS.Style.header, "[" .. SH_REPORTS:L("reports") .. "] ", color_white, data.msg)
end)

easynet.Callback("SH_REPORTS.ReportCreated", function(data)
	SH_REPORTS:ReportCreated(data)
end)

easynet.Callback("SH_REPORTS.ReportsPending", function(data)
	-- POP-UP YERINE SADECE CHAT MESAJI
	local realCount = 0
	for _, report in pairs(data.struct_reports) do
		local reasonData = SH_REPORTS.ReportReasons[report.reason_id]
		if not (type(reasonData) == "table" and reasonData.disabled) then
			realCount = realCount + 1
		end
	end
	
	if realCount > 0 then
		chat.AddText(SH_REPORTS.Style.header, "[" .. SH_REPORTS:L("reports") .. "] ", color_white, SH_REPORTS:L("there_are_x_reports_pending", realCount))
	end

	SH_REPORTS.ActiveReports = table.Copy(data.struct_reports)

	-- POP-UP'LARI OLUŞTURMA! KALDIRILDI
end)

easynet.Callback("SH_REPORTS.AdminLeft", function(data)
	for _, rep in pairs (SH_REPORTS.ActiveReports) do
		if (rep.id == data.report_id) then
			rep.admin_id = ""

			-- Eğer rapor listesi açıksa güncelle
			if (IsValid(_SH_REPORTS)) then
				_SH_REPORTS:RefreshReports()
			end
		end
	end
end)

-- YENİ: Periyodik chat bildirimi
easynet.Callback("SH_REPORTS.PeriodicNotification", function(data)
	if data.count > 0 then
		chat.AddText(
			SH_REPORTS.Style.header, "[" .. SH_REPORTS:L("reports") .. "] ",
			Color(255, 200, 100), "Bekleyen rapor sayısı: ", 
			Color(255, 255, 255), tostring(data.count),
			Color(100, 255, 100), " - Almak için ",
			Color(255, 255, 255), SH_REPORTS.NextReportCommand,
			Color(100, 255, 100), " yazın."
		)
	else
		chat.AddText(
			SH_REPORTS.Style.header, "[" .. SH_REPORTS:L("reports") .. "] ",
			Color(100, 255, 100), "Bekleyen rapor bulunmuyor."
		)
	end
end)

-- YENİ: Otomatik rapor gösterimi (!sıradakirapor için)
easynet.Callback("SH_REPORTS.AutoShowReport", function(data)
	-- Raporu bul
	local report
	for _, rep in pairs(SH_REPORTS.ActiveReports) do
		if rep.id == data.report_id then
			report = rep
			break
		end
	end
	
	-- Rapor bulunduysa detayları göster
	if report then
		SH_REPORTS:ShowReport(report)
	end
end)

-- YENİ: Direkt rapor detaylarını göster
easynet.Callback("SH_REPORTS.DirectShowReport", function(data)
	-- created_time yoksa time'ı kullan (geriye uyumluluk)
	data.created_time = data.created_time or data.time
	
	-- Raporu ActiveReports'a ekle/güncelle
	local found = false
	for _, rep in pairs(SH_REPORTS.ActiveReports) do
		if rep.id == data.id then
			-- Mevcut raporu güncelle
			for k, v in pairs(data) do
				rep[k] = v
			end
			found = true
			break
		end
	end
	
	if not found then
		table.insert(SH_REPORTS.ActiveReports, data)
	end
	
	-- Direkt rapor detaylarını göster (tab yerine)
	SH_REPORTS:ShowReport(data)
end)

-- F8 VE F9 TUŞLARI İÇİN HOOK
hook.Add("PlayerButtonDown", "SH_REPORTS.ClientKeys", function(ply, btn)
	if (!IsFirstTimePredicted()) then return end
	
	-- F8 - Rapor oluştur
	if (btn == SH_REPORTS.ReportKey) then
		if (!SH_REPORTS:IsAdmin(LocalPlayer()) or SH_REPORTS.StaffCanReport) then
			easynet.SendToServer("SH_REPORTS.QuickReport", {comment = "", lastkiller = LocalPlayer().SH_LastKiller, lastarrester = LocalPlayer().SH_LastArrester})
		else
			SH_REPORTS:Notify(SH_REPORTS:L("cannot_report_as_admin"), nil, SH_REPORTS.Style.failure)
		end
	end
	
	-- F9 - Rapor listesi
	if (btn == SH_REPORTS.ReportsKey) then
		-- Superadmin kontrolü
		if (SH_REPORTS.OnlySuperadminCanSeeList and SH_REPORTS:IsAdmin(LocalPlayer()) and LocalPlayer():GetUserGroup() ~= "superadmin") then
			chat.AddText(SH_REPORTS.Style.header, "[" .. SH_REPORTS:L("reports") .. "] ", color_white, "Rapor listesini görme yetkiniz yok. " .. SH_REPORTS.NextReportCommand .. " komutunu kullanın.")
		else
			SH_REPORTS:ShowReports()
		end
	end
end)