--[[
	Third party support for OnePrint
	This will take the money from the player that they were just given in the OnePrint code and instead add it to their bank accounts
--]]
function CH_ATM.WithdrawMoney_OnePrint( ply, amount, printer )
	if CH_ATM.Config.WithdrawToBankFromPrinter then
		-- First remove the money that was added from OnePrint withdrawal code
		ply:addMoney( -amount )
		
		-- Add money to bank account
		CH_ATM.AddMoneyToBankAccount( ply, amount )
		
		-- Notify player
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The money has been sent to your bank account." ) )
		
		-- bLogs support
		hook.Run( "CH_ATM_bLogs_ReceiveMoney", amount, ply, "Withdraw from money printer" )
	end
end
hook.Add( "OnePrint_OnWithdraw", "CH_ATM.WithdrawMoney_OnePrint", CH_ATM.WithdrawMoney_OnePrint )

--[[
	Send money from default money printer to bank instead of spawning a money bag
--]]
function CH_ATM.DefaultPrinter_AddToBank( printer, moneybag )
	if CH_ATM.Config.WithdrawToBankFromPrinter then
		local amount = moneybag:Getamount()
		local ply = printer:Getowning_ent()
		
		if not IsValid( ply ) then
			return
		end
		
		-- Add money to bank account
		CH_ATM.AddMoneyToBankAccount( ply, amount )
		
		-- Notify player
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your money printer has printed" ) .." ".. CH_ATM.FormatMoney( amount ) )
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The money has been sent to your bank account." ) )
		
		-- bLogs support
		hook.Run( "CH_ATM_bLogs_ReceiveMoney", amount, ply, "Sent directly to bank from money printer" )
		
		moneybag:Remove()
	end
end
hook.Add( "moneyPrinterPrinted", "CH_ATM.DefaultPrinter_AddToBank", CH_ATM.DefaultPrinter_AddToBank )