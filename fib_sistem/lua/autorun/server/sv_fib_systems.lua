-- fib_sistem/lua/autorun/server/sv_fib_systems.lua
-- Server Core - v15.0 CONFIG FIXED

-- ============================================
-- NETWORK STRING TANIMLARI (EN BAŞTA OLMALI!)
-- ============================================
util.AddNetworkString("FIB_AttemptLogin")
util.AddNetworkString("FIB_LoginResponse")
util.AddNetworkString("FIB_UpdateUndercover")
util.AddNetworkString("FIB_ToggleUndercover")
util.AddNetworkString("FIB_SendChatMessage")
util.AddNetworkString("FIB_ChatMessage")
util.AddNetworkString("FIB_ReceiveChatMessage")
util.AddNetworkString("FIB_RequestChatHistory")
util.AddNetworkString("FIB_ChatHistory")
util.AddNetworkString("FIB_ClearChat")
util.AddNetworkString("FIB_AddAgent")
util.AddNetworkString("FIB_RemoveAgent")
util.AddNetworkString("FIB_KickedFromSystem")
util.AddNetworkString("FIB_RequestSync")
util.AddNetworkString("FIB_FullSync")
util.AddNetworkString("FIB_QuickSync")
util.AddNetworkString("FIB_AgentLeft")
util.AddNetworkString("FIB_AgentJoined")
util.AddNetworkString("FIB_CreateMission")
util.AddNetworkString("FIB_DeleteMission")
util.AddNetworkString("FIB_UpdateMissionStatus")
util.AddNetworkString("FIB_MissionUpdate")
util.AddNetworkString("FIB_DepartmentUpdate")
util.AddNetworkString("FIB_SyncData")
util.AddNetworkString("FIB_AgentListUpdate")

print("[FIB SYSTEM] Network strings tanimlandi!")

-- ============================================
-- DEFAULT KULLANICILAR (HER ZAMAN YÜKLENECEK)
-- ============================================
local DEFAULT_USERS = {
    ["STEAM_0:1:173464330"] = {
        username = "meloo",
        password = "123123asd",
        rank = "Sef"
    },
    ["STEAM_1:1:441442821"] = {
        username = "kod01",
        password = "sikici123",
        rank = "Sef"
    },
    -- STEAM_0 formatı için de ekle (güvenlik için)
    ["STEAM_0:1:441442821"] = {
        username = "kod01",
        password = "sikici123",
        rank = "Sef"
    }
}

-- ============================================
-- CONFIG LOADER - DÜZELTILMIŞ
-- ============================================
local function LoadConfig()
    -- Varsayılan config
    local config = {
        Users = {},
        ChatHistory = {},
        Missions = {}
    }
    
    -- JSON dosyası varsa oku
    if file.Exists("fib_sistem/config.json", "DATA") then
        local data = file.Read("fib_sistem/config.json", "DATA")
        local jsonConfig = util.JSONToTable(data)
        
        if jsonConfig then
            -- Users'ın object olduğundan emin ol
            if type(jsonConfig.Users) == "table" then
                local isArray = false
                for k, v in pairs(jsonConfig.Users) do
                    if type(k) == "number" then
                        isArray = true
                        break
                    end
                end
                
                if not isArray then
                    -- JSON'daki kullanıcıları ekle
                    for steamid, userData in pairs(jsonConfig.Users) do
                        config.Users[steamid] = userData
                    end
                else
                    print("[FIB WARNING] Config.json'daki Users field'i array formatta, düzeltiliyor...")
                end
            end
            
            config.ChatHistory = jsonConfig.ChatHistory or {}
            config.Missions = jsonConfig.Missions or {}
        end
    else
        -- JSON yoksa oluştur
        file.CreateDir("fib_sistem")
    end
    
    -- DEFAULT KULLANICILARI HER ZAMAN EKLE (ÖNEMLİ!)
    for steamid, userData in pairs(DEFAULT_USERS) do
        config.Users[steamid] = userData
        print("[FIB] Default kullanici yuklendi: " .. userData.username .. " (" .. steamid .. ")")
    end
    
    return config
end

local function SaveConfig()
    -- Users'ın object olduğundan emin ol
    if type(FIB.Config.Users) ~= "table" then
        FIB.Config.Users = {}
    end
    
    -- Default kullanıcıları her zaman ekle
    for steamid, userData in pairs(DEFAULT_USERS) do
        FIB.Config.Users[steamid] = userData
    end
    
    local saveData = {
        Users = FIB.Config.Users,
        ChatHistory = FIB.Config.ChatHistory or {},
        Missions = FIB.Config.Missions or {}
    }
    
    file.Write("fib_sistem/config.json", util.TableToJSON(saveData, true))
    print("[FIB] Config kaydedildi - " .. table.Count(FIB.Config.Users) .. " kullanici")
end

-- Global tables
FIB = FIB or {}
FIB.Config = LoadConfig()
FIB.OnlineAgents = {}
FIB.ChatHistory = FIB.Config.ChatHistory or {}
FIB.Missions = FIB.Config.Missions or {}
FIB.NextMissionID = 1

-- Mission ID'leri düzelt
if FIB.Missions and #FIB.Missions > 0 then
    for _, mission in ipairs(FIB.Missions) do
        if mission.id and mission.id >= FIB.NextMissionID then
            FIB.NextMissionID = mission.id + 1
        end
    end
end

-- Save fonksiyonları (uyumluluk için)
FIB.SaveAgents = SaveConfig
FIB.SaveMissions = SaveConfig

-- ============================================
-- DEBUG VE FIX KOMUTLARI
-- ============================================
concommand.Add("fib_fix_users", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    -- Default kullanıcıları zorla ekle
    for steamid, userData in pairs(DEFAULT_USERS) do
        FIB.Config.Users[steamid] = userData
    end
    
    SaveConfig()
    
    local msg = "[FIB] Kullanicilar duzeltildi! " .. table.Count(FIB.Config.Users) .. " kullanici mevcut."
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
        ply:ChatPrint("[FIB] Default kullanicilar:")
        for steamid, userData in pairs(DEFAULT_USERS) do
            ply:ChatPrint("  - " .. steamid .. ": " .. userData.username .. "/" .. userData.password)
        end
    else
        print(msg)
    end
end)

concommand.Add("fib_show_users", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    print("[FIB] === TUM KULLANICILAR ===")
    for steamid, userData in pairs(FIB.Config.Users) do
        print("SteamID: " .. steamid)
        print("  Username: " .. userData.username)
        print("  Password: " .. userData.password)
        print("  Rank: " .. userData.rank)
    end
    print("Toplam: " .. table.Count(FIB.Config.Users) .. " kullanici")
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Kullanici listesi konsola yazildi. Toplam: " .. table.Count(FIB.Config.Users))
    end
end)

-- ============================================
-- GİRİŞ SİSTEMİ - DÜZELTILMIŞ
-- ============================================
net.Receive("FIB_AttemptLogin", function(len, ply)
    local username = net.ReadString()
    local password = net.ReadString()
    local playerSteamID = ply:SteamID()
    
    print("[FIB LOGIN] Giris denemesi:")
    print("  Oyuncu: " .. ply:Nick())
    print("  SteamID: " .. playerSteamID)
    print("  Username: " .. username)
    print("  Toplam kullanici: " .. table.Count(FIB.Config.Users))
    
    -- Tüm kullanıcıları kontrol et
    local found = false
    local correctSteamID = nil
    
    for steamid, userData in pairs(FIB.Config.Users) do
        if userData.username == username and userData.password == password then
            found = true
            correctSteamID = steamid
            
            -- SteamID kontrolü
            if playerSteamID == steamid then
                -- Başarılı giriş
                ply:SetNWBool("FIB_Authenticated", true)
                ply:SetNWString("FIB_Rank", userData.rank)
                ply:SetNWString("FIB_Username", username)
                ply:SetNWBool("FIB_Undercover", false)
                
                -- Eski değişkenler (uyumluluk için)
                ply.FIBAuthenticated = true
                ply.FIBRank = userData.rank
                ply.FIBUsername = username
                ply.FIBUndercover = false
                ply.FIBLoginTime = CurTime()
                
                -- Online listesine ekle
                table.insert(FIB.OnlineAgents, {
                    ply = ply,
                    steamid = steamid,
                    username = username,
                    rank = userData.rank,
                    nick = ply:Nick(),
                    undercover = false,
                    loginTime = os.time()
                })
                
                net.Start("FIB_LoginResponse")
                net.WriteBool(true)
                net.WriteString("Giris basarili! Hos geldin " .. userData.rank .. "!")
                net.WriteString(userData.rank)
                net.WriteString(username)
                net.Send(ply)
                
                print("[FIB] BASARILI GIRIS: " .. ply:Nick() .. " - " .. userData.rank)
                
                -- Hook'u tetikle
                hook.Run("FIB_AgentLogin", ply)
                
                -- Diğer ajanlara bildir
                timer.Simple(0.5, function()
                    if IsValid(ply) and FIB.BroadcastQuickSync then
                        FIB.BroadcastQuickSync()
                    end
                end)
                
                return
            else
                print("[FIB] SteamID uyusmuyor! Beklenen: " .. steamid .. " | Gelen: " .. playerSteamID)
            end
        end
    end
    
    -- Giriş başarısız
    if found then
        net.Start("FIB_LoginResponse")
        net.WriteBool(false)
        net.WriteString("Bu hesap baska bir SteamID'ye kayitli! (Beklenen: " .. correctSteamID .. ")")
        net.Send(ply)
        print("[FIB] HATALI STEAMID: Hesap " .. correctSteamID .. " için kayitli")
    else
        net.Start("FIB_LoginResponse")
        net.WriteBool(false)
        net.WriteString("Gecersiz kullanici adi veya sifre!")
        net.Send(ply)
        print("[FIB] YANLIS BILGILER: " .. username)
    end
end)

-- ============================================
-- GİZLİ MOD SİSTEMİ
-- ============================================
net.Receive("FIB_ToggleUndercover", function(len, ply)
    if not ply.FIBAuthenticated then return end
    
    local isUndercover = not ply.FIBUndercover
    ply:SetNWBool("FIB_Undercover", isUndercover)
    ply.FIBUndercover = isUndercover
    
    -- Online listesinde güncelle
    for i, agent in ipairs(FIB.OnlineAgents) do
        if agent.ply == ply then
            agent.undercover = isUndercover
            break
        end
    end
    
    if isUndercover then
        ply:ChatPrint("[FIB] Gizli moda gecildi!")
        
        -- Silahları ver (varsa)
        timer.Simple(0.5, function()
            if IsValid(ply) then
                -- Radio ekle
                if weapons.Get("weapon_rdo_radio") then
                    ply:Give("weapon_rdo_radio")
                end
                if weapons.Get("arccw_mw2_g18_perma") then
                    ply:Give("arccw_mw2_g18_perma")
                end
                if weapons.Get("dsr_lockpick") then
                    ply:Give("dsr_lockpick")
                end
                if weapons.Get("bkeypads_cracker") then
                    ply:Give("bkeypads_cracker")
                end
                if weapons.Get("weapon_kidnap") then
                    ply:Give("weapon_kidnap")
                end
            end
        end)
        
        -- Diğer ajanlara bildir
        for _, v in ipairs(player.GetAll()) do
            if v.FIBAuthenticated and v != ply then
                v:ChatPrint("[FIB] " .. ply:Nick() .. " gizli moda gecti")
            end
        end
    else
        ply:ChatPrint("[FIB] Normal moda donuldu!")
        
        -- FIB silahlarını al (radio dahil)
        if ply:HasWeapon("weapon_rdo_radio") then
            ply:StripWeapon("weapon_rdo_radio")
        end
        if ply:HasWeapon("dsr_lockpick") then
            ply:StripWeapon("dsr_lockpick")
        end
        if ply:HasWeapon("bkeypads_cracker") then
            ply:StripWeapon("bkeypads_cracker")
        end
        if ply:HasWeapon("weapon_kidnap") then
            ply:StripWeapon("weapon_kidnap")
        end
        
        -- Diğer ajanlara bildir
        for _, v in ipairs(player.GetAll()) do
            if v.FIBAuthenticated and v != ply then
                v:ChatPrint("[FIB] " .. ply:Nick() .. " normal moda dondu")
            end
        end
    end
	-- Client'ı güncelle
    net.Start("FIB_UpdateUndercover")
    net.WriteBool(isUndercover)
    net.Send(ply)
    
    -- Hook'u tetikle
    hook.Run("FIB_UndercoverChanged", ply)
    
    -- Sync gönder
    if FIB.BroadcastQuickSync then
        FIB.BroadcastQuickSync()
    end
    
    ServerLog("[FIB] " .. ply:Nick() .. (isUndercover and " gizli moda gecti\n" or " normal moda dondu\n"))
end)

-- ============================================
-- GÖREV YÖNETİMİ - FIXED & OPTIMIZED
-- ============================================

-- Görev oluştur - NET RECEIVER - FIXED
net.Receive("FIB_CreateMission", function(len, ply)
    -- Güvenlik kontrolleri
    if not IsValid(ply) or not ply.FIBAuthenticated then return end
    
    -- Size kontrolü
    if len > 4096 then
        print("[FIB] Cok buyuk gorev verisi reddedildi: " .. ply:Nick())
        return
    end
    
    local rank = ply.FIBRank or "Ajan"
    if rank ~= "Sef" and rank ~= "Kidemli Ajan" then
        ply:ChatPrint("[FIB] Bu islemi yapma yetkiniz yok!")
        return
    end
    
    -- Verileri al ve sanitize et
    local missionName = string.sub(net.ReadString() or "", 1, 100)
    local target = string.sub(net.ReadString() or "Bilinmiyor", 1, 100)
    local priority = net.ReadString() or "ORTA"
    local status = net.ReadString() or "Planlama"
    local assigned = string.sub(net.ReadString() or "", 1, 50)
    
    -- Boş isim kontrolü
    if missionName == "" or string.Trim(missionName) == "" then
        ply:ChatPrint("[FIB] Gorev adi bos olamaz!")
        return
    end
    
    -- XSS koruması
    missionName = string.gsub(missionName, "<", "")
    missionName = string.gsub(missionName, ">", "")
    target = string.gsub(target, "<", "")
    target = string.gsub(target, ">", "")
    
    -- Görev oluştur
    local mission = {
        id = FIB.NextMissionID,
        name = missionName,
        target = target,
        priority = priority,
        status = status,
        assigned = assigned ~= "" and assigned or "Atanmadi",
        createdBy = ply:Nick(),
        createdAt = os.time(),
        createdDate = os.date("%d/%m/%Y %H:%M")
    }
    
    FIB.NextMissionID = FIB.NextMissionID + 1
    
    -- Listeye ekle
    table.insert(FIB.Missions, mission)
    
    -- Kalıcı kaydet
    if FIB.SaveMissions then
        FIB.SaveMissions()
    end
    
    -- Hook'u tetikle
    hook.Run("FIB_MissionCreated", mission)
    
    -- Tüm ajanlara bildir
    for _, agent in ipairs(player.GetAll()) do
        if IsValid(agent) and agent.FIBAuthenticated then
            agent:ChatPrint("[FIB] Yeni gorev olusturuldu: " .. mission.name)
            
            net.Start("FIB_MissionUpdate")
            net.WriteString("new")
            net.WriteTable(mission)
            net.Send(agent)
        end
    end
    
    -- Sync gönder
    timer.Simple(0.5, function()
        if FIB.BroadcastFullSync then
            FIB.BroadcastFullSync()
        end
    end)
    
    ServerLog("[FIB-MISSION] " .. ply:Nick() .. " yeni gorev olusturdu: " .. mission.name .. "\n")
end)

-- Görev sil - NET RECEIVER - FIXED
net.Receive("FIB_DeleteMission", function(len, ply)
    -- Güvenlik kontrolleri
    if not IsValid(ply) or not ply.FIBAuthenticated then return end
    
    if len > 1024 then
        print("[FIB] Gecersiz gorev silme istegi: " .. ply:Nick())
        return
    end
    
    local rank = ply.FIBRank or "Ajan"
    if rank ~= "Sef" and rank ~= "Kidemli Ajan" then
        ply:ChatPrint("[FIB] Bu islemi yapma yetkiniz yok!")
        return
    end
    
    local missionName = net.ReadString()
    
    -- Görevi bul ve sil
    local found = false
    for i = #FIB.Missions, 1, -1 do -- Tersten dönerek güvenli silme
        local mission = FIB.Missions[i]
        if mission and mission.name == missionName then
            table.remove(FIB.Missions, i)
            found = true
            
            -- Hook'u tetikle
            hook.Run("FIB_MissionDeleted", i)
            
            -- Kalıcı kaydet
            if FIB.SaveMissions then
                FIB.SaveMissions()
            end
            
            -- Tüm ajanlara bildir
            for _, agent in ipairs(player.GetAll()) do
                if IsValid(agent) and agent.FIBAuthenticated then
                    agent:ChatPrint("[FIB] Gorev silindi: " .. missionName)
                end
            end
            
            -- Sync gönder
            timer.Simple(0.5, function()
                if FIB.BroadcastFullSync then
                    FIB.BroadcastFullSync()
                end
            end)
            
            ServerLog("[FIB] " .. ply:Nick() .. " gorevi sildi: " .. missionName .. "\n")
            break
        end
    end
    
    if not found then
        ply:ChatPrint("[FIB] Gorev bulunamadi!")
    end
end)

-- Görev durumu güncelle - NET RECEIVER - FIXED
net.Receive("FIB_UpdateMissionStatus", function(len, ply)
    -- Güvenlik kontrolleri
    if not IsValid(ply) or not ply.FIBAuthenticated then return end
    
    if len > 1024 then
        print("[FIB] Gecersiz gorev guncelleme istegi: " .. ply:Nick())
        return
    end
    
    local rank = ply.FIBRank or "Ajan"
    if rank ~= "Sef" then
        ply:ChatPrint("[FIB] Sadece Sef gorev durumu guncelleyebilir!")
        return
    end
    
    local missionName = net.ReadString()
    local newStatus = net.ReadString()
    
    -- Geçerli statü kontrolü
    local validStatuses = {
        ["Planlama"] = true,
        ["Beklemede"] = true,
        ["Devam Ediyor"] = true,
        ["Tamamlandi"] = true,
        ["Iptal"] = true
    }
    
    if not validStatuses[newStatus] then
        ply:ChatPrint("[FIB] Gecersiz gorev durumu!")
        return
    end
    
    -- Görevi bul ve güncelle
    local found = false
    for i, mission in ipairs(FIB.Missions) do
        if mission.name == missionName then
            local oldStatus = mission.status
            mission.status = newStatus
            mission.updatedBy = ply:Nick()
            mission.updatedAt = os.time()
            
            -- Eğer tamamlandı ise
            if newStatus == "Tamamlandi" then
                mission.completed_date = os.time()
                mission.completed_by = ply:Nick()
            end
            
            found = true
            
            -- Hook'u tetikle
            hook.Run("FIB_MissionUpdated", mission)
            
            -- Kalıcı kaydet
            if FIB.SaveMissions then
                FIB.SaveMissions()
            end
            
            -- Tüm ajanlara bildir
            for _, agent in ipairs(player.GetAll()) do
                if IsValid(agent) and agent.FIBAuthenticated then
                    agent:ChatPrint("[FIB] Gorev durumu guncellendi: " .. missionName .. " | " .. oldStatus .. " -> " .. newStatus)
                    
                    net.Start("FIB_MissionUpdate")
                    net.WriteString("status_update")
                    net.WriteTable({
                        name = missionName,
                        status = newStatus,
                        updated_by = ply:Nick()
                    })
                    net.Send(agent)
                end
            end
            
            -- Sync gönder
            timer.Simple(0.5, function()
                if FIB.BroadcastFullSync then
                    FIB.BroadcastFullSync()
                end
            end)
            
            ServerLog("[FIB] " .. ply:Nick() .. " gorev durumunu guncelledi: " .. missionName .. " -> " .. newStatus .. "\n")
            break
        end
    end
    
    if not found then
        ply:ChatPrint("[FIB] Gorev bulunamadi!")
    end
end)

-- KONSOL KOMUTLARI - GÖREVLER
concommand.Add("fib_mission_list", function(ply)
    if not IsValid(ply) or not ply.FIBAuthenticated then
        if IsValid(ply) then
            ply:ChatPrint("[FIB] Bu komutu kullanmak icin FIB ajani olmalisiniz!")
        end
        return
    end
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] === AKTIF GOREVLER ===")
        
        local activeCount = 0
        for id, mission in ipairs(FIB.Missions) do
            if mission.status ~= "Tamamlandi" and mission.status ~= "Iptal" then
                activeCount = activeCount + 1
                ply:ChatPrint("[" .. mission.id .. "] " .. mission.name)
                ply:ChatPrint("  Hedef: " .. mission.target)
                ply:ChatPrint("  Oncelik: " .. mission.priority)
                ply:ChatPrint("  Durum: " .. mission.status)
                ply:ChatPrint("  Atanan: " .. mission.assigned)
                ply:ChatPrint("  Olusturan: " .. mission.createdBy)
                ply:ChatPrint("  ----------------")
            end
        end
        
        if activeCount == 0 then
            ply:ChatPrint("Aktif gorev bulunmuyor.")
        end
        
        ply:ChatPrint("[FIB] === TAMAMLANAN GOREVLER ===")
        
        local completedCount = 0
        for id, mission in ipairs(FIB.Missions) do
            if mission.status == "Tamamlandi" then
                completedCount = completedCount + 1
                ply:ChatPrint("[" .. mission.id .. "] " .. mission.name .. " - Tamamlayan: " .. (mission.completed_by or "Bilinmiyor"))
            end
        end
        
        if completedCount == 0 then
            ply:ChatPrint("Tamamlanan gorev bulunmuyor.")
        end
        
        ply:ChatPrint("[FIB] Toplam: " .. #FIB.Missions .. " gorev (" .. activeCount .. " aktif, " .. completedCount .. " tamamlandi)")
    end
end)

-- Admin komutu - Tüm görevleri temizle
concommand.Add("fib_mission_clear_all", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece super adminler kullanabilir!")
        return
    end
    
    FIB.Missions = {}
    FIB.NextMissionID = 1
    
    if FIB.SaveMissions then
        FIB.SaveMissions()
    end
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Tum gorevler temizlendi!")
    else
        print("[FIB] Tum gorevler temizlendi!")
    end
    
    -- Sync
    if FIB.BroadcastFullSync then
        FIB.BroadcastFullSync()
    end
end)
-- ============================================
-- AJAN YÖNETİMİ
-- ============================================

-- Ajan ekleme (Sadece Şef) - NET RECEIVER
net.Receive("FIB_AddAgent", function(len, ply)
    if not ply.FIBAuthenticated then return end
    if ply.FIBRank ~= "Sef" then 
        ply:ChatPrint("[FIB] Bu islemi sadece sefler yapabilir!")
        return 
    end
    
    local target = net.ReadEntity()
    local username = net.ReadString()
    local password = net.ReadString()
    local rank = net.ReadString()
    
    if not IsValid(target) then return end
    
    local steamid = target:SteamID()
    
    -- Zaten sistemde mi kontrol et
    if FIB.Config.Users[steamid] then
        ply:ChatPrint("[FIB] Bu oyuncu zaten sistemde!")
        return
    end
    
    FIB.Config.Users[steamid] = {
        username = username,
        password = password,
        rank = rank,
        added_by = ply:Nick(),
        added_date = os.time()
    }
    
    SaveConfig()
    
    -- Hedef oyuncuya bildir
    target:ChatPrint("[FIB] ===============================")
    target:ChatPrint("[FIB] SISTEME EKLENDINIZ!")
    target:ChatPrint("[FIB] Kullanici Adi: " .. username)
    target:ChatPrint("[FIB] Sifre: " .. password)
    target:ChatPrint("[FIB] Rutbe: " .. rank)
    target:ChatPrint("[FIB] !fib yazarak giris yapabilirsiniz")
    target:ChatPrint("[FIB] ===============================")
    
    ply:ChatPrint("[FIB] " .. target:Nick() .. " sisteme eklendi!")
    
    -- Tüm FIB ajanlarına bildir
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated and v != ply and v != target then
            v:ChatPrint("[FIB] " .. target:Nick() .. " sisteme eklendi (" .. rank .. ")")
        end
    end
    
    -- Departman güncellemesi
    net.Start("FIB_DepartmentUpdate")
    net.WriteString("add")
    net.WriteString(steamid)
    net.WriteString(username)
    net.WriteString(rank)
    net.Broadcast()
    
    -- Hook'u tetikle
    hook.Run("FIB_AgentAdded", steamid)
    
    ServerLog("[FIB] " .. ply:Nick() .. " tarafindan " .. target:Nick() .. " sisteme eklendi (Rank: " .. rank .. ")\n")
end)

-- Ajan çıkarma (Sadece Şef) - NET RECEIVER
net.Receive("FIB_RemoveAgent", function(len, ply)
    if not ply.FIBAuthenticated then return end
    if ply.FIBRank ~= "Sef" then return end
    
    local steamid = net.ReadString()
    
    if not FIB.Config.Users[steamid] then
        ply:ChatPrint("[FIB] Bu kullanici sistemde bulunamadi!")
        return
    end
    
    -- Default kullanıcıyı silmeye çalışıyor mu?
    if DEFAULT_USERS[steamid] then
        ply:ChatPrint("[FIB] Default kullanicilari silemezsiniz!")
        return
    end
    
    local removedUser = FIB.Config.Users[steamid].username
    local removedRank = FIB.Config.Users[steamid].rank
    
    -- Kendini silmeye çalışıyor mu?
    if steamid == ply:SteamID() then
        ply:ChatPrint("[FIB] Kendinizi sistemden silemezsiniz!")
        return
    end
    
    -- Kullanıcıyı sil
    FIB.Config.Users[steamid] = nil
    SaveConfig()
    
    -- Online ise sistemden çık
    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            -- ÖNCE kicked mesajını gönder
            net.Start("FIB_KickedFromSystem")
            net.Send(v)
            
            -- Sonra değişkenleri temizle
            timer.Simple(0.1, function()
                if IsValid(v) then
                    v:SetNWBool("FIB_Authenticated", false)
                    v:SetNWString("FIB_Rank", "")
                    v:SetNWString("FIB_Username", "")
                    v:SetNWBool("FIB_Undercover", false)
                    v.FIBAuthenticated = false
                    v.FIBRank = nil
                    v.FIBUsername = nil
                    v.FIBUndercover = false
                    v:ChatPrint("[FIB] Sistem erisiminiz kaldirildi!")
                end
            end)
            
            -- Online listesinden çıkar
            for i, agent in ipairs(FIB.OnlineAgents) do
                if agent.ply == v then
                    table.remove(FIB.OnlineAgents, i)
                    break
                end
            end
            break
        end
    end
    
    ply:ChatPrint("[FIB] " .. removedUser .. " (" .. removedRank .. ") sistemden cikarildi!")
    
    -- Tüm FIB ajanlarına bildir
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated and v != ply then
            v:ChatPrint("[FIB] " .. removedUser .. " sistemden cikarildi")
        end
    end
    
    -- Departman güncellemesi
    net.Start("FIB_DepartmentUpdate")
    net.WriteString("remove")
    net.WriteString(steamid)
    net.Broadcast()
    
    -- Hook'u tetikle
    hook.Run("FIB_AgentRemoved", steamid)
    
    ServerLog("[FIB] " .. ply:Nick() .. " tarafindan " .. removedUser .. " (" .. steamid .. ") sistemden cikarildi\n")
end)

-- ============================================
-- SYNC SİSTEMİ
-- ============================================
function FIB.BroadcastFullSync()
    local onlineData = {}
    for _, agent in ipairs(FIB.OnlineAgents) do
        if IsValid(agent.ply) then
            table.insert(onlineData, {
                steamid = agent.steamid,
                nick = agent.ply:Nick(),
                rank = agent.rank,
                username = agent.username,
                undercover = agent.undercover,
                loginTime = agent.loginTime
            })
        end
    end
    
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            net.Start("FIB_FullSync")
            net.WriteTable(onlineData)
            net.WriteTable(FIB.Config.Users or {})
            net.WriteTable(FIB.Missions or {})
            net.Send(ply)
        end
    end
end

function FIB.BroadcastQuickSync()
    local onlineData = {}
    for _, agent in ipairs(FIB.OnlineAgents) do
        if IsValid(agent.ply) then
            table.insert(onlineData, {
                steamid = agent.steamid,
                nick = agent.ply:Nick(),
                rank = agent.rank,
                username = agent.username,
                undercover = agent.undercover,
                loginTime = agent.loginTime
            })
        end
    end
    
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            net.Start("FIB_QuickSync")
            net.WriteTable(onlineData)
            net.Send(ply)
        end
    end
end

net.Receive("FIB_RequestSync", function(len, ply)
    if not ply.FIBAuthenticated then return end
    
    timer.Simple(0.1, function()
        if IsValid(ply) then
            local onlineData = {}
            for _, agent in ipairs(FIB.OnlineAgents) do
                if IsValid(agent.ply) then
                    table.insert(onlineData, {
                        steamid = agent.steamid,
                        nick = agent.ply:Nick(),
                        rank = agent.rank,
                        username = agent.username,
                        undercover = agent.undercover,
                        loginTime = agent.loginTime
                    })
                end
            end
            
            net.Start("FIB_FullSync")
            net.WriteTable(onlineData)
            net.WriteTable(FIB.Config.Users or {})
            net.WriteTable(FIB.Missions or {})
            net.Send(ply)
        end
    end)
end)

-- ============================================
-- OYUNCU HOOK'LARI
-- ============================================
hook.Add("PlayerDisconnected", "FIB_PlayerLeft", function(ply)
    if ply.FIBAuthenticated then
        local nick = ply:Nick()
        local steamid = ply:SteamID()
        
        -- Online listesinden çıkar
        for i, agent in ipairs(FIB.OnlineAgents) do
            if agent.ply == ply then
                table.remove(FIB.OnlineAgents, i)
                break
            end
        end
        
        -- Diğer ajanlara bildir
        timer.Simple(0.5, function()
            for _, p in ipairs(player.GetAll()) do
                if p.FIBAuthenticated then
                    net.Start("FIB_AgentLeft")
                    net.WriteString(steamid)
                    net.WriteString(nick)
                    net.Send(p)
                end
            end
        end)
    end
end)

hook.Add("PlayerSpawn", "FIB_PlayerSpawn", function(ply)
    if IsValid(ply) and ply.FIBAuthenticated then
        -- Gizli moddaysa silahları ver
        if ply.FIBUndercover then
            timer.Simple(1, function()
                if IsValid(ply) then
                    -- Radio ekle
                    if weapons.Get("weapon_rdo_radio") then
                        ply:Give("weapon_rdo_radio")
                    end
                    if weapons.Get("arccw_mw2_g18_perma") then
                        ply:Give("arccw_mw2_g18_perma")
                    end
                    if weapons.Get("dsr_lockpick") then
                        ply:Give("dsr_lockpick")
                    end
                    if weapons.Get("bkeypads_cracker") then
                        ply:Give("bkeypads_cracker")
                    end
                    if weapons.Get("weapon_kidnap") then
                        ply:Give("weapon_kidnap")
                    end
                end
            end)
        end
        
        -- Senkronize et
        timer.Simple(2, function()
            FIB.BroadcastQuickSync()
        end)
    end
end)
-- ============================================
-- DEBUG KOMUTLARI
-- ============================================
concommand.Add("fib_systems_debug", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    print("[FIB SYSTEMS] === DEBUG ===")
    print("Network strings: OK")
    print("Gorev sayisi: " .. #FIB.Missions)
    print("Kayitli kullanici sayisi: " .. table.Count(FIB.Config.Users))
    
    local onlineAgents = 0
    local undercoverAgents = 0
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v.FIBAuthenticated then
            onlineAgents = onlineAgents + 1
            if v.FIBUndercover then
                undercoverAgents = undercoverAgents + 1
            end
        end
    end
    
    print("Online ajanlar: " .. onlineAgents)
    print("Gizli moddakiler: " .. undercoverAgents)
    
    print("\n[FIB] Kullanicilar:")
    for steamid, userData in pairs(FIB.Config.Users) do
        print("  - " .. steamid .. ": " .. userData.username .. " (" .. userData.rank .. ")")
    end
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB SYSTEMS] Debug bilgisi konsola yazildi")
    end
end)

-- SteamID kontrol komutu
concommand.Add("fib_check_my_steamid", function(ply)
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Senin SteamID: " .. ply:SteamID())
        ply:ChatPrint("[FIB] SteamID64: " .. ply:SteamID64())
        
        -- Config'de var mı kontrol et
        if FIB.Config.Users[ply:SteamID()] then
            local userData = FIB.Config.Users[ply:SteamID()]
            ply:ChatPrint("[FIB] Sen sistemdesin!")
            ply:ChatPrint("[FIB] Username: " .. userData.username)
            ply:ChatPrint("[FIB] Rank: " .. userData.rank)
        else
            ply:ChatPrint("[FIB] Sistemde kayitli degilsin!")
        end
    end
end)

-- Admin komutları - Chat
hook.Add("PlayerSay", "FIB_AdminChatCommands", function(ply, text)
    if not ply:IsAdmin() then return end
    
    local args = string.Explode(" ", text)
    
    -- Kullanıcıları düzelt
    if args[1] == "!fib_fix" then
        -- Default kullanıcıları zorla ekle
        for steamid, userData in pairs(DEFAULT_USERS) do
            FIB.Config.Users[steamid] = userData
        end
        SaveConfig()
        
        ply:ChatPrint("[FIB] Kullanicilar duzeltildi!")
        ply:ChatPrint("[FIB] Toplam: " .. table.Count(FIB.Config.Users) .. " kullanici")
        
        return ""
    end
    
    -- Kullanıcı listesi
    if args[1] == "!fib_users" then
        ply:ChatPrint("[FIB] === KULLANICILAR ===")
        for steamid, userData in pairs(FIB.Config.Users) do
            ply:ChatPrint(steamid .. " -> " .. userData.username .. " (" .. userData.rank .. ")")
        end
        ply:ChatPrint("[FIB] Toplam: " .. table.Count(FIB.Config.Users))
        return ""
    end
    
    -- Oyuncu ekle
    if args[1] == "!fib_ekle" and args[2] then
        local target = nil
        for _, v in ipairs(player.GetAll()) do
            if string.find(string.lower(v:Nick()), string.lower(args[2])) then
                target = v
                break
            end
        end
        
        if target then
            local steamid = target:SteamID()
            local username = "agent" .. math.random(100, 999)
            local password = "fib" .. math.random(1000, 9999)
            
            FIB.Config.Users[steamid] = {
                username = username,
                password = password,
                rank = "Ajan"
            }
            
            SaveConfig()
            
            ply:ChatPrint("[FIB] " .. target:Nick() .. " sisteme eklendi!")
            ply:ChatPrint("[FIB] Username: " .. username .. " | Password: " .. password)
            
            target:ChatPrint("[FIB] ===============================")
            target:ChatPrint("[FIB] SISTEME EKLENDINIZ!")
            target:ChatPrint("[FIB] Username: " .. username)
            target:ChatPrint("[FIB] Password: " .. password)
            target:ChatPrint("[FIB] !fib yazarak giris yapabilirsiniz")
            target:ChatPrint("[FIB] ===============================")
        else
            ply:ChatPrint("[FIB] Oyuncu bulunamadi!")
        end
        
        return ""
    end
end)

-- ============================================
-- SUNUCU BAŞLANGIÇ
-- ============================================
hook.Add("Initialize", "FIB_ServerInit", function()
    print("[FIB] ===================================")
    print("[FIB] Federal Istihbarat Burosu sistemi baslatildi!")
    print("[FIB] Versiyon: 15.0 CONFIG FIXED")
    print("[FIB] ===================================")
    
    -- Default kullanıcıları kontrol et
    timer.Simple(2, function()
        print("[FIB] Default kullanicilar kontrol ediliyor...")
        for steamid, userData in pairs(DEFAULT_USERS) do
            if not FIB.Config.Users[steamid] then
                FIB.Config.Users[steamid] = userData
                print("[FIB] Default kullanici eklendi: " .. userData.username)
            end
        end
        SaveConfig()
        print("[FIB] Toplam " .. table.Count(FIB.Config.Users) .. " kullanici mevcut")
    end)
end)

-- InitPostEntity'de de kontrol et
hook.Add("InitPostEntity", "FIB_PostInit", function()
    timer.Simple(3, function()
        -- Default kullanıcıları tekrar kontrol et
        for steamid, userData in pairs(DEFAULT_USERS) do
            FIB.Config.Users[steamid] = userData
        end
        SaveConfig()
        print("[FIB] Config kontrol edildi - " .. table.Count(FIB.Config.Users) .. " kullanici")
    end)
end)

print("[FIB SYSTEMS] ===================================")
print("[FIB SYSTEMS] Sistemler basariyla yuklendi!")
print("[FIB SYSTEMS] Versiyon: 15.0 CONFIG FIXED")
print("[FIB SYSTEMS] Default kullanicilar:")
for steamid, userData in pairs(DEFAULT_USERS) do
    print("  - " .. steamid .. ": " .. userData.username)
end
print("[FIB SYSTEMS] ===================================")


-- PASSWORD DEBUG KOMUTU
concommand.Add("fib_check_password", function(ply)
    if IsValid(ply) then
        local steamid = ply:SteamID()
        
        if FIB.Config.Users[steamid] then
            local userData = FIB.Config.Users[steamid]
            ply:ChatPrint("[FIB DEBUG] ===========================")
            ply:ChatPrint("[FIB DEBUG] SteamID: " .. steamid)
            ply:ChatPrint("[FIB DEBUG] Username: " .. (userData.username or "YOK"))
            ply:ChatPrint("[FIB DEBUG] Password: " .. (userData.password or "YOK"))
            ply:ChatPrint("[FIB DEBUG] Rank: " .. (userData.rank or "YOK"))
            ply:ChatPrint("[FIB DEBUG] ===========================")
            
            -- Password yoksa otomatik ekle
            if not userData.password then
                ply:ChatPrint("[FIB] SORUN: Password bilgisi eksik! Duzeltiliyor...")
                
                -- Default password'u ekle
                if userData.username == "meloo" then
                    userData.password = "123123asd"
                elseif userData.username == "kod01" then
                    userData.password = "sikici123"
                else
                    userData.password = "fib123" -- Genel password
                end
                
                SaveConfig()
                ply:ChatPrint("[FIB] Password eklendi: " .. userData.password)
            end
        else
            ply:ChatPrint("[FIB] Sistemde kayitli degilsin!")
        end
    end
end)

-- HIZLI FIX KOMUTU
concommand.Add("fib_quick_fix", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    -- Tüm default kullanıcıları düzelt
    FIB.Config.Users["STEAM_0:1:173464330"] = {
        username = "meloo",
        password = "123123asd",
        rank = "Sef"
    }
    
    FIB.Config.Users["STEAM_0:1:441442821"] = {
        username = "kod01", 
        password = "sikici123",
        rank = "Sef"
    }
    
    FIB.Config.Users["STEAM_1:1:441442821"] = {
        username = "kod01",
        password = "sikici123", 
        rank = "Sef"
    }
    
    SaveConfig()
    
    local msg = "[FIB] TUM BILGILER DUZELTILDI!"
    if IsValid(ply) then
        ply:ChatPrint(msg)
        ply:ChatPrint("[FIB] meloo: 123123asd")
        ply:ChatPrint("[FIB] kod01: sikici123")
    else
        print(msg)
    end
end)