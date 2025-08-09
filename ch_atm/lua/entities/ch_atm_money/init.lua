AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:SpawnFunction( ply, tr )
	if not tr.Hit then
		return
	end
	
	local SpawnPos = tr.HitPos + tr.HitNormal
	
	local ent = ents.Create( "ch_atm_money" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( Angle( 0, 0, 0 ) )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self:SetModel( "models/props/cs_assault/money.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NOCLIP )
	self:PhysWake()

	self.IsMoving = true
end

function ENT:AcceptInput( string, ply )
	if self.IsMoving then
		return
	end

	if not ply:IsPlayer() then
		return
	end
	
	if self.CashAmount <= 0 then
		return
	end
	
	-- If only withdrawer can take money then check who is trying to pick it up
	if CH_ATM.Config.OnlyOwnerCanTakeMoney then
		if self.Withdrawer != ply then
			return
		end
	end
	
	-- Add money
	CH_ATM.AddMoney( ply, self.CashAmount )

	-- Remove money entity
	self:Remove()
end

function ENT:Think()
	if not self.IsMoving then
		return
	end
	
	if self.CashAmount <= 0 then
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