/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if not SERVER then return end

zlm = zlm or {}
zlm.f = zlm.f or {}

-- Donmuş proplar için collision optimizasyonu
local function OptimizeFrozenProps()
    local optimized = 0
    
    for _, prop in ipairs(ents.FindByClass("prop_physics")) do
        if IsValid(prop) then
            local phys = prop:GetPhysicsObject()
            if IsValid(phys) and not phys:IsMotionEnabled() then
                -- Donmuş proplar için collision'ı optimize et
                prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
                optimized = optimized + 1
            end
        end
    end
    
    if optimized > 0 then
        print("[ZLM] Optimized " .. optimized .. " frozen props")
    end
end

-- Map yüklendiğinde ve cleanup'ta çalıştır
hook.Add("InitPostEntity", "zlm_OptimizeFrozenProps", OptimizeFrozenProps)
hook.Add("PostCleanupMap", "zlm_OptimizeFrozenProps", OptimizeFrozenProps)

-- Periyodik optimizasyon (5 dakikada bir)
timer.Create("zlm_PropOptimization", 300, 0, OptimizeFrozenProps)

-- Prop limit kontrolü
hook.Add("PlayerSpawnedProp", "zlm_PropLimitCheck", function(ply, model, ent)
    local props = 0
    for _, v in ipairs(ents.FindByClass("prop_physics")) do
        if IsValid(v) and v:CPPIGetOwner() == ply then
            props = props + 1
        end
    end
    
    -- Config'den prop limiti oku
    local limit = zlm.config.Performance.PropLimit or 75
    
    if props > limit then
        ent:Remove()
        zlm.f.Notify(ply, "Prop limit reached! (" .. limit .. ")", 1)
        return false
    end
end)