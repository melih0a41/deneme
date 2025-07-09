/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ITEM.Name = "Recycled Trash"
ITEM.Description = "A block of recycled trash."
ITEM.Model = "models/zerochain/props_trashman/ztm_recycleblock.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

function ITEM:GetName()
	local name = ztm.config.Recycler.recycle_types[self:GetData("RecycleType")].name
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

	return self:GetData("Name", name)
end

function ITEM:SaveData(ent)
	self:SetData("RecycleType", ent:GetRecycleType())
end

function ITEM:LoadData(ent)
	ent:SetRecycleType(self:GetData("RecycleType"))
	local _recycle_type = ztm.config.Recycler.recycle_types[ent:GetRecycleType()]

	ent:SetMaterial( _recycle_type.mat, true )
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a
