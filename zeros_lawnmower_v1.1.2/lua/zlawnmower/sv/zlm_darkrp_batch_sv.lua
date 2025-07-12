/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if not SERVER then return end
if not DarkRP then return end

zlm = zlm or {}
zlm.f = zlm.f or {}

-- DarkRP setDarkRPVar Batch Sistemi
local darkrpBatchQueue = {}
local darkrpBatchTimer = 0

-- Original setDarkRPVar'ı sakla
local originalSetDarkRPVar = nil

-- Hook ile override et
hook.Add("DarkRPFinishedLoading", "zlm_DarkRPBatchSystem", function()
    if not originalSetDarkRPVar then
        local meta = FindMetaTable("Entity")
        if meta and meta.setDarkRPVar then
            originalSetDarkRPVar = meta.setDarkRPVar
            
            -- Override function
            meta.setDarkRPVar = function(self, var, value, target)
                -- ZLM entity'leri için batch kullan
                if IsValid(self) and string.find(self:GetClass(), "zlm_") then
                    table.insert(darkrpBatchQueue, {
                        ent = self,
                        var = var,
                        value = value,
                        target = target
                    })
                    
                    -- Batch timer başlat
                    if darkrpBatchTimer == 0 then
                        darkrpBatchTimer = CurTime() + 0.1
                    end
                else
                    -- Diğer entity'ler için normal kullan
                    originalSetDarkRPVar(self, var, value, target)
                end
            end
        end
    end
end)

-- Batch işleyici
timer.Create("zlm_DarkRPBatch", 0.1, 0, function()
    if #darkrpBatchQueue > 0 and CurTime() >= darkrpBatchTimer then
        -- Tüm batch'i işle
        for _, data in ipairs(darkrpBatchQueue) do
            if IsValid(data.ent) and originalSetDarkRPVar then
                originalSetDarkRPVar(data.ent, data.var, data.value, data.target)
            end
        end
        
        -- Queue'yu temizle
        table.Empty(darkrpBatchQueue)
        darkrpBatchTimer = 0
    end
end)