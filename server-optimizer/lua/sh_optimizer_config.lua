--[[
    Server Optimizer Configuration
    Güvenli ve uyumlu sunucu performans ayarları
]]--

ServerOptimizer = ServerOptimizer or {}
ServerOptimizer.Config = {
    -- ConVar Cache Ayarları
    ConVarCacheTime = 5, -- Saniye cinsinden cache süresi
    ConVarWhitelist = { -- Bu convarlar hiç cache'lenmez
        "sv_gravity",
        "sv_airaccelerate",
        "sv_maxvelocity",
        "sv_sticktoground",
        "sv_rollangle",
        "sv_rollspeed",
        -- Oyuncu ConVar'ları
        "cl_interp",
        "cl_interp_ratio",
        "cl_updaterate",
        "cl_cmdrate",
        "rate",
        -- Performans kritik
        "fps_max",
        "mat_queue_mode",
        "gmod_physiterations",
    },
    
    -- Animasyon Optimizasyon Ayarları
    RemoveSwimming = false, -- Yüzme animasyonlarını kaldır (güvenlik için kapalı)
    RemoveNoclipAnim = false, -- Noclip animasyonlarını kaldır (güvenlik için kapalı)
    SimplifyDriving = false, -- Araç animasyonlarını basitleştir (güvenlik için kapalı)
    
    -- Entity Cache Ayarları
    EntityCacheTime = 0.5, -- Entity cache yenileme süresi (saniye)
    
    -- DarkRP Optimizasyonları
    OptimizeSetDarkRPVar = true, -- setDarkRPVar batch sistemi
    OptimizeHungerMod = true, -- Hungermod optimizasyonu
    DisableFPP = false, -- FPP'yi kapat (güvenlik için kapalı)
    
    -- Genel Performans
    DisableWidgets = false, -- Widget sistemini kapat (güvenlik için kapalı)
    DisableUnusedHooks = false, -- Kullanılmayan hookları kaldır (güvenlik için kapalı)
    
    -- Güvenlik Ayarları
    ProtectFunctions = true, -- Kritik fonksiyonları koru
    AutoDetectIncompatible = true, -- Uyumsuz addonları otomatik algıla
    DebugMode = false, -- Debug mesajları göster
    
    -- Performans Limitleri
    MaxCacheSize = 1000, -- Maksimum cache girişi sayısı
    MaxCacheMemory = 10, -- MB cinsinden maksimum cache bellek kullanımı
}

-- Güvenli mod ayarları
ServerOptimizer.SafeModeConfig = {
    ConVarCacheTime = 0, -- Cache'leme yok
    RemoveSwimming = false,
    RemoveNoclipAnim = false,
    SimplifyDriving = false,
    EntityCacheTime = 0, -- Cache'leme yok
    OptimizeSetDarkRPVar = true, -- DarkRP optimizasyonları genelde güvenli
    OptimizeHungerMod = true,
    DisableFPP = false,
    DisableWidgets = false,
    DisableUnusedHooks = false,
}

-- Dinamik config ayarlama
function ServerOptimizer.ApplySafeMode()
    if not ServerOptimizer.SafeMode then return end
    
    print("[Server Optimizer] Applying safe mode configuration")
    
    -- Güvenli mod ayarlarını uygula
    for key, value in pairs(ServerOptimizer.SafeModeConfig) do
        ServerOptimizer.Config[key] = value
    end
end

-- Config doğrulama
function ServerOptimizer.ValidateConfig()
    local config = ServerOptimizer.Config
    
    -- Sayısal değerleri doğrula
    config.ConVarCacheTime = math.max(0, tonumber(config.ConVarCacheTime) or 5)
    config.EntityCacheTime = math.max(0, tonumber(config.EntityCacheTime) or 0.5)
    config.MaxCacheSize = math.max(100, tonumber(config.MaxCacheSize) or 1000)
    config.MaxCacheMemory = math.max(1, tonumber(config.MaxCacheMemory) or 10)
    
    -- Boolean değerleri doğrula
    local booleans = {
        "RemoveSwimming", "RemoveNoclipAnim", "SimplifyDriving",
        "OptimizeSetDarkRPVar", "OptimizeHungerMod", "DisableFPP",
        "DisableWidgets", "DisableUnusedHooks", "ProtectFunctions",
        "AutoDetectIncompatible", "DebugMode"
    }
    
    for _, key in ipairs(booleans) do
        if type(config[key]) ~= "boolean" then
            config[key] = false
        end
    end
    
    -- Whitelist'in tablo olduğundan emin ol
    if type(config.ConVarWhitelist) ~= "table" then
        config.ConVarWhitelist = {}
    end
end

-- Console komutları
concommand.Add("sv_optimizer_reload_config", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    -- Config'i yeniden yükle
    if file.Exists("optimizer/sh_optimizer_config.lua", "LUA") then
        include("optimizer/sh_optimizer_config.lua")
        ServerOptimizer.ValidateConfig()
        
        if ServerOptimizer.SafeMode then
            ServerOptimizer.ApplySafeMode()
        end
        
        print("[Server Optimizer] Configuration reloaded")
    else
        print("[Server Optimizer] Config file not found!")
    end
end)

concommand.Add("sv_optimizer_toggle_debug", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    ServerOptimizer.Config.DebugMode = not ServerOptimizer.Config.DebugMode
    print("[Server Optimizer] Debug mode: " .. tostring(ServerOptimizer.Config.DebugMode))
end)

-- Config'i doğrula
ServerOptimizer.ValidateConfig()

-- Güvenli mod kontrolü
if ServerOptimizer.SafeMode then
    ServerOptimizer.ApplySafeMode()
end

print("[Server Optimizer] Configuration loaded" .. (ServerOptimizer.SafeMode and " (SAFE MODE)" or ""))