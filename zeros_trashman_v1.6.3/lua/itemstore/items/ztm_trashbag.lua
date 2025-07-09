/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ITEM.Name = "Trashbag"
ITEM.Description = "A bag of trash."
ITEM.Model = "models/zerochain/props_trashman/ztm_trashbag.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = "Trashbag " .. "[ " .. self:GetData("Trash") .. ztm.config.UoW .. " ]"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

	return self:GetData("Name", name)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

function ITEM:SaveData(ent)
	self:SetData("Trash", ent:GetTrash())
end

function ITEM:LoadData(ent)
	ent:SetTrash(self:GetData("Trash"))
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ITEM:Drop(ply, container,slot,ent)
	if ztm.Trashbag.GetCountByPlayer(ply) >= ztm.config.Trashbags.limit then
		ply:PickupItem( ent )
		zclib.Notify(ply, ztm.language.General["TrashbagLimit"], 1)
	else
		zclib.Player.SetOwner(ent, ply)
		ent:SetPos(ent:GetPos() + Vector(0,0,20))
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
