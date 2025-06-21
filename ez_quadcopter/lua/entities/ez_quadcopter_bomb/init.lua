AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)

	self:PhysWake()
end

function ENT:Use(activator)
end

function ENT:Explode(ply)
	local pos = self:GetPos()

	local explosion = EffectData()
	explosion:SetStart(pos)
	explosion:SetOrigin(pos)
	explosion:SetMagnitude(12)
	explosion:SetScale(1)
	util.Effect("Explosion", explosion, true, true)

	util.BlastDamage(self, ply or self, pos, 200, 300)
	self:Remove()
end
