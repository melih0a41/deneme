--[[
    Server Optimizer - Ana başlatma dosyası
    Bu dosya tüm optimizasyon modüllerini yükler
]]--

if CLIENT then return end

ServerOptimizer = ServerOptimizer or {}
ServerOptimizer.StartTime = SysTime()

-- Config'i yükle
include("sh_optimizer_config.lua")
AddCSLuaFile("sh_optimizer_config.lua")

-- Modülleri yükle
local modules = {
    "sv_convar_cache.lua",
    "sv_animation_optimized.lua",
    "sv_darkrp_optimizations.lua",
    "sv_entity_cache.lua"
}

for _, module in ipairs(modules) do
    include("optimizer/" .. module)
    print("[Server Optimizer] Loaded module: " .. module)
end

-- DarkRP modüllerini devre dışı bırak
hook.Add("DarkRPPreLoadModules", "ServerOptimizer_DisableModules", function()
    if ServerOptimizer.Config.DisableFPP then
        DarkRP.disabledDefaults["modules"]["fpp"] = true
    end
    DarkRP.disabledDefaults["modules"]["events"] = true
end)

-- InitPostEntity'de son optimizasyonlar
hook.Add("InitPostEntity", "ServerOptimizer_Init", function()
    if ServerOptimizer.Config.DisableWidgets then
        hook.Remove("PlayerTick", "TickWidgets")
        if widgets then
            function widgets.PlayerTick() end
        end
    end
    
    if ServerOptimizer.Config.DisableUnusedHooks then
        -- Kullanılmayan hookları kaldır
        hook.Remove("SetupMove", "DarkRP_DoorRamJump")
        hook.Remove("SetupMove", "DarkRP_WeaponSpeed")
        hook.Remove("Move", "DruggedPlayer")
    end
    
    local loadTime = math.Round(SysTime() - ServerOptimizer.StartTime, 3)
    print("[Server Optimizer] All optimizations loaded in " .. loadTime .. " seconds")
end)