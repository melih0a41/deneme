/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_filter.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Filter"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()

    // Corresponds to a ID from the MethTypes config (normal meth, blue meth)
    self:NetworkVar("Int", 1, "MethType")

    self:NetworkVar("Int", 2, "ProcessState")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    self:NetworkVar("Int", 3, "Progress")

    self:NetworkVar("Int", 4, "MethQuality")

    self:NetworkVar("Int", 5, "ErrorStart")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

    if (SERVER) then
        self:SetMethType(6)
        self:SetProcessState(0)
        self:SetProgress(0)
        self:SetMethQuality(1)
        self:SetErrorStart(-1)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

function ENT:OnStart(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > 0 and lp.x < 8 and lp.y < 15 and lp.y > 10 and lp.z > 27 and lp.z < 32 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

function ENT:OnErrorButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > 0 and lp.x < 8 and lp.y < 15 and lp.y > 10 and lp.z > 25 and lp.z < 31.4 then
        return true
    else
        return false
    end
end


// Tell us if you allow to receive liquid
function ENT:AllowConnection(From_ent)
    if From_ent:GetClass() == "zmlab2_machine_mixer" and From_ent:GetProcessState() == 9 and self:GetProcessState() == 0 then
        return true
    else
        return false
    end
end

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

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
