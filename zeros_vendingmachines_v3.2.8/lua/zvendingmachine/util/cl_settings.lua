/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if SERVER then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

hook.Add("AddToolMenuCategories", "zvm_CreateCategories", function()
    spawnmenu.AddToolCategory("Options", "zvm_options", "Vendingmachine")
end)

hook.Add("PopulateToolMenu", "zvm_PopulateMenus", function()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

    spawnmenu.AddToolMenuOption("Options", "zvm_options", "zvm_Admin_Settings", "Admin Settings", "", "", function(CPanel)
        zclib.Settings.OptionPanel("Vendingmachine", nil, Color(82, 131, 198, 255), zclib.colors["ui02"], CPanel, {
            [1] = {
                name = "Save",
                //desc = "Saves any public vendingmachine on the map.",
                class = "DButton",
                cmd = "zvm_save_vendingmachines"
            },
            [2] = {
                name = "Remove",
                //desc = "Removes any public vendingmachine on the map.",
                class = "DButton",
                cmd = "zvm_remove_vendingmachines"
            },
            [3] = {
                name = "Rebuild",
                //desc = "Rebuilds any public vendingmachine on the map.",
                class = "DButton",
                cmd = "zvm_load_vendingmachines"
            },
            [4] = {
                name = "Mirror",
                desc = "Copies the vendingmachine data you are looking at and applys it to any other vendingmachine on the map.",
                class = "DButton",
                cmd = "zvm_vendingmachine_mirror"
            },

        })
    end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
