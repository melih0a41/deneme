local cfg = gProtect.getConfig(nil, "gravitygunsettings")

gProtect = gProtect or {}

gProtect.HandleGravitygunPermission = function(ply, ent)
    if cfg.enabled then
        local owner = gProtect.GetOwner(ent)

        if !owner then
            local result = gProtect.GetOwnerString(ent)
            owner = string.sub(result, 1, 5) == "STEAM" and "Disconnected" or "World"
        end
        
        local usergroup = ply:GetUserGroup()

        if IsValid(ent) and ent:IsPlayer() then return nil end

        if cfg.blockedEntities[ent:GetClass()] and !cfg.bypassGroups[ply:GetUserGroup()] and !cfg.bypassGroups["*"] then return false end

        if owner == "World" then
            if cfg.targetWorld["*"] or cfg.targetWorld[usergroup] then return true end
        end

        if !isstring(owner) and IsValid(owner) and owner:IsPlayer() or owner == "Disconnected" then
            local permGroup = gProtect.PropClasses[ent:GetClass()] and cfg.targetPlayerOwnedProps or cfg.targetPlayerOwned
            if permGroup["*"] or permGroup[usergroup] or ply == owner then return true end
        end
    end
end

hook.Add("GravGunPunt", "gP:GravGunPuntingLogic", function(ply, ent)
	if cfg.enabled and (cfg.DisableGravityGunPunting or (IsValid(ent) and cfg.blockedEntities[ent:GetClass()])) then return false end
end)

hook.Add("gP:ConfigUpdated", "gP:UpdateGravGunSettings", function(updated)
    if updated ~= "gravitygunsettings" then return end
	cfg = gProtect.getConfig(nil, "gravitygunsettings")
end)