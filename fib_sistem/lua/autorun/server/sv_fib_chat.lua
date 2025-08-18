-- fib_sistem/lua/autorun/server/sv_fib_chat.lua
-- FIB Kalıcı Chat Sistemi - FIXED v2.0

-- Network strings
util.AddNetworkString("FIB_SendChatMessage")
util.AddNetworkString("FIB_ReceiveChatMessage")
util.AddNetworkString("FIB_RequestChatHistory")
util.AddNetworkString("FIB_ChatHistory")
util.AddNetworkString("FIB_ClearChat")

-- Chat geçmişi
FIB = FIB or {}
FIB.ChatHistory = FIB.ChatHistory or {}

-- Data klasörü kontrolü
if not file.IsDir("fib_data", "DATA") then
    file.CreateDir("fib_data")
end

-- Data dosyası
local CHAT_FILE = "fib_data/chat_history.json"

-- Rate limiting için
local chatRateLimit = {}

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
        local success, data = pcall(util.JSONToTable, jsonData)
        if success and data and data.messages then
            FIB.ChatHistory = data.messages
            print("[FIB CHAT] Chat gecmisi yuklendi: " .. #FIB.ChatHistory .. " mesaj")
            
            -- Eski mesajları temizle (30 günden eski)
            local currentTime = os.time()
            local cleaned = {}
            for _, msg in ipairs(FIB.ChatHistory) do
                if msg.timestamp and (currentTime - msg.timestamp) < (30 * 24 * 60 * 60) then
                    table.insert(cleaned, msg)
                end
            end
            
            if #cleaned < #FIB.ChatHistory then
                FIB.ChatHistory = cleaned
                FIB.SaveChatHistory()
                print("[FIB CHAT] " .. (#FIB.ChatHistory - #cleaned) .. " eski mesaj temizlendi")
            end
        else
            print("[FIB CHAT] Chat verisi bozuk, sifirlaniyor...")
            FIB.ChatHistory = {}
            FIB.SaveChatHistory()
        end
    end
end

-- ============================================
-- CHAT GEÇMİŞİNİ KAYDET
-- ============================================
function FIB.SaveChatHistory()
    local data = {
        version = "2.0",
        last_save = os.time(),
        messages = FIB.ChatHistory
    }
    
    local success, jsonData = pcall(util.TableToJSON, data, true)
    if success then
        file.Write(CHAT_FILE, jsonData)
        -- print("[FIB CHAT] Chat gecmisi kaydedildi: " .. #FIB.ChatHistory .. " mesaj")
    else
        print("[FIB CHAT] HATA: Chat gecmisi kaydedilemedi!")
    end
end

-- ============================================
-- MESAJ GÖNDERME - FIXED
-- ============================================
net.Receive("FIB_SendChatMessage", function(len, ply)
    -- Güvenlik kontrolleri
    if not IsValid(ply) then return end
    if not ply.FIBAuthenticated then
        print("[FIB CHAT] Yetkisiz mesaj gondermesi: " .. ply:Nick())
        return
    end
    
    -- Rate limiting (1 saniyede max 3 mesaj)
    local steamid = ply:SteamID()
    chatRateLimit[steamid] = chatRateLimit[steamid] or {count = 0, time = 0}
    
    if chatRateLimit[steamid].time > CurTime() - 1 then
        chatRateLimit[steamid].count = chatRateLimit[steamid].count + 1
        if chatRateLimit[steamid].count > 3 then
            ply:ChatPrint("[FIB] Cok hizli mesaj gonderiyorsunuz!")
            return
        end
    else
        chatRateLimit[steamid] = {count = 1, time = CurTime()}
    end
    
    -- Mesajı al ve kontrol et
    local message = net.ReadString()
    
    -- Boş mesaj kontrolü
    if not message or message == "" or string.Trim(message) == "" then
        return
    end
    
    -- Mesaj uzunluk limiti (500 karakter)
    if #message > 500 then
        message = string.sub(message, 1, 497) .. "..."
    end
    
    -- XSS koruması - basit HTML temizleme
    message = string.gsub(message, "<", "&lt;")
    message = string.gsub(message, ">", "&gt;")
    
    -- Mesaj verisi oluştur
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
    
    -- Max 500 mesaj tut (performans için)
    while #FIB.ChatHistory > 500 do
        table.remove(FIB.ChatHistory, 1)
    end
    
    -- Asenkron kaydet (performans için)
    timer.Create("FIB_SaveChatHistory", 2, 1, function()
        FIB.SaveChatHistory()
    end)
    
    -- TÜM FIB AJANLARINA GÖNDER - DÜZELTME
    local sentCount = 0
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v.FIBAuthenticated then
            net.Start("FIB_ReceiveChatMessage")
            net.WriteTable(msgData)
            net.Send(v)
            sentCount = sentCount + 1
        end
    end
    
    print("[FIB CHAT] " .. ply:Nick() .. ": " .. message .. " (" .. sentCount .. " ajana gonderildi)")
    
    -- Log
    ServerLog("[FIB-CHAT] " .. ply:Nick() .. " (" .. ply.FIBRank .. "): " .. message .. "\n")
end)

-- ============================================
-- CHAT GEÇMİŞİ İSTEĞİ
-- ============================================
net.Receive("FIB_RequestChatHistory", function(len, ply)
    if not IsValid(ply) or not ply.FIBAuthenticated then
        return
    end
    
    print("[FIB CHAT] " .. ply:Nick() .. " chat gecmisi istedi")
    
    -- Son 50 mesajı gönder (fazla yükleme olmasın)
    local recentMessages = {}
    local startIndex = math.max(1, #FIB.ChatHistory - 50)
    
    for i = startIndex, #FIB.ChatHistory do
        if FIB.ChatHistory[i] then
            table.insert(recentMessages, FIB.ChatHistory[i])
        end
    end
    
    net.Start("FIB_ChatHistory")
    net.WriteTable(recentMessages)
    net.Send(ply)
    
    print("[FIB CHAT] " .. #recentMessages .. " mesaj gonderildi")
end)

-- ============================================
-- CHAT TEMİZLEME (SADECE ŞEF)
-- ============================================
net.Receive("FIB_ClearChat", function(len, ply)
    if not IsValid(ply) or not ply.FIBAuthenticated or ply.FIBRank ~= "Sef" then
        print("[FIB CHAT] Yetkisiz temizleme denemesi: " .. (IsValid(ply) and ply:Nick() or "Unknown"))
        return
    end
    
    print("[FIB CHAT] " .. ply:Nick() .. " sohbet gecmisini temizledi")
    
    -- Geçmişi temizle
    FIB.ChatHistory = {}
    
    -- Hemen kaydet
    FIB.SaveChatHistory()
    
    -- Tüm FIB ajanlarına temizleme mesajı gönder
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v.FIBAuthenticated then
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

-- Server tam yüklendiğinde
hook.Add("InitPostEntity", "FIB_ChatPostInit", function()
    timer.Simple(1, function()
        FIB.LoadChatHistory()
    end)
end)

-- ============================================
-- OTOMATIK KAYDETME
-- ============================================
timer.Create("FIB_AutoSaveChat", 30, 0, function()
    if #FIB.ChatHistory > 0 then
        FIB.SaveChatHistory()
    end
end)

-- ============================================
-- CLEANUP
-- ============================================
hook.Add("ShutDown", "FIB_SaveChatOnShutdown", function()
    FIB.SaveChatHistory()
end)

print("[FIB CHAT] Kalici sohbet sistemi yuklendi! (v2.0 - FIXED)")