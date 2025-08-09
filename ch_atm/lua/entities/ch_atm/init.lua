AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:SpawnFunction( ply, tr )
	if not tr.Hit then
		return
	end
	
	local SpawnPos = tr.HitPos + tr.HitNormal
	
	local ent = ents.Create( "ch_atm" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( Angle( 0, 0, 0 ) )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

--[[
	When a player wants to exit and retrieve their card back
--]]
net.Receive( "CH_ATM_Net_PullOutCreditCard", function( len, ply )
	local atm = net.ReadEntity()
	
	if IsValid( atm ) then
		atm:ResetATM()
	end
end )

function ENT:Initialize()
	self:SetModel( "models/craphead_scripts/ch_atm/atm.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE  )
	
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end
	
	self.IsInUse = false
	self.InUseBy = nil
	self.ActivatedByCard = false
	
	self.RGBLightsEnabled = false
	
	-- Hack vars
	self:SetIsBeingHacked( false )
	self:SetIsHackCooldown( false )
	
	-- See if inactive color is enabled
	if CH_ATM.Config.EnableInactiveColor then
		self:SetBodygroup( 1, 1 )
		
		CH_ATM.ChangeATMColor( self, CH_ATM.Config.InactiveColor, 0 )
	end
	
	self:DropToFloor()
	
	-- Disable pocket hack
	self.RPOriginalMass = 1000
end

function ENT:AcceptInput( string, ply )
	if CH_ATM.Config.ActivateWithCreditCard then
		return
	end
	
	if ply:GetPos():DistToSqr( self:GetPos() ) <= CH_ATM.Config.DistanceToScreen3D2D then
		self:ActivateATM( ply, false )
	end
end

function ENT:Think()
	local distance_over_allowance = IsValid( self.InUseBy ) and ( self.InUseBy:GetPos():DistToSqr( self:GetPos() ) > CH_ATM.Config.DistanceToScreen3D2D )
	local user_invalid = self.IsInUse and not IsValid( self.InUseBy )
	
	if distance_over_allowance then
		self:CheckForFee()
		
		self:ResetATM()
	elseif user_invalid then
		self:ResetATM()
	end
	
	self:NextThink( CurTime() + 0.2 )
	return true 
end

function ENT:ActivateATM( ply, by_card )
	if self.IsInUse then
		return
	end
	
	if not ply:IsPlayer() then
		return
	end
	
	if self:GetIsBeingHacked() or self:GetIsHackCooldown() or self:GetIsEmergencyLockdown() then
		return
	end
	
	self.IsInUse = true
	self.InUseBy = ply
	
	self:SetBodygroup( 1, 1 )
	
	CH_ATM.ChangeATMColor( self, CH_ATM.Config.ActiveColor, 0 )

	-- Broadcast to network who is using the ATM
	net.Start( "CH_ATM_Net_ATMInUseBy" )
		net.WriteEntity( self )
		net.WriteBool( self.IsInUse )
		net.WriteEntity( self.InUseBy )
	net.Broadcast()
	
	-- Was activated by a credit card?
	if by_card then
		self.ActivatedByCard = true
	end
end

function ENT:ResetATM()
	if not self:GetIsBeingHacked() and not self:GetIsHackCooldown() and not self:GetIsEmergencyLockdown() then
		if not CH_ATM.Config.EnableInactiveColor then
			self:SetBodygroup( 1, 0 )
		else
			CH_ATM.ChangeATMColor( self, CH_ATM.Config.InactiveColor, 0 )
		end
	end
	
	-- If it was activated by card then give back credit card to player
	if self.ActivatedByCard then
		local card_owner = self.InUseBy
		
		CH_ATM.PullOutCreditCardATM( self )
		
		timer.Simple( 2, function()
			if IsValid( card_owner ) then
				card_owner:Give( "weapon_ch_atm_card" )
				card_owner:SelectWeapon( "weapon_ch_atm_card" )
			end
		end )
		
		self.ActivatedByCard = false
	end
	
	-- Reset to init screen and reset variables
	net.Start( "CH_ATM_Net_InitializeScreen" )
		net.WriteEntity( self )
	net.Broadcast()
	
	self.IsInUse = false
	self.InUseBy = nil
	
	-- Broadcast to network who is using the ATM
	net.Start( "CH_ATM_Net_ATMInUseBy" )
		net.WriteEntity( self )
		net.WriteBool( self.IsInUse )
		net.WriteEntity( self.InUseBy )
	net.Broadcast()
end

function ENT:CheckForFee()
	-- Check if config for card fee is enabled
	if not CH_ATM.Config.FinePlayerIfForgetCard then
		return
	end
	
	-- Check if the ATM was activated by a card
	if not self.ActivatedByCard then
		return
	end
	
	-- Get card owner (who using atm) and their atm holdings
	local card_owner = self.InUseBy
	if not IsValid( card_owner ) then
		return
	end
	
	local ply_bank_account = CH_ATM.GetMoneyBankAccount( card_owner )
	
	-- If they can afford the fee then charge them
	if ply_bank_account >= CH_ATM.Config.ForgetCardFee then
		-- Take money from their bank account (will also save)
		CH_ATM.TakeMoneyFromBankAccount( card_owner, CH_ATM.Config.ForgetCardFee )
		
		-- Notify them
		CH_ATM.NotifyPlayer( card_owner, "-".. CH_ATM.FormatMoney( CH_ATM.Config.ForgetCardFee ) .." ".. CH_ATM.LangString( "for forgetting your card at the ATM" ) )
		
		-- bLogs support
		hook.Run( "CH_ATM_bLogs_TakeMoney", CH_ATM.Config.ForgetCardFee, card_owner, "Forgot their card in the ATM" )
	end
end

-- 76561198381307883
function ENT:OnTakeDamage( dmg )
	return 0
end