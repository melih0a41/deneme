--[[
    Entity Cache System
    Entity bulma işlemlerini optimize eder
]]--

if CLIENT then return end

local EntityCache = {}
local CacheTime = ServerOptimizer.Config.EntityCacheTime

-- ents.FindInSphere optimizasyonu
local oldFindInSphere = ents.FindInSphere
function ents.FindInSphere(pos, radius)
    -- Cache key oluştur
    local key = tostring(pos) .. "_" .. radius
    local cached = EntityCache[key]
    
    if cached and cached.expiry > CurTime() then
        -- Cache'den geçerli entityleri döndür
        local valid = {}
        for _, ent in ipairs(cached.entities) do
            if IsValid(ent) then
                table.insert(valid, ent)
            end
        end
        return valid
    end
    
    -- Yeni sonuç
    local result = oldFindInSphere(pos, radius)
    
    -- Cache'e ekle
    EntityCache[key] = {
        entities = result,
        expiry = CurTime() + CacheTime
    }
    
    return result
end

-- Cache temizliği
timer.Create("ServerOptimizer_EntityCache", 10, 0, function()
    local time = CurTime()
    local cleaned = 0
    
    for key, data in pairs(EntityCache) do
        if data.expiry < time then
            EntityCache[key] = nil
            cleaned = cleaned + 1
        end
    end
end)

-- Entity.GetOwner optimizasyonu
local ownerCache = {}
local entmeta = FindMetaTable("Entity")
local oldGetOwner = entmeta.GetOwner

function entmeta:GetOwner()
    local cached = ownerCache[self]
    if cached and cached.time > CurTime() then
        return cached.owner
    end
    
    local owner = oldGetOwner(self)
    ownerCache[self] = {
        owner = owner,
        time = CurTime() + 1 -- 1 saniye cache
    }
    
    return owner
end

-- Entity silindiğinde cache temizle
hook.Add("EntityRemoved", "ServerOptimizer_OwnerCache", function(ent)
    ownerCache[ent] = nil
end)

print("[Server Optimizer] Entity cache system initialized")