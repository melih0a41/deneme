function CH_Bitminers.RandomizeBitcoinRate()
	timer.Create( "ch_bitminers_randomize_rate", CH_Bitminers.Config.RateRandomizeInterval, 0, function()
		local current_rate = CH_Bitminers.Config.BitcoinRate
		local randomized_change = math.random( -CH_Bitminers.Config.RateUpdateInterval, CH_Bitminers.Config.RateUpdateInterval )
		
		-- Update bitcoin rate
		CH_Bitminers.Config.BitcoinRate = math.Clamp( CH_Bitminers.Config.BitcoinRate + randomized_change, CH_Bitminers.Config.MinBitcoinRate, CH_Bitminers.Config.MaxBitcoinRate )

		-- Network bitcoin rate
		net.Start( "CH_BITMINERS_UpdateBitcoinRates" )
			net.WriteUInt( CH_Bitminers.Config.BitcoinRate, 20 )
		net.Broadcast()
	end )
end

--[[
	Delete bitminer entities on disconnect/team change if enabled.
--]]
CH_Bitminers.SpawnedEntities = CH_Bitminers.SpawnedEntities or {}

local function CH_BITMINERS_RemoveAllEntitiesDC( ply )
	if CH_Bitminers.Config.RemoveEntsOnDC then
		for ent, v in pairs( CH_Bitminers.SpawnedEntities ) do
			local ent_owner = ent:CPPIGetOwner()
			
			if ent_owner == ply then
				ent:Remove()
			end
		end
	end
end
hook.Add( "PlayerDisconnected", "CH_BITMINERS_RemoveAllEntitiesDC", CH_BITMINERS_RemoveAllEntitiesDC )

local function CH_BITMINERS_RemoveAllEntitiesTeamChange( ply, before, after )
	if CH_Bitminers.Config.RemoveEntsOnTeamChange then
		for ent, v in pairs( CH_Bitminers.SpawnedEntities ) do
			local ent_owner = ent:CPPIGetOwner()
			
			if ent_owner == ply then
				ent:Remove()
			end
		end
	end
end
hook.Add( "OnPlayerChangedTeam", "CH_BITMINERS_RemoveAllEntitiesTeamChange", CH_BITMINERS_RemoveAllEntitiesTeamChange )

--[[
	Notification function based on the current gamemode
--]]
function CH_Bitminers.NotifyPlayer( ply, text )
	if DarkRP then
		DarkRP.notify( ply, 3, CH_Bitminers.Config.NotificationTime, text )
	else
		ply:ChatPrint( text )
	end
end