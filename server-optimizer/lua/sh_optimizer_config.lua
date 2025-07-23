--[[
    Server Optimizer Configuration
    Sunucu performans ayarları
]]--

ServerOptimizer = ServerOptimizer or {}
ServerOptimizer.Config = {
    -- ConVar Cache Ayarları
    ConVarCacheTime = 5, -- Saniye cinsinden cache süresi
    ConVarWhitelist = { -- Bu convarlar cache'lenmez (sürekli değişenler)
        "sv_gravity",
        "sv_airaccelerate",
    },
    
    -- Animasyon Optimizasyon Ayarları
    RemoveSwimming = true, -- Yüzme animasyonlarını kaldır
    RemoveNoclipAnim = true, -- Noclip animasyonlarını kaldır
    SimplifyDriving = true, -- Araç animasyonlarını basitleştir
    
    -- Entity Cache Ayarları
    EntityCacheTime = 0.5, -- Entity cache yenileme süresi
    
    -- DarkRP Optimizasyonları
    OptimizeSetDarkRPVar = true, -- setDarkRPVar batch sistemi
    OptimizeHungerMod = true, -- Hungermod optimizasyonu
    DisableFPP = true, -- FPP'yi tamamen kapat
    
    -- Genel Performans
    DisableWidgets = true, -- Widget sistemini kapat
    DisableUnusedHooks = true, -- Kullanılmayan hookları kaldır
}

print("[Server Optimizer] Config loaded")