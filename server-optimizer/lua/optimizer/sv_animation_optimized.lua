--[[
    Optimized Animation System
    HandlePlayerJumping ve diğer animasyon fonksiyonlarını optimize eder
]]--

if CLIENT then return end

local plycache = {}
local config = ServerOptimizer.Config

-- Meta fonksiyonları cache'le
local plymeta = FindMetaTable("Player")
local entmeta = FindMetaTable("Entity")
local plyOnGround = entmeta.OnGround
local plyAnimRestartMainSequence = plymeta.AnimRestartMainSequence
local plyWaterLevel = entmeta.WaterLevel
local plyGetMoveType = entmeta.GetMoveType
local plyIsFlagSet = entmeta.IsFlagSet
local plyInVehicle = plymeta.InVehicle
local entLookupSequence = entmeta.LookupSequence

-- Oyuncu disconnectte cache temizle
hook.Add("PlayerDisconnected", "ServerOptimizer_AnimCleanup", function(ply)
    plycache[ply] = nil
end)

-- Animasyon override'ları InitPostEntity'de yapılacak
hook.Add("InitPostEntity", "ServerOptimizer_AnimationOverrides", function()
    local GAMEMODE = gmod.GetGamemode() or GM or GAMEMODE
    if not GAMEMODE then return end
    
    -- Optimize edilmiş HandlePlayerJumping
    function GAMEMODE:HandlePlayerJumping(ply, velocity)
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
        
        -- Zıplama mantığı (optimize edilmiş)
        local onGround = plyOnGround(ply)
        local waterLevel = plyWaterLevel(ply)
        
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
                plyAnimRestartMainSequence(ply)
            end
            
            if waterLevel >= 2 or ((CurTime() - cache.m_flJumpStartTime) > 0.2 and onGround) then
                cache.m_bJumping = false
                cache.m_fGroundTime = nil
                plyAnimRestartMainSequence(ply)
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
        if not config.SimplifyDriving then
            if self.BaseClass and self.BaseClass.HandlePlayerDriving then
                return self.BaseClass.HandlePlayerDriving(self, ply)
            end
            return false
        end
        
        if not plyInVehicle(ply) then return false end
        
        local cache = plycache[ply]
        if not cache then
            plycache[ply] = {}
            cache = plycache[ply]
        end
        
        -- Basitleştirilmiş araç animasyonu
        cache.CalcSeqOverride = entLookupSequence(ply, "sit_rollercoaster")
        return true
    end
    
    -- HandlePlayerDucking optimizasyonu
    function GAMEMODE:HandlePlayerDucking(ply, velocity)
        if not plyIsFlagSet(ply, FL_ANIMDUCKING) then return false end
        
        local cache = plycache[ply]
        if not cache then
            plycache[ply] = {}
            cache = plycache[ply]
        end
        
        -- Velocity kontrolünü optimize et
        cache.CalcIdeal = velocity:Length2DSqr() > 0.25 and ACT_MP_CROUCHWALK or ACT_MP_CROUCH_IDLE
        return true
    end
    
    -- Kullanılmayan animasyon fonksiyonlarını devre dışı bırak
    if config.RemoveSwimming then
        function GAMEMODE:HandlePlayerSwimming() return false end
    end
    
    if config.RemoveNoclipAnim then
        function GAMEMODE:HandlePlayerNoClipping() return false end
    end
    
    -- Basitleştirilmiş CalcMainActivity
    function GAMEMODE:CalcMainActivity(ply, velocity)
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
    
    print("[Server Optimizer] Animation system optimized")
end)