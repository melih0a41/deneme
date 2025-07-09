/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_methlab/zmlab2_storage.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Storage"
ENT.Category = "Zeros Methlab 2"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    self:NetworkVar("Int", 1, "NextPurchase")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    if (SERVER) then
        self:SetNextPurchase(0)
    end
end

function ENT:CanProperty(ply)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

function ENT:CanTool(ply, tab, str)
    return zclib.Player.IsAdmin(ply)
end

function ENT:CanDrive(ply)
    return zclib.Player.IsAdmin(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69
