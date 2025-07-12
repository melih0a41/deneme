/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_lawnmower/zlm_grasspress.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "GrassPress"
ENT.Category = "Zeros LawnMowerman"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsRunning")
    self:NetworkVar("Int", 0, "GrassCount")
    self:NetworkVar("Int", 1, "ProgressState")

    self:NetworkVar("Int", 2, "UpgradeLevel")
    self:NetworkVar("Float", 0, "UCooldDown")

    self:NetworkVar("Float", 1, "Production_TimeStamp")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

    if (SERVER) then
        self:SetGrassCount(0)
        self:SetProgressState(0)
        self:SetIsRunning(false)
        self:SetUpgradeLevel(0)
        self:SetUCooldDown(0)
        self:SetProduction_TimeStamp(-1)
    end
end

function ENT:EnableButton(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.z > 52.2 and lp.z < 57.4 and lp.x < 14.5 and lp.x > 9.5 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:UpgradButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.z > 46.7 and lp.z < 51.6 and lp.x < 9 and lp.x > -14.4 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d
