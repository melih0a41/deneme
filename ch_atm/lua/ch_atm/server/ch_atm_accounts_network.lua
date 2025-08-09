--[[
	Depositing money into the players bank account
--]]
net.Receive( "CH_ATM_Net_DepositMoney", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	local amount = math.Round( net.ReadUInt( 32 ) )
	local ply_money_wallet = CH_ATM.GetMoney( ply )
	
	local atm = net.ReadEntity()
	
	-- Perform a series of security checks before completing the deposit.
	if amount > ply_money_wallet then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You don't have this much money!" ) )
		return
	end
	
	if amount <= 0 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The amount must be positive!" ) )
		return
	end
	
	if not CH_ATM.IsPlayerCloseToAnATM( ply ) then
		return
	end
	
	if atm:GetIsBeingHacked() or atm:GetIsHackCooldown() then
		return
	end
	
	-- All checks passed so add money to bank
	CH_ATM.AddMoneyToBankAccount( ply, amount )
	
	-- Take money from the players wallet
	CH_ATM.TakeMoney( ply, amount )
	
	if CH_ATM.Config.SlideMoneyOutOfATM then
		CH_ATM.PushMoneyIntoATM( ply, atm )
	end
	
	-- Log transaction (only works with SQL enabled)
	CH_ATM.LogSQLTransaction( ply, "deposit", amount )

	-- bLogs support
	hook.Run( "CH_ATM_bLogs_DepositMoney", ply, amount )
	
	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have deposited" ) .." ".. CH_ATM.FormatMoney( amount ) )
end )

--[[
	Withdraw money from bank account
--]]
net.Receive( "CH_ATM_Net_WithdrawMoney", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	local amount = math.Round( net.ReadUInt( 32 ) )
	local ply_bank_account = CH_ATM.GetMoneyBankAccount( ply )
	
	local atm = net.ReadEntity()
	
	-- Perform a series of security checks before completing the deposit.
	if amount > ply_bank_account then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You don't have this much money!" ) )
		return
	end
	
	if amount <= 0 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The amount must be positive!" ) )
		return
	end
	
	if not CH_ATM.IsPlayerCloseToAnATM( ply ) then
		return
	end
	
	if atm:GetIsBeingHacked() or atm:GetIsHackCooldown() then
		return
	end
	
	-- All checks passed so take money from bank account
	CH_ATM.TakeMoneyFromBankAccount( ply, amount )
	
	-- Add money to players wallet / slide out of ATM
	if CH_ATM.Config.SlideMoneyOutOfATM then
		CH_ATM.PushMoneyOutOfATM( ply, atm, amount )
	else
		CH_ATM.AddMoney( ply, amount )
	end
	
	-- Log transaction (only works with SQL enabled)
	CH_ATM.LogSQLTransaction( ply, "withdraw", amount )
	
	-- bLogs support
	hook.Run( "CH_ATM_bLogs_WithdrawMoney", ply, amount )
	
	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have withdrawn" ) .." ".. CH_ATM.FormatMoney( amount ) )
end )

--[[
	Sending money to other players bank accounts
--]]
net.Receive( "CH_ATM_Net_SendMoney", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	local amount = math.Round( net.ReadUInt( 32 ) )
	local receiver = net.ReadEntity()
	local ply_bank_account = CH_ATM.GetMoneyBankAccount( ply )

	-- Perform a series of security checks before completing the deposit.
	if amount > ply_bank_account then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You don't have this much money!" ) )
		return
	end
	
	if amount <= 0 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The amount must be positive!" ) )
		return
	end
	
	if not CH_ATM.IsPlayerCloseToAnATM( ply ) then
		return
	end
	
	if not IsValid( receiver ) then
		return
	end
	
	-- If all checks passed then send the money
	
	-- Take money from the SENDER bank account
	CH_ATM.TakeMoneyFromBankAccount( ply, amount )
	
	-- Add to the RECEIVER bank account
	CH_ATM.AddMoneyToBankAccount( receiver, amount )
	
	-- Log transaction (only works with SQL enabled)
	CH_ATM.LogSQLTransaction( ply, "transfer", amount )
	
	-- bLogs support
	hook.Run( "CH_ATM_bLogs_SendMoney", ply, amount, receiver )
	
	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have sent" ) .." ".. CH_ATM.FormatMoney( amount ) .." to " .. receiver:Nick() )
	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The money has been deducted from your bank account." ) )
	
	CH_ATM.NotifyPlayer( receiver, CH_ATM.LangString( "You have received" ) .." ".. CH_ATM.FormatMoney( amount ) .." from " .. ply:Nick() )
	CH_ATM.NotifyPlayer( receiver, CH_ATM.LangString( "The money has been sent to your bank account." ) )
end )



--[[
	Sending money to an offline players account by SteamID64
--]]
net.Receive( "CH_ATM_Net_SendMoneyOffline", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	local amount = math.Round( net.ReadUInt( 32 ) )
	local receiver_sid64 = net.ReadString()
	local ply_bank_account = CH_ATM.GetMoneyBankAccount( ply )

	-- Perform a series of security checks before completing the deposit.
	if amount > ply_bank_account then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You don't have this much money!" ) )
		return
	end
	
	if amount <= 0 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The amount must be positive!" ) )
		return
	end
	
	if not CH_ATM.IsPlayerCloseToAnATM( ply ) then
		return
	end

	-- All security checks passed. First check if player is already online or else perform SQL against the SID64
	local receiver_ply = player.GetBySteamID64( receiver_sid64 )
	
	if IsValid( receiver_ply ) then
		-- Take money from the SENDER bank account
		CH_ATM.TakeMoneyFromBankAccount( ply, amount )
		
		-- Add to the RECEIVER bank account
		CH_ATM.AddMoneyToBankAccount( receiver_ply, amount )
		
		-- Log transaction
		CH_ATM.LogSQLTransaction( ply, "transfer", amount )
		
		-- bLogs support
		hook.Run( "CH_ATM_bLogs_SendMoney", ply, amount, receiver_ply )
		
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have sent" ) .." ".. CH_ATM.FormatMoney( amount ) .." to " .. receiver_ply:Nick() )
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The money has been deducted from your bank account." ) )
		
		CH_ATM.NotifyPlayer( receiver_ply, CH_ATM.LangString( "You have received" ) .." ".. CH_ATM.FormatMoney( amount ) .." from " .. ply:Nick() )
		CH_ATM.NotifyPlayer( receiver_ply, CH_ATM.LangString( "The money has been sent to your bank account." ) )
	else
		CH_ATM.SQL.Query( "SELECT * FROM ch_atm_accounts WHERE steamid = '" .. receiver_sid64 .. "';", function( data )
			if data then
				-- Take money from the SENDER bank account
				CH_ATM.TakeMoneyFromBankAccount( ply, amount )
				
				CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have sent" ) .." ".. CH_ATM.FormatMoney( amount ) )
				CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The money has been deducted from your bank account." ) )
				
				-- Log transaction
				CH_ATM.LogSQLTransaction( ply, "transfer", amount )
				
				-- Add money to the receiver account
				local new_money = tonumber( data.amount ) + amount
				
				-- Update their nick in the database
				CH_ATM.SQL.Query( "UPDATE ch_atm_accounts SET amount = '" .. new_money .. "' WHERE steamid = '" .. receiver_sid64 .. "';" )
			else
				CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "There is noone with this SteamID in the banking system." ) )
			end
		end, true )
	end
end )