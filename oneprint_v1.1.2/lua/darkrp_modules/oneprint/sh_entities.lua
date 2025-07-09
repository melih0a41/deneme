/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

-- TEAM_PRINTER = DarkRP.createJob("OnePrint", {
--     color = Color(228, 130, 38),
--     model = {"models/player/odessa.mdl"},
--     description = [[ Farm with printers ]],
--     weapons = {},
--     command = "oneprint_job",
--     max = 1,
--     salary = 20,
--     admin = 0,
--     vote = false,
--     category = "Citizens",
--     hasLicense = false
-- })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

DarkRP.createCategory{
    name = "OnePrint",
    categorises = "entities",
    startExpanded = true,
    color = Color(228, 152, 38),
    canSee = function(ply)
        return true -- Herkes görebilir
    end,
    sortOrder = 100,
}

DarkRP.createEntity("OnePrint", {
    ent = "oneprint",
    model = "models/ogl/ogl_oneprint.mdl",
    price = 50000,
    max = 1,
    cmd = "oneprint_ent",
    customCheck = function(ply)
        return true -- Herkes alabilir
    end,
    category = "OnePrint",
})
