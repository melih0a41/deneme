/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(10)
ITEM:SetModel("models/zerochain/props_trashman/ztm_recycleblock.mdl")
ITEM:SetDescription("A block of recycled trash.")

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

	ent:SetRecycleType(data.RecycleType)

	zclib.Player.SetOwner(ent, ply)
end)

function ITEM:CanStack(newItem, invItem)
	local ent = isentity(newItem)
	local RecycleType = ent and newItem:GetRecycleType() or newItem.data.RecycleType
	return RecycleType == invItem.data.RecycleType
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ITEM:GetData(ent)
	return {
		RecycleType = ent:GetRecycleType(),
	}
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

function ITEM:GetName(item)
	local ent = isentity(item)
	local RecycleType = ent and item:GetRecycleType() or item.data.RecycleType
	local trash_name = ztm.config.Recycler.recycle_types[RecycleType].name
	return trash_name
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, -190, 0),
		Pos = Vector(0, 0, -1)
	}
end

function ITEM:GetClientsideModel(tbl, mdlPanel)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	local RecycleType = tbl.data.RecycleType
	local _recycle_type = ztm.config.Recycler.recycle_types[RecycleType]

	mdlPanel.Entity:SetMaterial( _recycle_type.mat, true )
end

ITEM:Register("ztm_recycled_block")
