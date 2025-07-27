--[[
    Server Optimizer - Ana başlatma dosyası
    ArcCW ve diğer modern addonlarla tam uyumlu versiyon
]]--

if CLIENT then return end

ServerOptimizer = ServerOptimizer or {}
ServerOptimizer.StartTime = SysTime()
ServerOptimizer.HasArcCW = false
ServerOptimizer.SafeMode = false

-- Uyumluluk listesi
ServerOptimizer.IncompatibleAddons = {
    ["arccw_base"] = true,
    ["tfa_base"] = true,
    ["cw_2.0"] = true,
    ["m9k_base"] = true
}

-- Kritik fonksiyonları yedekle
ServerOptimizer.OriginalFunctions = {}

local function BackupCriticalFunctions()
    local plymeta = FindMetaTable("Player")
    local entmeta = FindMetaTable("Entity")
    
    ServerOptimizer.OriginalFunctions.GetInfo = plymeta.GetInfo
    ServerOptimizer.OriginalFunctions.GetInfoNum = plymeta.GetInfoNum
    ServerOptimizer.OriginalFunctions.GetConVar = GetConVar
    ServerOptimizer.OriginalFunctions.FindInSphere = ents.FindInSphere
    ServerOptimizer.OriginalFunctions.GetOwner = entmeta.GetOwner
    
    print("[Server Optimizer] Critical functions backed up")
end

-- Addon uyumluluk kontrolü
local function CheckIncompatibleAddons()
    -- Silah base kontrolü
    for addonName, _ in pairs(ServerOptimizer.IncompatibleAddons) do
        if weapons.Get(addonName) then
            ServerOptimizer.SafeMode = true
            print("[Server Optimizer] Incompatible addon detected: " .. addonName .. " - Entering safe mode")
            return true
        end
    end
    
    -- ArcCW özel kontrolü
    for _, wep in pairs(weapons.GetList()) do
        if wep.ArcCW or (wep.Base and string.find(wep.Base or "", "arccw")) then
            ServerOptimizer.HasArcCW = true
            ServerOptimizer.SafeMode = true
            print("[Server Optimizer] ArcCW detected - Entering compatibility mode")
            return true
        end
    end
    
    -- ConVar kontrolü
    if ConVarExists("arccw_enable_customization") or ConVarExists("tfa_ballistics_enabled") then
        ServerOptimizer.SafeMode = true
        print("[Server Optimizer] Weapon base ConVars detected - Entering safe mode")
        return true
    end
    
    return false
end

-- Fonksiyonları koru
BackupCriticalFunctions()

-- Erken uyumluluk kontrolü
hook.Add("Initialize", "ServerOptimizer_CompatCheck", function()
    CheckIncompatibleAddons()
end)

-- Config'i yükle
include("sh_optimizer_config.lua")
AddCSLuaFile("sh_optimizer_config.lua")

-- Güvenli mod kontrolü
if ServerOptimizer.SafeMode then
    print("[Server Optimizer] Running in SAFE MODE - Limited optimizations active")
    
    -- Sadece güvenli modülleri yükle
    local safeModules = {
        "sv_darkrp_optimizations.lua" -- DarkRP optimizasyonları genelde güvenli
    }
    
    for _, module in ipairs(safeModules) do
        include("optimizer/" .. module)
        print("[Server Optimizer] Loaded safe module: " .. module)
    end
else
    -- Normal modülleri yükle ama güvenlik önlemleriyle
    print("[Server Optimizer] Running in NORMAL MODE")
    
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
end

-- Fonksiyon koruma sistemi
local function ProtectCriticalFunctions()
    if not ServerOptimizer.Config.ProtectFunctions then return end
    
    local plymeta = FindMetaTable("Player")
    
    -- GetInfoNum her zaman olmalı
    if not plymeta.GetInfoNum then
        plymeta.GetInfoNum = ServerOptimizer.OriginalFunctions.GetInfoNum or function(self, name, default)
            if not IsValid(self) then return default or 0 end
            local val = self:GetInfo(name)
            return tonumber(val) or default or 0
        end
        print("[Server Optimizer] Restored missing GetInfoNum")
    end
    
    -- GetInfo her zaman olmalı
    if not plymeta.GetInfo then
        plymeta.GetInfo = ServerOptimizer.OriginalFunctions.GetInfo or function(self, name)
            if not IsValid(self) then return "" end
            return ""
        end
        print("[Server Optimizer] Restored missing GetInfo")
    end
end

-- DarkRP modüllerini kontrol et
hook.Add("DarkRPPreLoadModules", "ServerOptimizer_DisableModules", function()
    if ServerOptimizer.Config.DisableFPP and not ServerOptimizer.SafeMode then
        DarkRP.disabledDefaults["modules"]["fpp"] = true
    end
    if not ServerOptimizer.SafeMode then
        DarkRP.disabledDefaults["modules"]["events"] = true
    end
end)

-- InitPostEntity'de son kontroller
hook.Add("InitPostEntity", "ServerOptimizer_Init", function()
    -- Geç uyumluluk kontrolü
    timer.Simple(1, function()
        if not ServerOptimizer.SafeMode and CheckIncompatibleAddons() then
            print("[Server Optimizer] WARNING: Late incompatible addon detection!")
            print("[Server Optimizer] Some optimizations may cause issues - Restart recommended")
            
            -- Acil güvenlik önlemleri
            if ServerOptimizer.OriginalFunctions.GetConVar then
                _G.GetConVar = ServerOptimizer.OriginalFunctions.GetConVar
            end
            
            -- Kritik fonksiyonları koru
            ProtectCriticalFunctions()
        end
    end)
    
    -- Periyodik fonksiyon koruması
    if ServerOptimizer.Config.ProtectFunctions then
        timer.Create("ServerOptimizer_FunctionProtection", 5, 0, function()
            ProtectCriticalFunctions()
        end)
    end
    
    -- Widget ve hook optimizasyonları (sadece güvenli modda değilse)
    if not ServerOptimizer.SafeMode then
        if ServerOptimizer.Config.DisableWidgets then
            hook.Remove("PlayerTick", "TickWidgets")
            if widgets then
                function widgets.PlayerTick() end
            end
        end
        
        if ServerOptimizer.Config.DisableUnusedHooks then
            hook.Remove("SetupMove", "DarkRP_DoorRamJump")
            hook.Remove("SetupMove", "DarkRP_WeaponSpeed")
            hook.Remove("Move", "DruggedPlayer")
        end
    end
    
    local loadTime = math.Round(SysTime() - ServerOptimizer.StartTime, 3)
    local mode = ServerOptimizer.SafeMode and " (SAFE MODE)" or " (NORMAL MODE)"
    print("[Server Optimizer] Initialization completed in " .. loadTime .. " seconds" .. mode)
end)

-- Silah spawn kontrolü
hook.Add("OnEntityCreated", "ServerOptimizer_WeaponCheck", function(ent)
    if not IsValid(ent) or not ent:IsWeapon() then return end
    
    timer.Simple(0.1, function()
        if IsValid(ent) and ent.ArcCW and not ServerOptimizer.HasArcCW then
            ServerOptimizer.HasArcCW = true
            ServerOptimizer.SafeMode = true
            print("[Server Optimizer] WARNING: ArcCW weapon spawned - Compatibility issues may occur")
            print("[Server Optimizer] Restart the server for full safe mode")
            
            -- Kritik fonksiyonları koru
            ProtectCriticalFunctions()
        end
    end)
end)

-- Durum komutları
concommand.Add("sv_optimizer_status", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    local status = ServerOptimizer.SafeMode and "SAFE MODE" or "NORMAL MODE"
    print("=== Server Optimizer Status ===")
    print("Mode: " .. status)
    print("ArcCW Detected: " .. tostring(ServerOptimizer.HasArcCW))
    print("Protected Functions: " .. tostring(ServerOptimizer.Config.ProtectFunctions))
    print("Active Modules:")
    
    local modules = {
        ConVarCache = not ServerOptimizer.SafeMode,
        AnimationOptimizations = not ServerOptimizer.SafeMode,
        EntityCache = not ServerOptimizer.SafeMode,
        DarkRPOptimizations = true
    }
    
    for name, active in pairs(modules) do
        print("  - " .. name .. ": " .. (active and "ACTIVE" or "DISABLED"))
    end
    print("==============================")
end)

print("[Server Optimizer] Initialization complete")