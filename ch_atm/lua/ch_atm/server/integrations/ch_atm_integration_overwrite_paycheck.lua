--[[
	This will overwrite the salary and add the money to their bank account instead
--]]
function CH_ATM.SendSalaryToBank( ply, amount )
	if not CH_ATM.Config.SendPaycheckToBank then
		return
	end
	
	if CH_ATM.GetMoneyBankAccount( ply ) == CH_ATM.GetAccountMaxMoney( ply ) then
		return
	end
	
	-- Money they have before they get paid
	local before_pay = ply:getDarkRPVar( "money" )
	
	timer.Simple( 0.1, function()
		if IsValid( ply ) then
			-- Now check how much money they have after pay and deduct the money from before
			local after_pay = ply:getDarkRPVar( "money" ) - before_pay

			-- Remove the money from wallet
			ply:addMoney( -after_pay )
			
			-- Add money to bank account
			CH_ATM.AddMoneyToBankAccount( ply, after_pay )
			
			-- Notify player
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your paycheck has been sent to your bank account." ) )
			
			-- bLogs support
			hook.Run( "CH_ATM_bLogs_ReceiveMoney", amount, ply, "Received from paycheck" )
		end
	end )
end
hook.Add( "playerGetSalary", "CH_ATM.SendSalaryToBank", CH_ATM.SendSalaryToBank )