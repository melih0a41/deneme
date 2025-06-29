/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
// Darkrp weapons
zvm.config.PredefinedNames["weapon_ak47custom"] = "AK47"
zvm.config.PredefinedNames["weapon_ak472"] = "AK47"
zvm.config.PredefinedNames["weapon_deagle2"] = "Deagle"
zvm.config.PredefinedNames["weapon_fiveseven2"] = "FiveSeven"
zvm.config.PredefinedNames["weapon_glock2"] = "Glock"
zvm.config.PredefinedNames["weapon_m42"] = "M4"
zvm.config.PredefinedNames["weapon_mac102"] = "Mac10"
zvm.config.PredefinedNames["weapon_mp52"] = "MP5"
zvm.config.PredefinedNames["weapon_p2282"] = "P228"
zvm.config.PredefinedNames["weapon_pumpshotgun2"] = "Pump Shotgun"
zvm.config.PredefinedNames["ls_sniper"] = "Silenced Sniper"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

zvm.Definition.Add("spawned_shipment", {
	OnItemDataCatch = function(data, ent)
		local contents = ent:Getcontents()
		data.Ammount = ent:Getcount()
		data.contents = contents
	end,
	OnItemDataApplyPreSpawn = function(data, ent)
		ent:SetContents(data.contents, data.Ammount)
	end,
	OnItemDataName = function(data, ent)
		local contents = CustomShipments[ data.contents ]
		if contents.name then return contents.name .. " [" .. data.Ammount .. "x]" end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.contents == data.contents and compared_item.extraData.Ammount == data.Ammount end,
})

zvm.Definition.Add("spawned_ammo", {
	OnItemDataCatch = function(data, ent)
		data.amountGiven = ent.amountGiven
		data.ammoType = ent.ammoType
	end,
	OnItemDataApplyPreSpawn = function(data, ent)
		ent.amountGiven = data.amountGiven
		ent.ammoType = data.ammoType
	end,
	OnItemDataName = function(data, ent) return ent.ammoType .. " [" .. ent.amountGiven .. "x]" end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.ammoType == data.ammoType and compared_item.extraData.amountGiven == data.amountGiven end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zvm.Definition.Add("spawned_food", {
	OnItemDataCatch = function(data, ent)
		data.foodItem = ent.foodItem
	end,
	OnItemDataApplyPreSpawn = function(data, ent)
		ent.foodItem = data.foodItem
		ent.FoodEnergy = data.foodItem.energy
	end,
	OnItemDataName = function(data, ent)
		if data.foodItem and data.foodItem.name then return data.foodItem.name end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.foodItem.model == data.foodItem.model end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

zvm.Definition.Add("spawned_weapon", {
	OnItemDataCatch = function(data, ent)
		data.WeaponClass = ent:GetWeaponClass()
	end,
	OnItemDataApplyPreSpawn = function(data, ent)
		ent:SetWeaponClass(data.WeaponClass)
	end,
	OnItemDataName = function(data, ent) return ent:GetWeaponClass() end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.WeaponClass == data.WeaponClass end,
})
