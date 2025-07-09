local cfg = gProtect.getConfig(nil, "canusesettings")

gProtect = gProtect or {}

hook.Add("PlayerUse", "gP:CanUseSettings", function(ply, ent)
    if cfg.enabled and !ent:IsWorld() then
        local owner = gProtect.GetOwner(ent)

        if !owner then
            local result = gProtect.GetOwnerString(ent)
            owner = string.sub(result, 1, 5) == "STEAM" and "Disconnected" or "World"
        end

        local usergroup = ply:GetUserGroup()
        local secondary_usergroup = ply.GetSecondaryUserGroup and ply:GetSecondaryUserGroup()
        
        if tobool(cfg.blockedEntities[ent:GetClass()]) == cfg.blockedEntitiesisBlacklist and !cfg.bypassGroups[usergroup] and !cfg.bypassGroups[secondary_usergroup] then return false end

        if !isstring(owner) and IsValid(owner) and owner:IsPlayer() or owner == "Disconnected" then
            local permGroup = gProtect.PropClasses[ent:GetClass()] and cfg.targetPlayerOwnedProps or cfg.targetPlayerOwned
            if permGroup["*"] or permGroup[usergroup] or permGroup[secondary_usergroup] or gProtect.IsBuddyWithOwner(ent, ply, "canUse") then return end
        end

        if owner == "World" then
            if cfg.targetWorld["*"] or cfg.targetWorld[usergroup] then return end

            return false
        end
    end
end)

hook.Add("gP:ConfigUpdated", "gP:UpdateCanUseSettings", function(updated)
    if updated ~= "canusesettings" then return end
	cfg = gProtect.getConfig(nil, "canusesettings")
end)