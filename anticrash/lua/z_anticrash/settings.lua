-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

// SETTINGS
SH_ANTICRASH.SETTINGS = {}

// ADMINS
SH_ANTICRASH.SETTINGS.ADMINS = { -- Ranks that have access to the menu and its commands
	["superadmin"] = {"stats","users","global"}, -- Rank needs to be lowercase!
	["admin"] = {"stats","users","global"}, -- ["rank name"] = { permissions },
	["moderator"] = {"stats","users"},
}

// VARIOUS
SH_ANTICRASH.SETTINGS.SYSTEMLANG = "EN" -- The language of server console messages (this is automatically detected for players)

SH_ANTICRASH.SETTINGS.REMHIGHCOLENTITIES = true -- Automatically remove entities that have dangerous collision counts
SH_ANTICRASH.SETTINGS.COLLISIONINTENSITY = 15 -- Amount of collisions within 0.5 seconds before the entity is considered dangerous
SH_ANTICRASH.SETTINGS.HIGHCOLENTBLACKLIST = { -- Entities that will not be removed when exceeding collision intensity
	["example_classname"] = true, -- Entity class name
}

SH_ANTICRASH.SETTINGS.NOCOLLISIONSAMEOWNER = true -- Disable collisions only between entities owned by the same player
SH_ANTICRASH.SETTINGS.NOCOLLISIONENTITIES = { -- Entities that will never collide with each other
	["prop_vehicle_jeep"] = true,
	["prop_vehicle_airboat"] = true,
}

SH_ANTICRASH.SETTINGS.BLOCKEDENTITIES = { -- Entities that can't be created by any means
	["sent_ball"] = true, // Balls can be used to create instant lag, and give the player infinite HP
	["phys_magnet"] = true, // Magnets can bypass entity limit and can be used to seg fault crash the server
}

SH_ANTICRASH.SETTINGS.FIXNPCSEGMENTATIONCRASH = true -- Block faulty npcs from being spawn (can cause seg fault)
SH_ANTICRASH.SETTINGS.BLOCKROPESPAMMING = true -- Block ropes from being connected to the world
SH_ANTICRASH.SETTINGS.BLOCKSPAMMERS = true -- Block spammers by adding a small delay between spawning entities and toolgunning
SH_ANTICRASH.SETTINGS.BLOCKSPAMMERDELAY = 0.3 -- Delay in seconds between spawning entities and toolgunning

SH_ANTICRASH.SETTINGS.BLOCKINVALIDMODELS = true -- Block unprecached/error models
SH_ANTICRASH.SETTINGS.FREEZEOBJECTSONSPAWN = true -- Freeze objects when spawned
SH_ANTICRASH.SETTINGS.GHOSTOBJECTSONSPAWN = true -- Ghost objects when spawned
SH_ANTICRASH.SETTINGS.GHOSTOBJECTSONPICKUP = false -- Ghost objects when picked up

SH_ANTICRASH.SETTINGS.AUTOFREEZE = false -- Freeze all entities every X minutes
SH_ANTICRASH.SETTINGS.AUTOFREEZEDELAY = 10 -- Delay between freezes in minutes
SH_ANTICRASH.SETTINGS.FREEZEVEHICLES = false -- Should vehicles be frozen?
SH_ANTICRASH.SETTINGS.FREEZEALLDELAY = true -- Should unfreeze all be delayed for large contraptions?
SH_ANTICRASH.SETTINGS.FREEZEONDROP = false -- Should an entity be frozen when let go by the physgun?
SH_ANTICRASH.SETTINGS.FREEZEBLACKLIST = { -- Entities that should never be frozen by any means
	["example_classname"] = true, -- Entity class name
}
SH_ANTICRASH.SETTINGS.FREEZEBLACKLISTREG = {"example_"} -- Same as above but compares using the start of the class name

SH_ANTICRASH.SETTINGS.PHYSPERFMODE = true -- Reduces phys calculation impact on the server. (some mods like sligwolfs trains will break when this is enabled)
 
// Exploits
SH_ANTICRASH.SETTINGS.EXPLOITS = {}
SH_ANTICRASH.SETTINGS.EXPLOITS.CHATCLEAR = true -- Patch the chat clear exploit
SH_ANTICRASH.SETTINGS.EXPLOITS.CHATCLEARKICK = true -- Kick repeating offenders
SH_ANTICRASH.SETTINGS.EXPLOITS.CHATCLEARKICKAMOUNT = 5 -- Kick after X
SH_ANTICRASH.SETTINGS.EXPLOITS.NETRATELIMITER = true -- Enable netrate limiting

// Graph (menu)
SH_ANTICRASH.SETTINGS.GRAPH = {}
SH_ANTICRASH.SETTINGS.GRAPH.UPDATEDELAY = 0.5 -- Delay between graph updates in seconds (lower = less performant)
SH_ANTICRASH.SETTINGS.GRAPH.TIMEWINDOW = 60 -- Timewindow of the graph
SH_ANTICRASH.SETTINGS.GRAPH.ALWAYSUPDATE = true -- Update graph data even when the menu is closed (smoother, less performant)

SH_ANTICRASH.SETTINGS.GRAPH.SCALE = {}
SH_ANTICRASH.SETTINGS.GRAPH.SCALE.MAXPROPS = 1000 -- Estimate of props before the server start lagging (if value = -1 then "sbox_maxprops" x playercount is used)
SH_ANTICRASH.SETTINGS.GRAPH.SCALE.MAXNPCS = 150 -- Estimate of nps before the server starts lagging
SH_ANTICRASH.SETTINGS.GRAPH.SCALE.MAXVEHICLES = 100 -- Estimate of vehicles that are being driven before the server start lagging

// Auto Cleaner (client side)
SH_ANTICRASH.SETTINGS.CLEANER = {}
SH_ANTICRASH.SETTINGS.CLEANER.ENABLE = true
SH_ANTICRASH.SETTINGS.CLEANER.DELAY = 600 -- Delay in seconds between cleaning
SH_ANTICRASH.SETTINGS.CLEANER.CMDS = { -- Commands/Functions that the cleaner should run
	"r_cleardecals",
	"stopsound",
	game.RemoveRagdolls
}

// Lag Fix Measures
SH_ANTICRASH.SETTINGS.LAG = {}
SH_ANTICRASH.SETTINGS.LAG.Delay = 3 -- Amount of time in seconds before the lag should be fixed (higher number = less likable to recover)
SH_ANTICRASH.SETTINGS.LAG.CLEANMAP = false -- Reset the map completely (Entities,Decals,Gibs,Effects,NPC's,...)
SH_ANTICRASH.SETTINGS.LAG.REMOVEENTS = false -- Remove all player created entities
SH_ANTICRASH.SETTINGS.LAG.FREEZEENTS = true -- Freeze all player created entities
SH_ANTICRASH.SETTINGS.LAG.NOCOLLIDEENTS = true -- No Collide all ents created by the same player

SH_ANTICRASH.SETTINGS.LAG.REVERTCHANGES = true -- Remove all entities created X amount of minutes before the server lag
SH_ANTICRASH.SETTINGS.LAG.REVERTCHANGESTIME = 5 -- All entities placed in the last X amount of minutes will be removed

SH_ANTICRASH.SETTINGS.LAG.STUCK = 3 -- Amount of lag fixes before the lag is considered stuck
SH_ANTICRASH.SETTINGS.LAG.STUCKTIME = 120 -- Time window for the lag stuck in seconds
SH_ANTICRASH.SETTINGS.LAG.STUCKCLEANMAP = true -- Should the map be reset if the lag is stuck

SH_ANTICRASH.SETTINGS.CRASHOFFENDERTIMEWINDOW = 3 -- Time window in seconds to search for offenders before the anti-lag measures kick in

// Crazy Physics
SH_ANTICRASH.SETTINGS.CRAZYPHYSICS = {}
SH_ANTICRASH.SETTINGS.CRAZYPHYSICS.FREEZE = true -- Freeze entities with crazy physics
SH_ANTICRASH.SETTINGS.CRAZYPHYSICS.REMOVEAFTERFREEZE = true -- Remove entities that have been frozen before
SH_ANTICRASH.SETTINGS.CRAZYPHYSICS.REMOVEAFTERFREEZENUM = 1 -- After how many tries should the entity be removed?

// Out Of Bounds
SH_ANTICRASH.SETTINGS.OUTOFBOUNDS = {}
SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.REMOVE = true -- Remove out of bounds entities
SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.DELAY = 60 -- Delay in seconds to check for out of bounds entities
SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.BLACKLIST = { -- Entities that will not be removed when out of bounds
	["keyframe_rope"] = true,
	["player"] = true,
	["predicted_viewmodel"] = true,
	["physgun_beam"] = true,
	["gmod_hands"] = true,
	["manipulate_bone"] = true,
	["phys_constraintsystem"] = true,
	["prop_door_rotating"] = true,
	["phys_bone_follower"] = true,
	["logic_auto"] = true,
	["shadow_control"] = true,
	["trigger_teleport"] = true,
	["trigger_hurt"] = true,
	["player_manager"] = true,
	["scene_manager"] = true,
	["instanced_scripted_scene"] = true,
	["gmod_sw_wheel"] = true
}
SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.BLACKLISTREG = {"prop_","func_","env_","info_","phys_"} -- Same as above but compares using the start of the class name

// Workshop Dupes
SH_ANTICRASH.SETTINGS.DUPES = {}
SH_ANTICRASH.SETTINGS.DUPES.ENABLE = true -- Can players spawn workshop dupes?
SH_ANTICRASH.SETTINGS.DUPES.GHOST = false -- Ghost entities when spawned
SH_ANTICRASH.SETTINGS.DUPES.FREEZE = true -- Freeze all entities when spawned
SH_ANTICRASH.SETTINGS.DUPES.NOCOLLIDE = true -- No Collide all entities when spawned
SH_ANTICRASH.SETTINGS.DUPES.REPLACEINVALIDMODELS = true -- Prevents dupes with error models
SH_ANTICRASH.SETTINGS.DUPES.INVALIDMODELREPLACEMENT = "models/props_junk/PopCan01a.mdl" -- Replaces errors with this model if REPLACEINVALIDMODELS is enabled
SH_ANTICRASH.SETTINGS.DUPES.SIZELIMITPROPSONLY = false -- Should only props be included in the size limit? (e.g no thrusters, lamps, wheels, ...)
SH_ANTICRASH.SETTINGS.DUPES.SIZELIMIT = 50 -- Limit the amount of entities a dupe can have
SH_ANTICRASH.SETTINGS.DUPES.ROPELIMIT = 100 -- Limits the amount of ropes a dupe can have

// Advanced Duplicator
SH_ANTICRASH.SETTINGS.ADVDUPES = {}
SH_ANTICRASH.SETTINGS.ADVDUPES.ENABLE = true -- Can players spawn adv dupes?
SH_ANTICRASH.SETTINGS.ADVDUPES.GHOST = false -- Ghost entities when spawned
SH_ANTICRASH.SETTINGS.ADVDUPES.FREEZE = true -- Freeze all entities when spawned
SH_ANTICRASH.SETTINGS.ADVDUPES.NOCOLLIDE = true -- No Collide all entities when spawned
SH_ANTICRASH.SETTINGS.ADVDUPES.REPLACEINVALIDMODELS = true -- Prevents dupes with error models
SH_ANTICRASH.SETTINGS.ADVDUPES.INVALIDMODELREPLACEMENT = "models/props_junk/PopCan01a.mdl" -- Replaces errors with this model if REPLACEINVALIDMODELS is enabled
SH_ANTICRASH.SETTINGS.ADVDUPES.CONTRAPTIONSPAWNER = false -- Enable contraption spawner? (Can be used to easily crash a server)
SH_ANTICRASH.SETTINGS.ADVDUPES.SIZELIMITPROPSONLY = false -- Should only props be included in the size limit? (e.g no thrusters, lamps, wheels, ...)
SH_ANTICRASH.SETTINGS.ADVDUPES.SIZELIMIT = 50 -- Limit the amount of entities a dupe can have
SH_ANTICRASH.SETTINGS.ADVDUPES.ROPELIMIT = 100 -- Limits the amount of ropes a dupe can have

// DarkRP
SH_ANTICRASH.SETTINGS.DARKRP = {}
SH_ANTICRASH.SETTINGS.DARKRP.AFFECTF4ENTITIES = false -- Should entities spawned from the f4 menu be affected by the anti-crash?
SH_ANTICRASH.SETTINGS.DARKRP.F4SPAWNHOOKS = { -- The entities in these hooks will be affected
	"playerBoughtAmmo",
	"playerBoughtCustomEntity",
	"playerBoughtCustomVehicle",
	"playerBoughtDoor",
	"playerBoughtFood",
	"playerBoughtPistol",
	"playerBoughtShipment",
	"playerBoughtVehicle",
}