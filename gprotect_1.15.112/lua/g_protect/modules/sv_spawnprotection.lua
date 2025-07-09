local cfg = gProtect.getConfig(nil, "spawnrestriction")

gProtect = gProtect or {}

local modelSizeCache = {}

gProtect.HandleSpawnPermission = function(ply, model, type)
    if cfg.enabled then
        local handle = cfg[type]
        local isBlacklist = cfg.blockedModelsisBlacklist
        
        if model then
            if cfg.maxModelSize > 0 and modelSizeCache[model] and modelSizeCache[model] > cfg.maxModelSize then
                slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "too-big-prop"), ply)
                return false
            end

            local inBlacklist = cfg.blockedModels[model] or cfg.blockedModels[string.lower(model)]

            local result = hook.Run("gP:OverrideBlockedModel", ply, model) or inBlacklist or false

            if !cfg.bypassGroups[ply:GetUserGroup()] and (isBlacklist == result) and (type ~= "vehicleSpawnPermission" or !cfg.blockedModelsVehicleBypass) then
                slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "model-restricted"), ply)
                return false
            end
        end

        if handle[ply:GetUserGroup()] then
            return true
        elseif handle["*"] then
            return true
        else
            slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "insufficient-permission"), ply)
            return false
        end
    end
end

gProtect.HandleSENTSpawnPermission = function(ply, class)
    if cfg.enabled then
        local blockedclasses = cfg.blockedEntities
        local result = blockedclasses[class] and blockedclasses[class] or false

        if !cfg.bypassGroups[ply:GetUserGroup()] and (cfg.blockedEntitiesIsBlacklist == result) then
            slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "classname-restricted"), ply)
            return false
        end
    end
end

hook.Add("PlayerSpawnedProp", "gP:handlePreventComplexity", function(ply, model, ent)
    if cfg.enabled then
        if cfg.maxModelSize > 0 then
			local vec1, vec2 = ent:GetModelBounds()
			
			if vec1 and vec2 then
				local size = vec1:Distance(vec2)
				local scale = ent:GetModelScale()

				size = modelSizeCache[model] or (size * (isnumber(scale) and scale or 1))

                modelSizeCache[model] = modelSizeCache[model] or size

				if size > cfg.maxModelSize then
					ent:Remove()
					slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "too-big-prop"), ply)
				end
			end
		end

        local limit = (cfg.maxPropModelComplexity or 10)

        if limit <= 0 or !IsValid(ent) or cfg.bypassGroups[ply:GetUserGroup()] then return end
        
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            local meshes = #phys:GetMesh()
            local maxs, mins = ent:OBBMaxs(), ent:OBBMins()
            local size = maxs:DistToSqr(mins)
            local modelComplexity = (meshes / size) * 100

            if modelComplexity > limit then
                slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "too-complex-model"), ply)
                ent:Remove()
            end
        end
    end
end)

hook.Add("PlayerSpawnProp", "gP:CanSpawnPropLogic2", function(ply, model)
	local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, model, "propSpawnPermission")
	
	if spawnpermissionresult == false then return false end
end)

hook.Add("PlayerSpawnSENT", "gP:CanSpawnSENTSLogic", function(ply, class)
    local shouldBlockAdvDupe2, isAdvDupe2 = gProtect.ShouldBlockAdvDupe2(class)

    if !isAdvDupe2 then
        local spawnsentresult = gProtect.HandleSENTSpawnPermission(ply, class)
        local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, nil, "SENTSpawnPermission")

        if spawnpermissionresult == false or spawnsentresult == false then            
            return false 
        end
    elseif shouldBlockAdvDupe2 and !cfg.bypassGroups[ply:GetUserGroup()] then
        slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "classname-restricted"), ply)
        
        return false
    end
end)

hook.Add("PlayerSpawnSWEP", "gP:CanSpawnSWEPLogic", function(ply, weapon, swep)
	local model = swep.WorldModel
	local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, model, "SWEPSpawnPermission")

    if spawnpermissionresult != false then
        local blockedclasses = cfg.blockedEntities
        local result = blockedclasses[weapon] and blockedclasses[weapon] or false

        if !cfg.bypassGroups[ply:GetUserGroup()] and (cfg.blockedEntitiesIsBlacklist == result) then
            slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "classname-restricted"), ply)
            return false
        end
    end

	if spawnpermissionresult == false then return false end
end)

hook.Add("PlayerGiveSWEP", "gP:CanGiveSWEPLogic", function(ply, weapon, swep)
	local model = swep.WorldModel
	local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, model, "SWEPSpawnPermission")

    if spawnpermissionresult != false then
        local blockedclasses = cfg.blockedEntities
        local result = blockedclasses[weapon] and blockedclasses[weapon] or false

        if !cfg.bypassGroups[ply:GetUserGroup()] and (cfg.blockedEntitiesIsBlacklist == result) then
            slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "classname-restricted"), ply)
            return false
        end
    end

	if isbool(spawnpermissionresult)  then return spawnpermissionresult end
end)

hook.Add("PlayerSpawnVehicle", "gP:CanSpawnVehicleLogic", function(ply, model)
	local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, model, "vehicleSpawnPermission")

	if spawnpermissionresult == false then return false end
end)

hook.Add("PlayerSpawnNPC", "gP:CanSpawnNPCLogic", function(ply)
	local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, nil, "NPCSpawnPermission")

	if spawnpermissionresult == false then return false end
end)

hook.Add("PlayerSpawnRagdoll", "gP:CanSpawnRagdollLogic", function(ply, model)
	local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, model, "ragdollSpawnPermission")

	if spawnpermissionresult == false then return false end
end)

hook.Add("PlayerSpawnEffect", "gP:CanSpawnEffectLogic", function(ply, model)
	local spawnpermissionresult = gProtect.HandleSpawnPermission(ply, model, "effectSpawnPermission")

	if spawnpermissionresult == false then return false end
end)

hook.Add("gP:ConfigUpdated", "gP:UpdateSpawnProtection", function(updated)
    if updated ~= "spawnrestriction" then return end
	cfg = gProtect.getConfig(nil, "spawnrestriction")
end)