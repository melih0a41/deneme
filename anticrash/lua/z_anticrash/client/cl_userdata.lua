
CL_ANTICRASH.USERDATA = {}

CL_ANTICRASH.USERDATA.COL = {
	ENTITIES = SH_ANTICRASH.VARS.COLOR.LIGHTYDARK,
	SPAWNEDENTS = SH_ANTICRASH.VARS.COLOR.LIGHTYDARK,
	PROPS = SH_ANTICRASH.VARS.COLOR.LIGHTYDARK,
	CONSTRAINTS = SH_ANTICRASH.VARS.COLOR.LIGHTYDARK,
}

function CL_ANTICRASH.USERDATA.GetEntityCount(ply)
	
	local entTbl = ents.GetAll()
	local entCount = 0
	
	for i=1, #entTbl do
		
		local ent = entTbl[i]
		
		if ent:z_anticrashGetCreator() == ply then
			entCount = entCount + 1
		end
	
	end
			
	return entCount
			
end

function CL_ANTICRASH.USERDATA.GetSpawnedEntitiesCount(ply)
	return ply:z_anticrashGetSpawnCount()
end

function CL_ANTICRASH.USERDATA.GetPropCount(ply)

	local entTbl = ents.GetAll()
	local propCount = 0
	
	for i=1, #entTbl do
		
		local ent = entTbl[i]
		local class = ent:GetClass()
		
		if ent:z_anticrashGetCreator() == ply and !ent:IsVehicle() and string.StartWith(class, "prop_") then
			propCount = propCount + 1
		end
	
	end
			
	return propCount

end

function CL_ANTICRASH.USERDATA.GetConstraintCount(ply)
	return ply:z_anticrashGetConstraintCount()
end
