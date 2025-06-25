/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

include("zcrga/sh/zcrga_config.lua")
AddCSLuaFile("zcrga/sh/zcrga_config.lua")

local function zcrga_LoadAllFiles(fdir)
	local files, dirs = file.Find(fdir .. "*", "LUA")

	for _, afile in ipairs(files) do
		if string.match(afile, ".lua") then
			if SERVER then
				AddCSLuaFile(fdir .. afile)
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c88d96e23ef1c52b933ccc1d3ce15226554b8e572b9dbf763835533b4e11507c

			include(fdir .. afile)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c342b127afdf542b621f89d5d7f1fe28190f83a669677e45d028bc5b66d3917c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44

	for _, dir in ipairs(dirs) do
		zcrga_LoadAllFiles(fdir .. dir .. "/")
	end
end

zcrga_LoadAllFiles("zcrga/")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 049b4e254ea84b6bbd8714673e122cc1e8af2018030f6cc079898e33e35e9c0c
