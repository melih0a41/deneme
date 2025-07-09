local blacklist, cfg = gProtect.getConfig("blacklist", "general"), gProtect.getConfig(nil, "ghosting")
local welds = {}
local redoWelds = {}

gProtect = gProtect or {}

gProtect.Ghost = function(ent, nofreeze)
	local physics = ent:GetPhysicsObject()
		
	if IsValid(physics) and !nofreeze then
		physics:EnableMotion(false)
	end

	if cfg.enableMotion then
		timer.Simple(0, function()
			if !IsValid(ent) or !IsValid(physics) or (ent.BeingPhysgunned and !table.IsEmpty(ent.BeingPhysgunned)) then return end
			
			physics:EnableMotion(true)
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		end)
	end

	if !ent.sppghosted then
		ent.SPPData = ent.SPPData or {}
	
		ent.SPPData.color = ent:GetColor() and ent:GetColor() or Color(255,255,255)
		ent.SPPData.collision = ent:GetCollisionGroup() and ent:GetCollisionGroup() or COLLISION_GROUP_NONE
		ent.SPPData.rendermode = ent:GetRenderMode() and ent:GetRenderMode() or RENDERMODE_NORMAL
		ent.SPPData.material = ent:GetMaterial() and ent:GetMaterial() or ""
	end

	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:SetRenderMode(RENDERGROUP_TRANSLUCENT)
	ent:SetColor(cfg.ghostColor)
	ent:SetMaterial("models/debug/debugwhite")
	
	ent.sppghosted = true
end

gProtect.UnGhost = function(ent)
	if !ent.SPPData then return end

	ent:SetRenderMode(ent.SPPData.rendermode and ent.SPPData.rendermode or RENDERMODE_NORMAL)
	ent:SetCollisionGroup(ent.SPPData.collision and ent.SPPData.collision or COLLISION_GROUP_NONE)
	
	if ent.SPPData.color then
		ent:SetColor(ent.SPPData.color)
	end

	ent:SetMaterial(ent.SPPData.material and ent.SPPData.material or "")
	
	ent.SPPData = nil	
	ent.sppghosted = false
end

gProtect.CanGhost = function(ent)
	if !cfg.enabled then return false end

	return (cfg.useBlacklist and blacklist[ent:GetClass()]) or cfg.entities[ent:GetClass()] or cfg.entities["*"]
end

gProtect.GhostHandler = function(ent, todo, nofreeze, closedloop, ignore)
	if !cfg.enabled or !IsValid(ent) then return end
	
	if !ignore and ((cfg.useBlacklist and !blacklist[ent:GetClass()]) and !cfg.entities[ent:GetClass()] and !cfg.entities["*"]) then return end

	if cfg.antiObscuring and !todo then
		local colliders = gProtect.obscureDetection(ent)
		
		for k, v in pairs(colliders) do
			if v == ent then continue end
			if cfg.antiObscuring[v:GetClass()] then todo = true break end
		end
	end

	if todo then
		gProtect.Ghost(ent, nofreeze)
	else
		gProtect.UnGhost(ent)
	end

	if !closedloop then
		local constraintedEnts = constraint.GetAllConstrainedEntities(ent)
		if constraintedEnts then
			local action = !!todo
			local stopIt = false

			if !action then
				for k, v in pairs(constraintedEnts) do
					if v.BeingPhysgunned and !table.IsEmpty(v.BeingPhysgunned) then
						stopIt = true
					end
				end
			end

			if !stopIt then
				for k, v in pairs(constraintedEnts) do
					if v == ent then continue end
					local physobj = v:GetPhysicsObject()
					
					if IsValid(physobj) and !physobj:IsMotionEnabled() then
						continue
					end

					local physobj = v:GetPhysicsObject()
					physobj:EnableMotion(false)
					gProtect.GhostHandler(v, action, true, true)

					physobj:EnableMotion(true)
				end
			end
		end
	end

	return ent.sppghosted
end

hook.Add("OnPhysgunPickup", "gP:GhostPhysgun", function(ply, ent)
	if cfg.onPhysgun and IsValid(ent) and ((blacklist[ent:GetClass()] and cfg.useBlacklist) or cfg.entities[ent:GetClass()] or cfg.entities["*"]) then
		gProtect.GhostHandler(ent, true)
	end
end)

hook.Add("PhysgunDropped", "gP:UnGhostPhysgunDrop", function(ply, ent, obstructed)
	if obstructed then return end

	if IsValid(ent) then
		ent.BeingPhysgunned = ent.BeingPhysgunned or {}
		if ent.sppghosted and table.IsEmpty(ent.BeingPhysgunned) then
			local result = gProtect.GhostHandler(ent, false)

			if result then slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "entity-ghosted"), ply) end
		end
	end
end)

hook.Add("OnTool", "gP:GhostPhysgunHandle", function(ply, tr)
	local ent = tr.Entity
	if !cfg.enabled or !IsValid(ent) then return end

	gProtect.GhostHandler(ent, false)
end)

hook.Add("gP:ConfigUpdated", "gP:UpdateGhosting", function(updated)
	if updated ~= "ghosting" and updated ~= "general" then return end
	cfg = gProtect.getConfig(nil, "ghosting")
	blacklist = gProtect.getConfig("blacklist", "general")
end)


hook.Add("PhysgunDrop", "gP:GhostingGhostUnfrozen", function(ply, ent)
	if cfg.enabled and cfg.forceUnfrozen and IsValid(ent) and cfg.forceUnfrozenEntities[ent:GetClass()] then
		if !IsValid(ent) then return end
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			if phys:IsMotionEnabled() then
				gProtect.GhostHandler(ent, true)
			end
		end
	end
end)

hook.Add("OnEntityCreated", "gP:GhostingHandeler", function(ent)
	timer.Simple(.05, function()
		if !IsValid(ent) then return end

		if cfg.enabled and cfg.forceUnfrozen and cfg.forceUnfrozenEntities[ent:GetClass()] and IsValid(phys) and phys:IsMotionEnabled() then
			local owner = gProtect.GetOwner(ent)
			if !IsValid(owner) or !owner:IsPlayer() then return end
			
			local phys = ent:GetPhysicsObject()
			
			gProtect.GhostHandler(ent, true)
		end
	end)
end)

local markedDupeEnts = {}

hook.Add("OnEntityCreated", "gP:PreventTickCollision", function(ent)
	if ent:IsWorld() or !gProtect.CanGhost(ent) then return end
	
	local collisionGroup = ent:GetCollisionGroup()

	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)

	ent.gPVerifyingColGroup = true

	timer.Simple(0, function()
		if !IsValid(ent) or markedDupeEnts[ent] or !ent.gPVerifyingColGroup then return end

		local owner = gProtect.GetOwner(ent)
		if !IsValid(owner) or !owner:IsPlayer() then ent:SetCollisionGroup(collisionGroup) return end
		
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)

		ent.gPVerifyingColGroup = true
		
		timer.Simple(0, function()
			if !IsValid(ent) or ent.sppghosted or !ent.gPVerifyingColGroup then return end
			
			gProtect.GhostHandler(ent)
		
			if !ent.sppghosted then
				ent:SetCollisionGroup(collisionGroup)
			else
				ent.SPPData.collision = collisionGroup
			end

			ent.gPVerifyingColGroup = nil
		end)
	end)
end)

// Adv Dupe 2 Fix
local advDupe2EntStackLevel
hook.Add("gP:DuplicatorPostDoGeneric", "gP:DuplicatorFix", function(ent)
	advDupe2EntStackLevel = advDupe2EntStackLevel or gProtect.FindAdvDupe2StackLevel("MakeProp")
	
	if gProtect.IsAdvDupeClipboard(advDupe2EntStackLevel, "MakeProp") then
		markedDupeEnts[ent] = true
	end 
end)

hook.Add("PlayerSpawnedProp", "gP:DuplicatorFix", function(ply, model, ent)
	if markedDupeEnts[ent] then
		markedDupeEnts[ent] = nil
		ent.wantedGroup = ent:GetCollisionGroup()
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		markedDupeEnts[ent] = true
	end
end)

hook.Add("gP:ShouldSetCollisionGroup", "gP:DuplicatorFix", function(ent, group)
	ent.gPVerifyingColGroup = nil

	if markedDupeEnts[ent] then
		ent.wantedGroup = group

		return false
	end
end)

hook.Add("AdvDupe_FinishPasting",  "gP:DuplicatorFix", function(data)
	for k, ent in pairs(data and data[1] and data[1].CreatedEntities) do
		if markedDupeEnts[ent] then
			markedDupeEnts[ent] = nil
	
			gProtect.GhostHandler(ent)
		
			if !ent.sppghosted then
				ent:SetCollisionGroup(ent.wantedGroup || 0)
			else
				ent.SPPData.collision = ent.wantedGroup || 0
			end
		end
	end
end)