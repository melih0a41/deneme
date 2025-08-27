local cooldownActive = false
local cooldownEndTime = 0
local panelAlpha = 0
local pulseEffect = 0
local iconRotation = 0
local currentSanity = 100

-- Tüm renkler baştan tanımlanıyor
local COLOR_BACKGROUND = Color(20, 20, 25, 220)
local COLOR_BORDER = Color(200, 50, 50, 255)
local COLOR_TIMER_BG = Color(40, 40, 45, 200)
local COLOR_TIMER_FILL = Color(200, 50, 50, 255)
local COLOR_TEXT = Color(255, 255, 255, 255)
local COLOR_WARNING = Color(255, 100, 100, 255)
local COLOR_ICON = Color(200, 50, 50, 255)
local COLOR_GREEN = Color(120, 255, 120, 255)
local COLOR_YELLOW = Color(255, 200, 0, 255)
local COLOR_SANITY_HIGH = Color(120, 255, 120, 255)
local COLOR_SANITY_MID = Color(255, 200, 0, 255)
local COLOR_SANITY_LOW = Color(255, 50, 50, 255)

-- Font oluştur
local function CreateCooldownFonts()
    surface.CreateFont("dex_CooldownTimer", {
        font = "Roboto",
        size = 28,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("dex_CooldownLabel", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true
    })

    surface.CreateFont("dex_CooldownIcon", {
        font = "Marlett",
        size = 32,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("dex_SanityText", {
        font = "Roboto",
        size = 14,
        weight = 600,
        antialias = true
    })
end

-- Font oluşturma
CreateCooldownFonts()
hook.Add("OnScreenSizeChanged", "dex_RecreateCountdownFonts", CreateCooldownFonts)

-- Network mesajları
net.Receive("dex_UpdateCooldown", function()
    local timeLeft = net.ReadFloat()
    local isActive = net.ReadBool()
    
    cooldownActive = isActive
    if isActive then
        cooldownEndTime = CurTime() + timeLeft
    else
        cooldownEndTime = 0
    end
end)

net.Receive("dex_UpdateSanity", function()
    currentSanity = net.ReadInt(8)
end)

net.Receive("dex_CooldownWarning", function()
    local message = net.ReadString()
    notification.AddLegacy(message, NOTIFY_ERROR, 5)
    surface.PlaySound("buttons/button10.wav")
end)

-- Yardımcı fonksiyonlar
local function FormatTime(seconds)
    if not seconds or seconds <= 0 then return "00:00" end
    
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

local function DrawCircularProgress(x, y, radius, progress, segments)
    if not x or not y or not radius or not progress then return end
    
    segments = segments or 32
    local circle = {}
    
    local startAngle = -90
    local endAngle = startAngle + (360 * math.Clamp(progress, 0, 1))
    
    table.insert(circle, {x = x, y = y})
    
    for i = 0, segments do
        local angle = math.rad(startAngle + (endAngle - startAngle) * (i / segments))
        local px = x + math.cos(angle) * radius
        local py = y + math.sin(angle) * radius
        table.insert(circle, {x = px, y = py})
    end
    
    if #circle > 2 then
        surface.DrawPoly(circle)
    end
end

local function GetSanityColor(sanity)
    if sanity >= 70 then
        return COLOR_SANITY_HIGH
    elseif sanity >= 40 then
        return COLOR_SANITY_MID
    else
        return COLOR_SANITY_LOW
    end
end

-- Ana HUD fonksiyonu
hook.Add("HUDPaint", "dex_DrawCooldownPanel", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Config kontrolü
    if not DEX_CONFIG then return end
    if not DEX_CONFIG.IsSerialKiller then return end
    if not DEX_CONFIG.IsSerialKiller(ply) then return end
    
    -- Animasyon değerleri
    local targetAlpha = cooldownActive and 255 or 0
    panelAlpha = Lerp(FrameTime() * 5, panelAlpha, targetAlpha)
    
    if panelAlpha < 1 then return end
    
    -- Pulse efekti
    pulseEffect = math.sin(CurTime() * 2) * 0.1 + 0.9
    iconRotation = iconRotation + FrameTime() * 50
    
    -- Panel pozisyonu ve boyutu
    local screenW, screenH = ScrW(), ScrH()
    local panelW, panelH = 250, 160
    local panelX = screenW - panelW - 20  -- 30'dan 20'ye düşürüldü (daha sağda)
    local panelY = screenH * 0.35  -- Ekranın %35'i kadar aşağıda (ortalanmış)
    
    -- Kalan süre hesapla
    local timeLeft = math.max(0, cooldownEndTime - CurTime())
    local progress = 1 - (timeLeft / 600)
    
    -- Ana panel arka planı
    local bgAlpha = math.floor(panelAlpha * 0.9)
    draw.RoundedBox(8, panelX, panelY, panelW, panelH, 
        Color(COLOR_BACKGROUND.r, COLOR_BACKGROUND.g, COLOR_BACKGROUND.b, bgAlpha))
    
    -- Kenarlık efekti
    surface.SetDrawColor(COLOR_BORDER.r, COLOR_BORDER.g, COLOR_BORDER.b, 
        math.floor(panelAlpha * pulseEffect))
    surface.DrawOutlinedRect(panelX, panelY, panelW, panelH, 2)
    
    -- Başlık
    local titleY = panelY + 15
    draw.SimpleText("⚠ COOLDOWN AKTİF", "dex_CooldownLabel", panelX + panelW/2, titleY, 
        Color(COLOR_WARNING.r, COLOR_WARNING.g, COLOR_WARNING.b, math.floor(panelAlpha)), 
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Circular progress bar
    local circleX = panelX + 45
    local circleY = panelY + 65
    local circleRadius = 30
    
    -- Arka plan çember
    surface.SetDrawColor(COLOR_TIMER_BG.r, COLOR_TIMER_BG.g, COLOR_TIMER_BG.b, 
        math.floor(panelAlpha * 0.5))
    draw.NoTexture()
    
    local bgCircle = {}
    for i = 0, 32 do
        local angle = math.rad(i * 360 / 32)
        table.insert(bgCircle, {
            x = circleX + math.cos(angle) * circleRadius,
            y = circleY + math.sin(angle) * circleRadius
        })
    end
    
    if #bgCircle > 2 then
        surface.DrawPoly(bgCircle)
    end
    
    -- Progress çember
    surface.SetDrawColor(COLOR_TIMER_FILL.r, COLOR_TIMER_FILL.g, COLOR_TIMER_FILL.b, 
        math.floor(panelAlpha))
    DrawCircularProgress(circleX, circleY, circleRadius, progress, 32)
    
    -- İkon (ortada)
    draw.SimpleText("⌛", "dex_CooldownIcon", circleX, circleY, 
        Color(255, 255, 255, math.floor(panelAlpha)), 
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Zaman göstergesi
    local timeText = FormatTime(timeLeft)
    draw.SimpleText(timeText, "dex_CooldownTimer", panelX + 150, circleY - 10, 
        Color(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b, math.floor(panelAlpha)), 
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Durum metni - Sanity durumuna göre değişir
    local statusText = "Sakinleşiyor..."
    local statusColorToUse = COLOR_WARNING
    
    if currentSanity <= 30 then
        statusText = "DELİRİYORSUN!"
        statusColorToUse = COLOR_SANITY_LOW
    elseif currentSanity <= 50 then
        statusText = "İstek artıyor..."
        statusColorToUse = COLOR_SANITY_MID
    elseif timeLeft <= 60 then
        statusText = "Neredeyse hazır!"
        statusColorToUse = COLOR_GREEN
    end
    
    local r = statusColorToUse and statusColorToUse.r or 255
    local g = statusColorToUse and statusColorToUse.g or 255
    local b = statusColorToUse and statusColorToUse.b or 255
    
    draw.SimpleText(statusText, "dex_CooldownLabel", panelX + 150, circleY + 15, 
        Color(r, g, b, math.floor(panelAlpha)), 
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- SANITY GÖSTERGESİ - YENİ!
    local sanityY = panelY + panelH - 40
    local sanityBarW = panelW - 20
    local sanityBarH = 8
    
    -- Sanity bar arka plan
    draw.RoundedBox(4, panelX + 10, sanityY, sanityBarW, sanityBarH, 
        Color(40, 40, 40, math.floor(panelAlpha * 0.7)))
    
    -- Sanity bar dolgu
    local sanityProgress = currentSanity / 100
    local sanityColor = GetSanityColor(currentSanity)
    
    if sanityProgress > 0 then
        draw.RoundedBox(4, panelX + 10, sanityY, sanityBarW * sanityProgress, sanityBarH, 
            Color(sanityColor.r, sanityColor.g, sanityColor.b, math.floor(panelAlpha)))
    end
    
    -- Sanity metni
    draw.SimpleText("Akıl Sağlığı: " .. currentSanity .. "%", "dex_SanityText", 
        panelX + panelW/2, sanityY - 10, 
        Color(sanityColor.r, sanityColor.g, sanityColor.b, math.floor(panelAlpha * 0.9)), 
        TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    
    -- Alt bilgi çubuğu
    local barY = panelY + panelH - 20
    local barProgress = math.Clamp(progress, 0, 1)
    
    -- Progress bar arka plan
    draw.RoundedBox(4, panelX + 10, barY, panelW - 20, 10, 
        Color(COLOR_TIMER_BG.r, COLOR_TIMER_BG.g, COLOR_TIMER_BG.b, 
            math.floor(panelAlpha * 0.5)))
    
    -- Progress bar dolgu
    if barProgress > 0 then
        draw.RoundedBox(4, panelX + 10, barY, (panelW - 20) * barProgress, 10, 
            Color(COLOR_TIMER_FILL.r, COLOR_TIMER_FILL.g, COLOR_TIMER_FILL.b, 
                math.floor(panelAlpha)))
    end
    
    -- Yüzde göstergesi
    local percentText = string.format("%d%%", math.floor(progress * 100))
    draw.SimpleText(percentText, "dex_CooldownLabel", panelX + panelW - 15, barY - 35, 
        Color(COLOR_TEXT.r, COLOR_TEXT.g, COLOR_TEXT.b, math.floor(panelAlpha * 0.7)), 
        TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end)

-- Temizlik: Oyuncu öldüğünde cooldown'u sıfırla
hook.Add("PlayerDeath", "dex_ClearCooldownOnDeath", function(victim)
    if victim == LocalPlayer() then
        cooldownActive = false
        cooldownEndTime = 0
        panelAlpha = 0
    end
end)