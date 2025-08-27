-- Yeşil Tik HTML Kodu
local yes_icon = '<img src="https://i.imgur.com/rcRf2ja.png" width="16" height="16"> '
-- Kırmızı Çarpı HTML Kodu
local no_icon = '<img src="https://i.imgur.com/Xzb6Qr9.png" width="16" height="16"> '
local rule_indent = "\t\t" -- Tüm kural satırları için standart girinti

TEAM_SIVIL = DarkRP.createJob("Vatandaş", {
    color = Color(255, 255, 255),
    model = "models/player/Group01/male_02.mdl",
    description = [[
		Vatandaşsın, herkes gibi kurallara uymalısın!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "vatandas",
    max = 0,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,
	agenda = "BaskanDuyurusu", 

})


TEAM_ZGW_GOLDWASHER = DarkRP.createJob("Altın Avcısı", {
    color = Color(255, 255, 255),
    model = {"models/player/alyx.mdl"},
    description = [[
		Sahilde kum kazarak kumların arasına gömülmüş altınları bularak para kazanabilirsin!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"zgw_shovel","zgw_sieve"},
    command = "zgw_golddigger",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Sivil",
    hasLicense = false,
    PlayerSpawn = function(ply) ply:SetPlayerColor(Vector(1,0.6,0)) end,
})

TEAM_COCUK = DarkRP.createJob("Çocuk", {
    color = Color(255, 255, 255),
    model = "models/player/portal_and_mika/kid.mdl",
    description = [[
		Uslu Bir Çocuk Ol!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "cocuk",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,
})

TEAM_ZPIZ_CHEF = DarkRP.createJob("Pizza Şefi", {
    color = Color(255, 255, 255),
    model = {"models/ecott/chefcitizen.mdl"},
    description = [[
		Şehrin en nefis pizzalarını yapmakla ünlüsün. Kendine bir mekan açarak bunu kanıtla!.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "zpiz_pizzachef01",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Sivil",
    hasLicense = false,

})

TEAM_ZTM_TRASHMAN = DarkRP.createJob("Çöp Toplayıcısı", {
    color = Color(255, 255, 255),
    model = {"models/snowred/dab9595/hex/odessa.mdl"},
    description = [[
		Şehrin hijyen ve temizliğinden sen sorumlusun!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsız!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"ztm_trashcollector"},
    command = "ztm_trashman",
    max = 3,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Sivil",
    hasLicense = false,

})

TEAM_ZRUSH_FUELPRODUCER = DarkRP.createJob("Benzin Üreticisi", {
    color = Color(255, 255, 255),
    model = {"models/player/group03/male_04.mdl"},
    description = [[
		Petrolden benzin yaparak gelir elde etmeye çalış!

        ]] .. rule_indent .. no_icon .. [[Raid atamazsın!
        ]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
        ]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
        ]],
    weapons = {},
    command = "zrush_fuelrefiner",
    max = 3,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Sivil",
    hasLicense = false,

})

TEAM_GITARCI = DarkRP.createJob("Gitarcı", {
    color = Color(255, 255, 255),
    model = "models/tnrp/player/guyfieri/guyfieri.mdl",
    description = [[
		Gitar çal insanlardan bağış al!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"guitar"},
    command = "gitarci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_PALYACO = DarkRP.createJob("Palyaço", {
    color = Color(255, 255, 255),
    model = {
    "models/winningrook/gtav/clowns/clown_001.mdl",
    "models/winningrook/gtav/clowns/clown_000.mdl"
    },
    description = [[
		Bir gün bir palyaço varmış bütün ağlayanları güldürürmüş
		bir gün bir adam yoğun ağlama teşhisiylen doktora başvurmuş
		doktor da demiş ki git o palyaçoyu bul o seni güldürür
		o da demiş ki o da benim

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"weapon_gpee", "wos_fortnite_dancer","slappers",},
    command = "palyaco",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_EVSIZ = DarkRP.createJob("Evsiz", {
    color = Color(255, 255, 255),
    model = "models/jessev92/player/l4d/m9-hunter.mdl",
    description = [[
		Evsiz piç kurusu.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"weapon_gpee"},
    command = "evsiz",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,

})



TEAM_GANYAN = DarkRP.createJob("Ganyan Bayi Sahibi", {
    color = Color(255, 255, 255),
    model = "models/player/korka007/toni.mdl",
    description = [[
		Ganyan Bayi Sahibisin İnsanlara At Yarışı Oynat!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "ganyan",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_TAMIRCI = DarkRP.createJob("Tamirci", {
    color = Color(255, 255, 255),
    model = "models/player/mechanic.mdl",
    description = [[
		Bozulan Araçları Tamir Et!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"sv_wrench",},
    command = "tamirci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_BANKACI = DarkRP.createJob("Bankacı", {
    color = Color(255, 255, 255),
    model = "models/player/gman_high.mdl",
    description = [[
		Bankacısın Bankanın Güvenliğini Sağla ve İnsanlara Kasa Kirala!

		]] .. rule_indent .. yes_icon .. [[İnsanlardan printerlerini alıp bankada muhafaza edebilirsin!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "bankaci",
    max = 2,
    salary = 3000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_GUVENLIK = DarkRP.createJob("Güvenlik", {
    color = Color(255, 255, 255),
    model = {
    "models/player/guard_pack/guard_02.mdl",
    "models/player/guard_pack/guard_03.mdl"
    },
    description = [[
		Legal Meslekler ile beraber çalış ve bankanın güvenlğini sağla!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "guvenlik",
    max = 2,
    salary = 2000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Sivil",
    canDemote = false,
		    PlayerSpawn = function(ply)
        ply:SetArmor(100)
    end,


})

TEAM_CASINOSAHIBI = DarkRP.createJob("Casino Sahibi", {
    color = Color(255, 255, 255),
    model = {
	"models/xpears/safaksezer.mdl",
	"models/xpears/ganyotcu.mdl"
	},
    description = [[
		Kumarhaneye giriş ücreti al ve insanlara kumar oynat!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "casinosahibi",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_SILAHSATICISI = DarkRP.createJob("Silah Satıcısı", {
    color = Color(255, 255, 255),
    model = "models/player/eli.mdl",
    description = [[
		Yasal silah satışı, mühimmat ve ekipman satmaktan sorumlusun.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "silahsaticisi",
    max = 2,
    salary = 1500,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Sivil",
    canDemote = false,

})

TEAM_DJ = DarkRP.createJob("DJ", {
    color = Color(255, 255, 255),
    model = "models/lordvipes/daftpunk/player/dp_t_01_player.mdl",
    description = [[
		Müzik çalarak insanları eğlendirmekten sorumlusun.

		]] .. rule_indent .. yes_icon .. [[Şehir kurallarına uygun sesler açmalısın!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Sadece Radyodan açabilirsin, soundpad üzerinden yapamazsın!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "dj",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_OBEZ = DarkRP.createJob("Obez", {
    color = Color(255, 255, 255),
    model = "models/dawson/obese_male_deluxe_edition/obese_male_gregory_01.mdl",
    description = [[
		Sağlıktı besl- amaaan boşver bu hayata bir defa geliyorsun.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "obez",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Sivil",
    canDemote = false,

})

TEAM_KEDI = DarkRP.createJob("Kedi", {
    color = Color(255, 255, 255),
    model = "models/yevocore/cat/cat.mdl",
    description = [[
        Sadece köpekleri tırmalayabilirsin.
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
		
    ]],
    weapons = {
        "weapon_cat",
        "weapon_gpee",
    },
    command = "kedi",
    max = 3,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,
})

TEAM_KOPEK = DarkRP.createJob("Köpek", {
    color = Color(255, 255, 255),
    model = "models/doge_player/doge_player.mdl",
    description = [[
        Sadece kedileri ısırabilirsin.
		
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
		
    ]],
    weapons = {
        "weapon_pet",
        "weapon_gpee"
    },
    command = "kopek",
    max = 3,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sivil",
    canDemote = false,
})




-- Devlet Gorevlileri--

TEAM_BASKAN = DarkRP.createJob("Başkan", {
    color = Color(0, 0, 255),
    model = "models/Player/Donald_Trump.mdl",
    description = [[
		Şehri yöneten seçilmiş bir lidersin! Yasaları belirlemeli, polis ve kamu hizmetlerini yönetmelisin.

		]] .. rule_indent .. no_icon .. [[İllegal aktivitelere izin veremezsin!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_bo1_python","weapon_rdo_radio"},
    command = "baskan",
    max = 1,
    salary = 10000,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = true,
    mayor = true,
	agenda = "BaskanDuyurusu", 
    canRequestWarrant = true,
    canRequestWanted = true,
    canUnwarrant = true,
    PlayerSpawn = function(ply)
        ply:SetHealth(200)
        ply:SetArmor(200)
		ply:SetMaxArmor(200)
		ply:SetMaxHealth(200)
    end,
    PlayerDeath = function(ply, weapon, killer)
        ply:teamBan()
        ply:changeTeam(GAMEMODE.DefaultTeam, true)
        DarkRP.notifyAll(0, 4, "Başkan hayatını kaybetti!")
    end,
})

TEAM_POLIS = DarkRP.createJob("Polis", {
    color = Color(0, 0, 255, 255),
    model = {
        "models/kerry/nypd_v2/male_04.mdl",
        "models/kerry/nypd_v2/male_01.mdl",
        "models/kerry/nypd_v2/male_09.mdl",
        "models/kerry/nypd_v2/male_03.mdl",
    },
    description = [[
		Şehrin güvenliğini koruyan polis!

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_bo2_fiveseven","weapon_rdo_radio","weapon_rdo_radio"},
    command = "polis",
    max = 8,
    salary = 3000,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_BASKOMISER = DarkRP.createJob("Baş Komiser", {
    color = Color(0, 0, 255),
    model = "models/pacagma/re2_leon/leon_sk/leon_s_kennedy_player.mdl",
    description = [[
		Tüm polislerin başındaki rütbeli lider; operasyonları Amir ile planlar ve bölge güvenliğini sağlar.
		Rüşvet, yetki suistimali ve hukuksuz emirler kesinlikle yasaktır.

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_mw2_deagle","weapon_rdo_radio"},
    command = "baskomiser",
    max = 1,
    salary = 3500,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWarrant = true,
    canRequestWanted = true,
    canUnwarrant = true,
})


TEAM_FIB1 = DarkRP.createJob("FIB Şefi", {
    color = Color(0, 0, 255),
    model = "models/player/griffbo/dalecooper.mdl",
    description = [[
		Birim hakkındaki tüm evraklar silinmiş gözüküyor
]]
,
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_mw2_deagle","weapon_rdo_radio"},
    command = "fibsef",
    max = 1,
    salary = 10000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWarrant = true,
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_FIB2 = DarkRP.createJob("FIB Memuru", {
    color = Color(0, 0, 255),
    model = {
        "models/player/icpd/fbi2/female_01.mdl", 
        "models/player/icpd/fbi2/female_02.mdl", 
        "models/player/icpd/fbi2/female_03.mdl", 
        "models/player/icpd/fbi2/female_04.mdl", 
        "models/player/icpd/fbi2/female_06.mdl",
        "models/player/icpd/fbi2/female_07.mdl",
        "models/player/icpd/fbi2/female_gta_01.mdl",
        "models/player/icpd/fbi2/female_gta_02.mdl",
        "models/player/icpd/fbi2/male_01.mdl",
        "models/player/icpd/fbi2/male_02.mdl",
        "models/player/icpd/fbi2/male_03.mdl",
        "models/player/icpd/fbi2/male_04.mdl",
        "models/player/icpd/fbi2/male_05.mdl",
        "models/player/icpd/fbi2/male_06.mdl",
        "models/player/icpd/fbi2/male_07.mdl",
        "models/player/icpd/fbi2/male_08.mdl",
        "models/player/icpd/fbi2/male_09.mdl",
        "models/player/icpd/fbi2/male_gta_01.mdl",
        "models/player/icpd/fbi2/male_gta_02.mdl"
    },
    description = [[
		Kayıtlarda çok birşey gözükmüyor derin gibi

]] ,
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_mw2_deagle","weapon_rdo_radio"},
    command = "fibmemur",
    max = 2,
    salary = 10000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWarrant = true,
    canRequestWanted = true,
    canUnwarrant = true,
})


TEAM_AMIR = DarkRP.createJob("Amir", {
    color = Color(0, 0, 255),
    model = "models/players/mj_coc_private.mdl",
    description = [[
		Tüm emniyet güçlerinin başındaki yüksek rütbeli lider; operasyonları planlar ve bölge güvenliğini sağlar.
		Rüşvet, yetki suistimali ve hukuksuz emirler kesinlikle yasaktır.

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_bo1_cz75","weapon_rdo_radio"},
    command = "amir",
    max = 1,
    salary = 4000,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWarrant = true,
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_POH = DarkRP.createJob("SWAT", {
    color = Color(0, 0, 255),
    model = "models/konnie/isa/detroit/swat_soldier.mdl",
    description = [[
		Terörle mücadele, rehine kurtarma ve yüksek riskli operasyonlarda görev alan seçkin birlik. Sivillere zarar vermek ve yetki suistimali kesinlikle yasaktır.

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_mw2_mp5k","weapon_rdo_radio"},
    command = "swat",
    max = 4,
    salary = 3000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_POHSIHHIYE = DarkRP.createJob("SWAT Sıhhiye", {
    color = Color(0, 0, 255),
    model = "models/konnie/isa/detroit/swat_soldier.mdl",
    description = [[
		Terörle mücadele, rehine kurtarma ve yüksek riskli operasyonlarda görev alan seçkin birlik. Sivillere zarar vermek ve yetki suistimali kesinlikle yasaktır.

		Polis Özel Harekat birliklerini iyileştirmekten sorumlusun!

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_mw2_mp5k","dsr_medkit","weapon_rdo_radio"},
    command = "swatsihhiye",
    max = 2,
    salary = 3000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_POHKESKIN = DarkRP.createJob("SWAT Keskin Nişancı", {
    color = Color(0, 0, 255),
    model = "models/konnie/isa/detroit/swat_soldier_2.mdl",
    description = [[
		Terörle mücadele, rehine kurtarma ve yüksek riskli operasyonlarda görev alan seçkin birlik. Sivillere zarar vermek ve yetki suistimali kesinlikle yasaktır.

		Uzun menzilden hassas atışlarla operasyon ekiplerini korur ve kritik hedefleri etkisiz hâle getirir.

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_bo1_l96","arccw_bo2_fiveseven","weapon_rdo_radio"},
    command = "swatkeskinnisanci",
    max = 2,
    salary = 3000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_POHKOMUTANI = DarkRP.createJob("SWAT Komutanı", {
    color = Color(0, 0, 255),
    model = "models/konnie/isa/detroit/swat_captainallen.mdl",
    description = [[
		Baskın operasyonları,lockdown kaldınmalarını gibi ciddi operasyonlarda takımını yönetip kritik operasyonları planlar ve icra eder; hedefe ulaşmak için strateji belirler.

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_mw2_m4","dsr_medkit","weapon_rdo_radio"},
    command = "swatkomutani",
    max = 1,
    salary = 4000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWarrant = true,
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_BASKANKORUMASI = DarkRP.createJob("Başkan Koruması", {
    color = Color(0, 0, 255),
    model = "models/player/smith.mdl",
    description = [[
		Başkanın 1.Derece yakın korumasısın, başkanın emrinden çıkma!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_bo2_fiveseven","weapon_rdo_radio"},
    command = "baskankorumasi",
    max = 2,
    salary = 3000,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWanted = true,
    canUnwarrant = true,
})

TEAM_DOKTOR = DarkRP.createJob("Doktor", {
    color = Color(0, 0, 255),
    model = {
    "models/toju/hgg/doctors/female_01.mdl",
    "models/toju/hgg/doctors/male_09.mdl" ,
    },
    description = [[
		Doktorsun sana gelen hastalarla ilgilen!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_medkit","dsr_taser","weapon_rdo_radio"},
    command = "doktor",
    max = 3,
    salary = 7000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Devlet Gorevlileri",
    canDemote = false,
})

TEAM_AVUKAT = DarkRP.createJob("Avukat", {
    color = Color(0, 0, 255),
    model = "models/Player/saul/saul.mdl",
    description = [[
		Mahkemede müvekkillerini savunan, kanunları yorumlayıp adalet için mücadele eden hukuk profesyoneli.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "avukat",
    max = 3,
    salary = 2500,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
})

TEAM_HAKIM = DarkRP.createJob("Hakim", {
    color = Color(0, 0, 255),
    model = "models/kryptonite/phil_coulson/phil_coulson.mdl",
    description = [[
		Mahkeme salonunda adaleti temsil eder; davaları dinler, delilleri değerlendirir ve nihai kararı verir.
		Rüşvet, taraf tutma ve hukukun dışına çıkmak kesinlikle yasaktır.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_metal_detector","arccw_bo3_bloodhound","weapon_rdo_radio"},
    command = "hakim",
    max = 1,
    salary = 3000,
    admin = 0,
    vote = true,
    hasLicense = true,
    category = "Devlet Gorevlileri",
    canDemote = false,
    canRequestWarrant = true,
    canRequestWanted = true,
    canUnwarrant = true,
})

--İllegal--

TEAM_FAHISE = DarkRP.createJob("Fahişe", {
    color = Color(255, 0, 0),
    model = "models/doaxvv/Amy Bunny Suit.mdl",
    description = [[
		Şehirdeki nadide hanımefendi, müşterilerine gizlilik ve nezaketle hizmet sunabilirsin.

		]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Baskın atamazsın!
    ]],
    weapons = {"weapon_kidnap","weapon_r_restrains","slappers",},
    command = "fahise",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_TETIKCI = DarkRP.createJob("Tetikçi", {
    color = Color(255, 0, 0),
    model = "models/player/hitman_absolution_47_classic.mdl",
    description = [[
		Para karşılığı hedeflerini indirmekle yükümlüsün!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
    ]],
    weapons = {"arccw_waw_k98k",},
    command = "tetikci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    hitman = true,
    category = "Illegal Meslekler",
    canDemote = false,
	vote = true,

    PlayerDeath = function(ply, weapon, killer)
        ply:teamBan()
        ply:changeTeam(GAMEMODE.DefaultTeam, true)
    end,
})

TEAM_KAPKACCI = DarkRP.createJob("Kapkaççı", {
    color = Color(255, 0, 0),
    model = "models/player/witness.mdl",
    description = [[
		Kalabalık sokaklarda profesyonel yankesici; cüzdan ve değerli eşyaları sessizce çalma ustası.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
    ]],
    weapons = {"pickpocket",},
    command = "kapkacci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_HIRSIZ = DarkRP.createJob("Hırsız", {
    color = Color(255, 0, 0),
    model = "models/player/terrorist/terrorist.mdl",
    description = [[
		Planlı soygunlar düzenleyip ev ve iş yerlerine sessizce girebilirsin!

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {"dsr_lockpick","bkeypads_cracker",},
    command = "hirsiz",
    max = 8,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_ZMLAB2_COOK = DarkRP.createJob("Meth Pişiricisi", {
    color = Color(255, 0, 0),
    model = {
    "models/walterwhite/playermodels/walterwhitecas.mdl",
    "models/walterwhite/playermodels/walterwhitechem.mdl",
	"models/jesse/playermodels/jesse.mdl",
    },
    description = [[
		Temiz iş çıkarırım. Kimyayla aram iyidir. Kristali benden iyi yapan yoktur vesselam.

		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "methpisiricisi",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Illegal Meslekler",
    hasLicense = false,

})


TEAM_INSANKACIRICISI = DarkRP.createJob("İnsan Kaçırıcısı", {
    color = Color(255, 0, 0),
    model = "models/player/arctic.mdl",
    description = [[
		Kurbanlarını kaçırıp fidye veya bilgi talep eden suç üyesi.

		]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
    ]],
    weapons = {"weapon_r_restrains","weapon_kidnap",},
    command = "insankaciricisi",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_GRAFITICI = DarkRP.createJob("Grafitici", {
    color = Color(255, 0, 0),
    model = "models/player/big_baby_tape.mdl",
    description = [[
		Şehrin gri duvarlarını tuval edinip renkli eserler bırakan sokak sanatçısı.

		Polislere karşı dikkatli olmalısın sana ait olmayan duvarları boyamak riskli olabilir!

		]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsız!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
    ]],
    weapons = {"graffiti-swep"},
    command = "grafitici",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_ZGO2_AMATEUR = DarkRP.createJob("Amatör Ot Yetiştiricisi", {
    color = Color(255, 0, 0),
    model = {"models/jesse/playermodels/jesse.mdl"},
    description = [[
		Ot yetiştir satarsın.

		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {"zgo2_multitool","zgo2_backpack"},
    command = "amatorotyetistiricisi",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Illegal Meslekler",
    hasLicense = false,

})

TEAM_SOYGUNCU = DarkRP.createJob("Paralı Asker", {
    color = Color(255, 0, 0),
    model = {"models/dejtriyev/paidthug/paid_thug.mdl"},
    description = [[
		illegal örgüt fark etmeksizin, sözleşme gereği silahlı güvenlik ve operasyon desteği sağlar.

        ]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
		]] .. rule_indent .. [[
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
        ]] .. rule_indent .. no_icon .. [[Mug yapamazsınız!
    ]],
    weapons = {""},
    command = "paraliasker",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_TORBACI = DarkRP.createJob("Torbacı", {
    color = Color(255, 0, 0),
    model = "models/player/player_simon_henriksson.mdl",
    description = [[
        Sokaklarda uyuşturucu ticareti yaparak kar elde et; polis baskınlarına ve rakip çetelere karşı daima tedbirli ol.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
    ]],
    weapons = {},
    command = "torbaci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_LEAN = DarkRP.createJob("Lean Üreticisi", {
    color = Color(255, 0, 0),
    model = "models/player/kleiner.mdl",
    description = [[
        Lean Üretip Satarsın.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
    ]],
    weapons = {},
    command = "lean",
    max = 3,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,

})

TEAM_SIGARA = DarkRP.createJob("Sigara Üreticisi", {
    color = Color(255, 0, 0),
    model = "models/seumadruga/seu_madruga/seu_madruga_pm.mdl",
    description = [[
        Sigara Üretip Satarsın.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
    ]],
    weapons = {},
    command = "sigara",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,
})

TEAM_KOKO = DarkRP.createJob("Koko Üreticisi", {
    color = Color(255, 0, 0),
    model = "models/toju/hgg/doctors/male_01.mdl",
    description = [[
        Koko Üretip Satarsın.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
    ]],
    weapons = {},
    command = "kokoin",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,
})

TEAM_AMATORBITCOIN = DarkRP.createJob("Amatör Bitcoinci", {
    color = Color(255, 0, 0),
    model = "models/adidas/terror_leet_player.mdl",
    description = [[
		Kripto para madenciliği yapar ve dijital varlıklarla ticaret yapar.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "amatorbitcoinci",
    max = 3,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Illegal Meslekler",
    canDemote = false,
})

----- Çeteler -----

TEAM_GROVE = DarkRP.createJob("Grove Çete Üyesi", {
    color = Color(255, 0, 0),
    model = {
        "models/sentry/senfembal/sentryfem3male1pm.mdl",
        "models/sentry/senfembal/sentryfem2male1pm.mdl"
        },
    description = [[
		Grove Street Ailesi'nin yeşil bayrağı altında, bölgesini koruyan ve rakip çetelerle amansız mücadele eden sokak savaşçısı.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
		]] .. rule_indent .. [[
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "grove",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,

})

TEAM_GROVELIDERI = DarkRP.createJob("Grove Lideri", {
    color = Color(255, 0, 0),
    model = "models/sentry/senfembal/sentryfem1male3pm.mdl",
    description = [[
		Grove Street Ailesi'nin yeşil bayrağı altında çeteyi yöneten, bölge hakimiyeti ve operasyonları planlayan üstün rütbeli lider.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {},
    command = "grovelideri",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,
	vote = true,
    PlayerSpawn = function(ply)
        ply:SetHealth(125)
    end,
})

TEAM_BALLAS = DarkRP.createJob("Ballas Çete Üyesi", {
    color = Color(255, 0, 0),
    model ={
        "models/sentry/senfembal/sentrybal3male1pm.mdl",
        "models/sentry/senfembal/sentrybal2male3pm.mdl"
        },
    description = [[
		Floyd Street Ballas'ın mor bayrağı altında, toprak kontrolü ve gölgelerin hüküm sürdüğü işlerle nam salmış bir sokak savaşçısısın.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
		]] .. rule_indent .. [[
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "ballas",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,

})

TEAM_BALLASLIDERI = DarkRP.createJob("Ballas Lideri", {
    color = Color(255, 0, 0),
    model = "models/sentry/senfembal/sentrybal1male3pm.mdl",
    description = [[
		Floyd Street Ballas'ın mor bayrağı altında çeteyi yöneten, bölge hakimiyetini ve operasyonları planlayan üstün rütbeli lider.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {},
    command = "ballaslideri",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,
	vote = true,
    PlayerSpawn = function(ply)
        ply:SetHealth(125)
    end,
})

TEAM_VAGOS = DarkRP.createJob("Vagos Çete Üyesi", {
    color = Color(255, 0, 0),
    model ={
        "models/gtasa/lsv1pm.mdl",
        "models/gtasa/lsv2pm.mdl"
        },
    description = [[
		Los Santos Vagos'un sarı bayrağı altında, toprak kontrolü ve gölgelerin hüküm sürdüğü işlerle nam salmış bir sokak savaşçısısın.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
		]] .. rule_indent .. [[
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "vagos",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,

})

TEAM_VAGOSLIDERI = DarkRP.createJob("Vagos Lideri", {
    color = Color(255, 0, 0),
    model = "models/gtasa/lsv3pm.mdl",
    description = [[
		Los Santos Vagos'un sarı bayrağı altında çeteyi yöneten, bölge hakimiyetini ve operasyonları planlayan üstün rütbeli lider.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {},
    command = "vagoslideri",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,
	vote = true,
    PlayerSpawn = function(ply)
        ply:SetHealth(125)
    end,
})

TEAM_GECEKULUBU = DarkRP.createJob("Gece Kulübü Sahibi", {
    color = Color(255, 0, 0),
    model = "models/vito.mdl",
    description = [[
		Göz önünde bulunan mekan sahibisin. Ağırlığını korumalısın. Mekanın bir çete tarafından ele geçirilmiş ise ele geçiren çeteye hizmet etmek zorundasın!

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "gecekulubusahibi",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = true,
	category = "Çeteler",
    canDemote = false,
	    PlayerSpawn = function(ply)
        ply:SetHealth(125)
    end,


})

TEAM_GECEKULUBUCALISANI = DarkRP.createJob("Gece Kulübü Çalışanı", {
    color = Color(255, 0, 0),
    model = "models/humans/mafia/male_02.mdl",
    description = [[
		Mekanın güvenliğini sağlamaktan ve misafirlere hizmet etmekten sorumlusun.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
    ]],
    weapons = {},
    command = "gecekulubucalisani",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Çeteler",
    canDemote = false,

})

TEAM_MASONLIDERI = DarkRP.createJob("Mason Lideri", {
    color = Color(255, 0, 0),
    model = "models/player/suits/the_ortho_jew.mdl",
    description = [[
		Gizli locanın en yüksek rütbeli üyesi; törenleri yönetir, stratejileri belirler ve kardeşlik bağını korur.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {},
    command = "masonlideri",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,
	vote = true,
		    PlayerSpawn = function(ply)
        ply:SetHealth(125)
    end,


})


TEAM_MASON = DarkRP.createJob("Mason", {
    color = Color(255, 0, 0),
    model = "models/player/suits/the_ortho_jew.mdl",
    description = [[
		Gizemli törenler ve kardeşlik bağıyla şehrin perde arkasındaki bağlantılarını yöneten seçkin topluluk üyesi.

        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin
		]] .. rule_indent .. [[
		]] .. rule_indent .. no_icon .. [[Mug yapamazsız!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
    ]],
    weapons = {},
    command = "mason",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Çeteler",
    canDemote = false,

})

-- Bagisci Meslekleri --

TEAM_KARABORSACI = DarkRP.createJob("Karaborsacı", {
    color = Color(238, 255, 0),
    model = "models/lief/oe.mdl",
    description = [[
		Siyah piyasada silah, kaçak malzeme ve nadir eşyaları yüksek kârla satan gizli tüccar.

		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "karaborsaci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
	PlayerSpawn = function(ply)
    ply:SetHealth(150) 
    end,
})

TEAM_PROFTETIKCI = DarkRP.createJob("Profesyonel Tetikçi", {
    color = Color(238, 255, 0),
    model = "models/emmaemmerich/sneakingsuit/playermodel/sneaking_suit_venom_snake.mdl",
    description = [[
		İnsanlardan görev alıp profesyonelce görevini tamamlayan uzman suikastçı.

		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {"arccw_bo1_dragunov","dsr_lockpick","bkeypads_cracker",},
    command = "profesyoneltetikci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
    hitman = true,
	vote = true,
    PlayerSpawn = function(ply)
    ply:SetHealth(150) 
    end,
    PlayerDeath = function(ply, weapon, killer)
        ply:teamBan()
        ply:changeTeam(GAMEMODE.DefaultTeam, true)
    end,
})

TEAM_POHAGIRZIRH = DarkRP.createJob("SWAT Ağır Zırhlı Kuvvet", {
    color = Color(238, 255, 0),
    model = "models/konnie/isa/detroit/swat_soldier_2.mdl",
    description = [[
		Yüksek korumalı ekipmanlarınla yüksek riskli operasyonlara destek veren, güçlü ateş gücü ve koruma sağlayan seçkin birlik.

		]] .. rule_indent .. yes_icon .. [[Baskın atabilirsin (Warrant)!
		]] .. rule_indent .. [[
        ]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {"dsr_handcuffs","dsr_battering_ram","dsr_taser","dsr_metal_detector","arccw_mw2_m1014","arccw_mw2_mp5k","weapon_rdo_radio"},
    command = "swatagirzirh",
    max = 1,
    salary = 10000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
    PlayerSpawn = function(ply)
        ply:SetHealth(175)
        ply:SetArmor(175)
		ply:SetMaxArmor(175)
		ply:SetMaxHealth(175)
    end,
})

TEAM_ZGO2_PRO = DarkRP.createJob("Profesyonel Ot Yetiştiricisi", {
    color = Color(238, 255, 0),
    model = {"models/player/voikanaa/snoop_dogg.mdl"},
    description = [[
		İşinde ustalaşmış olduğunu kanıtladın ve mükemmel otlar yetiştirmeye gelişmiş bir şekilde devam ediyorsun!

		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {"zgo2_multitool","zgo2_backpack"},
    command = "profesyonelotyetistiricisi",
    max = 4,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Bagisci Meslekleri",
    hasLicense = false,
	PlayerSpawn = function(ply)
    ply:SetHealth(150)
    end,

})


TEAM_PROFHIRSIZ = DarkRP.createJob("Profesyonel Hırsız", {
    color = Color(238, 255, 0),
    model = {
    "models/player/arnold_schwarzenegger.mdl",
    "models/theboys/butcher.mdl",
    },
    description = [[
		Planlı ve uzman soygunlar düzenleyerek yüksek değerli eşyaları sessizce soyan usta..

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {"dsr_lockpick","bkeypads_cracker",},
    command = "profesyonelhirsiz",
    max = 6,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
	PlayerSpawn = function(ply)
    ply:SetHealth(150)
    end,

})


TEAM_PARALIASKERLIDERI = DarkRP.createJob("Paralı Asker Lideri", {
    color = Color(238, 255, 0),
    model = "models/breaking_bad/mike_ehrmantraut.mdl",
    description = [[
		Birliklerini yönetir, strateji belirler ve organize eder.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {"dsr_lockpick","bkeypads_cracker","weapon_kidnap_pro","weapon_r_restrains","arccw_mw2_mp5k",},
    command = "paraliaskerlideri",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
	vote = true,
    PlayerSpawn = function(ply)
    ply:SetHealth(150) 
    end,
})

TEAM_PROFADAMKACIRICI = DarkRP.createJob("Profesyonel Adam Kaçırıcı", {
    color = Color(238, 255, 0),
    model = "models/player/citizen_tonnylife/male_04.mdl",
    description = [[
		Birliklerini yönetir, strateji belirler ve organize eder.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {"dsr_lockpick","bkeypads_cracker","weapon_kidnap_pro","weapon_r_restrains",},
    command = "profesyoneladamkacirici",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
    PlayerSpawn = function(ply)
    ply:SetHealth(150) 
    end,
})

TEAM_PROFESYONELKAPKACCI = DarkRP.createJob("Profesyonel Kapkaççı", {
    color = Color(238, 255, 0),
    model = "models/mark2580/dmc/dmc_dante_player.mdl",
    description = [[
		Birliklerini yönetir, strateji belirler ve organize eder.

		]] .. rule_indent .. yes_icon .. [[Mug yapabilirsin!
		]] .. rule_indent .. yes_icon .. [[Raid atabilirsin!
        ]] .. rule_indent .. yes_icon .. [[Kidnap yapabilirsin!
    ]],
    weapons = {"dsr_lockpick","bkeypads_cracker","pro_pickpocket",},
    command = "profesyonelkapkacci",
    max = 1,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
    PlayerSpawn = function(ply)
    ply:SetHealth(150)
    end,
})


TEAM_ISADAMI = DarkRP.createJob("İş Adamı", {
    color = Color(238, 255, 0),
    model = "models/player/fring/Gus_suit.mdl",
    description = [[
		Büyük yatırımlar yapar, şirketleri yönetir ve şehrin ekonomisinde önemli rol oynar.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "isadami",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
    PlayerSpawn = function(ply)
    ply:SetHealth(150)
    end,
})

TEAM_PROFSIGARA = DarkRP.createJob("Profesyonel Sigara Üreticisi", {
    color = Color(238, 255, 0),
    model = "models/TLOU1/YoungTommy_PM.mdl",
    description = [[
        Sigara Üretip Satarsın.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
    ]],
    weapons = {},
    command = "profesyonelsigara",
    max = 3,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
	PlayerSpawn = function(ply)
    ply:SetHealth(150)
    end,
})

TEAM_BITCOIN = DarkRP.createJob("Bitcoinci", {
    color = Color(238, 255, 0),
    model = "models/matrix/neo_player.mdl",
    description = [[
		Kripto para madenciliği yapar ve dijital varlıklarla ticaret yapar.

		]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
        ]] .. rule_indent .. no_icon .. [[Kidnap yapamazsın!
    ]],
    weapons = {},
    command = "bitcoinci",
    max = 5,
    salary = 1000,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Bagisci Meslekleri",
    canDemote = false,
    PlayerSpawn = function(ply)
    ply:SetHealth(150)
    end,
})

--Yetkili--

TEAM_YETKILI = DarkRP.createJob("Yetkili Görevde", {
    color = Color(43, 255, 0),
    model = "models/player/police.mdl",
    description = [[
        Yetkili Görevde
    ]],
    weapons = {
        "bkeypads_access_logs",
        "gas_log_scanner"
    },
    command = "yetkili",
    max = 0,
    salary = 20000,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "Yetkili",
    canDemote = false,
    PlayerSpawn = function(ply)
        ply:SetHealth(99999)
        ply:SetMaxHealth(99999)
        ply:SetArmor(99999)
        ply:SetMaxArmor(99999)
    end,
})



--[[---------------------------------------------------------------------------
Define which team joining players spawn into and what team you change to if demoted
---------------------------------------------------------------------------]]
GAMEMODE.DefaultTeam = TEAM_SIVIL
--[[---------------------------------------------------------------------------
Define which teams belong to civil protection
Civil protection can set warrants, make people wanted and do some other police related things
---------------------------------------------------------------------------]]
GAMEMODE.CivilProtection = {
    [TEAM_POLIS] = true,
    [TEAM_BASKOMISER] = true,
    [TEAM_AMIR] = true,
    [TEAM_BASKAN] = true,
    [TEAM_POH] = true,
    [TEAM_POHAGIRZIRH] = true,
	[TEAM_POHKESKIN] = true,
    [TEAM_POHKOMUTANI] = true,
    [TEAM_POHSIHHIYE] = true,
	[TEAM_BASKANKORUMASI] = true,
    [TEAM_HAKIM] = true,
	[TEAM_FIB1] = true,
    [TEAM_FIB2] = true,
}
--[[---------------------------------------------------------------------------
Jobs that are hitmen (enables the hitman menu)
---------------------------------------------------------------------------]]
DarkRP.addHitmanTeam(TEAM_TETIKCI)
DarkRP.addHitmanTeam(TEAM_PROFTETIKCI)