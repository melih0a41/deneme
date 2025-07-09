local cfg = gProtect.getConfig(nil, "physgunsettings")
local blacklist = gProtect.getConfig("blacklist","general")

gProtect = gProtect or {}

gProtect.HandlePhysgunPermission = function(ply, ent)
    if IsValid(ent) and cfg.blockMultiplePhysgunning and ent.BeingPhysgunned and !table.IsEmpty(ent.BeingPhysgunned) then return false end

    if cfg.enabled then
        if IsValid(ent) and ent:IsPlayer() then return nil end

        local owner = gProtect.GetOwner(ent)

        if !owner then
            local result = gProtect.GetOwnerString(ent)
            owner = string.sub(result, 1, 5) == "STEAM" and "Disconnected" or "World"
        end
        
        local usergroup = ply:GetUserGroup()
        local secondaryUsergroup = ply.GetSecondaryUserGroup and ply:GetSecondaryUserGroup()
        
        if !cfg.PickupVehiclePermission[usergroup] and !cfg.PickupVehiclePermission[secondaryUsergroup] and !cfg.PickupVehiclePermission["*"] then
            if ent:IsVehicle() then return false end
        end

        if cfg.blockedEntities[ent:GetClass()] and !cfg.bypassGroups[ply:GetUserGroup()] and !cfg.bypassGroups["*"] then return false end
    end
end

gProtect.HandleMaxObstructs = function(ent, ply)
    if IsValid(ent) and blacklist[ent:GetClass()] and cfg.enabled and (cfg.maxDropObstructs > 0) then
        local physobj = ent:GetPhysicsObject()

        if IsValid(physobj) then
            if !physobj:IsMotionEnabled() then return false end
        end

		local obscuring = gProtect.obscureDetection(ent)

		if obscuring then
			local count = -1

			for k,v in pairs(obscuring) do
				if blacklist[v:GetClass()] then
					count = count + 1
				end
			end

            if count >= cfg.maxDropObstructs then
                local result = true

				if IsValid(physobj) then
					physobj:EnableMotion(false)
				end
                
				if cfg.maxDropObstructsAction == 1 then
                    gProtect.GhostHandler(ent, true)
				elseif cfg.maxDropObstructsAction == 2 then
					if IsValid(physobj) then
						physobj:EnableMotion(false)
                    end

                    result = false
				elseif cfg.maxDropObstructsAction == 3 then
                    ent:Remove()
                end

                gProtect.NotifyStaff(ply, "too-many-obstructs", 3)

                return result
			end
		end
    end    
end

gProtect.PhysgunSettingsOnDrop = function(ply, ent, obstructed)
    if cfg.enabled and cfg.StopMotionOnDrop and !obstructed then
        timer.Simple(.01, function()
            if !IsValid(ent) then return end
            local physobj = ent:GetPhysicsObject()
            if IsValid(physobj) then
                if physobj:IsMotionEnabled() then
                    physobj:EnableMotion(false)
                    physobj:EnableMotion(true)
                end
            end
        end)
    end
    
    if IsValid(ent) then
        ent.BeingPhysgunned = ent.BeingPhysgunned or {}
        ent.BeingPhysgunned[ply] = nil
    end
end

local function handleReloadUnfreeze(ply, ent, id)
    if cfg.enabled and cfg.DisableReloadUnfreeze then
		return false
    end
    
    if gProtect.HandlePermissions(ply, ent, "weapon_physgun") == false then return false end
end

local propClimbingLogs = {}

hook.Add("PhysgunDrop", "gP:AntiPropClimb", function(ply, ent)
	if cfg.preventPropClimbing then
        propClimbingLogs[ply] = propClimbingLogs[ply] or {}
        propClimbingLogs[ply][ent] = propClimbingLogs[ply][ent] or {}

        local tr = util.TraceLine({
            start = ply:GetPos(),
            endpos = ply:GetPos() - Vector(0, 0, 150),
            filter = ply
        })

        if tr.Entity == ent then
            local entPos = ent:GetPos()

            if propClimbingLogs[ply][ent].lastZ and entPos.z <= propClimbingLogs[ply][ent].lastZ then return end

            propClimbingLogs[ply][ent].lastZ = entPos.z

            table.insert(propClimbingLogs[ply][ent], {
                curTime = CurTime(),
            })

            local totalHits = 0

            for i = #propClimbingLogs[ply][ent], 1, -1 do
                local data = propClimbingLogs[ply][ent][i]

                if CurTime() - data.curTime > 10 then
                    table.remove(propClimbingLogs[ply][ent], i)
                continue end

                totalHits = totalHits + 1
            end

            if totalHits >= cfg.preventPropClimbingThreshold then
                if cfg.preventPropClimbingAction == 1 then
                    timer.Simple(0, function()
                        gProtect.GhostHandler(ent, true, nil, nil, true)
                    end )
                elseif cfg.preventPropClimbingAction == 2 then
                    ent:Remove()
                end

                propClimbingLogs[ply][ent] = {}
            end
        end
	end
end)

hook.Add("CanPlayerUnfreeze", "gP:PreventUnfreezeAll", function(ply, ent)
    return handleReloadUnfreeze(ply, ent)
end )

hook.Add("OnPhysgunReload", "gP:PreventUnfreeze", function(wep, ply)
    return handleReloadUnfreeze(ply, ply:GetEyeTraceNoCursor().Entity)
end)

hook.Add("gP:ConfigUpdated", "gP:UpdatePhysgunSettings", function(updated)
    if updated ~= "physgunsettings" and updated ~= "general" then return end
    cfg = gProtect.getConfig(nil, "physgunsettings")
    blacklist = gProtect.getConfig("blacklist", "general")
end)