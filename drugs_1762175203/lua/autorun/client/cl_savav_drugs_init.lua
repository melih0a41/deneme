-- SaVav Drugs System - Optimized Client Init
-- lua/autorun/client/cl_savav_drugs_init.lua

include("drugs_effects/savav_acid.lua")
include("drugs_effects/savav_watermelon.lua")   
include("drugs_effects/savav_beer.lua") 
include("drugs_effects/savav_lcd.lua")
include("drugs_effects/savav_psilocybin.lua")
include("drugs_effects/savav_meth.lua")   
include("drugs_effects/savav_cocaine.lua")   

-- Global değişkenler için güvenli başlatma
local function InitializeDrugVars()
    LocalPlayer().Active = LocalPlayer().Active or 0
    LocalPlayer().ALPHA1 = LocalPlayer().ALPHA1 or 0
    LocalPlayer().ALPHA2 = LocalPlayer().ALPHA2 or 0
    LocalPlayer().DrugType = LocalPlayer().DrugType or "0"
end

-- LocalPlayer hazır olduğunda başlat
hook.Add("InitPostEntity", "DrugSystemInit", InitializeDrugVars)

-- Ses yönetimi için global tablo
DRUG_ACTIVE_SOUNDS = DRUG_ACTIVE_SOUNDS or {}

-- Tüm sesleri temizle
local function CleanupAllDrugSounds()
    for _, sound in pairs(DRUG_ACTIVE_SOUNDS) do
        if sound then
            sound:Stop()
        end
    end
    DRUG_ACTIVE_SOUNDS = {}
end

-- Ölümde temizlik
hook.Add("LocalPlayerDeath", "DrugSystemCleanup", function()
    CleanupAllDrugSounds()
    
    -- Drug efektlerini sıfırla
    LocalPlayer().Active = 0
    LocalPlayer().ALPHA1 = 0
    LocalPlayer().ALPHA2 = 0
    LocalPlayer().DrugType = "0"
    
    -- Watermelon modellerini temizle
    if LocalPlayer().WaterMdodel then
        for _, model in pairs(LocalPlayer().WaterMdodel) do
            if IsValid(model) then
                model:Remove()
            end
        end
        LocalPlayer().WaterMdodel = {}
    end
end)

-- Net mesajları
net.Receive("DrugEffect", function()
    local drugType = net.ReadString()
    
    if LocalPlayer().Active == 0 or LocalPlayer().Active == nil then
        InitializeDrugVars()
        
        LocalPlayer().DrugType = drugType
        LocalPlayer().Active = 1
        LocalPlayer().ALPHA1 = 0
        LocalPlayer().ALPHA2 = 0
        
        -- Drug tipine göre efekt başlat
        local effectFunc = _G["DrugEffect_" .. drugType]
        if effectFunc then
            local fakeData = {
                ReadString = function() return drugType end
            }
            effectFunc(fakeData)
        end
    end
end)

net.Receive("DrugCleanup", function()
    LocalPlayer().Active = 0
    LocalPlayer().ALPHA1 = 0
    LocalPlayer().ALPHA2 = 0
    LocalPlayer().DrugType = "0"
    
    CleanupAllDrugSounds()
    
    -- Watermelon modellerini temizle
    if LocalPlayer().WaterMdodel then
        for _, model in pairs(LocalPlayer().WaterMdodel) do
            if IsValid(model) then
                model:Remove()
            end
        end
        LocalPlayer().WaterMdodel = {}
    end
end)

-- Memory temizlik timer'ı
timer.Create("DrugSystemMemoryCleanup", 60, 0, function()
    -- Kullanılmayan sesleri temizle
    for id, sound in pairs(DRUG_ACTIVE_SOUNDS) do
        if not sound or not sound:IsPlaying() then
            DRUG_ACTIVE_SOUNDS[id] = nil
        end
    end
    
    -- Clientside model sayısını kontrol et
    local csModels = 0
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetClass() == "class C_BaseFlex" then
            csModels = csModels + 1
        end
    end
    
    -- Çok fazla model varsa uyarı
    if csModels > 200 then
        print("[Drugs] Warning: High clientside model count: " .. csModels)
    end
end)

-- Performans monitörü
local perfMonitor = {
    lastFPS = 0,
    lastCheck = 0,
    lowFPSCount = 0,
    wasInDrug = false
}

hook.Add("Think", "DrugPerformanceMonitor", function()
    if CurTime() - perfMonitor.lastCheck < 1 then return end
    perfMonitor.lastCheck = CurTime()
    
    local fps = 1 / FrameTime()
    local inDrug = LocalPlayer().Active == 1 and LocalPlayer().ALPHA1 > 0
    
    -- Drug başladığında veya bittiğinde log
    if inDrug ~= perfMonitor.wasInDrug then
        perfMonitor.wasInDrug = inDrug
        if inDrug then
            print("[Drugs] Effect started - FPS: " .. math.floor(fps))
        else
            print("[Drugs] Effect ended - FPS: " .. math.floor(fps))
        end
    end
    
    -- FPS 25'in altına düştüyse ve drug aktifse
    if fps < 25 and inDrug then
        perfMonitor.lowFPSCount = perfMonitor.lowFPSCount + 1
        
        -- 3 saniye boyunca düşük FPS varsa efektleri azalt
        if perfMonitor.lowFPSCount > 3 then
            LocalPlayer().ALPHA1 = math.max(0, LocalPlayer().ALPHA1 - 25)
            print("[Drugs] Low FPS detected, reducing effects...")
            perfMonitor.lowFPSCount = 0
        end
    else
        perfMonitor.lowFPSCount = 0
    end
    
    perfMonitor.lastFPS = fps
end)

-- Konsol komutları
concommand.Add("drugs_debug", function()
    print("\n=== DRUG SYSTEM DEBUG ===")
    print("Active: " .. tostring(LocalPlayer().Active))
    print("ALPHA1: " .. tostring(LocalPlayer().ALPHA1))
    print("ALPHA2: " .. tostring(LocalPlayer().ALPHA2))
    print("DrugType: " .. tostring(LocalPlayer().DrugType))
    print("Active Sounds: " .. table.Count(DRUG_ACTIVE_SOUNDS))
    print("Current FPS: " .. math.floor(1 / FrameTime()))
    
    if LocalPlayer().WaterMdodel then
        local validModels = 0
        for _, model in pairs(LocalPlayer().WaterMdodel) do
            if IsValid(model) then
                validModels = validModels + 1
            end
        end
        print("Watermelon Models: " .. validModels)
    end
end)

concommand.Add("drugs_stop", function()
    print("[Drugs] Forcing effect stop...")
    
    LocalPlayer().Active = 0
    LocalPlayer().ALPHA1 = 0
    LocalPlayer().ALPHA2 = 0
    LocalPlayer().DrugType = "0"
    
    CleanupAllDrugSounds()
    
    if LocalPlayer().WaterMdodel then
        for _, model in pairs(LocalPlayer().WaterMdodel) do
            if IsValid(model) then
                model:Remove()
            end
        end
        LocalPlayer().WaterMdodel = {}
    end
    
    print("[Drugs] All effects stopped.")
end)

print("[SaVav Drugs] Optimized client init loaded!")
print("[SaVav Drugs] Type 'drugs_debug' in console for debug info")
print("[SaVav Drugs] Type 'drugs_stop' to force stop all effects")