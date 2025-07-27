--[[
    Optimized Animation System
    Güvenli mod desteği ile animasyon optimizasyonları
]]--

if CLIENT then return end

-- Güvenli modda bu modül yüklenmez
if ServerOptimizer and ServerOptimizer.SafeMode then
    print("[Server Optimizer] Animation optimizations disabled in safe mode")
    return
end

local plycache = {}
local config = ServerOptimizer.Config
local animationsDisabled = false

-- Meta fonksiyonları güvenli şekilde cache'le
local plymeta = FindMetaTable("Player")
local entmeta = FindMetaTable("Entity")

-- Fonksiyonları güvenli al
local function SafeGetFunction(meta, name)
    local func = meta[name]
    if type(func) == "function" then
        return func
    end
    return nil
end

local plyOnGround = SafeGetFunction(entmeta, "OnGround")
local plyAnimRestartMainSequence = SafeGetFunction(plymeta, "AnimRestartMainSequence")
local plyWaterLevel = SafeGetFunction(entmeta, "WaterLevel")
local plyGetMoveType = SafeGetFunction(entmeta, "GetMoveType")
local plyIsFlagSet = SafeGetFunction(entmeta, "IsFlagSet")
local plyInVehicle = SafeGetFunction(plymeta, "InVehicle")
local entLookupSequence = SafeGetFunction(entmeta, "LookupSequence")

-- Fonksiyon güvenlik kontrolü
local function CheckFunctions()
    return plyOnGround and plyAnimRestartMainSequence and plyWaterLevel and 
           plyGetMoveType and plyIsFlagSet and plyInVehicle and entLookupSequence
end

-- Oyuncu disconnectte cache temizle
hook.Add("PlayerDisconnected", "ServerOptimizer_AnimCleanup", function(ply)
    plycache[ply] = nil
end)

-- Weapon kontrolü
local function HasIncompatibleWeapon(ply)
    if not IsValid(ply) then return false end
    
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then
        -- ArcCW, TFA, CW2, M9K kontrolü
        if wep.ArcCW or wep.IsTFAWeapon or wep.CW20Weapon or wep.M9KWeapon then
            return true
        end
        
        -- Base kontrolü
        local base = wep.Base
        if base and (string.find(base, "arccw") or string.find(base, "tfa") or 
                     string.find(base, "cw_") or string.find(base, "m9k")) then
            return true
        end
    end
    
    return false
end

-- Animasyon override'ları InitPostEntity'de yapılacak
hook.Add("InitPostEntity", "ServerOptimizer_AnimationOverrides", function()
    -- Fonksiyon kontrolü
    if not CheckFunctions() then
        print("[Server Optimizer] Animation optimization aborted - Missing required functions")
        animationsDisabled = true
        return
    end
    
    timer.Simple(2, function()
        -- Uyumsuz addon kontrolü
        local incompatible = false
        for _, wep in pairs(weapons.GetList()) do
            if wep.ArcCW or wep.IsTFAWeapon or wep.CW20Weapon or wep.M9KWeapon or
               (wep.Base and (string.find(wep.Base or "", "arccw") or 
                             string.find(wep.Base or "", "tfa") or
                             string.find(wep.Base or "", "cw_") or
                             string.find(wep.Base or "", "m9k"))) then
                incompatible = true
                break
            end
        end
        
        if incompatible then
            print("[Server Optimizer] Weapon base detected - Animation optimizations disabled")
            animationsDisabled = true
            return
        end
        
        -- Optimizasyonları uygula
        ApplyAnimationOptimizations()
    end)
end)

-- Optimizasyonları uygula
function ApplyAnimationOptimizations()
    if animationsDisabled then return end
    
    local GAMEMODE = gmod.GetGamemode() or GM or GAMEMODE
    if not GAMEMODE then return end
    
    -- Orijinal fonksiyonları sakla
    local origHandlePlayerJumping = GAMEMODE.HandlePlayerJumping
    local origHandlePlayerDriving = GAMEMODE.HandlePlayerDriving
    local origHandlePlayerDucking = GAMEMODE.HandlePlayerDucking
    local origCalcMainActivity = GAMEMODE.CalcMainActivity
    
    -- Optimize edilmiş HandlePlayerJumping
    function GAMEMODE:HandlePlayerJumping(ply, velocity)
        -- Uyumsuz silah kontrolü
        if HasIncompatibleWeapon(ply) then
            if origHandlePlayerJumping then
                return origHandlePlayerJumping(self, ply, velocity)
            end
            return false
        end
        
        -- Fonksiyon kontrolü
        if not plyOnGround or not plyGetMoveType then
            if origHandlePlayerJumping then
                return origHandlePlayerJumping(self, ply, velocity)
            end
            return false
        end
        
        -- Cache kontrolü
        local cache = plycache[ply]
        if not cache then
            plycache[ply] = {}
            cache = plycache[ply]
        end
        
        -- Noclip kontrolü
        if plyGetMoveType(ply) == MOVETYPE_NOCLIP then
            cache.m_bJumping = false
            return false
        end
        
        -- Zıplama mantığı
        local onGround = plyOnGround(ply)
        local waterLevel = plyWaterLevel and plyWaterLevel(ply) or 0
        
        if not cache.m_bJumping and not onGround and waterLevel <= 0 then
            if not cache.m_fGroundTime then
                cache.m_fGroundTime = CurTime()
            elseif (CurTime() - cache.m_fGroundTime) > 0 and velocity:Length2DSqr() < 0.25 then
                cache.m_bJumping = true
                cache.m_bFirstJumpFrame = false
                cache.m_flJumpStartTime = 0
            end
        end
        
        if cache.m_bJumping then
            if cache.m_bFirstJumpFrame then
                cache.m_bFirstJumpFrame = false
                if plyAnimRestartMainSequence then
                    plyAnimRestartMainSequence(ply)
                end
            end
            
            if waterLevel >= 2 or ((CurTime() - cache.m_flJumpStartTime) > 0.2 and onGround) then
                cache.m_bJumping = false
                cache.m_fGroundTime = nil
                if plyAnimRestartMainSequence then
                    plyAnimRestartMainSequence(ply)
                end
            end
            
            if cache.m_bJumping then
                cache.CalcIdeal = ACT_MP_JUMP
                return true
            end
        end
        
        return false
    end
    
    -- Optimize edilmiş HandlePlayerDriving
    function GAMEMODE:HandlePlayerDriving(ply)
        -- Uyumsuz silah kontrolü
        if HasIncompatibleWeapon(ply) then
            if origHandlePlayerDriving then
                return origHandlePlayerDriving(self, ply)
            end
            return false
        end
        
        if not config.SimplifyDriving then
            if self.BaseClass and self.BaseClass.HandlePlayerDriving then
                return self.BaseClass.HandlePlayerDriving(self, ply)
            end
            return false
        end
        
        if not plyInVehicle or not plyInVehicle(ply) then return false end
        
        local cache = plycache[ply]
        if not cache then
            plycache[ply] = {}
            cache = plycache[ply]
        end
        
        -- Basitleştirilmiş araç animasyonu
        if entLookupSequence then
            cache.CalcSeqOverride = entLookupSequence(ply, "sit_rollercoaster")
        else
            cache.CalcSeqOverride = -1
        end
        
        return true
    end
    
    -- HandlePlayerDucking optimizasyonu
    function GAMEMODE:HandlePlayerDucking(ply, velocity)
        -- Uyumsuz silah kontrolü
        if HasIncompatibleWeapon(ply) then
            if origHandlePlayerDucking then
                return origHandlePlayerDucking(self, ply, velocity)
            end
            return false
        end
        
        if not plyIsFlagSet or not plyIsFlagSet(ply, FL_ANIMDUCKING) then 
            return false 
        end
        
        local cache = plycache[ply]
        if not cache then
            plycache[ply] = {}
            cache = plycache[ply]
        end
        
        -- Velocity kontrolü
        cache.CalcIdeal = velocity:Length2DSqr() > 0.25 and ACT_MP_CROUCHWALK or ACT_MP_CROUCH_IDLE
        return true
    end
    
    -- Kullanılmayan animasyonları kaldır (opsiyonel)
    if config.RemoveSwimming then
        function GAMEMODE:HandlePlayerSwimming() return false end
    end
    
    if config.RemoveNoclipAnim then
        function GAMEMODE:HandlePlayerNoClipping() return false end
    end
    
    -- Basitleştirilmiş CalcMainActivity
    function GAMEMODE:CalcMainActivity(ply, velocity)
        -- Uyumsuz silah kontrolü
        if HasIncompatibleWeapon(ply) then
            if origCalcMainActivity then
                return origCalcMainActivity(self, ply, velocity)
            end
            return ply.CalcIdeal or ACT_MP_STAND_IDLE, ply.CalcSeqOverride or -1
        end
        
        local cache = plycache[ply]
        if not cache then
            plycache[ply] = {
                CalcIdeal = ACT_MP_STAND_IDLE,
                CalcSeqOverride = -1
            }
            cache = plycache[ply]
        end
        
        cache.CalcIdeal = ACT_MP_STAND_IDLE
        cache.CalcSeqOverride = -1
        
        -- Optimized checks
        if not (self:HandlePlayerJumping(ply, velocity) or 
                self:HandlePlayerDucking(ply, velocity) or 
                self:HandlePlayerDriving(ply)) then
            
            local len2d = velocity:Length2DSqr()
            if len2d > 22500 then
                cache.CalcIdeal = ACT_MP_RUN
            elseif len2d > 0.25 then
                cache.CalcIdeal = ACT_MP_WALK
            end
        end
        
        return cache.CalcIdeal, cache.CalcSeqOverride
    end
    
    print("[Server Optimizer] Animation system optimized (with safety checks)")
end

-- Güvenlik kontrolü
hook.Add("Think", "ServerOptimizer_AnimSafety", function()
    if animationsDisabled then return end
    
    -- Yeni uyumsuz silah kontrolü
    if ServerOptimizer.HasArcCW and not animationsDisabled then
        animationsDisabled = true
        print("[Server Optimizer] Disabling animation optimizations due to weapon base detection")
        
        -- GAMEMODE fonksiyonlarını restore et
        local GAMEMODE = gmod.GetGamemode()
        if GAMEMODE and GAMEMODE.BaseClass then
            GAMEMODE.HandlePlayerJumping = GAMEMODE.BaseClass.HandlePlayerJumping
            GAMEMODE.HandlePlayerDriving = GAMEMODE.BaseClass.HandlePlayerDriving
            GAMEMODE.HandlePlayerDucking = GAMEMODE.BaseClass.HandlePlayerDucking
            GAMEMODE.CalcMainActivity = GAMEMODE.BaseClass.CalcMainActivity
        end
    end
end)