/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_ventilation.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Ventilation"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

function ENT:SetupDataTables()

    self:NetworkVar("Int", 2, "ProcessState")
    /*
        0 = OFF
        1 = ON
    */
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    self:NetworkVar("Entity", 1, "Output")

    //self:NetworkVar("Bool", 1, "IsVenting")
    self:NetworkVar("Int", 1, "LastPollutionMove")

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    if (SERVER) then
        self:SetProcessState(0)
        self:SetOutput(NULL)
        //self:SetIsVenting(false)
        self:SetLastPollutionMove(-1)
    end
end

function ENT:GetIsVenting()
    return self:GetProcessState() == 1
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:OnStart(ply)
    local trace = ply:GetEyeTrace()
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -8.8 and lp.x < 0 and lp.y < 15 and lp.y > 10 and lp.z > 28.5 and lp.z < 33.5 then
        return true
    else
        return false
    end
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
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69
