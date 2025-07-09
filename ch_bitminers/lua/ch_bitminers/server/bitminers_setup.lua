print( "[BITMINERS BY CRAP-HEAD] Initializing Script" )

-- Workshop content
resource.AddWorkshop( "2072136134" )

-- Network strings
util.AddNetworkString( "CH_BITMINERS_UpdateBitcoinRates" )
util.AddNetworkString( "CH_BITMINERS_CryptoOptions" )
util.AddNetworkString( "CH_BITMINERS_CryptoIntegration_SelectCrypto" )

local map = string.lower( game.GetMap() )

-- Initialize
local function CH_BITMINERS_Initialize()
	timer.Simple( 5, function()
		if not CH_Bitminers.Config.IntegrateCryptoCurrencies then
			CH_Bitminers.RandomizeBitcoinRate()
		end
		
		-- Spawn bitcoin rate screens
		if not file.IsDir( "craphead_scripts/ch_bitminers/".. map .."/screens/", "DATA" ) then
			file.CreateDir( "craphead_scripts/ch_bitminers/".. map .."/screens/", "DATA" )
		end
		
		CH_Bitminers.SpawnBitcoinScreens()
	end )
end
hook.Add( "Initialize", "CH_BITMINERS_Initialize", CH_BITMINERS_Initialize )

print( "[BITMINERS BY CRAP-HEAD] Initialized" )