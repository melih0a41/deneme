-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local nextFix = 0

local function IsCreatedByMap(ent)
	return ent:CreatedByMap() or ent:GetCreationTime() < 20
end

local function FixOutOfBounds()

	if !SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.REMOVE then return end
	
	if nextFix < CurTime() then
	
		local entTbl = ents.GetAll()
	
		for i=1, #entTbl do
		
			local ent = entTbl[i]

			if IsValid(ent) and !ent:IsWorld() and !IsCreatedByMap(ent) and !ent:IsInWorld() then
			
				-- Owned weapons
				if ent:IsWeapon() and ent:GetOwner() ~= NULL then
					continue
				end
			
				local class = ent:GetClass()
				local canFix = true
				
				-- Blacklist 
				if SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.BLACKLIST[class] then
					continue
				end
			
				-- Blacklist REG
				for blackListI=1, #SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.BLACKLISTREG do
					
					-- Check if class is in the blacklist
					if string.StartWith(class, SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.BLACKLISTREG[blackListI]) then
						canFix = false
						break
					end
				
				end
				
				if canFix then
					
					SH_ANTICRASH.UTILS.LOG.Print("##removingOutOfBounds %"..tostring(ent))
				
					SafeRemoveEntity(ent)
					
				end
				
			end
		
		end
	
		nextFix = CurTime() + SH_ANTICRASH.SETTINGS.OUTOFBOUNDS.DELAY
	
	end

end
hook.Add("Think","z_anticrash_FixOutOfBounds",FixOutOfBounds)