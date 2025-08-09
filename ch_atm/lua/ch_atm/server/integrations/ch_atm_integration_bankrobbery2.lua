--[[
	Third party support for bank robbery system 2
	Decrease online players bank interest when a robbery is successful
--]]
function CH_ATM.BankRobbery2_ModifyInterest( robber, amount_stolen )
	CH_ATM.DebugPrint( "CH_ATM.BankRobbery2_ModifyInterest" )
	CH_ATM.DebugPrint( robber )
	CH_ATM.DebugPrint( amount_stolen )
	
	-- Setup variables
	local interest_to_take = CH_ATM.Config.InterestToTakeOnBankRobbery
	local money_percent_to_take = CH_ATM.Config.MoneyPercentToTakeOnBankRobbery
	
	-- Loop through all players to take interest and money (if enabled)
	for k, ply in ipairs( player.GetAll() ) do
		-- Take a percentage of everyones money
		if money_percent_to_take > 0 then
			local ply_bank_account = CH_ATM.GetMoneyBankAccount( ply )
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
hook.Add( "CH_BankRobbery2_bLogs_RobberySuccessful", "CH_ATM.BankRobbery2_ModifyInterest", CH_ATM.BankRobbery2_ModifyInterest )