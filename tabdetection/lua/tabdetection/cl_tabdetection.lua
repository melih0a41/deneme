-- Client-side Tab Detection System
-- Bu dosyayı: garrysmod/lua/tabdetection/cl_tabdetection.lua olarak kaydedin

-- AFK durumlarını sakla
TabDetection = TabDetection or {}
TabDetection.PlayerStates = TabDetection.PlayerStates or {}

-- Windows ve Linux'ta pencere odağını kontrol et
if system.IsWindows() or system.IsLinux() then
    local lastFocusState = system.HasFocus()
    
    hook.Add("Think", "TabDetection.CheckWindowFocus", function()
        local currentFocus = system.HasFocus()
        
        -- Durum değiştiyse sunucuya bildir
        if currentFocus ~= lastFocusState then
            lastFocusState = currentFocus
            
            net.Start("TabDetection.WindowFocus")
                net.WriteBool(currentFocus)
            net.SendToServer()
        end
    end)
end

-- Sunucudan gelen durum güncellemelerini işle
net.Receive("TabDetection.UpdatePlayerState", function()
    local ply = net.ReadEntity()
    local isAFK = net.ReadBool()
    
    if IsValid(ply) then
        TabDetection.PlayerStates[ply] = isAFK
    end
end)

-- İlk bağlandığımızda durumları iste
hook.Add("InitPostEntity", "TabDetection.RequestStates", function()
    timer.Simple(1, function()
        net.Start("TabDetection.RequestStates")
        net.SendToServer()
        
        -- İlk odak durumunu gönder
        if system.IsWindows() or system.IsLinux() then
            net.Start("TabDetection.WindowFocus")
                net.WriteBool(system.HasFocus())
            net.SendToServer()
        end
    end)
end)

-- Oyuncu ayrıldığında temizle
hook.Add("EntityRemoved", "TabDetection.CleanupPlayer", function(ent)
    if ent:IsPlayer() then
        TabDetection.PlayerStates[ent] = nil
    end
end)