/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_mixer.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Mixer"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "ProcessState")
    /*
        0 = Needs Barrel
        1 = Needs Acid
        2 = Press the Start Mix Button
        3 = Add Aluminium
        4 = Press the Start Mix Button
        5 = Add Exhaust pipe
        6 = Moving Acid (Loading)
        7 = Needs to be cleaned
    */

    self:NetworkVar("Int", 2, "MethQuality")
    self:NetworkVar("Int", 3, "NeedAmount")

    self:NetworkVar("Int", 5, "ErrorStart")
    self:NetworkVar("Int", 6, "ProcessStart")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    self:NetworkVar("Int", 7, "MethType")

    if (SERVER) then
        self:SetProcessState(-1)

        self:SetMethQuality(0)
        self:SetNeedAmount(0)

        self:SetErrorStart(-1)
        self:SetProcessStart(-1)

        self:SetMethType(1)
    end
end

function ENT:OnStart(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 27 and lp.z < 31 then
        return true
    else
        return false
    end
end

function ENT:OnMethType(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 32 and lp.z < 37 then
        return true
    else
        return false
    end
end

function ENT:OnErrorButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)
    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 28 and lp.z < 33.6 then
        return true
    else
        return false
    end
end

function ENT:OnCenterButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 25 and lp.z < 38 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380




// Tell us if you allow to receive liquid
function ENT:AllowConnection(From_ent)
    if From_ent:GetClass() == "zmlab2_machine_furnace" and From_ent:GetProcessState() == 4 and self:GetProcessState() == 1 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

// Returns the start position and direction for a hose
function ENT:GetHose_In()
    local attach = self:GetAttachment(1)
    if attach == nil then return self:GetPos(),self:GetAngles() end
    local ang = attach.Ang
    ang:RotateAroundAxis(ang:Right(),180)

    return attach.Pos,ang
end


// Returns the start position and direction for a hose
function ENT:GetHose_Out()
    local attach = self:GetAttachment(2)
    if attach == nil then return self:GetPos(),self:GetAngles() end
    return attach.Pos,attach.Ang
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588



function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
