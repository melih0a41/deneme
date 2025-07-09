/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.config = zmlab2.config or {}
zmlab2.config.Storage = zmlab2.config.Storage or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

// Here are all the entities which can be bought from the storage
zmlab2.config.Storage.Shop = {
	[1] = {
		name = zmlab2.language["acid_title"],
		desc = zmlab2.language["acid_desc"],
		class = "zmlab2_item_acid",
		model = "models/zerochain/props_methlab/zmlab2_acid.mdl",
		price = 10,
		// Defines how many items of that class the player can spawn
		limit = 5,

		// Which rank is allowed to buy this?
		/*
		rank = {
			["vip"] = true,
		},
		*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

		// Which job is allowed to buy this?
		/*
		job = {
			[TEAM_ZMLAB2_COOK] = true
		},
		*/

		// You can use this to restrict this for any other reason
		/*
		customcheck = function(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

		end,
		*/
	},
	[2] = {
		name = zmlab2.language["methylamine_title"],
		desc = zmlab2.language["methylamine_desc"],
		class = "zmlab2_item_methylamine",
		model = "models/zerochain/props_methlab/zmlab2_methylamine.mdl",
		price = 10,
		limit = 3
	},
	[3] = {
		name = zmlab2.language["aluminum_title"],
		desc = zmlab2.language["aluminum_desc"],
		class = "zmlab2_item_aluminium",
		model = "models/zerochain/props_methlab/zmlab2_aluminium.mdl",
		price = 10,
		limit = 10
	},
	[4] = {
		name = zmlab2.language["lox_title"],
		desc = zmlab2.language["lox_desc"],
		class = "zmlab2_item_lox",
		model = "models/zerochain/props_methlab/zmlab2_lox.mdl",
		price = 10,
		limit = 3
	},
	[5] = {
		name = zmlab2.language["crate_title"],
		desc = zmlab2.language["crate_desc"],
		class = "zmlab2_item_crate",
		model = "models/zerochain/props_methlab/zmlab2_crate.mdl",
		price = 10,
		limit = 5
	},
	[6] = {
		name = zmlab2.language["palette_title"],
		desc = zmlab2.language["palette_desc"],
		class = "zmlab2_item_palette",
		model = "models/zerochain/props_methlab/zmlab2_palette.mdl",
		price = 10,
		limit = 1
	},
	[7] = {
		name = zmlab2.language["crusher_title"],
		desc = zmlab2.language["crusher_desc"],
		class = "zmlab2_item_autobreaker",
		model = "models/zerochain/props_methlab/zmlab2_autobreaker.mdl",
		price = 10000,
		limit = 1,
		/*
		rank = {
			["vip"] = true,
		},
		*/
	}
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6
