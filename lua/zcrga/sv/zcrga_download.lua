/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

if CLIENT then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

if zcrga.config.EnableResourceAddfile then
	zcrga = zcrga or {}
	zcrga.force = zcrga.force or {}

	function zcrga.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c88d96e23ef1c52b933ccc1d3ce15226554b8e572b9dbf763835533b4e11507c

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

		for k, v in pairs(folders) do
			zcrga.force.AddDir(path .. "/" .. v)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	zcrga.force.AddDir("particles")
	zcrga.force.AddDir("sound/zap")
	zcrga.force.AddDir("models/zerochain/props_arcade")
	zcrga.force.AddDir("materials/zerochain/props_arcade/coin")
	zcrga.force.AddDir("materials/zerochain/props_arcade/coinpusher")
	zcrga.force.AddDir("materials/zerochain/zap/particles")
else
	resource.AddWorkshop("1344490358") -- Zeros CoinPusher Contentpack
end
