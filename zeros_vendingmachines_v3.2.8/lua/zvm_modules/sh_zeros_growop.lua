/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros GrowOP
//https://www.gmodstore.com/market/view/zero-s-grow-op-weed-script
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa


zvm.Definition.Add("zwf_lamp", {
	OnItemDataCatch = function(data, ent)
		data.lampid = ent:GetLampID()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetLampID(data.lampid)
		ent:SetModel(zwf.config.Lamps[ data.lampid ].model)
	end,
	OnItemDataName = function(data, ent)
		return zwf.config.Lamps[ data.lampid ].name
	end,
	ItemExists = function(compared_item, data)
		return true, compared_item.extraData.lampid == data.lampid
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

zvm.Definition.Add("zwf_nutrition", {
	OnItemDataCatch = function(data, ent)
		data.nutid = ent:GetNutritionID()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetNutritionID(data.nutid)
		ent:SetSkin(zwf.config.Nutrition[data.nutid].skin)
	end,
	OnItemDataName = function(data, ent)
		return zwf.config.Nutrition[data.nutid].name
	end,
	ItemExists = function(compared_item, data)
		return true, compared_item.extraData.nutid == data.nutid
	end,
})

zvm.Definition.Add("zwf_seed", {
	OnItemDataCatch = function(data, ent)
		data.seedid = ent:GetSeedID()
		data.perf_time = ent:GetPerf_Time()
		data.perf_amount = ent:GetPerf_Amount()
		data.perf_thc = ent:GetPerf_THC()
		data.seedcount = ent:GetSeedCount()
		data.seedname = ent:GetSeedName()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetSeedID(data.seedid)
		ent:SetPerf_Time(data.perf_time)
		ent:SetPerf_Amount(data.perf_amount)
		ent:SetPerf_THC(data.perf_thc)
		ent:SetSeedCount(data.seedcount)
		ent:SetSeedName(data.seedname)
		local plantData = zwf.config.Plants[data.seedid]
		if plantData then
			ent:SetSkin(plantData.skin)
		end
	end,
	OnItemDataName = function(data, ent)
		return ent:GetSeedName()
	end,
	ItemExists = function(compared_item, data)
		return true, compared_item.extraData.seedid == data.seedid and compared_item.extraData.seedname == data.seedname and compared_item.extraData.seedcount == data.seedcount
	end,
})

zvm.Definition.Add("zwf_jar", {
	OnItemDataCatch = function(data, ent)
		data.weed_amount = ent:GetWeedAmount()
		data.weed_id = ent:GetPlantID()
		data.weed_thc = ent:GetTHC()
		data.weed_perftime = ent:GetPerf_Time()
		data.weed_perfamount = ent:GetPerf_Amount()
		data.weed_perfthc = ent:GetPerf_THC()
		data.weed_name = ent:GetWeedName()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetWeedAmount(data.weed_amount)
		ent:SetPlantID(data.weed_id)
		ent:SetTHC(data.weed_thc)
		ent:SetPerf_Time(data.weed_perftime)
		ent:SetPerf_Amount(data.weed_perfamount)
		ent:SetPerf_THC(data.weed_perfthc)
		ent:SetWeedName(data.weed_name)
	end,
	OnItemDataName = function(data, ent) return ent:GetWeedName() end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.weed_id == data.weed_id and compared_item.extraData.weed_name == data.weed_name and compared_item.extraData.weed_amount == data.weed_amount end,
	BlockItemCheck = function(other, Machine) return other:GetWeedAmount() <= 0 end,
})

zvm.Definition.Add("zwf_edibles", {
	OnItemDataCatch = function(data, ent)
		data.weed_id = ent.WeedID
		data.weed_amount = ent.WeedAmount
		data.weed_thc = ent.WeedTHC
		data.weed_name = ent.WeedName
		data.muffin_color = ent:GetColor()
		data.muffin_skin = ent:GetSkin()
		data.EdibleID = ent.EdibleID
	end,
	OnItemDataApply = function(data, ent)
		ent.EdibleID = data.EdibleID
		ent.WeedID = data.weed_id
		ent.WeedAmount = data.weed_amount
		ent.WeedTHC = data.weed_thc
		ent.WeedName = data.weed_name
		ent:SetColor(data.muffin_color)
		ent:SetSkin(data.muffin_skin)

		if ent.EdibleID and zwf.config.Cooking.edibles[ ent.EdibleID ] and zwf.config.Cooking.edibles[ ent.EdibleID ].edible_model then
			ent:SetModel(zwf.config.Cooking.edibles[ ent.EdibleID ].edible_model)
		end
	end,
	OnItemDataName = function(data, ent)
		if ent.WeedID ~= -1 then
			return ent.WeedName
		else
			return zwf.config.Cooking.edibles[ ent.EdibleID ].name
		end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.weed_id == data.weed_id and compared_item.extraData.weed_name == data.weed_name and compared_item.extraData.weed_amount == data.weed_amount end,
})

zvm.Definition.Add("zwf_joint_ent", {
	OnItemDataCatch = function(data, ent)
		data.weed_amount = ent:GetWeed_Amount()
		data.weed_id = ent:GetWeedID()
		data.weed_thc = ent:GetWeed_THC()
		data.weed_name = ent:GetWeed_Name()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetWeed_Amount(data.weed_amount)
		ent:SetWeedID(data.weed_id)
		ent:SetWeed_THC(data.weed_thc)
		ent:SetWeed_Name(data.weed_name)
	end,
	OnItemDataName = function(data, ent) return ent:GetWeed_Name() end,
	BlockItemCheck = function(other, Machine) return other:GetIsBurning() end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.weed_id == data.weed_id and compared_item.extraData.weed_name == data.weed_name and compared_item.extraData.weed_amount == data.weed_amount end,
})

zvm.Definition.Add("zwf_weedblock", {
	OnItemDataCatch = function(data, ent)
		data.weed_amount = ent:GetWeedAmount()
		data.weed_id = ent:GetWeedID()
		data.weed_thc = ent:GetTHC()
		data.weed_name = ent:GetWeedName()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetWeedAmount(data.weed_amount)
		ent:SetWeedID(data.weed_id)
		ent:SetTHC(data.weed_thc)
		ent:SetWeedName(data.weed_name)
	end,
	OnItemDataName = function(data, ent) return ent:GetWeedName() end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.weed_id == data.weed_id and compared_item.extraData.weed_name == data.weed_name and compared_item.extraData.weed_amount == data.weed_amount and compared_item.extraData.weed_thc == data.weed_thc end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

zvm.AllowedItems.Add("zwf_generator")
zvm.AllowedItems.Add("zwf_fuel")
zvm.AllowedItems.Add("zwf_lamp") // Has CustomData
zvm.AllowedItems.Add("zwf_autopacker")
zvm.AllowedItems.Add("zwf_drystation")
zvm.AllowedItems.Add("zwf_pot")
zvm.AllowedItems.Add("zwf_pot_hydro")
zvm.AllowedItems.Add("zwf_packingstation")
zvm.AllowedItems.Add("zwf_seed_bank")
zvm.AllowedItems.Add("zwf_splice_lab")
zvm.AllowedItems.Add("zwf_soil")
zvm.AllowedItems.Add("zwf_ventilator")
zvm.AllowedItems.Add("zwf_watertank")
zvm.AllowedItems.Add("zwf_palette")
zvm.AllowedItems.Add("zwf_outlet")
zvm.AllowedItems.Add("zwf_seed") // Has CustomData
zvm.AllowedItems.Add("zwf_bong01_ent")
zvm.AllowedItems.Add("zwf_bong02_ent")
zvm.AllowedItems.Add("zwf_bong03_ent")
zvm.AllowedItems.Add("zwf_doobytable")
zvm.AllowedItems.Add("zwf_mixer")
zvm.AllowedItems.Add("zwf_backmix")
zvm.AllowedItems.Add("zwf_oven")

zvm.AllowedItems.Add("zwf_jar") // Has CustomData
zvm.AllowedItems.Add("zwf_edibles") // Has CustomData
zvm.AllowedItems.Add("zwf_joint_ent") // Has CustomData
zvm.AllowedItems.Add("zwf_weedblock") // Has CustomData

zvm.AllowedItems.Add("zwf_shoptablet")
zvm.AllowedItems.Add("zwf_cable")
zvm.AllowedItems.Add("zwf_wateringcan")

zclib.RenderData.Add("zwf_seed_bank", {ang = Angle(0, 180, 0)})
zclib.RenderData.Add("zwf_seed", {ang = Angle(0, 0, -90)})
zclib.RenderData.Add("zwf_nutrition", {ang = Angle(0, 90, 0)})
zclib.RenderData.Add("zwf_jar", {pos = Vector(-35,-35,-15)})

local zwf_entTable = {
    ["zwf_autopacker"] = true,
    ["zwf_ventilator"] = true,
    ["zwf_outlet"] = true,
    ["zwf_pot"] = true,
    ["zwf_pot_hydro"] = true,
    ["zwf_soil"] = true,
    ["zwf_watertank"] = true,
    ["zwf_drystation"] = true,
    ["zwf_fuel"] = true,
    ["zwf_generator"] = true,
    ["zwf_lamp"] = true,
    ["zwf_packingstation"] = true,
    ["zwf_splice_lab"] = true,
    ["zwf_seed_bank"] = true,
    ["zwf_palette"] = true,
    ["zwf_doobytable"] = true,
    ["zwf_mixer"] = true,
    ["zwf_backmix"] = true,
    ["zwf_oven"] = true,
    ["zwf_edibles"] = true,
    ["zwf_jar"] = true,
    ["zwf_nutrition"] = true,
    ["zwf_joint_ent"] = true,
    ["zwf_weedblock"] = true,
}
hook.Add("zvm_OnPackageItemSpawned", "zvm_OnPackageItemSpawned_ZerosGrowOP", function(ply, ent,extradata)
    if zwf and zwf_entTable[ent:GetClass()] then
        zwf.f.SetOwner(ent, ply)
    end
end)

zclib.Snapshoter.SetPath("zwf_edibles", function(ItemData) return "zwf/edible_" .. ItemData.extraData.weed_id end)
zclib.Snapshoter.SetPath("zwf_nutrition", function(ItemData) return "zwf/nut_" .. ItemData.extraData.nutid end)
zclib.Snapshoter.SetPath("zwf_seed", function(ItemData) return "zwf/seed_" .. ItemData.extraData.seedid end)
zclib.Snapshoter.SetPath("zwf_weedblock", function(ItemData) return "zwf/weedblock_" .. ItemData.extraData.weed_id end)
zclib.Snapshoter.SetPath("zwf_jar", function(ItemData) return "zwf/jar_" .. ItemData.extraData.weed_id end)

hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosGrowOP", function(cEnt, ItemData)
    if zwf then
        if ItemData.class == "zwf_jar" and ItemData.extraData and ItemData.extraData.weed_id and ItemData.extraData.weed_amount then

            local weed_id = ItemData.extraData.weed_id
            local PlantData = zwf.config.Plants[weed_id]
            if PlantData then
                ItemData.model_skin = PlantData.skin
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

            ItemData.model = "models/zerochain/props_weedfarm/zwf_weedstick.mdl"
            zclib.CacheModel("models/zerochain/props_weedfarm/zwf_weedstick.mdl")
            cEnt:SetModel("models/zerochain/props_weedfarm/zwf_weedstick.mdl")
        elseif ItemData.class == "zwf_weedblock" and ItemData.extraData and ItemData.extraData.weed_id and ItemData.extraData.weed_amount then
            local weed_id = ItemData.extraData.weed_id
            local PlantData = zwf.config.Plants[weed_id]
            if PlantData then
                ItemData.model_skin = PlantData.skin
            end
        end
    end
end)
