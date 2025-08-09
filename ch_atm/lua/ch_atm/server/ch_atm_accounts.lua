--[[
	Load or create the players account on connect
--]]
function CH_ATM.ControlPlayerBankAccount( ply )
	local sid64 = ply:SteamID64()
	local escaped_nick = CH_ATM.SQL.Escape( ply:Nick() )
	
	CH_ATM.SQL.Query( "SELECT * FROM ch_atm_accounts WHERE steamid = '" .. sid64 .. "';", function( data )
		if data then
			-- Load account
			ply.CH_ATM_BankAccount = tonumber( data.amount )
			ply.CH_ATM_BankAccountLevel = tonumber( data.level )
			
			-- Update their nick in the database
			CH_ATM.SQL.Query( "UPDATE ch_atm_accounts SET nick = '" .. escaped_nick .. "' WHERE steamid = '" .. sid64 .. "';" )
		else
			-- Create new
			CH_ATM.SQL.Query( "INSERT INTO ch_atm_accounts ( amount, level, steamid, nick ) VALUES( '" .. CH_ATM.Config.AccountStartMoney .. "', 1, '" .. sid64 .. "', '" .. escaped_nick .. "');" )
			
			-- Set variables on the player
			ply.CH_ATM_BankAccount = CH_ATM.Config.AccountStartMoney
			ply.CH_ATM_BankAccountLevel = 1
		end
		
		-- Make sure it's not negative.
		if ply and ply.CH_ATM_BankAccount and ply.CH_ATM_BankAccount < 0 then
			ply.CH_ATM_BankAccount = 0
		end
		
		-- Set player interest based on config and account level
		if CH_ATM.Config.AccountLevels[ CH_ATM.GetAccountLevel( ply ) ] then
			CH_ATM.SetInterestRate( ply, CH_ATM.Config.AccountLevels[ CH_ATM.GetAccountLevel( ply ) ].InterestRate, CH_ATM.Config.InterestNotifyOnSpawn )
		else -- Their level does not longer exist in the config and thus we must reset it.
			ply.CH_ATM_BankAccountLevel = 1
			
			CH_ATM.SetInterestRate( ply, CH_ATM.Config.AccountLevels[ CH_ATM.GetAccountLevel( ply ) ].InterestRate, CH_ATM.Config.InterestNotifyOnSpawn )

			CH_ATM.SavePlayerBankAccount( ply )
		end
		
		-- Network bank account
		CH_ATM.NetworkBankAccountToPlayer( ply )
		
		-- Network transaction history
		CH_ATM.NetworkTransactionsSQL( ply )
	
		-- Network leaderboards
		CH_ATM.NetworkLeaderboard( ply )
	end, true )
end

--[[
	Network bank account to the player
--]]
function CH_ATM.NetworkBankAccountToPlayer( ply )
	local bank_account_amt = CH_ATM.GetMoneyBankAccount( ply )
	local bank_account_level = CH_ATM.GetAccountLevel( ply )
	
	-- Network it
	net.Start( "CH_ATM_Net_NetworkBankAccount" )
		net.WriteUInt( bank_account_amt, 32 )
		net.WriteUInt( bank_account_level, 8 )
	net.Send( ply )
end

--[[
	Function to save the players bank account
--]]
function CH_ATM.SavePlayerBankAccount( ply )
	if not IsValid( ply ) then
		return
	end

	-- Write to SQL
	CH_ATM.SQL.Query( "UPDATE ch_atm_accounts SET amount = '" .. ply.CH_ATM_BankAccount .. "', level = '" .. ply.CH_ATM_BankAccountLevel .. "' WHERE steamid = '" .. ply:SteamID64() .. "';" )
end