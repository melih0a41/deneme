/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_trashman/ztm_trashbag.mdl")
ITEM:SetDescription("A bag of trash.")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	local data = tbl.data
	ent:SetTrash(data.Trash)
	zclib.Player.SetOwner(ent, ply)
end)

function ITEM:GetData(ent)
	return {
		Trash = ent:GetTrash()
	}
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	local ent = isentity(item)
	local trash = ent and item:GetTrash() or item.data.Trash
	local name = "Trashbag " .. "[ " .. trash .. ztm.config.UoW .. " ]"

	return name
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

ITEM:Register("ztm_trashbag")
