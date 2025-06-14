-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

// Clean the entire map from all entities
function SV_ANTICRASH.CleanMap(force,hidePrint)
	
	if SH_ANTICRASH.SETTINGS.LAG.CLEANMAP or force then
	
		if !hidePrint then
			SH_ANTICRASH.UTILS.LOG.Print("#cleaningMap")
		end
		
		SV_ANTICRASH.RemoveEntities(true, true)
		
		game.CleanUpMap()
	
		-- No need to continue chain if the map is reset
		return true
	
	end

end

// Remove all player created entities
function SV_ANTICRASH.RemoveEntities(force, hidePrint)

	if !SH_ANTICRASH.SETTINGS.LAG.REMOVEENTS and !force then return end

	local entTbl = ents.GetAll()
	local count = 0
	
	for i=1, #entTbl do
		
		local ent = entTbl[i]
		
		if ent:z_anticrashIsValidEnt() then
			SafeRemoveEntity(ent)
			count = count + 1
		end
		
	end
	
	if !hidePrint then
		SH_ANTICRASH.UTILS.LOG.Print("##removingEnts %"..count)
	end
	
	return true, count

end

function SV_ANTICRASH.RevertChanges()

	if !SH_ANTICRASH.SETTINGS.LAG.REVERTCHANGES then return end

	local entTbl = ents.GetAll()
	local revertTime = CurTime() - (SH_ANTICRASH.SETTINGS.LAG.REVERTCHANGESTIME * 60)
	local count = 0
	
	for i=1, #entTbl do
		
		local ent = entTbl[i]
		
		if ent:z_anticrashIsValidEnt() and ent:GetCreationTime() > revertTime then
			ent.__markedForDelete = true
			SafeRemoveEntity(ent)
			
			count = count + 1
		end
		
	end
	
	SH_ANTICRASH.UTILS.LOG.Print("##revertChanges %"..count.." %"..SH_ANTICRASH.SETTINGS.LAG.REVERTCHANGESTIME)
	
end

// Freeze all player created entities
function SV_ANTICRASH.FreezeEntities(hidePrint)

	if !SH_ANTICRASH.SETTINGS.LAG.FREEZEENTS then return end
	
	local entTbl = ents.GetAll()
	local count = 0
	
	for i=1, #entTbl do
	
		local ent = entTbl[i]
		
		if ent:z_anticrashIsValidEnt() and SH_ANTICRASH.CanFreeze(ent) and !ent.__markedForDelete then
		
			if SV_ANTICRASH.UTILS.FreezeEntity(ent, true) then
				count = count + 1
			end
			
		end
	
	end
	
	if !hidePrint and count > 0 then
		SH_ANTICRASH.UTILS.LOG.Print("##freezeingEnts %"..count)
	end
	
	return count

end

// No Collide all entities that are close to each other created by the same player
function SV_ANTICRASH.NoCollideEntities(hidePrint,entTbl)

	if !SH_ANTICRASH.SETTINGS.LAG.NOCOLLIDEENTS then return end
	
	local entTbl = entTbl or ents.GetAll()
	local noCollidedEnts = {}
	local noCollideCount = 0
	
	for i=1, #entTbl do
	
		local ent = entTbl[i]
		if !IsValid(ent) or ent:IsWorld() or !ent:z_anticrashHasCreator() or ent.__markedForDelete then
			continue
		end
		
		ent.__noCollideTbl = ent.__noCollideTbl or {}
		
		local neighbourEnts = SH_ANTICRASH.GetNeighboringEnts(ent)
		
		for innerI=1, #neighbourEnts do
			
			local ent2 = neighbourEnts[innerI]
			ent2.__noCollideTbl = ent2.__noCollideTbl or {}
			
			-- No Collide if ents are valid, not the same and if they haven't been No Collided already
			if IsValid(ent2) and !ent2.__markedForDelete and ent ~= ent2 and !ent.__noCollideTbl[ent2:EntIndex()] and !ent2.__noCollideTbl[ent:EntIndex()] then
			
				if ent:z_anticrashGetCreator() == ent2:z_anticrashGetCreator()  then
					
					timer.Simple(noCollideCount/250,function()
						constraint.NoCollide( ent, ent2, 0, 0 )
					end)
					
					ent.__noCollideTbl[ent2:EntIndex()] = true
					ent2.__noCollideTbl[ent:EntIndex()] = true
					noCollidedEnts[ent] = true
					noCollidedEnts[ent2] = true
					noCollideCount = noCollideCount + 1
					
				end
			
			end
		
		end
	
	end
	
	local count = table.Count(noCollidedEnts)
	
	-- DEBUG
	-- print("NOCOLLIDEENTITIES> NoCollides", noCollideCount, "Ents:", count)
	
	if !hidePrint and count > 0 then
		SH_ANTICRASH.UTILS.LOG.Print("##noCollidingEnts %"..count)
	end
	
	return count
	
end

local function FindOffender()

	local entTbl = ents.GetAll()
	local timeCheck = CurTime() - SH_ANTICRASH.SETTINGS.CRASHOFFENDERTIMEWINDOW
	local offenders = {}
	
	for i=1, #entTbl do
		
		local ent = entTbl[i]
		local entCreator = ent:z_anticrashGetCreator()
	
		if entCreator ~= NULL and ent:GetCreationTime() > timeCheck then
			offenders[entCreator] = (offenders[entCreator] or 0) + 1
		end
		
	end
	
	if table.Count(offenders) == 0 then return end
	
	local sortedTbl = table.SortByKey(offenders, true)
	local offender = sortedTbl[1]
	
	if offender then
	
		local playerFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(offender)
		local printStr = "##offenderWarning %"..playerFormat.." %"..offenders[offender]
		
		SH_ANTICRASH.UTILS.LOG.ConsolePrintAdmins(printStr)
	
		offender:z_anticrashFlagPlayer(10)
		
	end
	
end

local antiLagMeasures = {
	SV_ANTICRASH.CleanMap,
	SV_ANTICRASH.RemoveEntities, 
	SV_ANTICRASH.RevertChanges,
	SV_ANTICRASH.FreezeEntities,
	SV_ANTICRASH.NoCollideEntities
}

// We need the anti lag measures to be run in a proper order
local function RunAntiLagMeasures(forced)

	if !forced then
		-- Check for spammers
		FindOffender()
	end
	
	-- Run measures
	for i=1, #antiLagMeasures do
		
		local antiLagMeasure = antiLagMeasures[i]
		local measureResult = antiLagMeasure()
		
		if measureResult and isbool(measureResult) then
			break
		end
	
	end

end
hook.Add("z_anticrash_LagDetect","z_anticrash_RunAntiLagMeasures",RunAntiLagMeasures)
SV_ANTICRASH.CMD.RegisterCMD("antilagmeasures","#runAntiLagMeasures", function()
	RunAntiLagMeasures(true)
end)

util.AddNetworkString("sv_anticrash_TriggerAntiLagMeasures")
local function TriggerAntiLagMeasures(len, ply)
	
	if !SH_ANTICRASH.HasAccess(ply,"stats") then return end
	
	SH_ANTICRASH.UTILS.LOG.PlyPrint(ply,"#triggeredAntiLagMeasures")
	
	RunAntiLagMeasures(true)
	
	SH_ANTICRASH.UTILS.LOG.ChatPrintAll(ply:Nick().." #ranAntilagMeasures")

end
net.Receive("sv_anticrash_TriggerAntiLagMeasures",TriggerAntiLagMeasures)

local nextFreeze = SH_ANTICRASH.SETTINGS.AUTOFREEZEDELAY*60
local function AutoFreeze()

	if !SH_ANTICRASH.SETTINGS.AUTOFREEZE then return end
	
	if nextFreeze < CurTime() then
	
		local count = SV_ANTICRASH.FreezeEntities(true)
		
		if count > 0 then
			local str = "##freezingAllEntities %"..count
			SH_ANTICRASH.UTILS.LOG.ServerPrint(str)
			SH_ANTICRASH.UTILS.LOG.ChatPrintAll(str)
		end
	
		nextFreeze = CurTime() + (SH_ANTICRASH.SETTINGS.AUTOFREEZEDELAY*60)
	
	end

end
hook.Add("Think","sv_anticrash_AutoFreeze",AutoFreeze)
