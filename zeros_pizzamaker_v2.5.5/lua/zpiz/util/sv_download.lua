/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if CLIENT then return end

resource.AddWorkshop( "2532060111" ) // Zeros Lua Libary Contentpack
//https://steamcommunity.com/sharedfiles/filedetails/?id=2532060111
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599

if zpiz.config.FastDL then
	zpiz = zpiz or {}
	zpiz.force = zpiz.force or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	function zpiz.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zpiz.force.AddDir(path .. "/" .. v)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

	zpiz.force.AddDir("particles")
	zpiz.force.AddDir("resource/fonts")
	zpiz.force.AddDir("sound/zpiz")
	zpiz.force.AddDir("models/zerochain/props_pizza")
	zpiz.force.AddDir("materials/zerochain/zpiz/particle")
	zpiz.force.AddDir("materials/zerochain/zpiz/ui")
	zpiz.force.AddDir("materials/zerochain/zpiz/ui/icons")
	zpiz.force.AddDir("materials/zerochain/zpiz/ui/pizzas")
	zpiz.force.AddDir("materials/zerochain/props_pizza")
	zpiz.force.AddDir("materials/zerochain/props_pizza/ingredients")
else
	resource.AddWorkshop("1332778012") -- Zeros PizzaMaker Contentpack
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47
