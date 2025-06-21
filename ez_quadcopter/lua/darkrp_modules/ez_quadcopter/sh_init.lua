-- Categorie
DarkRP.createCategory {
    name = "Drone",
    categorises = "entities",
    startExpanded = true,
    color = Color(200, 0, 0, 255),
    canSee = function(ply)
		return table.HasValue({
			TEAM_HAYDUTIHA, TEAM_DRONEPOLIS
		}, ply:Team()) 
	end, 
    sortOrder = 90,
}

-- Items
DarkRP.createEntity("DJI Quadcopter", {
    ent = "ez_quadcopter_dji",
    cmd = "buyezquadcopterdji",
    model = "models/easzy/ez_quadcopter/dji_quadcopter/w_dji_quadcopter.mdl",
    price = 10000,
    max = 1,
    category = "Drone",
	canSee = function(ply)
		return table.HasValue({
			TEAM_HAYDUTIHA, TEAM_DRONEPOLIS
		}, ply:Team()) 
	end, 
})

DarkRP.createEntity("FPV Quadcopter", {
    ent = "ez_quadcopter_fpv",
    cmd = "buyezquadcopterfpv",
    model = "models/easzy/ez_quadcopter/fpv_quadcopter/w_fpv_quadcopter.mdl",
    price = 20000,
    max = 1,
    category = "Drone",
	canSee = function(ply)
		return table.HasValue({
			TEAM_HAYDUTIHA, TEAM_DRONEPOLIS
		}, ply:Team()) 
	end, 
})

--[[DarkRP.createEntity("Bomb", {
    ent = "ez_quadcopter_bomb",
    cmd = "buyezquadcopterbomb",
    model = "models/easzy/ez_quadcopter/bomb/w_bomb.mdl",
    price = 150,
    max = 10,
    category = "Drone",
})
--]]

DarkRP.createEntity("DJI Battery", {
    ent = "ez_quadcopter_battery",
    cmd = "buyezquadcopterdjibattery",
    model = "models/easzy/ez_quadcopter/battery/w_battery.mdl",
    price = 4000,
    max = 1,
    category = "Drone",
	canSee = function(ply)
		return table.HasValue({
			TEAM_HAYDUTIHA, TEAM_DRONEPOLIS
		}, ply:Team()) 
	end, 
})

DarkRP.createEntity("FPV Battery", {
    ent = "ez_quadcopter_fpv_battery",
    cmd = "buyezquadcopterfpvbattery",
    model = "models/easzy/ez_quadcopter/fpv_battery/w_fpv_battery.mdl",
    price = 2000,
    max = 1,
    category = "Drone",
	canSee = function(ply)
		return table.HasValue({
			TEAM_HAYDUTIHA, TEAM_DRONEPOLIS
		}, ply:Team()) 
	end, 
})

-- Can't drop radio controllers
GM.Config.DisallowDrop["ez_quadcopter_dji_radio_controller"] = true
GM.Config.DisallowDrop["ez_quadcopter_fpv_radio_controller"] = true


