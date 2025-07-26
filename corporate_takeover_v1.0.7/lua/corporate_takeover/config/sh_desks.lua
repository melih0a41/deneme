////////////////////////////////
//                            //
//     Corporate Takeover     //
//     By KiwontaTv & Ian     //
//                            //
//           04/2025          //
//                            //
//     STEAM_0:0:178850058    //
//     STEAM_0:1:153915274    //
//                            //
//        Configuration       //
//                            //
////////////////////////////////

// Keep these lines!
Corporate_Takeover.Desks = {} -- this is really important! Desks need to be reset in order to be reloaded!
Corporate_Takeover.Researches = {} -- this is really important! Researches need to be reset in order to be reloaded!

/*
    This is a demo desk to show you, how it works. It will NOT get loaded.
*/
Corporate_Takeover:addDesk("demo", { -- Desk class - IMPORTANT: Must be unique!
    name = Corporate_Takeover:Lang("demo"), -- Desk name, must be in the language file.
    class = "demo", -- Actual desk class (entity. If you want to create a worker desk, use worker_desk)
    max = 1, -- maximum number of this desk

    price = 5000, -- Price to buy
    level = 7, -- minimum level
    sell = .4, -- The percentage of money you can get back when selling a desk (.4 = 40%; 35% = .35 and so on...)

    upkeepCost = 1.0, -- UpkeepCost multiplier - How much does the desk cost per tick (Percentage of basevalue - see Corporate_Takeover.Config.UpkeepBasecost)
    earningMultiplier = 1.25, -- Mutliplier of how much this desk can earn

    buyable = true,
    restriction = "admin", -- Groups set in the config ["admin" or "donator"]

    bodygroups = { -- bodygroubs according to the model
        [1] = 4,
        [2] = 4,
        [3] = 4,
    },

    skin = 0, -- skins according to the model

    model = "models/corporate_takeover/nostras/boss_desk.mdl", -- model duh....
    modeloffset = 0, -- Z-offset
    modelang = 90, -- Angles offset

    health = 500, -- Health
})
/*
    Demo ends
*/

// NEVER remove the corporate_desk!
Corporate_Takeover:addDesk("corporate_desk", {
    name = Corporate_Takeover:Lang("corporate_desk"),
    class = "corporate_desk",
    max = 1,

    price = 5000,
    sell = .4,

    upkeepCost = 1.0,

    model = "models/corporate_takeover/nostras/boss_desk.mdl",
    modeloffset = 0,
    modelang = 90,

    health = 500,
})

Corporate_Takeover:addDesk("vault", {
    name = Corporate_Takeover:Lang("vault"),
    class = "corp_vault",
    max = 1,

    upkeepCost = 1.0,

    buyable = true,
    level = 3,
    price = 1000, 
    sell = .75,

    model = "models/corporate_takeover/nostras/safe.mdl",
    modeloffset = 0,
    modelang = 0,

    health = 750,
})

Corporate_Takeover:addDesk("basic_worker_desk", {
    name = Corporate_Takeover:Lang("basic_worker_desk"),
    class = "worker_desk",
    max = 2,

    upkeepCost = 1.25,
    earningMultiplier = 1.25,

    buyable = true,
    level = 1,
    price = 2500, 
    sell = .75,

    model = "models/corporate_takeover/nostras/worker_desk.mdl",
    bodygroups = {
        [1] = 4,
        [2] = 4,
        [3] = 4,
    },
    modeloffset = 0,
    modelang = 90,

    health = 100,
})

Corporate_Takeover:addDesk("intermediate_worker_desk", {
    name = Corporate_Takeover:Lang("intermediate_worker_desk"),
    class = "worker_desk",
    max = 1,

    upkeepCost = 2.0,
    earningMultiplier = 1.5,

    buyable = true,
    level = 3,
    price = 7500,
    sell = .75,

    model = "models/corporate_takeover/nostras/worker_desk.mdl",
    bodygroups = {
        [1] = 4,
        [2] = 4,
        [3] = 4,
    },
    modeloffset = 0,
    modelang = 90,

    health = 150,
})

Corporate_Takeover:addDesk("advanced_worker_desk", {
    name = Corporate_Takeover:Lang("advanced_worker_desk"),
    class = "worker_desk",
    max = 1,

    upkeepCost = 3.0,

    earningMultiplier = 1.75,

    buyable = true,
    level = 7,
    price = 15000,
    sell = .75,

    model = "models/corporate_takeover/nostras/worker_desk.mdl",
    bodygroups = {
        [1] = 4,
        [2] = 4,
        [3] = 4,
    },
    modeloffset = 0,
    modelang = 90,

    health = 250,
})

Corporate_Takeover:addDesk("ultimate_worker_desk", {
    name = Corporate_Takeover:Lang("ultimate_worker_desk"),
    class = "worker_desk",
    max = 1,

    upkeepCost = 6.0,

    earningMultiplier = 2.0,

    buyable = true,
    level = 15,
    price = 40000,
    sell = .75,

    model = "models/corporate_takeover/nostras/worker_desk.mdl",
    bodygroups = {
        [1] = 4,
        [2] = 4,
        [3] = 4,
    },
    modeloffset = 0,
    modelang = 90,

    health = 350,
})

Corporate_Takeover:addDesk("secretary_desk", {
    name = Corporate_Takeover:Lang("secretary_desk"),
    class = "secretary_desk",
    max = 1,

    upkeepCost = 2,

    buyable = true,
    level = 8,
    price = 15000,
    sell = .75,

    model = "models/corporate_takeover/nostras/worker_desk.mdl",
    bodygroups = {
        [1] = 4,
        [2] = 4,
        [3] = 4,
    },
    skin = 2,
    modeloffset = 0,
    modelang = 90,

    health = 250,
})

Corporate_Takeover:addDesk("research_desk", {
    name = Corporate_Takeover:Lang("research_desk"),
    class = "research_desk",
    max = 1,

    upkeepCost = 1,

    buyable = true,
    level = 5,
    price = 12500,
    sell = .75,

    model = "models/corporate_takeover/nostras/worker_desk.mdl",
    bodygroups = {
        [1] = 4,
        [2] = 4,
        [3] = 4,
    },
    skin = 1,
    modeloffset = 0,
    modelang = 90,

    health = 250,
})

/*
    This is a demo research to show you, how it works. It will NOT get loaded.
*/

Corporate_Takeover:addResearchOption("demo", {
    name = "", -- can be overwritten
    description = "", -- can be overwritten
    class = "", -- can be overwritten, but really shouldn't!

    needed = {}, -- what researches are needed to research this (Classnames => demo for this one)

    icon = "icon", -- relative to "materials/corporate_takeover/<icon>.png"

    level = 5, -- minimum corporate level to buy this research
    price = 5000, -- price to buy this research
    restriction = "admin", -- Groups set in the config ["admin" or "donator"]

    time = 60, -- how long it takes to research (in seconds)

    -- Optinal: A callback function that gets called when the research is finished.
    onFinish = function(Corp, CorpID, class, ent)
        
    end
})
/*
    Demo ends
*/

//
// Research desk researches
//

Corporate_Takeover:addResearchOption("research_efficiency", {
    needed = {},
    icon = "cto_clock",
    level = 5,
    price = 10000,
    time = 180,
})

Corporate_Takeover:addResearchOption("research_price_drop", {
    needed = {},
    icon = "cto_money",
    level = 5,
    price = 10000,
    time = 180,
})

//
// XP Researches
//

Corporate_Takeover:addResearchOption("xp_worker_1", {
    needed = {},
    icon = "xp_worker_1",
    level = 5,
    price = 5000,
    time = 120,
})

Corporate_Takeover:addResearchOption("xp_worker_2", {
    needed = {"xp_worker_1"},
    icon = "xp_worker_2",
    level = 8,
    price = 10000,
    time = 120,
})

Corporate_Takeover:addResearchOption("xp_corp_1", {
    needed = {},
    icon = "cto_xp",
    level = 6,
    price = 5000,
    time = 120,
})

Corporate_Takeover:addResearchOption("xp_corp_2", {
    needed = {"xp_corp_1"},
    icon = "cto_xp_2",
    level = 7,
    price = 10000,
    time = 120,
})

//
// Worker Researches
//

Corporate_Takeover:addResearchOption("research_wage_1", {
    needed = {},
    icon = "wage_1",
    level = 5,
    price = 5000,
    time = 60,
})

Corporate_Takeover:addResearchOption("research_wage_2", {
    needed = {"research_wage_1"},
    icon = "wage_2",
    level = 9,
    price = 10000,
    time = 120,
})

Corporate_Takeover:addResearchOption("research_wage_3", {
    needed = {"research_wage_2"},
    icon = "wage_3",
    level = 15,
    price = 15000,
    time = 180,
})

//
// Secretary Researches
//

Corporate_Takeover:addResearchOption("automatic_coffee_self", {
    needed = {"automatic_coffee"},
    icon = "xp_worker_2",
    level = 20,
    price = 50000,
    time = 600,
})

Corporate_Takeover:addResearchOption("automatic_coffee", {
    icon = "xp_worker_1",
    level = 12,
    price = 25000,
    time = 300,
})

Corporate_Takeover:addResearchOption("wakeup_employees_research", {
    icon = "wakeup",
    level = 8,
    price = 12500,
    time = 180,
})
