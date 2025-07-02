-- ezquadcopter/server/ghost_mode.lua - Yeni dosya oluşturun

-- Ghost Mode no-collide sistemi
hook.Add("ShouldCollide", "ezquadcopter_ghost_mode", function(ent1, ent2)
    -- İki entity'den biri drone mı kontrol et
    local isDrone1 = IsValid(ent1) and (ent1:GetClass() == "ez_quadcopter_dji" or ent1:GetClass() == "ez_quadcopter_fpv")
    local isDrone2 = IsValid(ent2) and (ent2:GetClass() == "ez_quadcopter_dji" or ent2:GetClass() == "ez_quadcopter_fpv")
    
    -- En az biri drone ise
    if isDrone1 or isDrone2 then
        local drone = isDrone1 and ent1 or ent2
        local other = isDrone1 and ent2 or ent1
        
        -- Ghost yükseltmesi aktif mi kontrol et
        if drone.upgrades and drone.upgrades["Ghost"] and drone.upgrades["Ghost"] > 0 then
            if IsValid(other) then
                local class = other:GetClass()
                
                -- No-collide listesi
                local noCollideClasses = {
                    -- Proplar
                    ["prop_physics"] = true,
                    ["prop_physics_multiplayer"] = true,
                    ["prop_dynamic"] = true,
                    ["prop_dynamic_override"] = true,
                    ["prop_ragdoll"] = true,
                    
                    -- Kırılabilir objeler ve camlar
                    ["func_breakable"] = true,
                    ["func_breakable_surf"] = true,
                    ["func_physbox"] = true,
                    ["func_physbox_multiplayer"] = true,
                    
                    -- Gmod objeler
                    ["gmod_wheel"] = true,
                    ["gmod_button"] = true,
                    ["gmod_turret"] = true,
                    ["gmod_cameraprop"] = true,
                    ["gmod_light"] = true,
                    ["gmod_lamp"] = true,
                    ["gmod_balloon"] = true
                }
                
                -- Class kontrolü
                if noCollideClasses[class] then
                    return false -- Çarpışma yok
                end
                
                -- String içeren kontroller
                local noCollidePatterns = {
                    "prop_",
                    "wire_",
                    "window",
                    "glass",
                    "func_brush",
                    "breakable"
                }
                
                for _, pattern in ipairs(noCollidePatterns) do
                    if string.find(class, pattern) then
                        return false -- Çarpışma yok
                    end
                end
                
                -- Material bazlı kontrol (cam yüzeyler için)
                if other.GetMaterial then
                    local material = other:GetMaterial()
                    if material then
                        local glassMaterials = {
                            "glass",
                            "window",
                            "metal/metalvent",
                            "metal/metalgrate"
                        }
                        
                        for _, mat in ipairs(glassMaterials) do
                            if string.find(material:lower(), mat) then
                                return false -- Çarpışma yok
                            end
                        end
                    end
                end
                
                -- Oyuncu propları
                if other.CPPIGetOwner and IsValid(other:CPPIGetOwner()) then
                    return false -- Çarpışma yok
                end
                
                -- Harita objeleri (duvar/zemin hariç)
                if other:CreatedByMap() then
                    if not (class == "worldspawn" or class == "func_wall") then
                        return false -- Çarpışma yok
                    end
                end
            end
        end
    end
    
    -- Diğer durumlar için normal çarpışma
end)

-- Ghost mode aktif olduğunda efekt
if SERVER then
    timer.Create("ezquadcopter_ghost_effect", 0.5, 0, function()
        for _, drone in ipairs(ents.FindByClass("ez_quadcopter_*")) do
            if IsValid(drone) and drone.upgrades and drone.upgrades["Ghost"] and drone.upgrades["Ghost"] > 0 then
                -- Ghost mode aktifse efekt gönder
                local effectdata = EffectData()
                effectdata:SetOrigin(drone:GetPos())
                effectdata:SetEntity(drone)
                effectdata:SetScale(0.5)
                util.Effect("entity_remove", effectdata, true, true)
            end
        end
    end)
end