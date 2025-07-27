--[[
    Entity Cache System
    Güvenli entity cache sistemi
]]--

if CLIENT then return end

-- Güvenli modda bu modül yüklenmez
if ServerOptimizer and ServerOptimizer.SafeMode then
    print("[Server Optimizer] Entity cache disabled in safe mode")
    return
end

-- Kritik fonksiyonların varlığını kontrol et
if not ents or not ents.FindInSphere then
    print("[Server Optimizer] ERROR: ents.FindInSphere not available - Aborting entity cache")
    return
end

local EntityCache = {}
local OwnerCache = {}
local CacheTime = ServerOptimizer.Config.EntityCacheTime
local cacheDisabled = false

-- Orijinal fonksiyonları sakla
local oldFindInSphere = ents.FindInSphere
local entmeta = FindMetaTable("Entity")
local oldGetOwner = entmeta.GetOwner

-- Meta table güvenlik kontrolü
if not entmeta or type(entmeta) ~= "table" then
    print("[Server Optimizer] ERROR: Entity meta table not found!")
    return
end

-- Fonksiyonların varlığını kontrol et
if not oldFindInSphere or type(oldFindInSphere) ~= "function" then
    print("[Server Optimizer] ERROR: ents.FindInSphere not found!")
    return
end

if not oldGetOwner or type(oldGetOwner) ~= "function" then
    print("[Server Optimizer] ERROR: Entity:GetOwner not found!")
    return
end

-- Entity tipine göre cache süreleri
local cacheTimeByType = {
    ["prop_physics"] = 2,
    ["prop_dynamic"] = 2,
    ["func_door"] = 5,
    ["func_door_rotating"] = 5,
    ["player"] = 0, -- Oyuncular cache'lenmez
    ["npc_"] = 0.5, -- NPC'ler kısa süre
    ["weapon_"] = 0.5, -- Silahlar kısa süre
}

-- Cache'lenebilir entity kontrolü
local function IsCacheable(ent)
    if not IsValid(ent) then return false end
    
    local class = ent:GetClass()
    
    -- Oyuncu ve NPC'ler cache'lenmez
    if ent:IsPlayer() or ent:IsNPC() then
        return false
    end
    
    -- Silahlar dikkatli cache'lenir
    if ent:IsWeapon() then
        -- ArcCW ve benzeri silahlar cache'lenmez
        if ent.ArcCW or ent.IsTFAWeapon or ent.CW20Weapon or ent.M9KWeapon then
            return false
        end
    end
    
    -- Hareket eden veya dinamik entity'ler
    if ent:GetVelocity():Length() > 10 then
        return false
    end
    
    return true
end

-- ents.FindInSphere optimizasyonu
function ents.FindInSphere(pos, radius)
    -- Parametre tip kontrolü
    if type(pos) ~= "Vector" then
        print("[Server Optimizer] WARNING: FindInSphere called with non-vector pos: " .. type(pos))
        return oldFindInSphere(pos, radius)
    end
    
    if type(radius) ~= "number" then
        print("[Server Optimizer] WARNING: FindInSphere called with non-number radius: " .. type(radius))
        return oldFindInSphere(pos, radius)
    end
    
    -- Güvenlik kontrolleri
    if cacheDisabled or not pos or not radius or radius <= 0 then
        return oldFindInSphere(pos, radius)
    end
    
    -- Büyük yarıçaplar cache'lenmez
    if radius > 2000 then
        return oldFindInSphere(pos, radius)
    end
    
    -- Cache key
    local key = string.format("%.0f_%.0f_%.0f_%d", pos.x, pos.y, pos.z, radius)
    local cached = EntityCache[key]
    
    -- Cache kontrolü
    if cached and cached.expiry > CurTime() then
        -- Geçerli entity'leri filtrele
        local valid = {}
        for _, ent in ipairs(cached.entities) do
            if IsValid(ent) then
                -- Entity hala aynı pozisyonda mı?
                local dist = ent:GetPos():Distance(pos)
                if dist <= radius then
                    table.insert(valid, ent)
                end
            end
        end
        
        -- Cache güvenilirlik kontrolü
        if #valid >= #cached.entities * 0.8 then -- %80'i hala geçerliyse
            return valid
        end
    end
    
    -- Yeni sonuç
    local result = oldFindInSphere(pos, radius)
    
    -- Sonuç tip kontrolü
    if type(result) ~= "table" then
        print("[Server Optimizer] WARNING: FindInSphere returned non-table: " .. type(result))
        return result or {}
    end
    
    -- Sadece cache'lenebilir entity'leri içeren sonuçları cache'le
    local cacheableCount = 0
    for _, ent in ipairs(result) do
        if IsCacheable(ent) then
            cacheableCount = cacheableCount + 1
        end
    end
    
    -- En az %50'si cache'lenebilirse cache'e ekle
    if cacheableCount >= #result * 0.5 then
        EntityCache[key] = {
            entities = result,
            expiry = CurTime() + CacheTime
        }
    end
    
    return result
end

-- Entity.GetOwner optimizasyonu
function entmeta:GetOwner()
    -- Tip kontrolü - boolean veya nil ise orijinal fonksiyonu çağır
    if type(self) ~= "Entity" and type(self) ~= "Weapon" and type(self) ~= "Player" then
        print("[Server Optimizer] WARNING: GetOwner called on " .. type(self))
        if type(oldGetOwner) == "function" then
            return oldGetOwner(self)
        end
        return NULL
    end
    
    -- Güvenlik kontrolleri
    if cacheDisabled or not IsValid(self) then
        return oldGetOwner(self)
    end
    
    -- Bazı entity'ler cache'lenmez
    if self:IsPlayer() or self:IsNPC() then
        return oldGetOwner(self)
    end
    
    -- ArcCW silahları cache'lenmez
    if self.ArcCW or self.IsTFAWeapon then
        return oldGetOwner(self)
    end
    
    -- Cache kontrolü
    local cached = OwnerCache[self]
    if cached and cached.time > CurTime() then
        -- Owner hala geçerli mi?
        if IsValid(cached.owner) or cached.owner == NULL then
            return cached.owner
        end
    end
    
    -- Yeni owner al
    local owner = oldGetOwner(self)
    
    -- Cache'e ekle
    OwnerCache[self] = {
        owner = owner,
        time = CurTime() + 1
    }
    
    return owner
end

-- Entity silindiğinde cache temizle
hook.Add("EntityRemoved", "ServerOptimizer_CacheCleanup", function(ent)
    if not IsValid(ent) then return end
    
    -- Owner cache'den kaldır
    OwnerCache[ent] = nil
    
    -- Entity cache'lerden kaldır
    for key, data in pairs(EntityCache) do
        if data and data.entities then
            for i = #data.entities, 1, -1 do
                if data.entities[i] == ent then
                    table.remove(data.entities, i)
                end
            end
        end
    end
end)

-- Periyodik temizlik
timer.Create("ServerOptimizer_EntityCache", 10, 0, function()
    if cacheDisabled then
        timer.Remove("ServerOptimizer_EntityCache")
        return
    end
    
    local time = CurTime()
    local cleaned = 0
    
    -- Entity cache temizliği
    for key, data in pairs(EntityCache) do
        if not data or data.expiry < time then
            EntityCache[key] = nil
            cleaned = cleaned + 1
        end
    end
    
    -- Owner cache temizliği
    for ent, data in pairs(OwnerCache) do
        if not IsValid(ent) or not data or data.time < time then
            OwnerCache[ent] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 and ServerOptimizer.Config.DebugMode then
        print("[Server Optimizer] Cleaned " .. cleaned .. " cache entries")
    end
end)

-- Güvenlik: Uyumsuz addon algılandığında devre dışı bırak
hook.Add("Think", "ServerOptimizer_EntityCacheSafety", function()
    if cacheDisabled then return end
    
    if ServerOptimizer.HasArcCW or ServerOptimizer.SafeMode then
        cacheDisabled = true
        
        -- Orijinal fonksiyonlara geri dön
        ents.FindInSphere = oldFindInSphere
        entmeta.GetOwner = oldGetOwner
        
        -- Cache'leri temizle
        EntityCache = {}
        OwnerCache = {}
        
        -- Timer'ı durdur
        timer.Remove("ServerOptimizer_EntityCache")
        
        print("[Server Optimizer] Entity cache disabled due to incompatible addon")
        
        -- Bu hook'u kaldır
        hook.Remove("Think", "ServerOptimizer_EntityCacheSafety")
    end
end)

print("[Server Optimizer] Entity cache system initialized (with safety features)")