/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.force = zvm.force or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

resource.AddWorkshop( "2532060111" ) // Zeros Lua Libary Contentpack
//https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111

if zvm.config.FastDl then
	function zvm.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zvm.force.AddDir(path .. "/" .. v)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

	zvm.force.AddDir("sound/zvm/")
	zvm.force.AddDir("models/zerochain/props_vendingmachine/")
	zvm.force.AddDir("materials/zerochain/props_vendingmachine/")
	zvm.force.AddDir("materials/zerochain/zvendingmachine/")
	resource.AddSingleFile("materials/entities/zvm_machine.png")
else

	resource.AddWorkshop("2734306160") // Zeros Vendingmachine Contentpack 3.0.0
	// https://steamcommunity.com/sharedfiles/filedetails/?id=2734306160
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff
