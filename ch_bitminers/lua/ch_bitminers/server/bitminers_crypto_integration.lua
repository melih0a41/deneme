net.Receive( "CH_BITMINERS_CryptoIntegration_SelectCrypto", function( length, ply )
	-- Check enabled
	if not CH_Bitminers.Config.IntegrateCryptoCurrencies then
		return
	end

	local bitminer = net.ReadEntity()
	local crypto_index = net.ReadUInt( 6 )

	-- Security
	if not IsValid( bitminer) or ( IsValid( bitminer ) and bitminer:GetClass() != "ch_bitminer_shelf" ) then
		return
	end

	if ply:GetPos():DistToSqr( bitminer:GetPos() ) > 10000 then
		return
	end

	-- If the bitminer is not hacked, only allow the owner to access it.
	if not bitminer:GetIsHacked() then -- if not hacked
		if ply !=  bitminer:CPPIGetOwner() then -- person trying to access is not owner
			CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "Only the owner of this bitminer can access it!" ) )
			return
		end
	end

	-- Withdraw before changing
	if bitminer:GetBitcoinsMined() > 0 then
		bitminer:WithdrawInCrypto( ply )
	end
	
	-- Change the crypto in the bitminer and let the player know
	bitminer:SetCryptoIntegrationIndex( crypto_index )
	CH_Bitminers.NotifyPlayer( ply, CH_CryptoCurrencies.LangString( "Your bitminer is now mining" ) .." ".. CH_CryptoCurrencies.Cryptos[ crypto_index ].Name )
end )