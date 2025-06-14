-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

if !SH_ANTICRASH.SETTINGS.DARKRP.AFFECTF4ENTITIES then return end

local function SetDataAndCallback(ply,ent)

	if !ent:z_anticrashHasCreator() then
		
		ent:z_anticrashSetCreator(ply)
		
		ent:AddCallback("PhysicsCollide",function(ent, data)
			SV_ANTICRASH.UpdateCollisionData(ent, data)
		end)
		
	end

end

// Ents using basic spawn hooks
local function SetCreatorOnCreation(ply, ...)

	local args = {...}
	local ent = nil
	
	for i=1, #args do
		
		local arg = args[i]
		
		if IsEntity(arg) then
			ent = arg
			break
		end
		
	end
	
	if IsValid(ply, ent) then
		SetDataAndCallback(ply, ent)
	end
	
end

for i=1, #SH_ANTICRASH.SETTINGS.DARKRP.F4SPAWNHOOKS do
	hook.Add(SH_ANTICRASH.SETTINGS.DARKRP.F4SPAWNHOOKS[i],"z_anticrash_SetCreatorOnCreation",SetCreatorOnCreation)
end