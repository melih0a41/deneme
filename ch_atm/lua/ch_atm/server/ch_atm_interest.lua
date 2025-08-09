--[[
	Generate interest in bank accounts for online players
--]]
function CH_ATM.GenerateInterestPlayer( ply )
	-- Stop if not ply is valid
	if not IsValid( ply ) then
		return
	end
	
	-- Get players bank account amount
	local ply_bank_account = CH_ATM.GetMoneyBankAccount( ply )
	
	-- No interest if no money in bank
	if ply_bank_account <= 0 then
		return
	end
	
	-- Get players interest rate
	local interest_percentage = CH_ATM.GetAccountInterestRate( ply )
	
	-- How much interest to gain based on config percentage and money in bank
	local interest_to_gain = math.Round( ( ply_bank_account / 100 ) * interest_percentage )
	
	-- No interest to gain
	if interest_to_gain <= 0 then
		return
	end
	
	local max_interest = CH_ATM.GetMaxInterestToEarn( ply )
	
	if max_interest > 0 then
		interest_to_gain = math.Clamp( interest_to_gain, 0, max_interest )
	end
	
	-- Stop here if interest_to_gain + bank account is over max.
	local max_money = CH_ATM.GetAccountMaxMoney( ply )
	
	if max_money != 0 then
		-- If there is a maximum then
		if ( ply_bank_account + interest_to_gain ) > max_money then
			CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have not earned interest due to your account maximum being reached." ) )
			return
		end
	end
	
	-- Add interest money to bank account
	CH_ATM.AddMoneyToBankAccount( ply, interest_to_gain )
	
	-- Notify player
	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Interest for having money in your bank account has been paid." ) )
	CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have received" ) .." ".. CH_ATM.FormatMoney( interest_to_gain ) )
end

--[[
	Function to increase interest rate for the player
--]]
function CH_ATM.IncreaseInterestRate( ply, amount )
	if not IsValid( ply ) then
		return
	end

	CH_ATM.SetInterestRate( ply, CH_ATM.GetAccountInterestRate( ply ) + amount, true )
end

--[[
	Function to decrease interest rate for the player
--]]
function CH_ATM.DecreaseInterestRate( ply, amount )
	if not IsValid( ply ) then
		return
	end

	local new_interest = math.max( CH_ATM.GetAccountInterestRate( ply ) - amount, 0 )
	CH_ATM.SetInterestRate( ply, new_interest, true )
end

--[[
	Function to set interest rate for the player
--]]
function CH_ATM.SetInterestRate( ply, amount, notify )
	if not IsValid( ply ) then
		return
	end
	
	-- Update variable
	ply.CH_ATM_InterestRate = amount
	
	-- Notify player
	if notify then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your interest rate has been updated." ) )
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Your interest rate is now" ) .." ".. ply.CH_ATM_InterestRate )
	end

	-- Network it
	net.Start( "CH_ATM_Net_NetworkInterestRate" )
		net.WriteDouble( ply.CH_ATM_InterestRate )
	net.Send( ply )
end