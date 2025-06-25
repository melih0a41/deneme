/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

-- Yeşil Tik HTML Kodu
local yes_icon = '<img src="https://i.imgur.com/rcRf2ja.png" width="16" height="16"> '
-- Kırmızı Çarpı HTML Kodu
local no_icon = '<img src="https://i.imgur.com/Xzb6Qr9.png" width="16" height="16"> '
local rule_indent = "\t\t" -- Tüm kural satırları için standart girinti


TEAM_ZCRGA_ARCADEOWNER = DarkRP.createJob("Şans Makinesi Sahibi", {
    color = Color(238, 255, 0),
    model = {"models/player/group03/male_04.mdl"},
    description = [[Şans Makinelerini kullanarak insanlara kazanç vaat et ve sen kazan.
				]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
	]],
    weapons = {},
    command = "zcrga_arcadeowner",
    max = 2,
    salary = 5000,
    admin = 0,
    vote = false,
    category = "Bagisci Meslekleri",
    hasLicense = false,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

DarkRP.createCategory{
    name = "Şans Makinesi",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 107, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 104
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c88d96e23ef1c52b933ccc1d3ce15226554b8e572b9dbf763835533b4e11507c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 049b4e254ea84b6bbd8714673e122cc1e8af2018030f6cc079898e33e35e9c0c

DarkRP.createEntity("Eğlence Makinesi", {
    ent = "zcrga_machine",
    model = "models/zerochain/props_arcade/zap_coinpusher.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzcrga_machine",
    allowed = {TEAM_ZCRGA_ARCADEOWNER},
    category = "Şans Makinesi"
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
