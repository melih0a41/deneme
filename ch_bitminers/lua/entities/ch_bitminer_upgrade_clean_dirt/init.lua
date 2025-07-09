AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/craphead_scripts/bitminers/cleaning/spraybottle.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysWake()
	
	self:SetHealth( CH_Bitminers.Config.DirtCleaning )
	self:SetMaxHealth( CH_Bitminers.Config.DirtCleaning )
	
	self:CPPISetOwner( self:Getowning_ent() )
	
	-- Add entity to active entities table
	CH_Bitminers.SpawnedEntities[ self ] = true
end

function ENT:OnTakeDamage( dmg )
	if ( not self.m_bApplyingDamage ) then
		self.m_bApplyingDamage = true
		
		self:SetHealth( ( self:Health() or 100 ) - dmg:GetDamage() )
		if self:Health() <= 0 then
			self:Remove()
		end
		
		self.m_bApplyingDamage = false
	end
end

function ENT:StartTouch( ent )
	if ent:IsPlayer() then
		return
	end
	
	local cur_time = CurTime()
	if ( ent.LastTouch or 0 ) > cur_time then
		return
	end
	ent.LastTouch = cur_time + 2

	if ent:GetClass() == "ch_bitminer_power_solar" then
		ent:SetDirtAmount( 0 )
		
		SafeRemoveEntityDelayed( self, 0 )
	end
end

function ENT:OnRemove()
	-- Remove entity from active entities table
	CH_Bitminers.SpawnedEntities[ self ] = nil
end