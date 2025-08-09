-- sv_main.lua dosyasının EN BAŞINA bu kodu ekleyin
-- Mevcut kodu değiştirin, üzerine yazmayın

-- Güvenli başlatma bloğu
local function InitializeReportsTables()
	-- Ana tablo kontrolü
	if not SH_REPORTS then
		SH_REPORTS = {}
		print("[SH_REPORTS] Ana tablo oluşturuldu!")
	end
	
	-- Alt tabloları oluştur
	SH_REPORTS.ActiveReports = SH_REPORTS.ActiveReports or {}
	SH_REPORTS.UniqueID = SH_REPORTS.UniqueID or 0
	SH_REPORTS.InsertSQL = SH_REPORTS.InsertSQL or "INSERT IGNORE INTO"
	SH_REPORTS.ActiveSits = SH_REPORTS.ActiveSits or {}
	
	-- REZERVASYON TABLOSU - EN ÖNEMLİ
	if not SH_REPORTS.ReservedReports then
		SH_REPORTS.ReservedReports = {}
		print("[SH_REPORTS] ReservedReports tablosu oluşturuldu!")
	end
	
	-- Debug bilgisi
	print("[SH_REPORTS] Sistem başlatıldı. Tablolar:")
	print("  - ActiveReports: " .. table.Count(SH_REPORTS.ActiveReports) .. " rapor")
	print("  - ReservedReports: " .. table.Count(SH_REPORTS.ReservedReports) .. " rezervasyon")
	print("  - ActiveSits: " .. table.Count(SH_REPORTS.ActiveSits) .. " aktif sit")
end

-- Başlatmayı çalıştır
InitializeReportsTables()

-- Hook ile de kontrol et (güvenlik için)
hook.Add("Initialize", "SH_REPORTS.InitTables", function()
	InitializeReportsTables()
end)

-- Sunucu tamamen yüklendiğinde tekrar kontrol
hook.Add("InitPostEntity", "SH_REPORTS.VerifyTables", function()
	timer.Simple(1, function()
		if not SH_REPORTS.ReservedReports then
			SH_REPORTS.ReservedReports = {}
			print("[SH_REPORTS] UYARI: ReservedReports tablosu geç oluşturuldu!")
		end
	end)
end)

-- Workshop/Resource kontrolü
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

-- Dosyanın geri kalanı...

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

-- YENİ: Rezervasyon fonksiyonu
function SH_REPORTS:ReserveReport(reportId, admin)
	-- Eski rezervasyonu temizle (varsa)
	self:ClearReservation(admin)
	
	-- Yeni rezervasyon oluştur
	self.ReservedReports[reportId] = {
		admin = admin,
		admin_id = admin:SteamID64(),
		time = CurTime(),
		expire = CurTime() + 30 -- 30 saniye rezervasyon
	}
	
	-- 30 saniye sonra otomatik temizle
	timer.Create("SH_REPORTS_Reserve_" .. reportId, 30, 1, function()
		if self.ReservedReports[reportId] and self.ReservedReports[reportId].admin_id == admin:SteamID64() then
			self.ReservedReports[reportId] = nil
			
			-- Eğer hala üstlenilmediyse yetkiliyi bilgilendir
			local report = self:FindReport(reportId)
			if report and report.admin_id == "" then
				if IsValid(admin) then
					self:Notify(admin, "Rapor rezervasyon süresi doldu! Tekrar deneyin.", false)
				end
			end
		end
	end)
end

-- YENİ: Rezervasyonu temizle
function SH_REPORTS:ClearReservation(admin)
	local adminId = admin:SteamID64()
	for reportId, reservation in pairs(self.ReservedReports) do
		if reservation.admin_id == adminId then
			self.ReservedReports[reportId] = nil
			timer.Remove("SH_REPORTS_Reserve_" .. reportId)
		end
	end
end

-- GetAvailableReports fonksiyonunu bu şekilde güncelleyin (239. satır civarı)

function SH_REPORTS:GetAvailableReports()
	local reports = {}
	
	-- Güvenlik kontrolü ekle
	if not self.ReservedReports then
		self.ReservedReports = {}
	end
	
	for id, report in pairs(self.ActiveReports) do
		-- Üstlenilmemiş ve rezerve edilmemiş raporlar
		if report.admin_id == "" then
			local isReserved = false
			
			-- Rezervasyon kontrolü (güvenli)
			if self.ReservedReports and self.ReservedReports[id] then
				local reservation = self.ReservedReports[id]
				-- Rezervasyon süresi dolmuş mu?
				if CurTime() > reservation.expire then
					self.ReservedReports[id] = nil
				else
					isReserved = true
				end
			end
			
			-- Rezerve değilse ve yetkili şikayeti değilse
			if not isReserved then
				local reasonData = self.ReportReasons[report.reason_id]
				if not (type(reasonData) == "table" and reasonData.disabled) then
					table.insert(reports, report)
				end
			end
		end
	end
	
	-- Önceliğe göre sırala
	table.sort(reports, function(a, b)
		local priorityA = 999
		local priorityB = 999
		
		local reasonA = self.ReportReasons[a.reason_id]
		local reasonB = self.ReportReasons[b.reason_id]
		
		if type(reasonA) == "table" then
			priorityA = reasonA.priority or 999
		end
		if type(reasonB) == "table" then
			priorityB = reasonB.priority or 999
		end
		
		if priorityA == priorityB then
			return a.time < b.time
		end
		
		return priorityA < priorityB
	end)
	
	return reports
end

-- Boş sit alanı bul
function SH_REPORTS:FindAvailableSitLocation()
	if not self.SitLocations or #self.SitLocations == 0 then
		return nil
	end
	
	for _, location in ipairs(self.SitLocations) do
		local isOccupied = false
		
		for _, sitInfo in pairs(self.ActiveSits) do
			if sitInfo.location == location.pos then
				isOccupied = true
				break
			end
		end
		
		if not isOccupied then
			local nearbyPlayers = false
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:GetPos():Distance(location.pos) < self.SitAreaRadius then
					local inSit = false
					for _, sitInfo in pairs(self.ActiveSits) do
						if sitInfo.players and table.HasValue(sitInfo.players, ply) then
							inSit = true
							break
						end
					end
					
					if not inSit then
						nearbyPlayers = true
						break
					end
				end
			end
			
			if not nearbyPlayers then
				return location
			end
		end
	end
	
	return self.SitLocations[1]
end

-- Oyuncuları sit alanına ışınla
function SH_REPORTS:TeleportPlayersToSit(players, location)
	local positions = {}
	local basePos = location.pos
	local spacing = self.SitPlayerSpacing or 100
	
	local angleStep = 360 / #players
	for i, ply in ipairs(players) do
		if IsValid(ply) then
			local angle = (i - 1) * angleStep
			local rad = math.rad(angle)
			local offset = Vector(math.cos(rad) * spacing, math.sin(rad) * spacing, 0)
			local targetPos = basePos + offset
			
			ply.SH_PosBeforeReport = ply:GetPos()
			self:TeleportPlayer(ply, targetPos)
			
			timer.Simple(0.1, function()
				if IsValid(ply) then
					ply:SetEyeAngles((basePos - ply:GetPos()):Angle())
				end
			end)
		end
	end
end

-- Sit'i kaydet
function SH_REPORTS:RegisterSit(reportId, location, players)
	self.ActiveSits[reportId] = {
		location = location.pos,
		locationName = location.name,
		players = players,
		startTime = os.time()
	}
end

-- Sit'i kaldır
function SH_REPORTS:UnregisterSit(reportId)
	if self.ActiveSits[reportId] then
		if self.TeleportPlayersBack and self.ActiveSits[reportId].players then
			for _, ply in ipairs(self.ActiveSits[reportId].players) do
				if IsValid(ply) then
					self:ReturnPlayer(ply)
				end
			end
		end
		
		self.ActiveSits[reportId] = nil
	end
end
-- sv_main.lua - KOMPLE GÜNCEL HALİ (BÖLÜM 2/3)

function SH_REPORTS:PlayerSay(ply, str)
	local text = str:Replace("!", "/"):lower():Trim()

	if (self.AdminCommands[text]) then
		if (self.OnlySuperadminCanSeeList and ply:GetUserGroup() ~= "superadmin") then
			self:Notify(ply, "Rapor listesini görme yetkiniz yok. " .. self.NextReportCommand .. " komutunu kullanın.", false)
			return ""
		end
		self:ShowReports(ply)
		return ""
	end

	-- Sıradaki rapor komutu - REZERVASYON SİSTEMİ İLE
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
	if (self:IsAdmin(ply)) then
		tosend = self:GetAllReports()
	else
		tosend = self:GetAllReports(ply:SteamID64())
	end

	easynet.Send(ply, "SH_REPORTS.SendList", {
		server_time = os.time(),
		struct_reports = tosend,
	})
end

-- YENİ REZERVASYON SİSTEMİ İLE: AssignNextReport
function SH_REPORTS:AssignNextReport(admin)
	-- Aktif sit kontrolü
	if self:HasActiveSit(admin) then
		self:Notify(admin, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
		return
	end
	
	-- Zaten üstlendiği rapor var mı
	for _, report in pairs(self.ActiveReports) do
		if report.admin_id == admin:SteamID64() then
			-- Zaten üstlendiği raporu göster
			local reportData = table.Copy(report)
			reportData.created_time = reportData.created_time or reportData.time
			easynet.Send(admin, "SH_REPORTS.DirectShowReport", reportData)
			return
		end
	end
	
	-- Öncelikli rapor listesi (rezerve edilmemiş olanlar)
	local prioritizedReports = self:GetAvailableReports()
	
	if #prioritizedReports == 0 then
		self:Notify(admin, "Bekleyen veya müsait rapor bulunmuyor.", false)
		return
	end
	
	-- İlk müsait raporu al
	local nextReport = prioritizedReports[1]
	
	-- RAPORU SADECE REZERVE ET (ÜSTLENMEYİ BEKLEME)
	self:ReserveReport(nextReport.id, admin)
	
	-- Rapor detaylarını göster (ÜSTLENİLMEMİŞ OLARAK)
	local reportData = table.Copy(nextReport)
	reportData.created_time = reportData.created_time or reportData.time
	reportData.reserved_by = admin:SteamID64()
	
	-- Rapor penceresini aç
	easynet.Send(admin, "SH_REPORTS.DirectShowReport", reportData)
	
	-- Chat bildirimi
	easynet.Send(admin, "SH_REPORTS.Chat", {
		msg = "Rapor #" .. nextReport.id .. " size atandı. Üstlenmek için butona basın."
	})
end

-- YENİ: Rapor üstlendikten sonra teleport işlemleri
function SH_REPORTS:TeleportToReport(admin, id, action)
	if (!self:IsAdmin(admin)) then
		self:Notify(admin, "not_allowed_to_run_cmd", false)
		return
	end

	local report = self:FindReport(id)
	if (!report) then
		self:Notify(admin, "report_non_existent", false)
		return
	end
	
	-- Raporu üstlenen kişi mi kontrol et
	if report.admin_id ~= admin:SteamID64() then
		self:Notify(admin, "Bu rapor size ait değil!", false)
		return
	end
	
	local target = player.GetBySteamID64(report.reporter_id)
	if (!IsValid(target)) then
		self:Notify(admin, "Rapor eden oyuncu sunucuda değil!", false)
		return
	end
	
	-- Pozisyonları kaydet
	admin.SH_PosBeforeReport = admin:GetPos()
	target.SH_PosBeforeReport = target:GetPos()
	
	if action == "goto" then
		-- Git
		self:TeleportPlayer(admin, target:GetPos())
		self:Log(admin:Nick() .. " teleported to " .. target:Nick() .. " for report #" .. id)
	elseif action == "bring" then
		-- Çek
		self:TeleportPlayer(target, admin:GetPos() + Vector(50, 0, 0))
		self:Log(admin:Nick() .. " brought " .. target:Nick() .. " for report #" .. id)
	end
end

-- YENİ: Rapor için sit başlat
function SH_REPORTS:StartSitForReport(admin, id)
	if (!self:IsAdmin(admin)) then
		self:Notify(admin, "not_allowed_to_run_cmd", false)
		return
	end

	local report = self:FindReport(id)
	if (!report) then
		self:Notify(admin, "report_non_existent", false)
		return
	end
	
	-- Raporu üstlenen kişi mi kontrol et
	if report.admin_id ~= admin:SteamID64() then
		self:Notify(admin, "Bu rapor size ait değil!", false)
		return
	end
	
	-- Aktif sit kontrolü
	if self:HasActiveSit(admin) then
		self:Notify(admin, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
		return
	end
	
	-- Sit başlat
	self:StartDelayedSit(admin, report)
end

-- Network callback'leri ekleyin/güncelleyin:

easynet.Callback("SH_REPORTS.TeleportToReport", function(data, ply)
	SH_REPORTS:TeleportToReport(ply, data.id, data.action)
end)

easynet.Callback("SH_REPORTS.StartSitForReport", function(data, ply)
	SH_REPORTS:StartSitForReport(ply, data.id)
end)




-- ClaimReport fonksiyonunu güncelle (rezervasyonu korusun)
function SH_REPORTS:ClaimReport(admin, report)
	local sid = admin:SteamID64()
	
	-- Başka biri tarafından rezerve edilmiş mi?
	if self.ReservedReports[report.id] then
		local reservation = self.ReservedReports[report.id]
		-- Rezervasyon sahibi değilse ve süre dolmamışsa reddet
		if reservation.admin_id ~= sid and CurTime() <= reservation.expire then
			self:Notify(admin, "Bu rapor başka bir yetkili tarafından inceleniyor!", false)
			return false
		end
	end
	
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
	
	-- Bildirimleri gönder
	local reporter = player.GetBySteamID64(report.reporter_id)
	if IsValid(reporter) then
		self:Notify(reporter, "admin_claimed_your_report", true)
	end
	
	-- Chat mesajı
	easynet.Send(admin, "SH_REPORTS.Chat", {
		msg = "Rapor #" .. report.id .. " üstlenildi! Artık Git/Çek/Sit butonlarını kullanabilirsiniz."
	})

	-- Diğer yetkililere bildir
	easynet.Send(self:GetStaff(), "SH_REPORTS.ReportClaimed", {report_id = report.id, admin_id = report.admin_id})

	if (self.CurrentPerfReport) and (!report.is_admin or self.AdminReportsCount) then
		self:BetterQuery([[
			]] .. self.InsertSQL .. [[ sh_reports_performance (steamid, report_id)
			VALUES ({steamid}, {report_id});
			UPDATE sh_reports_performance SET claimed = claimed + 1
			WHERE steamid = {steamid} AND report_id = {report_id}
		]], {steamid = admin:SteamID64(), report_id = self.CurrentPerfReport.id})
	end
	
	-- Rezervasyonu temizle
	if self.ReservedReports[report.id] then
		self.ReservedReports[report.id] = nil
		timer.Remove("SH_REPORTS_Reserve_" .. report.id)
	end
	self:ClearReservation(admin)

	return true
end

-- YENİ: Manuel sit başlatma fonksiyonu (15 saniyelik geri sayım ile)
function SH_REPORTS:ClaimAndStartSit(admin, id)
	if (!self:IsAdmin(admin)) then
		self:Notify(admin, "not_allowed_to_run_cmd", false)
		return
	end

	local report = self:FindReport(id)
	if (!report) then
		self:Notify(admin, "report_non_existent", false)
		return
	end
	
	-- Rezervasyon kontrolü
	if self.ReservedReports[id] then
		local reservation = self.ReservedReports[id]
		if reservation.admin_id ~= admin:SteamID64() then
			if CurTime() > reservation.expire then
				self.ReservedReports[id] = nil
			else
				self:Notify(admin, "Bu rapor başka bir yetkili tarafından inceleniyor!", false)
				return
			end
		end
	end

	-- Aktif sit kontrolü
	if self:HasActiveSit(admin) then
		self:Notify(admin, "Aktif bir sit'iniz var! Önce mevcut sit'i bitirin.", false)
		return
	end

	-- Önce raporu üstlen
	if (!self:ClaimReport(admin, report)) then
		return
	end

	-- Sonra sit başlat
	self:StartDelayedSit(admin, report)
end

-- YENİ: Gecikmeli sit başlatma (15 saniye)
function SH_REPORTS:StartDelayedSit(admin, report)
	local reporter = player.GetBySteamID64(report.reporter_id)
	local reported = player.GetBySteamID64(report.reported_id)
	
	if not IsValid(reporter) then
		self:Notify(admin, "Rapor eden oyuncu sunucuda değil!", false)
		return
	end
	
	-- Geri sayım başlat (15 SANİYE)
	local countdown = self.SitCountdown or 15
	local timerName = "SH_REPORTS_SitCountdown_" .. report.id
	
	-- İlk bildirim
	local players = {reporter}
	if IsValid(reported) and reported ~= reporter then
		table.insert(players, reported)
	end
	
	for _, ply in ipairs(players) do
		if IsValid(ply) then
			easynet.Send(ply, "SH_REPORTS.Chat", {
				msg = tostring(countdown) .. " saniye içinde sit'e ışınlanacaksınız! Hazırlanın."
			})
			ply:EmitSound("buttons/blip1.wav")
		end
	end
	
	-- Admin'e bilgi
	easynet.Send(admin, "SH_REPORTS.Chat", {
		msg = "Sit " .. countdown .. " saniye sonra başlayacak."
	})
	
	-- 5 saniyede bir uyarı
	timer.Create(timerName, 5, countdown / 5, function()
		countdown = countdown - 5
		
		if countdown <= 0 then
			timer.Remove(timerName)
			
			if not IsValid(admin) then return end
			
			local validReporter = IsValid(reporter)
			local validReported = IsValid(reported) and reported ~= reporter
			
			if not validReporter then
				self:Notify(admin, "Rapor eden oyuncu sunucudan ayrıldı!", false)
				return
			end
			
			local location = self:FindAvailableSitLocation()
			if not location then
				self:Notify(admin, "Uygun sit alanı bulunamadı!", false)
				return
			end
			
			local sitPlayers = {admin}
			if validReporter then table.insert(sitPlayers, reporter) end
			if validReported then table.insert(sitPlayers, reported) end
			
			self:TeleportPlayersToSit(sitPlayers, location)
			self:RegisterSit(report.id, location, sitPlayers)
			report.sit_started = true
			
			easynet.Send(admin, "SH_REPORTS.Chat", {
				msg = "Sit başladı! Lokasyon: " .. location.name
			})
			
			self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> started sit for report #" .. report.id .. " at " .. location.name)
		else
			-- Kalan süre bildirimi
			for _, ply in ipairs(players) do
				if IsValid(ply) then
					easynet.Send(ply, "SH_REPORTS.Chat", {
						msg = tostring(countdown) .. " saniye kaldı!"
					})
					if countdown <= 5 then
						ply:EmitSound("buttons/button17.wav")
					else
						ply:EmitSound("buttons/blip1.wav")
					end
				end
			end
		end
	end)
	
	-- İptal timer'ı
	timer.Create(timerName .. "_Check", 1, countdown, function()
		if not IsValid(admin) or not self:FindReport(report.id) then
			timer.Remove(timerName)
			timer.Remove(timerName .. "_Check")
		end
	end)
end

-- GÜNCELLENDİ: ClaimAndTeleport (rezervasyon kontrolü ile)
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
	
	-- Rezervasyon kontrolü
	if self.ReservedReports[id] then
		local reservation = self.ReservedReports[id]
		if reservation.admin_id ~= admin:SteamID64() then
			if CurTime() > reservation.expire then
				self.ReservedReports[id] = nil
			else
				self:Notify(admin, "Bu rapor başka bir yetkili tarafından inceleniyor!", false)
				return
			end
		end
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
		self:Notify(admin, "Rapor eden oyuncu sunucuda değil!", false)
		return
	end

	-- Raporu üstlen (rezervasyon temizlenir)
	if (!self:ClaimReport(admin, report)) then
		return
	end

	-- Teleport işlemleri
	admin.SH_PosBeforeReport = admin:GetPos()
	target.SH_PosBeforeReport = target:GetPos()

	if (self.UseULXCommands) then
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

	-- Base kontrolü için özel durum
	if report.reason_id == 7 then
		self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> claimed BASE CONTROL report [#" .. id .. "] and teleported to " .. target:Nick() .. " <" .. target:SteamID() .. ">")
	else
		self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> claimed " .. target:Nick() .. "'s <" .. target:SteamID() .. "> report [#" .. id .. "]")
	end
end

-- Aktif sit kontrolü
function SH_REPORTS:HasActiveSit(admin)
	for reportId, sitInfo in pairs(self.ActiveSits) do
		if sitInfo.players and table.HasValue(sitInfo.players, admin) then
			return true
		end
	end
	return false
end

-- Öncelikli rapor listesi (ESKİ - hala kullanılıyor başka yerlerde)
function SH_REPORTS:GetPrioritizedReports()
	local reports = {}
	
	for id, report in pairs(self.ActiveReports) do
		if report.admin_id == "" then
			local reasonData = self.ReportReasons[report.reason_id]
			if not (type(reasonData) == "table" and reasonData.disabled) then
				table.insert(reports, report)
			end
		end
	end
	
	table.sort(reports, function(a, b)
		local priorityA = 999
		local priorityB = 999
		
		local reasonA = self.ReportReasons[a.reason_id]
		local reasonB = self.ReportReasons[b.reason_id]
		
		if type(reasonA) == "table" then
			priorityA = reasonA.priority or 999
		end
		if type(reasonB) == "table" then
			priorityB = reasonB.priority or 999
		end
		
		if priorityA == priorityB then
			return a.time < b.time
		end
		
		return priorityA < priorityB
	end)
	
	return reports
end
-- sv_main.lua - KOMPLE GÜNCEL HALİ (BÖLÜM 3/3)

function SH_REPORTS:CloseReport(ply, id)
	local report = self:FindReport(id)
	if (!report) then
		self:Notify(ply, "report_non_existent", false)
		return
	end

	local sid = ply:SteamID64()
	
	if (self:IsAdmin(ply) and ((report.admin_id == "" and self.CanDeleteWhenUnclaimed) or report.admin_id == sid)) or (report.reporter_id == sid) then
		local adminName = ply:Nick()
		local isAdminClosing = self:IsAdmin(ply) and report.reporter_id ~= sid
		
		-- Raporu sil
		self.ActiveReports[id] = nil
		
		-- Timer'ları temizle
		timer.Remove("SH_REPORTS_SitCountdown_" .. id)
		timer.Remove("SH_REPORTS_SitCountdown_" .. id .. "_Check")
		timer.Remove("SH_REPORTS_Timeout_" .. id)
		timer.Remove("SH_REPORTS_Reserve_" .. id)

		print("[SH_REPORTS] Report #" .. id .. " closed by " .. ply:Nick())

		self:Notify(ply, "report_closed", true)
		
		for _, p in ipairs(player.GetAll()) do
			easynet.Send(p, "SH_REPORTS.ReportClosed", {report_id = id})
		end

		-- Chat bildirimleri
		if isAdminClosing then
			local reporter = player.GetBySteamID64(report.reporter_id)
			if IsValid(reporter) then
				easynet.Send(reporter, "SH_REPORTS.Chat", {
					msg = "Raporunuz " .. adminName .. " tarafından kapatıldı."
				})
			end
			
			if report.reported_id ~= "0" then
				local reported = player.GetBySteamID64(report.reported_id)
				if IsValid(reported) then
					easynet.Send(reported, "SH_REPORTS.Chat", {
						msg = "Hakkınızdaki rapor " .. adminName .. " tarafından kapatıldı."
					})
				end
			end
		elseif report.reporter_id == sid then
			if report.admin_id ~= "" then
				local admin = player.GetBySteamID64(report.admin_id)
				if IsValid(admin) and admin ~= ply then
					easynet.Send(admin, "SH_REPORTS.Chat", {
						msg = report.reporter_name .. " kendi raporunu kapattı."
					})
				end
			end
		end

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

		-- Sit'i temizle
		if self.ActiveSits[id] then
			self:UnregisterSit(id)
		end

		-- PARA ÖDÜLÜ SİSTEMİ
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

				-- PARA ÖDÜLÜ
				local admin = player.GetBySteamID64(report.admin_id)
				if (self.RewardEnabled and IsValid(admin) and sid == report.admin_id) then
					local shouldGiveMoney = false
					
					-- Base kontrolü her zaman para verir
					if report.reason_id == 7 then
						shouldGiveMoney = true
					-- Diğerleri için: Git/Çek kullanıldıysa veya sit başlatıldıysa
					elseif report.sit_started or self.ActiveSits[id] then
						shouldGiveMoney = true
					-- Eğer admin raporu kapatıyorsa ve oyuncu yanındaysa
					elseif IsValid(target) and admin:GetPos():Distance(target:GetPos()) < 500 then
						shouldGiveMoney = true
					end
					
					if shouldGiveMoney then
						if not admin.LastReportReward then
							admin.LastReportReward = {}
						end
						
						-- Üst üste aynı oyuncu kontrolü
						if admin.LastReportReward.reporter_id == report.reporter_id then
							if (self.RewardNotification) then
								DarkRP.notify(admin, 1, 4, "Aynı oyuncudan üst üste rapor! Para ödülü verilmedi.")
							end
							self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> closed consecutive report from same player - no reward")
							admin.LastReportReward = {
								reporter_id = report.reporter_id,
								time = os.time()
							}
						else
							-- PARA VER
							local usergroup = admin:GetUserGroup()
							local reward = self.RewardAmounts[usergroup]
							
							if (reward and reward > 0) then
								if (self.MoneySystem == "darkrp" and admin.addMoney) then
									admin:addMoney(reward)
									
									if (self.RewardNotification) then
										DarkRP.notify(admin, 0, 4, "Raporu kapattığınız için " .. DarkRP.formatMoney(reward) .. " kazandınız!")
									end
								end
								
								self:Log(admin:Nick() .. " <" .. admin:SteamID() .. "> received " .. reward .. " money for closing report #" .. id)
								
								admin.LastReportReward = {
									reporter_id = report.reporter_id,
									time = os.time()
								}
							end
						end
					else
						if (self.RewardNotification) then
							DarkRP.notify(admin, 1, 4, "Sit başlatılmadığı/oyuncuya gidilmediği için para ödülü verilmedi!")
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
			local reasonText = self.ReportReasons[report.reason_id]
			if type(reasonText) == "table" then
				reasonText = reasonText.reason
			end
			
			self:BetterQuery([[
				]] .. self.InsertSQL .. [[ sh_reports_performance_history (id, reporter, reported, reason, comment, waiting_time, date, admin)
				VALUES ({id}, {reporter}, {reported}, {reason}, {comment}, {waiting_time}, {date}, {admin});
			]], {id = id, reporter = report.reporter_id, reported = report.reported_id, reason = reasonText, comment = report.comment, waiting_time = os.time() - report.time, date = os.time(), admin = report.admin_id})
		end
		
		-- Rezervasyonu temizle
		if self.ReservedReports[id] then
			self.ReservedReports[id] = nil
		end
	else
		self:Notify(ply, "not_allowed_to_run_cmd", false)
	end
end

-- PlayerDisconnected (rezervasyonları temizle)
function SH_REPORTS:PlayerDisconnected(ply)
	local sid = ply:SteamID64()
	
	-- Rezervasyonları temizle
	for reportId, reservation in pairs(self.ReservedReports) do
		if reservation.admin_id == sid then
			self.ReservedReports[reportId] = nil
			timer.Remove("SH_REPORTS_Reserve_" .. reportId)
		end
	end
	
	for id, report in pairs (self:GetAllReports()) do
		if (report.reporter_id == sid) then
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

-- Diğer yardımcı fonksiyonlar
function SH_REPORTS:ShowPerformanceReports(ply)
	if (!self.UsergroupsPerformance[ply:GetUserGroup()]) then
		self:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end

	if (self.CachedPerfReports) then
		easynet.Send(ply, "SH_REPORTS.SendPerfReports", {
			struct_perf_reports = self.CachedPerfReports
		})
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
				easynet.Send(ply, "SH_REPORTS.SendPerfReports", {
					struct_perf_reports = d
				})
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

-- Yardımcı fonksiyonlar
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

function SH_REPORTS:HasActiveStaff()
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and self:IsAdmin(ply) and ply:GetUserGroup() ~= "superadmin" then
			return true
		end
	end
	return false
end

function SH_REPORTS:StartReportTimeout(reportId)
	local report = self:FindReport(reportId)
	if not report then return end
	
	local reporter = player.GetBySteamID64(report.reporter_id)
	if not IsValid(reporter) then return end
	
	local hasStaff = self:HasActiveStaff()
	local timeRemaining = 30
	local lastNotification = 0
	
	local timerName = "SH_REPORTS_Timeout_" .. reportId
	timer.Create(timerName, 60, 30, function()
		local currentReport = self:FindReport(reportId)
		if not currentReport or currentReport.admin_id ~= "" then
			timer.Remove(timerName)
			return
		end
		
		local currentReporter = player.GetBySteamID64(report.reporter_id)
		if not IsValid(currentReporter) then
			timer.Remove(timerName)
			return
		end
		
		local elapsedMinutes = math.floor((30 - timer.RepsLeft(timerName)))
		timeRemaining = 30 - elapsedMinutes
		
		if timeRemaining <= 0 then
			timer.Remove(timerName)
			
			self.ActiveReports[reportId] = nil
			
			easynet.Send(currentReporter, "SH_REPORTS.Chat", {
				msg = "Raporunuz süre aşımı nedeniyle iptal edildi. Discord sunucumuzdan ticket açabilirsiniz: discord.gg/basodark"
			})
			
			for _, p in ipairs(player.GetAll()) do
				easynet.Send(p, "SH_REPORTS.ReportClosed", {report_id = reportId})
			end
			
			self:Log("Report #" .. reportId .. " auto-closed due to timeout (30 minutes)")
		else
			if elapsedMinutes - lastNotification >= 5 then
				lastNotification = elapsedMinutes
				
				local currentHasStaff = self:HasActiveStaff()
				
				if currentHasStaff then
					easynet.Send(currentReporter, "SH_REPORTS.Chat", {
						msg = "Raporunuz sırada bekliyor. " .. timeRemaining .. " dakika daha bekleyecek."
					})
				else
					easynet.Send(currentReporter, "SH_REPORTS.Chat", {
						msg = "Aktif yetkili bulunmuyor. Raporunuz " .. timeRemaining .. " dakika daha bekleyecek."
					})
				end
			end
		end
	end)
	
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

function SH_REPORTS:Log(s)
	if (!self.UseServerLog) then
		return end
	ServerLog(s .. "\n")
end

function SH_REPORTS:NewReport(ply, data)
	if (self:IsAdmin(ply) and !self.StaffCanReport) then
		self:Notify(ply, "cannot_report_as_admin", false)
		return
	end

	if (data.reporter_id == data.reported_id) then
		self:Notify(ply, "cannot_report_self", false)
		return
	end
	
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
	data.created_time = os.time()
	self.ActiveReports[data.id] = table.Copy(data)

	self:Notify(ply, "report_submitted", true)
	
	local reasonText = self.ReportReasons[data.reason_id]
	if type(reasonText) == "table" then
		reasonText = reasonText.reason
	end
	
	self:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> reported [#" .. data.id .. "] " .. data.reported_name .. " <" .. util.SteamIDFrom64(data.reported_id) .. "> for " .. reasonText)

	easynet.Send(self:GetStaff(), "SH_REPORTS.ReportCreated", data)
	
	self:StartReportTimeout(data.id)
	
	if not (type(reasonData) == "table" and reasonData.disabled) then
		local pendingCount = 0
		for id, report in pairs(self.ActiveReports) do
			if report.admin_id == "" then
				local rd = self.ReportReasons[report.reason_id]
				if not (type(rd) == "table" and rd.disabled) then
					pendingCount = pendingCount + 1
				end
			end
		end
		
		for _, admin in ipairs(player.GetAll()) do
			if IsValid(admin) and self:IsAdmin(admin) then
				easynet.Send(admin, "SH_REPORTS.PeriodicNotification", {
					count = pendingCount
				})
			end
		end
		
		timer.Start("SH_REPORTS.PeriodicCheck")
	end
end

-- Network Callbacks
easynet.Callback("SH_REPORTS.ClaimAndStartSit", function(data, ply)
	SH_REPORTS:ClaimAndStartSit(ply, data.id)
end)

easynet.Callback("SH_REPORTS.ReturnPlayers", function(data, ply)
	if (!SH_REPORTS:IsAdmin(ply)) then
		SH_REPORTS:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end
	
	local report = SH_REPORTS:FindReport(data.id)
	if (!report) then
		SH_REPORTS:Notify(ply, "report_non_existent", false)
		return
	end
	
	-- Raporu üstlenen kişi mi kontrol et
	if report.admin_id ~= ply:SteamID64() then
		SH_REPORTS:Notify(ply, "Bu rapor size ait değil!", false)
		return
	end
	
	-- Oyuncuları geri gönder
	local reporter = player.GetBySteamID64(report.reporter_id)
	if IsValid(reporter) and reporter.SH_PosBeforeReport then
		SH_REPORTS:TeleportPlayer(reporter, reporter.SH_PosBeforeReport, true)
		reporter.SH_PosBeforeReport = nil
		easynet.Send(reporter, "SH_REPORTS.Chat", {
			msg = "Eski konumunuza geri döndürüldünüz."
		})
	end
	
	local reported = player.GetBySteamID64(report.reported_id)
	if IsValid(reported) and reported.SH_PosBeforeReport then
		SH_REPORTS:TeleportPlayer(reported, reported.SH_PosBeforeReport, true)
		reported.SH_PosBeforeReport = nil
		easynet.Send(reported, "SH_REPORTS.Chat", {
			msg = "Eski konumunuza geri döndürüldünüz."
		})
	end
	
	-- Admin'i de geri gönder
	if ply.SH_PosBeforeReport then
		SH_REPORTS:TeleportPlayer(ply, ply.SH_PosBeforeReport, true)
		ply.SH_PosBeforeReport = nil
	end
	
	-- Sit'i kaldır (eğer varsa)
	if SH_REPORTS.ActiveSits[data.id] then
		SH_REPORTS:UnregisterSit(data.id)
	end
	
	SH_REPORTS:Notify(ply, "Oyuncular eski konumlarına geri döndürüldü.", true)
	SH_REPORTS:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> returned players to their original positions for report #" .. data.id)
end)

easynet.Callback("SH_REPORTS.Claim", function(data, ply)
	if (!SH_REPORTS:IsAdmin(ply)) then
		SH_REPORTS:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end
	
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

easynet.Callback("SH_REPORTS.CloseReport", function(data, ply)
	SH_REPORTS:CloseReport(ply, data.id)
end)

easynet.Callback("SH_REPORTS.RequestList", function(data, ply)
	SH_REPORTS:ShowReports(ply)
end)

easynet.Callback("SH_REPORTS.PlayerReady", function(data, ply)
	SH_REPORTS:PlayerReady(ply)
end)

easynet.Callback("SH_REPORTS.NewReport", function(data, ply)
	local report = data
	data.reporter_name = ply:Nick()
	data.reporter_id = ply:SteamID64()
	data.time = os.time()
	data.created_time = os.time()
	data.admin_id = ""
	data.comment = data.comment:sub(1, SH_REPORTS.MaxCommentLength)
	data.is_admin = SH_REPORTS:IsAdmin(ply)

	SH_REPORTS:NewReport(ply, data)
end)

easynet.Callback("SH_REPORTS.RequestPerfReports", function(data, ply)
	SH_REPORTS:ShowPerformanceReports(ply)
end)

easynet.Callback("SH_REPORTS.RequestPerfReportStaff", function(data, ply)
	SH_REPORTS:RequestPerfReportStaff(ply, data.id)
end)

easynet.Callback("SH_REPORTS.RateAdmin", function(data, ply)
	SH_REPORTS:RateAdmin(ply, data.report_id, data.rating)
end)

easynet.Callback("SH_REPORTS.RequestStaffRatings", function(data, ply)
	SH_REPORTS:RequestStaffRatings(ply)
end)

easynet.Callback("SH_REPORTS.MinimizeReport", function(data, ply)
	-- Yetkili kontrolü
	if (!SH_REPORTS:IsAdmin(ply)) then
		return
	end
	
	-- Raporu bul
	local report = SH_REPORTS:FindReport(data.report_id)
	if (!report) then
		return
	end
	
	-- Raporu üstlenen kişi mi kontrol et
	if report.admin_id ~= ply:SteamID64() then
		return
	end
	
	-- MinimizeReport mesajını client'a geri gönder (MakeTab'ı tetiklemek için)
	easynet.Send(ply, "SH_REPORTS.MinimizeReport", {
		report_id = data.report_id
	})
end)

easynet.Callback("SH_REPORTS.ReturnPlayers", function(data, ply)
	if (!SH_REPORTS:IsAdmin(ply)) then
		SH_REPORTS:Notify(ply, "not_allowed_to_run_cmd", false)
		return
	end
	
	local report = SH_REPORTS:FindReport(data.id)
	if (!report) then
		SH_REPORTS:Notify(ply, "report_non_existent", false)
		return
	end
	
	-- Raporu üstlenen kişi mi kontrol et
	if report.admin_id ~= ply:SteamID64() then
		SH_REPORTS:Notify(ply, "Bu rapor size ait değil!", false)
		return
	end
	
	-- Oyuncuları geri gönder
	local reporter = player.GetBySteamID64(report.reporter_id)
	if IsValid(reporter) and reporter.SH_PosBeforeReport then
		SH_REPORTS:TeleportPlayer(reporter, reporter.SH_PosBeforeReport, true)
		reporter.SH_PosBeforeReport = nil
		easynet.Send(reporter, "SH_REPORTS.Chat", {
			msg = "Eski konumunuza geri döndürüldünüz."
		})
	end
	
	local reported = player.GetBySteamID64(report.reported_id)
	if IsValid(reported) and reported.SH_PosBeforeReport then
		SH_REPORTS:TeleportPlayer(reported, reported.SH_PosBeforeReport, true)
		reported.SH_PosBeforeReport = nil
		easynet.Send(reported, "SH_REPORTS.Chat", {
			msg = "Eski konumunuza geri döndürüldünüz."
		})
	end
	
	-- Admin'i de geri gönder
	if ply.SH_PosBeforeReport then
		SH_REPORTS:TeleportPlayer(ply, ply.SH_PosBeforeReport, true)
		ply.SH_PosBeforeReport = nil
	end
	
	-- Sit'i kaldır (eğer varsa)
	if SH_REPORTS.ActiveSits and SH_REPORTS.ActiveSits[data.id] then
		SH_REPORTS:UnregisterSit(data.id)
	end
	
	SH_REPORTS:Notify(ply, "Oyuncular eski konumlarına geri döndürüldü.", true)
	SH_REPORTS:Log(ply:Nick() .. " <" .. ply:SteamID() .. "> returned players to their original positions for report #" .. data.id)
end)

easynet.Callback("SH_REPORTS.RequestReportHistory", function(data, ply)
	SH_REPORTS:RequestReportHistory(ply)
end)

-- Hooks
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
		if (SH_REPORTS.OnlySuperadminCanSeeList and SH_REPORTS:IsAdmin(ply) and ply:GetUserGroup() ~= "superadmin") then
			SH_REPORTS:Notify(ply, "Rapor listesini görme yetkiniz yok. " .. SH_REPORTS.NextReportCommand .. " komutunu kullanın.", false)
		else
			SH_REPORTS:ShowReports(ply)
		end
	end
end)

timer.Create("SH_REPORTS.MidnightCheck", 1, 0, function()
	SH_REPORTS:MidnightCheck()
end)

timer.Create("SH_REPORTS.PeriodicCheck", 120, 0, function()
	local pendingReports = {}
	local pendingCount = 0
	
	for id, report in pairs(SH_REPORTS.ActiveReports) do
		if report.admin_id == "" then
			local reasonData = SH_REPORTS.ReportReasons[report.reason_id]
			if not (type(reasonData) == "table" and reasonData.disabled) then
				pendingCount = pendingCount + 1
				table.insert(pendingReports, report)
			end
		end
	end
	
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and SH_REPORTS:IsAdmin(ply) then
			easynet.Send(ply, "SH_REPORTS.PeriodicNotification", {
				count = pendingCount
			})
		end
	end
end)

-- Debug komutu (rezervasyon durumu dahil)
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
		
		-- Rezervasyon durumu
		local reserved = ""
		if SH_REPORTS.ReservedReports[id] then
			local reservation = SH_REPORTS.ReservedReports[id]
			local remaining = math.ceil(reservation.expire - CurTime())
			reserved = " [REZERVE - " .. (IsValid(reservation.admin) and reservation.admin:Nick() or "???") .. " - " .. remaining .. " saniye]"
		end
		
		print("Rapor #" .. id .. reserved)
		print("  Rapor Eden: " .. report.reporter_name)
		print("  Şikayet Edilen: " .. report.reported_name)
		print("  Sebep: " .. reasonText .. extra)
		print("  Admin: " .. (report.admin_id ~= "" and report.admin_id or "Alınmamış"))
		print("  Sit Başladı mı: " .. tostring(report.sit_started))
	end
	
	print("\n=== Rezervasyon Durumu ===")
	for reportId, reservation in pairs(SH_REPORTS.ReservedReports) do
		local remaining = math.ceil(reservation.expire - CurTime())
		print("Rapor #" .. reportId .. " - " .. (IsValid(reservation.admin) and reservation.admin:Nick() or "???") .. " - " .. remaining .. " saniye kaldı")
	end
	
	print("\n=== Aktif Sitler ===")
	for reportId, sitInfo in pairs(SH_REPORTS.ActiveSits) do
		print("Rapor #" .. reportId .. " - " .. sitInfo.locationName)
		print("  Oyuncular: " .. #sitInfo.players)
	end
end)

concommand.Add("sh_reports_sync", function(ply)
	if not SH_REPORTS:IsAdmin(ply) then return end
	
	for _, p in ipairs(player.GetAll()) do
		SH_REPORTS:ShowReports(p)
	end
	
	print("[SH_REPORTS] Zorla senkronizasyon yapıldı!")
end)