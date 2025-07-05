/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if not CLIENT then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

hook.Add("AddToolMenuCategories", "zpiz_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "zpiz_options", "PizzaMaker")
end)

hook.Add("PopulateToolMenu", "zpiz_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "zpiz_options", "zpiz_Admin_Settings", "Admin Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("Public Setup", nil, Color(179, 135, 84, 255), zclib.colors["ui02"], CPanel, {
			[1] = {
				name = "Save",
				class = "DButton",
				cmd = "zpiz_save"
			},
			[2] = {
				name = "Remove",
				class = "DButton",
				cmd = "zpiz_remove"
			}
		})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

		zclib.Settings.OptionPanel("Pizza", nil, Color(179, 135, 84, 255), zclib.colors["ui02"], CPanel, {
			[1] = {
				name = "Spawn All",
				class = "DButton",
				cmd = "zpiz_pizza_all"
			},
		})
	end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599

end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47
