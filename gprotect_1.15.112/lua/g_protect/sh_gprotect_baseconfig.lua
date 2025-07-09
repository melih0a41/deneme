------------------------------------------------------                                   
-- NO NOT TOUCH ANYTHING IN HERE!!!!!!!!!                                                  
------------------------------------------------------                  
                  
gProtect = gProtect or {}                        
gProtect.config = gProtect.config or {}
gProtect.config.modules = gProtect.config.modules or {}

gProtect.config.modules.general = {
	["blacklist"] = {                   
		["prop_physics"] = true,
		["prop_physics_multiplayer"] = true
	},
	["remDiscPlyEnt"] = 120,
	["remDiscPlyEntSpecific"] = {},
	["remOutOfBounds"] = 120,
	["remOutOfBoundsWhitelist"] = {},
	["protectedFrozenEnts"] = {
		["prop_physics"] = true,
		["prop_physics_multiplayer"] = true
	},
	["protectedFrozenGroup"] = COLLISION_GROUP_INTERACTIVE_DEBRIS
}

gProtect.config.modules.ghosting = {
	["enabled"] = true,
	["ghostColor"] = Color(66, 135, 40, 120),
	["antiObscuring"] = {["player"] = true},
	["obscureOffset"] = 10,
	["entities"] = {},
	["onPhysgun"] = true,
	["forceUnfrozen"] = false,
	["forceUnfrozenEntities"] = {["prop_physics"] = true},
	["useBlacklist"] = true,
	["enableMotion"] = false,
}

gProtect.config.modules.damage = {
	["enabled"] = true,
	["useBlacklist"] = true,
	["vehiclePlayerDamage"] = false,
	["blacklistedEntPlayerDamage"] = true,
	["worldPlayerDamage"] = true,
	["entities"] = {},
	["immortalEntities"] = {},
	["bypassGroups"] = {},
	["canDamageWorldEntities"] = {["*"] = true}
}

gProtect.config.modules.anticollide = {
	["enabled"] = true,
	["notifyStaff"] = true,
	["protectDarkRPEntities"] = 1,
	["DRPentitiesThreshold"] = 125,
	["DRPentitiesException"] = 1,
	["protectSpawnedEntities"] = 1,
	["entitiesThreshold"] = 75,
	["entitiesException"] = 1,
	["protectSpawnedProps"] = 3,
	["propsThreshold"] = 45,
	["propsException"] = 1,
	["playerPropAction"] = 4,
	["playerPropThreshold"] = 500,
	["specificEntities"] = {},
}

gProtect.config.modules.spamprotection = {
	["enabled"] = true,
	["threshold"] = 3,
	["delay"] = 1,
	["action"] = 1,
	["notifyStaff"] = true,
	["protectProps"] = true,
	["protectEntities"] = true
}

gProtect.config.modules.spawnrestriction = {
	["enabled"] = true,

	["propSpawnPermission"] = {["*"] = true},
	["SENTSpawnPermission"] = {["owner"] = true, ["superadmin"] = true},
	["SWEPSpawnPermission"] = {["owner"] = true, ["superadmin"] = true},
	["vehicleSpawnPermission"] = {["owner"] = true, ["superadmin"] = true},
	["NPCSpawnPermission"] = {["owner"] = true, ["superadmin"] = true},
	["ragdollSpawnPermission"] = {["owner"] = true, ["superadmin"] = true},
	["effectSpawnPermission"] = {["owner"] = true, ["superadmin"] = true},
	["blockedEntities"] = {},
	["blockedModels"] = {},
	["blockedModelsisBlacklist"] = true,
	["blockedModelsVehicleBypass"] = true,
	["blockedEntitiesIsBlacklist"] = true,
	["bypassGroups"] = {["owner"] = true, ["superadmin"] = true},
	["maxPropModelComplexity"] = 10,
	["maxModelSize"] = 3000
}

gProtect.config.modules.toolgunsettings = {
	["enabled"] = true,            
	["targetWorld"] = {},
	["targetPlayerOwned"] =  {},     
	["targetPlayerOwnedProps"] = {},
	["targetVehiclePermission"] = {["superadmin"] = true},
	["restrictTools"] = {["rope"] = true},
	["groupToolRestrictions"] = {             
		["superadmin"] = {
			isBlacklist = true,
			list = {}
		}
	},
	["bypassGroups"] = {["owner"] = true, ["superadmin"] = true},
	["entityTargetability"] = {
		isBlacklist = true,
		list = {["sammyservers_textscreen"] = true, ["player"] = true},
	},
	["bypassTargetabilityTools"] = {["remover"] = true},
	["bypassTargetabilityGroups"] = {["owner"] = true, ["superadmin"] = true},
	["antiSpam"] = {}
}

gProtect.config.modules.physgunsettings = {                    
	["enabled"] = true,
	["targetWorld"] = {},
	["targetPlayerOwned"] = {},
	["targetPlayerOwnedProps"] = {},
	["targetPlayerOwnedPropsGroupLevel"] = {},
	["DisableReloadUnfreeze"] = true,          
	["PickupVehiclePermission"] = {["superadmin"] = true},
	["StopMotionOnDrop"] = true,
	["blockMultiplePhysgunning"] = true,
	["maxDropObstructs"] = 3,               
	["maxDropObstructsAction"] = 1,
	["preventPropClimbing"] = true,
	["preventPropClimbingThreshold"] = 5,
	["preventPropClimbingAction"] = 1,
	["blockedEntities"] = {},
	["bypassGroups"] = {}
}

gProtect.config.modules.gravitygunsettings = {                   
	["enabled"] = true,
	["targetWorld"] = {["*"] = true},
	["targetPlayerOwned"] = {["*"] = true},
	["targetPlayerOwnedProps"] = {["*"] = true},
	["DisableGravityGunPunting"] = true,
	["blockedEntities"] = {},
	["bypassGroups"] = {}
}

gProtect.config.modules.canpropertysettings = {
	["enabled"] = true,
	["targetWorld"] = {},
	["targetPlayerOwned"] = {},
	["targetPlayerOwnedProps"] = {},
	["blockedProperties"] = {},
	["blockedPropertiesisBlacklist"] = true,
	["blockedEntities"] = {},
	["bypassGroups"] = {["owner"] = true, ["superadmin"] = true}
}

gProtect.config.modules.canusesettings = {
	["enabled"] = true,
	["targetWorld"] = {["*"] = true},
	["targetPlayerOwned"] = {["*"] = true},
	["targetPlayerOwnedProps"] = {["*"] = true},
	["blockedEntities"] = {},
	["blockedEntitiesisBlacklist"] = true,
	["bypassGroups"] = {["owner"] = true, ["superadmin"] = true}
}

gProtect.config.modules.advdupe2 = {
	["enabled"] = true,
	["notifyStaff"] = true,
	["PreventRopes"] = 1,
	["PreventScaling"] = 1,
	["PreventNoGravity"] = 1,
	["PreventTrail"] = 1,
	["PreventUnreasonableValues"] = true,
	["PreventUnfreezeAll"] = true,
 	["BlacklistedCollisionGroups"] = {[COLLISION_GROUP_IN_VEHICLE] = true, [COLLISION_GROUP_PROJECTILE] = true},
	["WhitelistedConstraints"] = {
		["weld"] = true
	},
	["whitelistedClasses"] = {["gmod_button"] = true},
	["DelayBetweenUse"] = 2
}

gProtect.config.modules.miscs = {
	["enabled"] = true,
	["ClearDecals"] = 120,
	["blacklistedFadingDoorMats_punishment"] = 1,
	["blacklistedFadingDoorMats"] = {["pp/copy"] = true, ["dev/upscale"] = true},
	["FadingDoorLag"] = true,
	["DisableMotion"] = false,
	["DisableMotionEntities"] = {["prop_physics"] = true},
	["freezeOnSpawn"] = true,
	["preventFadingDoorAbuse"] = true,
	["precisionMoveFix"] = true,
	["preventSpawnNearbyPlayer"] = 10,
	["DRPEntForceOwnership"] = {},
	["DRPMaxObstructsOnPurchaseEnts"] = 3,
	["DRPObstructsFilter"] = 1
}

------------------------------------------------------           
-- NO NOT TOUCH ANYTHING IN HERE!!!!!!!!!                                                  
------------------------------------------------------76561198307194389