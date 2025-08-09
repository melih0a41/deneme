-- This file will contain code to Import from other ATM's

--[[
	Import from Blue's ATM
--]]
net.Receive( "CH_ATM_Net_ConvertAccountsFromBlueATM", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	if not ply:CH_ATM_IsAdmin() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Only administrators can perform this action!" ) )
		return
	end
	
	if not BATM then
		CH_ATM.NotifyPlayer( ply, "Blue's ATM ".. CH_ATM.LangString( "is not installed on your server!" ) )
		return
	end
	
	if player.GetCount() > 1 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have to be alone on the server to do this!" ) )
		return
	end
	
	print( "[CH ATM - Import Data] - Transfer initialized." )
	print( "[CH ATM - Import Data] - Transfering from Blue's ATM." )
	
	-- Delete all records
	CH_ATM.SQL.Query( "DELETE FROM ch_atm_accounts;" )
	
	-- Write new
	CH_ATM.SQL.Query( "SELECT * FROM batm_personal_accounts;", function( data )
		for key, value in pairs( data ) do
			if value then
				local AccountInfo = util.JSONToTable( value.accountinfo )
				
				if not AccountInfo then
					continue
				end

				if not AccountInfo.IsGroup then
					CH_ATM.SQL.Query( "INSERT INTO ch_atm_accounts ( amount, level, steamid, nick ) VALUES( '" .. AccountInfo.balance .. "', 1, '" .. AccountInfo.ownerID .. "', 'N/A');" )
					
					print( "[CH ATM - Import Data] - Creating new account for ".. AccountInfo.ownerID .." with a balance of ".. AccountInfo.balance )
				end
			end
		end
		
		print( "[CH ATM - Import Data] - Transfering from Blue's ATM has finished successfully." )
		print( "[CH ATM - Import Data] - Please delete Blue's ATM from your server and restart it now." )
		
		ply:ChatPrint( CH_ATM.LangString( "Please check your server console for transfer output!" ) )
	end, false )
end )

--[[
	Import from Slown ATM
--]]
net.Receive( "CH_ATM_Net_ConvertAccountsFromSlownLS", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	if not ply:CH_ATM_IsAdmin() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Only administrators can perform this action!" ) )
		return
	end
	
	if not SlownLS then
		CH_ATM.NotifyPlayer( ply, "SlownLS ATM ".. CH_ATM.LangString( "is not installed on your server!" ) )
		return
	end
	
	if player.GetCount() > 1 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have to be alone on the server to do this!" ) )
		return
	end

	print( "[CH ATM - Import Data] - Transfer initialized." )
	print( "[CH ATM - Import Data] - Transfering from SlownLS ATM." )
	
	-- Delete all records
	CH_ATM.SQL.Query( "DELETE FROM ch_atm_accounts;" )
	
	-- Write new
	CH_ATM.SQL.Query( "SELECT * FROM slownls_atm_accounts;", function( data )
		for key, value in pairs( data ) do
			if value then
				CH_ATM.SQL.Query( "INSERT INTO ch_atm_accounts ( amount, level, steamid, nick ) VALUES( '" .. value.balance .. "', 1, '" .. value.steamid .. "', 'N/A');" )
				
				print( "[CH ATM - Import Data] - Creating new account for ".. value.steamid .." with a balance of ".. value.balance )
			end
		end
		
		print( "[CH ATM - Import Data] - Transfering from SlownLS ATM has finished successfully." )
		print( "[CH ATM - Import Data] - Please delete SlownLS ATM from your server and restart it now." )
		
		ply:ChatPrint( CH_ATM.LangString( "Please check your server console for transfer output!" ) )
	end, false )
end )

--[[
	Import from Better Banking
--]]
net.Receive( "CH_ATM_Net_ConvertAccountsFromBetterBanking", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	if not ply:CH_ATM_IsAdmin() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Only administrators can perform this action!" ) )
		return
	end
	
	if not BetterBanking then
		CH_ATM.NotifyPlayer( ply, "BetterBanking ".. CH_ATM.LangString( "is not installed on your server!" ) )
		return
	end
	
	if player.GetCount() > 1 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have to be alone on the server to do this!" ) )
		return
	end

	print( "[CH ATM - Import Data] - Transfer initialized." )
	print( "[CH ATM - Import Data] - Transfering from BetterBanking ATM." )
	
	-- Delete all records
	CH_ATM.SQL.Query( "DELETE FROM ch_atm_accounts;" )
	
	-- Write new
	CH_ATM.SQL.Query( "SELECT * FROM " ..BetterBanking.Config.MySQL.Details['prefix'] .."accounts".. ";", function( data )
		for key, value in pairs( data ) do
			if value then
				CH_ATM.SQL.Query( "INSERT INTO ch_atm_accounts ( amount, level, steamid, nick ) VALUES( '" .. value.balance .. "', 1, '" .. value.steamid .. "', 'N/A');" )
				
				print( "[CH ATM - Import Data] - Creating new account for ".. value.steamid .." with a balance of ".. value.balance )
			end
		end
		
		print( "[CH ATM - Import Data] - Transfering from BetterBanking ATM has finished successfully." )
		print( "[CH ATM - Import Data] - Please delete BetterBanking ATM from your server and restart it now." )
		
		ply:ChatPrint( CH_ATM.LangString( "Please check your server console for transfer output!" ) )
	end, false )
end )

--[[
	Import from GlorifiedBanking
--]]
net.Receive( "CH_ATM_Net_ConvertAccountsFromGlorifiedBanking", function( len, ply )
	local cur_time = CurTime()
	
	if ( ply.CH_ATM_NetDelay or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.CH_ATM_NetDelay = cur_time + 1
	
	if not ply:CH_ATM_IsAdmin() then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "Only administrators can perform this action!" ) )
		return
	end
	
	if not GlorifiedBanking then
		CH_ATM.NotifyPlayer( ply, "GlorifiedBanking ".. CH_ATM.LangString( "is not installed on your server!" ) )
		return
	end
	
	if player.GetCount() > 1 then
		CH_ATM.NotifyPlayer( ply, CH_ATM.LangString( "You have to be alone on the server to do this!" ) )
		return
	end

	print( "[CH ATM - Import Data] - Transfer initialized." )
	print( "[CH ATM - Import Data] - Transfering from GlorifiedBanking ATM." )
	
	-- Delete all records
	CH_ATM.SQL.Query( "DELETE FROM ch_atm_accounts;" )
	
	-- Write new
	CH_ATM.SQL.Query( "SELECT * FROM gb_players;", function( data )
		for key, value in pairs( data ) do
			if value then
				CH_ATM.SQL.Query( "INSERT INTO ch_atm_accounts ( amount, level, steamid, nick ) VALUES( '" .. value.Balance .. "', 1, '" .. value.SteamID .. "', 'N/A');" )
			
				print( "[CH ATM - Import Data] - Creating new account for ".. value.SteamID .." with a balance of ".. value.Balance )
			end
		end
		
		print( "[CH ATM - Import Data] - Transfering from GlorifiedBanking ATM has finished successfully." )
		print( "[CH ATM - Import Data] - Please delete GlorifiedBanking ATM from your server and restart it now." )
		
		ply:ChatPrint( CH_ATM.LangString( "Please check your server console for transfer output!" ) )
	end, false )
end )