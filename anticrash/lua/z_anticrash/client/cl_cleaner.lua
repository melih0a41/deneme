-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local nextCleanTime = SH_ANTICRASH.SETTINGS.CLEANER.DELAY

local function AutoCleaner()

	if !SH_ANTICRASH.SETTINGS.CLEANER.ENABLE then return end

    if nextCleanTime < CurTime() then
		
		for i=1, #SH_ANTICRASH.SETTINGS.CLEANER.CMDS do
			
			local cmd = SH_ANTICRASH.SETTINGS.CLEANER.CMDS[i]
			
			if isstring(cmd) then
		
				RunConsoleCommand(cmd)
				
			else
			
				cmd()
				
			end
			
		end
		
        nextCleanTime = CurTime() + SH_ANTICRASH.SETTINGS.CLEANER.DELAY
		
    end
	
end
hook.Add("Think", "z_anticrash_AutoCleaner", AutoCleaner)