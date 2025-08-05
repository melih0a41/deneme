-- lua/drugs_effects/savav_watermelon.lua
-- OPTIMIZED VERSION - 100 model yerine max 25 model

local mat_fb = Material( "pp/fb" )
local WMmat = Material( "Melon_screen" )
local DRUG = "savav_watermelon"

-- Optimizasyon değişkenleri
local MAX_WATERMELONS = 25 -- 100'den 25'e düşürüldü
local watermelonModels = {}
local lastModelUpdate = 0
local modelUpdateInterval = 0.1 -- 0.1 saniyede bir güncelle

-- SkyBox render optimizasyonu
local lastSkyRender = 0
local skyRenderInterval = 1/30 -- 30 FPS cap

hook.Add( "PostDrawSkyBox", "PostDrawSkyBoxDGUG_savav_watermelon", function()
    if not LocalPlayer().ALPHA1 or LocalPlayer().ALPHA1 <= 0 then return end
    if LocalPlayer().DrugType ~= DRUG then return end
    
    -- Throttle
    if CurTime() - lastSkyRender < skyRenderInterval then return end
    lastSkyRender = CurTime()
    
    render.SetMaterial( WMmat )
    render.DrawQuadEasy(
        LocalPlayer():EyePos() + Vector(0, 0, 100), 
        Vector(-1, 0, -90), 
        2920, 
        2080, 
        Color(255, 255, 255, LocalPlayer().ALPHA1), 
        0
    )
end)

-- Model render optimizasyonu
hook.Add( "PostDrawOpaqueRenderables", "PostDrawOpaqueRenderablesDRUG_savav_watermelon", function()
    if not LocalPlayer().ALPHA1 or LocalPlayer().ALPHA1 <= 0 then return end
    if LocalPlayer().DrugType ~= DRUG then return end
    
    -- Throttle model updates
    if CurTime() - lastModelUpdate < modelUpdateInterval then 
        -- Sadece render et, pozisyon güncelleme yapma
        for i = 1, MAX_WATERMELONS do
            if IsValid(watermelonModels[i]) and watermelonModels[i]:GetColor().a > 0 then
                watermelonModels[i]:DrawModel()
            end
        end
        return
    end
    lastModelUpdate = CurTime()
    
    -- Alpha'ya göre model sayısını ayarla
    local activeModels = math.min(MAX_WATERMELONS, math.floor(LocalPlayer().ALPHA1 / 10))
    
    for i = 1, activeModels do
        -- Model yoksa oluştur
        if not IsValid(watermelonModels[i]) then
            watermelonModels[i] = ClientsideModel("models/props_junk/watermelon01.mdl")
            watermelonModels[i]:SetRenderMode(RENDERMODE_TRANSALPHA)
            watermelonModels[i]:SetPos(LocalPlayer():GetPos() + Vector(0, 0, 100))
        end
        
        -- Pozisyon güncelleme (optimized)
        local currentZ = watermelonModels[i]:GetPos().z
        local playerZ = LocalPlayer():GetPos().z
        
        if currentZ > playerZ - 50 then
            watermelonModels[i]:SetPos(watermelonModels[i]:GetPos() + Vector(0, 0, -1.5))
        else
            -- Yeni random pozisyon
            watermelonModels[i]:SetPos(LocalPlayer():GetPos() + Vector(
                math.random(-800, 800), -- 1000'den 800'e düşürüldü
                math.random(-800, 800),
                math.random(300, 500)   -- 400-700'den 300-500'e düşürüldü
            ))
        end
        
        watermelonModels[i]:SetColor(Color(255, 255, 255, LocalPlayer().ALPHA1))
        watermelonModels[i]:DrawModel()
    end
    
    -- Kullanılmayan modelleri gizle (silme yerine)
    for i = activeModels + 1, MAX_WATERMELONS do
        if IsValid(watermelonModels[i]) then
            watermelonModels[i]:SetColor(Color(255, 255, 255, 0))
        end
    end
end)

-- RenderScreenspaceEffects optimizasyonu
local lastEffectRender = 0
local effectRenderInterval = 1/60 -- 60 FPS cap

hook.Add( "RenderScreenspaceEffects", "DrugsREcts_savav_watermelon", function()
    if not LocalPlayer().ALPHA1 or LocalPlayer().ALPHA1 <= 0 then return end
    if LocalPlayer().DrugType ~= DRUG then return end
    
    -- Throttle
    if CurTime() - lastEffectRender < effectRenderInterval then return end
    lastEffectRender = CurTime()
    
    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0 - LocalPlayer().ALPHA1 / 590,
        ["$pp_colour_contrast"] = 1 + LocalPlayer().ALPHA1 / 590,
        ["$pp_colour_colour"] = 1 + LocalPlayer().ALPHA1 / 80,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })
end)

-- CalcView optimizasyonu
local lastCalcView = 0
local calcViewInterval = 1/60 -- 60 FPS cap

local function MyCalcView( ply, pos, angles, fov )
    if not LocalPlayer().ALPHA1 or LocalPlayer().ALPHA1 <= 0 then return end
    if LocalPlayer().DrugType ~= DRUG then return end
    
    -- Throttle
    if CurTime() - lastCalcView < calcViewInterval then return end
    lastCalcView = CurTime()
    
    local view = {}
    view.origin = pos + angles:Forward() * (LocalPlayer().ALPHA1 / 7)
    view.angles = angles + Angle(0, math.cos(CurTime()) * LocalPlayer().ALPHA1 / 120, 0)
    view.fov = fov + LocalPlayer().ALPHA1 / 3.6
    view.drawviewer = false
    
    return view
end

hook.Add( "CalcView", "CalcViewDrugsRect_savav_watermelon", MyCalcView )

-- HUDPaint optimizasyonu
hook.Add( "HUDPaint", "DrugsREct_savav_watermelon", function()
    if not LocalPlayer().ALPHA1 then return end
    
    -- Effect fade out
    if LocalPlayer().Active == 0 then
        if LocalPlayer().ALPHA1 > 0 then 
            LocalPlayer().ALPHA1 = LocalPlayer().ALPHA1 - 0.5 -- 0.05'ten 0.5'e hızlandırıldı
        end
        if LocalPlayer().ALPHA2 and LocalPlayer().ALPHA2 > 0 then 
            LocalPlayer().ALPHA2 = LocalPlayer().ALPHA2 - 0.5
        end
    end
    
    if LocalPlayer().DrugType == DRUG then
        -- Effect fade in
        if LocalPlayer().Active == 1 then
            if LocalPlayer().ALPHA1 < 255 then 
                LocalPlayer().ALPHA1 = LocalPlayer().ALPHA1 + 0.5 -- 0.05'ten 0.5'e hızlandırıldı
            end
            
            -- Ölüm kontrolü
            if not LocalPlayer():Alive() then
                if LocalPlayer().MUSIC then
                    LocalPlayer().MUSIC:ChangePitch(0, 60)
                    LocalPlayer().MUSIC:ChangeVolume(0, 100)
                end
                LocalPlayer().Active = 0
            end
        end
        
        -- Screen effect
        surface.SetDrawColor(
            math.sin(CurTime()) * 255, 
            255, 
            math.sin(CurTime()) * 255, 
            LocalPlayer().ALPHA1 / 35
        )
        surface.DrawRect(0, 0, ScrW(), ScrH())
        
        -- Cleanup check
        if LocalPlayer().ALPHA1 <= 0 then
            LocalPlayer().DrugType = "0"
            
            if LocalPlayer().MUSIC then
                LocalPlayer().MUSIC:Stop()
                DRUG_ACTIVE_SOUNDS[DRUG] = nil
            end
            
            -- Model cleanup
            for i = 1, MAX_WATERMELONS do
                if IsValid(watermelonModels[i]) then
                    watermelonModels[i]:Remove()
                end
            end
            watermelonModels = {}
        end
    end
end)

-- DrugEffect function
local function DrugEffect_savav_watermelon(data)
    if LocalPlayer().Active == 0 or LocalPlayer().Active == nil then
        LocalPlayer().DrugType = data:ReadString()
        LocalPlayer().Active = 1
        LocalPlayer().ALPHA1 = 0
        LocalPlayer().ALPHA2 = 0
        
        -- Sound setup
        LocalPlayer().MUSIC = CreateSound(LocalPlayer(), "awoo.wav")
        DRUG_ACTIVE_SOUNDS = DRUG_ACTIVE_SOUNDS or {}
        DRUG_ACTIVE_SOUNDS[DRUG] = LocalPlayer().MUSIC
        
        LocalPlayer().MUSIC:Play()
        LocalPlayer().MUSIC:ChangePitch(0, 0)
        LocalPlayer().MUSIC:ChangeVolume(0, 0)
        LocalPlayer().MUSIC:ChangePitch(100, 9)
        LocalPlayer().MUSIC:ChangeVolume(1, 6)
        
        -- Model tablosunu sıfırla
        watermelonModels = {}
        
        -- Timer
        timer.Simple(60, function()
            if LocalPlayer().MUSIC and LocalPlayer().MUSIC:IsPlaying() then
                LocalPlayer().MUSIC:ChangePitch(0, 60)
                LocalPlayer().MUSIC:ChangeVolume(0, 100)
            end
            LocalPlayer().Active = 0
        end)
    end
end

local function DrugEffect_WATER(data)
    LocalPlayer().Active = 0
    
    -- Cleanup
    if LocalPlayer().MUSIC then
        LocalPlayer().MUSIC:Stop()
    end
    
    for i = 1, MAX_WATERMELONS do
        if IsValid(watermelonModels[i]) then
            watermelonModels[i]:Remove()
        end
    end
    watermelonModels = {}
end

usermessage.Hook("DrugEffect_WATER", DrugEffect_WATER) 
usermessage.Hook("DrugEffect_savav_watermelon", DrugEffect_savav_watermelon)

-- Cleanup on script reload
for i = 1, 100 do
    if IsValid(watermelonModels[i]) then
        watermelonModels[i]:Remove()
    end
end
watermelonModels = {}