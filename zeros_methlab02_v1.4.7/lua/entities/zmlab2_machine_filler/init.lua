/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create(self.ClassName)
	if not IsValid(ent) then return end
	ent:SetPos(SpawnPos)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 90)
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
	self:UseClientSideAnimation()
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end
	zmlab2.Filler.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:OnRemove()
	zmlab2.Filler.OnRemove(self)
end

function ENT:StartTouch(other)
    zmlab2.Filler.OnStartTouch(self,other)
end

function ENT:AcceptInput(inputName, activator, caller, data)
	if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		zmlab2.Filler.OnUse(self, activator)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

function ENT:OnTakeDamage(dmginfo)
	zmlab2.Damage.OnTake(self, dmginfo)
end

/////////////////////////////////////////////////////////////////
/////////////////// PUMPING SYSTEM //////////////////////////////
/////////////////////////////////////////////////////////////////
// Get called when the Pumping System started unloading this Machine
function ENT:Unloading_Started()
	// NOT USED
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

// Get called when the Pumping System finished unloading this Machine
function ENT:Unloading_Finished()
	// NOT USED
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

// Get called when the Pumping System started loading this Machine
function ENT:Loading_Started()
	zmlab2.Filler.Loading_Started(self)
end

// Get called when the Pumping System finished loading this Machine
function ENT:Loading_Finished(Filter)
	zmlab2.Filler.Loading_Finished(self,Filter)
end
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
