--[[
	Network leaderboard to the client
--]]
function CH_ATM.NetworkLeaderboard( ply )
	CH_ATM.DebugPrint( "SERVERSIDE ATM LEADERBOARD NETWORKED TO: ".. ply:Nick() )

	-- Select query to get their transactions and write the table.
	CH_ATM.SQL.Query( "SELECT * FROM ch_atm_accounts ORDER BY amount DESC LIMIT 10;", function( data )
		if data then
			CH_ATM.DebugPrint( data )
			
			local table_length = #data
			
			-- Network it to the client as efficient as possible
			net.Start( "CH_ATM_Net_NetworkLeaderboard" )
				net.WriteUInt( table_length, 4 )

				for key, trans in ipairs( data ) do
					if trans.nick then
						net.WriteString( trans.nick )
					else
						net.WriteString( "N/A" )
					end
					net.WriteDouble( trans.amount )
				end
			net.Send( ply )
		end
	end, false )
end

--[[
	A function nessessary to update the sql tables if the nick column does not exist
--]]
function CH_ATM.AlterSQLToAddNick()
	CH_ATM.SQL.Query( "SELECT * FROM ch_atm_accounts;", function( data )
		if data then
			if not data.nick then
				CH_ATM.SQL.Query( "ALTER TABLE ch_atm_accounts ADD nick VARCHAR(40);" )
			end
		end
	end, true )
end