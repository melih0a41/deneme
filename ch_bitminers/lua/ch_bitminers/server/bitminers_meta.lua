local PMETA = FindMetaTable( "Player" )

function PMETA:CH_Bitminers_RewardXP( amount )
	local ply = self
	
	-- Give XP (Vronkadis DarkRP Level System)
	if CH_Bitminers.Config.DarkRPLevelSystemEnabled then
		ply:addXP( amount, false )
	end
	
	-- Give XP (Sublime Levels)
	if CH_Bitminers.Config.SublimeLevelSystemEnabled then
		ply:SL_AddExperience( amount, "XP rewarded")
	end
	
	-- Give XP (Elite XP system)
	if CH_Bitminers.Config.EXP2SystemEnabled then
		EliteXP.CheckXP( ply, amount )
	end
	
	-- Give XP (DarkRP essentials & Brick's Essentials)
	if CH_Bitminers.Config.EssentialsXPSystemEnabled then
		ply:AddExperience( amount, "XP rewarded" )
	end

	-- Give XP (GlorifiedLeveling)
	if CH_Bitminers.Config.GlorifiedLevelingXPSystemEnabled then
		GlorifiedLeveling.AddPlayerXP( ply, amount )
	end
end

function PMETA:CH_Bitminers_BitcoinsMinedPerInterval( crypto_index )
	local ply = self
	
	if CH_Bitminers.Config.IntegrateCryptoCurrencies and CH_CryptoCurrencies then
		-- If we have crypto addon we're going to calculate a different coins mined
		
		-- Grab the crypto price and how many USD to mine per interval
		local crypto_price = tonumber( CH_CryptoCurrencies.Cryptos[ crypto_index ].Price )
		local usd_to_mine = CH_Bitminers.Config.IntegrateCryptoMinedPer[ ply:GetUserGroup() ] or CH_Bitminers.Config.IntegrateCryptoDefaultMinedPer

		-- How many coins to mine is based on the USD and the crypto price.
		local to_mine = math.Round( usd_to_mine / crypto_price, 7 )
		
		-- If the API has not loaded (for some odd reason) then change the to_mine to 0 or else it will mine way too many coins
		if crypto_price <= 0 then
			to_mine = 0
		end
		
		return to_mine
	else
		return CH_Bitminers.Config.BitcoinsMinedPer[ ply:GetUserGroup() ] or CH_Bitminers.Config.DefaultBitcoinsMinedPer
	end
end