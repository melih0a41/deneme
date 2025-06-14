-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local function SetDataAndCallback(ply,ent)

	if !ent:z_anticrashHasCreator() then
	
		ent:z_anticrashSetCreator(ply)
		ply.__lastSpawnedTime = CurTime()
	
		ent:AddCallback("PhysicsCollide",function(ent, data)
			SV_ANTICRASH.UpdateCollisionData(ent, data)
			SV_ANTICRASH.DoCollisionControl(ent, data)
		end)
		
		ply:z_anticrashIncreaseSpawnCount()
		SV_ANTICRASH.UpdateSpawnedCount()
		
		if SH_ANTICRASH.SETTINGS.FREEZEOBJECTSONSPAWN then
			
			local physObj = ent:GetPhysicsObject()
			
			if IsValid(physObj) then
				physObj:EnableMotion(false)
				physObj:Sleep()
			end 
		
		end
		
		if SH_ANTICRASH.SETTINGS.GHOSTOBJECTSONSPAWN and !SH_ANTICRASH.HasGProtectGhosting() then
			SV_ANTICRASH.SetGhostEntity(ent,true)
		end
		
		if SH_ANTICRASH.SETTINGS.NOCOLLISIONENTITIES[ent:GetClass()] then
			ent:SetCustomCollisionCheck(true)
		end
		
	end
	
end

// Ents using basic spawn hooks
local function SetCreatorOnCreation(ply, arg2, arg3)
	
	local ent = isentity(arg2) and arg2 or arg3
	
	if IsValid(ply, ent) then
		SetDataAndCallback(ply, ent)
	end
	
end

for i=1, #SH_ANTICRASH.VARS.HOOKS.SPAWNED do
	hook.Add(SH_ANTICRASH.VARS.HOOKS.SPAWNED[i],"z_anticrash_SetCreatorOnCreation",SetCreatorOnCreation)
end

// Ents not using the basic spawn hooks
if cleanup then

	cleanup.__oldAdd = cleanup.__oldAdd or cleanup.Add
	
	function cleanup.Add(ply, Type, ent)
	
		if IsValid(ply, ent) and ent ~= nil and IsEntity(ent) then
			SetDataAndCallback(ply, ent)
		end

		cleanup.__oldAdd(ply, Type, ent)
		
	end
	
end