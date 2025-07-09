/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_dropoff.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "DropOff"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 1, "IsClosed")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if (SERVER) then
        self:SetIsClosed(true)
    end
end

function ENT:GravGunPunt()
	return false
end
function ENT:GravGunPickupAllowed()
	return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
