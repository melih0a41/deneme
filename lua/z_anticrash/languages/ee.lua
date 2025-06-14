-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local ee = {
	
	-- Stats
	lag = "LAG",
	collisions = "KOKKUPÕRKED",
	props = "REKVISIIDID",
	propsFrozen = "KÜLMUNUD REKVISIIDID",
	npcs = "NPCS",
	vehicles = "MASINAD",
	players = "MÄNGIJAD",
	uptime = "UPTIME",
	entities = "ÜKSUSED",
	spawned = "SPAWNED",
	fps = "FPS",
	tickrate = "TICKRATE",
	runAntiLagMeasures = "ALUSTA ANTI-LAG MEETMEID",
	
	-- Users
	search = "Otsi",
	constraints = "PIIRANGUD",
	showEntities = "Näita üksuseid",
	hideEntities = "Peida üksused",
	resetMap = "Lähtesta maailm",
	freezeEntities = "Külmuta üksused",
	removeEntities = "Eemalda üksused",
	
	-- Global
	noCollideEntities = "No-Collide üksused",
	
	-- Lag
	heavyLag = "Raske lag tuvastatud!",
	lagIsStuck = "Hoiatus: lag on kinni!",
	crashPrevented = "Serveri krahh ära hoitud!",
	cleaningMap = "+ Koristan maailma...",
	removingEnts = "+ Eemaldan %s üksust",
	revertChanges = "+ Eemaldan %s üksust loodud viimase %s minuti jooksul",
	freezeingEnts = "+ Külmutan %s üksust",
	noCollidingEnts = "+ No Colliding %s üksust",
	offenderWarning = "%s sisaldab kahtlase arvuga üksuseid (%s), mis võivad viia lagini!",
	freezingAllEntities = "Külmuta kõik üksused (%s)",
	
	-- Dupes
	dupesNotEnabled = "Dupes ei ole selles serveris lubatud!",
	advDupesNotEnabled = "Advanced Dupes ei ole selles serveris lubatud!",
	dupeExceedsSize = "See dupe ületab maksimaalse suuruse piirangut! (suurus:%s, max:%s)",
	dupeInformation = "%s spawning dupe, mis sisaldab %s üksust ja %s piirangut",
	
	-- Notifications
	triggeredAntiLagMeasures = "triggered anti-lag mõõtmeid!",
	ranAntilagMeasures = "alustas anti-lag mõõtmeid!",
	hasNoEntities = "üksuseid pole!",
	youRemovedFrom = "Eemaldasid %s üksust %s'st!",
	removedYourObjects = "eemaldas sinu spawnitud objektid!",
	youFrozeFrom = "Külmutasid %s üksust %s poolt!",
	frozeYourObjects = "külmutas sinu spawnitud objektid!",
	enabledSpawnAbility = "lubas sul objekte spawnida!",
	disabledSpawnAbility = "keelas sul objekte spawnida!",
	youEnabledSpawnAbility = "Lubasid %s'l objekte spawninda!",
	youDisabledSpawnAbility = "Keelasid %s'l objekte spawnida!",
	
	resetTheMap = "lähtesta maailm!",
	noEntNameFound = "%s ei leitud!",
	noEntitiesFound = "Ühtegi üksust ei leitud!",
	noUnfrozenEntsFound = "Ühtegi külmunud üksust ei leitud!",
	noUnCollidedEntsFound = "Ühtegi un-collided üksust ei leitud!",
	freezeAllEnts = "%s külmutas kõik %s! (%s)",
	noCollideAllEnts = "%s no-collided kõik %s! (%s)",
	removedAllEntName = "%s eemaldas kõik %s! (%s)",
	entitiesLowCase = "üksused",
	
	-- Console Log
	removedEntitiesFrom = "%s eemaldas %s üksust %s'st!",
	frozeEntitiesFrom = "%s külmutas %s üksust %s'st!",
	enabledSpawningCapabilities = "%s lubas spawni võimekuse %s'le!",
	disabledSpawningCapabilities = "%s keelas spawni võimekuse %s'le!",
	removingHighCollision = "Eemaldan %s'st kõrge kokkupõrke %s (%s)!",
	
}

return ee