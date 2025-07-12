/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if not SERVER then return end

local entTable = {
    ["zlm_grasspress"] = true,
    ["zlm_tractor"] = true,
    ["zlm_tractor_trailer"] = true
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

hook.Add("BaseWars_PlayerBuyEntity", "a_zlm_basewars_SetOwnerOnEntBuy", function(ply, ent)
    if entTable[ent:GetClass()] then
        zlm.f.SetOwner(ent, ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

hook.Add("playerBoughtCustomEntity", "a_zlm_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    if entTable[ent:GetClass()] then
        zlm.f.SetOwner(ent, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

        if ent:GetClass() == "zlm_tractor" and IsValid(ent.Vehicle) then
            ent.Vehicle:keysOwn(ply)
        end
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
