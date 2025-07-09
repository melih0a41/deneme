/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_filler.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Filler"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e


function ENT:SetupDataTables()

    // Corresponds to a ID from the MethTypes config (normal meth, blue meth)
    self:NetworkVar("Int", 1, "MethType")
    self:NetworkVar("Int", 2, "MethAmount")
    self:NetworkVar("Int", 3, "MethQuality")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

    self:NetworkVar("Int", 4, "ProcessState")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    self:NetworkVar("Entity", 1, "Tray")


    if (SERVER) then
        self:SetMethType(1)
        self:SetProcessState(0)
        self:SetMethAmount(0)
        self:SetMethQuality(1)
        self:SetTray(NULL)
    end
end

function ENT:OnPumpButton(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -8 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 26 and lp.z < 31 then
        return true
    else
        return false
    end
end

// Tell us if you allow to receive liquid
function ENT:AllowConnection(From_ent)
    if From_ent:GetClass() == "zmlab2_machine_filter" and From_ent:GetProcessState() == 4 and self:GetProcessState() == 0 then
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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e


function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
