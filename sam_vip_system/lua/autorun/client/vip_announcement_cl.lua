-- VIP Duyuru Sistemi - Client (Çoklu VIP Desteği)

-- Özel fontları oluştur
surface.CreateFont("VIPTitleFont", {
    font = "Arial",
    extended = false,
    size = 52,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont("VIPTextFont", {
    font = "Arial", 
    extended = false,
    size = 36,
    weight = 600,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont("VIPStarFont", {
    font = "Arial",
    extended = true,
    size = 40,
    weight = 800,
    blursize = 0,
    scanlines = 0,
    antialias = true,
})

net.Receive("SAM.VIPAnnouncement", function()
    local vipname = net.ReadString()
    local viptype = net.ReadString() -- VIP türü
    local vipcolor = net.ReadColor() -- VIP rengi
    local endTime = CurTime() + 8 -- Panel ekranda 8 saniye kalsın
    
    -- İsmi kısalt eğer çok uzunsa
    if string.len(vipname) > 20 then
        vipname = string.sub(vipname, 1, 18) .. ".."
    end
    
    -- Flaşör efekti için değişkenler
    local flashCount = 0
    local flashTime = CurTime()
    local flashDuration = 0.3 -- Her flaş süresi
    local maxFlashes = 3 -- Toplam flaş sayısı
    
    -- Yıldız efektleri - VIP türüne göre renk
    local stars = {}
    for i = 1, 40 do
        table.insert(stars, {
            x = math.random(0, ScrW()),
            y = math.random(-ScrH(), 0),
            speed = math.random(30, 100),
            size = math.random(8, 20),
            alpha = math.random(150, 255)
        })
    end
    
    hook.Add("HUDPaint", "DrawVIPAnnouncement", function()
        local w, h = ScrW(), ScrH()
        local panelHeight = 150
        local alpha = math.Clamp((endTime - CurTime()) * 255, 0, 255)
        
        -- Arkaplan panel
        draw.RoundedBox(0, 0, 0, w, panelHeight, Color(0, 0, 0, 200 * (alpha / 255)))
        
        -- Flaşör efekti (VIP renginde)
        if flashCount < maxFlashes * 2 and CurTime() - flashTime > flashDuration then
            flashTime = CurTime()
            flashCount = flashCount + 1
        end
        
        -- Flaş arka plan efekti
        if flashCount < maxFlashes * 2 and flashCount % 2 == 1 then
            local flashAlpha = math.sin((CurTime() - flashTime) * math.pi / flashDuration) * 60
            draw.RoundedBox(0, 0, 0, w, panelHeight, Color(vipcolor.r, vipcolor.g, vipcolor.b, flashAlpha * (alpha / 255)))
        end
        
        -- DUYURU başlığı (köşeli parantez yok)
        local titleText = "DUYURU"
        local titleY = 35
        
        -- Sadece ince gölge
        draw.SimpleText(titleText, "VIPTitleFont", w/2 + 2, titleY + 2, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
        
        -- Ana başlık - VIP renginde
        draw.SimpleText(titleText, "VIPTitleFont", w/2, titleY, Color(vipcolor.r, vipcolor.g, vipcolor.b, alpha), TEXT_ALIGN_CENTER)
        
        -- Alt metin - VIP türü kısmı renkli
        local bottomY = 90
        
        -- Metni parçalara ayır
        local text1 = vipname .. " "
        local text2 = viptype -- Bu kısım renkli olacak
        local text3 = " alarak bizlere destek oldu!"
        
        -- Text genişliklerini hesapla
        surface.SetFont("VIPTextFont")
        local text1Width = surface.GetTextSize(text1)
        local text2Width = surface.GetTextSize(text2)
        local text3Width = surface.GetTextSize(text3)
        local totalWidth = text1Width + text2Width + text3Width
        
        -- Başlangıç pozisyonu
        local startX = w/2 - totalWidth/2
        
        -- Gölge efekti (tüm metin için)
        local fullText = text1 .. text2 .. text3
        draw.SimpleText(fullText, "VIPTextFont", w/2 + 2, bottomY + 2, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
        
        -- İlk kısım (beyaz)
        draw.SimpleText(text1, "VIPTextFont", startX, bottomY, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT)
        
        -- VIP türü kısmı (VIP renginde)
        draw.SimpleText(text2, "VIPTextFont", startX + text1Width, bottomY, Color(vipcolor.r, vipcolor.g, vipcolor.b, alpha), TEXT_ALIGN_LEFT)
        
        -- Son kısım (beyaz)
        draw.SimpleText(text3, "VIPTextFont", startX + text1Width + text2Width, bottomY, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT)
        
        -- Hareket eden yıldız efektleri - VIP türüne göre renk
        for _, star in ipairs(stars) do
            -- Yıldızlara hafif gölge
            draw.SimpleText("*", "VIPStarFont", star.x + 1, star.y + 1, Color(0, 0, 0, star.alpha * (alpha / 255) * 0.5), TEXT_ALIGN_CENTER)
            -- Ana yıldız
            draw.SimpleText("*", "VIPStarFont", star.x, star.y, Color(vipcolor.r, vipcolor.g, vipcolor.b, star.alpha * (alpha / 255)), TEXT_ALIGN_CENTER)
            
            star.y = star.y + FrameTime() * star.speed
            if star.y > h then
                star.y = math.random(-h, 0)
                star.x = math.random(0, w)
            end
        end
        
        -- Süre bitince hook kaldır
        if CurTime() >= endTime then
            hook.Remove("HUDPaint", "DrawVIPAnnouncement")
        end
    end)
    
    -- Kutlama sesleri - VIP türüne göre farklı sesler
    if viptype == "Diamond VIP" then
        -- Diamond için özel ses kombinasyonu
        surface.PlaySound("garrysmod/save_load1.wav")
        timer.Simple(0.1, function()
            surface.PlaySound("buttons/button9.wav")
        end)
        timer.Simple(0.3, function()
            surface.PlaySound("ambient/levels/canals/windchime2.wav")
        end)
        timer.Simple(0.5, function()
            surface.PlaySound("ambient/alarms/warningbell1.wav")
        end)
    elseif viptype == "Platinum VIP" then
        -- Platinum için
        surface.PlaySound("garrysmod/save_load1.wav")
        timer.Simple(0.2, function()
            surface.PlaySound("ambient/levels/canals/windchime2.wav")
        end)
        timer.Simple(0.4, function()
            surface.PlaySound("buttons/button9.wav")
        end)
    elseif viptype == "Gold VIP" then
        -- Gold için
        surface.PlaySound("garrysmod/save_load1.wav")
        timer.Simple(0.2, function()
            surface.PlaySound("buttons/button9.wav")
        end)
    else
        -- Bronze ve Silver için standart ses
        surface.PlaySound("garrysmod/save_load1.wav")
    end
    
    -- Chat mesajı da ekle - VIP türüne göre renkli
    chat.AddText(
        vipcolor, "[" .. viptype .. "] ", 
        Color(255, 255, 255), vipname .. " adlı oyuncu ", 
        vipcolor, viptype, 
        Color(255, 255, 255), " satın aldı! Tebrikler!"
    )
end)