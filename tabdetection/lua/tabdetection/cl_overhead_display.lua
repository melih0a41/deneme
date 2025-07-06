-- Client-side Overhead Display System
-- Bu dosyayı: garrysmod/lua/tabdetection/cl_overhead_display.lua olarak kaydedin

-- Renkler ve ayarlar
local COLOR_AFK_DARK = Color(139, 0, 0, 255) -- Koyu kırmızı
local COLOR_AFK_BRIGHT = Color(255, 0, 0, 255) -- Parlak kırmızı
local COLOR_GLOW = Color(255, 100, 100, 100) -- Parlama efekti
local COLOR_SHADOW = Color(0, 0, 0, 255)
local COLOR_BACKGROUND = Color(20, 20, 20, 230)

-- Modern fontlar
surface.CreateFont("TabDetection_AFKFont_Modern", {
    font = "Roboto Bold", -- Fallback: Arial Black, Impact
    size = 36,
    weight = 900,
    antialias = true,
    extended = true
})

surface.CreateFont("TabDetection_AFKFont_Glow", {
    font = "Roboto Bold",
    size = 38,
    weight = 900,
    antialias = true,
    blursize = 8
})

-- 3D2D ayarları
local SCALE = 0.15
local HEIGHT_OFFSET = 20 -- Oyuncunun kafasından yukarıda

-- AFK yazısını oyuncuların üzerinde göster
hook.Add("PostDrawTranslucentRenderables", "TabDetection.DrawAFKLabels", function()
    local localPly = LocalPlayer()
    if not IsValid(localPly) then return end
    
    -- Tüm oyuncuları kontrol et
    for ply, isAFK in pairs(TabDetection.PlayerStates) do
        if IsValid(ply) and ply ~= localPly and isAFK then
            -- Görünmez veya noclip durumunu kontrol et
            if ply:GetNoDraw() then continue end -- Görünmezse gösterme
            if ply:GetRenderMode() == RENDERMODE_NONE then continue end -- Render modu none ise gösterme
            if ply:GetColor().a < 10 then continue end -- Çok saydamsa gösterme
            if ply:GetMoveType() == MOVETYPE_NOCLIP then continue end -- Noclip modundaysa gösterme
            
            -- SAM görünmezlik kontrolü
            if ply:GetNWBool("sam_cloak", false) then continue end
            if ply:GetNWBool("sam_god", false) and ply:GetColor().a < 255 then continue end
            
            -- ULX görünmezlik kontrolü (eğer ULX da yüklüyse)
            if ply.invisible and ply.invisible == true then continue end
            
            -- FAdmin görünmezlik kontrolü (eğer DarkRP kullanıyorsanız)
            if ply:GetNWBool("FAdmin_cloaked", false) then continue end
            
            -- Mesafe kontrolü
            if ply:GetPos():DistToSqr(localPly:GetPos()) > 1000000 then continue end
            
            -- Oyuncunun pozisyonu
            local pos = ply:GetPos()
            local eyePos = ply:EyePos()
            local drawPos = Vector(pos.x, pos.y, eyePos.z + HEIGHT_OFFSET)
            
            -- Kameraya bak
            local ang = (localPly:EyePos() - drawPos):Angle()
            ang:RotateAroundAxis(ang:Up(), 90)
            ang:RotateAroundAxis(ang:Forward(), 90)
            
            -- 3D2D çizim
            cam.Start3D2D(drawPos, ang, SCALE)
                -- Pulse efekti hesapla
                local pulse = (math.sin(CurTime() * 5) + 1) * 0.5 -- 0-1 arası hızlı pulse
                local glowIntensity = 20 + (pulse * 30) -- 20-50 arası glow
                
                -- Modern arka plan (yuvarlatılmış köşeler efekti)
                -- Gölge
                surface.SetDrawColor(0, 0, 0, 100)
                surface.DrawRect(-47, -17, 94, 34)
                
                -- Ana arka plan
                surface.SetDrawColor(COLOR_BACKGROUND)
                surface.DrawRect(-45, -15, 90, 30)
                
                -- Kırmızı vurgu çizgisi (üstte)
                surface.SetDrawColor(COLOR_AFK_BRIGHT.r, COLOR_AFK_BRIGHT.g, COLOR_AFK_BRIGHT.b, 255 * pulse)
                surface.DrawRect(-45, -15, 90, 2)
                
                -- Parlama efekti (glow) - Birden fazla katman
                for i = 1, 3 do
                    local alpha = glowIntensity / i
                    draw.SimpleText(
                        "AFK",
                        "TabDetection_AFKFont_Glow",
                        0, 0,
                        Color(255, 0, 0, alpha),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER
                    )
                end
                
                -- Ana AFK yazısı (gradient efekti simülasyonu)
                local afkColor = Color(
                    COLOR_AFK_DARK.r + (COLOR_AFK_BRIGHT.r - COLOR_AFK_DARK.r) * pulse,
                    COLOR_AFK_DARK.g + (COLOR_AFK_BRIGHT.g - COLOR_AFK_DARK.g) * pulse,
                    COLOR_AFK_DARK.b + (COLOR_AFK_BRIGHT.b - COLOR_AFK_DARK.b) * pulse,
                    255
                )
                
                -- Siyah gölge
                draw.SimpleText(
                    "AFK",
                    "TabDetection_AFKFont_Modern",
                    2, 2,
                    Color(0, 0, 0, 200),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                
                -- Ana yazı
                draw.SimpleText(
                    "AFK",
                    "TabDetection_AFKFont_Modern",
                    0, 0,
                    afkColor,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                
                -- Modern animasyonlu indikator (yatay çizgiler)
                local indicatorAlpha = 100 + (pulse * 155)
                surface.SetDrawColor(255, 0, 0, indicatorAlpha)
                
                -- Sol indikator
                surface.DrawRect(-42, -2, 8, 2)
                -- Sağ indikator  
                surface.DrawRect(34, -2, 8, 2)
                
            cam.End3D2D()
        end
    end
end)