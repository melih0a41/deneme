-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

// ENTITY
local ent = FindMetaTable("Entity")
local nwCreatorStr = "z_anticrash_Creator"

function ent:z_anticrashSetCreator(ply)
	self:SetNWEntity(nwCreatorStr,ply)
end

function ent:z_anticrashGetCreator()
	return self:GetNWEntity(nwCreatorStr)
end

function ent:z_anticrashHasCreator()
	return IsValid(self:z_anticrashGetCreator())
end

function ent:z_anticrashIsValidEnt()
	return IsValid(self) and self:z_anticrashHasCreator()
end

// PLAYER
local ply = FindMetaTable("Player")
local nwCanSpawnStr = "z_anticrash_CanSpawn_"
local nwCanSpawnGlobalStr = "z_anticrash_CanSpawn_Global"
local nwFlaggedStr = "z_anticrash_Flagged"
local nwSpawnCountStr = "z_anticrash_SpawnCount"
local nwConstraintCountStr = "z_anticrash_ConstraintCount"

function ply:z_anticrashSetCanSpawn(spawnHook,bool)

	if spawnHook == '*' then
		
		for i=1, SH_ANTICRASH.VARS.HOOKS.SPAWN do
			
			local spawnHook = SH_ANTICRASH.VARS.HOOKS.SPAWN[i]
		
			self:SetNWBool(nwCanSpawnStr..spawnHook,bool)
			
		end
		
	else
		self:SetNWBool(nwCanSpawnStr..spawnHook,bool)
	end

end

function ply:z_anticrashGetCanSpawn(spawnHook)
	return self:GetNWBool(nwCanSpawnStr..spawnHook, true)	
end

function ply:z_anticrashSetCanSpawnGlobal(bool)
	self:SetNWBool(nwCanSpawnGlobalStr, bool)
end

function ply:z_anticrashGetCanSpawnGlobal()
	return self:GetNWBool(nwCanSpawnGlobalStr, true)
end

function ply:z_anticrashFlagPlayer(flagNum)
	
	local newFlaggedCount = self:z_anticrashGetFlaggedCount() + (flagNum or 1)
	
	self:SetNWInt(nwFlaggedStr, newFlaggedCount)
	
end

function ply:z_anticrashGetFlaggedCount()
	return self:GetNWInt(nwFlaggedStr)
end

function ply:z_anticrashResetFlaggedCount()
	self:SetNWInt(nwFlaggedStr, 0)
end

function ply:z_anticrashIncreaseSpawnCount()

	self.__spawnCount = (self.__spawnCount or 0) + 1
	
	-- Timer to avoid overflowing the net channel when rapidly setting value
	timer.Create("z_anticrash_SpawnCount", 0.1, 1, function()
		self:SetNWInt(nwSpawnCountStr, self.__spawnCount)
	end)

end

function ply:z_anticrashGetSpawnCount()
	return self:GetNWInt(nwSpawnCountStr)
end

function ply:z_anticrashSetConstraintCount(num)
	self:SetNWInt(nwConstraintCountStr, num)
end

function ply:z_anticrashGetConstraintCount()
	return self:GetNWInt(nwConstraintCountStr)
end