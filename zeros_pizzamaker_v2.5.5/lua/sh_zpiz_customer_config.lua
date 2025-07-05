/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

zpiz = zpiz or {}
zpiz.config = zpiz.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

zpiz.config.Customer = {
    // How much does the player gets payed if he delivers a burned pizza
    BurnedPizzaPenalty = 0.2, //20%
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599

    // The Interval at which new customers get spawned
    RespawnRate = 2,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47

    // How many Customers can one Player have at once
    Limit = 3,

    // Time in seconds we add to the bake time of the pizza for the Customer do wait.
    ExtraWaitTime = 150
}

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

// Customers
///////////////////////
// Some Data for our customers
zpiz.config.Customers = {
    [1] = {
        Model = "models/Humans/Group01/male_07.mdl", // The Customer Model
        SitAnim = {"silo_sit"}, // The Customer Sit Animations
        ServAnim = {"cheer1", "cheer2"} // The Customer gets Pizza Animations
    },
    [2] = {
        Model = "models/Humans/Group01/male_08.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "cheer2"}
    },
    [3] = {
        Model = "models/Humans/Group01/male_09.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"cheer1", "cheer2"}
    },
    [4] = {
        Model = "models/Humans/Group01/Female_01.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "heal"}
    },
    [5] = {
        Model = "models/Humans/Group01/Female_02.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "heal"}
    },
    [6] = {
        Model = "models/Humans/Group01/Female_03.mdl",
        SitAnim = {"sitchair1", "silo_sit"},
        ServAnim = {"cheer1", "heal"}
    },
    [7] = {
        Model = "models/Humans/Group01/Male_01.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"cheer1", "cheer2"}
    },
    [8] = {
        Model = "models/alyx.mdl",
        SitAnim = {"d1_t03_sit_bed"},
        ServAnim = {"cheer1", "heal"}
    },
    [9] = {
        Model = "models/gman_high.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"tiefidget", "lintpick"}
    },
    [10] = {
        Model = "models/Kleiner.mdl",
        SitAnim = {"silo_sit"},
        ServAnim = {"heal"}
    }
}
