/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

zpiz.config.Ingredient = {
    // How many ingredients can each player spawn
    Limit = 50,

    // How long until the ingredient despawn, -1 disables this function
    Despawn = 60
}

// This Sets up our Fridge Shop and also the available Ingredients for Pizza
zpiz.config.Ingredients = {}
local function AddIngredient(data) return table.insert(zpiz.config.Ingredients,data) end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}

-- Her oyuncunun oluşturabileceği malzeme sayısı
zpiz.config.Ingredient = {
    Limit = 20,

    -- Malzemenin kaybolana kadar geçen süre (saniye), -1 devre dışı bırakır
    Despawn = 30
}

-- Buzdolabı dükkanımızı ve pizza için mevcut malzemeleri ayarlıyoruz
zpiz.config.Ingredients = {}
local function AddIngredient(data) return table.insert(zpiz.config.Ingredients, data) end

ZPIZ_ING_DOUGH = AddIngredient({
    name  = "Hamur",
    model = "models/zerochain/props_pizza/zpiz_pizzadough.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_dough.png", "smooth"),
    desc  = "Pizza Hamuru",
    limit = 6,
    price = 15
})

ZPIZ_ING_TOMATO = AddIngredient({
    name  = "Domates Sosu",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_tomato.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_tomato.png", "smooth"),
    desc  = "Temel Sos",
    price = 10,
    limit = 3,
    color = Color(200, 0, 0)
})

ZPIZ_ING_CHEESE = AddIngredient({
    name  = "Peynir",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_cheese.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_cheese.png", "smooth"),
    desc  = "Biraz kokulu peynir",
    price = 15,
    limit = 3,
    color = Color(252, 223, 118)
})

ZPIZ_ING_SPINAT = AddIngredient({
    name  = "Ispanak",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_spinat.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_spinat.png", "smooth"),
    desc  = "Ispanak olabilir, bilmiyorum",
    price = 15,
    limit = 3,
    color = Color(139, 164, 60)
})

ZPIZ_ING_SALAMI = AddIngredient({
    name  = "Salam",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_salami.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_salami.png", "smooth"),
    desc  = "Diyelim ki Salam, tamam mı",
    price = 75,
    limit = 3,
    color = Color(131, 23, 29)
})

ZPIZ_ING_OLIVES = AddIngredient({
    name  = "Zeytin",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_olives.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_olive.png", "smooth"),
    desc  = "Taze zeytinler!",
    price = 10,
    limit = 3,
    color = Color(156, 155, 34)
})

ZPIZ_ING_EGGPLANT = AddIngredient({
    name  = "Patlıcan",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_eggplant.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_eggplant.png", "smooth"),
    desc  = "Taze gibi kullanilir",
    price = 80,
    limit = 3,
    color = Color(90, 14, 94)
})

ZPIZ_ING_CHILLI = AddIngredient({
    name  = "Biber",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_chilli.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_chilli.png", "smooth"),
    desc  = "Çok acı!",
    price = 75,
    limit = 3,
    color = Color(255, 57, 57)
})

ZPIZ_ING_PICKLE = AddIngredient({
    name  = "Turşu",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_pickle.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_pickle.png", "smooth"),
    desc  = "Bu bir turşu!",
    price = 25,
    limit = 3,
    color = Color(25, 31, 19)
})

ZPIZ_ING_MUSHROOM = AddIngredient({
    name  = "Mantar",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_mushroom.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_mushroom.png", "smooth"),
    desc  = "O mantar",
    price = 15,
    limit = 3,
    color = Color(249, 220, 178)
})

ZPIZ_ING_PINEAPPLE = AddIngredient({
    name  = "Ananas",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_pineapple.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_pineapple.png", "smooth"),
    desc  = "Tuhaf!",
    price = 80,
    limit = 3,
    color = Color(238, 175, 74)
})

ZPIZ_ING_EGG = AddIngredient({
    name  = "Yumurta",
    model = "models/props_phx/misc/egg.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_egg.png", "smooth"),
    desc  = "Bir yumurta",
    price = 50,
    limit = 3,
    color = Color(229, 229, 229)
})

ZPIZ_ING_BACON = AddIngredient({
    name  = "Pastırma",
    model = "models/zerochain/props_pizza/zpizmak_ingredient_bacon.mdl",
    icon  = Material("materials/zerochain/zpizmak/ui/icons/zpizmak_bacon.png", "smooth"),
    desc  = "Pastırma! Pastırma! Pastırma!",
    price = 75,
    limit = 3,
    color = Color(118, 29, 33)
})
