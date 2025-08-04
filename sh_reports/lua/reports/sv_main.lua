if (!SH_REPORTS.ActiveReports) then
	SH_REPORTS.ActiveReports = {}
	SH_REPORTS.UniqueID = 0
	SH_REPORTS.InsertSQL = "INSERT IGNORE INTO"
end

if (SH_REPORTS.UseWorkshop) then
	resource.AddWorkshop("1141886968")
else
	resource.AddFile("materials/shenesis/general/back.png")
	resource.AddFile("materials/shenesis/general/close.png")
	resource.AddFile("materials/shenesis/reports/add.png")
	resource.AddFile("materials/shenesis/reports/stats.png")
	resource.AddFile("materials/shenesis/reports/star.png")
	resource.AddFile("resource/fonts/circular.ttf")
	resource.AddFile("resource/fonts/circular_bold.ttf")
end

function SH_REPORTS:DatabaseConnected()
	if (self.DatabaseMode == "mysqloo") then
		self:Query("SHOW TABLES LIKE 'sh_reports_performance'", function(q, ok, data)
			if (!ok) or (data and table.Count(data) > 0) then
				self:PostDatabaseConnected()
				return
			end

			self:Query([[
				CREATE TABLE `sh_reports_performance` (
				  `steamid` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
				  `claimed` int(10) unsigned DEFAULT '0',
				  `closed` int(10) unsigned DEFAULT '0',
				  `timespent` int(10) unsigned DEFAULT '0',
				  `report_id` int(10) unsigned DEFAULT '0',
				  UNIQUE KEY `steamid_UNIQUE` (`steamid`,`report_id`)
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

				CREATE TABLE `sh_reports_performance_reports` (
				  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
				  `start_time` int(10) unsigned DEFAULT '0',
				  `end_time` int(10) unsigned DEFAULT '0',
				  PRIMARY KEY (`id`)
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
			]], function(q2, ok2, data2)
				self:DBPrint("Creating sh_reports_performance and sh_reports_performance_reports: " .. tostring(ok2) .. " (" .. tostring(data2) .. ")")
				self:PostDatabaseConnected()
			end)
		end)

		self:Query("SHOW TABLES LIKE 'sh_reports_performance_ratings'", function(q, ok, data)
			if (!ok) or (data and table.Count(data) > 0) then
				return end

			self:Query([[
				CREATE TABLE `sh_reports_performance_ratings` (
				  `steamid` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
				  `total` int(10) unsigned DEFAULT '0',
				  `num` int(10) unsigned DEFAULT '0',
				  PRIMARY KEY (`steamid`)
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
			]], function(q2, ok2, data2)
				self:DBPrint("Creating sh_reports_performance_ratings: " .. tostring(ok2) .. " (" .. tostring(data2) .. ")")
			end)
		end)

		self:Query("SHOW TABLES LIKE 'sh_reports_performance_history'", function(q, ok, data)
			if (!ok) or (data and table.Count(data) > 0) then
				return end

			self:Query([[
				CREATE TABLE `sh_reports_performance_history` (
				  `id` int(10) unsigned NOT NULL,
				  `reporter` varchar(64) NOT NULL,
				  `reported` varchar(64) NOT NULL,
				  `reason` varchar(256),
				  `comment` varchar(2048),
				  `waiting_time` int(10) unsigned DEFAULT '0',
				  `date` int(10) unsigned DEFAULT '0',
				  `admin` varchar(64) NOT NULL,
				  `rating` int(10) unsigned DEFAULT '0',
				  PRIMARY KEY (`id`)
				) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
			]], function(q2, ok2, data2)
				self:DBPrint("Creating sh_reports_performance_history: " .. tostring(ok2) .. " (" .. tostring(data2) .. ")")
			end)
		end)
	else
		local function CreateTable(name, query)
			if (!sql.TableExists(name)) then
				sql.Query([[
					CREATE TABLE `]] .. name .. [[` (]] .. query .. [[)
				]])

				self:DBPrint("Creating " .. name .. ": " .. tostring(sql.TableExists(name)))
			end
		end

		CreateTable("sh_reports_performance", [[
			`steamid` varchar(64) NOT NULL,
			`claimed` int(10) DEFAULT '0',
			`closed` int(10) DEFAULT '0',
			`timespent` int(10) DEFAULT '0',
			`report_id` int(10) DEFAULT '0',
			UNIQUE(steamid, report_id) ON CONFLICT IGNORE
		]])

		CreateTable("sh_reports_performance_reports", [[
			`id` int(10) NOT NULL PRIMARY KEY,
			`start_time` int(10) DEFAULT '0',
			`end_time` int(10) DEFAULT '0'
		]])

		CreateTable("sh_reports_performance_ratings", [[
			`steamid` varchar(64) NOT NULL PRIMARY KEY,
			`total` int(10) DEFAULT '0',
			`num` int(10) DEFAULT '0'
		]])

		CreateTable("sh_reports_performance_history", [[
			`id` int(10) NOT NULL PRIMARY KEY,
			`reporter` varchar(64) NOT NULL,
			`reported` varchar(64) NOT NULL,
			`reason` varchar(256),
			`comment` varchar(2048),
			`waiting_time` int(10) DEFAULT '0',
			`date` int(10) DEFAULT '0',
			`admin` varchar(64) NOT NULL,
			`rating` int(5) DEFAULT '0'
		]])

		self.InsertSQL = "INSERT OR IGNORE INTO"
		self:PostDatabaseConnected()
	end
end

function SH_REPORTS:PostDatabaseConnected()
	self:BetterQuery("SELECT * FROM sh_reports_performance_reports WHERE {time} < end_time ORDER BY id DESC", {time = os.time()}, function(q, ok, data)
		if (!ok) then
			return end

		if (data and #data > 0) then
			local d = table.Copy(data[1])
			d.id = tonumber(d.id)
			d.start_time = tonumber(d.start_time)
			d.end_time = tonumber(d.end_time)

			self.CurrentPerfReport = d
			self:DBPrint("Using performance report #" .. d.id .. ". It will last until " .. os.date(self.DateFormat, d.end_time) .. " 00:00.")
		else
			self:DBPrint("Creating new performance report as none were found.")
			self:CreatePerformanceReport()
		end
	end)

	if (self.StorageExpiryTime > 0) then
		self:BetterQuery("DELETE FROM sh_reports_performance_history WHERE {time} > date", {time = os.time() - self.StorageExpiryTime})
	end
end

function SH_REPORTS:CreatePerformanceReport()
	local days = 1
	if (self.PerformanceFrequency == "weekly") then
		days = 7 - tonumber(os.date("%w")) + self.PerformanceWeekDay
	elseif (self.PerformanceFrequency == "monthly") then
		days = 31
	end
	local mthen = self:GetMidnight(days)

	self:Query("SELECT id FROM sh_reports_performance_reports", function(q, ok, data)
		if (!ok) then
			return end

		local d = {id = table.Count(data) + 1, start_time = os.time(), end_time = mthen}
		self.CurrentPerfReport = d

		self:BetterQuery([[
			INSERT INTO sh_reports_performance_reports (id, start_time, end_time)
			VALUES ({id}, {start_time}, {end_time})
		]], d)

		self:DBPrint("Created performance report #" .. d.id .. ". It will last until " .. os.date(self.DateFormat, mthen) .. " 00:00.")
	end)

	self.CachedPerfReports = nil
end


function SH_REPORTS:PlayerSay(ply, str)
	local text = str:Replace("!", "/"):lower():Trim()

	if (self.AdminCommands[text]) then
		-- Sadece superadmin rapor listesini görebilir
		if (self.OnlySuperadminCanSeeList and ply:GetUserGroup() ~= "superadmin") then
			self:Notify(ply, "Rapor listesini görme yetkiniz yok. " .. self.NextReportCommand .. " komutunu kullanın.", false)
			return ""
		end
		self:ShowReports(ply)
		return ""
	end

	-- Sıradaki rapor komutu - DÜZELTİLDİ!
	local nextCmd = self.NextReportCommand:Replace("!", "/"):lower()
	if (text == nextCmd) then
		if (!self:IsAdmin(ply)) then
			self:Notify(ply, "not_allowed_to_run_cmd", false)
			return ""
		end

		self:AssignNextReport(ply)
		return ""
	end

	if (self.ReportCommands[text]) then
		if (!self:IsAdmin(ply) or self.StaffCanReport) then
			easynet.Send(ply, "SH_REPORTS.QuickReport", {comment = "", lastkiller = ply.SH_LastKiller, lastarrester = ply.SH_LastArrester})
		else
			self:Notify(ply, "cannot_report_as_admin", false)
		end

		return ""
	end

	if (self.EnableQuickReport and !self:IsAdmin(ply) and text:StartWith("@")) then
		easynet.Send(ply, "SH_REPORTS.QuickReport", {comment = str:sub(2), lastkiller = ply.SH_LastKiller, lastarrester = ply.SH_LastArrester})
		return ""
	end

	if (text == "/reportstats") then
		if (self:IsAdmin(ply)) then
			self:BetterQuery("SELECT * FROM sh_reports_performance WHERE steamid = {steamid}", {steamid = ply:SteamID64()}, function(q, ok, data)
				if (!ok or !IsValid(ply)) then
					return end

				local claimed = 0
				local closed = 0
				for _, d in pairs (data) do
					claimed = claimed + tonumber(d.claimed)
					closed = closed + tonumber(d.closed)
				end

				ply:ChatPrint("Reports claimed: " .. string.Comma(claimed) .. " | Reports closed: " .. string.Comma(closed))
			end)
		end

		return ""
	end
end

function SH_REPORTS:ShowReports(ply)
	local tosend = {}
	if (self:IsAdmin(ply)) then -- If admin, send all reports, if not only send own
		tosend = self:GetAllReports()
	else
		tosend = self:GetAllReports(ply:SteamID64())
	end

	easynet.Send(ply, "SH_REPORTS.SendList", {
		server_time = os.time(),
		struct_reports = tosend,
	})
end

local function SendPerfReports(ply, preps)
	easynet.Send(ply, "SH_REPORTS.SendPerfReports", {
		struct_perf_reports = preps
	})
end

function SH_REPORTS:ShowPerformanceReports(ply)
	if (!self.UsergroupsPerformance[ply:GetUserGroup()]) then
		self:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end

	if (self.CachedPerfReports) then
		SendPerfReports(ply, self.CachedPerfReports)
	else
		self:BetterQuery("SELECT * FROM sh_reports_performance_reports", {time = os.time()}, function(q, ok, data)
			if (!ok or !IsValid(ply)) then
				return end

			local d = {}
			for k, v in pairs (data) do
				d[tonumber(v.id)] = v
			end

			self.CachedPerfReports = d
			if (IsValid(ply)) then
				SendPerfReports(ply, d)
			end
		end)
	end
end

function SH_REPORTS:RequestPerfReportStaff(ply, id)
	if (!self.UsergroupsPerformance[ply:GetUserGroup()]) then
		self:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end

	self:BetterQuery("SELECT steamid, claimed, closed, timespent FROM sh_reports_performance WHERE report_id = {id}", {id = id}, function(q, ok, data)
		if (!ok or !IsValid(ply)) then
			return end
		
		for k, v in pairs (data) do
			v.claimed = tonumber(v.claimed) or 0
			v.closed = tonumber(v.closed) or 0
			v.timespent = tonumber(v.timespent) or 0
		end

		easynet.Send(ply, "SH_REPORTS.SendPerfReportStaff", {
			id = id,
			struct_perf_reports_staff = data
		})
	end)
end

function SH_REPORTS:RequestStaffRatings(ply)
	if (!self.UsergroupsPerformance[ply:GetUserGroup()]) then
		self:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end

	self:BetterQuery("SELECT steamid, num, total FROM sh_reports_performance_ratings", {}, function(q, ok, data)
		if (!ok or !IsValid(ply)) then
			return end

		easynet.Send(ply, "SH_REPORTS.SendRatings", {
			struct_rating = data
		})
	end)
end

function SH_REPORTS:RequestReportHistory(ply)
	if (!self.UsergroupsPerformance[ply:GetUserGroup()]) then
		self:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end

	self:BetterQuery("SELECT * FROM sh_reports_performance_history", {}, function(q, ok, data)
		if (!ok or !IsValid(ply)) then
			return end

		-- Factorize the SteamID's to save on bytes
		local t_steamids = {}

		local t = {}
		for _, dat in pairs (data) do
			t[tonumber(dat.id)] = dat

			t_steamids[dat.reporter] = true
			t_steamids[dat.reported] = true
			t_steamids[dat.admin] = true
		end

		local steamids = {}
		for steamid in pairs (t_steamids) do
			t_steamids[steamid] = table.insert(steamids, {steamid = steamid})
		end

		local t_list = {}
		for id, dat in pairs (t) do
			table.insert(t_list, {
				report_id = tonumber(dat.id),
				reporter_nid = t_steamids[dat.reporter],
				reported_nid = t_steamids[dat.reported],
				reason = dat.reason,
				comment = dat.comment,
				rating = dat.rating,
				date = dat.date,
				waiting_time = dat.waiting_time,
				admin_nid = t_steamids[dat.admin],
			})
		end

		easynet.Send(ply, "SH_REPORTS.SendHistoryList", {
			struct_history_steamids = steamids,
			struct_history_list = t_list,
		})
	end)
end

function SH_REPORTS:ClaimReport(admin, report)
	local sid = admin:SteamID64()
	
	-- Aktif sit kontrolü
	if self:HasActiveSit(admin) then
		self:Notify(admin, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
		return false
	end
	
	for _, rep in pairs (self:GetAllReports()) do
		if (rep.admin_id == sid) then
			self:Notify(admin, "claimed_report_still_active", false)
			return false
		end
	end

	if (report.admin_id ~= "") then
		return false
	end

	report.claim_time = os.time()
	report.admin_id = sid
	self:Notify(player.GetBySteamID64(report.reporter_id), "admin_claimed_your_report", true)

	easynet.Send(admin, "SH_REPORTS.MinimizeReport", {report_id = report.id})
	easynet.Send(self:GetStaff(), "SH_REPORTS.ReportClaimed", {report_id = report.id, admin_id = report.admin_id})

	if (self.CurrentPerfReport) and (!report.is_admin or self.AdminReportsCount) then
		self:BetterQuery([[
			]] .. self.InsertSQL .. [[ sh_reports_performance (steamid, report_id)
			VALUES ({steamid}, {report_id});
			UPDATE sh_reports_performance SET claimed = claimed + 1
			WHERE steamid = {steamid} AND report_id = {report_id}
		]], {steamid = admin:SteamID64(), report_id = self.CurrentPerfReport.id})
	end
	
	-- Otomatik sit başlatma (30 saniye gecikmeli)
	if self.AutoStartSit then
		self:StartDelayedSit(admin, report)
	end

	return true
end

-- Aktif sit kontrolü
function SH_REPORTS:HasActiveSit(admin)
	-- GAS AdminSits kontrolü
	if GAS and GAS.AdminSits and GAS.AdminSits.Sits then
		for _, sit in pairs(GAS.AdminSits.Sits) do
			if sit and not sit.Ended then
				for _, ply in pairs(sit.InvolvedPlayers:sequential()) do
					if IsValid(ply) and ply == admin then
						return true
					end
				end
			end
		end
	end
	
	return false
end

-- Gecikmeli sit başlatma
function SH_REPORTS:StartDelayedSit(admin, report)
	local reporter = player.GetBySteamID64(report.reporter_id)
	local reported = player.GetBySteamID64(report.reported_id)
	
	if not IsValid(reporter) then
		self:Notify(admin, "Rapor eden oyuncu sunucuda değil!", false)
		return
	end
	
	-- Pozisyonları kaydet
	admin.SH_PosBeforeReport = admin:GetPos()
	if IsValid(reporter) then
		reporter.SH_PosBeforeReport = reporter:GetPos()
	end
	if IsValid(reported) then
		reported.SH_PosBeforeReport = reported:GetPos()
	end
	
	-- Geri sayım başlat
	local countdown = self.SitCountdown or 30
	local timerName = "SH_REPORTS_SitCountdown_" .. report.id
	
	-- İlk bildirim
	local players = {reporter}
	if IsValid(reported) then
		table.insert(players, reported)
	end
	
	for _, ply in ipairs(players) do
		if IsValid(ply) then
			easynet.Send(ply, "SH_REPORTS.Chat", {
				msg = tostring(countdown) .. " saniye içinde sit'e ışınlanacaksınız! Hazırlanın."
			})
			-- Ses efekti
			ply:EmitSound("buttons/blip1.wav")
		end
	end
	
	-- Admin'e bilgi
	easynet.Send(admin, "SH_REPORTS.Chat", {
		msg = "Sit " .. countdown .. " saniye sonra başlayacak."
	})
	
	timer.Create(timerName, 5, countdown / 5, function()
		countdown = countdown - 5
		
		if countdown <= 0 then
			-- Sit başlat
			timer.Remove(timerName)
			
			if not IsValid(admin) then return end
			
			-- Oyuncuları kontrol et
			local validReporter = IsValid(reporter)
			local validReported = IsValid(reported) and reported ~= reporter
			
			if not validReporter then
				self:Notify(admin, "Rapor eden oyuncu sunucudan ayrıldı!", false)
				return
			end
			
			-- GAS AdminSit başlat
			if GAS and GAS.AdminSits then
				local sitPlayers = {admin}
				if validReporter then table.insert(sitPlayers, reporter) end
				if validReported then table.insert(sitPlayers, reported) end
				
				local sit = GAS.AdminSits:CreateSit(admin, sitPlayers)
				if sit and sit.ID then
					report.gas_sit_id = sit.ID
					report.sit_started = true
				end
			end
			
			self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> started auto-sit for report #" .. report.id)
		else
			-- Uyarı mesajları
			for _, ply in ipairs(players) do
				if IsValid(ply) then
					easynet.Send(ply, "SH_REPORTS.Chat", {
						msg = tostring(countdown) .. " saniye kaldı!"
					})
					-- Ses efekti
					if countdown <= 10 then
						ply:EmitSound("buttons/button17.wav")
					else
						ply:EmitSound("buttons/blip1.wav")
					end
				end
			end
		end
	end)
	
	-- İptal etme timer'ı (admin disconnect vb.)
	timer.Create(timerName .. "_Check", 1, countdown, function()
		if not IsValid(admin) or not self:FindReport(report.id) then
			timer.Remove(timerName)
			timer.Remove(timerName .. "_Check")
		end
	end)
end

function SH_REPORTS:ClaimAndTeleport(admin, id, bring, bring_reported)
	if (!self:IsAdmin(admin)) then
		self:Notify(admin, "not_allowed_to_run_cmd", false)
		return
	end

	local report = self:FindReport(id)
	if (!report) then
		self:Notify(admin, "report_non_existent", false)
		return
	end

	if (self.ClaimNoTeleport) then
		return end
		
	-- Aktif sit kontrolü
	if self:HasActiveSit(admin) then
		self:Notify(admin, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
		return
	end

	local target = player.GetBySteamID64(report.reporter_id)
	if (!IsValid(target)) then
		return end

	-- Raporu üstlen ama otomatik sit başlatma
	local oldAutoStart = self.AutoStartSit
	self.AutoStartSit = false
	
	if (!self:ClaimReport(admin, report)) then
		self.AutoStartSit = oldAutoStart
		return
	end
	
	self.AutoStartSit = oldAutoStart

	admin.SH_PosBeforeReport = admin:GetPos()
	target.SH_PosBeforeReport = target:GetPos()

	if (self.UseULXCommands) then
		-- Bad idea? ULX sucks anyways
		if (bring) then
			ulx.bring(admin, {target})
		else
			ulx.goto(admin, target)
		end

		if (bring_reported) then
			local reported = player.GetBySteamID64(report.reported_id)
			if (IsValid(reported)) then
				reported.SH_PosBeforeReport = reported:GetPos()

				if (bring) then
					ulx.bring(admin, {reported})
				else
					ulx.send(admin, reported, target)
				end
			end
		end
	else
		local a, b = admin, target
		if (bring) then
			a, b = target, admin
		end

		self:TeleportPlayer(a, b:GetPos())

		if (bring_reported) then
			local reported = player.GetBySteamID64(report.reported_id)
			if (IsValid(reported)) then
				reported.SH_PosBeforeReport = reported:GetPos()

				self:TeleportPlayer(reported, b:GetPos())
			end
		end
	end

	self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> claimed " .. target:Nick() .. "'s <" .. target:SteamID() .. "> report [#" .. id .. "]")
end

function SH_REPORTS:ClaimAndCSit(admin, id)
	-- GmodAdminSuite kontrolü
	if (GAS and GAS.AdminSits) then
		if (!self:IsAdmin(admin)) then
			self:Notify(admin, "not_allowed_to_run_cmd", false)
			return
		end
		
		-- Aktif sit kontrolü
		if self:HasActiveSit(admin) then
			self:Notify(admin, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
			return
		end

		local report = self:FindReport(id)
		if (!report) then
			self:Notify(admin, "report_non_existent", false)
			return
		end

		local target = player.GetBySteamID64(report.reporter_id)
		if (!IsValid(target)) then
			return
		end

		-- Raporu üstlen ama otomatik sit başlatma
		local oldAutoStart = self.AutoStartSit
		self.AutoStartSit = false
		
		if (!self:ClaimReport(admin, report)) then
			self.AutoStartSit = oldAutoStart
			return
		end
		
		self.AutoStartSit = oldAutoStart

		admin.SH_PosBeforeReport = admin:GetPos()
		target.SH_PosBeforeReport = target:GetPos()

		-- Oyuncuları hazırla
		local players = {admin} -- Admin'i de ekle
		if target ~= admin then
			table.insert(players, target)
		end
		
		local reported = player.GetBySteamID64(report.reported_id)
		if (IsValid(reported) and reported ~= admin and reported ~= target) then
			reported.SH_PosBeforeReport = reported:GetPos()
			table.insert(players, reported)
		end

		-- GAS AdminSit başlat
		local sit = GAS.AdminSits:CreateSit(admin, players)
		if (sit and sit.ID) then
			report.gas_sit_id = sit.ID
		end

		self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> claimed " .. target:Nick() .. "'s <" .. target:SteamID() .. "> report [#" .. id .. "] and started a GAS admin sit")
		return
	end

	-- Eski csitsystem desteği (eğer GAS yoksa)
	if (!csitsystem) then
		return
	end

	if (!self:IsAdmin(admin)) then
		self:Notify(admin, "not_allowed_to_run_cmd", false)
		return
	end

	local report = self:FindReport(id)
	if (!report) then
		self:Notify(admin, "report_non_existent", false)
		return
	end

	local target = player.GetBySteamID64(report.reporter_id)
	if (!IsValid(target)) then
		return end

	-- Raporu üstlen ama otomatik sit başlatma
	local oldAutoStart = self.AutoStartSit
	self.AutoStartSit = false
	
	if (!self:ClaimReport(admin, report)) then
		self.AutoStartSit = oldAutoStart
		return
	end
	
	self.AutoStartSit = oldAutoStart

	admin.SH_PosBeforeReport = admin:GetPos()
	target.SH_PosBeforeReport = target:GetPos()

	report.sit_id = csitsystem.HandOver(admin, target, player.GetBySteamID64(report.reported_id))

	self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> claimed " .. target:Nick() .. "'s <" .. target:SteamID() .. "> report [#" .. id .. "] and started a sit")
end

function SH_REPORTS:CloseReport(ply, id)
	local report = self:FindReport(id)
	if (!report) then
		self:Notify(ply, "report_non_existent", false)
		return
	end

	local sid = ply:SteamID64()
	
	-- Yetki kontrolü
	if (self:IsAdmin(ply) and ((report.admin_id == "" and self.CanDeleteWhenUnclaimed) or report.admin_id == sid)) or (report.reporter_id == sid) then
		-- YENİ: Chat bildirim değişkenleri
		local adminName = ply:Nick()
		local isAdminClosing = self:IsAdmin(ply) and report.reporter_id ~= sid
		
		-- Raporu sil
		self.ActiveReports[id] = nil
		
		-- Geri sayım timer'larını temizle
		timer.Remove("SH_REPORTS_SitCountdown_" .. id)
		timer.Remove("SH_REPORTS_SitCountdown_" .. id .. "_Check")

		-- Debug log
		print("[SH_REPORTS] Report #" .. id .. " closed by " .. ply:Nick())

		-- Bildirimleri gönder
		self:Notify(ply, "report_closed", true)
		
		-- TÜM oyunculara rapor kapatıldı mesajını gönder (güvenilirlik için)
		for _, p in ipairs(player.GetAll()) do
			easynet.Send(p, "SH_REPORTS.ReportClosed", {report_id = id})
		end

		-- YENİ: Chat bildirimleri
		if isAdminClosing then
			-- Rapor eden kişiye chat bildirimi
			local reporter = player.GetBySteamID64(report.reporter_id)
			if IsValid(reporter) then
				easynet.Send(reporter, "SH_REPORTS.Chat", {
					msg = "Raporunuz " .. adminName .. " tarafından kapatıldı."
				})
			end
			
			-- Rapor edilen kişiye chat bildirimi (eğer varsa ve online ise)
			if report.reported_id ~= "0" then
				local reported = player.GetBySteamID64(report.reported_id)
				if IsValid(reported) then
					easynet.Send(reported, "SH_REPORTS.Chat", {
						msg = "Hakkınızdaki rapor " .. adminName .. " tarafından kapatıldı."
					})
				end
			end
		elseif report.reporter_id == sid then
			-- Rapor eden kendi raporunu kapattı
			-- Eğer yetkili varsa ona bildir
			if report.admin_id ~= "" then
				local admin = player.GetBySteamID64(report.admin_id)
				if IsValid(admin) and admin ~= ply then
					easynet.Send(admin, "SH_REPORTS.Chat", {
						msg = report.reporter_name .. " kendi raporunu kapattı."
					})
				end
			end
		end

		-- Rapor sahibine özel bildirim
		local target = player.GetBySteamID64(report.reporter_id)
		if (IsValid(target)) then
			if (report.reporter_id ~= sid) then
				self:Notify(target, "your_report_was_closed", true)
			elseif (report.admin_id ~= "") then
				local admin = player.GetBySteamID64(report.admin_id)
				if (IsValid(admin) and admin ~= ply) then
					self:Notify(admin, "reporter_closed_report", true)
				end
			end
		end

		-- GAS sit kontrolü - DÜZELTİLMİŞ
		if (report.gas_sit_id and GAS and GAS.AdminSits and GAS.AdminSits.Sits) then
			local sit = GAS.AdminSits.Sits[report.gas_sit_id]
			if (sit and not sit.Ended) then
				GAS.AdminSits:EndSit(sit)
			end
		end

		-- Eski csitsystem kontrolü
		if (report.sit_id and csitsystem) then
			pcall(function() csitsystem.EndSit(report.sit_id) end)
		end

		-- Oyuncuları geri gönder
		if (self.TeleportPlayersBack) then
			if (IsValid(target)) then
				self:ReturnPlayer(target)
			end

			local admin = player.GetBySteamID64(report.admin_id)
			if (IsValid(admin)) then
				self:ReturnPlayer(admin)
			end

			local reported = player.GetBySteamID64(report.reported_id)
			if (IsValid(reported)) then
				self:ReturnPlayer(reported)
			end
		end

		if (!report.is_admin or self.AdminReportsCount) then
			if (report.admin_id ~= "") then
				local claim_time = os.time() - report.claim_time

				if (self.CurrentPerfReport) then
					self:BetterQuery([[
						]] .. self.InsertSQL .. [[ sh_reports_performance (steamid, report_id, timespent)
						VALUES ({steamid}, {report_id}, {timespent});
						UPDATE sh_reports_performance SET closed = closed + 1, timespent = timespent + {timespent}
						WHERE steamid = {steamid} AND report_id = {report_id}
					]], {steamid = report.admin_id, report_id = self.CurrentPerfReport.id, timespent = claim_time})
				end

				-- PARA ÖDÜLÜ SİSTEMİ (GÜNCELLENDİ - ÜST ÜSTE AYNI OYUNCU KONTROLÜ)
				local admin = player.GetBySteamID64(report.admin_id)
				if (self.RewardEnabled and IsValid(admin) and sid == report.admin_id) then
					-- SIT KONTROLÜ: Sadece sit başlatıldıysa para ver
					if (report.sit_started or report.gas_sit_id or report.sit_id) then
						-- ÜST ÜSTE AYNI OYUNCU KONTROLÜ
						if not admin.LastReportReward then
							admin.LastReportReward = {}
						end
						
						-- Son ödül alınan rapor bu oyuncudan mı?
						if admin.LastReportReward.reporter_id == report.reporter_id then
							-- Aynı oyuncudan üst üste rapor - para verme
							if (self.RewardNotification) then
								DarkRP.notify(admin, 1, 4, "Aynı oyuncudan üst üste rapor! Para ödülü verilmedi.")
							end
							
							-- Log kaydı
							self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> closed consecutive report from same player - no reward")
							
							-- Yine de bu raporu kaydet (bir sonraki farklı olabilir)
							admin.LastReportReward = {
								reporter_id = report.reporter_id,
								time = os.time()
							}
						else
							-- PARA VER
							local usergroup = admin:GetUserGroup()
							local reward = self.RewardAmounts[usergroup]
							
							if (reward and reward > 0) then
								-- DarkRP para sistemi
								if (self.MoneySystem == "darkrp" and admin.addMoney) then
									admin:addMoney(reward)
									
									if (self.RewardNotification) then
										DarkRP.notify(admin, 0, 4, "Raporu kapattığınız için " .. DarkRP.formatMoney(reward) .. " kazandınız!")
									end
								end
								
								-- Log kaydı
								self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> received " .. reward .. " money for closing report #" .. id)
								
								-- Son ödül alınan raporu kaydet
								admin.LastReportReward = {
									reporter_id = report.reporter_id,
									time = os.time()
								}
							end
						end
					else
						-- Sit başlatılmadıysa bildirim
						if (self.RewardNotification) then
							DarkRP.notify(admin, 1, 4, "Sit başlatılmadığı için para ödülü verilmedi!")
						end
					end
				end

				if (sid == report.reporter_id) then
					self:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> closed their own report [#" .. id .. "]")
				else
					if (IsValid(target) and self.AskRating) then
						if (!target.SH_ReportsCompleted) then
							target.SH_ReportsCompleted = {}
						end
						target.SH_ReportsCompleted[id] = ply:SteamID64()

						easynet.Send(target, "SH_REPORTS.PromptRating", {report_id = id, admin_name = ply:Nick()})
					end

					self:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> closed the report [#" .. id .. "] from " .. report.reporter_name .. "<" .. util.SteamIDFrom64(report.reporter_id) .. ">")
				end
			elseif (self:IsAdmin(ply)) then
				if (self.CurrentPerfReport) then
					self:BetterQuery([[
						]] .. self.InsertSQL .. [[ sh_reports_performance (steamid, report_id)
						VALUES ({steamid}, {report_id});
						UPDATE sh_reports_performance SET closed = closed + 1
						WHERE steamid = {steamid} AND report_id = {report_id}
					]], {steamid = sid, report_id = self.CurrentPerfReport.id})
				end

				if (sid == report.reporter_id) then
					self:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> closed their own UNCLAIMED report [#" .. id .. "]")
				else
					self:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> closed the UNCLAIMED report [#" .. id .. "] from " .. report.reporter_name .. "<" .. util.SteamIDFrom64(report.reporter_id) .. ">")
				end
			end
		end

		if (report.admin_id ~= "" and self.StoreCompletedReports ~= "none") then
			-- Reason'ı doğru şekilde al
			local reasonText = self.ReportReasons[report.reason_id]
			if type(reasonText) == "table" then
				reasonText = reasonText.reason
			end
			
			self:BetterQuery([[
				]] .. self.InsertSQL .. [[ sh_reports_performance_history (id, reporter, reported, reason, comment, waiting_time, date, admin)
				VALUES ({id}, {reporter}, {reported}, {reason}, {comment}, {waiting_time}, {date}, {admin});
			]], {id = id, reporter = report.reporter_id, reported = report.reported_id, reason = reasonText, comment = report.comment, waiting_time = os.time() - report.time, date = os.time(), admin = report.admin_id})
		end
	else
		self:Notify(ply, "not_allowed_to_run_cmd", false)
	end
end

function SH_REPORTS:RateAdmin(ply, report_id, rating)
	if (!ply.SH_ReportsCompleted or !ply.SH_ReportsCompleted[report_id]) then
		self:Notify(ply, "report_non_existent", false)
		return
	end

	local admin_id = ply.SH_ReportsCompleted[report_id]
	rating = math.Clamp(rating, 1, 5)

	self:BetterQuery([[
		]] .. self.InsertSQL .. [[ sh_reports_performance_ratings (steamid, total, num)
		VALUES ({steamid}, 0, 0);
		UPDATE sh_reports_performance_ratings SET total = total + {rating}, num = num + 1
		WHERE steamid = {steamid}
	]], {steamid = admin_id, rating = rating})

	if (self.StoreCompletedReports ~= "none") then
		self:BetterQuery([[
			UPDATE sh_reports_performance_history SET rating = {rating}
			WHERE id = {id}
		]], {id = report_id, rating = rating})
	end

	if (self.NotifyRating) then
		local admin = player.GetBySteamID64(admin_id)
		if (IsValid(admin)) then
			local rstr = ""
			for i = 1, 5 do
				rstr = rstr .. (rating >= i and "★" or "☆")
			end

			self:Notify(admin, "rate_notification\t" .. ply:Nick() .. "\t" .. rstr, rating >= 3)
		end
	end

	ply.SH_ReportsCompleted[report_id] = nil
	self:Notify(ply, "rate_thanks", true)
end

function SH_REPORTS:PlayerReady(ply)
	if (self.NotifyAdminsOnConnect and self:IsAdmin(ply)) then
		local num = 0
		local pending = {}
		for id, report in pairs (self:GetAllReports()) do
			if (report.admin_id == "") then
				-- Yetkili şikayetlerini dahil etme
				local reasonData = self.ReportReasons[report.reason_id]
				if not (type(reasonData) == "table" and reasonData.disabled) then
					num = num + 1
					table.insert(pending, report)
				end
			end
		end

		if (num > 0) then
			easynet.Send(ply, "SH_REPORTS.ReportsPending", {num = num, struct_reports = pending})
		end
	end
end

-- Mevcut PlayerDisconnected fonksiyonunu bul ve güncelle:
function SH_REPORTS:PlayerDisconnected(ply)
	local sid = ply:SteamID64()
	for id, report in pairs (self:GetAllReports()) do
		if (report.reporter_id == sid) then
			-- YENİ: Timeout timer'ını temizle
			timer.Remove("SH_REPORTS_Timeout_" .. id)
			
			self.ActiveReports[id] = nil
			easynet.Send(self:GetStaff(), "SH_REPORTS.ReportClosed", {report_id = id})

			local admin = player.GetBySteamID64(report.admin_id)
			if (IsValid(admin)) then
				self:Notify(admin, "reporter_closed_report", false)
			end
		elseif (self:IsAdmin(ply) and report.admin_id == sid) then
			report.admin_id = ""
			easynet.Send(self:GetStaff(), "SH_REPORTS.AdminLeft", {report_id = id})

			local reporter = player.GetBySteamID64(report.reporter_id)
			if (IsValid(reporter)) then
				easynet.Send(reporter, "SH_REPORTS.AdminLeft", {report_id = id})
				self:Notify(reporter, "admin_has_disconnected", false)
			end
		end
	end
end

function SH_REPORTS:ReturnPlayer(ply)
	if (!ply.SH_PosBeforeReport) then
		return end

	ply:SetPos(ply.SH_PosBeforeReport)
	ply.SH_PosBeforeReport = nil
end

function SH_REPORTS:MidnightCheck()
	local perf = self.CurrentPerfReport
	if (!perf) then
		return end

	if (os.time() >= perf.end_time) then
		self:DBPrint("Current performance report #" .. perf.id .. " expired, creating new one..")
		self:CreatePerformanceReport()
	end
end

function SH_REPORTS:Notify(ply, msg, good)
	easynet.Send(ply, "SH_REPORTS.Notify", {msg = msg, positive = good})
end

function SH_REPORTS:GetStaff(ply)
	local t = {}
	for _, v in ipairs (player.GetAll()) do
		if (self:IsAdmin(v)) then
			table.insert(t, v)
		end
	end

	return t
end

local function CheckObstruction(ply, pos)
	local t = {
		start = pos,
		endpos = pos + Vector(0, 0, 72),
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 4),
		filter = ply
	}

	return bit.band(util.PointContents(pos), CONTENTS_SOLID) > 0 or util.TraceHull(t).Hit
end

local coords = {
	Vector(48, 0, 0),
	Vector(-48, 0, 0),
	Vector(0, 48, 0),
	Vector(0, -48, 0),
	Vector(48, 48, 0),
	Vector(-48, 48, 0),
	Vector(48, -48, 0),
	Vector(-48, -48, 0),
}

function SH_REPORTS:TeleportPlayer(ply, pos, exact)
	if (!exact) then
		if (CheckObstruction(ply, pos)) then
			for _, c in ipairs (coords) do
				if (!util.TraceLine({start = pos, endpos = pos + c, filter = ents.GetAll()}).Hit and !CheckObstruction(ply, pos + c)) then
					pos = pos + c
					break
				end
			end
		end
	end

	ply.SH_PositionBeforeTeleport = ply:GetPos()
	ply:SetPos(pos)
end

function SH_REPORTS:FindReport(id)
	return self.ActiveReports[id]
end

function SH_REPORTS:GetAllReports(author)
	local t = {}
	for id, report in pairs (self.ActiveReports) do
		if (author and report.reporter_id ~= author) then
			continue end

		t[id] = report
	end

	return t
end

-- Önceliğe göre sıralanmış rapor listesi döndürür
function SH_REPORTS:GetPrioritizedReports()
	local reports = {}
	
	-- Üstlenilmemiş raporları al
	for id, report in pairs(self.ActiveReports) do
		if report.admin_id == "" then
			-- Yetkili şikayeti kontrolü - bunları dahil etme
			local reasonData = self.ReportReasons[report.reason_id]
			if not (type(reasonData) == "table" and reasonData.disabled) then
				table.insert(reports, report)
			end
		end
	end
	
	-- Önceliğe göre sırala (düşük numara = yüksek öncelik)
	table.sort(reports, function(a, b)
		local priorityA = self.ReportReasons[a.reason_id].priority or 999
		local priorityB = self.ReportReasons[b.reason_id].priority or 999
		
		-- Aynı öncelikte ise zamana göre sırala (eski önce)
		if priorityA == priorityB then
			return a.time < b.time
		end
		
		return priorityA < priorityB
	end)
	
	return reports
end

-- Yetkililere sıradaki raporu atar
function SH_REPORTS:AssignNextReport(admin)
	-- Aktif sit kontrolü
	if self:HasActiveSit(admin) then
		self:Notify(admin, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
		return
	end
	
	-- Zaten üstlendiği rapor var mı kontrol et
	for _, report in pairs(self.ActiveReports) do
		if report.admin_id == admin:SteamID64() then
			self:Notify(admin, "claimed_report_still_active", false)
			return
		end
	end
	
	-- Öncelikli rapor listesini al
	local prioritizedReports = self:GetPrioritizedReports()
	
	if #prioritizedReports == 0 then
		self:Notify(admin, "Bekleyen rapor bulunmuyor.", false)
		return
	end
	
	-- İlk raporu al (en yüksek öncelikli)
	local nextReport = prioritizedReports[1]
	
	-- Raporu üstlen
	if self:ClaimReport(admin, nextReport) then
		-- CHAT MESAJLARI KALDIRILDI!
		-- Sadece tab göster ve otomatik olarak rapor detaylarını aç
		
		-- Önce tab'ı göster
		-- (ClaimReport zaten MinimizeReport gönderiyor, tab otomatik oluşuyor)
		
		-- 0.2 saniye sonra otomatik olarak rapor detaylarını aç
		timer.Simple(0.2, function()
			if IsValid(admin) then
				-- Direkt rapor detaylarını göster
				local reportData = table.Copy(nextReport)
				reportData.created_time = reportData.created_time or reportData.time -- Geriye uyumluluk için
				
				-- DirectShowReport ile rapor detaylarını gönder
				easynet.Send(admin, "SH_REPORTS.DirectShowReport", reportData)
			end
		end)
	end
end

function SH_REPORTS:Log(s)
	if (!self.UseServerLog) then
		return end

	ServerLog(s .. "\n")
end

local function GetPerformanceReport(date, preps)
	for id, ps in pairs (preps) do
		if (date >= ps[1] and date <= ps[2]) then
			return id
		end
	end
end

function SH_REPORTS:RebuildPerformance()
	local preps = {}
	self:BetterQuery("SELECT * FROM sh_reports_performance_reports", {}, function(q, ok, data)
		for k, v in pairs (data) do
			preps[tonumber(v.id)] = {tonumber(v.start_time), tonumber(v.end_time)}
		end

		self:BetterQuery("SELECT * FROM sh_reports_performance_history", {}, function(q, ok, data)
			local staffreps = {}
			for _, rep in SortedPairsByMemberValue (data, "date") do
				local admin = tostring(rep.admin)
				staffreps[admin] = staffreps[admin] or {}
				
				table.insert(staffreps[admin], rep)
			end

			local staffpreps = {}
			for sid, reps in pairs (staffreps) do
				staffpreps[sid] = {}

				for _, rep in pairs (reps) do
					local prepid = GetPerformanceReport(tonumber(rep.date), preps)
					staffpreps[sid][prepid] = staffpreps[sid][prepid] or {}
					table.insert(staffpreps[sid][prepid], rep)
				end
			end
			
			for sid, preps in pairs (staffpreps) do
				for prepid, reps in pairs (preps) do
					local claimed, closed, timespent = 0, 0, 0
					for _, rep in pairs (reps) do
						claimed = claimed + 1
						closed = closed + 1
						timespent = timespent + tonumber(rep.waiting_time)
					end
					
					self:BetterQuery("SELECT * FROM sh_reports_performance WHERE steamid = {steamid} AND report_id = {prepid}", {steamid = sid, prepid = prepid}, function(q, ok, data)
						if (data and data[1]) then
							self:BetterQuery("UPDATE sh_reports_performance SET claimed = {claimed}, closed = {closed}, timespent = {timespent} WHERE steamid = {steamid} AND report_id = {prepid}", {claimed = claimed, closed = closed, timespent = timespent, steamid = sid, prepid = prepid})
						else
							self:BetterQuery("INSERT INTO sh_reports_performance (steamid, claimed, closed, timespent, report_id) VALUES ({steamid}, {claimed}, {closed}, {timespent}, {prepid})", {claimed = claimed, closed = closed, timespent = timespent, steamid = sid, prepid = prepid})
						end
					end)
				end
			end
		end)
	end)
end

-- Debug komutları
concommand.Add("sh_reports_debug", function(ply)
	if not SH_REPORTS:IsAdmin(ply) then return end
	
	print("=== Aktif Raporlar ===")
	for id, report in pairs(SH_REPORTS.ActiveReports) do
		local reasonData = SH_REPORTS.ReportReasons[report.reason_id]
		local reasonText = reasonData
		local extra = ""
		
		if type(reasonData) == "table" then
			reasonText = reasonData.reason .. " (Öncelik: " .. reasonData.priority .. ")"
			if reasonData.disabled then
				extra = " [DEVRE DIŞI - Discord'a yönlendirilir]"
			end
		end
		
		print("Rapor #" .. id)
		print("  Rapor Eden: " .. report.reporter_name)
		print("  Şikayet Edilen: " .. report.reported_name)
		print("  Sebep: " .. reasonText .. extra)
		print("  Admin: " .. (report.admin_id ~= "" and report.admin_id or "Alınmamış"))
		print("  GAS Sit ID: " .. tostring(report.gas_sit_id))
	end
	
	-- Öncelikli sırayı göster
	local prioritized = SH_REPORTS:GetPrioritizedReports()
	if #prioritized > 0 then
		print("\n=== Öncelik Sırası (Yetkili şikayetleri hariç) ===")
		for i, report in ipairs(prioritized) do
			local reasonData = SH_REPORTS.ReportReasons[report.reason_id]
			local reasonText = reasonData
			if type(reasonData) == "table" then
				reasonText = reasonData.reason .. " (Öncelik: " .. reasonData.priority .. ")"
			end
			print(i .. ". Rapor #" .. report.id .. " - " .. reasonText)
		end
	end
end)

-- Zorla senkronizasyon komutu
concommand.Add("sh_reports_sync", function(ply)
	if not SH_REPORTS:IsAdmin(ply) then return end
	
	-- Tüm oyunculara güncel listeyi gönder
	for _, p in ipairs(player.GetAll()) do
		SH_REPORTS:ShowReports(p)
	end
	
	print("[SH_REPORTS] Zorla senkronizasyon yapıldı!")
end)

hook.Add("PlayerDisconnected", "SH_REPORTS.PlayerDisconnected", function(ply)
	SH_REPORTS:PlayerDisconnected(ply)
end)

hook.Add("PlayerSay", "SH_REPORTS.PlayerSay", function(ply, str)
	local r = SH_REPORTS:PlayerSay(ply, str)
	if (r) then
		return r
	end
end)

hook.Add("DoPlayerDeath", "SH_REPORTS.DoPlayerDeath", function(ply, atk, dmginfo)
	if (IsValid(atk) and atk:IsPlayer() and atk ~= ply) then
		ply.SH_LastKiller = atk
	end
end)

hook.Add("playerArrested", "SH_REPORTS.playerArrested", function(ply, time, arrester)
	if (IsValid(arrester) and arrester:IsPlayer() and arrester ~= ply) then
		ply.SH_LastArrester = arrester
	end
end)

hook.Add("PlayerButtonDown", "SH_REPORTS.PlayerButtonDown", function(ply, btn)
	if (!IsFirstTimePredicted()) then
		return end

	if (btn == SH_REPORTS.ReportKey) then
		if (!SH_REPORTS:IsAdmin(ply) or SH_REPORTS.StaffCanReport) then
			easynet.Send(ply, "SH_REPORTS.QuickReport", {comment = "", lastkiller = ply.SH_LastKiller, lastarrester = ply.SH_LastArrester})
		else
			SH_REPORTS:Notify(ply, "cannot_report_as_admin", false)
		end
	elseif (btn == SH_REPORTS.ReportsKey) then
		-- Superadmin kontrolü
		if (SH_REPORTS.OnlySuperadminCanSeeList and SH_REPORTS:IsAdmin(ply) and ply:GetUserGroup() ~= "superadmin") then
			SH_REPORTS:Notify(ply, "Rapor listesini görme yetkiniz yok. " .. SH_REPORTS.NextReportCommand .. " komutunu kullanın.", false)
		else
			SH_REPORTS:ShowReports(ply)
		end
	end
end)

-- GAS AdminSits için düzeltilmiş hook
hook.Add("GAS.AdminSits.SitEnded", "SH_REPORTS.GAS_SitEnded", function(Sit)
	if not Sit then return end
	
	-- Sit ID'yi kullanarak raporu bul
	for reportId, report in pairs(SH_REPORTS.ActiveReports) do
		if report.gas_sit_id == Sit.ID then
			local admin = player.GetBySteamID64(report.admin_id)
			if IsValid(admin) then
				-- Timer kullanarak bir sonraki frame'de kapat
				timer.Simple(0, function()
					SH_REPORTS:CloseReport(admin, reportId)
					SH_REPORTS:Notify(admin, "Sit sonlandığı için rapor otomatik kapatıldı.", true)
				end)
			end
			break
		end
	end
end)

-- GAS AdminSits'in kendi CSit uyumluluğunu kullanalım
if SERVER and csitsystem and csitsystem.EndSit then
	local oldEndSit = csitsystem.EndSit
	csitsystem.EndSit = function(id)
		-- Önce orijinal fonksiyonu çağır
		oldEndSit(id)
		
		-- Sonra raporları kontrol et
		for reportId, report in pairs(SH_REPORTS.ActiveReports) do
			if report.sit_id == id or report.gas_sit_id == id then
				local admin = player.GetBySteamID64(report.admin_id)
				if IsValid(admin) then
					SH_REPORTS:CloseReport(admin, reportId)
					SH_REPORTS:Notify(admin, "Sit sonlandığı için rapor otomatik kapatıldı.", true)
				end
			end
		end
	end
end

timer.Create("SH_REPORTS.MidnightCheck", 1, 0, function()
	SH_REPORTS:MidnightCheck()
end)

-- NewReport callback'ini güncelle (dosyanın sonunda):

easynet.Callback("SH_REPORTS.NewReport", function(data, ply)
	local report = data
	data.reporter_name = ply:Nick()
	data.reporter_id = ply:SteamID64()
	data.time = os.time()
	data.created_time = os.time() -- YENİ
	data.admin_id = ""
	data.comment = data.comment:sub(1, SH_REPORTS.MaxCommentLength)
	data.is_admin = SH_REPORTS:IsAdmin(ply)

	SH_REPORTS:NewReport(ply, data)
end)

easynet.Callback("SH_REPORTS.Claim", function(data, ply)
	if (!SH_REPORTS:IsAdmin(ply)) then
		SH_REPORTS:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end
	
	-- Aktif sit kontrolü
	if SH_REPORTS:HasActiveSit(ply) then
		SH_REPORTS:Notify(ply, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
		return
	end

	local report = SH_REPORTS:FindReport(data.id)
	if (!report) then
		SH_REPORTS:Notify(ply, "report_non_existent", false)
		return
	end

	SH_REPORTS:ClaimReport(ply, report)
end)

easynet.Callback("SH_REPORTS.ClaimAndTeleport", function(data, ply)
	SH_REPORTS:ClaimAndTeleport(ply, data.id, data.bring, data.bring_reported)
end)

easynet.Callback("SH_REPORTS.ClaimAndCSit", function(data, ply)
	SH_REPORTS:ClaimAndCSit(ply, data.id)
end)

easynet.Callback("SH_REPORTS.CloseReport", function(data, ply)
	SH_REPORTS:CloseReport(ply, data.id)
end)

easynet.Callback("SH_REPORTS.RequestPerfReports", function(data, ply)
	SH_REPORTS:ShowPerformanceReports(ply)
end)

easynet.Callback("SH_REPORTS.RequestPerfReportStaff", function(data, ply)
	SH_REPORTS:RequestPerfReportStaff(ply, data.id)
end)

easynet.Callback("SH_REPORTS.PlayerReady", function(data, ply)
	SH_REPORTS:PlayerReady(ply)
end)

easynet.Callback("SH_REPORTS.RateAdmin", function(data, ply)
	SH_REPORTS:RateAdmin(ply, data.report_id, data.rating)
end)

easynet.Callback("SH_REPORTS.RequestStaffRatings", function(data, ply)
	SH_REPORTS:RequestStaffRatings(ply)
end)

easynet.Callback("SH_REPORTS.RequestReportHistory", function(data, ply)
	SH_REPORTS:RequestReportHistory(ply)
end)

easynet.Callback("SH_REPORTS.RequestList", function(data, ply)
	SH_REPORTS:ShowReports(ply)
end)

-- MEVCUT KODLARIN SONUNA (timer.Create("SH_REPORTS.MidnightCheck"... kodundan sonra) EKLE:

-- 2 dakikada bir bekleyen raporları kontrol et ve yetkililere bildir
timer.Create("SH_REPORTS.PeriodicCheck", 120, 0, function() -- 120 saniye = 2 dakika
	local pendingReports = {}
	local pendingCount = 0
	
	-- Bekleyen raporları say (yetkili şikayetleri hariç)
	for id, report in pairs(SH_REPORTS.ActiveReports) do
		if report.admin_id == "" then
			local reasonData = SH_REPORTS.ReportReasons[report.reason_id]
			if not (type(reasonData) == "table" and reasonData.disabled) then
				pendingCount = pendingCount + 1
				table.insert(pendingReports, report)
			end
		end
	end
	
	-- Tüm yetkililere bildirim gönder
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and SH_REPORTS:IsAdmin(ply) then
			easynet.Send(ply, "SH_REPORTS.PeriodicNotification", {
				count = pendingCount
			})
		end
	end
end)

-- NewReport fonksiyonunu güncelle (MEVCUT NewReport fonksiyonunu BUL ve DEĞİŞTİR)
function SH_REPORTS:NewReport(ply, data)
	if (self:IsAdmin(ply) and !self.StaffCanReport) then
		self:Notify(ply, "cannot_report_as_admin", false)
		return
	end

	if (data.reporter_id == data.reported_id) then
		self:Notify(ply, "cannot_report_self", false)
		return
	end
	
	-- Yetkili şikayeti kontrolü
	local reasonData = self.ReportReasons[data.reason_id]
	if type(reasonData) == "table" and reasonData.disabled then
		self:Notify(ply, "Bu kategori için rapor oluşturamazsınız. Discord üzerinden ticket açın: discord.gg/basodark", false)
		return
	end

	local target = player.GetBySteamID64(data.reported_id)
	if (IsValid(target) and self:IsAdmin(target) and !self.StaffCanBeReported) then
		self:Notify(ply, "cannot_report_admin", false)
		return
	end

	local sid = ply:SteamID64()
	if (table.Count(self:GetAllReports(sid)) >= self.MaxReportsPerPlayer) then
		self:Notify(ply, "report_limit_reached", false)
		return
	end

	if (data.reported_id == "0" and !self.CanReportOther) then
		return end

	self.UniqueID = self.UniqueID + 1
	data.id = self.UniqueID
	data.created_time = os.time() -- YENİ: Oluşturulma zamanı
	self.ActiveReports[data.id] = table.Copy(data)

	self:Notify(ply, "report_submitted", true)
	
	-- Rapor sebebi metnini al
	local reasonText = self.ReportReasons[data.reason_id]
	if type(reasonText) == "table" then
		reasonText = reasonText.reason
	end
	
	self:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> reported [#" .. data.id .. "] " .. data.reported_name .. " <" .. util.SteamIDFrom64(data.reported_id) .. "> for " .. reasonText)

	easynet.Send(self:GetStaff(), "SH_REPORTS.ReportCreated", data)
	
	-- YENİ: 30 dakika timeout sistemi başlat
	self:StartReportTimeout(data.id)
	
	-- Yetkili şikayeti değilse tüm yetkililere sadece bekleyen rapor sayısını bildir
	if not (type(reasonData) == "table" and reasonData.disabled) then
		-- Bekleyen rapor sayısını hesapla
		local pendingCount = 0
		for id, report in pairs(self.ActiveReports) do
			if report.admin_id == "" then
				local rd = self.ReportReasons[report.reason_id]
				if not (type(rd) == "table" and rd.disabled) then
					pendingCount = pendingCount + 1
				end
			end
		end
		
		-- Tüm yetkililere sadece bekleyen rapor sayısını bildir (YENİ RAPOR mesajı KALDIRILDI!)
		for _, admin in ipairs(player.GetAll()) do
			if IsValid(admin) and self:IsAdmin(admin) then
				easynet.Send(admin, "SH_REPORTS.PeriodicNotification", {
					count = pendingCount
				})
			end
		end
		
		-- Periyodik timer'ı sıfırla (2 dakika sonra tekrar çalışacak)
		timer.Start("SH_REPORTS.PeriodicCheck")
	end
end

-- Aktif yetkililer var mı kontrol et (superadmin hariç)
-- Aktif yetkililer var mı kontrol et (superadmin hariç)
function SH_REPORTS:HasActiveStaff()
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and self:IsAdmin(ply) and ply:GetUserGroup() ~= "superadmin" then
			return true
		end
	end
	return false
end

-- Rapor timeout sistemini başlat
-- Rapor timeout sistemini başlat
function SH_REPORTS:StartReportTimeout(reportId)
	local report = self:FindReport(reportId)
	if not report then return end
	
	local reporter = player.GetBySteamID64(report.reporter_id)
	if not IsValid(reporter) then return end
	
	-- İlk kontrolü hemen yap
	local hasStaff = self:HasActiveStaff()
	local timeRemaining = 30
	local lastNotification = 0 -- Son bildirim zamanı
	
	-- 1 dakikada bir kontrol et (daha sık bildirim için)
	local timerName = "SH_REPORTS_Timeout_" .. reportId
	timer.Create(timerName, 60, 30, function() -- 60 saniye = 1 dakika, 30 kez = 30 dakika
		-- Rapor hala var mı kontrol et
		local currentReport = self:FindReport(reportId)
		if not currentReport or currentReport.admin_id ~= "" then
			-- Rapor yok veya üstlenilmiş, timer'ı iptal et
			timer.Remove(timerName)
			return
		end
		
		-- Oyuncu hala online mı kontrol et
		local currentReporter = player.GetBySteamID64(report.reporter_id)
		if not IsValid(currentReporter) then
			timer.Remove(timerName)
			return
		end
		
		-- Kalan süreyi hesapla (dakika cinsinden)
		local elapsedMinutes = math.floor((30 - timer.RepsLeft(timerName)))
		timeRemaining = 30 - elapsedMinutes
		
		if timeRemaining <= 0 then
			-- 30 dakika doldu, raporu iptal et
			self.ActiveReports[reportId] = nil
			timer.Remove(timerName)
			
			-- Discord yönlendirme mesajı
			easynet.Send(currentReporter, "SH_REPORTS.Chat", {
				msg = "Raporunuz süre aşımı nedeniyle iptal edildi. Discord sunucumuzdan ticket açabilirsiniz: discord.gg/basodark"
			})
			
			-- Tüm oyunculara rapor kapatıldı mesajını gönder
			for _, p in ipairs(player.GetAll()) do
				easynet.Send(p, "SH_REPORTS.ReportClosed", {report_id = reportId})
			end
			
			-- Log
			self:Log("Report #" .. reportId .. " auto-closed due to timeout (30 minutes)")
		else
			-- 5 dakikada bir bildirim gönder
			if elapsedMinutes - lastNotification >= 5 then
				lastNotification = elapsedMinutes
				
				-- Aktif yetkili kontrolü (superadmin hariç)
				local currentHasStaff = self:HasActiveStaff()
				
				if currentHasStaff then
					-- Yetkili var ama bakılmıyor
					easynet.Send(currentReporter, "SH_REPORTS.Chat", {
						msg = "Raporunuz sırada bekliyor. " .. timeRemaining .. " dakika daha bekleyecek."
					})
				else
					-- Yetkili yok
					easynet.Send(currentReporter, "SH_REPORTS.Chat", {
						msg = "Aktif yetkili bulunmuyor. Raporunuz " .. timeRemaining .. " dakika daha bekleyecek."
					})
				end
			end
		end
	end)
	
	-- İlk mesajı gönder (hemen)
	timer.Simple(1, function()
		if not IsValid(reporter) then return end
		
		local currentReport = self:FindReport(reportId)
		if not currentReport or currentReport.admin_id ~= "" then return end
		
		if hasStaff then
			easynet.Send(reporter, "SH_REPORTS.Chat", {
				msg = "Raporunuz sırada bekliyor. Her 5 dakikada bir bilgilendirileceksiniz."
			})
		else
			easynet.Send(reporter, "SH_REPORTS.Chat", {
				msg = "Aktif yetkili bulunmuyor. Raporunuz 30 dakika boyunca bekleyecek."
			})
		end
	end)
end

-- ClaimReport'u güncelle - timer'ı iptal et
local oldClaimReport = SH_REPORTS.ClaimReport
function SH_REPORTS:ClaimReport(admin, report)
	local result = oldClaimReport(self, admin, report)
	
	if result then
		-- Rapor üstlenildi, timeout timer'ını iptal et
		timer.Remove("SH_REPORTS_Timeout_" .. report.id)
	end
	
	return result
end

-- CloseReport'u güncelle - timer'ı iptal et
local oldCloseReport = SH_REPORTS.CloseReport
function SH_REPORTS:CloseReport(ply, id)
	-- Timer'ı iptal et
	timer.Remove("SH_REPORTS_Timeout_" .. id)
	
	-- Orijinal fonksiyonu çağır
	return oldCloseReport(self, ply, id)
end

-- Oyuncu çıktığında timer'ı temizle kısmı zaten PlayerDisconnected fonksiyonunda hallediliyor