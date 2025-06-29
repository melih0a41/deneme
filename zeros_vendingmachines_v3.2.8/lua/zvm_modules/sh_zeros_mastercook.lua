/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros MasterCook
//https://www.gmodstore.com/market/view/zero-s-genlab-disease-script
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

zvm.AllowedItems.Add("zmc_buildkit")
zvm.AllowedItems.Add("zmc_gastank")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

zclib.RenderData.Add("zmc_buildkit", {
	ang = Angle(0, 270, 0)
})

zclib.RenderData.Add("zmc_gastank", {
	ang = Angle(0, 270, 0)
})

zvm.Definition.Add("zmc_item", {
	OnItemDataCatch = function(data, ent)
		data.ItemID = ent:GetItemID()
		data.IsRotten = ent:GetIsRotten()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetItemID(data.ItemID)
		ent:SetIsRotten(data.IsRotten)
		zmc.Item.UpdateVisual(ent, zmc.Item.GetData(data.ItemID), true)
	end,
	OnItemDataName = function(data, ent) return zmc.Item.GetName(data.ItemID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.ItemID == data.ItemID end,
	BlockItemCheck = function(other, Machine) return other:GetIsRotten() end,
})

zvm.Definition.Add("zmc_dish", {
	OnItemDataCatch = function(data, ent)
		data.DishID = ent:GetDishID()
		data.EatProgress = ent.EatProgress
	end,
	OnItemDataApply = function(data, ent)
		local DishData = zmc.Dish.GetData(data.DishID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

		if DishData and DishData.mdl then
			ent:SetModel(DishData.mdl)
		end

		ent:SetDishID(data.DishID)
		ent.EatProgress = data.EatProgress
	end,
	OnItemDataName = function(data, ent) return zmc.Dish.GetName(data.DishID) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.DishID == data.DishID end,
	BlockItemCheck = function(ent, Machine)
		local DishData = zmc.Dish.GetData(ent:GetDishID())
		if DishData == nil then return true end
		if DishData.items == nil then return true end
		local foodCount = table.Count(DishData.items)
		if ent:GetEatProgress() ~= -1 and ent:GetEatProgress() ~= foodCount then return true end
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zclib.Snapshoter.SetPath("zmc_item", function(ItemData) return "zmcook/items/" .. ItemData.extraData.ItemID end)
zclib.Snapshoter.SetPath("zmc_dish", function(ItemData) return "zmcook/dishs/" .. ItemData.extraData.DishID end)

hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosMasterCook", function(cEnt, ItemData)
	-- Lets add the food on the plates before rendering
	if zmc and ItemData.class == "zmc_dish" and ItemData.extraData and ItemData.extraData.DishID then
		local data = zmc.Dish.GetData(ItemData.extraData.DishID)

		if data then
			zmc.Dish.DrawFoodItems(cEnt, data, nil, nil, false, true)
		end
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc
