-- fib_sistem/lua/autorun/server/sv_fib_chat.lua
-- FIB Kalıcı Chat Sistemi

-- Network strings
util.AddNetworkString("FIB_SendChatMessage")
util.AddNetworkString("FIB_ReceiveChatMessage")
util.AddNetworkString("FIB_RequestChatHistory")
util.AddNetworkString("FIB_ChatHistory")
util.AddNetworkString("FIB_ClearChat")

-- Chat geçmişi
FIB = FIB or {}
FIB.ChatHistory = FIB.ChatHistory or {}

-- Data dosyası
local CHAT_FILE = "fib_data/chat_history.json"

-- ============================================
-- CHAT GEÇMİŞİNİ YÜKLE
-- ============================================
function FIB.LoadChatHistory()
    if not file.Exists(CHAT_FILE, "DATA") then
        print("[FIB CHAT] Chat gecmisi dosyasi bulunamadi, yeni olusturuluyor...")
        FIB.ChatHistory = {}
        FIB.SaveChatHistory()
        return
    end
    
    local jsonData = file.Read(CHAT_FILE, "DATA")
    if jsonData then
        local data = util.JSONToTable(jsonData)
        if data and data.messages then
            FIB.ChatHistory = data.messages
            print("[FIB CHAT] Chat gecmisi yuklendi: " .. #FIB.ChatHistory .. " mesaj")
            
            -- Eski mesajları temizle (30 günden eski)
            local currentTime = os.time()
            local cleaned = {}
            for _, msg in ipairs(FIB.ChatHistory) do
                if (currentTime - msg.timestamp) < (30 * 24 * 60 * 60) then
                    table.insert(cleaned, msg)
                end
            end
            FIB.ChatHistory = cleaned
        end
    end
end

-- ============================================
-- CHAT GEÇMİŞİNİ KAYDET
-- ============================================
function FIB.SaveChatHistory()
    local data = {
        version = "1.0",
        last_save = os.time(),
        messages = FIB.ChatHistory
    }
    
    local jsonData = util.TableToJSON(data, true)
    file.Write(CHAT_FILE, jsonData)
    
    print("[FIB CHAT] Chat gecmisi kaydedildi: " .. #FIB.ChatHistory .. " mesaj")
end

-- ============================================
-- MESAJ GÖNDERME
-- ============================================
net.Receive("FIB_SendChatMessage", function(len, ply)
    if not ply.FIBAuthenticated then
        print("[FIB CHAT] Yetkisiz mesaj gondermesi: " .. ply:Nick())
        return
    end
    
    local message = net.ReadString()
    
    -- Boş mesaj kontrolü
    if message == "" or string.Trim(message) == "" then
        return
    end
    
    -- Mesaj uzunluk limiti (500 karakter)
    if #message > 500 then
        message = string.sub(message, 1, 500)
    end
    
    -- Mesaj verisi
    local msgData = {
        sender = ply:Nick(),
        steamid = ply:SteamID(),
        message = message,
        rank = ply.FIBRank or "Ajan",
        isUndercover = ply.FIBUndercover or false,
        timestamp = os.time(),
        time = os.date("%H:%M")
    }
    
    -- Geçmişe ekle
    table.insert(FIB.ChatHistory, msgData)
    
    -- Max 500 mesaj tut
    if #FIB.ChatHistory > 500 then
        table.remove(FIB.ChatHistory, 1)
    end
    
    -- Kaydet
    FIB.SaveChatHistory()
    
    -- Tüm FIB ajanlarına gönder
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            net.Start("FIB_ReceiveChatMessage")
            net.WriteTable(msgData)
            net.Send(v)
        end
    end
    
    -- Log
    ServerLog("[FIB-CHAT] " .. ply:Nick() .. " (" .. ply.FIBRank .. "): " .. message .. "\n")
end)

-- ============================================
-- CHAT GEÇMİŞİ İSTEĞİ
-- ============================================
net.Receive("FIB_RequestChatHistory", function(len, ply)
    if not ply.FIBAuthenticated then
        return
    end
    
    print("[FIB CHAT] " .. ply:Nick() .. " chat gecmisi istedi")
    
    -- Son 50 mesajı gönder (fazla yükleme olmasın)
    local recentMessages = {}
    local startIndex = math.max(1, #FIB.ChatHistory - 50)
    
    for i = startIndex, #FIB.ChatHistory do
        table.insert(recentMessages, FIB.ChatHistory[i])
    end
    
    net.Start("FIB_ChatHistory")
    net.WriteTable(recentMessages)
    net.Send(ply)
end)

-- ============================================
-- CHAT TEMİZLEME (SADECE ŞEF)
-- ============================================
net.Receive("FIB_ClearChat", function(len, ply)
    if not ply.FIBAuthenticated or ply.FIBRank ~= "Sef" then
        print("[FIB CHAT] Yetkisiz temizleme denemesi: " .. ply:Nick())
        return
    end
    
    print("[FIB CHAT] " .. ply:Nick() .. " sohbet gecmisini temizledi")
    
    -- Geçmişi temizle
    FIB.ChatHistory = {}
    
    -- Kaydet
    FIB.SaveChatHistory()
    
    -- Tüm FIB ajanlarına temizleme mesajı gönder
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            v:ChatPrint("[FIB] Sohbet gecmisi " .. ply:Nick() .. " tarafindan temizlendi")
            
            -- Client'ta da temizlet
            net.Start("FIB_ChatHistory")
            net.WriteTable({})
            net.Send(v)
        end
    end
    
    -- Log
    ServerLog("[FIB-CHAT] Sohbet gecmisi temizlendi - " .. ply:Nick() .. "\n")
end)

-- ============================================
-- STARTUP
-- ============================================
hook.Add("Initialize", "FIB_ChatInit", function()
    timer.Simple(2, function()
        FIB.LoadChatHistory()
    end)
end)

-- ============================================
-- OTOMATIK KAYDETME
-- ============================================
timer.Create("FIB_AutoSaveChat", 60, 0, function()
    if #FIB.ChatHistory > 0 then
        FIB.SaveChatHistory()
    end
end)

print("[FIB CHAT] Kalici sohbet sistemi yuklendi!")