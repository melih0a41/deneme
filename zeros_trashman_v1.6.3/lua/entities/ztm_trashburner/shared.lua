/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_trashman/ztm_trashburner.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Trashburner"
ENT.Category = "Zeros Trashman"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Trash")
    self:NetworkVar("Bool", 1, "IsBurning")
    self:NetworkVar("Bool", 0, "IsClosed")
    self:NetworkVar("Float", 0, "StartTime")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

    if (SERVER) then
        self:SetTrash(0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

        self:SetIsClosed(false)
        self:SetIsBurning(false)
        self:SetStartTime(-1)
    end
end

function ENT:OnCloseButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if lp.x > -40 and lp.x < -38 and lp.y < 10.5 and lp.y > 0 and lp.z > 52 and lp.z < 60 then
        return true
    else
        return false
    end
end

function ENT:OnStartButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

    if lp.x > -40 and lp.x < -38 and lp.y < -0.6 and lp.y > -11 and lp.z > 52 and lp.z < 60 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b
