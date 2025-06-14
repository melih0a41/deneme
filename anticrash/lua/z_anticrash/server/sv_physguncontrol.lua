-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local function PhysgunPickup(ply, ent)

	if SH_ANTICRASH.SETTINGS.GHOSTOBJECTSONPICKUP and ent:z_anticrashGetCreator() == ply and !SH_ANTICRASH.HasGProtectGhosting() then
		SV_ANTICRASH.SetGhostEntity(ent, true)
	end
	
end 
hook.Add("PhysgunPickup", "sv_anticrash_PhysgunPickup", PhysgunPickup)

local function PhysgunDrop(ply, ent)
	 
	SV_ANTICRASH.SetGhostEntity(ent,false)
	
	if SH_ANTICRASH.SETTINGS.FREEZEONDROP then
		SV_ANTICRASH.UTILS.FreezeEntity(ent)
	end
	
end
hook.Add("PhysgunDrop", "sv_anticrash_PhysgunDrop", PhysgunDrop)

local function CanPlayerUnfreeze(ply, ent, phys)
	
	local prioritizedHookName = "z_anticrash_prioritized_CanPlayerUnfreeze"
	local canUnFreeze = hook.Run(prioritizedHookName, ply, ent, phys)
	
	if canUnFreeze == false then return false end
	if !SH_ANTICRASH.SETTINGS.FREEZEALLDELAY then return end

	if (ply.__nextUnfreeze or 0) < CurTime() then
	
		ply.__nextUnfreeze = CurTime() + 0.1
	
		return true
	
	else
		
		ply.__nextUnfreeze = ply.__nextUnfreeze + 0.05
		
		-- Delayed unfreeze
		timer.Simple(ply.__nextUnfreeze-CurTime(), function()
			
			if IsValid(phys) then
				phys:EnableMotion(true)
			end
			
		end)
		
		return false
	
	end

end
SH_ANTICRASH.PrioritizedAddHook("CanPlayerUnfreeze", "sv_anticrash_CanPlayerUnfreeze", CanPlayerUnfreeze)