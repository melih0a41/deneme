-- lua/drugs_effects/savav_acid.lua
-- OPTIMIZED VERSION - ConCommand spam düzeltildi

local mat_fb = Material("pp/fb")
local DRUG = "savav_acid"

-- Throttle değişkenleri
local lastCommandTime = 0
local commandInterval = 0.5 -- 0.5 saniyede bir komut (spam önleme)
local lastJumpCommand = 0
local isJumping = false

-- Think hook optimizasyonu
hook.Add("Think", "ThinkDrugsREct_savav_acid", function()
    if not LocalPlayer().ALPHA1 or LocalPlayer().ALPHA1 <= 0 then return end
    if LocalPlayer().DrugType ~= DRUG then return end
    
    -- Throttle komutu
    if CurTime() - lastCommandTime < commandInterval then return end
    
    -- Sadece %10 ihtimalle komut çalıştır (600'de 1 yerine)
    local rand = math.random(1, 100)
    
    if rand <= 2 then -- %2 ihtimal
        lastCommandTime = CurTime()
        
        -- Jump toggle sistemi (spam yerine)
        if not isJumping and CurTime() - lastJumpCommand > 2 then
            LocalPlayer():ConCommand("+jump")
            isJumping = true
            lastJumpCommand = CurTime()
            
            timer.Simple(0.3, function()
                LocalPlayer():ConCommand("-jump")
                isJumping = false
            end)
        end
        
    elseif rand <= 4 then -- %2 ihtimal
        lastCommandTime = CurTime()
        
        -- İleri hareket
        LocalPlayer():ConCommand("+forward")
        timer.Simple(0.2, function()
            LocalPlayer():ConCommand("-forward")
        end)
        
    elseif rand <= 5 then -- %1 ihtimal
        lastCommandTime = CurTime()
        
        -- Bakış açısı değişimi (daha az agresif)
        local currentAngles = LocalPlayer():EyeAngles()
        local newYaw = currentAngles.yaw + math.random(-45, 45) -- 90 yerine 45 derece
        LocalPlayer():SetEyeAngles(Angle(currentAngles.pitch, newYaw, currentAngles.roll))
    end
end)

-- CalcView optimizasyonu
local lastCalcView = 0
local calcViewInterval = 1/60 -- 60 FPS cap

local function MyCalcView(ply, pos, angles, fov)
    if not LocalPlayer().ALPHA1 or LocalPlayer().ALPHA1 <= 0 then return end
    if LocalPlayer().DrugType ~= DRUG then return end
    
    -- Throttle
    if CurTime() - lastCalcView < calcViewInterval then return end
    lastCalcView = CurTime()
    
    local view = {}
    view.origin = pos - (angles:Forward() * LocalPlayer().ALPHA1 / 10)
    view.angles = angles + Angle(0, 0, math.cos(CurTime() / 8) * LocalPlayer().ALPHA1 / 4)
    view.fov = fov + LocalPlayer().ALPHA1 / 2
    view.drawviewer = false
    
    return view
end

hook.Add("CalcView", "CalcViewDrugsRect_savav_acid", MyCalcView)

-- HUDPaint optimizasyonu
local lastHudUpdate = 0
local hudUpdateInterval = 1/30 -- 30 FPS for HUD

hook.Add("HUDPaint", "DrugsREct_savav_acid", function()
    if not LocalPlayer().ALPHA1 then return end
    
    -- Effect fade out
    if LocalPlayer().Active == 0 then
        if LocalPlayer().ALPHA1 > 0 then 
            LocalPlayer().ALPHA1 = LocalPlayer().ALPHA1 - 0.5 -- Hızlandırıldı
        end
        if LocalPlayer().ALPHA2 and LocalPlayer().ALPHA2 > 0 then 
            LocalPlayer().ALPHA2 = LocalPlayer().ALPHA2 - 0.5
        end
    end
    
    if LocalPlayer().DrugType == DRUG then
        -- Effect fade in
        if LocalPlayer().Active == 1 then
            if LocalPlayer().ALPHA1 < 255 then 
                LocalPlayer().ALPHA1 = LocalPlayer().ALPHA1 + 0.5 -- Hızlandırıldı
            end
            
            -- Ölüm kontrolü
            if not LocalPlayer():Alive() then
                if LocalPlayer().MUSIC then
                    LocalPlayer().MUSIC:ChangePitch(0, 60)
                    LocalPlayer().MUSIC:ChangeVolume(0, 100)
                end
                LocalPlayer().Active = 0
                
                -- Komutları temizle
                LocalPlayer():ConCommand("-jump")
                LocalPlayer():ConCommand("-forward")
                isJumping = false
            end
        end
        
        -- Throttle HUD render
        if CurTime() - lastHudUpdate < hudUpdateInterval then return end
        lastHudUpdate = CurTime()
        
        -- Optimize edilmiş render (35 yerine 20 iterasyon)
        for i = 1, 20 do
            local Cos = math.cos(i / 2) * LocalPlayer().ALPHA1 * 2
            local Sin = math.sin(i / 2) * LocalPlayer().ALPHA1 * 2
            local Sinonius = math.cos(CurTime()) * LocalPlayer().ALPHA1 / 15
            local Cosonius = math.sin(CurTime()) * LocalPlayer().ALPHA1 / 15
            
            surface.SetDrawColor(255, 255, 255, (LocalPlayer().ALPHA1 / 2.1) / (i / 10))
            surface.SetMaterial(mat_fb)
            surface.DrawTexturedRect(Cos - Cosonius, Sin - Sinonius, ScrW(), ScrH())
        end
        
        -- Screen tint
        surface.SetDrawColor(
            math.sin(CurTime()) * 255, 
            255, 
            -math.cos(CurTime()) * 255, 
            LocalPlayer().ALPHA1 / 2
        )
        surface.DrawRect(0, 0, ScrW(), ScrH())
        
        -- Cleanup check
        if LocalPlayer().ALPHA1 <= 0 then
            LocalPlayer().DrugType = "0"
            
            if LocalPlayer().MUSIC then
                LocalPlayer().MUSIC:Stop()
                DRUG_ACTIVE_SOUNDS[DRUG] = nil
            end
            
            -- Komutları temizle
            LocalPlayer():ConCommand("-jump")
            LocalPlayer():ConCommand("-forward")
            isJumping = false
        end
    end
end)

-- DrugEffect function
local function DrugEffect_savav_acid(data)
    if LocalPlayer().Active == 0 or LocalPlayer().Active == nil then
        LocalPlayer().DrugType = data:ReadString()
        LocalPlayer().Active = 1
        LocalPlayer().ALPHA1 = 0
        LocalPlayer().ALPHA2 = 0
        
        -- Reset command states
        isJumping = false
        lastCommandTime = 0
        lastJumpCommand = 0
        
        -- Sound setup
        LocalPlayer().MUSIC = CreateSound(LocalPlayer(), "MIBD.wav")
        DRUG_ACTIVE_SOUNDS = DRUG_ACTIVE_SOUNDS or {}
        DRUG_ACTIVE_SOUNDS[DRUG] = LocalPlayer().MUSIC
        
        LocalPlayer().MUSIC:Play()
        LocalPlayer().MUSIC:ChangePitch(0, 0)
        LocalPlayer().MUSIC:ChangeVolume(0, 0)
        LocalPlayer().MUSIC:ChangePitch(100, 25)
        LocalPlayer().MUSIC:ChangeVolume(0.4, 6)
        
        -- Timer
        timer.Simple(80, function()
            if LocalPlayer().MUSIC and LocalPlayer().MUSIC:IsPlaying() then
                LocalPlayer().MUSIC:ChangePitch(0, 160)
                LocalPlayer().MUSIC:ChangeVolume(0, 200)
            end
            LocalPlayer().Active = 0
            
            -- Cleanup commands
            LocalPlayer():ConCommand("-jump")
            LocalPlayer():ConCommand("-forward")
            isJumping = false
        end)
    end
end

local function DrugEffect_WATER(data)
    LocalPlayer().Active = 0
    
    -- Cleanup
    if LocalPlayer().MUSIC then
        LocalPlayer().MUSIC:Stop()
    end
    
    -- Komutları temizle
    LocalPlayer():ConCommand("-jump")
    LocalPlayer():ConCommand("-forward")
    isJumping = false
end

usermessage.Hook("DrugEffect_WATER", DrugEffect_WATER)
usermessage.Hook("DrugEffect_savav_acid", DrugEffect_savav_acid)