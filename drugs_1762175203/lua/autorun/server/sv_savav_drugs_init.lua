-- SaVav Drugs System - Optimized Server Init
-- lua/autorun/server/sv_savav_drugs_init.lua

AddCSLuaFile("drugs_effects/savav_acid.lua")
AddCSLuaFile("drugs_effects/savav_watermelon.lua")
AddCSLuaFile("drugs_effects/savav_beer.lua")
AddCSLuaFile("drugs_effects/savav_lcd.lua")
AddCSLuaFile("drugs_effects/savav_psilocybin.lua")
AddCSLuaFile("drugs_effects/savav_meth.lua")
AddCSLuaFile("drugs_effects/savav_cocaine.lua")

-- Network strings
util.AddNetworkString("DrugEffect")
util.AddNetworkString("DrugCleanup")

local function DRUGSINPUT( ply )
    ply:SetNWFloat( "drug", "0" )
end

-- DRUGSTHINK FONKSIYONU KALDIRILDI! CPU SORUNU ÇÖZÜLDÜ!
-- Eski kod hiçbir işe yaramıyordu ve performans sorununa neden oluyordu

hook.Add( "PlayerInitialSpawn", "DRUGSINPUT", DRUGSINPUT )

-- Ölümde drug efektlerini temizle
hook.Add("PlayerDeath", "CleanupDrugEffects", function(ply)
    ply:SetNWFloat("drug", "0")
    timer.Remove(ply:Name() .. "_DrugTimer")
    
    -- Client'a temizleme mesajı gönder
    net.Start("DrugCleanup")
    net.Send(ply)
end)

-- Disconnect'te timer temizliği
hook.Add("PlayerDisconnected", "CleanupDrugTimers", function(ply)
    timer.Remove(ply:Name() .. "_DrugTimer")
end)

-- Entity spawn limiti
local maxDrugEntities = 50 -- Toplam drug entity limiti
local playerDrugLimit = 5 -- Oyuncu başına limit

hook.Add("OnEntityCreated", "DrugEntityLimit", function(ent)
    if not IsValid(ent) then return end
    
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        
        local class = ent:GetClass()
        if string.find(class, "savav_") then
            local count = 0
            for _, e in ipairs(ents.FindByClass("savav_*")) do
                count = count + 1
            end
            
            if count > maxDrugEntities then
                ent:Remove()
                print("[Drugs] Entity limit reached (" .. maxDrugEntities .. "), removing excess drug entities")
            end
        end
    end)
end)

-- Oyuncu başına drug limiti
hook.Add("PlayerCanPickupItem", "DrugPlayerLimit", function(ply, item)
    if not IsValid(item) then return end
    
    local class = item:GetClass()
    if string.find(class, "savav_") then
        -- Oyuncunun aktif drug'u var mı kontrol et
        if ply:GetNWFloat("drug") ~= "0" then
            ply:ChatPrint("Zaten bir uyuşturucu etkisi altındasınız!")
            return false
        end
    end
end)

-- Performans monitörü (sadece superadmin için)
local perfCheckInterval = 30 -- 30 saniyede bir kontrol
local lastPerfCheck = 0

hook.Add("Think", "DrugSystemPerformanceMonitor", function()
    if CurTime() - lastPerfCheck < perfCheckInterval then return end
    lastPerfCheck = CurTime()
    
    local drugEntCount = #ents.FindByClass("savav_*")
    local activeDrugUsers = 0
    
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetNWFloat("drug") ~= "0" then
            activeDrugUsers = activeDrugUsers + 1
        end
    end
    
    -- Yüksek entity sayısında uyarı
    if drugEntCount > 30 then
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsSuperAdmin() then
                ply:ChatPrint("[Drugs] UYARI: " .. drugEntCount .. " drug entity var! (Limit: " .. maxDrugEntities .. ")")
            end
        end
    end
    
    -- Debug bilgisi
    if game.GetIPAddress() == "loopback" then -- Sadece local server'da
        print("[Drugs] Entities: " .. drugEntCount .. " | Active Users: " .. activeDrugUsers)
    end
end)

-- Temizlik komutu (admin için)
concommand.Add("drugs_cleanup", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("Bu komutu kullanma yetkiniz yok!")
        return
    end
    
    local removed = 0
    
    -- Tüm drug entity'lerini temizle
    for _, ent in ipairs(ents.FindByClass("savav_*")) do
        ent:Remove()
        removed = removed + 1
    end
    
    -- Tüm oyuncuların drug efektlerini temizle
    for _, p in ipairs(player.GetAll()) do
        p:SetNWFloat("drug", "0")
        timer.Remove(p:Name() .. "_DrugTimer")
        
        net.Start("DrugCleanup")
        net.Send(p)
    end
    
    local msg = "[Drugs] " .. removed .. " entity temizlendi, tüm efektler sıfırlandı."
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

-- Drug bilgi komutu
concommand.Add("drugs_info", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    local drugEntCount = #ents.FindByClass("savav_*")
    local activeDrugUsers = {}
    
    for _, p in ipairs(player.GetAll()) do
        local drug = p:GetNWFloat("drug")
        if drug ~= "0" then
            table.insert(activeDrugUsers, p:Nick() .. " - " .. drug)
        end
    end
    
    local msg = "\n=== DRUG SYSTEM INFO ===\n"
    msg = msg .. "Total Entities: " .. drugEntCount .. "/" .. maxDrugEntities .. "\n"
    msg = msg .. "Active Users: " .. #activeDrugUsers .. "\n"
    
    if #activeDrugUsers > 0 then
        msg = msg .. "\nActive Effects:\n"
        for _, info in ipairs(activeDrugUsers) do
            msg = msg .. "- " .. info .. "\n"
        end
    end
    
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, msg)
    else
        print(msg)
    end
end)

print("[SaVav Drugs] Optimized server init loaded!")
print("[SaVav Drugs] DRUGSTHINK hook removed - CPU usage fixed!")
print("[SaVav Drugs] Entity limit: " .. maxDrugEntities)
print("[SaVav Drugs] Per-player limit: " .. playerDrugLimit)