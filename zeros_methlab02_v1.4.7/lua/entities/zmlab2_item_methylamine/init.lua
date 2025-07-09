/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(self.ClassName)
	if not IsValid(ent) then return end
	ent:SetPos(SpawnPos)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)

	ent:SetAngles(angle)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)
	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:UseClientSideAnimation()
	local phys = self:GetPhysicsObject()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self:SetMaxHealth( zmlab2.config.Damageable[self:GetClass()] )
	self:SetHealth(self:GetMaxHealth())

	zclib.EntityTracker.Add(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

function ENT:OnRemove()
	zclib.EntityTracker.Remove(self)
end

function ENT:OnTakeDamage(dmginfo)
	zmlab2.Damage.OnTake(self, dmginfo)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
