-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

if !duplicator then return end

duplicator.__oldPaste = duplicator.__oldPaste or duplicator.Paste

duplicator.Paste = function(ply, entityList, constraintList)

	-- Persistent props
	if !IsValid(ply) then 
		return duplicator.__oldPaste(ply, entityList, constraintList)
	end
	
	-- Disable dupes if disabled
	if !SH_ANTICRASH.SETTINGS.DUPES.ENABLE then
		SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,"#dupesNotEnabled")
		return {}, {}
	end
	
	-- Check if ent count is below limit
	local entCount = table.Count(entityList)
	local propCount = 0
	local limitCount = entCount
	
	if SH_ANTICRASH.SETTINGS.DUPES.SIZELIMITPROPSONLY then
		for key, ent in pairs(entityList) do
			if ent.Class == "prop_physics" then
				propCount = propCount + 1
			end
		end
		limitCount = propCount
	end
	
	if limitCount > SH_ANTICRASH.SETTINGS.DUPES.SIZELIMIT then
		SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,"##dupeExceedsSize %"..limitCount.." %"..SH_ANTICRASH.SETTINGS.DUPES.SIZELIMIT)
		return {}, {}
	end
	
	-- Constraint limits
	local ropeCount = 0
	for key, constr in pairs(constraintList) do
		if constr.Type == "Rope" then
			ropeCount = ropeCount + 1
		end
	end
	
	if ropeCount > SH_ANTICRASH.SETTINGS.DUPES.ROPELIMIT then
		SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,"##dupeExceedsRopeLimit %"..ropeCount.." %"..SH_ANTICRASH.SETTINGS.DUPES.ROPELIMIT)
		return {}, {}
	end  
	
	local fixedConstraintList = table.Copy(constraintList)
	local constraintCount = table.Count(fixedConstraintList)
	
	// Crash dupe reverse engineering
	//file.Write( "all_constraint_data.txt", table.ToString(fixedConstraintList, "Constraints", true))
	
	-- Constraint manipulation
	for key, constr in pairs(fixedConstraintList) do
	
		// Axis crash exploit
		if constr.Type == "Axis" and istable(constr.Entity) then
			for _, ent in pairs(constr.Entity) do
				if ent.LPos ~= nil then
					ent.LPos = constraint.z_anticrash_GetClampedAxisPos(ent.LPos);
				end
			end
		end
	
		constr.__creator = ply
	end
	
	-- Force proper vehicle models
	SV_ANTICRASH.UTILS.ForceDupeVehicleModel(entityList)
	
	//local crashEnts = 0
	
	for entID, ent in pairs(entityList) do
		
		// Crash dupe reverse engineering
		/*
		if crashEnts < 2 and ent.EntityMods ~= nil and ent.EntityMods.colour ~= nil and ent.EntityMods.colour.Color.a == 0 then
			ent.EntityMods.material.MaterialOverride = "models/shiny"
			ent.EntityMods.colour.Color = Color(255,0,0,255)
			ent.Model =	"models/mechanics/robotics/c2.mdl"
			crashEnts = crashEnts + 1
			//PrintTable(ent)
		else
			//entityList[entID] = nil
			//continue
		end
		*/
		
		-- Remove blocked entities
		if SH_ANTICRASH.SETTINGS.BLOCKEDENTITIES[ent.Class] or SH_ANTICRASH.SETTINGS.BLOCKEDENTITIES[ent.ClassName] then
			entityList[entID] = nil
			continue
		end
 
		-- Replace error models
		if ent.Model ~= nil and SH_ANTICRASH.SETTINGS.DUPES.REPLACEINVALIDMODELS then
			if !util.IsValidModel(ent.Model) then
				-- Invalid constraints on missing entities --> do_constraint_system: Couldn't invert rot matrix!
				-- entityList[entID] = nil
				
				if ent.Class == "prop_effect" then
					entityList[entID] = nil
				else
					ent.Model = SH_ANTICRASH.SETTINGS.DUPES.INVALIDMODELREPLACEMENT
				end
			end
		end
			
		if ent.PhysicsObjects then
		
			for physObjI=0, #ent.PhysicsObjects do 
			
				local physObj = ent.PhysicsObjects[physObjI]
				
				if istable(physObj) then
					
					-- Freeze all entities with physics objects
					if SH_ANTICRASH.SETTINGS.DUPES.FREEZE then
						physObj.Frozen = true
						physObj.Sleep = true
					end
					
					ent.__pos = physObj.Pos
					
				end

			end
			
		end
	
	end
	
	if SH_ANTICRASH.SETTINGS.DUPES.NOCOLLIDE then
	
		-- Second loop when we have all our ent positions to compare distance
		for entID, ent in pairs(entityList) do
	
			for entID2, ent2 in pairs(entityList) do
			
				-- NoCollide neighboring ents
				if ent == ent2 or !ent.__pos or !ent2.__pos or ent.__pos:Distance(ent2.__pos) > 100 then
					continue
				end
				
				-- Create nocollide constraints between ents
				local noCollideConstraint = {
					Type = "NoCollide",
					nocollide = true,
					Bone1 = 0,
					Bone2 = 0,
					Entity = {
						[1] = {
							Bone = 0,
							Index = entID,
							World = false
						},
						[2] = {
							Bone = 0,
							Index = entID2,
							World = false
						}
					}
				}
				
				table.insert(fixedConstraintList,noCollideConstraint)
			end
		end
	end
	
	local plyFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)
	SH_ANTICRASH.UTILS.LOG.Print("##dupeInformation %"..plyFormat.." %"..entCount.." %"..constraintCount)
	
	local createdEnts, createdConstraints = duplicator.__oldPaste(ply, entityList, fixedConstraintList)
	
	-- Ghost
	if SH_ANTICRASH.SETTINGS.DUPES.GHOST then
		for k, ent in pairs(createdEnts) do
			SV_ANTICRASH.SetGhostEntity(ent,true)
		end
	end
	
	return createdEnts, createdConstraints

end 

// Constraint owner
duplicator.__oldCreateConstraintFromTable = duplicator.__oldCreateConstraintFromTable or duplicator.CreateConstraintFromTable

duplicator.CreateConstraintFromTable = function (constStruct, entityList)
	
	local const = nil
	ProtectedCall( function() const = duplicator.__oldCreateConstraintFromTable(constStruct, entityList) end )
	
	if IsValid(const,constStruct.__creator) and IsEntity(const) then
		const:z_anticrashSetCreator(constStruct.__creator)
	end

	return const

end