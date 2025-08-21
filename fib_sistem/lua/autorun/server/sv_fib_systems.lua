-- fib_sistem/lua/autorun/server/sv_fib_systems.lua
-- Server Core - v14.0 FIXED

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

-- Config loader
local function LoadConfig()
    if not file.Exists("fib_sistem/config.json", "DATA") then
        -- Varsayılan config
        local defaultConfig = {
            Users = {
                ["STEAM_0:0:11111111"] = {
                    username = "admin",
                    password = "admin123",
                    rank = "Sef"
                }
            },
            ChatHistory = {},
            Missions = {}
        }
        
        file.CreateDir("fib_sistem")
        file.Write("fib_sistem/config.json", util.TableToJSON(defaultConfig, true))
        return defaultConfig
    end
    
    local data = file.Read("fib_sistem/config.json", "DATA")
    return util.JSONToTable(data) or {}
end

local function SaveConfig()
    file.Write("fib_sistem/config.json", util.TableToJSON(FIB.Config, true))
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
-- GİRİŞ SİSTEMİ
-- ============================================
net.Receive("FIB_AttemptLogin", function(len, ply)
    local username = net.ReadString()
    local password = net.ReadString()
    
    for steamid, userData in pairs(FIB.Config.Users) do
        if userData.username == username and userData.password == password then
            if ply:SteamID() == steamid then
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
                net.Start("FIB_LoginResponse")
                net.WriteBool(false)
                net.WriteString("Bu hesap baska bir SteamID'ye kayitli!")
                net.Send(ply)
                return
            end
        end
    end
    
    net.Start("FIB_LoginResponse")
    net.WriteBool(false)
    net.WriteString("Gecersiz kullanici adi veya sifre!")
    net.Send(ply)
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
    print("Kayitli toplam ajan: " .. table.Count(FIB.Config.Users))
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB SYSTEMS] Debug bilgisi konsola yazildi")
    end
end)

-- ============================================
-- SUNUCU BAŞLANGIÇ
-- ============================================
hook.Add("Initialize", "FIB_ServerInit", function()
    print("[FIB] Federal Istihbarat Burosu sistemi baslatildi!")
    print("[FIB] Kayitli ajan sayisi: " .. table.Count(FIB.Config.Users))
end)

print("[FIB SYSTEMS] ===================================")
print("[FIB SYSTEMS] Sistemler basariyla yuklendi!")
print("[FIB SYSTEMS] Versiyon: 14.0 FIXED")
print("[FIB SYSTEMS] ===================================")