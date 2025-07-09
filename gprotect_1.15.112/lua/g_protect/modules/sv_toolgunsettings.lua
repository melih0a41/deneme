local cfg = gProtect.getConfig(nil, "toolgunsettings")

gProtect = gProtect or {}

local spamProtection = {}

gProtect.HandleToolgunPermissions = function(ply, tr, tool)
    if cfg.enabled then
        local ent = tr.Entity
        local owner = gProtect.GetOwner(ent)

        if !owner then
            local result = gProtect.GetOwnerString(ent)
            owner = string.sub(result, 1, 5) == "STEAM" and "Disconnected" or "World"
        end
        
        local usergroup, group_tools_usergroup = ply:GetUserGroup()
        local secondary_usergroup = ply.GetSecondaryUserGroup and ply:GetSecondaryUserGroup()
        local sid, sid64 = ply:SteamID(), ply:SteamID64()
        local team = ply:Team()
        local team_name = RPExtraTeams and RPExtraTeams[team] and RPExtraTeams[team].name
        local final_result

        local limit = tonumber(cfg.antiSpam[tool]) or 0
        if limit > 0 then
            spamProtection[ply] = spamProtection[ply] or {}
            spamProtection[ply][tool] = spamProtection[ply][tool] or {}
            if !spamProtection[ply][tool].timer or CurTime() >= (spamProtection[ply][tool].timer or 0) then
                spamProtection[ply][tool].timer = CurTime() + 1
                spamProtection[ply][tool].count = 0
            end

            spamProtection[ply][tool].count = spamProtection[ply][tool].count or {}
            if spamProtection[ply][tool].count >= limit then
                if IsValid(ply) then
                    slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "ratelimited_toolgun"), ply)
                end
            return false end
            spamProtection[ply][tool].count = spamProtection[ply][tool].count + 1
        end

        group_tools_usergroup = usergroup
        if !cfg.groupToolRestrictions[usergroup] and cfg.groupToolRestrictions["default"] then group_tools_usergroup = "default" end

        if cfg.entityTargetability and cfg.entityTargetability["list"] and !cfg.bypassTargetabilityGroups[group_tools_usergroup] and IsValid(ent) and !cfg.bypassTargetabilityTools[tool] then
            if cfg.entityTargetability["isBlacklist"] == tobool(cfg.entityTargetability["list"][ent:GetClass()]) then return false end
        end

        local whitelistReturnedTrue = false

        if !whitelistReturnedTrue and cfg.groupToolRestrictions[sid] and cfg.groupToolRestrictions[sid]["list"] and cfg.groupToolRestrictions[sid]["list"][tool] then
            if !cfg.groupToolRestrictions[sid]["isBlacklist"] and tobool(cfg.groupToolRestrictions[sid]["list"][tool]) then whitelistReturnedTrue = true end

            if cfg.groupToolRestrictions[sid]["isBlacklist"] == tobool(cfg.groupToolRestrictions[sid]["list"][tool]) then return false, "blocked-sid" end
        end

        if !whitelistReturnedTrue and cfg.groupToolRestrictions[team_name] and cfg.groupToolRestrictions[team_name]["list"] and cfg.groupToolRestrictions[team_name]["list"][tool] then
            if !cfg.groupToolRestrictions[team_name]["isBlacklist"] and tobool(cfg.groupToolRestrictions[team_name]["list"][tool]) then whitelistReturnedTrue = true end

            if cfg.groupToolRestrictions[team_name]["isBlacklist"] == tobool(cfg.groupToolRestrictions[team_name]["list"][tool]) then return false, "blocked-teamname" end
        end

        if !whitelistReturnedTrue and cfg.groupToolRestrictions[secondary_usergroup] and cfg.groupToolRestrictions[secondary_usergroup]["list"] then
            if !cfg.groupToolRestrictions[secondary_usergroup]["isBlacklist"] and tobool(cfg.groupToolRestrictions[secondary_usergroup]["list"][tool]) then whitelistReturnedTrue = true end

            if cfg.groupToolRestrictions[secondary_usergroup]["isBlacklist"] == tobool(cfg.groupToolRestrictions[secondary_usergroup]["list"][tool]) then return false, "blocked-secondaryusergroup" end
        end

        if !whitelistReturnedTrue and cfg.groupToolRestrictions[group_tools_usergroup] and cfg.groupToolRestrictions[group_tools_usergroup]["list"] then
            if !cfg.groupToolRestrictions[group_tools_usergroup]["isBlacklist"] and tobool(cfg.groupToolRestrictions[group_tools_usergroup]["list"][tool]) then whitelistReturnedTrue = true end

            if cfg.groupToolRestrictions[group_tools_usergroup]["isBlacklist"] == tobool(cfg.groupToolRestrictions[group_tools_usergroup]["list"][tool]) then return false, "blocked-usergroup" end
        end

        if cfg.restrictTools[tool] and !cfg.bypassGroups[usergroup] then
            return false
        end

        if ent:IsVehicle() and cfg.targetVehiclePermission and !cfg.targetVehiclePermission[usergroup] and !cfg.targetVehiclePermission[secondary_usergroup] and !cfg.bypassGroups[usergroup] and !cfg.bypassGroups[secondary_usergroup] then return false end

        if !isstring(owner) and IsValid(owner) and owner:IsPlayer() or owner == "Disconnected" then
            local permGroup = gProtect.PropClasses[ent:GetClass()] and cfg.targetPlayerOwnedProps or cfg.targetPlayerOwned
            if permGroup["*"] or permGroup[usergroup] or permGroup[secondary_usergroup] then return true end
        end
       
        if ent:IsWorld() then
            return nil
        end

        if owner == "World" then
            if cfg.targetWorld["*"] or cfg.targetWorld[usergroup] then return true end

            return false
        end
    end
end

hook.Add("gP:ConfigUpdated", "gP:UpdateToolgunSettings", function(updated)
    if updated ~= "toolgunsettings" then return end
	cfg = gProtect.getConfig(nil, "toolgunsettings")
end)