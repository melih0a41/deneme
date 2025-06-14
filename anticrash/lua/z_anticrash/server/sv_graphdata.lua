-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SV_ANTICRASH.UpdateCollisionData(ent, data)
	ent.z_anticrash_CollisionCount = (ent.z_anticrash_CollisionCount or 0) + 1
end

SV_ANTICRASH.__spawnedEnts = SV_ANTICRASH.__spawnedEnts or 0

function SV_ANTICRASH.UpdateSpawnedCount()
	SV_ANTICRASH.__spawnedEnts = SV_ANTICRASH.__spawnedEnts + 1
end

local nextUpdateData = 0
local nextBroadcastData = 0

local function UpdateGraphData()
	
	if nextUpdateData < CurTime() then
	
		local entTbl = ents.GetAll()
		local collisionCount = 0
		local freezeCount = 0
		
		for i=1, #entTbl do
			
			local ent = entTbl[i]
			
			if ent.z_anticrash_CollisionCount then
				
				collisionCount = collisionCount + ent.z_anticrash_CollisionCount
				ent.z_anticrash_CollisionCount = 0
				
			end
			
			if string.StartWith(ent:GetClass(),"prop_") then
				
				local physObj = ent:GetPhysicsObject()
			
				if IsValid(physObj) and !physObj:IsMotionEnabled() then
					freezeCount = freezeCount + 1
				end
				
			end

		end
		
		if nextBroadcastData < CurTime() then
			
			SetGlobalInt("z_anticrash_CollisionCount",collisionCount)
			SetGlobalInt("z_anticrash_FreezeCount",freezeCount)
			SetGlobalInt("z_anticrash_Spawned",SV_ANTICRASH.__spawnedEnts)
			
			nextBroadcastData = CurTime() + SH_ANTICRASH.SETTINGS.GRAPH.UPDATEDELAY
			
		end
		
		nextUpdateData = CurTime() + 0.5
	
	end


end
hook.Add("Think","sv_anticrash_UpdateGraphData",UpdateGraphData)
