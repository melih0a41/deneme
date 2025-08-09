--[[
	Notification function based on the current gamemode
--]]
function CH_ATM.NotifyPlayer( ply, text )
	if DarkRP then
		DarkRP.notify( ply, 1, CH_ATM.Config.NotificationTime, text )
	else
		ply:ChatPrint( text )
	end
end

--[[
	Function to check if a player is close to an ATM that is in use and in use by that player
--]]
function CH_ATM.IsPlayerCloseToAnATM( ply )
	local is_close = false

	for k, atm in ipairs( ents.FindByClass( "ch_atm" ) ) do
		if ply:GetPos():DistToSqr( atm:GetPos() ) <= CH_ATM.Config.DistanceToScreen3D2D then
			if atm.IsInUse and atm.InUseBy == ply then
				is_close = true
				break
			end
		end
	end

	return is_close
end

--[[
	Function to find amount of cops online
--]]
function CH_ATM.GetAmountOfCops()
	local amount_of_cops = 0
	
	for k, ply in ipairs( player.GetAll() ) do
		if ply:CH_ATM_IsPoliceJob() then
			amount_of_cops = amount_of_cops + 1
		end
	end
	
	return amount_of_cops
end

--[[
	Function to spawn money and move it out of the ATM
--]]
function CH_ATM.PushMoneyOutOfATM( ply, atm, amount )
	local money = ents.Create( "ch_atm_money" )
	money:SetPos( atm:LocalToWorld( Vector( -2.8, 6.2, 47.7 ) ) )
	money:SetAngles( atm:GetAngles() )
	money:Spawn()
	
	money.CashAmount = amount
	money.ATMEntity = atm
	money.Withdrawer = ply
	
	-- Stop moving after 2 seconds
	timer.Simple( 2, function()
		if not IsValid( money ) then
			return
		end
		
		money.IsMoving = false
		money:SetMoveType( MOVETYPE_NONE )
	end )
end

--[[
	Function to spawn money and move it into the ATM
--]]
function CH_ATM.PushMoneyIntoATM( ply, atm )
	local money = ents.Create( "ch_atm_money" )
	money:SetPos( atm:LocalToWorld( Vector( 1, 6.2, 47.7 ) ) )
	money:SetAngles( atm:GetAngles() )
	money:Spawn()
	
	money.CashAmount = 0
	money.ATMEntity = atm
	money.Withdrawer = ply
	
	-- Stop moving after 2 seconds
	timer.Simple( 2, function()
		if not IsValid( money ) then
			return
		end
		
		money:Remove()
	end )
end

--[[
	Function to give XP to a player
	Supports various XP systems
--]]
function CH_ATM.GiveXP( ply, amount, reason )
	if tonumber( amount ) <= 0 then
		return
	end
	
	-- Give XP (Vronkadis DarkRP Level System)
	if LevelSystemConfiguration then
		ply:addXP( amount, true )
	end
	
	-- Give XP (Sublime Levels)
	if Sublime and Sublime.Config and Sublime.Config.BaseExperience then
		ply:SL_AddExperience( amount, reason )
	end
	
	-- Give XP (Elite XP system)
	if EliteXP then
		EliteXP.CheckXP( ply, amount )
	end
	
	-- Give XP (DarkRP essentials & Brick's Essentials)
	if ( BRICKS_SERVER and BRICKS_SERVER.CONFIG and BRICKS_SERVER.CONFIG.LEVELING ) or ( DARKRP_ESSENTIALS and DARKRP_ESSENTIALS.CONFIG and DARKRP_ESSENTIALS.CONFIG.Enable_Leveling ) then
		ply:AddExperience( amount, reason )
	end

	-- Give XP (GlorifiedLeveling)
	if GlorifiedLeveling then
		GlorifiedLeveling.AddPlayerXP( ply, amount )
	end
end

--[[
	Function to spawn credit card and move it into the ATM
--]]
function CH_ATM.InsertCreditCardATM( atm )
	local creditcard = ents.Create( "ch_atm_credit_card" )
	creditcard:SetPos( atm:LocalToWorld( Vector( 1.75, -5.6, 48.2 ) ) )
	creditcard:SetAngles( atm:GetAngles() )
	creditcard:Spawn()
	
	creditcard.IsInsert = true
	
	-- Stop moving after 2 seconds
	timer.Simple( 2, function()
		if not IsValid( creditcard ) then
			return
		end
		
		creditcard:Remove()
	end )
end

--[[
	Function to spawn credit card and move it out of the ATM
--]]
function CH_ATM.PullOutCreditCardATM( atm )
	local creditcard = ents.Create( "ch_atm_credit_card" )
	creditcard:SetPos( atm:LocalToWorld( Vector( -1.75, -5.6, 48.2 ) ) )
	creditcard:SetAngles( atm:GetAngles() )
	creditcard:Spawn()
	
	creditcard.IsInsert = false
	
	-- Stop moving after 2 seconds
	timer.Simple( 2, function()
		if not IsValid( creditcard ) then
			return
		end
		
		creditcard:Remove()
	end )
end