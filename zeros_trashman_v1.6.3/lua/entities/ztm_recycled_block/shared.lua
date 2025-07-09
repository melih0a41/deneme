/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_trashman/ztm_recycleblock.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Recycled Block"
ENT.Category = "Zeros Trashman"
ENT.RenderGroup = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "RecycleType")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    if (SERVER) then
        self:SetRecycleType(5)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d
