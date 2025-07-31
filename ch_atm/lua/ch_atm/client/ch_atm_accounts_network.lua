--[[
	This is a method of ensuring that the player is loaded in, so we can network stuff to them (PlayerInitialSpawn is unreliable)
	-- 76561198381307883
--]]
function CH_ATM.IsPlayerLoadedIn()
	if IsValid( LocalPlayer() ) then
		net.Start( "CH_ATM_Net_HUDPaintLoad" )
		net.SendToServer()
		
		hook.Remove( "HUDPaint", "CH_ATM.IsPlayerLoadedIn" )
	end
end
hook.Add( "HUDPaint", "CH_ATM.IsPlayerLoadedIn", CH_ATM.IsPlayerLoadedIn )

--[[
	Receive the players bank account and network it to him
--]]
net.Receive( "CH_ATM_Net_NetworkBankAccount", function( len, ply )
	local bank_account = net.ReadUInt( 32 )
	local bank_account_level = net.ReadUInt( 8 )
	local player = LocalPlayer()
	
	player.CH_ATM_BankAccount = bank_account
	player.CH_ATM_BankAccountLevel = bank_account_level

	CH_ATM.DebugPrint( "CLIENTSIDE BANK ACCOUNT FOR: ".. player:Nick() )
	CH_ATM.DebugPrint( player.CH_ATM_BankAccount )
	CH_ATM.DebugPrint( player.CH_ATM_BankAccountLevel )
end )

--[[
	Receive the players bank interest rate and network it to him
--]]
net.Receive( "CH_ATM_Net_NetworkInterestRate", function( len, ply )
	local interest_rate = net.ReadDouble()
	local player = LocalPlayer()
	
	player.CH_ATM_InterestRate = interest_rate

	CH_ATM.DebugPrint( "CLIENTSIDE BANK INTEREST RATE FOR: ".. player:Nick() )
	CH_ATM.DebugPrint( player.CH_ATM_InterestRate )
end )

--[[
	Receive the players bank transactions and network it to him
--]]
net.Receive( "CH_ATM_Net_NetworkTransactions", function( len, ply )
	local amount_of_entries = net.ReadUInt( 6 )
	
	-- Create the clientside table if it does not exist
	local ply = LocalPlayer()
	ply.CH_ATM_Transactions = {}
	
	for i = 1, amount_of_entries do
		local action = net.ReadString()
		local amount = net.ReadDouble()
		local timestamp = net.ReadString()
	
		ply.CH_ATM_Transactions[ i ] = {
			Action = action,
			Amount = amount,
			TimeStamp = timestamp,
		}
	end

	CH_ATM.DebugPrint( "CLIENTSIDE ATM TRANSACTIONS FOR: ".. ply:Nick() )
	CH_ATM.DebugPrint( ply.CH_ATM_Transactions )
end )