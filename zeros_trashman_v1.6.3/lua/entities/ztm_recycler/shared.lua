/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_trashman/ztm_recycler.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Recycler"
ENT.Category = "Zeros Trashman"
ENT.RenderGroup = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Trash")
    self:NetworkVar("Int", 1, "SelectedType")
    self:NetworkVar("Int", 2, "RecycleStage")
    self:NetworkVar("Float", 0, "StartTime")


    if (SERVER) then
        self:SetTrash(0)
        self:SetSelectedType(1)
        //self:SetIsRecycling(false)
        self:SetRecycleStage(0)
        self:SetStartTime(-1)
    end
end


function ENT:OnStartButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

    if lp.x > 35 and lp.x < 36 and lp.y < 20.6 and lp.y > -9.5 and lp.z > 49.17 and lp.z < 54.4 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:OnSwitchButton_Left(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > 35 and lp.x < 36 and lp.y < -4.3 and lp.y > -9.5 and lp.z > 56.90 and lp.z < 62.0 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

function ENT:OnSwitchButton_Right(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > 35 and lp.x < 36 and lp.y < 20.6 and lp.y > 15.4 and lp.z > 56.90 and lp.z < 62.0 then
        return true
    else
        return false
    end
end
