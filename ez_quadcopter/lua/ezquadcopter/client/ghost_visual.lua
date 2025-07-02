-- ezquadcopter/client/ghost_visual.lua - Yeni dosya oluşturun

-- Ghost mode görsel efektleri
hook.Add("PreDrawTranslucentRenderables", "ezquadcopter_ghost_visual", function()
    for _, drone in ipairs(ents.FindByClass("ez_quadcopter_*")) do
        if IsValid(drone) and drone.upgrades and drone.upgrades["Ghost"] and drone.upgrades["Ghost"] > 0 then
            -- Ghost efekti - yarı saydam
            render.SetBlend(0.7)
            
            -- Mavi glow efekti
            render.SetColorModulation(0.5, 0.8, 1)
            
            -- Outline efekti
            outline.Add(drone, Color(100, 200, 255, 100), OUTLINE_MODE_ALWAYS)
        end
    end
end)

-- Ghost mode HUD göstergesi
hook.Add("HUDPaint", "ezquadcopter_ghost_hud", function()
    local ply = LocalPlayer()
    local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
    
    if IsValid(quadcopter) and quadcopter.on and quadcopter.upgrades and quadcopter.upgrades["Ghost"] and quadcopter.upgrades["Ghost"] > 0 then
        -- Ghost mode aktif göstergesi
        local x = ScrW() - 200
        local y = 150
        
        -- Yanıp sönen efekt
        local alpha = 150 + math.sin(CurTime() * 3) * 50
        
        -- Arka plan
        draw.RoundedBox(8, x - 5, y - 5, 160, 40, Color(0, 0, 0, 150))
        
        -- İkon
        surface.SetDrawColor(100, 200, 255, alpha)
        surface.SetMaterial(Material("icon16/eye.png"))
        surface.DrawTexturedRect(x, y, 32, 32)
        
        -- Yazı
        draw.SimpleText("GHOST MODE", "DermaDefault", x + 40, y + 16, Color(100, 200, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Dalga efekti
        for i = 1, 2 do
            local waveAlpha = math.max(0, alpha - i * 80)
            local waveSize = 32 + i * 12
            
            surface.SetDrawColor(100, 200, 255, waveAlpha)
            surface.DrawOutlinedRect(x - (waveSize-32)/2, y - (waveSize-32)/2, waveSize, waveSize, 2)
        end
    end
end)

-- Drone render hook'u
hook.Add("PostDrawOpaqueRenderables", "ezquadcopter_ghost_render", function()
    for _, drone in ipairs(ents.FindByClass("ez_quadcopter_*")) do
        if IsValid(drone) and drone.upgrades and drone.upgrades["Ghost"] and drone.upgrades["Ghost"] > 0 then
            -- Hologram efekti
            local pos = drone:GetPos()
            local ang = drone:GetAngles()
            
            -- Dönen halka efekti
            local time = CurTime() * 2
            cam.Start3D2D(pos, Angle(0, time * 30 % 360, 0), 0.5)
                surface.SetDrawColor(100, 200, 255, 30)
                draw.NoTexture()
                
                local segments = 32
                local radius = 100
                for i = 0, segments do
                    local angle1 = (i / segments) * math.pi * 2
                    local angle2 = ((i + 1) / segments) * math.pi * 2
                    
                    surface.DrawLine(
                        math.cos(angle1) * radius,
                        math.sin(angle1) * radius,
                        math.cos(angle2) * radius,
                        math.sin(angle2) * radius
                    )
                end
            cam.End3D2D()
        end
    end
end)