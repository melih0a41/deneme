-- VIP Duyuru Sistemi - Client

-- Özel fontları oluştur
surface.CreateFont("VIPTitleFont", {
    font = "Arial",
    extended = false,
    size = 48,
    weight = 800,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = true,
})

surface.CreateFont("VIPTextFont", {
    font = "Arial", 
    extended = false,
    size = 32,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = true,
})

surface.CreateFont("VIPStarFont", {
    font = "Arial",
    extended = true,
    size = 36,
    weight = 800,
    blursize = 0,
    scanlines = 0,
    antialias = true,
})

net.Receive("SAM.VIPAnnouncement", function()
    local vipname = net.ReadString()
    local endTime = CurTime() + 8 -- Panel ekranda 8 saniye kalsın

    -- Yıldız efektleri
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
        local panelHeight = 140
        local alpha = math.Clamp((endTime - CurTime()) * 255, 0, 255)

        -- Arkaplan panel
        draw.RoundedBox(0, 0, 0, w, panelHeight, Color(0, 0, 0, 200 * (alpha / 255)))

        -- VIP Yazıları - Gölgeli ve outline'lı
        -- Önce gölge çiz
        draw.SimpleText("*** TEBRIKLER ***", "VIPTitleFont", w / 2 + 2, 32, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
        draw.SimpleText("*** TEBRIKLER ***", "VIPTitleFont", w / 2, 30, Color(255, 215, 0, alpha), TEXT_ALIGN_CENTER)
        
        -- Alt metin gölgeli
        draw.SimpleText(vipname .. " VIP alarak bizlere destek oldu!", "VIPTextFont", w / 2 + 2, 82, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
        draw.SimpleText(vipname .. " VIP alarak bizlere destek oldu!", "VIPTextFont", w / 2, 80, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)

        -- Hareket eden yıldız efektleri
        for _, star in ipairs(stars) do
            draw.SimpleText("*", "VIPStarFont", star.x, star.y, Color(255, 215, 0, star.alpha * (alpha / 255)), TEXT_ALIGN_CENTER)
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

    -- Kutlama sesleri - Birden fazla ses çal
    surface.PlaySound("garrysmod/save_load1.wav") -- Ana ses
    
    -- Ekstra ses efektleri
    timer.Simple(0.2, function()
        surface.PlaySound("buttons/button9.wav") -- Tıklama sesi
    end)
    
    timer.Simple(0.4, function()
        surface.PlaySound("ambient/levels/canals/windchime2.wav") -- Parlama sesi
    end)
    
    -- Alternatif ses kombinasyonları (birini seçin):
    -- surface.PlaySound("friends/friend_online.wav") -- Steam arkadaş çevrimiçi sesi
    -- surface.PlaySound("ui/achievement_earned.wav") -- Başarı sesi
    -- surface.PlaySound("ambient/alarms/warningbell1.wav") -- Çan sesi
    -- surface.PlaySound("npc/scanner/scanner_photo1.wav") -- Fotoğraf sesi
    -- surface.PlaySound("weapons/physcannon/energy_bounce1.wav") -- Enerji sesi
    
    -- Chat mesajı da ekle
    chat.AddText(Color(255, 215, 0), "[VIP] ", Color(255, 255, 255), vipname .. " adlı oyuncu VIP satın aldı! Tebrikler!")
end)