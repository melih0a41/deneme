--[[
    ConVar Cache System
    Güvenli ve uyumlu ConVar cache sistemi
]]--

if CLIENT then return end

-- Güvenli modda bu modül yüklenmez
if ServerOptimizer and ServerOptimizer.SafeMode then
    print("[Server Optimizer] ConVar cache disabled in safe mode")
    return
end

local ConVarCache = {}
local CacheExpiry = {}
local oldGetConVar = GetConVar
local config = ServerOptimizer.Config
local cacheDisabled = false

-- Orijinal fonksiyonu güvenli sakla
if not debug.getregistry()._ServerOptimizer_OldGetConVar then
    debug.getregistry()._ServerOptimizer_OldGetConVar = oldGetConVar
end

-- Uyumsuz ConVar listesi (bunlar hiç cache'lenmez)
local blacklist = {
    -- ArcCW
    "arccw_", 
    -- TFA
    "tfa_",
    "sv_tfa_",
    -- CW 2.0
    "cw_",
    -- M9K
    "m9k_",
    -- Genel silah sistemleri
    "weapon_",
    "sv_weapon_",
    -- Kritik sunucu ayarları
    "sv_cheats",
    "sv_allowcslua",
    "sv_scriptenforcer",
    "sv_allowupload",
    "sv_allowdownload"
}

-- ConVar blacklist kontrolü
local function IsBlacklisted(name)
    if not name or type(name) ~= "string" then return true end
    
    -- Önek kontrolü
    for _, prefix in ipairs(blacklist) do
        if string.sub(name, 1, #prefix) == prefix then
            return true
        end
    end
    
    -- Whitelist kontrolü
    for _, whitelisted in ipairs(config.ConVarWhitelist) do
        if name == whitelisted then
            return true
        end
    end
    
    return false
end

-- Güvenli GetConVar override
function GetConVar(name)
    -- Güvenlik kontrolleri
    if cacheDisabled or not name or type(name) ~= "string" then
        return oldGetConVar(name)
    end
    
    -- Blacklist kontrolü
    if IsBlacklisted(name) then
        return oldGetConVar(name)
    end
    
    -- Cache kontrolü
    local time = CurTime()
    if ConVarCache[name] and CacheExpiry[name] and CacheExpiry[name] > time then
        -- Cache'deki ConVar hala geçerli mi kontrol et
        local cached = ConVarCache[name]
        if type(cached) == "ConVar" then
            return cached
        else
            -- Cache bozulmuş, temizle
            ConVarCache[name] = nil
            CacheExpiry[name] = nil
        end
    end
    
    -- Yeni ConVar al ve cache'e ekle
    local convar = oldGetConVar(name)
    if convar and type(convar) == "ConVar" then
        ConVarCache[name] = convar
        CacheExpiry[name] = time + config.ConVarCacheTime
    end
    
    return convar
end

-- ConVar değişikliklerini takip et
local function SetupChangeCallbacks()
    if not cvars then return end
    
    -- Önceki callback'i kaldır
    cvars.RemoveChangeCallback("*", "ServerOptimizer_ConVarChange")
    
    -- Yeni callback ekle
    cvars.AddChangeCallback("*", function(name, old, new)
        -- Cache'i temizle
        if ConVarCache[name] then
            ConVarCache[name] = nil
            CacheExpiry[name] = nil
        end
    end, "ServerOptimizer_ConVarChange")
end

-- Güvenli başlatma
timer.Simple(0, function()
    SetupChangeCallbacks()
end)

-- Periyodik cache temizliği
timer.Create("ServerOptimizer_ConVarCleanup", 60, 0, function()
    if cacheDisabled then
        timer.Remove("ServerOptimizer_ConVarCleanup")
        return
    end
    
    local time = CurTime()
    local cleaned = 0
    
    for name, expiry in pairs(CacheExpiry) do
        if not expiry or expiry < time then
            ConVarCache[name] = nil
            CacheExpiry[name] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 and config.DebugMode then
        print("[Server Optimizer] Cleaned " .. cleaned .. " expired ConVar entries")
    end
end)

-- Güvenlik: Uyumsuz addon algılandığında devre dışı bırak
hook.Add("Think", "ServerOptimizer_ConVarSafety", function()
    if cacheDisabled then return end
    
    if ServerOptimizer.HasArcCW or ServerOptimizer.SafeMode then
        cacheDisabled = true
        
        -- Orijinal GetConVar'a geri dön
        if debug.getregistry()._ServerOptimizer_OldGetConVar then
            _G.GetConVar = debug.getregistry()._ServerOptimizer_OldGetConVar
        else
            _G.GetConVar = oldGetConVar
        end
        
        -- Cache'i temizle
        ConVarCache = {}
        CacheExpiry = {}
        
        -- Timer'ı durdur
        timer.Remove("ServerOptimizer_ConVarCleanup")
        
        print("[Server Optimizer] ConVar cache disabled due to incompatible addon")
        
        -- Bu hook'u kaldır
        hook.Remove("Think", "ServerOptimizer_ConVarSafety")
    end
end)

-- Acil durum komutu
concommand.Add("sv_optimizer_restore_convar", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    cacheDisabled = true
    
    if debug.getregistry()._ServerOptimizer_OldGetConVar then
        _G.GetConVar = debug.getregistry()._ServerOptimizer_OldGetConVar
        print("[Server Optimizer] GetConVar restored to original")
    else
        print("[Server Optimizer] Original GetConVar not found!")
    end
    
    ConVarCache = {}
    CacheExpiry = {}
    timer.Remove("ServerOptimizer_ConVarCleanup")
end)

print("[Server Optimizer] ConVar cache system initialized (with safety features)")