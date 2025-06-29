/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Methlab2
//https://www.gmodstore.com/market/view/zero-s-methlab2-drug-script

zvm.AllowedItems.Add("zmlab2_equipment")

zvm.AllowedItems.Add("zmlab2_item_acid")
zvm.AllowedItems.Add("zmlab2_item_aluminium")
zvm.AllowedItems.Add("zmlab2_item_lox")
zvm.AllowedItems.Add("zmlab2_item_methylamine")

zvm.AllowedItems.Add("zmlab2_item_meth") // Has CustomData
zvm.AllowedItems.Add("zmlab2_item_crate") // Has CustomData
zvm.AllowedItems.Add("zmlab2_item_palette")
zvm.AllowedItems.Add("zmlab2_item_autobreaker")

zvm.AllowedItems.Add("zmlab2_equipment")
zvm.AllowedItems.Add("zmlab2_tent")

zvm.AllowedItems.Add("zmlab2_machine_ventilation")
zvm.AllowedItems.Add("zmlab2_machine_furnace")
zvm.AllowedItems.Add("zmlab2_machine_mixer")
zvm.AllowedItems.Add("zmlab2_machine_filter")
zvm.AllowedItems.Add("zmlab2_machine_filler")
zvm.AllowedItems.Add("zmlab2_machine_frezzer")
zvm.AllowedItems.Add("zmlab2_table")
zvm.AllowedItems.Add("zmlab2_storage")

zclib.RenderData.Add("zmlab2_equipment", {ang = Angle(0, 180, 0)})

local function GetName(extraData)
    local name = zmlab2.Meth.GetName(extraData.meth_type) or "Meth"
    return name .. " " .. extraData.meth_amount .. zmlab2.config.UoM .. " " .. extraData.meth_qual .. "%"
end

zvm.Definition.Add("zmlab2_item_crate", {
	OnItemDataCatch = function(data, ent)
		data.meth_amount = ent:GetMethAmount()
		data.meth_type = ent:GetMethType()
		data.meth_qual = ent:GetMethQuality()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetMethAmount(data.meth_amount)
		ent:SetMethType(data.meth_type)
		ent:SetMethQuality(data.meth_qual)
	end,
	OnItemDataName = function(data, ent)
		if data.meth_amount > 0 then
			return GetName(data)
		else
			return ent.PrintName
		end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.meth_amount == data.meth_amount and compared_item.extraData.meth_type == data.meth_type and compared_item.extraData.meth_qual == data.meth_qual end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

zvm.Definition.Add("zmlab2_item_meth", {
	OnItemDataCatch = function(data, ent)
		data.meth_amount = ent:GetMethAmount()
		data.meth_type = ent:GetMethType()
		data.meth_qual = ent:GetMethQuality()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetMethAmount(data.meth_amount)
		ent:SetMethType(data.meth_type)
		ent:SetMethQuality(data.meth_qual)
	end,
	OnItemDataName = function(data, ent) return GetName(data) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.meth_amount == data.meth_amount and compared_item.extraData.meth_type == data.meth_type and compared_item.extraData.meth_qual == data.meth_qual end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

zvm.Definition.Add("zmlab2_item_palette", {
	BlockItemCheck = function(other, Machine) return table.Count(other.MethList) > 0 end
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa


zclib.Snapshoter.SetPath("zmlab2_item_meth", function(ItemData)
	return "zmlab2/meth/meth_" .. math.Round(ItemData.extraData.meth_type) .. "_" .. math.Round((3 / 100) * ItemData.extraData.meth_qual)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zclib.Snapshoter.SetPath("zmlab2_item_crate", function(ItemData)
    if ItemData.extraData.meth_amount > 0 then return "zmlab2/crate/crate_" .. math.Round(ItemData.extraData.meth_type) .. "_" .. math.Clamp(5 - math.Round((5 / zmlab2.config.Crate.Capacity) * ItemData.extraData.meth_amount), 1, 5) .. "_" .. math.Round((3 / 100) * ItemData.extraData.meth_qual) end
end)

hook.Add("zclib_RenderProductImage", "zclib_RenderProductImage_ZerosMethlab2", function(cEnt, ItemData)
    if zmlab2 then
        if ItemData.class == "zmlab2_item_crate" and ItemData.extraData and ItemData.extraData.meth_amount > 0 then
            local MethMat = zmlab2.Meth.GetMaterial(ItemData.extraData.meth_type, ItemData.extraData.meth_qual)

            if MethMat then
                cEnt:SetSubMaterial(0, "!" .. MethMat)
            end

            local cur_amount = ItemData.extraData.meth_amount
            local bg = math.Clamp(5 - math.Round((5 / zmlab2.config.Crate.Capacity) * cur_amount), 1, 5)
            cEnt:SetBodygroup(0, bg)
        elseif ItemData.class == "zmlab2_item_meth" and ItemData.extraData and ItemData.extraData.meth_amount > 0 then
            local MethMat = zmlab2.Meth.GetMaterial(ItemData.extraData.meth_type, ItemData.extraData.meth_qual)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

            if MethMat then
                //cEnt:SetSubMaterial(0, "!" .. MethMat)
				cEnt:SetMaterial("!" .. MethMat)
            end
        end
    end
end)
