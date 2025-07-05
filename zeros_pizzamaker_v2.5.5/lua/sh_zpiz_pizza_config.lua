/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}

zpiz.config.Pizza = {}
local function AddPizza(data) return table.insert(zpiz.config.Pizza,data) end

AddPizza({
    // Pizzanın adı
    name = "Margarita",
    -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 10,

    // Pizzanın açıklaması
    desc = "Temel Pizza!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_magarita.png", "smooth"),
    -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 50,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 5,
    -- 76561198872838622

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Ispanaklı Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SPINAT] = 2,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 15,

    // Pizzanın açıklaması
    desc = "Sevilmeyen Pizza!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_spinat.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 25,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 15,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Salamli Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SALAMI] = 2,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 15,

    // Pizzanın açıklaması
    desc = "Bir eşek pizzası!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_salami.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 10,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 15,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Zeytinli Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_OLIVES] = 3,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 20,

    // Pizzanın açıklaması
    desc = "Italyan pizzası!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_olivia.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 10,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 15,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Büyük Boy Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SALAMI] = 1,
        [ZPIZ_ING_OLIVES] = 1,
        [ZPIZ_ING_EGGPLANT] = 1,
        [ZPIZ_ING_SPINAT] = 1,
        [ZPIZ_ING_PICKLE] = 1,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 120,

    // Pizzanın açıklaması
    desc = "Büyük bir pizza!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_grande.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 5,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 60,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 200
})

AddPizza({
    // Pizzanın adı
    name = "Pastırma Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_BACON] = 2,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 25,

    // Pizzanın açıklaması
    desc = "Pastırmalı pizza!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_bacon.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 10,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 15,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Yumurtali Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_EGG] = 1,
        [ZPIZ_ING_CHILLI] = 1,
        [ZPIZ_ING_BACON] = 1,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 25,

    // Pizzanın açıklaması
    desc = "Fazla yumurta.",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_egg.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 10,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 15,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Mantarli Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 1,
        [ZPIZ_ING_SPINAT] = 1,
        [ZPIZ_ING_CHILLI] = 1,
        [ZPIZ_ING_MUSHROOM] = 1,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 25,

    // Pizzanın açıklaması
    desc = "Sarhos etmez.",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_mushroom.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 10,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 15,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Tropikal Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 2,
        [ZPIZ_ING_PINEAPPLE] = 1,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 30,

    // Pizzanın açıklaması
    desc = "Tropikal tat!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_hawai.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 10,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 15,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})

AddPizza({
    // Pizzanın adı
    name = "Cheddar Peynir Pizza",

    // Gerekli malzemeler
    recipe = {
        [ZPIZ_ING_TOMATO] = 1,
        [ZPIZ_ING_CHEESE] = 3,
    },

    // Pizzanın pişmesi için gereken süre (saniye cinsinden)
    time = 30,

    // Pizzanın açıklaması
    desc = "Peynirli bir pizza!",

    // Pizzanın fiyatı (malzeme maliyeti bu değere daha sonra eklenir)
    price = 5000,

    // Pizza piştiğinde nasıl görünecek
    icon = Material("materials/zerochain/zpizmak/ui/pizzas/pizza_cheese.png", "smooth"),

    // Bir müşterinin bu pizzayı seçme olasılığı (1-100)
    chance = 10,

    // Oyuncu pizzayı yediğinde kazanacağı sağlık miktarı
    health = 5,

    // Burada özelleştirilmiş sağlık sınırını belirleyebilirsiniz
    health_cap = 100
})
