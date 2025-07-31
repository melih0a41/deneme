AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:SpawnFunction( ply, tr )
	if not tr.Hit then
		return
	end
	
	local SpawnPos = tr.HitPos + tr.HitNormal
	
	local ent = ents.Create( "ch_atm_credit_card" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( Angle( 0, 0, 0 ) )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self:SetModel( "models/craphead_scripts/ch_atm/suitcard.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NOCLIP )
	self:PhysWake()

	self.IsMoving = true
end

--[[
	Move it
--]]
function ENT:Think()
	if not self.IsMoving then
		return
	end
	
	if self.IsInsert then
		self:SetVelocity( self:GetForward() * -0.5 )
	else
		self:SetVelocity( self:GetForward() * 0.5 )
	end
end

--[[
	Disable damage for entity
--]]
function ENT:OnTakeDamage( dmg )
	return 0
end