/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

local ITEM = BRICKS_SERVER.Func.CreateItemType("ztm_recycled_block")

ITEM.GetItemData = function(ent)
    if (not IsValid(ent)) then return end
    local itemData = {"ztm_recycled_block", "models/zerochain/props_trashman/ztm_recycleblock.mdl",ent:GetRecycleType()}

    return itemData, 1
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

ITEM.OnSpawn = function(ply, pos, itemData, itemAmount)
    local ent = ents.Create("ztm_recycled_block")
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
	ent:SetRecycleType(itemData[3])
	zclib.Player.SetOwner(ent, ply)
end

ITEM.GetInfo = function(itemData)

	local trash_name = ztm.config.Recycler.recycle_types[itemData[3]].name
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

    return {trash_name, "A block of recycled trash.", ""}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

ITEM.ModelDisplay = function(Panel, itemtable)
    if (not Panel.Entity or not IsValid(Panel.Entity)) then return end
    local mn, mx = Panel.Entity:GetRenderBounds()
    local size = 0
    size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
    size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
    size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
    Panel:SetFOV(20)
    Panel:SetCamPos(Vector(size, size * 3, size * 2))
    Panel:SetLookAt((mn + mx) * 0.5)
    Panel.Entity:SetAngles(Angle(0, -45, 0))

	local RecycleType = itemtable[3]
	local _recycle_type = ztm.config.Recycler.recycle_types[RecycleType]
	if _recycle_type and _recycle_type.mat then
		Panel.Entity:SetMaterial(_recycle_type.mat, true)
	end
end

ITEM.CanCombine = function(itemData1, itemData2) return false end
ITEM:Register()

if BRICKS_SERVER and BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.INVENTORY and BRICKS_SERVER.CONFIG.INVENTORY.Whitelist then
    BRICKS_SERVER.CONFIG.INVENTORY.Whitelist["ztm_recycled_block"] = {false, true}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381
