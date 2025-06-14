-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

if !constraint then return end


// Remove all constraints before removing the entity
local function ConstraintCleaner(ent)

	if IsValid(ent) then
		constraint.RemoveAll(ent)
	end
	
end
hook.Add("EntityRemoved", "z_anticrash_ConstraintCleaner", ConstraintCleaner)

// Rope spammers
constraint.__oldRope = constraint.__oldRope or constraint.Rope

constraint.Rope = function(ent1, ent2, bone1, bone2, lPos1, lPos2, length, addlength, forcelimit, width, material, rigid, color)
	
	if SH_ANTICRASH.SETTINGS.BLOCKROPESPAMMING then
	
		if ent1:IsWorld() or ent2:IsWorld() then
			return
		end
		
	end
	
	return constraint.__oldRope(ent1, ent2, bone1, bone2, lPos1, lPos2, length, addlength, forcelimit, width, material, rigid, color)
 
end

// Constraint material abusers (CreateKeyframeRope is used for all visible constraints)
-- test material: vgui/ico_box8

constraint.__oldCreateKeyframeRope = constraint.__oldCreateKeyframeRope or constraint.CreateKeyframeRope

constraint.CreateKeyframeRope = function ( pos, width, material, ...)
	material = SH_ANTICRASH.UTILS.MATERIAL.ForceValid( material ) 
	
	return constraint.__oldCreateKeyframeRope(pos, width, material, ...)
end

// Remember no collides
constraint.__oldNoCollide = constraint.__oldNoCollide or constraint.NoCollide

constraint.NoCollide = function(ent1, ent2, ...)
	
	local noCollide = constraint.__oldNoCollide(ent1,ent2,...)
	
	if IsValid(ent1, ent2, noCollide) then
		
		ent1.__noCollideTbl = ent1.__noCollideTbl or {}
		ent2.__noCollideTbl = ent2.__noCollideTbl or {}
		
		if IsValid(ent1.__noCollideTbl, ent2.__noCollideTbl) then
			ent1.__noCollideTbl[ent2:EntIndex()] = true
			ent2.__noCollideTbl[ent1:EntIndex()] = true
		end
	
	end
	
	return noCollide

end

// Axis crash exploit
constraint.__oldAxis = constraint.__oldAxis or constraint.Axis

constraint.z_anticrash_GetClampedAxisPos = function (pos)
	pos = pos or Vector()
	pos.x = math.Clamp(pos.x, -1000, 1000)
	pos.y = math.Clamp(pos.y, -1000, 1000)
	pos.z = math.Clamp(pos.z, -1000, 1000)
	
	return pos
end

constraint.Axis = function(ent1, ent2, bone1, bone2, lPos1, lPos2, ...)
	lPos1 = constraint.z_anticrash_GetClampedAxisPos(lPos1)
	lPos2 = constraint.z_anticrash_GetClampedAxisPos(lPos2)
	
	return constraint.__oldAxis(ent1, ent2, bone1, bone2, lPos1, lPos2, ...)
end

/*
local constraintFunc = {
	["AdvBallsocket"] = true,
	["Axis"] = true,
	["Ballsocket"] = true,
	["CreateKeyframeRope"] = true,
	["Elastic"] = true,
	["Hydraulic"] = true,
	["Keepupright"] = true,
	["Motor"] = true,
	["Muscle"] = true,
	["NoCollide"] = true,
	["Pulley"] = true,
	["Rope"] = true,
	["Slider"] = true,
	["Weld"] = true,
	["Winch"] = true,
}

for name, func in pairs(constraint) do
	
	if constraintFunc[name] then
	
		local oldFuncName = "__old"..name
	
		constraint[oldFuncName] = constraint[oldFuncName] or func
		
		constraint[name] = function(...)
			
			local args = {...}
			
			for i=1, #args do
				
				local arg = args[i]
				
				if arg ~= nil and IsEntity(arg) and !arg:IsWorld() and !arg:IsPlayer()  then
				
					print('adding constraint count to', arg)
					
					break
					
				end
			
			end
		
			-- Old func
			constraint[oldFuncName](...)
			
		end
		
	end

end
*/