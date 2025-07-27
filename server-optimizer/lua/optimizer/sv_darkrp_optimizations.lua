--[[
    DarkRP Specific Optimizations
    DarkRP'ye özel güvenli performans iyileştirmeleri
]]--

if CLIENT then return end

local config = ServerOptimizer.Config

-- DarkRP var mı kontrol et
local function IsDarkRPLoaded()
    return DarkRP ~= nil and GAMEMODE and (GAMEMODE.Name == "DarkRP" or GAMEMODE.Base == "darkrp")
end

-- setDarkRPVar batch sistemi
if config.OptimizeSetDarkRPVar then
    hook.Add("InitPostEntity", "ServerOptimizer_DarkRPVarBatch", function()
        timer.Simple(1, function()
            if not IsDarkRPLoaded() then return end
            
            local varQueue = {}
            local nextProcess = 0
            
            local plymeta = FindMetaTable("Player")
            local oldSetDarkRPVar = plymeta.setDarkRPVar
            
            if not oldSetDarkRPVar then 
                print("[Server Optimizer] setDarkRPVar not found - Skipping optimization")
                return 
            end
            
            -- Kritik değişkenler listesi (bunlar hemen gönderilir)
            local critical = {
                money = true,
                job = true,
                wanted = true,
                HasGunlicense = true,
                hungerPercent = true,
                arrested = true,
                agenda = true,
                DarkRPVars = true
            }
            
            -- Güvenli setDarkRPVar override
            function plymeta:setDarkRPVar(name, value, target)
                if not IsValid(self) then return end
                
                -- Kritik değişkenler veya güvenli mod
                if critical[name] or ServerOptimizer.SafeMode then
                    return oldSetDarkRPVar(self, name, value, target)
                end
                
                -- Batch sistemi
                varQueue[self] = varQueue[self] or {}
                varQueue[self][name] = {value = value, target = target, time = CurTime()}
                
                -- Process queue
                if CurTime() >= nextProcess then
                    nextProcess = CurTime() + 0.1 -- 100ms batch window
                    
                    timer.Simple(0, function()
                        for ply, vars in pairs(varQueue) do
                            if IsValid(ply) then
                                for varname, data in pairs(vars) do
                                    -- 200ms'den eski değişkenler hemen gönder
                                    if CurTime() - data.time > 0.2 then
                                        oldSetDarkRPVar(ply, varname, data.value, data.target)
                                    end
                                end
                            else
                                varQueue[ply] = nil
                            end
                        end
                        
                        -- Temizle
                        varQueue = {}
                    end)
                end
            end
            
            -- Oyuncu disconnect'te queue temizle
            hook.Add("PlayerDisconnected", "ServerOptimizer_VarQueueCleanup", function(ply)
                varQueue[ply] = nil
            end)
            
            print("[Server Optimizer] DarkRP setDarkRPVar optimization applied")
        end)
    end)
end

-- Hungermod optimizasyonu
if config.OptimizeHungerMod then
    hook.Add("loadCustomDarkRPItems", "ServerOptimizer_HungerMod", function()
        if not IsDarkRPLoaded() then return end
        
        if GAMEMODE.Config and GAMEMODE.Config.hungerspeed then
            local oldSpeed = GAMEMODE.Config.hungerspeed
            -- Minimum 5 saniye, maksimum 30 saniye
            GAMEMODE.Config.hungerspeed = math.Clamp(oldSpeed, 5, 30)
            
            if GAMEMODE.Config.hungerspeed ~= oldSpeed then
                print("[Server Optimizer] Adjusted hunger speed from " .. oldSpeed .. " to " .. GAMEMODE.Config.hungerspeed)
            end
        end
    end)
end

-- Gereksiz think hookları optimize et
hook.Add("InitPostEntity", "ServerOptimizer_CleanupThink", function()
    if not IsDarkRPLoaded() then return end
    
    timer.Simple(5, function() -- DarkRP tamamen yüklendikten sonra
        -- Arrest stick think optimizasyonu
        if _G.ArrestStickThink then
            local oldThink = _G.ArrestStickThink
            local nextThink = 0
            
            _G.ArrestStickThink = function(...)
                if CurTime() < nextThink then return end
                nextThink = CurTime() + 0.1 -- 100ms throttle
                return oldThink(...)
            end
            
            print("[Server Optimizer] ArrestStick think optimized")
        end
        
        -- Door ram think optimizasyonu
        if _G.DoorRamThink then
            local oldThink = _G.DoorRamThink
            local nextThink = 0
            
            _G.DoorRamThink = function(...)
                if CurTime() < nextThink then return end
                nextThink = CurTime() + 0.05 -- 50ms throttle
                return oldThink(...)
            end
            
            print("[Server Optimizer] DoorRam think optimized")
        end
    end)
end)

-- FPP optimizasyonu (sadece normal modda)
if config.DisableFPP and not ServerOptimizer.SafeMode then
    hook.Add("InitPostEntity", "ServerOptimizer_FPPOptimization", function()
        if not IsDarkRPLoaded() then return end
        
        timer.Simple(2, function()
            if FPP and FPP.Settings then
                -- Bazı FPP kontrolleri devre dışı bırak
                FPP.Settings = FPP.Settings or {}
                FPP.Settings.FPP_TOOLGUN = FPP.Settings.FPP_TOOLGUN or {}
                FPP.Settings.FPP_TOOLGUN.worldprops = 0 -- Dünya propları kontrolü kapat
                
                print("[Server Optimizer] FPP optimizations applied")
            end
        end)
    end)
end

-- DarkRP ağ trafiği optimizasyonu
hook.Add("InitPostEntity", "ServerOptimizer_NetworkOptimization", function()
    if not IsDarkRPLoaded() then return end
    
    timer.Simple(3, function()
        -- updateJob network optimizasyonu
        if GAMEMODE.updateJob then
            local oldUpdateJob = GAMEMODE.updateJob
            local lastUpdate = {}
            
            function GAMEMODE:updateJob(ply)
                if not IsValid(ply) then return end
                
                -- Son güncelleme kontrolü (500ms throttle)
                local steamid = ply:SteamID()
                if lastUpdate[steamid] and CurTime() - lastUpdate[steamid] < 0.5 then
                    return
                end
                
                lastUpdate[steamid] = CurTime()
                return oldUpdateJob(self, ply)
            end
            
            -- Oyuncu disconnect'te temizle
            hook.Add("PlayerDisconnected", "ServerOptimizer_UpdateJobCleanup", function(ply)
                lastUpdate[ply:SteamID()] = nil
            end)
            
            print("[Server Optimizer] DarkRP network optimizations applied")
        end
    end)
end)

print("[Server Optimizer] DarkRP optimizations loaded")