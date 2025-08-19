-- lua/autorun/client/cl_aphone_twitter_notify.lua
-- Sadece bildirim sistemi ve toggle fonksiyonları

-- BİLDİRİM AYARI CONVAR
local twitter_notif_enabled = CreateClientConVar("aphone_twitter_notif", "1", true, false, "Twitter bildirimlerini aç/kapat")

-- Bildirim sistemi değişkenleri
local notifications = {}
local notif_height = 90
local notif_height_with_img = 275
local notif_width = 450
local notif_margin = 10
local notif_duration = 8

-- Renk tanımlamaları
local twitter_blue = Color(29, 161, 242)
local white = Color(255, 255, 255)
local shadow = Color(0, 0, 0, 150)

-- Twitter logosu
local twitter_logo = Material("akulla/aphone/app_twitter.png", "smooth")

-- Logo çizme fonksiyonu
local function DrawTwitterLogo(x, y, size, alpha)
    if not twitter_logo:IsError() then
        surface.SetDrawColor(ColorAlpha(white, alpha))
        surface.SetMaterial(twitter_logo)
        surface.DrawTexturedRect(x, y, size, size)
    else
        -- Logo yüklenemedi, basit şekil çiz
        draw.RoundedBox(4, x, y, size, size, ColorAlpha(twitter_blue, alpha))
        draw.SimpleText("T", "DefaultSmall", x + size/2, y + size/2, ColorAlpha(white, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Font oluştur
surface.CreateFont("TwitterNotifTitle", {
    font = "Roboto",
    size = 22,
    weight = 700
})

surface.CreateFont("TwitterNotifText", {
    font = "Roboto", 
    size = 20,
    weight = 400
})

-- Bildirim ekle fonksiyonu
local function AddNotification(handle, text, hasImg, imgUrl)
    -- BİLDİRİMLER KAPALIYSA ÇIKIS
    if not twitter_notif_enabled:GetBool() then
        print("[Twitter] Bildirimler kapalı, bildirim gösterilmiyor: " .. handle)
        return
    end
    
    local customWidth = hasImg and 260 or notif_width
    
    local notif = {
        handle = handle,
        text = text,
        hasImg = hasImg,
        imgUrl = imgUrl,
        startTime = CurTime(),
        alpha = 0,
        x = ScrW() + 10,
        targetX = ScrW() - customWidth - notif_margin,
        height = hasImg and notif_height_with_img or notif_height,
        width = customWidth
    }
    
    -- Mevcut bildirimleri yukarı kaydır
    local totalHeight = notif_margin
    for i = #notifications, 1, -1 do
        local n = notifications[i]
        totalHeight = totalHeight + n.height + notif_margin
        n.targetY = ScrH() - totalHeight
        n.targetX = ScrW() - (n.width or notif_width) - notif_margin
    end
    
    notif.y = ScrH() - notif_margin - notif.height
    notif.targetY = notif.y
    
    table.insert(notifications, 1, notif)
    
    -- Ses çal
    surface.PlaySound("ambient/water/drip1.wav")
    print("[Twitter] Bildirim eklendi: " .. handle .. " - " .. text)
end

-- Server'dan bildirim al
net.Receive("aphone_tweet_notify", function()
    local handle = net.ReadString()
    local text = net.ReadString()
    local hasImg = net.ReadBool()
    local imgUrl = hasImg and net.ReadString() or nil
    
    -- Tweet metnini kısalt
    local shortText = string.len(text) > 90 and string.sub(text, 1, 87) .. "..." or text
    
    -- Bildirim ekle
    AddNotification(handle, shortText, hasImg, imgUrl)
end)

-- Bildirimleri çiz
hook.Add("HUDPaint", "TwitterNotifications", function()
    for i = #notifications, 1, -1 do
        local notif = notifications[i]
        local elapsed = CurTime() - notif.startTime
        
        -- Bildirim süresi kontrolü
        if elapsed > notif_duration then
            notif.alpha = math.max(0, notif.alpha - FrameTime() * 500)
            notif.x = notif.x + FrameTime() * 300
            
            if notif.alpha <= 0 then
                table.remove(notifications, i)
                
                -- Diğer bildirimleri yeniden konumlandır
                local totalHeight = notif_margin
                for j = #notifications, 1, -1 do
                    local n = notifications[j]
                    totalHeight = totalHeight + n.height + notif_margin
                    n.targetY = ScrH() - totalHeight
                    n.targetX = ScrW() - (n.width or notif_width) - notif_margin
                end
            end
        else
            -- Fade in
            if elapsed < 0.3 then
                notif.alpha = math.min(255, notif.alpha + FrameTime() * 850)
            else
                notif.alpha = 255
            end
        end
        
        -- Smooth animasyon
        notif.x = Lerp(FrameTime() * 8, notif.x, notif.targetX)
        notif.y = Lerp(FrameTime() * 8, notif.y, notif.targetY)
        
        -- Gölge
        draw.RoundedBox(12, notif.x + 2, notif.y + 2, notif.width or notif_width, notif.height, ColorAlpha(shadow, notif.alpha * 0.7))
        
        -- Ana arka plan
        draw.RoundedBox(12, notif.x, notif.y, notif.width or notif_width, notif.height, ColorAlpha(twitter_blue, notif.alpha))
        
        -- Sol beyaz şerit
        draw.RoundedBoxEx(12, notif.x, notif.y, 5, notif.height, ColorAlpha(white, notif.alpha), true, false, true, false)
        
        -- Logo ve başlık
        if notif.hasImg then
            DrawTwitterLogo(notif.x + 20, notif.y + 10, 22, notif.alpha)
            draw.SimpleText(notif.handle, "DefaultSmall", notif.x + 47, notif.y + 12, ColorAlpha(white, notif.alpha))
        else
            DrawTwitterLogo(notif.x + 15, notif.y + 12, 32, notif.alpha)
            draw.SimpleText(notif.handle, "TwitterNotifTitle", notif.x + 55, notif.y + 15, ColorAlpha(white, notif.alpha))
        end
        
        -- Tweet metni
        local textY = notif.y + (notif.hasImg and 35 or 45)
        draw.SimpleText(notif.text, notif.hasImg and "DefaultSmall" or "TwitterNotifText", notif.x + (notif.hasImg and 25 or 30), textY, ColorAlpha(white, notif.alpha * 0.9))
    end
end)

-- TOGGLE FONKSİYONLARI
function APHONE_TwitterNotifToggle()
    local isEnabled = twitter_notif_enabled:GetBool()
    twitter_notif_enabled:SetBool(not isEnabled)
    
    local newStatus = twitter_notif_enabled:GetBool()
    if newStatus then
        notification.AddLegacy("✓ Twitter bildirimleri AÇILDI", NOTIFY_GENERIC, 3)
        surface.PlaySound("buttons/button15.wav")
    else
        notification.AddLegacy("✗ Twitter bildirimleri KAPATILDI", NOTIFY_ERROR, 3)
        surface.PlaySound("buttons/button10.wav")
    end
    
    print("[Twitter] Bildirimler " .. (newStatus and "AÇILDI" or "KAPATILDI"))
    return newStatus
end

-- Durum kontrol fonksiyonu
function APHONE_GetTwitterNotifStatus()
    return twitter_notif_enabled:GetBool()
end

-- Chat komutu
hook.Add("OnPlayerChat", "TwitterNotifToggleCommand", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "/tnotif" then
        APHONE_TwitterNotifToggle()
        return true
    end
end)

print("[Twitter] Bildirim sistemi yüklendi!")