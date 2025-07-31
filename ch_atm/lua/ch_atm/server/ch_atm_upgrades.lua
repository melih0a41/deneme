--[[
	Upgrade the players bank account to the next level
--]]
net.Receive( "CH_ATM_Net_UpgradeBankAccountLevel", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	local next_level = CH_ATM.GetAccountLevel( ply ) + 1
	
	if not CH_ATM.Config.AccountLevels[ next_level ] then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your account cannot be upgraded anymore!" ) )
		return
	end
	
	local upgrade_price = CH_ATM.Config.AccountLevels[ next_level ].UpgradePrice
	
	-- Perform a series of security checks before completing.
	if upgrade_price > CH_ATM.GetMoneyBankAccount( ply ) then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You don't have this much money!" ) )
		return
	end
	
	if not CH_ATM.IsPlayerCloseToAnATM( ply ) then
		return
	end
	
	-- If all checks passed then increase their level by 1
	ply.CH_ATM_BankAccountLevel = next_level
	
	-- Set new interest rate
	CH_ATM.SetInterestRate( ply, CH_ATM.Config.AccountLevels[ CH_ATM.GetAccountLevel( ply ) ].InterestRate, true )
	
	-- Take money from their bank account (will also save)
	CH_ATM.TakeMoneyFromBankAccount( ply, upgrade_price )
	
	-- bLogs support
	hook.Run( "CH_ATM_bLogs_TakeMoney", upgrade_price, ply, "Upgraded their bank account to level ".. next_level )
	
	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your bank account has been upgraded to level" ) .." ".. next_level )
	CH_ATM.NotifyPlayer( ply, CH_ATM.FormatMoney( upgrade_price ) .." ".. CH_ATM.LangString( "has been deducted from your bank account." ) )
end )