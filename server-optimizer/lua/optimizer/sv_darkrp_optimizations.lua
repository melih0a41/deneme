--[[
    DarkRP Specific Optimizations
    DarkRP'ye özel performans iyileştirmeleri
]]--

if CLIENT then return end

local config = ServerOptimizer.Config

-- setDarkRPVar batch sistemi
if config.OptimizeSetDarkRPVar then
    local varQueue = {}
    local nextProcess = 0
    
    local oldSetDarkRPVar = FindMetaTable("Player").setDarkRPVar
    
    if oldSetDarkRPVar then
        local plymeta = FindMetaTable("Player")
        
        function plymeta:setDarkRPVar(name, value, target)
            -- Kritik değişkenler hemen gönderilir
            local critical = {money = true, job = true, wanted = true}
            
            if critical[name] then
                return oldSetDarkRPVar(self, name, value, target)
            end
            
            -- Diğerleri queue'ya eklenir
            varQueue[self] = varQueue[self] or {}
            varQueue[self][name] = {value = value, target = target}
            
            -- Process queue
            if CurTime() >= nextProcess then
                nextProcess = CurTime() + 0.1 -- 100ms batch window
                
                for ply, vars in pairs(varQueue) do
                    if IsValid(ply) then
                        for varname, data in pairs(vars) do
                            oldSetDarkRPVar(ply, varname, data.value, data.target)
                        end
                    end
                end
                
                varQueue = {}
            end
        end
    end
end

-- Hungermod optimizasyonu
if config.OptimizeHungerMod then
    hook.Add("loadCustomDarkRPItems", "ServerOptimizer_HungerMod", function()
        if GAMEMODE.Config.hungerspeed then
            -- Hunger timer'ı optimize et
            local oldHungerSpeed = GAMEMODE.Config.hungerspeed
            GAMEMODE.Config.hungerspeed = math.max(oldHungerSpeed, 5) -- Minimum 5 saniye
        end
    end)
end

-- Gereksiz think hookları temizle
hook.Add("InitPostEntity", "ServerOptimizer_CleanupThink", function()
    timer.Simple(5, function() -- DarkRP yüklendikten sonra
        -- Arrest stick think optimizasyonu
        local oldThink = _G.ArrestStickThink
        if oldThink then
            local nextThink = 0
            _G.ArrestStickThink = function(...)
                if CurTime() < nextThink then return end
                nextThink = CurTime() + 0.1 -- 100ms throttle
                return oldThink(...)
            end
        end
    end)
end)

print("[Server Optimizer] DarkRP optimizations loaded")