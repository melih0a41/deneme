AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/craphead_scripts/bitminers/utility/cooling_upgrade_2.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysWake()
	
	self:SetHealth( CH_Bitminers.Config.CoolingUpgradesHealth )
	self:SetMaxHealth( CH_Bitminers.Config.CoolingUpgradesHealth )
	
	self.CoolingLevel = 2
	
	self:CPPISetOwner( self:Getowning_ent() )
	
	-- Add entity to active entities table
	CH_Bitminers.SpawnedEntities[ self ] = true
end

function ENT:OnTakeDamage( dmg )
	if ( not self.m_bApplyingDamage ) then
		self.m_bApplyingDamage = true
		
		self:SetHealth( ( self:Health() or 100 ) - dmg:GetDamage() )
		if self:Health() <= 0 then
			self:Destruct()
			self:Remove()
		end
		
		self.m_bApplyingDamage = false
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	
	effectdata:SetStart( vPoint )
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( 1 )
	util.Effect( "ManhackSparks", effectdata )
end

function ENT:OnRemove()
	-- Remove entity from active entities table
	CH_Bitminers.SpawnedEntities[ self ] = nil
end