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
		_SH_REPORTS:Close()
		SH_REPORTS:ShowReports()
	end
end)

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
				rep.line:Close()
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
				_SH_REPORTS:Close()
				SH_REPORTS:ShowReports()
			end
		end)
	end
end)

easynet.Callback("SH_REPORTS.ReportClaimed", function(data)
	for _, rep in pairs (SH_REPORTS.ActiveReports) do
		if (rep.id == data.report_id) then
			rep.admin_id = data.admin_id

			if (IsValid(rep.line)) then
				rep.line.claimed.avi:SetSteamID(data.admin_id)
				rep.line.claimed.avi:SetVisible(true)

				local admin = player.GetBySteamID64(data.admin_id)
				if (IsValid(admin)) then
					rep.line.claimed.name:SetTextInset(32, 0)
					rep.line.claimed.name:SetContentAlignment(4)
					rep.line.claimed.name:SetText(admin:Nick())
				end
			end

			if (IsValid(rep.pending)) then
				rep.pending:Close()
			end

			if (data.admin_id ~= LocalPlayer():SteamID64() and IsValid(rep.line) and IsValid(rep.line.delete)) then
				rep.line.delete:Remove()
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

			if (IsValid(rep.line)) then
				rep.line.claimed.avi:SetVisible(false)

				rep.line.claimed.name:SetTextInset(0, 0)
				rep.line.claimed.name:SetContentAlignment(5)
				rep.line.claimed.name:SetText(SH_REPORTS:L("unclaimed"))
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