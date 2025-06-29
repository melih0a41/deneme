/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Oilrush
//https://www.gmodstore.com/market/view/5387

zvm.Definition.Add("zrush_barrel", {
	OnItemDataCatch = function(data, ent)
		local oil = ent:GetOil()
		local fuel = ent:GetFuel()
		local FuelTypeID = ent:GetFuelTypeID()

		if oil > 0 then
			data.oil = oil
		elseif fuel > 0 then
			data.fuel = fuel
			data.FuelTypeID = FuelTypeID
		end
	end,
	OnItemDataApply = function(data, ent)
		if data.oil then
			ent:SetOil(data.oil)
		elseif data.fuel then
			ent:SetFuel(data.fuel)
			ent:SetFuelTypeID(data.FuelTypeID)
		end

		zrush.Barrel.UpdateVisual(ent)
	end,
	OnItemDataName = function(data, ent)
		if data.oil then
			return "Oil Barrel"
		elseif data.fuel and data.FuelTypeID then
			local fuelname = zrush.Fuel.GetName(data.FuelTypeID) or "Unkown"

			return fuelname .. " Barrel"
		else
			return "Empty Barrel"
		end
	end,
	ItemExists = function(compared_item, data)
		if data.oil then
			return true, compared_item.extraData.oil == data.oil
		elseif data.fuel then
			return true, compared_item.extraData.fuel == data.fuel and compared_item.extraData.FuelTypeID == data.FuelTypeID
		else
			return true, true
		end
	end
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

zvm.AllowedItems.Add("zrush_machinecrate")
zvm.AllowedItems.Add("zrush_palette")
zvm.AllowedItems.Add("zrush_drillpipe_holder")

zclib.RenderData.Add("zrush_barrel", {pos = Vector(0,0,3)})

zvm.Definition.Add("zrush_palette", {
	BlockItemCheck = function(other, Machine) return other.BarrelCount > 0 end,
})

zvm.Definition.Add("zrush_drillpipe_holder", {
	BlockItemCheck = function(other, Machine) return other:GetPipeCount() < 10 end,
})

zclib.Snapshoter.SetPath("zrush_barrel", function(ItemData)
	if ItemData.extraData then
		if ItemData.extraData.oil and ItemData.extraData.oil > 0 then
			return "zrush/barrel_oil"
		elseif ItemData.extraData.FuelTypeID and ItemData.extraData.fuel and ItemData.extraData.fuel > 0 then
			return "zrush/barrel_fuel_" .. ItemData.extraData.FuelTypeID
		end
	else
		return "zrush/barrel_empty"
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosOilRush", function(cEnt, ItemData)
	if zrush and ItemData.class == "zrush_barrel" then
		if ItemData.extraData then
			if ItemData.extraData.oil then
				cEnt:SetColor(zrush.default_colors[ "grey02" ])
			elseif ItemData.extraData.fuel and ItemData.extraData.FuelTypeID then
				cEnt:SetColor(zrush.FuelTypes[ ItemData.extraData.FuelTypeID ].color)
			else
				cEnt:SetColor(color_white)
			end
		end

		ItemData.model = "models/zerochain/props_oilrush/zor_barrel.mdl"
		zclib.CacheModel("models/zerochain/props_oilrush/zor_barrel.mdl")
		cEnt:SetModel("models/zerochain/props_oilrush/zor_barrel.mdl")
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
