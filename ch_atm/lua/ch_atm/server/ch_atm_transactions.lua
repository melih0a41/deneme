--[[
	Logging transactions to the SQL database
--]]
function CH_ATM.LogSQLTransaction( ply, action, amount )
	local timestamp = os.date( "%Y/%m/%d %X", os.time() )

	-- Write new transaction for player
	CH_ATM.SQL.Query( "INSERT INTO ch_atm_transactions ( action, amount, timestamp, steamid ) VALUES( '" .. action .. "', '" .. amount .. "', '" .. timestamp .. "', '" .. ply:SteamID64() .. "' );" )
	
	-- Network it
	CH_ATM.NetworkTransactionsSQL( ply )
end

--[[
	Network transaction to the client
--]]
function CH_ATM.NetworkTransactionsSQL( ply )
	CH_ATM.DebugPrint( "SERVERSIDE ATM TRANSACTIONS FOR: ".. ply:Nick() )

	-- Select query to get their transactions and write the table.
	CH_ATM.SQL.Query( "SELECT * FROM ch_atm_transactions WHERE steamid = '" .. ply:SteamID64() .. "' ORDER BY timestamp DESC LIMIT " .. CH_ATM.Config.MaximumTransactionsToShow .. ";", function( data )
		if data then
			CH_ATM.DebugPrint( data )
			
			local table_length = #data
			
			-- Network it to the client as efficient as possible
			net.Start( "CH_ATM_Net_NetworkTransactions" )
				net.WriteUInt( table_length, 6 )

				for key, trans in ipairs( data ) do
					net.WriteString( trans.action )
					net.WriteDouble( trans.amount )
					net.WriteString( trans.timestamp )
				end
			net.Send( ply )
		end
	end, false )
end