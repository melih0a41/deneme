--[[
    ConVar Cache System
    GetConVar çağrılarını cache'leyerek CPU kullanımını azaltır
]]--

if CLIENT then return end

local ConVarCache = {}
local CacheExpiry = {}
local oldGetConVar = GetConVar
local config = ServerOptimizer.Config

-- GetConVar override
function GetConVar(name)
    -- Whitelist kontrolü
    for _, whitelisted in ipairs(config.ConVarWhitelist) do
        if name == whitelisted then
            return oldGetConVar(name)
        end
    end
    
    -- Cache kontrolü
    local time = CurTime()
    if ConVarCache[name] and CacheExpiry[name] > time then
        return ConVarCache[name]
    end
    
    -- Cache'e ekle
    local convar = oldGetConVar(name)
    if convar then
        ConVarCache[name] = convar
        CacheExpiry[name] = time + config.ConVarCacheTime
    end
    
    return convar
end

-- ConVar değişikliklerini takip et
if cvars then
    cvars.AddChangeCallback("*", function(name, old, new)
        -- Cache'i temizle
        ConVarCache[name] = nil
        CacheExpiry[name] = 0
    end, "ServerOptimizer_ConVarChange")
end

-- Periyodik cache temizliği (memory leak önleme)
timer.Create("ServerOptimizer_ConVarCleanup", 60, 0, function()
    local time = CurTime()
    local cleaned = 0
    
    for name, expiry in pairs(CacheExpiry) do
        if expiry < time then
            ConVarCache[name] = nil
            CacheExpiry[name] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        print("[Server Optimizer] Cleaned " .. cleaned .. " expired ConVar entries")
    end
end)

print("[Server Optimizer] ConVar cache system initialized")