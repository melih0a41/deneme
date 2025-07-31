--[[
	Third party support for pVault
	Decrease online players bank interest when a robbery is successful
--]]
function CH_ATM.pVault_ModifyInterest( vault, robber )
	CH_ATM.DebugPrint( "CH_ATM.pVault_ModifyInterest" )
	CH_ATM.DebugPrint( vault )
	CH_ATM.DebugPrint( robber )
	
	local interest_to_take = CH_ATM.Config.InterestToTakeOnBankRobbery
	local money_percent_to_take = CH_ATM.Config.MoneyPercentToTakeOnBankRobbery
	
	-- Loop through all players to take interest and money (if enabled)
	for k, ply in ipairs( player.GetAll() ) do
		-- Take a percentage of everyones money
		if money_percent_to_take > 0 then
			local ply_bank_account = ply.CH_ATM_BankAccount
			local amount_to_take = math.Round( ( ply_bank_account / 100 ) * money_percent_to_take )

			if ply_bank_account > 0 then
				CH_ATM.TakeMoneyFromBankAccount( ply, amount_to_take )
				
				CH_ATM.NotifyPlayer( ply, "The bank has been robbed and you have lost ".. CH_ATM.FormatMoney( amount_to_take ) )
			end
		end
		
		-- Decrease interest for all online players
		if interest_to_take > 0 then
			CH_ATM.DecreaseInterestRate( ply, interest_to_take )
		end
	end
end
hook.Add( "pVaultVaultCracked", "CH_ATM.pVault_ModifyInterest", CH_ATM.pVault_ModifyInterest )

--"pVaultVaultCracked", vault, ply
--"pVaultMoneyCleaned", ply, money