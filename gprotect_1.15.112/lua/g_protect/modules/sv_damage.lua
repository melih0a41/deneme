local cfg = gProtect.getConfig(nil, "damage")
local blacklist = gProtect.getConfig("blacklist", "general")

local function doDamageCheck(ent, victim, falldamage)
    if ent and ent ~= NULL then
        local classname = ent:GetClass()
        if victim:IsPlayer() then
            if ((cfg.useBlacklist and blacklist[classname]) or cfg.entities[classname]) and cfg.blacklistedEntPlayerDamage then return false end
            if ent:IsWorld() and cfg.worldPlayerDamage and !falldamage then return false end
            if ent:IsVehicle() and cfg.vehiclePlayerDamage then return false end
        end
    end
end

hook.Add("EntityTakeDamage", "gP:HandleDamage", function(victim, dmginfo)
    if cfg.enabled then
        local attacker = dmginfo:GetAttacker()
        local inflictor = dmginfo:GetInflictor()
        local falldamage = dmginfo:IsFallDamage()
        local victimclass = victim:GetClass()
        local victimowner = gProtect.GetOwner(victim)

        if !victimowner then
            local result = gProtect.GetOwnerString(victim)
            victimowner = string.sub(result, 1, 5) == "STEAM" and "Disconnected" or "World"
        end

        local attackerusergroup = IsValid(attacker) and attacker:IsPlayer() and attacker:GetUserGroup() or ""
         
        local canDamageWorldEntitiesCheck, immortalEntCheck

        if cfg.immortalEntities[victimclass] and (!cfg.bypassGroups[attackerusergroup] and !cfg.bypassGroups["*"] ) then immortalEntCheck = false end
        if !victim:IsPlayer() and (victimowner == "World") and (!cfg.canDamageWorldEntities[attackerusergroup] and !cfg.canDamageWorldEntities["*"]) then canDamageWorldEntitiesCheck = false end

        local result = gProtect.returnStatements(true, false, doDamageCheck(inflictor, victim, falldamage), doDamageCheck(attacker, victim, falldamage), immortalEntCheck, canDamageWorldEntitiesCheck)
        if isbool(result) and !result then return true end
    end
end)

hook.Add("gP:ConfigUpdated", "gP:UpdateDamageModule", function(updated)
    if updated ~= "damage" and updated ~= "general" then return end
    cfg = gProtect.getConfig(nil, "damage")
    blacklist = gProtect.getConfig("blacklist","general")
end)