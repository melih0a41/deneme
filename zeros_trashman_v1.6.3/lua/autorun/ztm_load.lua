/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/


local DebugPrint = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

local function NicePrint(txt)
    if DebugPrint == false then return end

    if SERVER then
        MsgC(Color(84, 150, 197), txt .. "\n")
    else
        MsgC(Color(193, 193, 98), txt .. "\n")
    end
end

local function PreLoadFile(path)
	if CLIENT then
		include(path)
	else
		AddCSLuaFile(path)
		include(path)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

local function LoadFiles(path)
	local files, _ = file.Find(path .. "/*", "LUA")

	for _, v in ipairs(files) do
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

	for _, v in ipairs(files) do
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
	NicePrint("//////////////// Zero´s Trashman //////////////////")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("//                                               //")
	PreLoadFile("sh_ztm_config.lua")
	LoadFiles("ztm_languages")

	LoadFiles("ztrashman/util")
	LoadFiles("ztrashman/util/player")
	LoadFiles("ztrashman/generic")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

	LoadFiles("ztrashman/buyermachine")
	LoadFiles("ztrashman/leafpile")
	LoadFiles("ztrashman/manhole")
	LoadFiles("ztrashman/recycler")
	LoadFiles("ztrashman/swep")
	LoadFiles("ztrashman/trash")
	LoadFiles("ztrashman/trashbag")
	LoadFiles("ztrashman/trashburner")
	LoadFiles("ztrashman/trashcan")

	NicePrint("//                                               //")
	NicePrint("///////////////////////////////////////////////////")
	NicePrint("///////////////////////////////////////////////////")

	if DebugPrint == false then
		if SERVER then
			MsgC(Color(84, 150, 197), "Zeros Trashman - Loaded\n")
		else
			MsgC(Color(193, 193, 98), "Zeros Trashman - Loaded\n")
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

PreLoadFile("ztrashman/util/cl_settings.lua")


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

		MsgC(Color(255, 0, 0), "[Zero´s Trashman] > Zeros Lua Libary not found!")
		MsgC(Color(255, 0, 0), "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")

		if CLIENT then
			surface.PlaySound( "common/warning.wav" )
		end

		if SERVER then
			for k,v in ipairs(player.GetAll()) do
				if IsValid(v) then
					Warning(v, "[Zero´s Trashman] > Zeros Lua Libary not found!")
					Warning(v, "https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111")
				end
			end
		end
		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

	Initialize()
end)
