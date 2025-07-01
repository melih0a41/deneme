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
        local panelHeight = 120
        local alpha = math.Clamp((endTime - CurTime()) * 255, 0, 255)

        -- Arkaplan panel
        draw.RoundedBox(0, 0, 0, w, panelHeight, Color(0, 0, 0, 200 * (alpha / 255)))

        -- VIP Yazısı
        draw.SimpleText("🌟 TEBRİKLER 🌟", "DermaLarge", w / 2, 20, Color(255, 215, 0, alpha), TEXT_ALIGN_CENTER)
        draw.SimpleText(vipname .. " VIP alarak bizlere destek oldu!", "DermaLarge", w / 2, 65, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)

        -- Hareket eden yıldız efektleri
        for _, star in ipairs(stars) do
            draw.SimpleText("★", "DermaLarge", star.x, star.y, Color(255, 215, 0, star.alpha * (alpha / 255)), TEXT_ALIGN_CENTER)
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

    -- Kutlama sesi
    surface.PlaySound("garrysmod/content_downloaded.wav")
end)
