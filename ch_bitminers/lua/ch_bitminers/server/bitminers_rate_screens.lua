local map = string.lower( game.GetMap() )

function CH_Bitminers.SpawnBitcoinScreens()
	for k, v in ipairs( file.Find( "craphead_scripts/ch_bitminers/".. map .."/screens/bitcoin_screen_*.txt", "DATA" ) ) do
		local PositionFile = file.Read( "craphead_scripts/ch_bitminers/".. map .."/screens/".. v, "DATA" )

		local ThePosition = string.Explode( ";", PositionFile )

		local TheVector = Vector( ThePosition[1], ThePosition[2], ThePosition[3] )
		local TheAngle = Angle( ThePosition[4], ThePosition[5], ThePosition[6] )

		local BitcoinScreen = ents.Create( "ch_bitminer_bitcoin_screen" )
		BitcoinScreen:SetPos( TheVector )
		BitcoinScreen:SetAngles( TheAngle )
		BitcoinScreen:Spawn()
		timer.Simple( 1, function()
			if IsValid( BitcoinScreen ) then
				BitcoinScreen:SetMoveType( MOVETYPE_NONE )
			end
		end )
	end
end

function CH_Bitminers.SaveBitcoinScreens( ply, cmd, args )
	if not ply:IsAdmin() then
		CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "Only administrators can perform this action" ) )
		return
	end
	
	for k, v in ipairs( file.Find( "craphead_scripts/ch_bitminers/".. map .."/screens/bitcoin_screen_*.txt", "DATA" ) ) do
		file.Delete( "craphead_scripts/ch_bitminers/".. map .."/screens/".. v )
	end
	
	for k, ent in ipairs( ents.FindByClass( "ch_bitminer_bitcoin_screen" ) ) do
		local ScreenVector = string.Explode( " ", tostring( ent:GetPos() ) )
		local ScreenAngles = string.Explode( " ", tostring( ent:GetAngles() ) )
		
		file.Write( "craphead_scripts/ch_bitminers/".. map .."/screens/bitcoin_screen_".. math.random( 1, 9999999 ) ..".txt", ""..(ScreenVector[1])..";"..(ScreenVector[2])..";"..(ScreenVector[3])..";"..(ScreenAngles[1])..";"..(ScreenAngles[2])..";"..(ScreenAngles[3]).."", "DATA" )
	end
	
	CH_Bitminers.NotifyPlayer( ply, CH_Bitminers.LangString( "All bitcoin rate screens have been saved!" ) )
end
concommand.Add( "ch_bitminer_save_screens", CH_Bitminers.SaveBitcoinScreens )

-- Respawn bitcoin screens
function CH_Bitminers.RespawnEntsCleanup()
	print( "[BITMINERS BY CRAP-HEAD] - Map cleaned up. Respawning bitcoin exchange rate screens..." )

	timer.Simple( 1, function()
		CH_Bitminers.SpawnBitcoinScreens()
	end )
end
hook.Add( "PostCleanupMap", "CH_Bitminers.RespawnEntsCleanup", CH_Bitminers.RespawnEntsCleanup )