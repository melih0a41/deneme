-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]


local function CanArmDupe(ply)
	
	-- Prevent dupes from being downloaded if disabled
	if !SH_ANTICRASH.SETTINGS.DUPES.ENABLE then
		return false
	end

end
hook.Add("CanArmDupe","cl_anticrash_CanArmDupe",CanArmDupe)

/*
-- local __oldOpenDupe = engine.OpenDupe
__oldOpenDupe = __oldOpenDupe or engine.OpenDupe

engine.OpenDupe = function(dupeName)
	
	local compressedDupe = __oldOpenDupe(dupeName)
	
	-- Default dupe error handling
	if ( !compressedDupe ) then
		MsgN( "Error loading dupe.. (", dupeName, ")" )
		return
	end

	if ( #compressedDupe > 64000 && !game.SinglePlayer() ) then
		LocalPlayer():ChatPrint( "That dupe is too large to spawn in multiplayer!" )
		return
	end
	
	local uncompressedDupe = util.Decompress( compressedDupe.data, 5242880 )
	
	if ( !uncompressedDupe ) then
		MsgN( "Couldn't decompress dupe!" )
		return
	end
	
	-- Check dupe data
	local dupe = util.JSONToTable( uncompressedDupe )
	PrintTable(dupe)
	
	-- Allow dupe to be spawned
	return compressedDupe

end
*/