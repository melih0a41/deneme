-- Add all categories and DarkRP entities here automatically.

function CH_BITMINERS_DarkRPEntities()
    -- Categories
    DarkRP.createCategory{
        name = "Bitminer Ekipmanları",
        categorises = "entities",
        startExpanded = true,
        color = Color(0, 107, 0, 255),
        canSee = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        sortOrder = 50,
    }

    -- Entities
    DarkRP.createEntity("Güç Kablosu", {
        ent = "ch_bitminer_power_cable",
        model = "models/craphead_scripts/bitminers/utility/plug.mdl",
        price = 1000,
        max = 5,
        category = "Bitminer Ekipmanları",
        cmd = "buypowercable",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Jeneratör", {
        ent = "ch_bitminer_power_generator",
        model = "models/craphead_scripts/bitminers/power/generator.mdl",
        price = 50000,
        max = 2,
        category = "Bitminer Ekipmanları",
        cmd = "buypowergenerator",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Güneş Paneli", {
        ent = "ch_bitminer_power_solar",
        model = "models/craphead_scripts/bitminers/power/solar_panel.mdl",
        price = 100000,
        max = 2,
        category = "Bitminer Ekipmanları",
        cmd = "buysolarpanel",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN end,
        allowed = {TEAM_BITCOIN}
    })

    DarkRP.createEntity("Güç Birleştirici", {
        ent = "ch_bitminer_power_combiner",
        model = "models/craphead_scripts/bitminers/power/power_combiner.mdl",
        price = 10000,
        max = 1,
        category = "Bitminer Ekipmanları",
        cmd = "buypowercombiner",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Bitmining Rafı (Standart)", {
        ent = "ch_bitminer_shelf",
        model = "models/craphead_scripts/bitminers/rack/rack.mdl",
        price = 25000,
        max = 1,
        category = "Bitminer Ekipmanları",
        cmd = "buyminingshelf",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Ekstra Bitmining Rafı", {
        ent = "ch_bitminer_shelf",
        model = "models/craphead_scripts/bitminers/rack/rack.mdl",
        price = 35000,
        max = 1,
        category = "Bitminer Ekipmanları",
        cmd = "buyextraminingshelf",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN end,
        allowed = {TEAM_BITCOIN}
    })

    DarkRP.createEntity("Soğutma Yükseltmesi", {
        ent = "ch_bitminer_upgrade_cooling3",
        model = "models/craphead_scripts/bitminers/utility/cooling_upgrade_3.mdl",
        price = 40000,
        max = 1,
        category = "Bitminer Ekipmanları",
        cmd = "buycooling3",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Tekli Miner", {
        ent = "ch_bitminer_upgrade_miner",
        model = "models/craphead_scripts/bitminers/utility/miner_solo.mdl",
        price = 15000,
        max = 3,
        category = "Bitminer Ekipmanları",
        cmd = "buysingleminer",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("RGB Kit Yükseltmesi", {
        ent = "ch_bitminer_upgrade_rgb",
        model = "models/craphead_scripts/bitminers/utility/rgb_kit.mdl",
        price = 5000,
        max = 1,
        category = "Bitminer Ekipmanları",
        cmd = "buyrgbkit",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Güç Kaynağı Yükseltmesi", {
        ent = "ch_bitminer_upgrade_ups",
        model = "models/craphead_scripts/bitminers/utility/ups_solo.mdl",
        price = 10000,
        max = 1,
        category = "Bitminer Ekipmanları",
        cmd = "buyupsupgrade",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Yakıt", {
        ent = "ch_bitminer_power_generator_fuel_large",
        model = "models/craphead_scripts/bitminers/utility/jerrycan.mdl",
        price = 3500,
        max = 1,
        category = "Bitminer Ekipmanları",
        cmd = "buygeneratorfuellarge",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

    DarkRP.createEntity("Temizlik Sıvısı", {
        ent = "ch_bitminer_upgrade_clean_dirt",
        model = "models/craphead_scripts/bitminers/cleaning/spraybottle.mdl",
        price = 1500,
        max = 2,
        category = "Bitminer Ekipmanları",
        cmd = "buydirtcleanfluid",
        customCheck = function(ply) return ply:Team() == TEAM_BITCOIN or ply:Team() == TEAM_AMATORBITCOIN end,
        allowed = {TEAM_BITCOIN, TEAM_AMATORBITCOIN}
    })

end
hook.Add( "loadCustomDarkRPItems", "CH_BITMINERS_DarkRPEntities", CH_BITMINERS_DarkRPEntities )