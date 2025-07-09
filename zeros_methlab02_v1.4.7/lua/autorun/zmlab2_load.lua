/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

local DebugPrint = false

local function NicePrint(txt)
    if DebugPrint == false then return end

    if SERVER then
        MsgC(Color(84, 150, 197), txt .. "\n")
    else
        MsgC(Color(193, 193, 98), txt .. "\n")
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

local function PreLoadFile(path)
	if CLIENT then
		include(path)
	else
		AddCSLuaFile(path)
		include(path)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

local function LoadFiles(path)
	local files, _ = file.Find(path .. "/*", "LUA")

	for _, v in pairs(files) do
		if string.sub(v, 1, 3) == "sh_" then
			if CLIENT then
				include(path .. "/" .. v)
			else
				AddCSLuaFile(path .. "/" .. v)
				include(path .. "/" .. v)
			end
			NicePrint("// Loaded " .. v .. string.rep(" ", 38 - v:len()) .. " //")
		end
	end

	for _, v in pairs(files) do
		if string.sub(v, 1, 3) == "cl_" then
			if CLIENT then
				include(path .. "/" .. v)
				NicePrint("// Loaded " .. v .. string.rep(" ", 38 - v:len()) .. " //")
			else
				AddCSLuaFile(path .. "/" .. v)
			end
		elseif string.sub(v, 1, 3) == "sv_" then
			include(path .. "/" .. v)
			NicePrint("// Loaded " .. v .. string.rep(" ", 38 - v:len()) .. " //")
		end
	end
end

local function Initialize()
	NicePrint(" ")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("////////////// Zeros Methlab 2 ////////////////////")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("//                                               //")

	PreLoadFile("zmlab2/sh_main_config.lua")

	LoadFiles("zmlab2_languages")

	// TODO Find a better solution for translations which are used in the libary and also used by multiple scripts
	zclib.Language["Minutes"] = zmlab2.language["Minutes"]
	zclib.Language["Seconds"] = zmlab2.language["Seconds"]
	zclib.Language["Cancel"] = zmlab2.language["Cancel"]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

	zclib.config.Currency = zmlab2.config.Currency
	zclib.config.CurrencyInvert = zmlab2.config.CurrencyInvert
	zclib.config.AdminRanks = table.Copy(zmlab2.config.AdminRanks)


	PreLoadFile("zmlab2/sh_meth_config.lua")
	PreLoadFile("zmlab2/sh_tent_config.lua")
	PreLoadFile("zmlab2/sh_equipment_config.lua")
	PreLoadFile("zmlab2/sh_storage_config.lua")
	PreLoadFile("zmlab2/sh_custom_hooks.lua")

	LoadFiles("zmlab2/util")
	LoadFiles("zmlab2/util/player")
	LoadFiles("zmlab2/tent")
	LoadFiles("zmlab2/ventilation")
	LoadFiles("zmlab2/minigame")
	LoadFiles("zmlab2/minigame/games")
	LoadFiles("zmlab2/equipment")
	LoadFiles("zmlab2/furnace")
	LoadFiles("zmlab2/storage")
	LoadFiles("zmlab2/pumpsystem")
	LoadFiles("zmlab2/mixer")
	LoadFiles("zmlab2/filter")
	LoadFiles("zmlab2/filler")
	LoadFiles("zmlab2/frezzer")
	LoadFiles("zmlab2/packing")
	LoadFiles("zmlab2/pollutionsystem")
	LoadFiles("zmlab2/extinguisher")
	LoadFiles("zmlab2/generic")
	LoadFiles("zmlab2/meth")
	LoadFiles("zmlab2/crate")
	LoadFiles("zmlab2/palette")
	LoadFiles("zmlab2/dropoff")
	LoadFiles("zmlab2/npc")
	LoadFiles("zmlab2/save")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

	NicePrint("//                                               //")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////////////////////////////////////////")

	if DebugPrint == false then
		if SERVER then
			MsgC(Color(84, 150, 197), "Zeros Methlab 2 - Loaded\n")
		else
			MsgC(Color(193, 193, 98), "Zeros Methlab 2 - Loaded\n")
		end
	end
end

PreLoadFile("zmlab2/util/sh_materials.lua")
PreLoadFile("zmlab2/util/cl_fonts.lua")
PreLoadFile("zmlab2/util/cl_settings.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

timer.Simple(0,function()

	// If zeros libary is not installed on the server then lets tell them
	if zclib == nil then
		local function Warning(ply, msg)
			if DarkRP and DarkRP.notify then
				DarkRP.notify(ply, 1, 8, msg)
			else
				ply:ChatPrint(msg)
			end
		end

		MsgC(Color(255, 0, 0), "[Zero´s Methlab 2] > Zeros Lua Libary not found!")
		MsgC(Color(255, 0, 0), "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")

		if CLIENT then
			surface.PlaySound( "common/warning.wav" )
		end

		if SERVER then
			for k,v in ipairs(player.GetAll()) do
				if IsValid(v) then
					Warning(v, "[Zero´s Methlab 2] > Zeros Lua Libary not found!")
					Warning(v, "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")
				end
			end
		end
		return
	end

	Initialize()
end)
