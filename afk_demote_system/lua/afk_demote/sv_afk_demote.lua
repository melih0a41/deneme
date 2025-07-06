-- Server-side AFK Demote System
-- Bu dosyayı: garrysmod/addons/afk_demote_system/lua/afk_demote/sv_afk_demote.lua olarak kaydedin

-- Network strings
util.AddNetworkString("AFKDemote.ShowWarning")
util.AddNetworkString("AFKDemote.Response")
util.AddNetworkString("AFKDemote.CheckActivity")

-- Aktif demote istekleri ve cooldown
local activeDemoteRequests = {}
local playerLastActivity = {}
local demoteCooldowns = {}

-- Oyuncu aktivitesini takip et
hook.Add("PlayerInitialSpawn", "AFKDemote.TrackActivity", function(ply)
    playerLastActivity[ply] = {
        lastMove = CurTime(),
        lastPos = ply:GetPos(),
        lastAng = ply:EyeAngles(),
        lastAction = CurTime()
    }
end)

-- Hareket kontrolü
hook.Add("Think", "AFKDemote.CheckMovement", function()
    for ply, data in pairs(playerLastActivity) do
        if IsValid(ply) and ply:Alive() then
            local currentPos = ply:GetPos()
            local currentAng = ply:EyeAngles()
            
            if currentPos:Distance(data.lastPos) > 5 or currentAng ~= data.lastAng then
                data.lastMove = CurTime()
                data.lastPos = currentPos
                data.lastAng = currentAng
                data.lastAction = CurTime()
            end
        end
    end
end)

-- Aktivite takibi
hook.Add("KeyPress", "AFKDemote.KeyPress", function(ply, key)
    if playerLastActivity[ply] then
        playerLastActivity[ply].lastAction = CurTime()
    end
end)

hook.Add("PlayerSwitchWeapon", "AFKDemote.WeaponSwitch", function(ply, oldWep, newWep)
    if playerLastActivity[ply] then
        playerLastActivity[ply].lastAction = CurTime()
    end
end)

hook.Add("PlayerSay", "AFKDemote.PlayerChat", function(ply, text)
    if playerLastActivity[ply] then
        playerLastActivity[ply].lastAction = CurTime()
    end
end)

-- Ana demote fonksiyonu
local function AFKDemoteCommand(ply, args)
    if not IsValid(ply) then return "" end
    
    -- Argümanları parse et
    args = args or ""
    local splitArgs = string.Explode(" ", string.Trim(args))
    local targetName = splitArgs[1] or ""
    local reason = table.concat(splitArgs, " ", 2) or ""
    
    -- Hedef kontrolü
    if targetName == "" then
        DarkRP.notify(ply, 1, 4, "Kullanım: /demote <oyuncu>")
        return ""
    end
    
    -- Sadece AFK sebebi kabul et
    if reason ~= "" and string.lower(reason) ~= "afk" then
        DarkRP.notify(ply, 1, 4, "Sadece AFK sebebi ile demote atabilirsiniz!")
        return ""
    end
    
    -- Oyuncuyu bul
    local target = DarkRP.findPlayer(targetName)
    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, "Oyuncu bulunamadı: " .. targetName)
        return ""
    end
    
    -- Kendini demote kontrolü
    if target == ply then
        DarkRP.notify(ply, 1, 4, "Kendinizi demote edemezsiniz!")
        return ""
    end
    
    -- Default job kontrolü
    if target:Team() == GAMEMODE.DefaultTeam then
        DarkRP.notify(ply, 1, 4, "Bu oyuncu zaten varsayılan meslekte!")
        return ""
    end
    
    -- Cooldown kontrolü
    local cooldownKey = ply:SteamID() .. "_" .. target:SteamID()
    if demoteCooldowns[cooldownKey] and demoteCooldowns[cooldownKey] > CurTime() then
        local timeLeft = math.ceil((demoteCooldowns[cooldownKey] - CurTime()) / 60)
        DarkRP.notify(ply, 1, 4, "Bu oyuncuya tekrar demote için " .. timeLeft .. " dakika bekleyin!")
        return ""
    end
    
    -- AFK kontrolü
    local lastActivity = playerLastActivity[target]
    if lastActivity and (CurTime() - lastActivity.lastAction) < 10 then
        DarkRP.notify(ply, 1, 4, target:Nick() .. " şu anda aktif! AFK değil.")
        return ""
    end
    
    -- Aktif istek kontrolü
    if activeDemoteRequests[target] then
        DarkRP.notify(ply, 1, 4, "Bu oyuncu için zaten bir AFK kontrolü var!")
        return ""
    end
    
    -- İşlemi başlat
    demoteCooldowns[cooldownKey] = CurTime() + 1800
    activeDemoteRequests[target] = {
        demoteBy = ply,
        startTime = CurTime(),
        targetTeam = target:Team(),
        responded = false
    }
    
    -- Uyarı gönder
    net.Start("AFKDemote.ShowWarning")
        net.WriteEntity(ply)
    net.Send(target)
    
    DarkRP.notify(ply, 0, 4, target:Nick() .. " oyuncusuna AFK uyarısı gönderildi.")
    print("[AFK Demote] " .. ply:Nick() .. " sent AFK warning to " .. target:Nick())
    
    -- Timer
    timer.Create("AFKDemote_" .. target:SteamID64(), 300, 1, function()
        if IsValid(target) and activeDemoteRequests[target] and not activeDemoteRequests[target].responded then
            if IsValid(activeDemoteRequests[target].demoteBy) then
                target:changeTeam(GAMEMODE.DefaultTeam, true)
                DarkRP.notifyAll(0, 5, target:Nick() .. " AFK olduğu için meslekten atıldı!")
                print("[AFK Demote] " .. target:Nick() .. " was demoted for being AFK")
            end
        end
        activeDemoteRequests[target] = nil
    end)
    
    return ""
end

-- DarkRP komutunu override et
if DarkRP then
    -- Mevcut komutu kaldır
    DarkRP.removeChatCommand("demote")
    
    -- Yeni komutu ekle
    DarkRP.defineChatCommand("demote", AFKDemoteCommand)
    
    print("[AFK Demote] Demote command registered successfully!")
end

-- Varsayılan demote'u engelle
hook.Add("canDemote", "AFKDemote.BlockDefault", function()
    return false, ""
end)

-- Client yanıtı
net.Receive("AFKDemote.Response", function(len, ply)
    local isAFK = net.ReadBool()
    
    if activeDemoteRequests[ply] and not isAFK then
        activeDemoteRequests[ply].responded = true
        timer.Remove("AFKDemote_" .. ply:SteamID64())
        
        if IsValid(activeDemoteRequests[ply].demoteBy) then
            DarkRP.notify(activeDemoteRequests[ply].demoteBy, 1, 5, ply:Nick() .. " AFK değil!")
        end
        
        DarkRP.notify(ply, 0, 4, "AFK olmadığınız onaylandı.")
        activeDemoteRequests[ply] = nil
    end
end)

-- Temizlik
hook.Add("PlayerDisconnected", "AFKDemote.CleanUp", function(ply)
    playerLastActivity[ply] = nil
    if activeDemoteRequests[ply] then
        timer.Remove("AFKDemote_" .. ply:SteamID64())
        activeDemoteRequests[ply] = nil
    end
    
    for key, _ in pairs(demoteCooldowns) do
        if string.find(key, ply:SteamID()) then
            demoteCooldowns[key] = nil
        end
    end
end)

-- Aktivite kontrolü
timer.Create("AFKDemote.SendActivityCheck", 5, 0, function()
    for target, request in pairs(activeDemoteRequests) do
        if IsValid(target) and not request.responded then
            net.Start("AFKDemote.CheckActivity")
            net.Send(target)
        end
    end
end)