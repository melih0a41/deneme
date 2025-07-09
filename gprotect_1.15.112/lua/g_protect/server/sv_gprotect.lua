
gProtect = gProtect or {}
gProtect.TouchPermission = gProtect.TouchPermission or {}
gProtect.ownershipCache = gProtect.ownershipCache or {}
gProtect.data = gProtect.data or {}
gProtect.spawnedents = gProtect.spawnedents or {}

local disconnectedPly, syncedQueue, limitRequests = {}, {}, {}

resource.AddWorkshop("2064194474")

util.AddNetworkString("gP:Networking")

local parseDataFromModule = function(moduleName, ...)
	local data = {}
	local args = {...}

	for _, v in ipairs(args) do
		data[v] = gProtect.data[moduleName][v]
	end

	return data
end

local function setSpawnedEnt(ply, ent)
	if !IsValid(ply) or !IsValid(ent) then return end
	
	local sid = ply:SteamID()
	
	gProtect.spawnedents[sid] = gProtect.spawnedents[sid] or {}
	gProtect.spawnedents[sid][ent] = true
end

local syncToolgunSettings = function(ply)
	gProtect.networkData(ply, "toolgunsettings", parseDataFromModule("toolgunsettings", "groupToolRestrictions", "restrictTools", "bypassGroups"))
end

local function networkEntOwnership(ent, ply)
	net.Start("gP:Networking")
	net.WriteUInt(2, 2)
	net.WriteUInt(ent:EntIndex(), 14)
	net.WriteString(ent.gPOwner or "")

	if IsValid(ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

local function syncEntOwnership(ply)
	for k,v in ipairs(ents.GetAll()) do
		if !v.gPOwner then continue end

		networkEntOwnership(v, ply)
	end
end

gProtect.SetOwner = function(ply, ent)
	if !IsValid(ent) or !IsValid(ply) then return end
	
	local sid = ply:SteamID()

	if sid then
		ent.gPOwner = sid

		networkEntOwnership(ent)
	end

	gProtect.ownershipCache[ent] = ply

	setSpawnedEnt(ply, ent)
end

hook.Add("EntityRemoved", "gP:EntOwnershipClearQueue", function(ent)
	ent.gPOwner = nil

	networkEntOwnership(ent)
end)

gProtect.GetOwnedEnts = function(ply)
	return gProtect.spawnedents[ply:SteamID()] or {}
end

gProtect.getConfig = function(info, modul)
	local data = gProtect.data

	if !data[modul] or (info and !data[modul][info]) then data = table.Copy(gProtect.config.modules) end

	return info and data[modul][info] or data[modul]
end

gProtect.GetConfig = gProtect.getConfig

local miscscfg = gProtect.getConfig(nil, "miscs")
local generalcfg = gProtect.getConfig(nil, "general")
local gravityguncfg = gProtect.getConfig(nil, "gravitygunsettings")
local physguncfg = gProtect.getConfig(nil, "physgunsettings")
local toolguncfg = gProtect.getConfig(nil, "toolgunsettings")
local ghostcfg = gProtect.getConfig(nil, "ghosting")

local networkData = function(ply, moduleName, data)
	local networkTo = ply

	net.Start("gP:Networking")
	net.WriteUInt(1, 2)
	net.WriteUInt(#data, 32)
	net.WriteData(data, #data)
	net.WriteString(moduleName)
	
	if !ply then
		networkTo = {}

		for _, v in ipairs(player.GetAll()) do
			if !gProtect.HasPermission(v, "gProtect_Settings") then continue end
	
			table.insert(networkTo, v)
		end
	end

	net.Send(networkTo)
end

gProtect.networkData = function(ply, moduleName, overrideData)
	local settings = overrideData or gProtect.data

	if moduleName then
		if !overrideData then
			settings = settings[moduleName]
		end
	else
		moduleName = ""
	end
	
	settings = util.TableToJSON(settings)
	settings = util.Compress(settings)

	networkData(ply, moduleName, settings)
end

gProtect.networkTouchPermissions = function(ply, exclusive)
	if exclusive then
		net.Start("gP:Networking")
		net.WriteUInt(0, 2)
		net.WriteString(util.TableToJSON(gProtect.TouchPermission[exclusive]))
		net.WriteString(exclusive)
		
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	else
		for k,v in pairs(gProtect.TouchPermission) do
			gProtect.networkTouchPermissions(ply, k)
		end
	end
end

gProtect.blacklistModel = function(list, todo, ply)
	todo = todo or nil

	local data = gProtect.data
	local count = table.Count(list)
	local changes = {}

	for mdl, v in pairs(list) do
		changes[string.lower(mdl)] = todo or false
		data["spawnrestriction"]["blockedModels"][string.lower(mdl)] = todo

		if count <= 3 then
			slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, todo and "added-blacklist" or "removed-blacklist", mdl), ply)
		end
	end

	gProtect.updateSetting("spawnrestriction", "blockedModels", changes)

	if count > 3 then
		slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, todo and "blacklisted-multiple" or "unblacklisted-multiple", count), ply)
	end

	gProtect.networkData(nil, "spawnrestriction")

	hook.Run("gP:ConfigUpdated", "spawnrestriction")
end

gProtect.blacklistEntity = function(list, todo, ply)
	todo = todo or nil

	local data = gProtect.data
	local count = table.Count(list)
	local changes = {}

	for classname, v in pairs(list) do
		changes[string.lower(classname)] = todo or false
		data["general"]["blacklist"][string.lower(classname)] = todo

		if count <= 3 then
			slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, todo and "added-blacklist-ent" or "removed-blacklist-ent", classname), ply)
		end
	end

	gProtect.updateSetting("general", "blacklist", changes)

	if count > 3 then
		slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, todo and "blacklisted-multiple-ent" or "unblacklisted-multiple-ent", count), ply)
	end

	gProtect.networkData(nil, "general")

	hook.Run("gP:ConfigUpdated", "general")
end

local findAllTraceHull = function(ent, offset)
	local foundEntities = {ent}

	for i=1, ents.GetCount() do
		local pos = ent:GetPos()
		local mins, maxs = ent:OBBMins(), ent:OBBMaxs()


		if offset then
			mins.x = mins.x - offset
			mins.y = mins.y - offset
			mins.z = mins.z - offset
	
			maxs.x = maxs.x + offset
			maxs.y = maxs.y + offset
			maxs.z = maxs.z + offset
		end
		
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos
		tracedata.filter = foundEntities
		tracedata.mins = mins
		tracedata.maxs = maxs
		local trace = util.TraceHull( tracedata )
		
		if !IsValid(trace.Entity) then break end
	
		table.insert(foundEntities, trace.Entity)
	end

	return foundEntities
end

gProtect.obscureDetection = function(ent, method)
	local results = {}

	if method == 1 then
		local pos = ent:GetPos()
		local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
		
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos
		tracedata.filter = ent
		tracedata.mins = mins
		tracedata.maxs = maxs
		local trace = util.TraceHull( tracedata )
		
		if trace.Entity and IsValid(trace.Entity) then
			results = {trace.Entity}
		end
	elseif method == 2 then
		results = table.Merge(findAllTraceHull(ent), gProtect.obscureDetection(ent))
	elseif method == 3 then
		local mins, maxs = ent:OBBMins(), ent:OBBMaxs()

		results = ents.FindInBox(ent:LocalToWorld(mins), ent:LocalToWorld(maxs))
	elseif method == 4 then
		local offset = ghostcfg.obscureOffset or 10
		local potentialColliders = ents.FindInSphere(ent:GetPos(), ent:BoundingRadius() + offset)

		for k,v in ipairs(potentialColliders) do
			if v:GetSolid() == SOLID_VPHYSICS then continue end

			local nearestFromCollider = v:NearestPoint(ent:GetPos())
			local nearestPoint = ent:NearestPoint(nearestFromCollider)

			if nearestFromCollider:DistToSqr(nearestPoint) <= (offset * offset) then
				table.insert(results, v)
			end
		end
	else
		local added = {}

		for k, v in ipairs(table.Add(gProtect.obscureDetection(ent, 4), gProtect.obscureDetection(ent, 3))) do
			if added[v] or v == ent then continue end

			added[v] = true

			table.insert(results, v)
		end
	end
	
	return results
end

local notifydelay = {}

gProtect.NotifyStaff = function(ply, msg, delay, ...)
	local additions = {...}

	if !IsValid(ply) or !ply:IsPlayer() then return end

	if delay then
		if notifydelay[ply] and notifydelay[ply][msg] and CurTime() - notifydelay[ply][msg] < delay then return end
		notifydelay[ply] = notifydelay[ply] or {}
		notifydelay[ply][msg] = CurTime()
	end

	for k,v in ipairs(player.GetAll()) do
		if v == ply then continue end
		
		if gProtect.HasPermission(v, "gProtect_StaffNotifications") then
			slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, msg, ply:Nick(), unpack(additions)), v)
		end
	end
end

hook.Add("gP:UndoAdded", "gP:handleOwnership", function(ply, ent)
	gProtect.SetOwner(ply, ent)
end)

hook.Add("BaseWars_PlayerBuyEntity", "gP:handleOwnership", function(ply, ent)
	setSpawnedEnt(ply, ent)
end)

hook.Add("BaseWars_PlayerBuyProp", "gP:handleOwnership", function(ply, ent)
	setSpawnedEnt(ply, ent)
end)

hook.Add("BaseWars_PlayerBuyGun", "gP:handleOwnership", function(ply, ent)
	setSpawnedEnt(ply, ent)
end)

hook.Add("BaseWars_PlayerBuyDrug", "gP:handleOwnership", function(ply, ent)
	setSpawnedEnt(ply, ent)
end)

hook.Add("OnEntityCreated", "gP:handleProps", function(ent) -- This is a stupid solution, however due to how locked down things are it has to be like this.
	if IsValid(ent) and gProtect.PropClasses[ent:GetClass()] then
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			if ent.e2_propcore_last_action then return end

			local physobj = ent:GetPhysicsObject()

			if !IsValid(physobj) then return end

			if !physobj:IsMotionEnabled() then
				physobj:Sleep()
			end
		end)
	end
end)

hook.Add("PlayerSpawnedProp", "gP:handleSpawning", function(ply, model, ent)
	if IsValid(ent) then
		if IsValid(ply) and ply:IsPlayer() then 
			if miscscfg.enabled and miscscfg.freezeOnSpawn then 
				local physobj = ent:GetPhysicsObject()
				if IsValid(physobj) then 
					physobj:EnableMotion(false) 
					physobj:Sleep()
				end 
			end 
		end

		gProtect.HandleMaxObstructs(ent, ply)
	end
end)

hook.Add("CanTool", "gP:CanToolHandeler", function(ply, tr, tool)
	local miscresult = gProtect.HandleMiscToolGun(ply, tr, tool)
	local advdupe2result = gProtect.HandleAdvDupe2ToolGun(ply, tr, tool)
	local toolgunsettingsresult, toolgun_error = gProtect.HandleToolgunPermissions(ply, tr, tool)
	if miscresult == false or advdupe2result == false then return false end
	if tr.Entity.sppghosted and tool ~= "remover" then return false end

	if toolgunsettingsresult == false then if toolgun_error then slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, toolgun_error), ply) end return false end

	local hasPerm = gProtect.HandlePermissions(ply, tr.Entity, "gmod_tool")

	if hasPerm == false then return false end

	local finalresult = toolgunsettingsresult ~= nil and (toolgunsettingsresult or hasPerm) or nil
	
	if finalresult == nil then
		hook.Run("OnTool", ply, tr, tool)
	end
	
	return finalresult
end)

hook.Add("MotionChanged", "gP:HandleDroppedEntities", function(phys, enabledmotion)
	if !IsValid(phys) then return end
	local ent = phys:GetEntity()
	if IsValid(ent) then
		if !ent.gPOldCollisionGroup then
			if generalcfg.protectedFrozenEnts[ent:GetClass()] and !enabledmotion and !ent.BeingPhysgunned and !ent.sppghosted and ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
				ent.gPOldCollisionGroup = ent:GetCollisionGroup()
				ent:SetCollisionGroup(generalcfg.protectedFrozenGroup)
			end
		elseif enabledmotion then
			ent:SetCollisionGroup(ent.gPOldCollisionGroup)
			ent.gPOldCollisionGroup = nil
		end
	end
end)

hook.Add("OnTool", "gP:HandleChangedCollision", function(ply, tr, tool)
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) and tool == "nocollide" and generalcfg.protectedFrozenEnts[ent:GetClass()] and ent.gPOldCollisionGroup then
		timer.Simple(.1, function()
			ent.gPOldCollisionGroup = ent:GetCollisionGroup()
		end)
	end
end)

hook.Add("OnProperty", "gP:HandleChangedCollisionProperty", function(ply, property, ent)
	if IsValid(ent) and property == "collision" and generalcfg.protectedFrozenEnts[ent:GetClass()] and ent.gPOldCollisionGroup then
		timer.Simple(.1, function()
			ent.gPOldCollisionGroup = ent:GetCollisionGroup()
		end)
	end
end)

hook.Add("PhysgunDrop", "gP:HandlePhysgunDropping", function(ply, ent)
	local obstructed = gProtect.HandleMaxObstructs(ent, ply)

	gProtect.PhysgunSettingsOnDrop(ply, ent, obstructed)
	
	hook.Run("PhysgunDropped", ply, ent, obstructed)
end)

hook.Add("OnPhysgunPickup", "gP:HandlePickups", function(ply, ent)
    if IsValid(ent) then
        ent.BeingPhysgunned = ent.BeingPhysgunned or {}
        ent.BeingPhysgunned[ply] = true
    end
end)

hook.Add("GravGunPickupAllowed", "gP:HandleGravgunPickup", function(ply, ent, norun)
	if TCF and TCF.Config and ent:GetClass() == "cocaine_cooking_pot" and IsValid(ent:GetParent()) or !gravityguncfg.enabled then return nil end

	if isbool(gProtect.HandleGravitygunPermission(ply, ent)) then return gProtect.HandleGravitygunPermission(ply, ent) end

	return gProtect.HandlePermissions(ply, ent, "weapon_physcannon")
end)

hook.Add("CanProperty", "gP:HandleCanProperty", function(ply, property, ent)
	if IsValid(ent) and ent.sppghosted and property ~= "remover" then return false end
	local result = gProtect.CanPropertyPermission(ply, property, ent)

	if !isbool(result) then result = gProtect.HandlePermissions(ply, ent, "canProperty") end

	if result then
		hook.Run("OnProperty", ply, property, ent)

		timer.Simple(0, function() gProtect.GhostHandler(ent) end)
	end

    return result
end)

hook.Add("playerBoughtCustomEntity", "gP:DarkRPEntitesHandler", function(ply, enttbl, ent, price)
	if IsValid(ply) then
		local sid = ply:SteamID()

		gProtect.spawnedents[sid] = gProtect.spawnedents[sid] or {}
		gProtect.spawnedents[sid][ent] = true

		if IsValid(ent) and isfunction(ent.Setowning_ent) then
			ent:Setowning_ent(ply)
		end
	end
end)

hook.Add("PlayerSpawnedSENT", "gP:HandleSpawningEntities", function(ply, ent)
	if IsValid(ent) and isfunction(ent.Setowning_ent) and IsValid(ply) then
		ent:Setowning_ent(ply)
	end
end)

hook.Add("canPocket", "gP:HandleOnPickup", function(ply, ent)
	if IsValid(ent) and isfunction(ent.Setowning_ent) then
		local owner = gProtect.GetOwner(ent)

		if owner and IsValid(owner) and owner:IsPlayer() then
			ent:Setowning_ent(owner)
		end
	end
end)

hook.Add("onPocketItemDropped", "gP:HandlePocketDropping", function(ply, ent, item, id)
	if !ply or !ply.darkRPPocket or !ply.darkRPPocket[item] or !ply.darkRPPocket[item].DT then return end

	for k,v in pairs(ply.darkRPPocket[item].DT) do
        if k == "owning_ent" and IsValid(v) and v:IsPlayer() and isfunction(ent.Getowning_ent) then
			gProtect.SetOwner(ent:Getowning_ent(), ent)
        end
    end
end)


hook.Add("PlayerSay", "gP:OpenMenu", function(ply, text, _)
	if string.lower(text) == "!gprotect" then
		if !gProtect.HasPermission(ply, "gProtect_Settings") and !gProtect.HasPermission(ply, "gProtect_DashboardAccess") then
			return text
		end

		if !limitRequests[ply:SteamID()] then gProtect.networkData(ply) end
		
		ply:ConCommand("gprotect_settings")

		return ""
	end
end )

hook.Add("gP:ConfigUpdated", "gP:UpdateCoreConfig", function(updated)
	if !updated or updated == "miscs" or updated == "general" or updated == "gravitygunsettings" or updated == "physgunsettings" or updated == "toolgunsettings" or updated == "ghosting" then
		miscscfg = gProtect.getConfig(nil, "miscs")
		generalcfg = gProtect.getConfig(nil, "general")
		gravityguncfg = gProtect.getConfig(nil, "gravitygunsettings")
		physguncfg = gProtect.getConfig(nil, "physgunsettings")
		toolguncfg = gProtect.getConfig(nil, "toolgunsettings")
		ghostcfg = gProtect.getConfig(nil, "ghosting")
	end
end)

hook.Add("PlayerInitialSpawn", "gP:FirstJoiner", function(ply)
	local sid = ply:SteamID()

	-- Sync ownership cache
	local ownedEnts = gProtect.GetOwnedEnts(ply)

	for k, v in pairs(ownedEnts) do
		if IsValid(k) then
			gProtect.ownershipCache[k] = ply
		end
	end

	disconnectedPly[sid] = nil
	if sid and timer.Exists("gP:RemoveDisconnectedEnts_"..sid) then timer.Remove("gP:RemoveDisconnectedEnts_"..sid) end
end)

local function deleteDisconnectedEntities(sid, force)
	if sid then
		if !gProtect.spawnedents[sid] then return end
		for k,v in pairs(gProtect.spawnedents[sid]) do
			if !IsValid(k) then continue end

			if gProtect.GetOwner(k) or (generalcfg.remDiscPlyEntSpecific[k:GetClass()] and !force) then continue end
			k:Remove()

			gProtect.spawnedents[k] = nil
		end
		
		disconnectedPly[sid] = nil
	else
		if !disconnectedPly then return end
		for k, v in pairs(disconnectedPly) do
			if !gProtect.spawnedents[k] then continue end
			for i, z in pairs(gProtect.spawnedents[k]) do
				if !IsValid(i) then continue end
				local class = i:GetClass()
				if generalcfg.remDiscPlyEntSpecific[class] then continue end
				i:Remove()

				gProtect.spawnedents[i] = nil
			end

			disconnectedPly[k] = nil
		end
	end
end

hook.Add("PlayerDisconnected", "gP:HandleDisconnects", function(ply)
	local sid = ply:SteamID()
	limitRequests[sid] = nil
	disconnectedPly[sid] = true

	if !gProtect.spawnedents[sid] then return end

	for k,v in pairs(gProtect.spawnedents[sid]) do
		if IsValid(k) then
			local time = tonumber(generalcfg.remDiscPlyEntSpecific[k:GetClass()])

			if time and time >= 0 then
				timer.Simple(time, function()
					if !disconnectedPly[sid] then return end

					if IsValid(k) then k:Remove() end
				end)
			end
		end
	end
	
	if (tonumber(generalcfg.remDiscPlyEnt) or 0) < 0 then return end

	timer.Create("gP:RemoveDisconnectedEnts_"..sid, generalcfg.remDiscPlyEnt, 1, function()
		deleteDisconnectedEntities(sid)
	end)
end)

concommand.Add("gprotect_transfer_fpp_blockedmodels", function( ply, cmd, args )
	if IsValid(ply) and !gProtect.HasPermission(ply, "gProtect_Settings") then return end
	local data = gProtect.data
	local changes = {}

	if args[1] == "1" then
		for k,v in pairs(FPP.BlockedModels) do
			changes[string.lower(k)] = true
			data["spawnrestriction"]["blockedModels"][string.lower(k)] = true
		end
	else
		local fppblockedmodels = sql.Query("SELECT * FROM FPP_BLOCKEDMODELS1;")
	
		if !istable(fppblockedmodels) then slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "unsuccessfull-transfer"), ply) return end
	
		for k,v in pairs(fppblockedmodels) do
			changes[string.lower(v.model)] = true
			data["spawnrestriction"]["blockedModels"][string.lower(v.model)] = true
		end
	end

	gProtect.updateSetting("spawnrestriction", "blockedModels", changes)
	gProtect.networkData(nil, "spawnrestriction")

	slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "successfull-fpp-blockedmodels"), ply)
end)

concommand.Add("gprotect_transfer_fpp_grouptools", function( ply, cmd, args )
	if IsValid(ply) and !gProtect.HasPermission(ply, "gProtect_Settings") then return end
	local grouptools = sql.Query("SELECT * FROM FPP_GROUPTOOL;")

	local data = gProtect.data

	if !istable(grouptools) then slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "unsuccessfull-transfer"), ply) return end

	for k,v in pairs(grouptools) do
		if !v.groupname or !v.tool then continue end
		data["toolgunsettings"]["groupToolRestrictions"][v.groupname] = data["toolgunsettings"]["groupToolRestrictions"][v.groupname] or {list = {}, isBlacklist = true}
		data["toolgunsettings"]["groupToolRestrictions"][v.groupname]["list"] = data["toolgunsettings"]["groupToolRestrictions"][v.groupname]["list"] or {}
		if data["toolgunsettings"]["groupToolRestrictions"][v.groupname].isBlacklist == nil then data["toolgunsettings"]["groupToolRestrictions"][v.groupname].isBlacklist = true end

		data["toolgunsettings"]["groupToolRestrictions"][v.groupname]["list"][v.tool] = true
	end

	gProtect.updateSetting("toolgunsettings", "groupToolRestrictions")

	gProtect.networkData(nil, "toolgunsettings")
	slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "successfull-fpp-grouptools"), ply)
end)

net.Receive("gP:Networking", function(_, ply)
	local perm_config, perm_dashboard = gProtect.HasPermission(ply, "gProtect_Settings"), gProtect.HasPermission(ply, "gProtect_DashboardAccess")
	if !perm_config and !perm_dashboard then return end
	local action = net.ReadUInt(2)

	if !perm_config and action ~= 1 then slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "insufficient-permission"), ply) return end

	if action == 1 then
		local mode = net.ReadUInt(2)
		local todo = net.ReadUInt(3)
		if mode == 1 then
			local victim = net.ReadEntity()
			if !IsValid(victim) or !victim:IsPlayer() then return end

			gProtect.spawnedents[victim:SteamID()] = gProtect.spawnedents[victim:SteamID()] or {}

			if todo == 1 then
				if !gProtect.spawnedents[victim:SteamID()] then return end
				for k,v in pairs(gProtect.spawnedents[victim:SteamID()]) do
					if !IsValid(k) or !gProtect.PropClasses[k:GetClass()] then continue end
					local physob = k:GetPhysicsObject()
					if IsValid(physob) then
						physob:EnableMotion(false)
					end
				end

				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "you-frozen-props", victim:Nick()), ply)
				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "props-frozen"), victim)
			elseif todo == 2 then
				for k,v in pairs(gProtect.spawnedents[victim:SteamID()]) do
					if !IsValid(k) or !string.find(k:GetClass(), "prop") then continue end
					k:Remove()
				end
				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "you-removed-props", victim:Nick()), ply)
				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "props-removed"), victim)
			elseif todo == 3 then
				for k,v in pairs(gProtect.spawnedents[victim:SteamID()]) do
					if !IsValid(k) or !string.find(k:GetClass(), "prop") then continue end
					gProtect.GhostHandler(k, true, nil, nil, true)
				end

				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "you-ghosted-props", victim:Nick()), ply)
				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "props-ghosted"), victim)
			elseif todo == 4 then
				for k,v in pairs(gProtect.spawnedents[victim:SteamID()]) do
					if !IsValid(k) then continue end
					k:Remove()
				end

				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "you-removed-ents", victim:Nick()), ply)
				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "ents-removed"), victim)
			end
		elseif mode == 2 then
			if todo == 1 then
				for k, v in ipairs(player.GetAll()) do
					slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "everyones-props-ghosted"), v)
					if !gProtect.spawnedents[v:SteamID()] then continue end
					for i, z in pairs(gProtect.spawnedents[v:SteamID()]) do
						if !IsValid(i) or !string.find(i:GetClass(), "prop") then continue end
						gProtect.GhostHandler(i, true, nil, nil, true)
					end
				end
			elseif todo == 2 then
				for k, v in ipairs(player.GetAll()) do
					slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "everyones-props-frozen"), v)
					if !gProtect.spawnedents[v:SteamID()] then continue end
					for i, z in pairs(gProtect.spawnedents[v:SteamID()]) do
						if !IsValid(i) or !gProtect.PropClasses[i:GetClass()] then continue end
						local physob = i:GetPhysicsObject()
						if IsValid(physob) then
							physob:EnableMotion(false)
						end
					end
				end
			elseif todo == 3 then
				deleteDisconnectedEntities(nil, true)

				slib.notify(gProtect.config.Prefix..slib.getLang("gprotect", gProtect.config.SelectedLanguage, "disconnected-ents-removed"), ply)
			end
		end
	elseif action == 2 then
		local mode = net.ReadUInt(2)
		local list = net.ReadString()
		local todo = net.ReadBool()

		if !list then return end
		
		list = util.JSONToTable(list)

		local count = #list

		if mode == 1 then
			gProtect.blacklistModel(list, todo, ply)
		elseif mode == 2 then
			gProtect.blacklistEntity(list, todo, ply)
		end
	elseif action == 3 then
		local moduleName = net.ReadString()
		local variable = net.ReadString()
		
		if !moduleName or !variable then return end

		local statement = slib.getStatement(gProtect.config.modules[moduleName][variable])

		local value

		if statement == "string" then
			value = net.ReadString()
		elseif statement == "bool" then
			value = net.ReadBool()
		elseif statement == "int" then
			value = net.ReadInt(18)
		elseif statement == "table" or statement == "color" then
			local len = net.ReadUInt(32)
			value = net.ReadData(len)
			value = util.JSONToTable(util.Decompress(value))
		end
		
		gProtect.data[moduleName][variable] = value

		gProtect.updateSetting(moduleName, variable)
		gProtect.networkData(nil, moduleName)

		hook.Run("gP:ConfigUpdated", moduleName, variable, value)
	end
end)

local function verifyData()
	local data = gProtect.data
	local modified = {}

	for k, v in pairs(gProtect.config.modules) do
		if data[k] == nil then
			data[k] = v
			modified[k] = true
			continue
		end
		
		if istable(v) then
			for i, z in pairs(v) do
				if data[k][i] == nil or slib.getStatement(data[k][i]) ~= slib.getStatement(z) then
					data[k][i] = z
					modified[k] = true
				end
			end
		end
	end

	for k, v in pairs(data) do
		if gProtect.config.modules[k] == nil then
			data[k] = nil
		end
		
		if istable(v) then
			for i, z in pairs(v) do
				if gProtect.config.modules[k][i] == nil then
					data[k][i] = nil
				end
			end
		end
	end

	for k, v in pairs(modified) do
		gProtect.updateSetting(k)
		
		hook.Run("gP:ConfigUpdated", k)
	end

	local toolgun = {toolguncfg.targetWorld, toolguncfg.targetPlayerOwned, toolguncfg.targetPlayerOwnedProps}
	local physgun = {physguncfg.targetWorld, physguncfg.targetPlayerOwned, physguncfg.targetPlayerOwnedProps, physguncfg.targetPlayerOwnedPropsGroupLevel}
	local gravitygun = {gravityguncfg.targetWorld, gravityguncfg.targetPlayerOwned, gravityguncfg.targetPlayerOwnedProps}

	local permTypes = {"targetWorld", "targetPlayerOwned", "targetPlayerOwnedProps", "targetPlayerOwnedPropsGroupLevel"}

	for k,v in ipairs(permTypes) do
		gProtect.TouchPermission[v] = gProtect.TouchPermission[v] or {}
		gProtect.TouchPermission[v]["gmod_tool"] = toolgun[k]
		gProtect.TouchPermission[v]["weapon_physgun"] = physgun[k]
		gProtect.TouchPermission[v]["weapon_physcannon"] = gravitygun[k]
	end
end

timer.Create("gP:RemoveOutOfBounds", generalcfg["remOutOfBounds"], 0, function()
	for k,v in ipairs(ents.GetAll()) do
		if !generalcfg["remOutOfBoundsWhitelist"][v:GetClass()] then continue end
		if !v:IsInWorld() then v:Remove() end
	end
end)

hook.Add("gP:ConfigUpdated", "gP:RegisterTouchPermissions", function(module, variable, value)
	if module == "general" and variable == "remOutOfBounds" then
		timer.Adjust("gP:RemoveOutOfBounds", generalcfg["remOutOfBounds"])	
	end

	local sharedSettings = {
		["targetWorld"] = true,
		["targetPlayerOwned"] = true,
		["targetPlayerOwnedProps"] = true,
		["targetPlayerOwnedPropsGroupLevel"] = true,
	}

	if sharedSettings[variable] then
		local type

		if module == "toolgunsettings" then
			type = "gmod_tool"
		elseif module == "physgunsettings" then
			type = "weapon_physgun"
		elseif module == "gravitygunsettings" then
			type = "weapon_physcannon"
		end

		if type then
			gProtect.TouchPermission[variable] = gProtect.TouchPermission[variable] or {}
			gProtect.TouchPermission[variable][type] = value

			gProtect.networkTouchPermissions(nil, variable)
		end
	end
	
	if module == "toolgunsettings" and (variable == "groupToolRestrictions" or variable == "restrictTools" or variable == "bypassGroups") then
		syncToolgunSettings()
	end
end)

hook.Add("gP:SQLConnected", "gP:SyncData", function()
	gProtect.syncConfig()
end)

hook.Add("gP:SQLSynced", "gP:TransferOldData", function()
	gProtect.transferOldSettings()

	verifyData()
end)

hook.Add("slib.FullLoaded", "gP:SyncToolgunSettings", function(ply)
	syncToolgunSettings(ply)
	syncEntOwnership(ply)
end)