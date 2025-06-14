-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

// Limit dupe size
local function AdvDupeHookInitQueue()
	
	if !AdvDupe2 then return end
	
	-- Prevent any freeze options from working
	local ply = FindMetaTable("Player")
	local __oldGetInfo = ply.GetInfo
	
	local forceDisabledConvars = {
		["advdupe2_paste_unfreeze"] = 0,
		["advdupe2_preserve_freeze"] = 0
	}
	
	-- Disable contraption spawner
	if !SH_ANTICRASH.SETTINGS.ADVDUPES.CONTRAPTIONSPAWNER then
		local maxContraptionEntities = GetConVar("AdvDupe2_MaxContraptionEntities")
		maxContraptionEntities:SetInt(0)
		local maxContraptionConstraints = GetConVar("AdvDupe2_MaxContraptionConstraints")
		maxContraptionEntities:SetInt(0)
	end
	
	function ply:GetInfo(str)
		
		if SH_ANTICRASH.SETTINGS.ADVDUPES.FREEZE and forceDisabledConvars[str] then
			return forceDisabledConvars[str]
		end
	
		return __oldGetInfo(self, str)
	
	end
	
	if !AdvDupe2.InitPastingQueue then return end
	
	AdvDupe2.__oldInitPastingQueue = AdvDupe2.__oldInitPastingQueue or AdvDupe2.InitPastingQueue
	
	AdvDupe2.InitPastingQueue = function(ply,...)

		if ply and ply.AdvDupe2 and ply.AdvDupe2.Entities and ply.AdvDupe2.Constraints then

			if !SH_ANTICRASH.SETTINGS.ADVDUPES.ENABLE then
				SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,"#advDupesNotEnabled")
				ply.AdvDupe2.Pasting = false
				return
			end
			
			-- Check if ent count is below limit
			local entityList = ply.AdvDupe2.Entities
			local entCount = table.Count(entityList)
			local propCount = 0
			local limitCount = entCount

			if SH_ANTICRASH.SETTINGS.ADVDUPES.SIZELIMITPROPSONLY then
				for key, ent in pairs(entityList) do
					if ent.Class == "prop_physics" then
						propCount = propCount + 1
					end
				end
				limitCount = propCount
			end
			
			if limitCount > SH_ANTICRASH.SETTINGS.ADVDUPES.SIZELIMIT then
				SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,"##dupeExceedsSize %"..limitCount.." %"..SH_ANTICRASH.SETTINGS.ADVDUPES.SIZELIMIT)
				ply.AdvDupe2.Pasting = false
				return
			end
			
			-- Constraint limits
			local constraintList = ply.AdvDupe2.Constraints
			local ropeCount = 0
			
			for key, constr in pairs(constraintList) do
			
				// Rope limit
				if constr.Type == "Rope" then
					ropeCount = ropeCount + 1
				end
				
				// Axis crash exploit
				if constr.Type == "Axis" and istable(constr.Entity) then
					for _, ent in pairs(constr.Entity) do
						if ent.LPos ~= nil then
							ent.LPos = constraint.z_anticrash_GetClampedAxisPos(ent.LPos);
						end
					end
				end
			end
			
			if ropeCount > SH_ANTICRASH.SETTINGS.ADVDUPES.ROPELIMIT then
				SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,"##dupeExceedsRopeLimit %"..ropeCount.." %"..SH_ANTICRASH.SETTINGS.ADVDUPES.ROPELIMIT)
				return
			end
			
			-- Replace error models
			if SH_ANTICRASH.SETTINGS.DUPES.REPLACEINVALIDMODELS then
			
				for key, ent in pairs(entityList) do
				
					-- Remove blocked entities
					if SH_ANTICRASH.SETTINGS.BLOCKEDENTITIES[ent.Class] then
						entityList[key] = nil
						continue
					end
				
					if ent.Model ~= nil and !util.IsValidModel(ent.Model) then
						-- Invalid constraints on missing entities --> do_constraint_system: Couldn't invert rot matrix!
						-- entityList[key] = nil
						
						if ent.Class == "prop_effect" then
							entityList[key] = nil
						else
							ent.Model = SH_ANTICRASH.SETTINGS.ADVDUPES.INVALIDMODELREPLACEMENT
						end
					end
				end
			end
			
			-- Force proper vehicle models
			SV_ANTICRASH.UTILS.ForceDupeVehicleModel(entityList)
			
			local constraintCount = table.Count(constraintList)
			
			local plyFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)
			SH_ANTICRASH.UTILS.LOG.Print("##dupeInformation %"..plyFormat.." %"..entCount.." %"..constraintCount)
		
		end
		
		AdvDupe2.__oldInitPastingQueue(ply,...)
		
	end

end
hook.Add("Initialize","sv_anticrash_AdvDupeHookInitQueue",AdvDupeHookInitQueue)

local function AdvDupeFinishPasting(dupeTbl)
	
	local dupeTbl = (dupeTbl or {})[1]
	
	if !dupeTbl then return end
	
	local entTbl = dupeTbl.CreatedEntities or {}
	local sequentialCount, sequentialEntTbl = 0, {}
	local constraintTbl = dupeTbl.CreatedConstraints or {}
	local ply = dupeTbl.Player
	
	for _, ent in pairs(entTbl) do
			
		if !IsValid(ent) then continue end
		
		SV_ANTICRASH.SetGhostEntity(ent,SH_ANTICRASH.SETTINGS.ADVDUPES.GHOST)
		
		if SH_ANTICRASH.SETTINGS.ADVDUPES.FREEZE then
			local physObj = ent:GetPhysicsObject()
			
			if IsValid(physObj) and physObj:IsMotionEnabled() then
				physObj:EnableMotion(false)
				physObj:Sleep()
			end
		end
		
		if SH_ANTICRASH.SETTINGS.ADVDUPES.NOCOLLIDE then
			sequentialCount = sequentialCount + 1
			sequentialEntTbl[sequentialCount] = ent
		end
		
	end
	
	if SH_ANTICRASH.SETTINGS.ADVDUPES.NOCOLLIDE then
		SV_ANTICRASH.NoCollideEntities(true,sequentialEntTbl)
	end
	
	-- Set owner of constraints
	for _, const in pairs(constraintTbl) do
		if IsValid(const) then
			const:z_anticrashSetCreator(ply)
		end
	end

end
hook.Add("AdvDupe_FinishPasting", "sv_anticrash_AdvDupeFinishPasting",AdvDupeFinishPasting)