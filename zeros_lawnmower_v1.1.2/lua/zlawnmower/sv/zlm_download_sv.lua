/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if CLIENT then return end
zlm = zlm or {}
zlm.f = zlm.f or {}

if zlm.config.EnableResourceAddfile then
	zlm = zlm or {}
	zlm.force = zlm.force or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	function zlm.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zlm.force.AddDir(path .. "/" .. v)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	zlm.force.AddDir("particles")
	zlm.force.AddDir("sound/zlm/")
	zlm.force.AddDir("models/zerochain/props_lawnmower/")
	zlm.force.AddDir("materials/particle/zlm/")
	zlm.force.AddDir("materials/entities/")
	zlm.force.AddDir("materials/zerochain/zlm/")
	zlm.force.AddDir("materials/zerochain/props_lawnmower/")
	zlm.force.AddDir("scripts/vehicles/zerochain/")
else
	resource.AddWorkshop( "1693683733" ) -- Zeros LawnMowerMan Contentpack
	//https://steamcommunity.com/sharedfiles/filedetails/?id=1693683733
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
