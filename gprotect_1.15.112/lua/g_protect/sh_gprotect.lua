gProtect = gProtect or {}
gProtect.language = gProtect.language or {}

gProtect.PropClasses = {
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["prop_static"] = true
}

local cachedSID = {}

local function getBySteamID(sid)
	if cachedSID[sid] and IsValid(cachedSID[sid]) then return cachedSID[sid] end
	for k,v in ipairs(player.GetAll()) do
		if !IsValid(v) then continue end
		if v:SteamID() == sid then
			cachedSID[sid] = v
			return v
		end
	end
end

gProtect.GetOwner = function(ent)
	if !IsValid(ent) then return end
	
	local result = ent.gPOwner or ""
	local foundply = getBySteamID(result)
	
	foundply = !isstring(foundply) and (IsValid(foundply) and foundply:IsPlayer() and foundply) or foundply

	return (foundply and foundply) or nil
end

gProtect.GetHighestTargetPlayerOwnerPropsGroupLevel = function(ply)
    local groupLevels = gProtect.TouchPermission and gProtect.TouchPermission["targetPlayerOwnedPropsGroupLevel"] and gProtect.TouchPermission["targetPlayerOwnedPropsGroupLevel"]["weapon_physgun"] or {}
    local usergroup = ply:GetUserGroup()
    local secondaryUsergroup = ply.GetSecondaryUserGroup and ply:GetSecondaryUserGroup()

	local userGroupLevel = tonumber(groupLevels[usergroup])
	local secondaryUserGroupLevel = tonumber(groupLevels[secondaryUsergroup])

    if table.IsEmpty(groupLevels) or (!userGroupLevel and !secondaryUserGroupLevel) then return 0 end

	if !secondaryUserGroupLevel then return userGroupLevel end
	if !userGroupLevel then return secondaryUserGroupLevel end

    return math.max(userGroupLevel, secondaryUserGroupLevel)
end

gProtect.GetOwnerString = function(ent)
	return IsValid(ent) and ent.gPOwner or ""
end

gProtect.HasPermission = function(ply, perm)
	local usergroup, result = ply:GetUserGroup(), false

	if gProtect.config.Permissions[perm][usergroup] then return true end

	if CAMI and isfunction(CAMI.PlayerHasAccess) then
		if CAMI.PlayerHasAccess(ply, perm, function(cbResult)
			result = cbResult
		end) then
			return true
		end
	end

	return result
end

gProtect.HandlePermissions = function(ply, ent, permission)
	if (!IsValid(ent) and !ent:IsWorld()) or !IsValid(ply) or !ply:IsPlayer() then return false end

	local owner = gProtect.GetOwner(ent)
	local weapon = permission and permission or IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or "weapon_physgun"
	local ownsid = isstring(owner) and owner or IsValid(owner) and owner:SteamID() or ""

	if gProtect.IsBuddyWithOwner(ent, ply, weapon) then
		return true
	end
	
	if ent:IsWorld() then return nil end

	if gProtect.TouchPermission then
		local isProp = gProtect.PropClasses[ent:GetClass()]
		local isOwnerValidPlayer = owner and IsValid(owner) and owner:IsPlayer()
		local touchTable

		if isOwnerValidPlayer then
			touchTable = isProp and gProtect.TouchPermission["targetPlayerOwnedProps"] or gProtect.TouchPermission["targetPlayerOwned"]
		else
			touchTable = gProtect.TouchPermission["targetWorld"]
		end

		if touchTable and touchTable[weapon] then
			touchTable = touchTable[weapon]
		end

		if !touchTable then return false end

		local hasTargetPerms = touchTable and touchTable["*"] or touchTable[ply:GetUserGroup()]
		local passesGroupLevelCheck = true

		if hasTargetPerms and isProp and isOwnerValidPlayer then
			local highestGroupLevel = gProtect.GetHighestTargetPlayerOwnerPropsGroupLevel(ply)
			local ownerHighestGroupLevel = gProtect.GetHighestTargetPlayerOwnerPropsGroupLevel(owner)

			if highestGroupLevel < ownerHighestGroupLevel then
				passesGroupLevelCheck = false
			end
		end

		if hasTargetPerms and passesGroupLevelCheck then return true end
	end
	
	return false, true
end

gProtect.IsBuddyWithOwner = function(ent, ply, permission)
    local owner = gProtect.GetOwner(ent)

    if !owner then return false end

    if ply == owner then return true end

    local ownsid = isstring(owner) and owner or IsValid(owner) and owner:SteamID()

    if !ownsid then return false end
    
    if gProtect.TouchPermission[ownsid] and gProtect.TouchPermission[ownsid][permission] and istable(gProtect.TouchPermission[ownsid][permission]) and gProtect.TouchPermission[ownsid][permission][ply:SteamID()] then
        return true
    end
end

local cfg = SERVER and gProtect.getConfig(nil, "physgunsettings") or {}

hook.Add("PhysgunPickup", "gP:PhysgunPickupLogic", function(ply, ent)
	if SERVER and !cfg.enabled or ent:IsPlayer() then return nil end
	if TCF and TCF.Config and ent:GetClass() == "cocaine_cooking_pot" and IsValid( ent:GetParent() ) then return nil end --- Compatibilty with "The Cocaine Factory".

	--- This checks for config options that only the server can access.
	if SERVER and gProtect.HandlePhysgunPermission(ply, ent) == false then return false end
	if gProtect.HandlePermissions(ply, ent, "weapon_physgun") == false then return false end
end)

hook.Add("gP:ConfigUpdated", "gP:UpdatePhysgunSH", function(updated)
	if updated ~= "physgunsettings" or CLIENT then return end
	cfg = gProtect.getConfig(nil, "physgunsettings")
end)

local function registerPerm(name)
	if CAMI and isfunction(CAMI.RegisterPrivilege) then CAMI.RegisterPrivilege({Name = name, hasAccess = false, callback = function() end}) end
end

registerPerm("gProtect_Settings")
registerPerm("gProtect_StaffNotifications")
registerPerm("gProtect_DashboardAccess")