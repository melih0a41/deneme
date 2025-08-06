/**
* General configuration
**/

-- Usergroups allowed to view/handle reports
SH_REPORTS.Usergroups = {
	-- Yönetim Grupları
	["superadmin"] = true,
	["basadmin"] = true,
	["kidemliadmin"] = true,
	["yardimciadmin"] = true,
	["admin"] = true,

	-- Moderasyon Grupları
	["denetleyicimoderator"] = true,
	["kidemlimoderator"] = true,
	["moderator"] = true,	
	["asistanmoderator"] = true,

	-- Diğer Yetkili Gruplar
	["eventmanager"] = true,

	-- Rehber Grupları
	["viprehber"] = true,
	["toplulukrehberi"] = true,
	["kidemlirehber"] = true,
	["rehber"] = true,
	["rehberadayi"] = true,
}

-- Usergroups allowed to view performance reports
SH_REPORTS.UsergroupsPerformance = {
	["superadmin"] = true,
}

-- Customize your report reasons here with priority.
-- Lower priority number = higher priority (1 is highest)
SH_REPORTS.ReportReasons = {
	[1] = {
		reason = "Hile & İstismar (Exploit, Bug Abuse, Şüpheli Oyuncu)",
		priority = 1
	},
	[2] = {
		reason = "Genel Davranış İhlali (Küfür, Taciz, Trol, Rahatsız Edici Davranışlar vb.)",
		priority = 2
	},
	[3] = {
		reason = "Rol Kuralı İhlali (FearRP, FailRP, RDM, VDM, NLR vb.)",
		priority = 3
	},
	[4] = {
		reason = "Soru-Cevap (Sunucu, oyun veya rollerle ilgili sorularınızı yetkililere iletin.)",
		priority = 4
	},
	[5] = {
		reason = "Bug/Hata (Sunucuda karşılaşılan teknik hata ve bug bildirimleri.)",
		priority = 5
	},
	[6] = {
		reason = "Yetkili Şikayeti(Yetkililerin görev ve yetki ihlallerini buradan bildirebilirsiniz.)",
		priority = 6,
		disabled = true, -- Bu kategori devre dışı
		discord_redirect = true, -- Discord'a yönlendir
		discord_message = "Yetkili şikayetleri için lütfen discord.gg/basodark adresini ziyaret ederek ticket oluşturun."
	},
	[7] = {
		reason = "Base Kontrolü (Üslerin rol kurallarına uygun olup olmadığını kontrol ettirmek için.)",
		priority = 7
	}
}

-- Auto-start sit when report is claimed - DEĞİŞTİRİLDİ: KAPALI
-- If true, sit will start automatically after countdown
SH_REPORTS.AutoStartSit = false -- false yapıldı, artık manuel seçim olacak

-- Countdown time before sit starts (in seconds) - DEĞİŞTİRİLDİ: 15 SANİYE
SH_REPORTS.SitCountdown = 15 -- 30'dan 15'e düşürüldü

/**
* SIT LOKASYON SİSTEMİ
* Birden fazla sit alanı tanımlayabilirsiniz
* Sistem otomatik olarak boş olan ilk alanı seçecektir
**/

-- Sit lokasyonları (sırayla denenecek)
-- Her lokasyon için: {pos = Vector(x, y, z), name = "Alan Adı"}
SH_REPORTS.SitLocations = {
	{pos = Vector(2166.680908, -4775.164551, -123.187973), name = "Sit Alanı 1"},
	{pos = Vector(3488.375000, -4720.825195, -125.325607), name = "Sit Alanı 2"},
	{pos = Vector(3490.969727, -5399.336426, -121.405205), name = "Sit Alanı 3"},
	-- İstediğiniz kadar ekleyebilirsiniz
}

-- Sit alanı yarıçapı (bu mesafe içinde başka sit varsa sonraki alana geçer)
SH_REPORTS.SitAreaRadius = 500

-- Oyuncuları sit alanına ışınlarken aralarındaki mesafe
SH_REPORTS.SitPlayerSpacing = 100

-- Can non-superadmins see the full report list?
-- If false, they must use !sıradakirapor command
SH_REPORTS.OnlySuperadminCanSeeList = true

-- Command to get next report in queue
SH_REPORTS.NextReportCommand = "!sıradakirapor"

-- How many reports can a player make?
SH_REPORTS.MaxReportsPerPlayer = 1

-- Play a sound to admins whenever a report is made?
SH_REPORTS.NewReportSound = {
	enabled = true,
	path = Sound("buttons/button16.wav"),
}

-- Enable ServerLog support? Any actions related to reports will be ServerLog'd IN ENGLISH if true.
-- NOTE: ServerLogs are in English.
SH_REPORTS.UseServerLog = true

-- Should admins be able to create reports?
SH_REPORTS.StaffCanReport = true

-- Can players report admins?
SH_REPORTS.StaffCanBeReported = false

-- Should admins be able to delete unclaimed reports?
SH_REPORTS.CanDeleteWhenUnclaimed = true

-- Notify admins when they connect of any unclaimed reports?
SH_REPORTS.NotifyAdminsOnConnect = true

-- Can players report "Other"?
-- Other is no player in particular; but players can make a report with Other if they want a sit or something.
SH_REPORTS.CanReportOther = true

-- Use ULX commands for teleporting? (allows returning etc.)
SH_REPORTS.UseULXCommands = false

-- Key binding to open the Make Report menu.
SH_REPORTS.ReportKey = KEY_F8

-- Key binding to open the Report List menu.
SH_REPORTS.ReportsKey = KEY_F9

-- Should players be asked for rating the admin after their report gets closed?
SH_REPORTS.AskRating = true

-- Should admins know whenever a player rates them?
SH_REPORTS.NotifyRating = true

-- Should players be teleported back to their position after their report gets closed?
SH_REPORTS.TeleportPlayersBack = true

-- How many pending reports to show on admin's screen?
SH_REPORTS.PendingReportsDispNumber = 3

-- Allows admins to claim reports without teleporting?
-- If true, the Goto and Bring commands will be hidden.
SH_REPORTS.ClaimNoTeleport = false

-- Use Steam Workshop for the custom content?
-- If false, custom content will be downloaded through FastDL.
SH_REPORTS.UseWorkshop = true

/**
* Command configuration
**/

-- Chat commands which can open the View Reports menu (for admins)
-- ! are automatically replaced by / and inputs are made lowercase for convenience.
SH_REPORTS.AdminCommands = {
	["/adminrapor"] = true,
	
}

-- Chat commands which can open the Make Report menu (for players)
-- ! are automatically replaced by / and inputs are made lowercase for convenience.
SH_REPORTS.ReportCommands = {
	["@"] = true,
    ["/report"]    = true,
    ["!report"]    = true,
    ["/rapor"]     = true,
    ["!rapor"]     = true,
    ["/şikayet"]   = true,
    ["!şikayet"]   = true,
    ["/sikayet"]   = true,
    ["!sikayet"]   = true,
    ["@"]           = true,
 }


-- Enable quick reporting with @?
-- Typing "@this guy RDM'd me" would open the Make Report menu with the text as a comment.
-- Might conflict with add-ons relying on @ commands.
-- NOTE: Admins cannot use this feature.
SH_REPORTS.EnableQuickReport = true

/**
* Performance reports configuration
**/

-- How should performance reports be saved?
-- Possible options: sqlite, mysqloo
-- mysqloo requires gmsv_mysqloo to be installed on your server.
-- You can configure MySQL credentials in reports/lib_database.lua
SH_REPORTS.DatabaseMode = "sqlite"

-- What should be the frequency of performance reports?
-- Possible options: daily, weekly, monthly
SH_REPORTS.PerformanceFrequency = "weekly"

-- If the above option is weekly, on what day of the week
-- should new performance reports be created? (always at midnight)
-- 0: Sunday
-- 1: Monday
-- 2: Tuesday
-- 3: Wednesday
-- 4: Thursday
-- 5: Friday
-- 6: Saturday
SH_REPORTS.PerformanceWeekDay = 1

-- Should reports created by admins count for the performance reports and ratings?
SH_REPORTS.AdminReportsCount = false

/**
* Storage configuration
**/

-- Should reports closed by an admin be stored?
-- Useful if you want to see a past report, and what rating the admin got.
-- Possible options: none, sqlite, mysqloo
-- none disables this feature.
SH_REPORTS.StoreCompletedReports = "sqlite"

-- Should reports be purged after some time? In seconds.
-- Purges are done on map start to avoid performance loss.
-- Set to 0 to make stored reports never expire.
-- Beware! Too many reports may prevent you from seeing the history properly due to large amounts of data to send.
SH_REPORTS.StorageExpiryTime = 86400 * 7

/**
* Para Ödülü Sistemi
**/

-- Rapor başına para ödülü sistemi aktif mi?
SH_REPORTS.RewardEnabled = true

-- SAM yetkilerine göre rapor başına verilecek para miktarları
SH_REPORTS.RewardAmounts = {
    -- Yönetim Ödülleri
    ["superadmin"] = 600000,
    ["basadmin"] = 550000,
    ["kidemliadmin"] = 500000,
    ["yardimciadmin"] = 400000,
    ["admin"] = 300000,

    -- Moderasyon Ödülleri
    ["denetleyicimoderator"] = 275000,
    ["kidemlimoderator"] = 250000,
    ["moderator"] = 200000,
    ["asistanmoderator"] = 175000,

    -- Diğer Yetkiler
    ["eventmanager"] = 150000,

    -- Rehber Ödülleri
    ["viprehber"] = 150000,
    ["toplulukrehberi"] = 130000,
    ["kidemlirehber"] = 120000,
    ["rehber"] = 100000,
    ["rehberadayi"] = 75000,
}

-- Para verildiğinde bildirim gösterilsin mi?
SH_REPORTS.RewardNotification = true

-- Para verme sistemi için kullanılacak para fonksiyonu
-- DarkRP için: "darkrp"
-- Diğer sistemler için özelleştirme gerekebilir
SH_REPORTS.MoneySystem = "darkrp"

/**
* Advanced configuration
* Edit at your own risk!
**/

SH_REPORTS.MaxCommentLength = 2048

-- Periyodik kontrol süresi (saniye)
SH_REPORTS.PeriodicCheckInterval = 30

-- Pop-up bildirimleri devre dışı bırak
SH_REPORTS.DisablePopups = true

-- Rapor timeout sistemi
-- Üstlenilmeyen raporlar ne kadar süre sonra otomatik iptal edilsin? (dakika)
SH_REPORTS.ReportTimeout = 30

-- Timeout hatırlatma mesajı sıklığı (dakika)
SH_REPORTS.TimeoutReminderInterval = 5

-- Timeout durumunda Discord yönlendirme mesajı
SH_REPORTS.TimeoutDiscordMessage = "Discord sunucumuzdan ticket açabilirsiniz: discord.gg/basodark"

-- Superadminler aktif yetkili sayılsın mı?
-- false = Sadece superadmin varsa "aktif yetkili yok" mesajı gösterilir
SH_REPORTS.SuperadminCountsAsActiveStaff = false

SH_REPORTS.DateFormat = "%Y/%m/%d"

SH_REPORTS.TimeFormat = "%Y/%m/%d %H:%M:%S"

-- When making a report with the "RDM" reason
-- it will automatically select the player who last killed you.
-- If you modify the report reasons above make sure to modify those here as well for convenience.
SH_REPORTS.ReasonAutoTarget = {
	["RDM"] = "killer",
	["RDA"] = "arrester",
}

/**
* Theme configuration
**/

-- Font to use for normal text throughout the interface.
SH_REPORTS.Font = "Circular Std Medium"

-- Font to use for bold text throughout the interface.
SH_REPORTS.FontBold = "Circular Std Bold"

-- Color sheet. Only modify if you know what you're doing
SH_REPORTS.Style = {
	header = Color(52, 152, 219, 255),
	bg = Color(52, 73, 94, 255),
	inbg = Color(44, 62, 80, 255),

	close_hover = Color(231, 76, 60, 255),
	hover = Color(255, 255, 255, 10, 255),
	hover2 = Color(255, 255, 255, 5, 255),

	text = Color(255, 255, 255, 255),
	text_down = Color(0, 0, 0),
	textentry = Color(44, 62, 80),
	menu = Color(127, 140, 141),

	success = Color(46, 204, 113),
	failure = Color(231, 76, 60),
	rating = Color(241, 196, 15),
}

/**
* Language configuration
**/

-- Various strings used throughout the add-on.
-- Available languages: english, french, german
-- To add your own language, see the reports/language folder
-- You may need to restart the map after changing the language!
SH_REPORTS.LanguageName = "english"