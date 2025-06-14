-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SV_ANTICRASH.DoCollisionControl(ent, data)

	-- DEBUG
	-- print(ent, data.HitEntity, ent.z_anticrash_CollisionCount)
	
	if (ent.z_anticrash_CollisionCount or 0) >= SH_ANTICRASH.SETTINGS.COLLISIONINTENSITY then
		
		-- Whitelisted entities
		if SH_ANTICRASH.SETTINGS.HIGHCOLENTBLACKLIST[ent:GetClass()] or SH_ANTICRASH.SETTINGS.HIGHCOLENTBLACKLIST[data.HitEntity:GetClass()] then return end
	
		-- One of the entities is not removed yet
		if ent.__markedForDelete or data.HitEntity.__markedForDelete then return end
		
		-- Remove the newest player created entity
		if ent:z_anticrashHasCreator() and data.HitEntity:z_anticrashHasCreator() then
		
			local toRemoveEnt
			local entSpeed, hitEntSpeed = ent:GetVelocity():LengthSqr(), data.HitEntity:GetVelocity():LengthSqr()
			
			if entSpeed == hitEntSpeed then
				-- Remove newest ent
				toRemoveEnt = ent:GetCreationID() > data.HitEntity:GetCreationID() and ent or data.HitEntity
			else
				-- Remove fastest ent
				toRemoveEnt = entSpeed > hitEntSpeed and ent or data.HitEntity
			end
			
			if !toRemoveEnt then return end
			
			local toRemoveEntCreator = toRemoveEnt:z_anticrashGetCreator() 
			local playerFormat = SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(toRemoveEntCreator)
			local colCount
			
			if toRemoveEnt.z_anticrash_CollisionCount and toRemoveEnt.z_anticrash_CollisionCount >= ent.z_anticrash_CollisionCount then
				colCount = toRemoveEnt.z_anticrash_CollisionCount
			else
				colCount = ent.z_anticrash_CollisionCount
			end
			
			-- Ragdoll check ( Ragdolls have an insane amount of collision )
			if toRemoveEnt:IsRagdoll() and colCount < 100 then return end
			
			local printStr = "##removingHighCollision %"..tostring(toRemoveEnt).." %"..colCount.." %"..playerFormat
			
			SH_ANTICRASH.UTILS.LOG.ConsolePrintAdmins(printStr)

			if SH_ANTICRASH.SETTINGS.REMHIGHCOLENTITIES then
				toRemoveEnt.__markedForDelete = true
				toRemoveEnt:Remove()
			end
			
			toRemoveEntCreator:z_anticrashFlagPlayer()
		
		end
		
	end
	
	/* Changing Collisions rules in callback can cause crash!
	
	if ent.z_anticrash_CollisionCount > 10 and !ent.z_anticrash_BlockCollisionControl then
		
		ent.z_anticrash_BlockCollisionControl = true
		
		ent.__oldColGrp = ent.__oldColGrp or ent:GetCollisionGroup()
		
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		
		local rndTime = math.Rand(1,2)
		
		timer.Simple(rndTime, function()
			
			if IsValid(ent) then
				ent:SetCollisionGroup(ent.__oldColGrp)
			end
			
		end)
	end	
	
	*/	
	
end

local function ShouldCollide(ent1, ent2)

	if SH_ANTICRASH.SETTINGS.NOCOLLISIONENTITIES[ent1:GetClass()] and SH_ANTICRASH.SETTINGS.NOCOLLISIONENTITIES[ent2:GetClass()] then
		
		if SH_ANTICRASH.SETTINGS.NOCOLLISIONSAMEOWNER then
		
			local ent1Creator = ent1:z_anticrashGetCreator()
			local ent2Creator = ent2:z_anticrashGetCreator()
			
			if ent1Creator ~= NULL and ent2Creator ~= NULL and ent1Creator ~= ent2Creator then
				return
			end
			
		end
		
		return false

	end

end
hook.Add("ShouldCollide", "z_anticrash_ShouldNeverCollide", ShouldCollide)

-- Fixes crashes if a ton of things get put into motion simultaniously ( fading door crash )
local phys = FindMetaTable("PhysObj")
local physMotionDelay = 0.25
phys.__oldEnableMotion = phys.__oldEnableMotion or phys.EnableMotion
phys.__oldWake = phys.__oldWake or phys.Wake

function phys:Wake()

	if !IsValid(self) then return end

	local selfEnt = self:GetEntity()
	
	if !IsValid(selfEnt) then
		self:__oldWake()
		return
	end
	
	-- Enable wake in delay when needed
	if selfEnt.__EnableMotionDelayTime and selfEnt.__EnableMotionDelayTime > CurTime() then
		timer.Simple(selfEnt.__EnableMotionDelayTime - CurTime(), function()
			if IsValid( self ) then
				-- print("Delayed wake")
				self:__oldWake()
			end
		end)
	else
		-- print("Undelayed wake", selfEnt)
		self:__oldWake()
	end

end

function phys:EnableMotion(enable)

	if !IsValid(self) then return end
	
	local selfEnt = self:GetEntity()
	
	-- Only work when enabling motion
	if !enable or !IsValid(selfEnt) then
		self:__oldEnableMotion(enable)
		self:Sleep()
		return
	end
	
	local selfOwner = selfEnt:z_anticrashGetCreator()
	
	-- AdvDupe compatibility
	if selfOwner and selfOwner.AdvDupe2 and selfOwner.AdvDupe2.Pasting then
		return
	end
	
	local mins, max = self:GetAABB()
	local pos, ang = self:GetPos(), self:GetAngles()
	
	if !mins or !max or !pos or !ang then
		self:__oldEnableMotion(enable)
		return
	end
	
	local worldMins = LocalToWorld(mins, Angle(0,0,0), pos, ang)
	local worldMaxs = LocalToWorld(max, Angle(0,0,0), pos, ang)
	local neighbours = ents.FindInBox(worldMins, worldMaxs)
	local curTime = CurTime()
	
	-- Check entities within the phys bounds to delay motion
	for i=1, #neighbours do
	
		local ent = neighbours[i]
		
		if ent == selfEnt or !ent:z_anticrashHasCreator() then continue end
		
		if ent.__EnableMotionDelayTime and ent.__EnableMotionDelayTime > curTime then
			ent.__EnableMotionDelayTime = ent.__EnableMotionDelayTime + physMotionDelay
		else
			ent.__EnableMotionDelayTime = curTime + physMotionDelay
		end
		
		-- print("Delaying motion for ->", ent, ent.__EnableMotionDelayTime)
	end
	
	-- Enable phys motion in delay when needed
	if selfEnt.__EnableMotionDelayTime and selfEnt.__EnableMotionDelayTime > curTime then
		timer.Simple(selfEnt.__EnableMotionDelayTime - curTime, function()
			if IsValid( self ) then
				-- print("Delayed unmotion ")
				self:__oldEnableMotion(enable)
			end
		end)
	else
		-- print("Undelayed motion", selfEnt)
		self:__oldEnableMotion(enable)
	end
	
end