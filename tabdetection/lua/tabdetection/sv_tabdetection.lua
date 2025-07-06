-- Server-side Tab Detection System
-- Bu dosyayı: garrysmod/lua/tabdetection/sv_tabdetection.lua olarak kaydedin

-- Oyuncuların durumlarını saklayan tablo
local playerStates = {}

-- Network stringlerini tanımla
util.AddNetworkString("TabDetection.WindowFocus")
util.AddNetworkString("TabDetection.UpdatePlayerState")
util.AddNetworkString("TabDetection.RequestStates")

-- Oyuncu bağlandığında
hook.Add("PlayerInitialSpawn", "TabDetection.PlayerConnect", function(ply)
    playerStates[ply] = {
        isTabbed = false,
        isAFK = false,
        lastMove = CurTime(),
        lastPos = ply:GetPos(),
        lastAng = ply:EyeAngles()
    }
end)

-- Oyuncu ayrıldığında
hook.Add("PlayerDisconnected", "TabDetection.PlayerDisconnect", function(ply)
    playerStates[ply] = nil
end)

-- Client'dan gelen sekme durumu güncellemelerini işle
net.Receive("TabDetection.WindowFocus", function(len, ply)
    if not IsValid(ply) or not playerStates[ply] then return end
    
    local hasFocus = net.ReadBool()
    playerStates[ply].isTabbed = not hasFocus
    
    -- Sekme durumu değiştiğinde AFK durumunu güncelle
    if not hasFocus then
        playerStates[ply].isAFK = true
    else
        playerStates[ply].isAFK = false
        playerStates[ply].lastMove = CurTime()
    end
    
    -- Tüm oyunculara durumu gönder
    net.Start("TabDetection.UpdatePlayerState")
        net.WriteEntity(ply)
        net.WriteBool(playerStates[ply].isAFK)
    net.Broadcast()
end)

-- Yeni bağlanan oyuncular mevcut durumları istediğinde
net.Receive("TabDetection.RequestStates", function(len, ply)
    if not IsValid(ply) then return end
    
    -- Tüm oyuncuların durumlarını gönder
    for target, state in pairs(playerStates) do
        if IsValid(target) and target ~= ply then
            net.Start("TabDetection.UpdatePlayerState")
                net.WriteEntity(target)
                net.WriteBool(state.isAFK)
            net.Send(ply)
        end
    end
end)

-- Hareket kontrolü için
hook.Add("Think", "TabDetection.CheckMovement", function()
    for ply, state in pairs(playerStates) do
        if IsValid(ply) and not state.isTabbed then
            local currentPos = ply:GetPos()
            local currentAng = ply:EyeAngles()
            
            -- Pozisyon veya bakış açısı değiştiyse
            if currentPos:Distance(state.lastPos) > 5 or currentAng ~= state.lastAng then
                state.lastMove = CurTime()
                state.lastPos = currentPos
                state.lastAng = currentAng
                
                -- Eğer AFK'ysa aktif yap
                if state.isAFK then
                    state.isAFK = false
                    net.Start("TabDetection.UpdatePlayerState")
                        net.WriteEntity(ply)
                        net.WriteBool(false)
                    net.Broadcast()
                end
            end
            
            -- 120 saniye (2 dakika) hareket etmemişse AFK yap
            if not state.isAFK and CurTime() - state.lastMove > 120 then
                state.isAFK = true
                net.Start("TabDetection.UpdatePlayerState")
                    net.WriteEntity(ply)
                    net.WriteBool(true)
                net.Broadcast()
            end
        end
    end
end)