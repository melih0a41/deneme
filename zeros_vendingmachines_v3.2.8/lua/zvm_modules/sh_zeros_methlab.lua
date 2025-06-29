/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Methlab
//https://www.gmodstore.com/market/view/zero-s-methlab-drug-script
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

zvm.AllowedItems.Add("zmlab_collectcrate") // Has CustomData
zvm.AllowedItems.Add("zmlab_filter")
zvm.AllowedItems.Add("zmlab_methylamin")
zvm.AllowedItems.Add("zmlab_palette")
zvm.AllowedItems.Add("zmlab_aluminium")
zvm.AllowedItems.Add("zmlab_combiner")
zvm.AllowedItems.Add("zmlab_frezzer")
zvm.AllowedItems.Add("zmlab_meth") // Has CustomData
zvm.AllowedItems.Add("zmlab_meth_baggy") // Has CustomData

zclib.RenderData.Add("zmlab_frezzer", {ang = Angle(0, 180, 0)})
zclib.RenderData.Add("zmlab_methylamin", {ang = Angle(0, 270, 0)})

zvm.Definition.Add("zmlab_collectcrate", {
	OnItemDataCatch = function(data, ent)
		data.meth_amount = ent:GetMethAmount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetMethAmount(data.meth_amount)
	end,
	OnItemDataName = function(data, ent)
		if data.meth_amount > 0 then
			return ent.PrintName .. " " .. data.meth_amount .. zmlab.config.UoW
		else
			return ent.PrintName
		end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.meth_amount == data.meth_amount end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

zvm.Definition.Add("zmlab_meth", {
	OnItemDataCatch = function(data, ent)
		data.meth_amount = ent:GetMethAmount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetMethAmount(data.meth_amount)
	end,
	OnItemDataName = function(data, ent) return ent.PrintName .. " " .. data.meth_amount .. zmlab.config.UoW end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.meth_amount == data.meth_amount end,
})

zvm.Definition.Add("zmlab_meth_baggy", {
	OnItemDataApply = function(data, ent)
		ent:SetMethAmount(zmlab.config.MethExtractorSWEP.Amount)
	end
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

zvm.Definition.Add("zmlab_palette", {
	BlockItemCheck = function(other, Machine) return other:GetCrateCount() > 0 end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

local zmlab_entTable = {
	[ "zmlab_collectcrate" ] = true,
	[ "zmlab_filter" ] = true,
	[ "zmlab_methylamin" ] = true,
	[ "zmlab_palette" ] = true,
	[ "zmlab_aluminium" ] = true,
	[ "zmlab_combiner" ] = true,
	[ "zmlab_frezzer" ] = true,
}

hook.Add("zvm_OnPackageItemSpawned", "zvm_OnPackageItemSpawned_ZerosMethlab", function(ply, ent, extradata)
	if zmlab and zmlab_entTable[ ent:GetClass() ] then
		zmlab.f.SetOwner(ent, ply)
	end
end)

hook.Add("zclib_GetImagePath", "zclib_GetImagePath_ZerosMethlab", function(ItemData)
	if zmlab and string.sub(ItemData.class, 1, 6) == "zmlab_" then return "zmlab/" .. ItemData.class end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
