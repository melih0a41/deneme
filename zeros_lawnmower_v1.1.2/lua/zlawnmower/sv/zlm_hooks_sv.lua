/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if not SERVER then return end
zlm = zlm or {}
zlm.f = zlm.f or {}

// Here are some Hooks you can use for Custom Code
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

// Called when the player mowes grass
hook.Add("zlm_OnGrassMowed", "zlm_OnGrassMowed_Vrondakis", function(ply, tractor)
    if IsValid(ply) and zlm.config.VrondakisLevelSystem then
        ply:addXP(zlm.config.Vrondakis["Mowing"].XP, " ", true)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389


// Called when the player sells grassrolls
hook.Add("zlm_OnGrassRollSold", "zlm_OnGrassRollSold_Vrondakis", function(ply, GrassRollCount, erning,npc)
    // Vrondakis
    if IsValid(ply) and zlm.config.VrondakisLevelSystem then
        ply:addXP(zlm.config.Vrondakis["Selling"].XP * GrassRollCount, " ", true)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad
