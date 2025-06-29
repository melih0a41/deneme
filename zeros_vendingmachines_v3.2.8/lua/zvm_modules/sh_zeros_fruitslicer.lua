/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
// Zeros Fruitlsicer
// https://www.gmodstore.com/market/view/4965

zvm.Definition.Add("zfs_smoothie", {
	OnItemDataCatch = function(data, ent)
		data.ProductID = ent:GetProductID()
		data.ToppingID = ent:GetToppingID()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetProductID(data.ProductID)
		ent:SetToppingID(data.ToppingID)
		zfs.Smoothie.Visuals(ent)
	end,
	OnItemDataName = function(data, ent)
		local name = "Unkown"
		local pData = zfs.Smoothie.GetData(ent:GetProductID())

		if pData then
			name = pData.Name
		end

		local tData = zfs.Topping.GetData(ent:GetToppingID())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

		if tData and ent:GetToppingID() > 1 then
			name = name .. " [" .. tData.Name .. "]"
		end

		return name
	end,
	OnItemDataPrice = function(ent, data)
		if ent.Price then
			return ent.Price
		else
			local pData = zfs.Smoothie.GetData(ent:GetProductID())
			local tData = zfs.Topping.GetData(ent:GetToppingID())
			local PriceBoni = zfs.Smoothie.GetFruitVarationBoni(ent:GetProductID()) * zfs.config.Price.FruitMultiplicator
			local FruitVariationCharge = math.Round(pData.Price * PriceBoni)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

			return FruitVariationCharge + tData.ExtraPrice
		end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.ProductID == data.ProductID and compared_item.extraData.ToppingID == data.ToppingID end,
})

zvm.Definition.Add("zfs_fruitbox", {
	OnItemDataCatch = function(data, ent)
		data.FruitID = ent:GetFruitID()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetFruitID(data.FruitID)
	end,
	OnItemDataName = function(data, ent)
		local dat = zfs.Fruit.GetData(ent:GetFruitID())

		return dat.Name or "Unknown"
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.FruitID == data.FruitID end,
})

zclib.Snapshoter.SetPath("zfs_fruitbox", function(ItemData)
	if ItemData.extraData then return "zfs/fruits/zfs_fruitbox_" .. ItemData.extraData.FruitID end
end)

zclib.Snapshoter.SetPath("zfs_smoothie", function(ItemData)
	if ItemData.extraData then return "zfs/smoothies/zfs_smoothie_" .. ItemData.extraData.ProductID .. "_" .. ItemData.extraData.ToppingID end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosFruitlsicer", function(cEnt, ItemData)
	if zfs and ItemData.class == "zfs_smoothie" then
		zclib.CacheModel("models/zerochain/fruitslicerjob/fs_fruitcup.mdl")
		local pData = zfs.Smoothie.GetData(ItemData.extraData.ProductID)
		local tData = zfs.Topping.GetData(ItemData.extraData.ToppingID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

		if pData and tData then
			cEnt:SetBodygroup(0, 1)
			cEnt:SetColor(zfs.Smoothie.GetColor(ItemData.extraData.ProductID))

			if tData.Model then
				zclib.CacheModel(tData.Model)
				-- Create topping model
				local client_mdl = zclib.ClientModel.Add(tData.Model, RENDERGROUP_BOTH)

				if IsValid(client_mdl) then
					client_mdl:SetModel(string.lower(tData.Model))
					local ang = cEnt:GetAngles()
					ang:RotateAroundAxis(cEnt:GetUp(), 90)
					client_mdl:SetAngles(ang)
					local pos = cEnt:GetPos() + cEnt:GetUp() * 10
					client_mdl:SetPos(pos)
					client_mdl:SetParent(cEnt)
					client_mdl:SetModelScale(tData.mScale)

					render.Model({
						model = string.lower(tData.Model),
						pos = pos,
						angle = ang
					}, client_mdl)

					cEnt:CallOnRemove("zfs_remove_render_topping_" .. cEnt:EntIndex(), function(ent)
						zclib.ClientModel.Remove(client_mdl)
					end)
				end
			end
		end
	end
end)

hook.Add("zclib_PostRenderProductImage", "zclib_PostRenderProductImage_ZerosFruitlsicer", function(cEnt, ItemData)
	if zfs and ItemData.class == "zfs_fruitbox" then
		zclib.CacheModel("models/zerochain/fruitslicerjob/fs_cardboardbox.mdl")
		cam.Start3D2D(cEnt:LocalToWorld(Vector(0, 0, 16.5)), cEnt:LocalToWorldAngles(Angle(0, 180, 0)), 0.2)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zfs.Fruit.GetIcon(ItemData.extraData.FruitID))
			surface.DrawTexturedRect(-50, -50, 100, 100)
		cam.End3D2D()
	end
end)
