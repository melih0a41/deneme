/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_trashman/ztm_trashbag.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Trashbag"
ENT.Category = "Zeros Trashman"
ENT.RenderGroup = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Trash")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if (SERVER) then
        self:SetTrash(100)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a
