/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

local ITEM = BRICKS_SERVER.Func.CreateItemType("ztm_trashbag")

ITEM.GetItemData = function(ent)
    if (not IsValid(ent)) then return end
    local itemData = {"ztm_trashbag", "models/zerochain/props_trashman/ztm_trashbag.mdl",ent:GetTrash()}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

    return itemData, 1
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

ITEM.OnSpawn = function(ply, pos, itemData, itemAmount)
    local ent = ents.Create("ztm_trashbag")
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
	ent:SetTrash(itemData[3])
	zclib.Player.SetOwner(ent, ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

ITEM.GetInfo = function(itemData)
    return {"Trashbag", "A bag of trash.", ""}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a


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
end


ITEM.CanCombine = function(itemData1, itemData2) return false end
ITEM:Register()

if BRICKS_SERVER and BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.INVENTORY and BRICKS_SERVER.CONFIG.INVENTORY.Whitelist then
    BRICKS_SERVER.CONFIG.INVENTORY.Whitelist["ztm_trashbag"] = {false, true}
end
