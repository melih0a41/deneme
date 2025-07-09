/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_chest.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Equipment"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:OnBuild(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 44 and lp.z < 51 then
        return true
    else
        return false
    end
end

function ENT:OnMove(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 37 and lp.z < 44 then
        return true
    else
        return false
    end
end

function ENT:OnRepair(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 30 and lp.z < 37 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:OnRemoveButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 10 and lp.y < 15 and lp.y > 13 and lp.z > 23 and lp.z < 30 then
        return true
    else
        return false
    end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6
