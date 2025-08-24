-- Cooldown Sistemi
util.AddNetworkString("dex_UpdateCooldown")
util.AddNetworkString("dex_CooldownWarning")

local PlayerCooldowns = {}
local COOLDOWN_TIME = 600 -- 10 dakika (600 saniye)

-- Cooldown başlatma fonksiyonu
function StartKillCooldown(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID()
    PlayerCooldowns[steamID] = {
        endTime = CurTime() + COOLDOWN_TIME,
        startTime = CurTime()
    }
    
    -- Client'a cooldown bilgisini gönder
    net.Start("dex_UpdateCooldown")
        net.WriteFloat(COOLDOWN_TIME)
        net.WriteBool(true)
    net.Send(ply)
    
    -- Cooldown timer'ı başlat
    timer.Create("dex_cooldown_" .. steamID, 1, COOLDOWN_TIME, function()
        if not IsValid(ply) then 
            timer.Remove("dex_cooldown_" .. steamID)
            return 
        end
        
        local timeLeft = PlayerCooldowns[steamID] and (PlayerCooldowns[steamID].endTime - CurTime()) or 0
        
        if timeLeft <= 0 then
            -- Cooldown bitti
            PlayerCooldowns[steamID] = nil
            
            net.Start("dex_UpdateCooldown")
                net.WriteFloat(0)
                net.WriteBool(false)
            net.Send(ply)
            
            -- Bildirim gönder
            if DarkRP then
                DarkRP.notify(ply, 0, 5, "Tekrar avlanmaya hazırsın!")
            end
            
            timer.Remove("dex_cooldown_" .. steamID)
        else
            -- Süre güncelle
            net.Start("dex_UpdateCooldown")
                net.WriteFloat(timeLeft)
                net.WriteBool(true)
            net.Send(ply)
        end
    end)
end

-- Cooldown kontrol fonksiyonu
function IsOnCooldown(ply)
    if not IsValid(ply) then return false end
    
    local steamID = ply:SteamID()
    local cooldownData = PlayerCooldowns[steamID]
    
    if cooldownData and cooldownData.endTime > CurTime() then
        return true, cooldownData.endTime - CurTime()
    end
    
    return false, 0
end

-- Oyuncu çıkış yapınca temizle
hook.Add("PlayerDisconnected", "dex_ClearCooldown", function(ply)
    local steamID = ply:SteamID()
    PlayerCooldowns[steamID] = nil
    timer.Remove("dex_cooldown_" .. steamID)
end)

-- Oyuncu giriş yapınca cooldown kontrolü
hook.Add("PlayerInitialSpawn", "dex_CheckCooldown", function(ply)
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        
        local steamID = ply:SteamID()
        if PlayerCooldowns[steamID] and PlayerCooldowns[steamID].endTime > CurTime() then
            local timeLeft = PlayerCooldowns[steamID].endTime - CurTime()
            
            net.Start("dex_UpdateCooldown")
                net.WriteFloat(timeLeft)
                net.WriteBool(true)
            net.Send(ply)
        end
    end)
end)