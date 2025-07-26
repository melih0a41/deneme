AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/corporate_takeover/nostras/tasse.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger()
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.picked = nil
	self.delay = CurTime()
end

function ENT:Use(ply)
	if(self.delay > CurTime()) then return end
	self.delay = CurTime() + .5
	if(self:IsPlayerHolding()) then return end
	if(self.picked == true) then
		ply:DropObject()
		self.picked = nil
	else
		self.picked = true
		ply:PickupObject(self)
	end
end