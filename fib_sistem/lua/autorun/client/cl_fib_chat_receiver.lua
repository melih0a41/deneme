-- fib_sistem/lua/autorun/client/cl_fib_chat_receiver.lua
-- FIB Chat Receiver

-- Chat mesajı alındığında
net.Receive("FIB_ReceiveChatMessage", function()
    local msgData = net.ReadTable()
    
    -- Ana menü açıksa ve iletişim sekmesindeyse mesajı ekle
    if FIB.AddChatMessage then
        FIB.AddChatMessage(
            msgData.sender,
            msgData.message,
            msgData.rank,
            msgData.time,
            msgData.isUndercover
        )
    end
    
    -- Bildirim sesi (kendi mesajın değilse)
    if msgData.steamid ~= LocalPlayer():SteamID() then
        surface.PlaySound("buttons/button24.wav")
        
        -- Küçük bildirim göster
        notification.AddLegacy("FIB: Yeni mesaj - " .. msgData.sender, NOTIFY_GENERIC, 3)
    end
end)

-- Chat geçmişi alındığında
net.Receive("FIB_ChatHistory", function()
    local messages = net.ReadTable()
    
    print("[FIB CHAT] Chat gecmisi alindi: " .. #messages .. " mesaj")
    
    -- Önce mevcut mesajları temizle
    if IsValid(FIB.ChatContent) then
        FIB.ChatContent:Clear()
        FIB.ChatContent:SetTall(0)
    end
    
    -- Mesajları ekle
    for _, msgData in ipairs(messages) do
        if FIB.AddChatMessage then
            FIB.AddChatMessage(
                msgData.sender,
                msgData.message,
                msgData.rank,
                msgData.time,
                msgData.isUndercover
            )
        end
    end
end)

print("[FIB CHAT] Chat receiver yuklendi!")