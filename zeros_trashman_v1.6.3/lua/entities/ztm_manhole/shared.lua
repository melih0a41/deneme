/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_trashman/ztm_manhole.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Manhole"
ENT.Category = "Zeros Trashman"
ENT.RenderGroup = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Trash")
    self:NetworkVar("Bool", 0, "IsClosed")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if (SERVER) then
        self:SetTrash(0)
        self:SetIsClosed(true)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
