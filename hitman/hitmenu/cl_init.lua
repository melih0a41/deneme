--[[
Modern Hitman HUD (Optimized & Fixed)
Performans iyileştirmeleri: Trace cache, renk cache, throttling
HUD titremesi düzeltildi
--]]

local localplayer
local hudText
-- Modern Renk Paleti (cl_menu.lua ile uyumlu)
local colors = {
    background = Color(38, 40, 48, 245),
    panelBorder = Color(80, 85, 95, 100),
    primaryText = Color(245, 245, 245, 255),
    secondaryText = Color(160, 165, 175, 220),
    accent = Color(60, 180, 160, 255),
    accentBright = Color(0, 255, 0, 255),
    accentDark = Color(45, 150, 130, 255),
    price = Color(220, 180, 90, 255),
    error = Color(255, 0, 0, 255),
    errorDark = Color(180, 55, 55, 255),
    hudShadow = Color(0, 0, 0, 180)
}

local plyMeta = FindMetaTable("Player")
local activeHitmen = {}
local minHitDistanceSqr = GM.Config.minHitDistance * GM.Config.minHitDistance

-- OPTIMIZASYON: Cache değişkenleri
local eyeTraceCache = {
    time = 0,
    entity = NULL,
    interval = 0.05 -- 50ms cache - daha hızlı güncelleme için azaltıldı
}

local targetInfoCache = {
    time = 0,
    distance = 0,
    nick = "",
    interval = 0.5 -- 500ms cache
}

local visibilityCache = {
    time = 0,
    visible = false,
    interval = 0.2 -- 200ms cache
}

-- HUD Yazısı için stabilite değişkenleri
local showHitRequestText = false
local lastHitmanEntity = NULL
local textAlpha = 0
local targetAlpha = 255

-- OPTIMIZASYON: String cache
local hitRequestText = ""
local targetTextFormat = "Hedef: %s (Mesafe: %d m)"

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function plyMeta:drawHitInfo()
    activeHitmen[self] = true
end

function plyMeta:stopHitInfo()
    activeHitmen[self] = nil
end

--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
function DarkRP.hooks:onHitAccepted(hitman, target, customer)
    if not IsValid(hitman) then return end
    hitman:drawHitInfo()
end

function DarkRP.hooks:onHitCompleted(hitman, target, customer)
    if not IsValid(hitman) then return end
    hitman:stopHitInfo()
end

function DarkRP.hooks:onHitFailed(hitman, target, reason)
    if not IsValid(hitman) then return end
    hitman:stopHitInfo()
end

hook.Add("EntityRemoved", "hitmenu", function(ent)
    activeHitmen[ent] = nil
end)

-- OPTIMIZASYON: Font cache
local font_trebuchet24 = "Trebuchet24"

-- HUDPaint Hook'u (Stabilize Edilmiş)
hook.Add("HUDPaint", "DrawHitOption", function()
    localplayer = localplayer or LocalPlayer()
    if not IsValid(localplayer) then return end
    
    hudText = hudText or GAMEMODE.Config.hudText or "Ben bir tetikçiyim! Benden suikast istemek için E'ye basın."
    hitRequestText = hitRequestText == "" and hudText or hitRequestText
    
    local curTime = CurTime()
    local x, y
    
    -- Eye trace entity kontrolü - her frame güncelle ama smooth transition kullan
    local tr = localplayer:GetEyeTrace()
    local eyeTraceEntity = tr.Entity
    
    -- Hitman'e bakınca çıkan "Hit İste" yazısı - Smooth fade in/out
    if IsValid(eyeTraceEntity) and eyeTraceEntity:IsPlayer() and eyeTraceEntity:isHitman() and not eyeTraceEntity:hasHit() then
        local distSqr = localplayer:GetPos():DistToSqr(eyeTraceEntity:GetPos())
        if distSqr < minHitDistanceSqr then
            -- Fade in
            targetAlpha = math.min(255, targetAlpha + FrameTime() * 500)
            lastHitmanEntity = eyeTraceEntity
            showHitRequestText = true
        else
            -- Fade out
            targetAlpha = math.max(0, targetAlpha - FrameTime() * 500)
            if targetAlpha == 0 then
                showHitRequestText = false
            end
        end
    else
        -- Fade out
        targetAlpha = math.max(0, targetAlpha - FrameTime() * 500)
        if targetAlpha == 0 then
            showHitRequestText = false
            lastHitmanEntity = NULL
        end
    end
    
    -- Yazıyı çiz (alpha ile smooth transition)
    if showHitRequestText and targetAlpha > 0 then
        x, y = ScrW() / 2, ScrH() / 2 + 30
        
        local shadowColor = Color(colors.hudShadow.r, colors.hudShadow.g, colors.hudShadow.b, targetAlpha * 0.7)
        local textColor = Color(colors.primaryText.r, colors.primaryText.g, colors.primaryText.b, targetAlpha)
        
        draw.DrawText(hitRequestText, font_trebuchet24, x + 1, y + 1, shadowColor, TEXT_ALIGN_CENTER)
        draw.DrawText(hitRequestText, font_trebuchet24, x, y, textColor, TEXT_ALIGN_CENTER)
    end

    -- Aktif hit yönetimi
    if not localplayer:isHitman() or not localplayer:hasHit() then return end
    
    local currentTarget = localplayer:getHitTarget()
    if not IsValid(currentTarget) then return end

    -- OPTIMIZASYON: Mesafe ve nick cache
    local distance, targetNick
    if curTime - targetInfoCache.time > targetInfoCache.interval then
        distance = math.Round(localplayer:GetPos():Distance(currentTarget:GetPos()) / 39.37)
        targetNick = currentTarget:Nick()
        targetInfoCache.distance = distance
        targetInfoCache.nick = targetNick
        targetInfoCache.time = curTime
    else
        distance = targetInfoCache.distance
        targetNick = targetInfoCache.nick
    end

    -- OPTIMIZASYON: Görünürlük cache
    local isVisible
    if curTime - visibilityCache.time > visibilityCache.interval then
        local tr = util.TraceLine({
            start = localplayer:EyePos(),
            endpos = currentTarget:GetShootPos(),
            filter = { localplayer, currentTarget },
            mask = MASK_SOLID_BRUSHONLY
        })
        isVisible = not tr.Hit
        visibilityCache.visible = isVisible
        visibilityCache.time = curTime
    else
        isVisible = visibilityCache.visible
    end

    -- Metin ve Renk Ayarlama
    local text = string.format(targetTextFormat, targetNick, distance)
    local textColor = colors.primaryText

    if isVisible then
        textColor = colors.accentBright

        -- Crosshair Kontrolü (Sadece hedef görünürse)
        local aimTrace = util.TraceLine({
            start = localplayer:EyePos(),
            endpos = localplayer:EyePos() + localplayer:GetAimVector() * 16384,
            filter = localplayer
        })
        
        if aimTrace.Hit and aimTrace.Entity == currentTarget then
            textColor = colors.error
        end
    end

    -- Konum ve Çizim
    x = ScrW() / 2
    y = 15

    draw.DrawText(text, font_trebuchet24, x + 1, y + 1, colors.hudShadow, TEXT_ALIGN_CENTER)
    draw.DrawText(text, font_trebuchet24, x, y, textColor, TEXT_ALIGN_CENTER)
end)

-- KeyPress Hook'u (Düzeltilmiş)
local lastKeyPress = 0
local keyPressDelay = 0.5 -- Delay artırıldı
hook.Add("KeyPress", "openHitMenu", function(ply, key)
    if key ~= IN_USE then return end
    if ply ~= LocalPlayer() then return end -- Sadece LocalPlayer için çalış
    
    local curTime = CurTime()
    if curTime - lastKeyPress < keyPressDelay then return end
    
    localplayer = localplayer or LocalPlayer()
    
    -- Güncel trace al
    local tr = localplayer:GetEyeTrace()
    local hitman = tr.Entity
    
    if not IsValid(hitman) or not hitman:IsPlayer() or not hitman:isHitman() then return end
    
    local distSqr = localplayer:GetPos():DistToSqr(hitman:GetPos())
    if distSqr > minHitDistanceSqr then return end

    local canRequest, message = hook.Call("canRequestHit", DarkRP.hooks, hitman, localplayer, nil, hitman:getHitPrice())

    if not canRequest then
        GAMEMODE:AddNotify(DarkRP.getPhrase("cannot_request_hit", message or ""), 1, 4)
        surface.PlaySound("buttons/lightswitch2.wav")
        return
    end

    lastKeyPress = curTime -- Key press zamanını güncelle
    DarkRP.openHitMenu(hitman)
end)

-- InitPostEntity Hook'u
hook.Add("InitPostEntity", "HitmanMenu", function()
    for _, v in pairs(player.GetAll()) do
        if IsValid(v) and v:isHitman() and v:hasHit() then
            v:drawHitInfo()
        end
    end
end)

-- OPTIMIZASYON: Cache temizleme
hook.Add("OnEntityCreated", "HitmanCacheClear", function(ent)
    if ent:IsPlayer() then
        targetInfoCache.time = 0
        visibilityCache.time = 0
    end
end)

--[[---------------------------------------------------------------------------
Networking
---------------------------------------------------------------------------]]
net.Receive("onHitAccepted", function(len)
    hook.Call("onHitAccepted", DarkRP.hooks, net.ReadEntity(), net.ReadEntity(), net.ReadEntity())
end)

net.Receive("onHitCompleted", function(len)
    hook.Call("onHitCompleted", DarkRP.hooks, net.ReadEntity(), net.ReadEntity(), net.ReadEntity())
end)

net.Receive("onHitFailed", function(len)
    hook.Call("onHitFailed", DarkRP.hooks, net.ReadEntity(), net.ReadEntity(), net.ReadString())
end)