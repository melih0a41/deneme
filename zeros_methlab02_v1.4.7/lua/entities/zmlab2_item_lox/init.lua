/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(self.ClassName)
	if not IsValid(ent) then return end
	ent:SetPos(SpawnPos)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

	ent:SetAngles(angle)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)
	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:UseClientSideAnimation()
	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	self:SetMaxHealth( zmlab2.config.Damageable[self:GetClass()] )
    self:SetHealth(self:GetMaxHealth())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	zclib.EntityTracker.Add(self)
end

function ENT:OnRemove()
	zclib.EntityTracker.Remove(self)
end

function ENT:OnTakeDamage(dmginfo)
	zmlab2.Damage.OnTake(self, dmginfo)
end
