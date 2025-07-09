/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if not SERVER then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

local entTable = {
    ["ztm_trashburner"] = true,
    ["ztm_recycler"] = true,
}

hook.Add("playerBoughtCustomEntity", "a_ztm_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    if entTable[ent:GetClass()] then
        zclib.Player.SetOwner(ent, ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

hook.Add("BaseWars_PlayerBuyEntity", "a_ztm_basewars_SetOwnerOnEntBuy", function(ply, ent)
    if entTable[ent:GetClass()] then
        zclib.Player.SetOwner(ent, ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
