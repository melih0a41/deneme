
--[[---------------------------------------------------------
	Name: Setup
-----------------------------------------------------------]]
VoidCases = VoidCases or {}
VoidCases.Config = {}
VoidCases.Lang = VoidCases.Lang or {}

function VoidCases.Lang.GetPhrase(phrase, x)
	return VoidLib.Lang:GetLangPhrase("VoidCases", phrase, x)
end

VoidCases.Dir = "voidcases"

VoidCases.CurrentVersion = "2.9.6"
VoidCases.LatestVersion = nil

if (CLIENT) then
	include(VoidCases.Dir .. "/libs/cami.lua")
end

if (SERVER) then
	include("voidcases_mysql.lua")

	include(VoidCases.Dir .. "/libs/cami.lua")
	AddCSLuaFile(VoidCases.Dir .. "/libs/cami.lua")

	if (string.sub(VoidCases.CurrentVersion, 1, 1) != "{") then
		resource.AddWorkshop("2078529432")
	end

	resource.AddWorkshop("1983122259")
end

--[[---------------------------------------------------------
	Name: Main
-----------------------------------------------------------]]
function VoidCases.Load(dir, shared)
	local files = file.Find(dir.. "/".. "*", "LUA")

	for k, v in pairs(files) do
		if string.StartWith(v, "cl") then

			AddCSLuaFile(dir.. "/".. v)

			if CLIENT then
				local load = include(dir.. "/".. v)
				if load then load() end
			end
		end

		if string.StartWith(v, "sv") then
			if SERVER then
				local load = include(dir.. "/".. v)
				if load then load() end
			end
		end

		if string.StartWith(v, "sh") or shared then
			AddCSLuaFile(dir.. "/".. v)

			local load = include(dir.. "/".. v)
			if load then load() end
		end
	end
end

function VoidCases.AddCSDir(dir)
	local files = file.Find(dir.. "/".. "*", "LUA")

	for k, v in pairs(files) do
		AddCSLuaFile(dir.. "/".. v)

		if CLIENT then
			include(dir.. "/".. v)
		end
	end
end

--[[---------------------------------------------------------
	Name: Functions
-----------------------------------------------------------]]
function VoidCases.PrintError(...)
	MsgC(Color(120, 255, 120), "[VoidCases] (ERROR): ", Color(255, 255, 255), ..., "\n")
end

// 89495909548170261
function VoidCases.PrintWarning(...)
	MsgC(Color(120, 255, 120), "\n")
	MsgC(Color(120, 255, 120), "///////////////////////////////////////////////////////////////////////////////////////////////////", "\n")
	local warning = [[
 _    _   ___  ______  _   _  _____  _   _  _____ 
| |  | | / _ \ | ___ \| \ | ||_   _|| \ | ||  __ \
| |  | |/ /_\ \| |_/ /|  \| |  | |  |  \| || |  \/
| |/\| ||  _  ||    / | . ` |  | |  | . ` || | __ 
\  /\  /| | | || |\ \ | |\  | _| |_ | |\  || |_\ \
 \/  \/ \_| |_/\_| \_|\_| \_/ \___/ \_| \_/ \____/																				
	]]
	MsgC(Color(120, 255, 120), warning, "\n")
	MsgC(Color(120, 255, 120), "///////////////////////////////////////////////////////////////////////////////////////////////////", "\n")
	MsgC(Color(120, 255, 120), "\n")
	MsgC(Color(120, 255, 120), "[VoidCases] (WARNING): ", Color(255, 255, 255), ..., "\n")
	MsgC(Color(120, 255, 120), "\n")
	MsgC(Color(120, 255, 120), "///////////////////////////////////////////////////////////////////////////////////////////////////", "\n")
	MsgC(Color(120, 255, 120), "\n")
end


function VoidCases.PrintDebug(...)
	if (!VoidCases.Debug) then return end

	MsgC(Color(120, 255, 120), "[VoidCases] (DEBUG): ", Color(255, 255, 255), ..., "\n")
end

function VoidCases.Print(...)
	MsgC(Color(255, 120, 120), "[VoidCases]: ", Color(255, 255, 255), ..., "\n")
end

--[[---------------------------------------------------------
	Name: Loading
-----------------------------------------------------------]]

function VoidCases.LoadAll()
	VoidCases.Load(VoidCases.Dir.. "/libs")
	VoidCases.Load(VoidCases.Dir)
	VoidCases.AddCSDir(VoidCases.Dir.. "/vgui")
end

if (!VoidCases.Loaded) then
	if (VoidLib) then
		VoidCases.Print("VoidLib already loaded, loading..")
		VoidCases.LoadAll()
	else
		VoidCases.PrintDebug("VoidLib not loaded, waiting for hook")
		hook.Add("VoidLib.Loaded", "VoidCases.Init.WaitForVoidLib", function ()
			VoidCases.Print("VoidLib load hook called, loading..")
			VoidCases.LoadAll()
		end)
	end

	-- By this time, VoidLib should be available.
	hook.Add("Initialize", "VoidCases.IsVoidLibLoaded", function ()
		if (!VoidLib) then
			VoidCases.PrintError("--------------------------------------------------------------------------------")
			VoidCases.PrintError("You are missing VoidLib! Subscribe to it at https://steamcommunity.com/sharedfiles/filedetails/?id=2078529432!")
			VoidCases.PrintError("Without VoidLib the addon will not function properly.")
			VoidCases.PrintError("You have been warned! This addon will not load until VoidLib is installed.")
			VoidCases.PrintError("Do not open a support ticket unless you are 100% sure that VoidLib is installed.")
			VoidCases.PrintError("--------------------------------------------------------------------------------")
		end
	end)
end

VoidCases.Loaded = true


--[[---------------------------------------------------------
	Name: VoidLib loader
	Info: Don't touch this or the addon will break.
-----------------------------------------------------------]]

if (!SERVER) then return end
hook.Add("InitPostEntity", "VoidCases.LibLoader", function ()
	VoidLib.Tracker:RegisterAddon("VoidCases", "4da3824e-2485-4784-9204-988178dcb47d", "86480918269574254")
	VoidCases.HasTLoaded = true
	VoidCases.LoadNPCs()
end)
