gProtect = gProtect or {}
gProtect.EmptyFuncs = gProtect.EmptyFuncs or {}
CPPI = CPPI or {}

local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")



-- Create empty functions to prevent nil errors.
if !ENTITY.CPPIGetOwner then
    function ENTITY:CPPIGetOwner() end
    gProtect.EmptyFuncs["CPPIGetOwner"] = ENTITY.CPPIGetOwner
end

if !ENTITY.CPPISetOwner then
    function ENTITY:CPPISetOwner() end
end

local function overrideCPPI()
    ENTITY.oldCPPIGetOwner = ENTITY.oldCPPIGetOwner or (ENTITY.CPPIGetOwner != gProtect.EmptyFuncs["CPPIGetOwner"] and ENTITY.CPPIGetOwner)
    function ENTITY:CPPIGetOwner()
        local result = gProtect.GetOwner(self)
        
        if isstring(result) and isfunction(ENTITY.oldCPPIGetOwner) then result = self:oldCPPIGetOwner() end

        return SERVER and gProtect.ownershipCache[self] or (isstring(result) and nil or result), 200
    end

    function PLAYER:CPPIGetFriends()
        local friends_tbl = CLIENT and gProtect.BuddiesData or gProtect.TouchPermission
        local sid = self:SteamID()
        local found_friends = {}
        local result = {}

        if friends_tbl[sid] then
            for k, v in pairs(friends_tbl[sid]) do
                if !istable(v) then continue end
                for sid, v in pairs(v) do
                    found_friends[sid] = true
                end
            end
        end

        for k, v in pairs(found_friends) do
            table.insert(result, k)
        end
        
        return result
    end

    if SERVER then
        ENTITY.oldCPPISetOwner = ENTITY.oldCPPISetOwner or ENTITY.CPPISetOwner
        function ENTITY:CPPISetOwner(ply)
            if isfunction(ENTITY.oldCPPISetOwner) then
                self:oldCPPISetOwner(ply)
            end

            if !IsValid(ply) then return end
            gProtect.SetOwner(ply, self)
        end

        function ENTITY:CPPICanTool(ply, tool)            
            return gProtect.HandlePermissions(ply, self, "gmod_tool")
        end
    
        function ENTITY:CPPICanPhysgun(ply)
            if SERVER and !gProtect.HandlePhysgunPermission(ply, self) then return false end

            return gProtect.HandlePermissions(ply, self, "weapon_physgun")
        end
    
        function ENTITY:CPPICanPickup(ply)
            return gProtect.HandlePermissions(ply, self, "weapon_physcannon")
        end
    
        function ENTITY:CPPICanPunt(ply)
            if cfg.enabled and (cfg.DisableGravityGunPunting or (IsValid(ent) and cfg.blockedEntities[ent:GetClass()])) then return false end

            return true
        end
    end
end

timer.Simple(3, function()
    overrideCPPI()
end)