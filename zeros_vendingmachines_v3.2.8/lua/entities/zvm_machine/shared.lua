/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_vendingmachine/zvm_machine.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Vendingmachine"
ENT.Category = "Zeros Vendingmachine"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()

    self:NetworkVar("Bool", 0, "EditConfig")
    self:NetworkVar("Bool", 1, "AllowCollisionInput")
    self:NetworkVar("Entity", 0, "MachineUser")

    self:NetworkVar("Bool", 2, "PublicMachine")

    self:NetworkVar("Int", 0, "Earnings")

    self:NetworkVar("Int", 1, "StyleID")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if (SERVER) then
        self:SetAllowCollisionInput(false)
        self:SetEditConfig(false)
        self:SetMachineUser(NULL)
        self:SetPublicMachine(false)
        self:SetEarnings(0)

        self:SetStyleID(1)
    end
end

function ENT:OnStartButton(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > -10 and lp.x < 15 and lp.y < 27 and lp.y > 26 and lp.z > 37 and lp.z < 92 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978
