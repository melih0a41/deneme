AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/blood/glass.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.NextUseTime = 0
end

function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end
    if self.NextUseTime > CurTime() then return end
    self.NextUseTime = CurTime() + 1

    local swep = caller:GetWeapon("dex_w_glass")
    if not IsValid(swep) then
        caller:Give("dex_w_glass")
        swep = caller:GetWeapon("dex_w_glass")
    end

    if IsValid(swep) and swep.AddGlassName then
        local name = self.GlassName or DEX_LANG.Get("unknown")
        swep:SetTargetPlayerName(name)
        swep:AddGlassName(name)
        self:Remove()
    end
end
