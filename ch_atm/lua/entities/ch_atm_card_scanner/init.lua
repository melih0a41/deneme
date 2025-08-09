AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:SpawnFunction( ply, tr )
	if not tr.Hit then
		return
	end
	
	local SpawnPos = tr.HitPos + tr.HitNormal
	
	local ent = ents.Create( "ch_atm_card_scanner" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( Angle( 0, 0, 0 ) )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self:SetModel( "models/craphead_scripts/ch_atm/terminal.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE  )
	
	self:PhysWake()
	
	self:SetColor( CH_ATM.Config.TerminalDefaultColor )
	
	self.IsInUse = false
	self.InUseBy = nil
	
	self:SetIsReadyToScan( false )
	self:SetTerminalPrice( "" )
	
	-- Set DarkRP owner
	self:CPPISetOwner( self:Getowning_ent() )
end

--[[
	Update the status of the terminal
--]]
net.Receive( "CH_ATM_Net_CardScanner_IsReadyToScan", function( length, ply )
	local ent = net.ReadEntity()
	local status = net.ReadBool()
	
	ent:SetIsReadyToScan( status )
end )

--[[
	Update the terminal price
--]]
net.Receive( "CH_ATM_Net_CardScanner_UpdatePrice", function( length, ply )
	local ent = net.ReadEntity()
	local input = net.ReadString()
	local clear = net.ReadBool()
	
	if clear then
		ent:SetTerminalPrice( "" )
	else
		ent:SetTerminalPrice( ent:GetTerminalPrice() .. input )
	end
end )

--[[
	Function to trigger the green/red lights on scanner
--]]
function ENT:ChangeLights( accepted, on )
	if accepted and on then
		self:SetBodygroup( 1, 1 )
		
		self:SetSkin( 0 )
	elseif not accepted and on then
		self:SetBodygroup( 1, 1 )
		
		self:SetSkin( 1 )
	elseif not on then
		self:SetBodygroup( 1, 0 )
	end
end

--[[
	Disable damage for entity
--]]
function ENT:OnTakeDamage( dmg )
	return 0
end

--[[
	Pay via alt + e
--]]
function ENT:Use( ply )
	if not CH_ATM.Config.CanPressAltEToPay then
		return
	end
	
	-- Cooldown
	local cur_time = CurTime()
	if ( self.LastUsed or 0 ) > cur_time then
		return
	end
	self.LastUsed = cur_time + 2.1
	
	-- Some vars aye
	local terminal_owner = self:CPPIGetOwner()
	local terminal_price = tonumber( self:GetTerminalPrice() )
	
	-- Check that the terminal has an owner.
	if not IsValid( terminal_owner ) then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The card scanner terminal does not have a valid owner!" ) )
		return
	end
	
	-- Do nothing if we own the terminal
	if ply == terminal_owner then
		return
	end
	
	-- Check if terminal is ready to scan
	if not self:GetIsReadyToScan() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The credit card scanner is not ready to take your card. Waiting for owner..." ) )
		return
	end
	
	-- Check if ALT also down
	if not ply:KeyDown( CH_ATM.Config.AltKeyToPay ) then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You must press ALT + E to pay on a terminal!" ) )
		return
	end
	
	-- The price as an int is nil (it's 0 or not set)
	if not terminal_price then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The card scanner terminal price is 0 or below!" ) )
		return
	end
	
	if terminal_price <= 0 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The card scanner terminal price is 0 or below!" ) )
		return
	end
	
	if CH_ATM.GetMoneyBankAccount( ply ) >= terminal_price then
		-- If transaction can pass
		
		-- Charge buyers bank account
		CH_ATM.TakeMoneyFromBankAccount( ply, terminal_price )
		
		-- bLogs support for buyer/ply and terminal_owner
		hook.Run( "CH_ATM_bLogs_TakeMoney", terminal_price, ply, "Paid via credit card." )
		hook.Run( "CH_ATM_bLogs_ReceiveMoney", terminal_price, terminal_owner, "Received from credit card terminal." )
		
		-- Notify player
		CH_ATM.NotifyPlayer( ply, CH_ATM.FormatMoney( terminal_price ) .." ".. CH_ATM.LangString( "has been charged from your bank account." ) )
		
		-- Notify terminal owner and give them money
		CH_ATM.AddMoneyToBankAccount( terminal_owner, terminal_price )
		
		CH_ATM.NotifyPlayer( terminal_owner, ply:Nick() .." ".. CH_ATM.LangString( "has swiped their credit card on your card terminal." ) )
		CH_ATM.NotifyPlayer( terminal_owner, CH_ATM.FormatMoney( terminal_price ) .." ".. CH_ATM.LangString( "has been added to your bank account." ) )
		
		-- Log transaction (only works with SQL enabled)
		CH_ATM.LogSQLTransaction( ply, "card", terminal_price )
		
		-- Change lights on machine to green
		self:ChangeLights( true, true )
		
		-- Emit success sound
		self:EmitSound( "npc/turret_floor/ping.wav", 100 )
		
		-- Reset scanner values
		self:SetIsReadyToScan( false )
		self:SetTerminalPrice( "" )
		
		-- Turn off lights again after 2 sec
		timer.Simple( 2, function()
			if IsValid( self ) then
				self:ChangeLights( false, false )
			end
		end )
	else
		-- Does not have enough money
		
		-- Notify player
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You don't have this much money!" ) )
		
		-- Change lights on machine to red
		self:ChangeLights( false, true )
		
		-- Emit failed sound
		self:EmitSound( "common/warning.wav", 100 )
		
		-- Turn off lights again after 2 sec
		timer.Simple( 2, function()
			if IsValid( self ) then
				self:ChangeLights( false, false )
			end
		end )
	end
end