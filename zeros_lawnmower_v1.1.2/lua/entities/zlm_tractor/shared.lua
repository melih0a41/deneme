/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.DisableDuplicator = false
ENT.PrintName = "LawnMower"
ENT.Author = "ZeroChain"
ENT.Category = "Zeros LawnMowerman"
ENT.Spawnable = true
ENT.AdminSpawnable = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsRunning")
    self:NetworkVar("Bool", 1, "IsMowing")
    self:NetworkVar("Bool", 2, "IsUnloading")
    self:NetworkVar("Bool", 3, "HasCorb")
    self:NetworkVar("Bool", 4, "HasTrailer")
    self:NetworkVar("Int", 0, "GrassStorage")
    self:NetworkVar("Entity", 0, "VehicleEnt")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    if (SERVER) then
        self:SetIsRunning(false)
        self:SetIsMowing(false)
        self:SetGrassStorage(0)
        self:SetIsUnloading(false)
        self:SetHasCorb(true)
        self:SetHasTrailer(false)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d
