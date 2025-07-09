/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.config = zmlab2.config or {}
zmlab2.config.MethTypes = {}
local function AddMeth(data) return table.insert(zmlab2.config.MethTypes,data) end

AddMeth({
	name = zmlab2.language["meth_title"],
	desc = zmlab2.language["meth_desc"],

	// The money value per gram if the quality is perfect (100%)
	price = 10,

	// Color of the meth
	color = Color(187, 230, 210, 255),
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	// The crystall model which gets used in the Filter Interface
	crystal_mdl = "models/zerochain/props_methlab/zmlab2_crystall02.mdl",

	// Can be used to overwrite the material
	material = {
		diff = "zerochain/props_methlab/meth/zmlab2_meth_type02_diff",
		nrm = "zerochain/props_methlab/meth/zmlab2_meth_type02_nrm",
	},

	// Defines how hard the minigame for this methtype is (1-10)
	// 1 = Easy , 10 = Expert
	difficulty = 3,

	// Defines how much meth this type produces
	batch_size = 2500,

	// How many Methylamin Barrels and Aluminium are needed
	recipe_barrel = 1,
	recipe_alu = 2,


	// How long is one mix cycle in the mixer machine for this meth type (seconds)
	mix_time = 30,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

	// How long does it take to vent this meth type in the mixer machine (seconds)
	vent_time = 30,

	// How long does the Filter Machine need to compose / produce the meth (seconds)
	filter_time = 30,

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

	// Can be used to call some custom code when the player consums this type of meth (Gets called once per "E - Press" on a meth bag)
	OnConsumption = function(ply,meth_type,meth_quality)

		/*
			//Here are some modificators you can use (All of them are the Max Value and if applied will scale themself depending on Meth Quality)

			// A movement speed multiplier
			ply.zmlab2_Effect_Speed = 2

			// A damage multiplier for any damage inflicted on the player

			//Same damage multiplier can be used as a table instead to only modify certain damage types
			ply.zmlab2_Effect_DMG = {
				[DMG_FALL] = 0
			}
		*/

		ply.zmlab2_Effect_Speed = 1.5
	end,

	// Called once the effect has ended or before another effect replaced this effect
	OnEffectEnd = function(ply) end,

	// Some values for the screeneffect
	visuals = {
		// The music to play while high (audio file needs loop points in order to loop)
		//music = "path/to/file.wav",

		// The particle effect which gets created when the player is high
		effect = "zmlab2_high_effect01",

		MaterialOverlay = "effects/tp_eyefx/tpeye3",
		MotionBlur = true,
		Bloom = true,

		// Particle effects which get created when the meth gets moved/ made
		effect_breaking = "zmlab2_meth_breaking",
		effect_filling = "zmlab2_meth_filling",
		effect_exploding = "zmlab2_meth_explo",
		effect_mixer_liquid = "zmlab2_mixer_liquid",
		effect_mixer_exhaust = "zmlab2_mixer_exhaust",
	},

	// Which rank is allowed to make this methtype?
	/*
	rank = {
		["user"] = true,
		["bronzvip"] = true,
		["silvervip"] = true,
		["goldvip"] = true,
		["diamondvip"] = true,
		["platinumvip"] = true,
		["rehber"] = true,
		["viprehber"] = true,
		["moderator"] = true,
		["moderator+"] = true,
		["admin"] = true,
		["admin+"] = true,
		["basadmin"] = true,
		["superadmin"] = true,
	},
	*/

	// Which job is allowed to make this methtype?
	/*
	job = {
		[TEAM_ZMLAB2_COOK] = true
	},
	*/

	// You can use this to restrict this methtype for any other reason
	/*
	customcheck = function(ply)
		if ply:Nick() ~= "Walter White" then return false end
	end,
	*/
})

AddMeth({
	name = zmlab2.language["bluemeth_title"],
	desc = zmlab2.language["bluemeth_desc"],
	price = 15,
	color = Color(40, 201, 230, 255),
	crystal_mdl = "models/zerochain/props_methlab/zmlab2_crystall02.mdl",
	material = {
		diff = "zerochain/props_methlab/meth/zmlab2_meth_type02_diff",
		nrm = "zerochain/props_methlab/meth/zmlab2_meth_type02_nrm",
	},
	difficulty = 4,
	batch_size = 2500,
	recipe_barrel = 2,
	recipe_alu = 1,
	mix_time = 40,
	vent_time = 40,
	filter_time = 40,
	OnConsumption = function(ply,meth_type,meth_quality)
		ply.zmlab2_Effect_Speed = 3
	end,
	visuals = {
		music = "zmlab2/meth_music_blue.wav",
		effect = "zmlab2_high_effect01",
		MaterialOverlay = "effects/tp_eyefx/tpeye3",
		MotionBlur = true,
		Bloom = true,
		effect_breaking = "zmlab2_meth_breaking_blue",
		effect_filling = "zmlab2_meth_filling_blue",
		effect_exploding = "zmlab2_meth_explo_blue",
		effect_mixer_liquid = "zmlab2_mixer_liquid_blue",
		effect_mixer_exhaust = "zmlab2_mixer_exhaust_blue",
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

AddMeth({
	name = zmlab2.language["kalaxi_title"],
	desc = zmlab2.language["kalaxi_desc"],
	price = 20,
	color = Color(230, 12, 104, 255),
	crystal_mdl = "models/zerochain/props_methlab/zmlab2_crystall03.mdl",
	difficulty = 5,
	batch_size = 2500,
	recipe_barrel = 2,
	recipe_alu = 2,
	mix_time = 45,
	vent_time = 45,
	filter_time = 45,
	OnConsumption = function(ply,meth_type,meth_quality)
		ply.zmlab2_Effect_Speed = 3

		ply:SetJumpPower( 200 + ((300 / 100) * meth_quality) )
	end,
	OnEffectEnd = function(ply)
		ply:SetJumpPower( 200 )
	end,
	visuals = {
		music = "zmlab2/meth_music_kalaxian.wav",
		effect = "zmlab2_high_effect02",
		MaterialOverlay = "effects/tp_eyefx/tpeye3",
		MotionBlur = true,
		Bloom = true,
		effect_breaking = "zmlab2_meth_breaking_pink",
		effect_filling = "zmlab2_meth_filling_pink",
		effect_exploding = "zmlab2_meth_explo_pink",
		effect_mixer_liquid = "zmlab2_mixer_liquid_pink",
		effect_mixer_exhaust = "zmlab2_mixer_exhaust_pink",
	}
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

AddMeth({
	name = zmlab2.language["glitter_title"],
	desc = zmlab2.language["glitter_desc"],
	price = 25,
	color = Color(230, 168, 18, 255),
	crystal_mdl = "models/zerochain/props_methlab/zmlab2_crystall01.mdl",
	material = {
		diff = "zerochain/props_methlab/meth/zmlab2_meth_type03_diff",
		nrm = "zerochain/props_methlab/meth/zmlab2_meth_type03_nrm",
	},
	difficulty = 7,
	batch_size = 5000,
	recipe_barrel = 1,
	recipe_alu = 5,
	mix_time = 50,
	vent_time = 50,
	filter_time = 50,
	OnConsumption = function(ply,meth_type,meth_quality)
		ply.zmlab2_Effect_DMG = {
			[DMG_FALL] = 0
		}
		ply.zmlab2_Effect_Speed = 3
	end,
	visuals = {
		music = "zmlab2/meth_music_glitter.wav",
		effect = "zmlab2_high_effect03",
		MaterialOverlay = "effects/tp_eyefx/tpeye3",
		MotionBlur = true,
		Bloom = true,
		effect_breaking = "zmlab2_meth_breaking_yellow",
		effect_filling = "zmlab2_meth_filling_yellow",
		effect_exploding = "zmlab2_meth_explo_yellow",
		effect_mixer_liquid = "zmlab2_mixer_liquid_yellow",
		effect_mixer_exhaust = "zmlab2_mixer_exhaust_yellow",
	}
})

AddMeth({
	name = zmlab2.language["kronole_title"],
	desc = zmlab2.language["kronole_desc"],
	price = 30,
	color = Color(89, 106, 136, 255),
	crystal_mdl = "models/zerochain/props_methlab/zmlab2_crystall01.mdl",
	material = {
		diff = "zerochain/props_methlab/meth/zmlab2_meth_type01_diff",
		nrm = "zerochain/props_methlab/meth/zmlab2_meth_type01_nrm",
	},
	difficulty = 8,
	batch_size = 2500,
	recipe_barrel = 1,
	recipe_alu = 1,
	mix_time = 55,
	vent_time = 55,
	filter_time = 55,
	OnConsumption = function(ply,meth_type,meth_quality)
		ply.zmlab2_Effect_Speed = 1.1
	end,
	visuals = {
		music = "zmlab2/meth_music_kronole.wav",
		effect = "zmlab2_high_effect04",
		MaterialOverlay = "effects/tp_eyefx/tpeye3",
		MotionBlur = true,
		Bloom = true,
		effect_breaking = "zmlab2_meth_breaking_darkblue",
		effect_filling = "zmlab2_meth_filling_darkblue",
		effect_exploding = "zmlab2_meth_explo_darkblue",
		effect_mixer_liquid = "zmlab2_mixer_liquid_blue",
		effect_mixer_exhaust = "zmlab2_mixer_exhaust_blue",
	},
})

AddMeth({
	name = zmlab2.language["melange_title"],
	desc = zmlab2.language["melange_desc"],
	price = 35,
	color = Color(157, 78, 78, 255),
	crystal_mdl = "models/zerochain/props_methlab/zmlab2_crystall04.mdl",
	difficulty = 9,
	batch_size = 2500,
	recipe_barrel = 2,
	recipe_alu = 2,
	mix_time = 60,
	vent_time = 60,
	filter_time = 60,
	OnConsumption = function(ply,meth_type,meth_quality)
		ply.zmlab2_Effect_Speed = 2
	end,
	/*
	rank = {
		["user"] = true,
		["vip"] = true,
		["rehber"] = true,
		["viprehber"] = true,
		["moderator"] = true,
		["moderator+"] = true,
		["admin"] = true,
		["admin+"] = true,
		["basadmin"] = true,
		["superadmin"] = true,
	},
	*/
	visuals = {
		music = "zmlab2/meth_music_spice.wav",
		effect = "zmlab2_high_effect05",
		MaterialOverlay = "effects/tp_eyefx/tpeye3",
		MotionBlur = true,
		Bloom = true,
		effect_breaking = "zmlab2_meth_breaking_brown",
		effect_filling = "zmlab2_meth_filling_brown",
		effect_exploding = "zmlab2_meth_explo_brown",
		effect_mixer_liquid = "zmlab2_mixer_liquid_brown",
		effect_mixer_exhaust = "zmlab2_mixer_exhaust_brown",
	},
})

AddMeth({
	name = zmlab2.language["mdma_title"],
	desc = zmlab2.language["mdma_desc"],
	price = 40,
	color = Color(239, 57, 106, 255),
	crystal_mdl = "models/zerochain/props_methlab/zmlab2_crystall01.mdl",
	difficulty = 10,
	batch_size = 2500,
	recipe_barrel = 1,
	recipe_alu = 5,
	mix_time = 65,
	vent_time = 65,
	filter_time = 65,
	OnConsumption = function(ply,meth_type,meth_quality)
		ply.zmlab2_Effect_Speed = 2
	end,
	visuals = {
		music = "zmlab2/meth_music_mdma.wav",
		effect = "zmlab2_high_effect04",
		MaterialOverlay = "effects/tp_eyefx/tpeye3",
		MotionBlur = true,
		Bloom = true,
		effect_breaking = "zmlab2_meth_breaking_pink",
		effect_filling = "zmlab2_meth_filling_pink",
		effect_exploding = "zmlab2_meth_explo_pink",
		effect_mixer_liquid = "zmlab2_mixer_liquid_pink",
		effect_mixer_exhaust = "zmlab2_mixer_exhaust_pink",
	},
})
