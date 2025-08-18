-- fib_sistem/lua/autorun/client/cl_fib_chat_receiver.lua
-- FIB Chat Receiver - FIXED v2.0

-- ============================================
-- CHAT MESAJI ALINDIĞINDA
-- ============================================
net.Receive("FIB_ReceiveChatMessage", function()
    local msgData = net.ReadTable()
    
    -- Veri kontrolü
    if not msgData or not msgData.sender or not msgData.message then
        print("[FIB CHAT] Hatalı mesaj verisi alındı!")
        return
    end
    
    -- Debug log
    print("[FIB CHAT] Mesaj alindi: " .. msgData.sender .. ": " .. msgData.message)
    
    -- Ana menü açıksa ve iletişim sekmesindeyse mesajı ekle
    if FIB and FIB.AddChatMessage then
        FIB.AddChatMessage(
            msgData.sender,
            msgData.message,
            msgData.rank or "Ajan",
            msgData.time or os.date("%H:%M"),
            msgData.isUndercover or false
        )
    else
        print("[FIB CHAT] AddChatMessage fonksiyonu bulunamadi!")
    end
    
    -- Bildirim sesi (kendi mesajın değilse)
    if msgData.steamid ~= LocalPlayer():SteamID() then
        surface.PlaySound("buttons/button24.wav")
        
        -- Küçük bildirim göster
        notification.AddLegacy("FIB: Yeni mesaj - " .. msgData.sender, NOTIFY_GENERIC, 3)
    end
end)

-- ============================================
-- CHAT GEÇMİŞİ ALINDIĞINDA
-- ============================================
net.Receive("FIB_ChatHistory", function()
    local messages = net.ReadTable()
    
    if not messages then
        print("[FIB CHAT] Chat gecmisi alinamadi!")
        return
    end
    
    print("[FIB CHAT] Chat gecmisi alindi: " .. #messages .. " mesaj")
    
    -- Önce mevcut mesajları temizle
    if IsValid(FIB.ChatContent) then
        FIB.ChatContent:Clear()
        FIB.ChatContent:SetTall(0)
        
        -- Çocuk panelleri temizle
        for _, child in ipairs(FIB.ChatContent:GetChildren()) do
            if IsValid(child) then
                child:Remove()
            end
        end
    end
    
    -- Timer ile mesajları ekle (UI donmasını önlemek için)
    local messageIndex = 1
    local function AddNextMessage()
        if messageIndex <= #messages then
            local msgData = messages[messageIndex]
            
            if msgData and FIB and FIB.AddChatMessage then
                FIB.AddChatMessage(
                    msgData.sender,
                    msgData.message,
                    msgData.rank or "Ajan",
                    msgData.time or os.date("%H:%M"),
                    msgData.isUndercover or false
                )
            end
            
            messageIndex = messageIndex + 1
            
            -- Sonraki mesajı ekle
            timer.Simple(0.01, AddNextMessage)
        else
            -- Tüm mesajlar eklendi, scroll'u en alta getir
            timer.Simple(0.1, function()
                if IsValid(FIB.ChatScroll) then
                    FIB.ChatScroll:GetVBar():SetScroll(FIB.ChatScroll:GetCanvas():GetTall())
                end
            end)
        end
    end
    
    -- Mesaj eklemeyi başlat
    if #messages > 0 then
        AddNextMessage()
    end
end)

-- ============================================
-- GÖREV GÜNCELLEMELERİ
-- ============================================
net.Receive("FIB_MissionUpdate", function()
    local action = net.ReadString()
    
    if action == "new" then
        local missionData = net.ReadTable()
        
        -- Listeye ekle
        if FIB.Missions then
            table.insert(FIB.Missions, missionData)
        else
            FIB.Missions = {missionData}
        end
        
        -- UI'ı güncelle
        if FIB.RefreshMissionList then
            FIB.RefreshMissionList()
        end
        
        -- Bildirim
        notification.AddLegacy("FIB: Yeni gorev - " .. missionData.name, NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button3.wav")
        
    elseif action == "delete" then
        local missionId = net.ReadFloat()
        
        -- Listeden çıkar
        if FIB.Missions then
            for i = #FIB.Missions, 1, -1 do
                if FIB.Missions[i] and FIB.Missions[i].id == missionId then
                    table.remove(FIB.Missions, i)
                    break
                end
            end
        end
        
        -- UI'ı güncelle
        if FIB.RefreshMissionList then
            FIB.RefreshMissionList()
        end
        
    elseif action == "status_update" then
        local updateData = net.ReadTable()
        
        -- Görevi bul ve güncelle
        if FIB.Missions then
            for _, mission in ipairs(FIB.Missions) do
                if mission.name == updateData.name then
                    mission.status = updateData.status
                    mission.updated_by = updateData.updated_by
                    break
                end
            end
        end
        
        -- UI'ı güncelle
        if FIB.RefreshMissionList then
            FIB.RefreshMissionList()
        end
    end
end)

-- ============================================
-- STARTUP
-- ============================================
hook.Add("InitPostEntity", "FIB_ChatReceiverInit", function()
    print("[FIB CHAT] Chat receiver hazir!")
end)

print("[FIB CHAT] Chat receiver yuklendi! (v2.0 - FIXED)")