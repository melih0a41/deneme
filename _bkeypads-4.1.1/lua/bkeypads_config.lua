bKeypads:SetConfig({ -- Don't touch this line

--################################################################################################################--
--[[##############################################################################################################--


       ██████╗ ██╗██╗     ██╗  ██╗   ██╗███████╗    ██╗  ██╗███████╗██╗   ██╗██████╗  █████╗ ██████╗ ███████╗
       ██╔══██╗██║██║     ██║  ╚██╗ ██╔╝██╔════╝    ██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝
       ██████╔╝██║██║     ██║   ╚████╔╝ ███████╗    █████╔╝ █████╗   ╚████╔╝ ██████╔╝███████║██║  ██║███████╗
       ██╔══██╗██║██║     ██║    ╚██╔╝  ╚════██║    ██╔═██╗ ██╔══╝    ╚██╔╝  ██╔═══╝ ██╔══██║██║  ██║╚════██║
       ██████╔╝██║███████╗███████╗██║   ███████║    ██║  ██╗███████╗   ██║   ██║     ██║  ██║██████╔╝███████║
       ╚═════╝ ╚═╝╚══════╝╚══════╝╚═╝   ╚══════╝    ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═════╝ ╚══════╝


    https://www.gmodstore.com/market/view/billys-keypads

    Thank you for purchasing my script and supporting my work :D I hope this will enrich your server.
	Make sure you've followed the installation instructions and activated your license if you haven't already.

	Using a leak? That's okay -- sometimes it's hard to justify splashing out on a new server, for example.
	But please be safe - the VAST majority of leaks contain backdoors and malicious code that can destroy
	your server and attract malicious players.

	If your server is successful, don't forget to support the creators who provided you with their hard work.

--################################################################################################################--
--################################################################################################################--

	This Lua file allows you to configure Billy's Keypads.

	PLEASE DO NOT EDIT THIS FILE IN NOTEPAD - IT'S LIKE TRYING TO DO SURGERY WITH A KITCHEN KNIFE.
	Use one of these:
	https://www.sublimetext.com/
	https://notepad-plus-plus.org/downloads/
	https://code.visualstudio.com/

	Unfortunately I cannot provide support regarding configuring the addon as I would just get flooded and wouldn't
	have time to help people with bugs or errors so please reach out to friends or the Internet if you need help.

	It follows the same syntax as actual Lua code so if you make a typo you are likely to break it. Be careful.

	Don't change anything in this file except for the settings themselves unless you know what you are doing.

	This config file uses Simplerr (the same thing DarkRP uses) to help you understand any errors.
	https://fptje.github.io/glualint-web/ can also help you debug your config file.

	Good luck, have fun :D

]]--##############################################################################################################--
--##[[                                              PERMISSIONS                                               ]]##--

-- NOTE: It is recommended that you install OpenPermissions with Billy's Keypads for advanced permissions control
-- If you have GmodAdminSuite installed then OpenPermissions should already be installed
-- Type !openpermissions in chat to open it
-- https://github.com/GmodAdminSuite/OpenPermissions

--################################################################################################################--
--##[[                                             GENERAL CONFIG                                             ]]##--

-- The maximum number of keypads a player can spawn
-- 0 = no maximum
MaxKeypads = {
	["default"] = 12,

	["admin"] = 0,
	["superadmin"] = 0,
},

-- If enabled, keypads can ONLY be placed on & linked to fading doors.
-- This will force "Auto Fading Door" for convenience.
-- Do not turn this on if you want your players to be able to link keypads to map objects! This overrides that.
-- NOTE: You can override this for usergroups/teams/jobs (e.g. donator ranks) if OpenPermissions is installed
KeypadOnlyFadingDoors = false,

-- Enable the creation of mirrored keypads?
-- Players will be able to place mirrored keypads on props that are automatically linked
-- Only one keypad will count towards their keypad limit!
KeypadMirroring = true,

-- The maximum distance players can link stuff from
-- Set to 0 for no maximum
-- NOTE: You can override this for usergroups/teams/jobs (e.g. admins) if OpenPermissions is installed
LinkingDistance = 1000000,

-- Set this to false to suppress the map's lighting on keypads when they're being interacted with by a player
-- May help with visibility
AlwaysEngineLighting = true,

Wiremod = {
	-- Enable Wiremod support
	-- (You can leave this enabled even without Wiremod installed)
	-- NOTE: You can control the permissions for access to Wiremod keypads (e.g. donator ranks) if OpenPermissions is installed
	Enabled = true,

	-- Enable the "Scanning" output for keypads
	-- This could theoretically be overpowered on DarkRP, leading clever players to create Wiremod keypads that open their door when the keypad
	-- is being scanned. This means they can make Keypad Crackers useless on the keypad.
	ScanningOutput = false,
},

-- Allow players to create keypads that press a key on their keyboard when access is granted or denied?
-- Billy's Keypads includes its own fading door tool which does not use a keyboard button for opening/closing the fading door.
-- This prevents fading door abuse and requires keypads to be linked to fading doors to control them. Therefore, in most cases
-- you won't need to enable this, and it's recommended you leave this off on roleplay servers.
-- More advanced users can instead use Wiremod for their creations, if it's installed (and you've enabled Wiremod keypads above)
-- NOTE: You can control the permissions for access to keyboard pressing (e.g. donator ranks) if OpenPermissions is installed
EnableKeyboardPress = false,

Notifications = {
	-- Allow players to receive "Access Granted" and "Access Denied" notifications from their keypads
	-- NOTE: You can control the permissions for receiving notifications (e.g. donator ranks) if OpenPermissions is installed
	Enable = true,

	-- Notifications by default have their own popups that show at the botttom of the screen
	-- If this doesn't fit in with the rest of your server, you can redirect notifications to chat instead
	UseChat = false,
},

--################################################################################################################--
--##[[                                                SCANNING                                                ]]##--

Scanning = {
	ScanMethods = {
		-- NOTE: You can control the permissions for access to scan methods (e.g. donator ranks) if OpenPermissions is installed

		-- Whether or not the PIN method of keypads is enabled
		EnablePIN = true,

		-- Whether or not the facial scanning method of keypads is enabled
		EnableFaceID = true,

		-- Whether or not keycards are enabled
		EnableKeycards = true,
	},

	ScanTimes = {
		-- How long should it take in seconds to scan the face of a player?
		FaceID = 0.5,

		-- How long should it take in seconds to scan an inserted keycard?
		Keycard = 0.5
	},

	-- In hammer units, what is the maximum distance a player/keycard can be scanned from?
	MaxDistance = 7000,

	-- Should the keypad abort scanning an inserted keycard if the player moves too far away?
	KeycardFailTooFarAway = true,

	AccessGranted = {
		-- The minimum amount of time in seconds a keypad can be "Access Granted" for
		-- Set to 0 for no minimum
		MinimumTime = 0,

		-- The maximum amount of time in seconds a keypad can be "Access Granted" for
		-- Set to 0 for no maxmimum
		MaximumTime = 0,

		-- Maximum number of repeats
		-- Set to 0 for no maximum
		MaximumRepeats = 10,

		-- Minimum repeat delay
		-- If set to 0 for no minimum
		MinimumRepeatDelay = 1,

		-- WARNING: If you have very high/unlimited MaximumRepeats and a low MinimumRepeatDelay, players could crash/lag the server by spamming repeats
	},

	AccessDenied = {
		-- The minimum amount of time in seconds a keypad can be "Access Denied" for
		-- Set to 0 for no minimum
		MinimumTime = 0,

		-- The maximum amount of time in seconds a keypad can be "Access Denied" for
		-- Set to 0 for no maxmimum
		MaximumTime = 0,

		-- Maximum number of repeats
		-- Set to 0 for no maximum
		MaximumRepeats = 10,

		-- Minimum repeat delay
		-- If set to 0 for no minimum
		MinimumRepeatDelay = 1,

		-- WARNING: If you have very high/unlimited MaximumRepeats and a low MinimumRepeatDelay, players could crash/lag the server by spamming repeats
	},
},

--################################################################################################################--
--##[[                                                KEYCARDS                                                ]]##--

Keycards = {
	ShowID = {
		-- Should keycard identification be enabled?
		AllowIndentification = true,

		-- The message that is displayed when a player presents their identification
		-- Available replacements:
		-- %name%      - Player's name
		-- %keycard%   - Keycard name
		-- %level%     - Keycard level
		-- %team%      - Team/job name
		-- %usergroup% - Player's usergroup
		Message = "%name% presents their %keycard% keycard and identifies themselves as %team%",

		-- If you are familiar with GMod's markup library's formatting, switch this option to true to enable markup tags
		-- https://wiki.facepunch.com/gmod/markup.Parse
		MessageMarkup = false,

		-- In hammer units, how far can players see keycard identification from?
		Distance = 10000,

		-- How long is the message displayed for?
		Time = 4,

		-- How long must the player wait before presenting their identification again?
		Cooldown = 2,
	},

	-- The message that is displayed when pressing E on a keycard scanner
	InsertKeycardMessage = "Please insert your keycard!",

	-- Should players spawn with a keycard?
	-- You can configure what teams spawn with keycards and the keycard level they spawn with below
	SpawnWithKeycard = false,

	-- Teams that should never spawn with a keycard
	SpawnWithoutKeycard = {
		TEAM_CLASS_D,
		TEAM_HOBO
	},

	-- Can players drop the keycard they spawned with?
	-- NOTE: You can configure who can drop their keycard using OpenPermissions if installed
	CanDropSpawnedWithKeycard = false,

	-- Can players drop other keycards?
	-- Dropped keycards can be collected by players and used to access keypads
	-- NOTE: You can configure who can drop keycards using OpenPermissions if installed
	CanDropKeycard = true,

	-- Drop keycards on death?
	-- NOTE: This is unaffected by CanDropSpawnedWithKeycard and CanDropKeycard
	DropKeycardOnDeath = false,

	-- Should the custom DarkRP /job be shown instead of the player's job's actual name?
	ShowCustomJobName = true,

	Levels = {
		-- You can configure keycard levels here

		-- NOTE: The order of the keycards matter!
		-- Keycards further down can access keypads which are configured to grant access to "Level X or higher" keycards
		-- Players can also have multiple keycard levels, but the one furthest down is the one VISIBLE to them and others.
		-- The "Name" field of the keycard levels does not affect this.

		{
			-- Level 1 is always the default, do not remove it, or the next keycard level will be selected as default.
			Name  = "Level 1",
			Color = Color(255, 0, 0)
		},

		{
			Name  = "Level 2",
			Color = Color(0, 0, 255),
			Teams = { TEAM_POLICE, TEAM_CHIEF, TEAM_MAYOR }
		},

		{
			Name  = "Level 3",
			Color = Color(0, 255, 0),
			Teams = { TEAM_CHIEF, TEAM_MAYOR }
		},

		{
			Name  = "Level 4",
			Color = Color(200, 0, 255),
			Teams = { TEAM_MAYOR }
		},

		--[[

		customCheck keycard level example:
		For more help, read this: https://wiki.gmodadminsuite.com/bkeypads#custom-checks TODO
		{
			Name = "Level 5",
			Color = Color(0, 0, 0),
			customCheck = function(ply)
				-- You can use a customCheck function here to use custom Lua code to determine a keycard's level
				-- For example, your custom SCP gamemode has its own keycard level system, and exposes a PLAYER:GetKeycardLevel() function
				-- In this example, you can use the following code to link this system to Billy's keycards:
				return ply:GetKeycardLevel() == 5
			end,
		}

		--]]
	},

	KeycardImage = {
		-- Keycards display various information on their world models, one of which being a small image that you can configure here

		-- Possible choices:

		-- avatar  : Displays the player's profile picture, if this cannot be displayed, Backup will be used instead
		-- keycard : Displays a keycard icon
		-- scp     : Displays the SCP Foundation logo
		-- <url>   : Displays a .png image downloaded from the given URL
		-- <path>  : Displays a texture in the client's game files (you may have to configure a way for clients to download this texture)

		-- Recommended size for images: 256x256
		Image = "avatar",
		Backup = "keycard",

		-- The color shown beneath the keycard image
		BackgroundColor = Color(0, 0, 0, 255)
	}
},

--################################################################################################################--
--##[[                                               APPEARANCE                                               ]]##--

Appearance = {
	ScreenColors = {
		-- What color should be displayed on keypads whilst scanning?
		Scanning = Color(32, 32, 32),

		-- What color should be displayed on keypads when access is granted?
		Granted = Color(80, 255, 80),

		-- What color should be displayed on keypads when access is denied?
		Denied = Color(255, 60, 60),

		-- What color should be displayed when a keypad is hacked or broken?
		Hacked = Color(150, 0, 0),
	},

	LEDColors = {
		-- What color should be displayed on the status LED whilst scanning?
		Scanning = Color(255, 175, 0),

		-- What color should be displayed on the status LED when access is granted?
		Granted = Color(0, 255, 0),

		-- What color should be displayed on the status LED when access is denied?
		Denied = Color(255, 0, 0),

		-- What color should be displayed on the status LED when a keypad is hacked or broken?
		Hacked = Color(255, 0, 0),
	},

	CustomImages = {
		-- Should custom images be enabled?
		-- This allows players to add custom images to their keypads, such as a logo.
		-- NOTE: You can control the permissions for the usage of custom images (e.g. donator ranks) if OpenPermissions is installed
		Enable = true,

		-- Domains that can be used as custom image URLs for keypads
		-- It is very important that you only use trusted websites & domains here because the images are downloaded clientside which exposes your players' IP addresses to possible malicious actors.
		-- So, do not add random, untrusted domains here. If a player asks to add a domain here, they are probably up to no good. Imgur and Steam should be good enough.
		URLWhitelist = {
			"i.imgur.com",
			"steamcdn-a.akamaihd.net",
			"steamuserimages-a.akamaihd.net",
		},
	}
},

--################################################################################################################--
--##[[                                           PAYMENTS & ECONOMY                                           ]]##--

Payments = {
	-- Allow players to charge others for using their keypad?
	-- NOTE: You can control the permissions for access to this (e.g. donator ranks) if OpenPermissions is installed
	Enable = true,

	-- Should players be asked to confirm whether they want to make the payment or not?
	Prompt = true,

	-- Minimum amount of money players can charge (this cannot be below 1)
	MinimumPayment = 1,

	-- Maximum amount of money players can charge
	-- Set to 0 for no maximum
	MaximumPayment = 0,

	Economy = {
		-- If DarkRP isn't running, turn this on to use the below custom Lua functions instead of DarkRP functions for checking money, taking payments, etc.
		CustomEconomy = false,

		-- return true if the player can afford $"amount"
		canAfford = function(ply, amount)
			return ply:GetMoney() >= amount
		end,

		-- Note; "amount" may be negative (for TAKING money) or positive (for ADDING money)
		addMoney = function(ply, amount)
			ply:SetMoney(ply:GetMoney() + amount)
		end,

		-- Return a correctly formatted currency string
		-- e.g. 1000.5 -> $1,000.50
		formatMoney = function(amount)
			-- Separate 1000s into 1,000s
			local left, num, right = string.match(amount, "^([^%d]*%d)(%d*)(.-)$")
			local formatted = left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right

			-- Right-pad a 0 to single-digit cents/pennies
			formatted = (formatted:gsub("%.(%d)$", ".%10"))

			return "$" .. formatted
		end,
	},
},

--################################################################################################################--
--##[[                                               MAP LINKING                                              ]]##--

MapLinking = {
	-- Should map linking to doors be enabled?
	Doors = true,

	-- Should map linking to buttons be enabled?
	Buttons = true,
},

--################################################################################################################--
--##[[                                               ACCESS LOGS                                              ]]##--

AccessLogs = {
	-- TIP: Need a new job for your roleplay server? Maybe make a detective job which spawns with the bkeypads_access_logs weapon ;)

	-- Do police need a warrant to view the access logs of a keypad?
	PoliceNeedWarrant = true,

	-- Can the access log checker weapon be dropped?
	-- NOTE: In DarkRP, this is also controlled by GM.Config.dropspawnedweapons
	CanDrop = true,
},

--################################################################################################################--
--##[[                                               FADING DOORS                                             ]]##--

FadingDoors = {
	-- Allow players to create fading doors which open/close using buttons on the keyboard?
	-- Enabling this means your server is vulnerable to fading door abuse
	EnableKeyboardPress = false,

	-- Allow players to create reversed fading doors?
	-- (Fading doors that are open by default and close when activated)
	Reversible = false,

	-- The maximum number of fading doors a player can spawn
	-- 0 = no maximum
	Maximum = {
		["default"] = 10,

		["admin"] = 0,
		["superadmin"] = 0,
	},

	-- Prevent fading doors from closing on players and making them stuck?
	-- Players will be automatically pushed out of fading doors they're stuck in
	-- THIS ISN'T 100% ACCURATE! (Source Engine is kind of shit at this)
	KeepOpen = true,
	-- Increase this number if you have a laggy server :D (Fading doors will be less responsive when stuck checking)
	TickIntervalMul = 16,

	-- DarkRP:
	-- Whether to allow fading doors to be lockpicked or not
	-- (If they can't be lockpicked, players must keypad crack the corresponding keypad instead)
	Lockpick = false,

	-- The materials that players are allowed to use for their fading doors
	Materials = {
		"sprites/heatwave",
		"models/wireframe",
		"debug/env_cubemap_model",
		"models/shadertest/shader3",
		"models/shadertest/shader4",
		"models/shadertest/shader5",
		"models/shiny",
		"models/debug/debugwhite",
		"Models/effects/comball_sphere",
		"Models/effects/comball_tape",
		"Models/effects/splodearc_sheet",
		"Models/effects/vol_light001",
		"models/props_combine/stasisshield_sheet",
		"models/props_combine/portalball001_sheet",
		"models/props_combine/com_shield001a",
		"models/props_c17/frostedglass_01a",
		"models/props_lab/Tank_Glass001",
		"models/props_combine/tprings_globe",
		"models/rendertarget",
		"models/screenspace",
		"brick/brick_model",
		"models/props_pipes/GutterMetal01a",
		"models/props_pipes/Pipesystem01a_skin3",
		"models/props_wasteland/wood_fence01a",
		"models/props_foliage/tree_deciduous_01a_trunk",
		"models/props_c17/FurnitureFabric003a",
		"models/props_c17/FurnitureMetal001a",
		"models/props_c17/paper01",
		"models/flesh",
	},

	-- Whether fading door sounds are enabled or not
	-- NOTE: You can control the permissions for access to fading door sounds (e.g. donator ranks) if OpenPermissions is installed
	EnableSounds = true,

	-- The sounds that players are allowed to use for the opening/closing sound of a fading door
	Sounds = {
		"doors/doorstop1.wav",
		"npc/turret_floor/retract.wav",
		"npc/roller/mine/combine_mine_deactivate1.wav",
		"npc/roller/mine/combine_mine_deploy1.wav",
		"npc/roller/mine/rmine_taunt1.wav",
		"npc/scanner/scanner_nearmiss2.wav",
		"npc/scanner/scanner_siren1.wav",
		"npc/barnacle/barnacle_gulp1.wav",
		"npc/barnacle/barnacle_gulp2.wav",
		"npc/combine_gunship/attack_start2.wav",
		"npc/combine_gunship/attack_stop2.wav",
		"npc/dog/dog_pneumatic1.wav",
		"npc/dog/dog_pneumatic2.wav",
	},

	-- The sounds that players are allowed to use for the active sound of a fading door
	-- These sounds must be looping sounds
	LoopSounds = {
		"ambient/machines/machine6.wav",
		"ambient/energy/force_field_loop1.wav",
		"physics/metal/canister_scrape_smooth_loop1.wav",
		"ambient/levels/citadel/citadel_drone_loop5.wav",
		"ambient/levels/citadel/citadel_drone_loop6.wav",
		"ambient/atmosphere/city_rumble_loop1.wav",
		"ambient/machines/city_ventpump_loop1.wav",
		"ambient/machines/combine_shield_loop3.wav",
		"npc/manhack/mh_engine_loop1.wav",
		"npc/manhack/mh_engine_loop2.wav",
	}
},

Persistence = {
	-- Whether persistent keypads should be saved on server shutdown
	-- If this is off, then any changes you make to permanent keypads will need to be saved using the profile switcher in the persistence tool's spawn menu section
	SaveOnShutDown = false,
},

KeypadDestruction = {
	-- Enable keypad damage (players can shoot to destroy & disable keypads)
	-- Admins will still be able to spawn destructible keypads if they explicitly choose to.
	-- NOTE: You can control the permissions for this if OpenPermissions is installed
	Enable = false,

	-- How much health should a keypad spawn with?
	KeypadHealth = 200,

	-- What is the maximum shield charge a keypad can hold as a percentage of its maximum health?
	-- 0 = Unlimited
	-- 100% = 1
	-- 200% = 2
	-- 300% = 3
	-- ...
	MaxShield = 1,

	-- In seconds, how often should a keypad regenerate health?
	-- 0 to disable
	KeypadRegenRate = 0.5,

	-- How much health should a keypad regenerate as a percentage of its maximum health?
	-- 0 to disable
	-- NOTE: The actual amount will be rounded up to get rid of any decimals
	-- Example:
	-- Maximum health = 200
	-- Health regeneration pct = 0.01 = 1%
	-- Health regeneration amount = 200 * 1% = 2
	-- Health regeneration rate = 0.5 seconds
	-- Time to fully regenerate = 200 / (200 * 1%) / 0.5 = 200 seconds
	KeypadRegenAmount = 0.01,

	-- How much should a battery charge a keypad's health as a percentage of its maximum health?
	-- 100% = 1
	-- 75% = 0.75
	-- 50% = 0.5
	-- 25% = 0.25
	-- ...
	BatteryCharge = 0.25,

	-- How much should a shield battery charge a keypad's shield as a percentage of its maximum health?
	ShieldBatteryCharge = 0.25,

	-- DarkRP F4 menu items
	DarkRP = {
		-- https://darkrp.miraheze.org/wiki/DarkRP:CustomEntityFields

		Battery = {
			Disabled = true,
			Name = "Keypad Battery",

			price = 500,
			max = 0,
			cmd = "buykeypadbattery",
			category = "Other",
			--allowed = { TEAM_MECHANIC },
			--customCheck = function(ply) return ply:GetUserGroup() == "donator" end,
		},

		ShieldBattery = {
			Disabled = true,
			Name = "Keypad Shield Battery",

			price = 1000,
			max = 0,
			cmd = "buykeypadshield",
			category = "Other",
			--allowed = { TEAM_MECHANIC },
			--customCheck = function(ply) return ply:GetUserGroup() == "donator" end,
		}
	},
},

-- Should experimental ENTITY:GetClass() override be enabled?
-- This will make sure that all keypad crackers work with Billy's Keypads
-- This is very experimental and could cause problems
ExperimentalKeypadCompatibility = true,

-- Disable PIN keypad fake angles?
-- PIN keypads will prevent other players from seeing which numbers you are pressing on the keypad
-- This behaviour can sometimes trigger anticheats, so you can disable it here
DisablePINKeypadFakeAngles = false,

-- Congratulations, you've reached the end of the config!














--################################################################################################################--
--################################################################################################################--
}) -- Don't touch this line