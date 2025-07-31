CH_ATM.Leaderboard = CH_ATM.Leaderboard or {}

--[[
	Receive the leaderboard and update the CL table
--]]
net.Receive( "CH_ATM_Net_NetworkLeaderboard", function( len, ply )
	local ply = LocalPlayer()
	local amount_of_entries = net.ReadUInt( 4 )
	
	for i = 1, amount_of_entries do
		CH_ATM.Leaderboard[ i ] = {
			Name = net.ReadString(),
			Amount = net.ReadDouble(),
		}
	end

	CH_ATM.DebugPrint( "CLIENTSIDE ATM LEADERBOARD NETWORKED FOR: ".. ply:Nick() )
	CH_ATM.DebugPrint( CH_ATM.Leaderboard )
end )