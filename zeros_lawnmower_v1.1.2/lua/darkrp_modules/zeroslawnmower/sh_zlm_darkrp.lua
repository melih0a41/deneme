/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

-- Yeşil Tik HTML Kodu
local yes_icon = '<img src="https://i.imgur.com/rcRf2ja.png" width="16" height="16"> '
-- Kırmızı Çarpı HTML Kodu
local no_icon = '<img src="https://i.imgur.com/Xzb6Qr9.png" width="16" height="16"> '
local rule_indent = "\t\t" -- Tüm kural satırları için standart girinti


TEAM_ZLM_LAWNMOWERMAN = DarkRP.createJob("Bahçıvan", {
    color = Color(255, 255, 255),
    model = {"models/player/Group01/male_06.mdl"},
    description = [[Para Kazanmak için güzel bir yol çimleri biç makinede öğüt paranı al.
				]] .. rule_indent .. no_icon .. [[Raid atamazsın!
		]] .. rule_indent .. no_icon .. [[Mug yapamazsın!
		]] .. rule_indent .. no_icon .. [[İllegal Aktivitelere Katılamazsın!
		]],
    weapons = {},
    command = "zlm_lawnmowerman",
    max = 2,
    salary = 1000,
    admin = 0,
    vote = false,
    category = "Sivil",
    hasLicense = false
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

DarkRP.createCategory{
    name = "Ekipmanlar",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 107, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 104
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

DarkRP.createEntity("Çim Öğütücü", {
    ent = "zlm_grasspress",
    model = "models/zerochain/props_lawnmower/zlm_grasspress.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzlm_grasspress",
    allowed = {TEAM_ZLM_LAWNMOWERMAN},
    category = "Ekipmanlar"
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
