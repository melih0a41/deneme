-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/* (05/03/2021)
	- Will be removed/cleaned up in a future version due to engine bugs/conflicts
*/

local nextWarning = 0

local function FixCrazyPhysics(ent, physObj)

	if !IsValid(ent) then return end

	ent.__crazyFrozenAmount = ent.__crazyFrozenAmount or 0
	
	-- Remove crazy physics entities
	/*
	if SH_ANTICRASH.SETTINGS.CRAZYPHYSICS.REMOVEAFTERFREEZE then
		
		if ent.__crazyFrozenAmount >= math.max(1,SH_ANTICRASH.SETTINGS.CRAZYPHYSICS.REMOVEAFTERFREEZENUM) then
			
			SH_ANTICRASH.UTILS.LOG.Print("Removing crazy physics on "..tostring(ent))
			
			SafeRemoveEntity(ent)
			
		end
		
	end
	*/
	
	-- Freeze crazy physics entities
	if SH_ANTICRASH.SETTINGS.CRAZYPHYSICS.FREEZE then
	
		ent.__crazyFrozenAmount = ent.__crazyFrozenAmount + 1
		
		if nextWarning < CurTime() then
			-- The engine will start defusing the object after this step
			SH_ANTICRASH.UTILS.LOG.Print("Freezing crazy physics on "..tostring(ent))
			nextWarning = CurTime() + 0.1
		end
		
		// Temp disabled, can cause a segmentation fault in very rare conditions
		-- if IsValid(physObj) then
			-- physObj:EnableMotion(false)
			-- physObj:Sleep()
		-- end
		
	end

end
hook.Add("OnCrazyPhysics","z_anticrash_FixCrazyPhysics",FixCrazyPhysics)