--[[
	Add money to bank account
--]]
function CH_ATM.AddMoneyToBankAccount( ply, amount )
	-- Safety control checks
	if not ply:IsPlayer() then
		return
	end
	
	-- All checks passed
	ply.CH_ATM_BankAccount = CH_ATM.GetMoneyBankAccount( ply ) + amount
	
	-- Check if the account has a limit above 0 (0 is unlimited)
	local max_money = CH_ATM.GetAccountMaxMoney( ply )
	
	if max_money != 0 then
		-- Check if remaining money should be paid out to wallet
		if CH_ATM.Config.PayoutMoneyToWalletIfMax then
			-- If yes then calculate remaining money
			local remaining_money = CH_ATM.GetMoneyBankAccount( ply ) - max_money
			
			-- If there are remaining money then payout to wallet and notify player
			if remaining_money > 0 then
				CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "The remaining amount has been paid out to your wallet. Wallet credited with" ) .." ".. CH_ATM.FormatMoney( remaining_money ) )
			
				-- Payout remaining money to wallet
				CH_ATM.AddMoney( ply, remaining_money )
			end
		end
		
		-- If there is a maximum then clamp the account money and notify the owner.
		if CH_ATM.GetMoneyBankAccount( ply ) > max_money then
			-- Clamp the account to the max and notify the player
			ply.CH_ATM_BankAccount = math.Clamp( CH_ATM.GetMoneyBankAccount( ply ), 0, max_money )
			
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your bank account holding has gone above your maximum of" ) .." ".. CH_ATM.FormatMoney( max_money ) )
			
			-- If not remaining money should be paid to wallet then notify owner that their money was capped
			if not CH_ATM.Config.PayoutMoneyToWalletIfMax then
				CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your bank account cannot receive more money and it has been set to your maximum." ) )
			end
			
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Upgrade your account to increase your max holding." ) )
		end
	end
	
	-- Save players bank account
	CH_ATM.SavePlayerBankAccount( ply )
	
	-- Network it
	CH_ATM.NetworkBankAccountToPlayer( ply )
end

--[[
	Take money from bank account
--]]
function CH_ATM.TakeMoneyFromBankAccount( ply, amount )
	-- Safety control checks
	if not ply:IsPlayer() then
		return
	end

	-- All checks passed (clamp it at 0 so it never goes negative)
	local new_money = CH_ATM.GetMoneyBankAccount( ply ) - amount
	ply.CH_ATM_BankAccount = math.Clamp( new_money, 0, 999999999999999999 )
	
	-- Save players bank account
	CH_ATM.SavePlayerBankAccount( ply )
	
	-- Network it
	CH_ATM.NetworkBankAccountToPlayer( ply )
end