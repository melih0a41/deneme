--[[
=======================================================
ÖNEMLİ: SUNUCU KODU GEREKLİ!
=======================================================
DeepWeb'in çalışması için MUTLAKA aşağıdaki kodu sunucuya ekleyin:

DOSYA: garrysmod/lua/autorun/server/sv_deepweb.lua

-- BAŞLANGIÇ --
util.AddNetworkString("aphone_deepweb_user_join")
util.AddNetworkString("aphone_deepweb_user_leave")
util.AddNetworkString("aphone_deepweb_active_users")
util.AddNetworkString("aphone_deepweb_message")
util.AddNetworkString("aphone_deepweb_sync")

DEEPWEB_ACTIVE_USERS = DEEPWEB_ACTIVE_USERS or {}

net.Receive("aphone_deepweb_user_join", function(len, ply)
    local username = net.ReadString()
    DEEPWEB_ACTIVE_USERS[ply:SteamID()] = username
    
    net.Start("aphone_deepweb_active_users")
        net.WriteUInt(table.Count(DEEPWEB_ACTIVE_USERS), 8)
        for sid, uname in pairs(DEEPWEB_ACTIVE_USERS) do
            net.WriteString(sid)
            net.WriteString(uname)
        end
    net.Broadcast()
end)

net.Receive("aphone_deepweb_user_leave", function(len, ply)
    DEEPWEB_ACTIVE_USERS[ply:SteamID()] = nil
    
    net.Start("aphone_deepweb_active_users")
        net.WriteUInt(table.Count(DEEPWEB_ACTIVE_USERS), 8)
        for sid, uname in pairs(DEEPWEB_ACTIVE_USERS) do
            net.WriteString(sid)
            net.WriteString(uname)
        end
    net.Broadcast()
end)

net.Receive("aphone_deepweb_message", function(len, ply)
    local username = net.ReadString()
    local message = net.ReadString()
    
    net.Start("aphone_deepweb_sync")
        net.WriteString(username)
        net.WriteString(message)
    net.Broadcast()
end)

hook.Add("PlayerDisconnected", "DeepWebCleanup", function(ply)
    if DEEPWEB_ACTIVE_USERS[ply:SteamID()] then
        DEEPWEB_ACTIVE_USERS[ply:SteamID()] = nil
        
        net.Start("aphone_deepweb_active_users")
            net.WriteUInt(table.Count(DEEPWEB_ACTIVE_USERS), 8)
            for sid, uname in pairs(DEEPWEB_ACTIVE_USERS) do
                net.WriteString(sid)
                net.WriteString(uname)
            end
        net.Broadcast()
    end
end)
-- BİTİŞ --

HIZLI KURULUM (Konsol):
lua_run_sv util.AddNetworkString("aphone_deepweb_user_join") util.AddNetworkString("aphone_deepweb_user_leave") util.AddNetworkString("aphone_deepweb_active_users") util.AddNetworkString("aphone_deepweb_message") util.AddNetworkString("aphone_deepweb_sync")
=======================================================

=======================================================
CLIENT KURULUM TALİMATLARI
=======================================================
DeepWeb'in telefonda görünmesi için:

DOSYA YOLU: garrysmod/lua/autorun/client/cl_deepweb_autoload.lua

hook.Add("InitPostEntity", "LoadDeepWebApp", function()
    timer.Simple(10, function()
        include("aphone/apps/deepweb/cl_main.lua")
        print("[DeepWeb] Autorun ile yuklendi!")
    end)
end)

VEYA konsola: lua_openscript_cl aphone/apps/deepweb/cl_main.lua
=======================================================
]]

-- aPhone kontrolü
if not aphone then
    print("[DeepWeb] HATA: aPhone bulunamadi! 5 saniye sonra tekrar denenecek...")
    timer.Simple(5, function()
        if aphone then
            include("aphone/apps/deepweb/cl_main.lua")
        else
            print("[DeepWeb] HATA: aPhone hala yuklu degil!")
        end
    end)
    return
end

local APP = {}

APP.name = "DeepWeb"
APP.desc = "Access the underground network"
APP.category = "Tools"
APP.author = "Anonymous"
APP.version = "1.0"
APP.icon = "icon16/application_xp_terminal.png" -- Varsayılan icon
APP.enabled = true

-- aPhone'un isteyebileceği alternatif parametreler
APP.description = APP.desc
APP.Name = APP.name -- Büyük harfle de deneyelim
APP.Icon = APP.icon

-- Network sistemi - Sadece online modda çalışır
NETWORK_ENABLED = true

-- IMGUR ICON YÜKLEME
local iconURL = "https://i.imgur.com/04HVC9Z.png" -- DeepWeb logo URL'nizi buraya koyun
local iconPath = "deepweb_icon_" .. util.CRC(iconURL) .. ".png"

-- Icon'u yükle veya cache'den al
timer.Simple(2, function()
    -- Cache kontrolü
    if file.Exists(iconPath, "DATA") then
        print("[DeepWeb] Icon cache'den yukleniyor...")
        
        -- Material oluştur
        local mat = Material("data/" .. iconPath, "noclamp smooth")
        
        -- APP'e ve aPhone'a ata
        if not mat:IsError() then
            APP.icon = mat
            APP.Icon = mat
            
            if aphone and aphone.Apps and aphone.Apps["DeepWeb"] then
                aphone.Apps["DeepWeb"].icon = mat
                aphone.Apps["DeepWeb"].Icon = mat
                print("[DeepWeb] Imgur icon cache'den yuklendi!")
            end
        end
    else
        -- Imgur'dan indir
        print("[DeepWeb] Imgur'dan icon indiriliyor...")
        
        http.Fetch(iconURL, 
            function(body, size, headers, code)
                -- Başarılı indirme
                print("[DeepWeb] Icon indirildi, boyut: " .. size .. " bytes")
                
                -- Dosyaya kaydet
                file.Write(iconPath, body)
                
                -- Material oluştur
                timer.Simple(0.1, function()
                    local mat = Material("data/" .. iconPath, "noclamp smooth")
                    
                    if not mat:IsError() then
                        APP.icon = mat
                        APP.Icon = mat
                        
                        -- aPhone'a güncelle
                        if aphone and aphone.Apps and aphone.Apps["DeepWeb"] then
                            aphone.Apps["DeepWeb"].icon = mat
                            aphone.Apps["DeepWeb"].Icon = mat
                            print("[DeepWeb] Imgur icon basariyla yuklendi!")
                        end
                    else
                        print("[DeepWeb] Material olusturma hatasi!")
                    end
                end)
            end,
            function(error)
                -- İndirme hatası
                print("[DeepWeb] Icon indirme hatasi: " .. error)
            end
        )
    end
end)

-- Alternatif: Base64 icon (daha güvenilir)
-- APP.iconBase64 = "data:image/png;base64,..." -- Base64 kodunu buraya yapıştırın

-- Debug mesajı
print("[DeepWeb] Uygulama tanimlandi: " .. APP.name)
print("[DeepWeb] Online mod aktif - Sunucu kodu gerekli!")

-- Network string kontrolü
timer.Simple(1, function()
    if util.NetworkStringToID then
        local hasStrings = util.NetworkStringToID("aphone_deepweb_message") ~= 0
        if hasStrings then
            print("[DeepWeb] ✓ Network string'ler bulundu - Sunucu kodu yuklu!")
        else
            print("[DeepWeb] ✗ Network string'ler BULUNAMADI! Sunucu kodunu ekleyin!")
            print("[DeepWeb] Hizli cozum: lua_run_sv util.AddNetworkString(\"aphone_deepweb_message\") util.AddNetworkString(\"aphone_deepweb_sync\") util.AddNetworkString(\"aphone_deepweb_user_join\") util.AddNetworkString(\"aphone_deepweb_user_leave\") util.AddNetworkString(\"aphone_deepweb_active_users\")")
        end
    end
end)



-- Illegal job'lar - sadece bunlar girebilir
local ALLOWED_JOBS = {
    ["thief"] = true,
    ["drug dealer"] = true,
    ["mafya"] = true,
    ["mafia"] = true,
    ["gun dealer"] = true,
    ["hirsiz"] = true,
    ["uyusturucu saticisi"] = true,
    ["silah kacakcisi"] = true,
    ["kacakci"] = true,
    ["gangster"] = true,
    ["vatandaş"] = true, -- TEST İÇİN EKLENDİ
    ["citizen"] = true, -- TEST İÇİN EKLENDİ
}

-- Yasaklı job'lar - bunlar giremez
local BLOCKED_JOBS = {
    ["police"] = true,
    ["cop"] = true,
    ["swat"] = true,
    ["fbi"] = true,
    ["government"] = true,
    ["mayor"] = true,
    ["polis"] = true,
    ["devlet"] = true,
    ["asker"] = true
}

-- Renk teması - MODERN HACKER (TÜM RENKLER TANIMLI)
local COLORS = {
    bg = Color(8, 8, 12), -- Çok koyu mavi-siyah
    terminal = Color(12, 15, 20), -- Terminal arka plan
    accent = Color(0, 255, 150), -- Neon yeşil (ana renk)
    secondary = Color(0, 200, 255), -- Siber mavi
    danger = Color(255, 80, 80), -- Neon kırmızı
    warning = Color(255, 200, 0), -- Neon sarı
    purple = Color(150, 0, 255), -- Neon mor
    gray = Color(80, 90, 100), -- Soğuk gri
    white = Color(240, 245, 255), -- Soğuk beyaz
    shadow = Color(0, 0, 0, 180), -- Derin gölge
    -- Eksik renkler eklendi
    green = Color(0, 255, 150), -- Neon yeşil (accent ile aynı)
    orange = Color(255, 150, 0), -- Neon turuncu
    red = Color(255, 80, 80) -- Neon kırmızı (danger ile aynı)
}

-- Chat geçmişi için global değişken
if not DEEPWEB_CHAT_HISTORY then
    DEEPWEB_CHAT_HISTORY = {}
end

-- Anonymous isimler - GLOBAL
if not ANONYMOUS_NAMES then
    ANONYMOUS_NAMES = {
        -- Orijinal isimler
        "Anonymous_001", "DarkHacker", "ShadowUser", "CryptoKing", 
        "BlackMarket", "DeepTrader", "PhantomUser", "GhostDealer",
        "CyberCriminal", "DarkLord", "SilentKiller", "BloodMoney",
        "UndergroundBoss", "SecretAgent", "NightCrawler", "DeathDealer",
        
        -- Yeni eklenen isimler (50+ isim)
        "ZeroDay", "DarkPhantom", "CyberGhost", "RedSkull", "BlackWidow",
        "ShadowByte", "DeepThroat", "DarkNet", "CryptoPhantom", "NightShade",
        "VirusKing", "HackerElite", "DarkCoder", "ByteBandit", "CyberNinja",
        "PhantomHawk", "SilentStorm", "BlackHat", "WhiteHat", "GrayHat",
        "DeepShadow", "CyberWolf", "DarkFox", "NightOwl", "ShadowEagle",
        "Anonymous_666", "DevilTrader", "HellRaiser", "DemonKing", "SoulReaper",
        "DarkAngel", "FallenOne", "AbyssWalker", "VoidMaster", "ChaosLord",
        "ByteKiller", "DataThief", "InfoBroker", "DarkOracle", "CyberPunk",
        "NeonGhost", "DigitalNinja", "MatrixKing", "CodeBreaker", "SystemCrash",
        "FirewallKiller", "ProxyMaster", "TorGhost", "VPNKing", "DarkRouter",
        "BinaryBeast", "HexHacker", "RootAdmin", "ShellShock", "BackdoorMan",
        "TrojanMaster", "WormKing", "MalwareLord", "ExploitGod", "ZeroCool",
        "AcidBurn", "CrashOverride", "LordNikon", "PhreakShow", "DarkMatter",
        "QuantumThief", "NeuralHack", "SynapseBreak", "MindBender", "PsychoHack",
        "RogueAI", "GhostProtocol", "StealthMode", "InvisibleMan", "ShadowClone",
        "DarkEnergy", "VoidRunner", "NullPointer", "SegFault", "CoreDump",
        "Anonymous_404", "Error404", "Access_Denied", "Forbidden_403", "NotFound",
        "ServerDown", "TimeoutError", "BufferOverflow", "StackSmash", "HeapSpray"
    }
end

-- Aktif kullanıcılar için global tablo
if not DEEPWEB_ACTIVE_USERS then
    DEEPWEB_ACTIVE_USERS = {}
end

-- Kullanıcının mevcut ismi
local MY_DEEPWEB_NAME = nil

-- Mesaj ekleme fonksiyonu
local function AddMessageToHistory(username, message)
    table.insert(DEEPWEB_CHAT_HISTORY, {
        username = username,
        message = message,
        time = CurTime()
    })
    
    -- Maksimum 50 mesaj tut (performans için)
    if #DEEPWEB_CHAT_HISTORY > 50 then
        table.remove(DEEPWEB_CHAT_HISTORY, 1)
    end
end

-- Kullanılmayan random isim seç
local function GetAvailableRandomName()
    -- Kullanılmayan isimleri bul
    local availableNames = {}
    for _, name in ipairs(ANONYMOUS_NAMES) do
        local isUsed = false
        for _, usedName in pairs(DEEPWEB_ACTIVE_USERS) do
            if name == usedName then
                isUsed = true
                break
            end
        end
        if not isUsed then
            table.insert(availableNames, name)
        end
    end
    
    -- Eğer boş isim kaldıysa random seç
    if #availableNames > 0 then
        return availableNames[math.random(1, #availableNames)]
    else
        -- Tüm isimler doluysa daha unique isimler oluştur
        local prefixes = {"Dark", "Shadow", "Cyber", "Ghost", "Night", "Black", "Deep", "Silent", "Phantom", "Crypto"}
        local suffixes = {"Killer", "Master", "Lord", "King", "Elite", "Pro", "God", "Boss", "Ninja", "Wolf"}
        local prefix = prefixes[math.random(1, #prefixes)]
        local suffix = suffixes[math.random(1, #suffixes)]
        return prefix .. suffix .. "_" .. math.random(100, 999)
    end
end

-- Chat geçmişini yükle
local function LoadChatHistory(chat_scroll)
    if not IsValid(chat_scroll) then return end
    
    for i, msg_data in ipairs(DEEPWEB_CHAT_HISTORY) do
        -- Mesaj uzunluğuna göre panel boyutu hesapla
        surface.SetFont("DermaLarge")
        local textW, textH = surface.GetTextSize(msg_data.message)
        local panelWidth = chat_scroll:GetWide() - 20
        local lineCount = math.ceil(textW / panelWidth) + 1
        local panelHeight = math.max(60, lineCount * 25 + 35)
        
        -- Mesaj paneli oluştur
        local msg_panel = vgui.Create("DPanel", chat_scroll)
        msg_panel:Dock(TOP)
        msg_panel:SetTall(panelHeight)
        msg_panel:DockMargin(3, 3, 3, 3)
        msg_panel:SetCursor("blank") -- Cursor'u gizle
        
        function msg_panel:Paint(w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 255))
            surface.SetDrawColor(COLORS.green)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        
        -- Kullanıcı adı
        local username = vgui.Create("DLabel", msg_panel)
        username:Dock(TOP)
        username:SetTall(25)
        username:SetText(msg_data.username)
        username:SetTextColor(COLORS.orange)
        username:SetFont("DermaLarge")
        username:SetCursor("blank") -- Cursor'u gizle
        
        -- Mesaj içeriği
        local msg_content = vgui.Create("DLabel", msg_panel)
        msg_content:Dock(FILL)
        msg_content:SetText(msg_data.message)
        msg_content:SetTextColor(COLORS.white)
        msg_content:SetFont("DermaLarge")
        msg_content:SetWrap(true)
        msg_content:SetAutoStretchVertical(true)
        msg_content:DockMargin(5, 5, 5, 5)
        msg_content:SetCursor("blank") -- Cursor'u gizle
    end
    
    -- Chat'i en alta kaydır
    timer.Simple(0.2, function()
        if IsValid(chat_scroll) then
            chat_scroll:GetVBar():SetScroll(chat_scroll:GetVBar().CanvasSize)
        end
    end)
end

-- Global chat scroll değişkeni
local current_chat_scroll = nil

-- Sunucudan gelen mesajları dinle ve chat'e ekle
if util.NetworkStringToID and util.NetworkStringToID("aphone_deepweb_sync") ~= 0 then
    net.Receive("aphone_deepweb_sync", function()
        local username = net.ReadString()
        local message = net.ReadString()
        
        -- Mesajı geçmişe ekle
        AddMessageToHistory(username, message)
        
        print("[DeepWeb] Sunucudan mesaj alindi: " .. username .. " - " .. message)
        
        -- Eğer DeepWeb açıksa, mesajı görsel olarak da ekle
        if IsValid(current_chat_scroll) then
            -- Mesaj uzunluğuna göre panel boyutu hesapla
            surface.SetFont("DermaLarge")
            local textW, textH = surface.GetTextSize(message)
            local panelWidth = current_chat_scroll:GetWide() - 20
            local lineCount = math.ceil(textW / panelWidth) + 1
            local panelHeight = math.max(60, lineCount * 25 + 35)
            
            -- MESAJI CHAT ALANINA EKLE
            local msg_panel = vgui.Create("DPanel", current_chat_scroll)
            msg_panel:Dock(TOP)
            msg_panel:SetTall(panelHeight)
            msg_panel:DockMargin(3, 3, 3, 3)
            msg_panel:SetCursor("blank") -- Cursor'u gizle
            
            function msg_panel:Paint(w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 255))
                surface.SetDrawColor(COLORS.green)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            -- Kullanıcı adı
            local username_label = vgui.Create("DLabel", msg_panel)
            username_label:Dock(TOP)
            username_label:SetTall(25)
            username_label:SetText(username)
            username_label:SetTextColor(COLORS.orange)
            username_label:SetFont("DermaLarge")
            username_label:SetCursor("blank") -- Cursor'u gizle
            
            -- Mesaj içeriği
            local msg_content = vgui.Create("DLabel", msg_panel)
            msg_content:Dock(FILL)
            msg_content:SetText(message)
            msg_content:SetTextColor(COLORS.white)
            msg_content:SetFont("DermaLarge")
            msg_content:SetWrap(true)
            msg_content:SetAutoStretchVertical(true)
            msg_content:DockMargin(5, 5, 5, 5)
            msg_content:SetCursor("blank") -- Cursor'u gizle
            
            -- Chat'i aşağı kaydır
            timer.Simple(0.1, function()
                if IsValid(current_chat_scroll) then
                    current_chat_scroll:GetVBar():SetScroll(current_chat_scroll:GetVBar().CanvasSize)
                end
            end)
            
            -- Ses efekti (yeni mesaj geldi) - sadece bildirimler açıksa
            if DEEPWEB_NOTIFICATIONS_ENABLED then
                surface.PlaySound("buttons/button16.wav")
            end
        end
    end)
end

-- Aktif kullanıcı listesini güncelle
if util.NetworkStringToID and util.NetworkStringToID("aphone_deepweb_active_users") ~= 0 then
    net.Receive("aphone_deepweb_active_users", function()
        local count = net.ReadUInt(8)
        DEEPWEB_ACTIVE_USERS = {}
        
        for i = 1, count do
            local steamid = net.ReadString()
            local username = net.ReadString()
            DEEPWEB_ACTIVE_USERS[steamid] = username
        end
        
        print("[DeepWeb] Aktif kullanici listesi guncellendi: " .. count .. " kullanici")
        
        -- Status bar güncelleme hook'unu çağır
        hook.Run("DeepWebUsersUpdated")
    end)
end

-- Giriş kontrolü - DARKRP UYUMLU
local function CanAccessDeepWeb(ply)
    if not IsValid(ply) then 
        return false 
    end
    
    -- Farklı job alma yöntemlerini dene
    local job = ""
    
    if ply.getJobTable and ply:getJobTable() then
        job = string.lower(ply:getJobTable().name or "")
    elseif ply.GetUserGroup then
        job = string.lower(ply:GetUserGroup() or "")
    elseif ply.Team then
        job = string.lower(team.GetName(ply:Team()) or "")
    elseif ply.getDarkRPVar then
        job = string.lower(ply:getDarkRPVar("job") or "")
    end
    
    -- Debug - hangi job algılandığını göster
    print("[DeepWeb] Oyuncu: " .. ply:Nick() .. " | Algilanan job: '" .. job .. "'")
    
    -- Yasaklı job kontrolü
    for blocked_job, _ in pairs(BLOCKED_JOBS) do
        if string.find(job, blocked_job) then
            print("[DeepWeb] Engellendi: " .. blocked_job .. " tespit edildi")
            return false, "ERISIM ENGELLENDI - GUVENSIZ UYE - "
        end
    end
    
    -- İzin verilen job kontrolü
    for allowed_job, _ in pairs(ALLOWED_JOBS) do
        if string.find(job, allowed_job) then
            print("[DeepWeb] Izin verildi: " .. allowed_job .. " tespit edildi")
            return true
        end
    end
    
    -- Diğer durumlar
    print("[DeepWeb] Job bulunamadi veya izin verilmedi: " .. job)
    return false, "ACCESS DENIED - INSUFFICIENT CRIMINAL CREDENTIALS"
end

function APP:Open(main, main_x, main_y, screenmode)
    -- Main panel cursor'unu hemen gizle
    main:SetCursor("blank")
    
    -- Debug mesajı
    print("[DeepWeb] APP:Open cagirildi!")
    
    -- Giriş kontrolü
    local canAccess, errorMsg = CanAccessDeepWeb(LocalPlayer())
    
    if not canAccess then
        -- Access Denied ekranı
        function main:Paint(w, h)
            -- Siyah arka plan
            surface.SetDrawColor(COLORS.bg)
            surface.DrawRect(0, 0, w, h)
            
            -- Kırmızı uyarı
            draw.SimpleText("ACCESS DENIED", "DermaLarge", w/2, h/2 - 50, COLORS.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(errorMsg or "YETKISIZ ERISIM", "DermaDefault", w/2, h/2, COLORS.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("SADECE ILLEGALDE KENDINI KANITLAMIS KISILER GIREBILIR", "DermaDefault", w/2, h/2 + 30, COLORS.orange, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Hacker efekti - yanıp sönen text
            if math.sin(CurTime() * 3) > 0 then
                draw.SimpleText("[ KILITLI SISTEM ]", "DermaDefault", w/2, h/2 + 60, COLORS.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        return
    end
    
    -- Unique session ID oluştur
    local sessionID = "DeepWeb_" .. os.time() .. "_" .. math.random(1000, 9999)
    
    -- Kullanıcıya isim ata
    MY_DEEPWEB_NAME = GetAvailableRandomName()
    
    -- Sunucuya kullanıcı girişini bildir (Güvenli)
    timer.Simple(0.1, function()
        -- Network string kontrolü
        local canSend = true
        
        -- Nova Defender bypass
        if util.NetworkStringToID and util.NetworkStringToID("aphone_deepweb_user_join") == 0 then
            canSend = false
            print("[DeepWeb] HATA: Network string'ler tanimli degil! Sunucu kodunu ekleyin.")
            
            -- Ana ekrana hata mesajı ekle
            if IsValid(main) then
                local error_panel = vgui.Create("DPanel", main)
                error_panel:Dock(TOP)
                error_panel:SetTall(30)
                error_panel:DockMargin(5, 5, 5, 5)
                
                function error_panel:Paint(w, h)
                    draw.RoundedBox(4, 0, 0, w, h, COLORS.danger)
                    draw.SimpleText("SUNUCU KODU EKSİK! sv_deepweb.lua dosyasını ekleyin.", "DermaDefault", w/2, h/2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            return
        end
        
        if canSend then
            net.Start("aphone_deepweb_user_join")
                net.WriteString(MY_DEEPWEB_NAME)
            net.SendToServer()
            print("[DeepWeb] Kullanici girisi bildirildi: " .. MY_DEEPWEB_NAME)
        end
    end)
    
    -- Ana tema renkleri
    local green = COLORS.green
    local bg = COLORS.terminal
    local white = COLORS.white
    
    if not screenmode then
        main:Phone_DrawTop(main_x, main_y, false)
    end

    -- Terminal arka plan - MODERN CYBER
    function main:Paint(w, h)
        -- ÜST GRADIENT ARKA PLAN - DEEPWEB STYLE
        -- Neon yeşil gradient (Twitter tarzı ama hacker temalı)
        for i = 0, h/7 do
            local alpha = 255 - (i * 1800 / h)
            surface.SetDrawColor(0, 255 - (i*2), 150 - i, math.max(alpha, 200))
            surface.DrawRect(0, i, w, 1)
        end
        
        -- Üst header için koyu alan
        surface.SetDrawColor(0, 30, 20, 240)
        surface.DrawRect(0, 0, w, h/9)
        
        -- Neon çizgi
        surface.SetDrawColor(0, 255, 150, 255)
        surface.DrawRect(0, h/9, w, 2)
        
        -- Glow efekti
        for i = 1, 10 do
            surface.SetDrawColor(0, 255, 150, 20 - i*2)
            surface.DrawRect(0, h/9 + i, w, 1)
        end
        
        -- ALT KISIM İÇİN ARKA PLAN
        -- Gradient arka plan (koyu mavi-siyah)
        for i = h/7, h, 2 do
            local alpha = math.sin((i-h/7) * 0.01 + CurTime() * 0.5) * 10 + 20
            surface.SetDrawColor(8, 8, 12 + alpha * 0.3, 255)
            surface.DrawRect(0, i, w, 2)
        end
        
        -- HACKER ASCII ART - Arka planda soluk görünen
        if math.sin(CurTime() * 0.5) > 0.7 then
            -- Anonymous maske
            local asciiArt = {
                "    ╔═══════════╗",
                "    ║  ◉     ◉  ║",
                "    ║      <     ║", 
                "    ║    ___    ║",
                "    ╚═══════════╝"
            }
            
            local yPos = h/2 - 50
            for _, line in ipairs(asciiArt) do
                draw.SimpleText(line, "DermaDefault", w/2, yPos, Color(0, 255, 150, 30), TEXT_ALIGN_CENTER)
                yPos = yPos + 12
            end
        end
        
        -- Matrix yağmuru efekti
        if math.random(1, 5) == 1 then
            local chars = "01"
            local x = math.random(0, w/10) * 10
            local char = string.sub(chars, math.random(1, #chars), math.random(1, #chars))
            
            for i = 0, h, 15 do
                local alpha = 255 - (i * 255 / h)
                draw.SimpleText(char, "DefaultSmall", x, i, Color(0, 255, 150, alpha * 0.3), TEXT_ALIGN_CENTER)
            end
        end
        
        -- Hacker terminal text (arka planda)
        local hackerTexts = {
            "root@darknet:~# access_granted",
            "Connecting to TOR network...",
            "[OK] Anonymous session started",
            ">>> DEEP_WEB_ACCESS <<<",
            "Bypassing firewall...",
            "Encryption: AES-256"
        }
        
        if math.random(1, 100) == 1 then
            local text = hackerTexts[math.random(1, #hackerTexts)]
            local x = math.random(10, w-100)
            local y = math.random(h/7 + 20, h-20)
            draw.SimpleText(text, "DefaultSmall", x, y, Color(0, 255, 150, 50), TEXT_ALIGN_LEFT)
        end
        
        -- Scan line efekti
        local scanY = (CurTime() * 100) % h
        surface.SetDrawColor(0, 255, 150, 30)
        surface.DrawRect(0, scanY, w, 2)
    end

    -- Header - CYBER GLOW
    local header = vgui.Create("DLabel", main)
    header:Dock(TOP)
    header:SetTall(45)
    header:SetText(">> DEEP_WEB.EXE <<")
    header:SetFont("DermaLarge")
    header:SetTextColor(COLORS.white)
    header:SetContentAlignment(5)
    header:SetCursor("blank") -- Cursor'u gizle
    
    function header:Paint(w, h)
        -- Boş bırakıldı, text gradient üzerinde görünecek
    end

    -- Status bar - CYBER STATUS
    local status = vgui.Create("DLabel", main)
    status:Dock(TOP)
    status:SetTall(25)
    status:SetText("STATUS: [CONNECTING...] | USER: " .. MY_DEEPWEB_NAME)
    status:SetFont("DefaultSmall")
    status:SetTextColor(COLORS.secondary)
    status:SetContentAlignment(4)
    status:SetCursor("blank") -- Cursor'u gizle
    
    -- Status bar güncelleme fonksiyonu
    local function UpdateStatusBar()
        if IsValid(status) then
            local count = math.max(1, table.Count(DEEPWEB_ACTIVE_USERS))
            status:SetText("STATUS: [ENCRYPTED] | USER: " .. MY_DEEPWEB_NAME .. " | ONLINE: " .. count)
            status:SetTextColor(COLORS.secondary)
        end
    end
    
    -- İlk güncelleme için kısa bir gecikme
    timer.Simple(0.2, UpdateStatusBar)
    
    -- Aktif kullanıcı listesi güncellendiğinde status bar'ı güncelle
    hook.Add("DeepWebUsersUpdated", sessionID, UpdateStatusBar)
    
    -- OnClose için sessionID'yi sakla
    main.deepwebSessionID = sessionID
    
    function status:Paint(w, h)
        -- Koyu arka plan
        draw.RoundedBox(0, 0, 0, w, h, Color(5, 8, 15, 200))
        
        -- Alt çizgi - data stream efekti
        local streamPos = (CurTime() * 50) % w
        surface.SetDrawColor(COLORS.accent)
        surface.DrawRect(streamPos, h-2, 20, 2)
        surface.SetDrawColor(0, 255, 150, 100)
        surface.DrawRect(streamPos + 20, h-2, 10, 2)
    end

-- BİLDİRİM TOGGLE BUTONU
if not DEEPWEB_NOTIFICATIONS_ENABLED then
    DEEPWEB_NOTIFICATIONS_ENABLED = true
end

    -- PNG ikonları yükle
    local currentMap = game.GetMap()
    local bell_on, bell_off

    if currentMap == "rp_downtown_baso" then
        bell_on = Material("icons/bell_on.png", "smooth")
        bell_off = Material("icons/bell_off.png", "smooth")
        
        if bell_on:IsError() or bell_off:IsError() then
            print("[DeepWeb] PNG ikonlar bulunamadi, varsayilan kullanilacak")
            bell_on = Material("icon16/tick.png", "smooth")
            bell_off = Material("icon16/cross.png", "smooth")
        end
    else
        bell_on = Material("icon16/tick.png", "smooth")
        bell_off = Material("icon16/cross.png", "smooth")
    end

    local notif_toggle = vgui.Create("DButton", main) -- DPanel yerine DButton
    notif_toggle:SetSize(80, 80)
    notif_toggle:SetZPos(1000)
    notif_toggle.isEnabled = GetConVar("aphone_deepweb_notifications") and GetConVar("aphone_deepweb_notifications"):GetBool() or true
    notif_toggle:SetText("")
    notif_toggle:SetCursor("blank") -- Cursor'u gizle

    timer.Simple(0.1, function()
        if IsValid(notif_toggle) and IsValid(main) then
            notif_toggle:SetPos(main:GetWide() - 90, 45)
        end
    end)

    function notif_toggle:Paint(w, h)
        local isEnabled = self.isEnabled
        
        -- PNG ikon çiz
        local iconMat = isEnabled and bell_on or bell_off
        
        if iconMat and not iconMat:IsError() then
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(iconMat)
            surface.DrawTexturedRect(0, 0, w, h)
        else
            -- PNG yüklenemezse text göster
            draw.RoundedBox(4, 0, 0, w, h, COLORS.terminal)
            draw.SimpleText(isEnabled and "[ON]" or "[OFF]", "DefaultSmall", w/2, h/2, isEnabled and COLORS.accent or COLORS.danger, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

function notif_toggle:DoClick()
    self.isEnabled = not self.isEnabled
    DEEPWEB_NOTIFICATIONS_ENABLED = self.isEnabled
    
    -- SADECE BU SATIRI EKLEYİN:
    RunConsoleCommand("aphone_deepweb_notifications", self.isEnabled and "1" or "0")
    
    surface.PlaySound("buttons/button16.wav")
    
    -- HUD mesajı göster
    notification.AddLegacy("DeepWeb bildirimleri " .. (self.isEnabled and "AÇILDI" or "KAPATILDI"), self.isEnabled and NOTIFY_GENERIC or NOTIFY_ERROR, 3)
end

    -- Chat area
    local chat_scroll = vgui.Create("DScrollPanel", main)
    current_chat_scroll = chat_scroll -- Global değişkene ata
    chat_scroll:Dock(FILL)
    chat_scroll:DockMargin(5, 5, 5, 5)
    chat_scroll:SetCursor("blank") -- Cursor'u gizle
    
    -- Chat scroll teması
    function chat_scroll:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(5, 5, 5, 200))
        
        -- Terminal grid efekti
        surface.SetDrawColor(Color(0, 50, 0, 50))
        for i = 0, h, 20 do
            surface.DrawLine(0, i, w, i)
        end
        for i = 0, w, 20 do
            surface.DrawLine(i, 0, i, h)
        end
    end

    -- Input area
    local input_panel = vgui.Create("DPanel", main)
    input_panel:Dock(BOTTOM)
    input_panel:SetTall(60)
    input_panel:DockMargin(5, 0, 5, 5)
    input_panel:SetCursor("blank") -- Cursor'u gizle
    
    function input_panel:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, COLORS.terminal)
        surface.SetDrawColor(green)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    -- Input prompt
    local prompt = vgui.Create("DLabel", input_panel)
    prompt:Dock(LEFT)
    prompt:SetWide(40)
    prompt:SetText(">>>")
    prompt:SetFont("DermaDefault")
    prompt:SetTextColor(green)
    prompt:SetContentAlignment(5)
    prompt:SetCursor("blank") -- Cursor'u gizle
	
    -- Enter tuşu için kontrol değişkeni
    local waitingForEnter = false

    -- Text input - TWITTER STİLİ (ÇALIŞAN) - BÜYÜK FONT
    local input_text = vgui.Create("DButton", input_panel) -- DLabel yerine DButton
    input_text:Dock(FILL)
    input_text:DockMargin(5, 10, 50, 10)
    input_text:SetFont("DermaLarge") -- BÜYÜK FONT
    input_text:SetText("Enter your message...")
    input_text:SetTextColor(COLORS.gray)
    input_text.goodtext = nil -- Twitter tarzı text saklama
    input_text:SetCursor("blank") -- Cursor'u gizle
    
    function input_text:Paint(w, h)
        -- Arka plan
        draw.RoundedBox(2, 0, 0, w, h, Color(20, 20, 20, 255))
        
        -- Border
        surface.SetDrawColor(COLORS.gray)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Text'i manuel çiz (DButton'un default text çizimini override et)
        draw.SimpleText(self:GetText(), self:GetFont(), w/2, h/2, self:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        return true -- DButton'un default çizimini engelle
    end
    
    -- Twitter'daki gibi text giriş sistemi
    local placeholder = "Enter your message..."
    
    function input_text:DoClick()
        -- Twitter'daki Phone_AskTextEntry sistemini kullan
        local currentText = self:GetText() == placeholder and "" or self:GetText()
        
        -- Enter kontrolünü başlat
        waitingForEnter = true
        
        -- Text giriş popup'ı aç (Twitter sistemi)
        self:Phone_AskTextEntry(currentText, 200, input_panel, input_panel:GetWide() - 60)
    end
    
    -- Twitter'daki textEnd fonksiyonu
    function input_text:textEnd(clean_txt, wrapped_txt)
        self:SetText(wrapped_txt)
        self.goodtext = clean_txt
        
        -- Text renk kontrolü (Twitter'dan)
        if wrapped_txt ~= placeholder and wrapped_txt ~= "" then
            self:SetTextColor(COLORS.white) -- Beyaz text
        else
            self:SetTextColor(COLORS.gray) -- Placeholder gri
        end
    end

    -- Send button
    local send_btn = vgui.Create("DButton", input_panel)
    send_btn:Dock(RIGHT)
    send_btn:SetWide(40)
    send_btn:SetText(">>")
    send_btn:SetTextColor(green)
    send_btn:SetCursor("blank") -- Cursor'u gizle
    
    function send_btn:Paint(w, h)
        if self:IsHovered() then
            draw.RoundedBox(2, 0, 0, w, h, Color(0, 100, 0, 100))
        else
            draw.RoundedBox(2, 0, 0, w, h, Color(0, 50, 0, 100))
        end
        
        surface.SetDrawColor(green)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    function send_btn:DoClick()
        -- Twitter tarzı mesaj gönderme
        if not input_text.goodtext then return end
        
        local message = input_text.goodtext
        if message and message ~= "" then
            local username = "[" .. MY_DEEPWEB_NAME .. "]"
            
            -- Mesajı geçmişe ekle (KALİCİ)
            AddMessageToHistory(username, message)
            
            -- Mesaj uzunluğuna göre panel boyutu hesapla
            surface.SetFont("DermaLarge")
            local textW, textH = surface.GetTextSize(message)
            local panelWidth = input_panel:GetWide() - 20 -- Margin'ler
            local lineCount = math.ceil(textW / panelWidth) + 1 -- Satır sayısı
            local panelHeight = math.max(60, lineCount * 25 + 35) -- Dinamik yükseklik
            
            -- MESAJI CHAT ALANINA EKLE - DİNAMİK BOYUT
            local msg_panel = vgui.Create("DPanel", chat_scroll)
            msg_panel:Dock(TOP)
            msg_panel:SetTall(panelHeight) -- Dinamik yükseklik
            msg_panel:DockMargin(3, 3, 3, 3)
            msg_panel:SetCursor("blank") -- Cursor'u gizle
            
            function msg_panel:Paint(w, h)
                -- Mesaj arka planı - daha belirgin
                draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 25, 255))
                surface.SetDrawColor(COLORS.green)
                surface.DrawOutlinedRect(0, 0, w, h, 2) -- Kalın border
            end
            
            -- Kullanıcı adı - BÜYÜK
            local username_label = vgui.Create("DLabel", msg_panel)
            username_label:Dock(TOP)
            username_label:SetTall(25)
            username_label:SetText(username)
            username_label:SetTextColor(COLORS.orange)
            username_label:SetFont("DermaLarge")
            username_label:SetCursor("blank") -- Cursor'u gizle
            
            -- Mesaj içeriği - AUTO HEIGHT
            local msg_content = vgui.Create("DLabel", msg_panel)
            msg_content:Dock(FILL)
            msg_content:SetText(message)
            msg_content:SetTextColor(COLORS.white)
            msg_content:SetFont("DermaLarge")
            msg_content:SetWrap(true) -- Text wrap açık
            msg_content:SetAutoStretchVertical(true) -- Otomatik boy ayarı
            msg_content:DockMargin(5, 5, 5, 5) -- İç boşluk
            msg_content:SetCursor("blank") -- Cursor'u gizle
            
            -- Chat'i aşağı kaydır
            timer.Simple(0.1, function()
                if IsValid(chat_scroll) then
                    chat_scroll:GetVBar():SetScroll(chat_scroll:GetVBar().CanvasSize)
                end
            end)
            
            -- SUNUCUYA MESAJI GÖNDER (Güvenli)
            -- Network string kontrolü
            if util.NetworkStringToID and util.NetworkStringToID("aphone_deepweb_message") == 0 then
                print("[DeepWeb] HATA: Mesaj gonderilemedi - Sunucu kodu eksik!")
                
                -- Hata mesajı göster
                local error_msg = vgui.Create("DPanel", chat_scroll)
                error_msg:Dock(TOP)
                error_msg:SetTall(30)
                error_msg:DockMargin(3, 3, 3, 3)
                
                function error_msg:Paint(w, h)
                    draw.RoundedBox(4, 0, 0, w, h, COLORS.danger)
                    draw.SimpleText("MESAJ GÖNDERİLEMEDİ - Sunucu kodu eksik!", "DermaDefault", w/2, h/2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                timer.Simple(3, function()
                    if IsValid(error_msg) then
                        error_msg:Remove()
                    end
                end)
            else
                net.Start("aphone_deepweb_message")
                    net.WriteString(username)
                    net.WriteString(message)
                net.SendToServer()
                print("[DeepWeb] Mesaj sunucuya gonderildi")
            end
            
            print("[DeepWeb] Mesaj gonderildi ve kaydedildi: " .. message)
            
            -- Input'u temizle (Twitter tarzı)
            input_text:SetText("Enter your message...")
            input_text:SetTextColor(COLORS.gray)
            input_text.goodtext = nil
        end
    end

    -- Chat geçmişini yükle
    timer.Simple(0.5, function()
        if IsValid(chat_scroll) then
            LoadChatHistory(chat_scroll)
        end
    end)

    -- Enter tuşu kontrolü için Think hook
    hook.Add("Think", "DeepWebEnterCheck_" .. sessionID, function()
        if waitingForEnter and input.IsKeyDown(KEY_ENTER) then
            waitingForEnter = false
            
            timer.Simple(0.1, function()
                if IsValid(input_text) and input_text.goodtext and input_text.goodtext ~= "" then
                    if IsValid(send_btn) then
                        send_btn:DoClick()
                    end
                end
            end)
        end
        
        -- DeepWeb kapalıysa hook'u kaldır
        if not IsValid(main) then
            hook.Remove("Think", "DeepWebEnterCheck_" .. sessionID)
        end
    end)

    -- APhone'un kendi cursor sistemini kullan
    main:aphone_RemoveCursor()
    
    -- Normal cursor'u gizle
    main:SetCursor("blank")
    
    -- Alt panellerde de cursor'u gizle
    timer.Simple(0.1, function()
        if IsValid(main) then
            for _, child in ipairs(main:GetChildren()) do
                if IsValid(child) then
                    child:SetCursor("blank")
                end
            end
        end
    end)
    
    -- Global cursor kontrolü
    local function HideAllCursors(panel)
        if not IsValid(panel) then return end
        panel:SetCursor("blank")
        for _, child in ipairs(panel:GetChildren()) do
            HideAllCursors(child)
        end
    end
    
    -- Hemen ve biraz sonra cursor kontrolü yap
    HideAllCursors(main)
    timer.Simple(0.5, function()
        if IsValid(main) then
            HideAllCursors(main)
        end
    end)
    
    -- Cleanup fonksiyonunu panel'e ekle
    main.OnRemove = function(self)
        -- Sunucuya bildir - kullanıcı çıktı (Güvenli)
        if MY_DEEPWEB_NAME then
            -- Network string kontrolü
            if util.NetworkStringToID and util.NetworkStringToID("aphone_deepweb_user_leave") ~= 0 then
                net.Start("aphone_deepweb_user_leave")
                    net.WriteString(MY_DEEPWEB_NAME)
                net.SendToServer()
                print("[DeepWeb] Kullanici cikisi bildirildi: " .. MY_DEEPWEB_NAME)
            end
        end
        
        -- Hook'ları temizle
        hook.Remove("DeepWebUsersUpdated", sessionID)
        hook.Remove("Think", "DeepWebEnterCheck_" .. sessionID)
        
        -- Temizlik
        MY_DEEPWEB_NAME = nil
        current_chat_scroll = nil
    end
end

function APP:OnClose()
    -- OnRemove otomatik olarak çağrılacak
end

function APP:Open2D(main, main_x, main_y)
    print("[DeepWeb] Open2D cagirildi!")
    APP:Open(main, main_x, main_y, true)
end

-- Alternatif açılış fonksiyonları (aPhone versiyonuna göre)
function APP:Run(main, main_x, main_y)
    print("[DeepWeb] Run cagirildi!")
    self:Open(main, main_x, main_y, false)
end

function APP:OnClick(main, main_x, main_y)
    print("[DeepWeb] OnClick cagirildi!")
    self:Open(main, main_x, main_y, false)
end

function APP:OpenApp(main, main_x, main_y)
    print("[DeepWeb] OpenApp cagirildi!")
    self:Open(main, main_x, main_y, false)
end

-- Uygulamayı kaydet - ÖNEMLİ!
if aphone and aphone.RegisterApp then
    -- APP nesnesini kontrol et
    print("[DeepWeb] APP nesnesi kontrol ediliyor:")
    for k,v in pairs(APP) do
        print(" - " .. k .. ":", type(v))
    end
    
    -- Farklı kayıt yöntemleri dene
    local success1 = pcall(function()
        aphone.RegisterApp(APP)
    end)
    
    if not success1 then
        print("[DeepWeb] RegisterApp(APP) basarisiz, alternatif deneniyor...")
        
        -- Alternatif 1: Tablo olarak gönder
        local success2 = pcall(function()
            aphone.RegisterApp({
                name = "DeepWeb",
                desc = "Access the underground network",
                icon = "icon16/application_xp_terminal.png",
                author = "Anonymous",
                Open = APP.Open,
                Open2D = APP.Open2D
            })
        end)
        
        if not success2 then
            print("[DeepWeb] Alternatif 1 basarisiz")
            
            -- Alternatif 2: Sadece isim ve fonksiyon
            local success3 = pcall(function()
                aphone.RegisterApp("DeepWeb", APP)
            end)
            
            if not success3 then
                print("[DeepWeb] Tum kayit yontemleri basarisiz!")
            else
                print("[DeepWeb] Alternatif 2 ile kayit basarili!")
            end
        else
            print("[DeepWeb] Alternatif 1 ile kayit basarili!")
        end
    else
        print("[DeepWeb] RegisterApp cagirildi!")
    end
else
    print("[DeepWeb] HATA: aphone.RegisterApp bulunamadi!")
end

-- Yedek kayıt yöntemi
timer.Simple(1, function()
    if aphone and aphone.RegisterApp then
        -- Uygulama kayıtlı mı kontrol et
        if not (aphone.Apps and aphone.Apps["DeepWeb"]) then
            aphone.RegisterApp(APP)
            print("[DeepWeb] Timer ile kayit yapildi!")
        else
            print("[DeepWeb] Uygulama zaten kayitli!")
        end
    end
end)

-- Diğer aPhone uygulamalarını kontrol et
timer.Simple(3, function()
    if aphone and aphone.Apps then
        print("[DeepWeb] Kayitli uygulamalar:")
        for name, app in pairs(aphone.Apps) do
            print(" - " .. name)
        end
        
        -- DeepWeb kayıtlı mı?
        if aphone.Apps["DeepWeb"] then
            print("[DeepWeb] DeepWeb basariyla kayitli!")
        else
            -- Manuel kayıt dene
            aphone.Apps["DeepWeb"] = APP
            print("[DeepWeb] Manuel kayit yapildi!")
        end
    end
end)

-- Hook ile kayıt (en güvenli)
hook.Add("AphoneLoaded", "RegisterDeepWeb", function()
    if aphone and aphone.RegisterApp and APP then
        aphone.RegisterApp(APP)
        print("[DeepWeb] Hook ile kayit yapildi!")
    end
end)

-- Debug mesajı
print("[DeepWeb] Dosya yuklendi ve kayit denemeleri basladi!")
print("[DeepWeb] aPhone durumu:", aphone ~= nil)
print("[DeepWeb] RegisterApp durumu:", aphone and aphone.RegisterApp ~= nil)