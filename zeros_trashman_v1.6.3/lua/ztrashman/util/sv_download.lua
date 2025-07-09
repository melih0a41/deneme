/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if CLIENT then return end
ztm = ztm or {}
ztm.force = ztm.force or {}

resource.AddWorkshop( "2532060111" ) // Zeros Lua Libary Contentpack
//https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

if ztm.config.FastDl then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	function ztm.force.AddDir(path)

		local files, folders = file.Find("addons/zeros_trashman/" .. path .. "/*", "GAME")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

		for k, v in pairs(files) do
			resource.AddFile("addons/zeros_trashman/" .. path .. "/" .. v)
		end

		for k, v in pairs(folders) do

			ztm.force.AddDir("addons/zeros_trashman/" .. path .. "/" .. v)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

	ztm.force.AddDir("particles")
	ztm.force.AddDir("sound/ztm/")
	ztm.force.AddDir("models/zerochain/props_trashman/")
	ztm.force.AddDir("materials/zerochain/props_trashman/")
	ztm.force.AddDir("materials/entities/")
	ztm.force.AddDir("materials/vgui/entities/")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

else
	resource.AddWorkshop( "1795813904" ) // Zeros Trashman Contentpack
	//https://steamcommunity.com/sharedfiles/filedetails/?id=1795813904
end
