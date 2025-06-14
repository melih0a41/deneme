-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

-- if SH_ANTICRASH.VARS then return end

SH_ANTICRASH.VARS = {}
SH_ANTICRASH.VARS.LATESTVERSION = true
SH_ANTICRASH.VARS.NEIGHBOUROFFSETVECTOR = Vector(10,10,10)

// COLOR (Thank you Sleepy <3)
SH_ANTICRASH.VARS.COLOR = {

	-- Contrast Checker: https://juicystudio.com/services/luminositycontrastratio.php#specify

	DARK = Color(30, 30, 30),
	MOREDARKY = Color(35, 35, 35),
	DARKY = Color(41, 41, 41),
	LESSDARKY = Color(45, 45, 45),
	LIGHTDARK = Color(48, 48, 48),
	LIGHTYDARK = Color(52, 52, 52),
	GREY = Color(109, 125, 126),
	DARKGREY = Color(149, 165, 166),
	LIGHTGREY = Color(150, 150, 150),
	
	PURPLE = Color(154, 0, 223),
	DARKPURPLE = Color(104, 0, 173),
	FUCHSIA = Color(255,0,255),
	CONTRASTFUCHSIA = Color(222, 0, 222),
	
	BLUE = Color(41, 128, 185),
	DARKBLUE = Color(0,0,139),
	LIGHTBLUE = Color(41, 183, 185),
	
	RED = Color(230, 58, 64),
	DARKRED = Color(139, 0, 0),
	
	GREEN = Color(46, 204, 113),
	
	LIGHTYELLOW = Color(189, 201, 15),
	YELLOW = Color(255, 215, 0),
	
	LIGHTORANGE = Color(255, 100, 73),
	ORANGE = Color(230, 153, 58),
	DARKORGANGE = Color(255, 140, 0),
	CONTRASTORGANGE = Color(222, 121, 0),
	SUPERDARKORGANGE = Color(191, 115, 0),
	ORANGERED = Color(255, 83, 73),
	CONTRASTORANGERED = Color(222, 44, 0),
	
}

// HOOKS
SH_ANTICRASH.VARS.HOOKS = {}

SH_ANTICRASH.VARS.HOOKS.SPAWN = {
	"PlayerSpawnObject",
	"PlayerSpawnNPC",
	"PlayerSpawnSENT",
	"PlayerSpawnSWEP",
	"PlayerSpawnVehicle",
	"CanTool"
}

SH_ANTICRASH.VARS.HOOKS.SPAWNED = {
	"PlayerSpawnedEffect",
	"PlayerSpawnedNPC",
	"PlayerSpawnedProp",
	"PlayerSpawnedRagdoll",
	"PlayerSpawnedSENT",
	"PlayerSpawnedSWEP",
	"PlayerSpawnedVehicle"
}

// CMD Load order priority
if SERVER then

	SV_ANTICRASH.CMD = SV_ANTICRASH.CMD or {}
	SV_ANTICRASH.CMD.REGISTERED = SV_ANTICRASH.CMD.REGISTERED or {}

	function SV_ANTICRASH.CMD.RegisterCMD(cmd,info,func)

		SV_ANTICRASH.CMD.REGISTERED[cmd] = {
			info = info,
			func = func
		}
		
	end
	
end

// Cleanup types
SH_ANTICRASH.VARS.CLEANUP = {}

SH_ANTICRASH.VARS.CLEANUP.COLORS = {
	[1] = Color(150,0,0)
}

SH_ANTICRASH.VARS.CLEANUP.TYPES = {
	[1] = { type = "resetmap", name = "resetMap" },
	[2] = { type = "removeall", name = "removeEntities" },
	[3] = { type = "freezeall", name = "freezeEntities" },
	[4] = { type = "nocollideall", name = "noCollideEntities" },
}

SH_ANTICRASH.VARS.CLEANUP.TYPESBYKEY = {}

local function GetCleanupName(cleanupType)
	return CLIENT and language.GetPhrase("Cleanup_"..cleanupType) or cleanupType
end

local function CleanupInit()

	local cleanupTbl = cleanup.GetTable()
	
	if #cleanupTbl == 0 then
		timer.Simple(1,CleanupInit)
		return
	end

	table.sort(cleanupTbl, function(a, b) 
		return GetCleanupName(a) < GetCleanupName(b)
	end)

	for _, cleanupType in pairs(cleanupTbl) do
		
		local insertKey = table.insert(SH_ANTICRASH.VARS.CLEANUP.TYPES, {
			type = cleanupType,
			name = GetCleanupName(cleanupType),
			isDefault = true
		})
		
		if SERVER then
			SV_ANTICRASH.CMD.RegisterCMD(cleanupType, "Remove "..cleanupType, function(ply, cmd, args)
				SV_ANTICRASH.DefaultCleanup(ply,cleanupType)
			end)
		end
		
	end
	
	-- Create table with cleanupType as key, custom key: 76561198307191491
	for i=1, #SH_ANTICRASH.VARS.CLEANUP.TYPES do
		local cleanupType = SH_ANTICRASH.VARS.CLEANUP.TYPES[i].type
		SH_ANTICRASH.VARS.CLEANUP.TYPESBYKEY[cleanupType] = SH_ANTICRASH.VARS.CLEANUP.TYPES[i]
	end
	
	local startColor = SH_ANTICRASH.VARS.CLEANUP.COLORS[1]
	local tintDiff = 120/#SH_ANTICRASH.VARS.CLEANUP.TYPES
	for i=2, #SH_ANTICRASH.VARS.CLEANUP.TYPES do
		
		local diff = (tintDiff*i)
		local newColor = Color(startColor.r-diff,startColor.g-diff,startColor.b-diff)
	
		SH_ANTICRASH.VARS.CLEANUP.COLORS[i] = newColor
		
	end

end
hook.Add("PostGamemodeLoaded","sh_anticrash_CleanupInit", CleanupInit)