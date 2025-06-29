/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Crackermaker
//https://www.gmodstore.com/market/view/zero-s-crackermaker-firework-production

zvm.Definition.Add("zcm_box", {
	BlockItemCheck = function(other, Machine)
		if zcm and other:GetFireworkCount() > 0 then return true end
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		zcm.f.SetOwner(ent, ply)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zvm.Definition.Add("zcm_blackpowder", {
	OnPackageItemSpawned = function(data, ent, ply)
		zcm.f.SetOwner(ent, ply)
	end,
})

zvm.Definition.Add("zcm_paperroll", {
	OnPackageItemSpawned = function(data, ent, ply)
		zcm.f.SetOwner(ent, ply)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zvm.Definition.Add("zcm_firecracker", {
	OnPackageItemSpawned = function(data, ent, ply)
		zcm.f.SetOwner(ent, ply)
	end,
})

zvm.Definition.Add("zcm_crackermachine", {
	OnPackageItemSpawned = function(data, ent, ply)
		zcm.f.SetOwner(ent, ply)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosCrackermaker", function(cEnt, ItemData)
	if zcm and ItemData.class == "zcm_crackermachine" then
		local function DrawPart(mdl)
			render.Model({
				model = mdl,
				pos = cEnt:GetPos(),
				angle = Angle(0, 0, 0)
			}, client_mdl)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

		DrawPart("models/zerochain/props_crackermaker/zcm_paperroller.mdl")
		DrawPart("models/zerochain/props_crackermaker/zcm_rollmover.mdl")
		DrawPart("models/zerochain/props_crackermaker/zcm_cutter.mdl")
		DrawPart("models/zerochain/props_crackermaker/zcm_cutrollrelease.mdl")
		DrawPart("models/zerochain/props_crackermaker/zcm_rollpacker.mdl")
		DrawPart("models/zerochain/props_crackermaker/zcm_rollbinder.mdl")
		DrawPart("models/zerochain/props_crackermaker/zcm_powderfiller.mdl")
	end
end)
