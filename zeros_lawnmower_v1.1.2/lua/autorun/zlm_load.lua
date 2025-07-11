/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm || {}
zlm.f = zlm.f || {}

local function NicePrint(txt)
	if SERVER then
		MsgC(Color(115, 200, 115), txt .. "\n")
	else
		MsgC(Color(193, 193, 98), txt .. "\n")
	end
end

local IgnoreFileTable = {}
function zlm.f.PreLoadFile(fdir,afile,info)
	IgnoreFileTable[afile] = true
	zlm.f.LoadFile(fdir,afile,info)
end

function zlm.f.LoadFile(fdir,afile,info)

	if info then
		local nfo = "// [ Initialize ]: " .. afile .. string.rep( " ", 30 - afile:len() ) .. "//"
		NicePrint(nfo)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

	if SERVER then
		AddCSLuaFile(fdir .. afile)
	end

	include(fdir .. afile)
end

function zlm.f.LoadAllFiles(fdir)
	local files, dirs = file.Find(fdir .. "*", "LUA")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	for _, afile in ipairs(files) do
		if string.match(afile, ".lua") and not IgnoreFileTable[afile] then
			zlm.f.LoadFile(fdir,afile,true)
		end
	end

	for _, dir in ipairs(dirs) do
		zlm.f.LoadAllFiles(fdir .. dir .. "/")
	end
end

// Initializes the Script
function zlm.f.Initialize()
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("/////////////// Zeros LawnMowerman ////////////////")
	NicePrint("///////////////////////////////////////////////////")

	zlm.f.PreLoadFile("zlawnmower/sh/","zlm_precache.lua",true)
	zlm.f.PreLoadFile("zlawnmower/sh/","zlm_tableregi.lua",true)

	zlm.f.PreLoadFile("zlawnmower/sh/","zlm_materials.lua",true)
	zlm.f.PreLoadFile("","zlm_main_config.lua",true)
	zlm.f.PreLoadFile("","zlm_grass_config.lua",true)

	zlm.f.LoadAllFiles("zlm_languages/")


	zlm.f.LoadAllFiles("zlawnmower/sh/")
	if SERVER then
		zlm.f.LoadAllFiles("zlawnmower/sv/")
	end
	zlm.f.LoadAllFiles("zlawnmower/cl/")

	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////////////////////////////////////////")
end

if SERVER then
	timer.Simple(0,function()
		zlm.f.Initialize()
	end)
else
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380


	// This needs to be called instantly on client since client settings wont work otherwhise
	zlm.f.PreLoadFile("zlawnmower/sh/", "zlm_materials.lua", false)
	zlm.f.PreLoadFile("zlawnmower/cl/", "zlm_fonts.lua", false)
	zlm.f.PreLoadFile("zlawnmower/cl/", "zlm_settings_menu.lua", false)

	timer.Simple(0,function()
		zlm.f.Initialize()
	end)
end

zlm.f.PreLoadFile("zlawnmower/sh/", "zlm_tableregi.lua", false)
zlm.f.PreLoadFile("", "zlm_grass_config.lua", false)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
