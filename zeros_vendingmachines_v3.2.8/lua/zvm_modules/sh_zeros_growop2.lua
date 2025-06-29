/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros GrowOP2
//https://www.gmodstore.com/market/view/zero-s-growop-2-weed-script

zvm.AllowedItems.Add("zgo2_clipper")
zvm.AllowedItems.Add("zgo2_crate")
zvm.AllowedItems.Add("zgo2_doobytable")
zvm.AllowedItems.Add("zgo2_dryline")
zvm.AllowedItems.Add("zgo2_packer")
zvm.AllowedItems.Add("zgo2_pump")
zvm.AllowedItems.Add("zgo2_splicer")
zvm.AllowedItems.Add("zgo2_battery")
zvm.AllowedItems.Add("zgo2_bulb")
zvm.AllowedItems.Add("zgo2_fuel")
zvm.AllowedItems.Add("zgo2_jarcrate")
zvm.AllowedItems.Add("zgo2_logbook")
zvm.AllowedItems.Add("zgo2_motor")
zvm.AllowedItems.Add("zgo2_palette")
zvm.AllowedItems.Add("zgo2_soil")

zvm.Definition.Add("zgo2_generator", {
	OnItemDataCatch = function(data, ent) data.GeneratorID = zgo2.Generator.GetID(ent:GetGeneratorID()) end,
	OnItemDataApply = function(data, ent) ent:SetGeneratorID(zgo2.Generator.GetListID(data.GeneratorID)) end,
	OnItemDataName = function(data, ent) return zgo2.Generator.GetName(data.GeneratorID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.GeneratorID == data.GeneratorID end,
})

zvm.Definition.Add("zgo2_lamp", {
	OnItemDataCatch = function(data, ent) data.LampID = zgo2.Lamp.GetID(ent:GetLampID()) end,
	OnItemDataApply = function(data, ent) ent:SetLampID(zgo2.Lamp.GetListID(data.LampID)) end,
	OnItemDataName = function(data, ent) return zgo2.Lamp.GetName(data.LampID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.LampID == data.LampID end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

zvm.Definition.Add("zgo2_pot", {
	OnItemDataCatch = function(data, ent) data.PotID = zgo2.Pot.GetID(ent:GetPotID()) end,
	OnItemDataApply = function(data, ent) ent:SetPotID(zgo2.Pot.GetListID(data.PotID)) end,
	OnItemDataName = function(data, ent) return zgo2.Pot.GetName(data.PotID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.PotID == data.PotID end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

zvm.Definition.Add("zgo2_rack", {
	OnItemDataCatch = function(data, ent) data.RackID = zgo2.Rack.GetID(ent:GetRackID()) end,
	OnItemDataApply = function(data, ent) ent:SetRackID(zgo2.Rack.GetListID(data.RackID)) end,
	OnItemDataName = function(data, ent) return zgo2.Rack.GetName(data.RackID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.RackID == data.RackID end,
})

zvm.Definition.Add("zgo2_seed", {
	OnItemDataCatch = function(data, ent)
		data.PlantID = zgo2.Plant.GetID(ent:GetPlantID())
		data.Count = ent:GetCount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetPlantID(zgo2.Plant.GetListID(data.PlantID))
		ent:SetCount(data.Count)
	end,
	OnItemDataName = function(data, ent) return zgo2.Plant.GetName(data.PlantID) .. " x"..data.Count end,
	ItemExists = function(compared_item, data) return true, compared_item.data.PlantID == data.PlantID and compared_item.data.Count == data.Count end
})

zvm.Definition.Add("zgo2_tent", {
	OnItemDataCatch = function(data, ent) data.TentID = zgo2.Tent.GetID(ent:GetTentID())end,
	OnItemDataApply = function(data, ent) ent:SetTentID(zgo2.Tent.GetListID(data.TentID)) end,
	OnItemDataName = function(data, ent) return zgo2.Tent.GetName(data.TentID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.TentID == data.TentID end,
})

zvm.Definition.Add("zgo2_watertank", {
	OnItemDataCatch = function(data, ent) data.WatertankID = zgo2.Watertank.GetID(ent:GetWatertankID()) end,
	OnItemDataApply = function(data, ent) ent:SetWatertankID(zgo2.Watertank.GetListID(data.WatertankID)) end,
	OnItemDataName = function(data, ent) return zgo2.Watertank.GetName(data.WatertankID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.WatertankID == data.WatertankID end,
})

zvm.Definition.Add("zgo2_joint_ent", {
	OnItemDataCatch = function(data, ent)
		data.WeedID = zgo2.Plant.GetID(ent:GetWeedID())
		data.WeedTHC = ent:GetWeedTHC()
		data.WeedAmount = ent:GetWeedAmount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetWeedID(zgo2.Plant.GetListID(data.WeedID))
		ent:SetWeedTHC(data.WeedTHC)
		ent:SetWeedAmount(data.WeedAmount)
	end,
	OnItemDataName = function(data, ent) return zgo2.Plant.GetName(data.WeedID) end,
	ItemExists = function(compared_item, data)
		return true, compared_item.extraData.WeedID == data.WeedID and compared_item.extraData.WeedTHC == data.WeedTHC and compared_item.extraData.WeedAmount == data.WeedAmount
	end,

	ItemUnpackOverwrite = function(ply, Crate, itemdata)
		if not zgo2.Plant.IsValid(itemdata.extraData.WeedID) then
			zclib.Notify(ply, zgo2.language[ "InvalidPlantData" ], 1)
			return true
		end
	end
})

zvm.Definition.Add("zgo2_baggy", {
	OnItemDataCatch = function(data, ent)
		data.WeedID = zgo2.Plant.GetID(ent:GetWeedID())
		data.WeedTHC = ent:GetWeedTHC()
		data.WeedAmount = ent:GetWeedAmount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetWeedID(zgo2.Plant.GetListID(data.WeedID))
		ent:SetWeedTHC(data.WeedTHC)
		ent:SetWeedAmount(data.WeedAmount)
	end,
	OnItemDataName = function(data, ent) return zgo2.Plant.GetName(data.WeedID) .. " " .. data.WeedAmount .. zgo2.config.UoM .. " " .. data.WeedTHC .. "%" end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.WeedID == data.WeedID and compared_item.extraData.WeedTHC == data.WeedTHC and compared_item.extraData.WeedAmount == data.WeedAmount end,
	ItemUnpackOverwrite = function(ply, Crate, itemdata)
		if not zgo2.Plant.IsValid(itemdata.extraData.WeedID) then
			zclib.Notify(ply, zgo2.language[ "InvalidPlantData" ], 1)
			return true
		end
	end
})

zvm.Definition.Add("zgo2_jar", {
	OnItemDataCatch = function(data, ent)
		data.WeedID = zgo2.Plant.GetID(ent:GetWeedID())
		data.WeedTHC = ent:GetWeedTHC()
		data.WeedAmount = ent:GetWeedAmount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetWeedID(zgo2.Plant.GetListID(data.WeedID))
		ent:SetWeedTHC(data.WeedTHC)
		ent:SetWeedAmount(data.WeedAmount)
	end,
	OnItemDataName = function(data, ent) return zgo2.Plant.GetName(data.WeedID) .. " " .. data.WeedAmount .. zgo2.config.UoM .. " " .. data.WeedTHC .. "%" end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.WeedID == data.WeedID and compared_item.extraData.WeedTHC == data.WeedTHC and compared_item.extraData.WeedAmount == data.WeedAmount end,
	ItemUnpackOverwrite = function(ply, Crate, itemdata)
		if not zgo2.Plant.IsValid(itemdata.extraData.WeedID) then
			zclib.Notify(ply, zgo2.language[ "InvalidPlantData" ], 1)
			return true
		end
	end
})

zvm.Definition.Add("zgo2_weedblock", {
	OnItemDataCatch = function(data, ent)
		data.WeedID = zgo2.Plant.GetID(ent:GetWeedID())
	end,
	OnItemDataApply = function(data, ent)
		ent:SetWeedID(zgo2.Plant.GetListID(data.WeedID))
	end,
	OnItemDataName = function(data, ent) return zgo2.Plant.GetName(data.WeedID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.WeedID == data.WeedID end,
	ItemUnpackOverwrite = function(ply, Crate, itemdata)
		if not zgo2.Plant.IsValid(itemdata.extraData.WeedID) then
			zclib.Notify(ply, zgo2.language[ "InvalidPlantData" ], 1)
			return true
		end
	end
})

zvm.Definition.Add("zgo2_weedbranch", {
	OnItemDataCatch = function(data, ent)
		data.WeedID = zgo2.Plant.GetID(ent:GetPlantID())
		data.WeedAmount = ent.WeedAmount
		data.WeedTHC = ent.WeedTHC
		data.IsDried = ent:GetIsDried()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetPlantID(zgo2.Plant.GetListID(data.WeedID))
		ent.WeedAmount = data.WeedAmount
		ent.WeedTHC = data.WeedTHC
		ent:SetIsDried(data.IsDried)
	end,
	OnItemDataName = function(data, ent) return zgo2.Plant.GetName(data.WeedID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.WeedID == data.WeedID and compared_item.extraData.WeedTHC == data.WeedTHC and compared_item.extraData.IsDried == data.IsDried end,

	ItemUnpackOverwrite = function(ply, Crate, itemdata)
		if not zgo2.Plant.IsValid(itemdata.extraData.WeedID) then
			zclib.Notify(ply, zgo2.language[ "InvalidPlantData" ], 1)
			return true
		end
	end
})

zvm.Definition.Add("zgo2_bong", {
	OnItemDataCatch = function(data, ent) data.BongID = zgo2.Bong.GetID(ent:GetBongID())end,
	OnItemDataApply = function(data, ent) ent:SetBongID(zgo2.Bong.GetListID(data.BongID)) end,
	OnItemDataName = function(data, ent) return zgo2.Bong.GetName(data.BongID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.BongID == data.BongID end,
})

if CLIENT then

	zclib.Snapshoter.SetPath("zgo2_weedbranch", function(ItemData)
		if ItemData.extraData and ItemData.extraData.WeedID then return "zgo2/weedbranch_" .. ItemData.extraData.WeedID end
		if ItemData.WeedID then return "zgo2/weedbranch_" .. ItemData.WeedID end
	end)


	zclib.Snapshoter.SetPath("zgo2_jar", function(ItemData)
		if ItemData.extraData and ItemData.extraData.WeedID then return "zgo2/jar_" .. ItemData.extraData.WeedID end
		if ItemData.WeedID then return "zgo2/jar_" .. ItemData.WeedID end
	end)

	zclib.Snapshoter.SetPath("zgo2_weedblock", function(ItemData)
		if ItemData.extraData and ItemData.extraData.WeedID then return "zgo2/weedblock_" .. ItemData.extraData.WeedID end
		if ItemData.WeedID then return "zgo2/weedblock_" .. ItemData.WeedID end
	end)

	zclib.Snapshoter.SetPath("zgo2_bong", function(ItemData)
		if ItemData.extraData and ItemData.extraData.BongID then return "zgo2/bong_" .. ItemData.extraData.BongID end
		if ItemData.BongID then return "zgo2/bong_" .. ItemData.BongID end
	end)

	zclib.Snapshoter.SetPath("zgo2_pot", function(ItemData)
		if ItemData.extraData and ItemData.extraData.PotID then return "zgo2/pot_" .. ItemData.extraData.PotID end
		if ItemData.PotID then return "zgo2/pot_" .. ItemData.PotID end
	end)

	zclib.Snapshoter.SetPath("zgo2_baggy", function(ItemData)
		if ItemData.extraData and ItemData.extraData.WeedID then return "zgo2/baggy_" .. ItemData.extraData.WeedID end
		if ItemData.WeedID then return "zgo2/baggy_" .. ItemData.WeedID end
	end)

	zclib.Snapshoter.SetPath("zgo2_joint_ent", function(ItemData)
		if ItemData.extraData and ItemData.extraData.WeedID then return "zgo2/joint_" .. ItemData.extraData.WeedID end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	zclib.Hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_Vendignmachine_zgo2", function(ent, ItemData)
		if ItemData and ItemData.class == "zgo2_jar" and ItemData.extraData and ItemData.extraData.WeedID then
			ent:SetBodygroup(0, 1)
			ent:SetBodygroup(1, 1)
			ent:SetBodygroup(2, 1)
			ent:SetBodygroup(3, 1)
			ent:SetBodygroup(4, 1)
			zgo2.Plant.UpdateMaterial(ent, zgo2.Plant.GetData(ItemData.extraData.WeedID))
		end

		if ItemData and ItemData.class == "zgo2_weedblock" and ItemData.extraData and ItemData.extraData.WeedID then
			zgo2.Plant.UpdateMaterial(ent, zgo2.Plant.GetData(ItemData.extraData.WeedID))
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

		if ItemData and ItemData.class == "zgo2_baggy" and ItemData.extraData and ItemData.extraData.WeedID then
			zgo2.Plant.UpdateMaterial(ent, zgo2.Plant.GetData(ItemData.extraData.WeedID))
		end

		if ItemData and ItemData.class == "zgo2_weedbranch" and ItemData.extraData and ItemData.extraData.WeedID then
			zgo2.Plant.UpdateMaterial(ent, zgo2.Plant.GetData(ItemData.extraData.WeedID))
		end

		if ItemData and ItemData.class == "zgo2_pot" and ItemData.extraData and ItemData.extraData.PotID then
			local data = zgo2.Pot.GetData(ItemData.extraData.PotID)

			if data then
				ent:SetModelScale(data.scale or 1, 0)

				if data.hose then
					ent:SetBodygroup(2, 1)
				end

				zgo2.Pot.ApplyMaterial(ent, data)
			end
		end

		if ItemData and ItemData.class == "zgo2_bong" and ItemData.extraData and ItemData.extraData.BongID then
			zgo2.Bong.ApplyMaterial(ent, zgo2.Bong.GetData(ItemData.extraData.BongID))
		end
	end)
end
