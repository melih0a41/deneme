-- fib_sistem/lua/autorun/server/sv_fib_system.lua
-- Server Core - v13.0 COMPLETE

-- ============================================
-- NETWORK STRING TANIMLARI (EN BAŞTA OLMALI!)
-- ============================================
util.AddNetworkString("FIB_AttemptLogin")
util.AddNetworkString("FIB_LoginResponse")
util.AddNetworkString("FIB_UpdateUndercover")
util.AddNetworkString("FIB_ToggleUndercover")
util.AddNetworkString("FIB_SendChatMessage")
util.AddNetworkString("FIB_ChatMessage")
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

-- Save fonksiyonları (uyumluluk için)
FIB.SaveAgents = SaveConfig
FIB.SaveMissions = SaveConfig

-- ============================================
-- CHAT SİSTEMİ
-- ============================================
local function AddChatMessage(ply, message)
    local msgData = {
        sender = ply:Nick(),
        steamid = ply:SteamID(),
        message = message,
        rank = ply:GetNWString("FIB_Rank", "Ajan"),
        time = os.date("%H:%M"),
        timestamp = os.time(),
        undercover = ply:GetNWBool("FIB_Undercover", false)
    }
    
    table.insert(FIB.ChatHistory, msgData)
    
    -- Max 100 mesaj tut
    if #FIB.ChatHistory > 100 then
        table.remove(FIB.ChatHistory, 1)
    end
    
    -- Config'e kaydet
    FIB.Config.ChatHistory = FIB.ChatHistory
    SaveConfig()
    
    -- Tüm FIB ajanlarına gönder
    for _, agent in ipairs(player.GetAll()) do
        if agent:GetNWBool("FIB_Authenticated", false) then
            net.Start("FIB_ChatMessage")
            net.WriteTable(msgData)
            net.Send(agent)
        end
    end
end

-- Chat mesajı gönderme
net.Receive("FIB_SendChatMessage", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    
    local message = net.ReadString()
    if message and message ~= "" then
        AddChatMessage(ply, message)
    end
end)

-- Chat geçmişi isteme
net.Receive("FIB_RequestChatHistory", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    
    net.Start("FIB_ChatHistory")
    net.WriteTable(FIB.ChatHistory)
    net.Send(ply)
end)

-- Chat temizleme (Sadece Şef)
net.Receive("FIB_ClearChat", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    if ply:GetNWString("FIB_Rank", "Ajan") ~= "Sef" then return end
    
    FIB.ChatHistory = {}
    FIB.Config.ChatHistory = {}
    SaveConfig()
    
    -- Tüm ajanlara bildir
    for _, agent in ipairs(player.GetAll()) do
        if agent:GetNWBool("FIB_Authenticated", false) then
            net.Start("FIB_ChatHistory")
            net.WriteTable({})
            net.Send(agent)
        end
    end
end)

-- FIB ÖZEL CHAT KONSOL KOMUTU
concommand.Add("fib_chat", function(ply, cmd, args)
    if not ply:GetNWBool("FIB_Authenticated", false) then
        return
    end
    
    local message = table.concat(args, " ")
    if message == "" then return end
    
    -- Tüm FIB ajanlarına mesajı gönder
    for _, v in ipairs(player.GetAll()) do
        if v:GetNWBool("FIB_Authenticated", false) then
            net.Start("FIB_ChatMessage")
            net.WriteEntity(ply)
            net.WriteString(message)
            net.WriteString(ply:GetNWString("FIB_Rank", "Ajan"))
            net.WriteBool(ply:GetNWBool("FIB_Undercover", false))
            net.Send(v)
            
            -- Chat'e de yaz (sadece FIB ajanları görür)
            v:ChatPrint(Color(0, 120, 255), "[FIB-OZEL] ", 
                       Color(255, 200, 0), "(" .. ply:GetNWString("FIB_Rank", "Ajan") .. ") ",
                       team.GetColor(ply:Team()), ply:Nick(), 
                       Color(255, 255, 255), ": " .. message)
        end
    end
    
    -- Log
    ServerLog("[FIB-CHAT] " .. ply:Nick() .. ": " .. message .. "\n")
end)

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
                
                -- Diğer ajanlara bildir
                timer.Simple(0.5, function()
                    if IsValid(ply) then
                        BroadcastQuickSync()
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
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    
    local isUndercover = not ply:GetNWBool("FIB_Undercover", false)
    ply:SetNWBool("FIB_Undercover", isUndercover)
    ply.FIBUndercover = isUndercover -- Eski değişken de güncelle
    
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
            if v:GetNWBool("FIB_Authenticated", false) and v != ply then
                v:ChatPrint("[FIB] " .. ply:Nick() .. " gizli moda gecti")
            end
        end
    else
        ply:ChatPrint("[FIB] Normal moda donuldu!")
        
        -- FIB silahlarını al
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
            if v:GetNWBool("FIB_Authenticated", false) and v != ply then
                v:ChatPrint("[FIB] " .. ply:Nick() .. " normal moda dondu")
            end
        end
    end
    
    -- Client'ı güncelle
    net.Start("FIB_UpdateUndercover")
    net.WriteBool(isUndercover)
    net.Send(ply)
    
    -- Hook'u tetikle (sync için)
    hook.Run("FIB_UndercoverChanged", ply)
    
    -- Sync gönder
    BroadcastQuickSync()
    
    -- Log
    ServerLog("[FIB] " .. ply:Nick() .. (isUndercover and " gizli moda gecti\n" or " normal moda dondu\n"))
end)

-- Konsol komutu (eski uyumluluk için)
concommand.Add("fibgec", function(ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then
        ply:ChatPrint("[FIB] Bu komutu kullanmak icin FIB sistemine giris yapmalisiniz!")
        return
    end
    
    -- Toggle undercover - net mesaj gönder
    local isUndercover = not ply:GetNWBool("FIB_Undercover", false)
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
        
        -- Silahları ver
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
        
        -- Diğer ajanlara bildir
        for _, v in ipairs(player.GetAll()) do
            if v:GetNWBool("FIB_Authenticated", false) and v != ply then
                v:ChatPrint("[FIB] " .. ply:Nick() .. " gizli moda gecti")
            end
        end
    else
        ply:ChatPrint("[FIB] Normal moda donuldu!")
        
        -- FIB silahlarını al
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
            if v:GetNWBool("FIB_Authenticated", false) and v != ply then
                v:ChatPrint("[FIB] " .. ply:Nick() .. " normal moda dondu")
            end
        end
    end
    
    -- Client güncelle
    net.Start("FIB_UpdateUndercover")
    net.WriteBool(isUndercover)
    net.Send(ply)
    
    -- Hook tetikle
    hook.Run("FIB_UndercoverChanged", ply)
    
    -- Sync
    FIB_SyncAllAgents()
    
    -- Log
    ServerLog("[FIB] " .. ply:Nick() .. (isUndercover and " gizli moda gecti\n" or " normal moda dondu\n"))
end)

-- ============================================
-- GÖREV YÖNETİMİ
-- ============================================

-- Görev oluştur - NET RECEIVER
net.Receive("FIB_CreateMission", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    
    local rank = ply:GetNWString("FIB_Rank", "Ajan")
    if rank ~= "Sef" and rank ~= "Kidemli Ajan" then
        ply:ChatPrint("[FIB] Bu islemi yapma yetkiniz yok!")
        return
    end
    
    local mission = {
        id = #FIB.Missions + 1,
        name = net.ReadString(),
        target = net.ReadString(),
        priority = net.ReadString(),
        status = net.ReadString(),
        assigned = net.ReadString(),
        createdBy = ply:Nick(),
        createdAt = os.time()
    }
    
    table.insert(FIB.Missions, mission)
    
    -- Config'e kaydet
    FIB.Config.Missions = FIB.Missions
    SaveConfig()
    
    -- Tüm ajanlara bildir
    for _, agent in ipairs(player.GetAll()) do
        if agent:GetNWBool("FIB_Authenticated", false) then
            agent:ChatPrint("[FIB] Yeni gorev olusturuldu: " .. mission.name)
            
            net.Start("FIB_MissionUpdate")
            net.WriteString("new")
            net.WriteTable(mission)
            net.Send(agent)
        end
    end
    
    -- Sync gönder
    BroadcastFullSync()
    
    ServerLog("[FIB-MISSION] " .. ply:Nick() .. " yeni gorev olusturdu: " .. mission.name .. "\n")
end)

-- Görev sil - NET RECEIVER
net.Receive("FIB_DeleteMission", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    
    local rank = ply:GetNWString("FIB_Rank", "Ajan")
    if rank ~= "Sef" and rank ~= "Kidemli Ajan" then
        ply:ChatPrint("[FIB] Bu islemi yapma yetkiniz yok!")
        return
    end
    
    local missionName = net.ReadString()
    
    -- Görevi bul ve sil
    for i, mission in ipairs(FIB.Missions) do
        if mission.name == missionName then
            table.remove(FIB.Missions, i)
            
            -- Config'e kaydet
            FIB.Config.Missions = FIB.Missions
            SaveConfig()
            
            -- Tüm ajanlara bildir
            for _, agent in ipairs(player.GetAll()) do
                if agent:GetNWBool("FIB_Authenticated", false) then
                    agent:ChatPrint("[FIB] Gorev silindi: " .. missionName)
                end
            end
            
            -- Sync gönder
            BroadcastFullSync()
            return
        end
    end
    
    ply:ChatPrint("[FIB] Gorev bulunamadi!")
end)

-- Görev durumu güncelle - NET RECEIVER
net.Receive("FIB_UpdateMissionStatus", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    
    local rank = ply:GetNWString("FIB_Rank", "Ajan")
    if rank ~= "Sef" then
        ply:ChatPrint("[FIB] Sadece Sef gorev durumu guncelleyebilir!")
        return
    end
    
    local missionName = net.ReadString()
    local newStatus = net.ReadString()
    
    -- Görevi bul ve güncelle
    for i, mission in ipairs(FIB.Missions) do
        if mission.name == missionName then
            mission.status = newStatus
            mission.updatedBy = ply:Nick()
            mission.updatedAt = os.time()
            
            -- Eğer tamamlandı ise
            if newStatus == "Tamamlandi" then
                mission.completed_date = os.time()
                mission.completed_by = ply:Nick()
            end
            
            -- Config'e kaydet
            FIB.Config.Missions = FIB.Missions
            SaveConfig()
            
            -- Tüm ajanlara bildir
            for _, agent in ipairs(player.GetAll()) do
                if agent:GetNWBool("FIB_Authenticated", false) then
                    agent:ChatPrint("[FIB] Gorev durumu guncellendi: " .. missionName .. " -> " .. newStatus)
                    
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
            BroadcastFullSync()
            
            ServerLog("[FIB] " .. ply:Nick() .. " gorev durumunu guncelledi: " .. missionName .. " -> " .. newStatus .. "\n")
            return
        end
    end
    
    ply:ChatPrint("[FIB] Gorev bulunamadi!")
end)

-- KONSOL KOMUTLARI - GÖREVLER
concommand.Add("fib_mission_create", function(ply, cmd, args)
    if not ply:GetNWBool("FIB_Authenticated", false) or (ply:GetNWString("FIB_Rank", "Ajan") ~= "Sef" and ply:GetNWString("FIB_Rank", "Ajan") ~= "Kidemli Ajan") then
        ply:ChatPrint("[FIB] Bu komutu sadece sef ve kidemli ajanlar kullanabilir!")
        return
    end
    
    local missionName = args[1] or "Isimsiz Gorev"
    local target = args[2] or "Belirtilmemis"
    local priority = args[3] or "NORMAL"
    local status = args[4] or "Planlama"
    
    local mission = {
        id = #FIB.Missions + 1,
        name = missionName,
        target = target,
        priority = priority,
        status = status,
        creator = ply:Nick(),
        assigned = {},
        created = os.time()
    }
    
    table.insert(FIB.Missions, mission)
    
    -- Veriyi kaydet
    FIB.Config.Missions = FIB.Missions
    SaveConfig()
    
    -- Tüm ajanlara bildir
    for _, v in ipairs(player.GetAll()) do
        if v:GetNWBool("FIB_Authenticated", false) then
            v:ChatPrint("[FIB] Yeni gorev olusturuldu: " .. missionName)
            
            net.Start("FIB_MissionUpdate")
            net.WriteString("new")
            net.WriteTable(mission)
            net.Send(v)
        end
    end
    
    ServerLog("[FIB-MISSION] " .. ply:Nick() .. " yeni gorev olusturdu: " .. missionName .. "\n")
end)

concommand.Add("fib_mission_delete", function(ply, cmd, args)
    if not ply:GetNWBool("FIB_Authenticated", false) or (ply:GetNWString("FIB_Rank", "Ajan") ~= "Sef" and ply:GetNWString("FIB_Rank", "Ajan") ~= "Kidemli Ajan") then
        ply:ChatPrint("[FIB] Bu komutu sadece sef ve kidemli ajanlar kullanabilir!")
        return
    end
    
    local missionId = tonumber(args[1])
    
    if not missionId or not FIB.Missions[missionId] then
        ply:ChatPrint("[FIB] Gecersiz gorev ID!")
        return
    end
    
    local missionName = FIB.Missions[missionId].name
    
    -- Görevi sil
    table.remove(FIB.Missions, missionId)
    
    -- Veriyi kaydet
    FIB.Config.Missions = FIB.Missions
    SaveConfig()
    
    -- Bildir
    for _, v in ipairs(player.GetAll()) do
        if v:GetNWBool("FIB_Authenticated", false) then
            v:ChatPrint("[FIB] Gorev silindi: " .. missionName)
        end
    end
    
    ServerLog("[FIB] " .. ply:Nick() .. " gorevi sildi: " .. missionName .. "\n")
end)

concommand.Add("fib_mission_complete", function(ply, cmd, args)
    if not ply:GetNWBool("FIB_Authenticated", false) then
        ply:ChatPrint("[FIB] Bu komutu kullanmak icin FIB ajani olmalisiniz!")
        return
    end
    
    local missionId = tonumber(args[1])
    
    if not missionId or not FIB.Missions[missionId] then
        ply:ChatPrint("[FIB] Gecersiz gorev ID!")
        return
    end
    
    -- Görevi tamamla
    FIB.Missions[missionId].status = "Tamamlandi"
    FIB.Missions[missionId].completed_by = ply:Nick()
    FIB.Missions[missionId].completed_date = os.time()
    
    -- Veriyi kaydet
    FIB.Config.Missions = FIB.Missions
    SaveConfig()
    
    -- Bildir
    for _, v in ipairs(player.GetAll()) do
        if v:GetNWBool("FIB_Authenticated", false) then
            v:ChatPrint("[FIB] Gorev tamamlandi: " .. FIB.Missions[missionId].name)
            v:ChatPrint("[FIB] Tamamlayan: " .. ply:Nick())
        end
    end
    
    ServerLog("[FIB] " .. ply:Nick() .. " gorevi tamamladi: " .. FIB.Missions[missionId].name .. "\n")
end)

concommand.Add("fib_mission_list", function(ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then
        ply:ChatPrint("[FIB] Bu komutu kullanmak icin FIB ajani olmalisiniz!")
        return
    end
    
    ply:ChatPrint("[FIB] === AKTIF GOREVLER ===")
    
    for id, mission in ipairs(FIB.Missions) do
        if mission.status ~= "Tamamlandi" and mission.status ~= "Iptal" then
            ply:ChatPrint("[" .. id .. "] " .. mission.name .. " - Hedef: " .. mission.target .. " - Oncelik: " .. mission.priority .. " - Durum: " .. mission.status)
        end
    end
    
    ply:ChatPrint("[FIB] === TAMAMLANAN GOREVLER ===")
    
    for id, mission in ipairs(FIB.Missions) do
        if mission.status == "Tamamlandi" then
            ply:ChatPrint("[" .. id .. "] " .. mission.name .. " - Tamamlayan: " .. (mission.completed_by or "Bilinmiyor"))
        end
    end
end)

-- ============================================
-- AJAN YÖNETİMİ
-- ============================================

-- Ajan ekleme (Sadece Şef) - NET RECEIVER
net.Receive("FIB_AddAgent", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    if ply:GetNWString("FIB_Rank", "Ajan") ~= "Sef" then 
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
        if v:GetNWBool("FIB_Authenticated", false) and v != ply and v != target then
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
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    if ply:GetNWString("FIB_Rank", "Ajan") ~= "Sef" then return end
    
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
        if v:GetNWBool("FIB_Authenticated", false) and v != ply then
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

-- DETAYLI ADMIN KOMUTLARI
concommand.Add("fib_admin_add", function(ply, cmd, args)
    if IsValid(ply) and (not ply:GetNWBool("FIB_Authenticated", false) or ply:GetNWString("FIB_Rank", "Ajan") ~= "Sef") then
        ply:ChatPrint("[FIB] Bu komutu sadece sefler kullanabilir!")
        return
    end
    
    local targetName = args[1]
    if not targetName then 
        if IsValid(ply) then
            ply:ChatPrint("[FIB] Kullanim: fib_admin_add <oyuncu_ismi>")
        else
            print("[FIB] Kullanim: fib_admin_add <oyuncu_ismi>")
        end
        return 
    end
    
    -- Oyuncuyu bul
    local target = nil
    for _, v in ipairs(player.GetAll()) do
        if string.find(string.lower(v:Nick()), string.lower(targetName)) then
            target = v
            break
        end
    end
    
    if target then
        local steamid = target:SteamID()
        local username = "AGENT" .. math.random(100, 999)
        local password = "FIB#" .. math.random(1000, 9999)
        
        FIB.Config.Users[steamid] = {
            username = username,
            password = password,
            rank = "Ajan",
            added_by = IsValid(ply) and ply:Nick() or "Console",
            added_date = os.time()
        }
        
        SaveConfig()
        
        if IsValid(ply) then
            ply:ChatPrint("[FIB] " .. target:Nick() .. " sisteme eklendi.")
            ply:ChatPrint("[FIB] Kullanici: " .. username .. " | Sifre: " .. password)
        else
            print("[FIB] " .. target:Nick() .. " sisteme eklendi.")
            print("[FIB] Kullanici: " .. username .. " | Sifre: " .. password)
        end
        
        target:ChatPrint("[FIB] Sisteme eklendiniz! !fib yazarak giris yapabilirsiniz.")
        target:ChatPrint("[FIB] Kullanici: " .. username .. " | Sifre: " .. password)
        
        -- Departman güncellemesi
        net.Start("FIB_DepartmentUpdate")
        net.WriteString("add")
        net.WriteString(steamid)
        net.WriteString(username)
        net.WriteString("Ajan")
        net.Broadcast()
        
        -- Hook'u tetikle
        hook.Run("FIB_AgentAdded", steamid)
        
        ServerLog("[FIB-ADMIN] " .. (IsValid(ply) and ply:Nick() or "Console") .. " tarafindan " .. target:Nick() .. " eklendi\n")
    else
        if IsValid(ply) then
            ply:ChatPrint("[FIB] Oyuncu bulunamadi!")
        else
            print("[FIB] Oyuncu bulunamadi!")
        end
    end
end)

concommand.Add("fib_admin_remove", function(ply, cmd, args)
    if IsValid(ply) and (not ply:GetNWBool("FIB_Authenticated", false) or ply:GetNWString("FIB_Rank", "Ajan") ~= "Sef") then
        ply:ChatPrint("[FIB] Bu komutu sadece sefler kullanabilir!")
        return
    end
    
    local steamid = args[1]
    if not steamid then 
        if IsValid(ply) then
            ply:ChatPrint("[FIB] Kullanim: fib_admin_remove <steamid>")
        else
            print("[FIB] Kullanim: fib_admin_remove <steamid>")
        end
        return 
    end
    
    if FIB.Config.Users[steamid] then
        local removedUser = FIB.Config.Users[steamid].username
        
        -- Online ise çık
        for _, v in ipairs(player.GetAll()) do
            if v:SteamID() == steamid then
                v:SetNWBool("FIB_Authenticated", false)
                v:SetNWString("FIB_Rank", "")
                v:SetNWString("FIB_Username", "")
                v:SetNWBool("FIB_Undercover", false)
                v.FIBAuthenticated = false
                v.FIBRank = nil
                v.FIBUsername = nil
                v.FIBUndercover = false
                v:ChatPrint("[FIB] Sistem erisiminiz kaldirildi!")
                break
            end
        end
        
        FIB.Config.Users[steamid] = nil
        SaveConfig()
        
        if IsValid(ply) then
            ply:ChatPrint("[FIB] Kullanici sistemden silindi: " .. steamid)
        else
            print("[FIB] Kullanici sistemden silindi: " .. steamid)
        end
        
        -- Departman güncellemesi
        net.Start("FIB_DepartmentUpdate")
        net.WriteString("remove")
        net.WriteString(steamid)
        net.Broadcast()
        
        -- Hook'u tetikle
        hook.Run("FIB_AgentRemoved", steamid)
        
        ServerLog("[FIB-ADMIN] " .. (IsValid(ply) and ply:Nick() or "Console") .. " tarafindan " .. steamid .. " silindi\n")
    else
        if IsValid(ply) then
            ply:ChatPrint("[FIB] Bu kullanici sistemde bulunamadi!")
        else
            print("[FIB] Bu kullanici sistemde bulunamadi!")
        end
    end
end)

-- ============================================
-- SYNC SİSTEMİ
-- ============================================
function BroadcastFullSync()
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
        if ply:GetNWBool("FIB_Authenticated", false) then
            net.Start("FIB_FullSync")
            net.WriteTable(onlineData)
            net.WriteTable(FIB.Config.Users or {})
            net.WriteTable(FIB.Missions or {})
            net.Send(ply)
        end
    end
end

function BroadcastQuickSync()
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
        if ply:GetNWBool("FIB_Authenticated", false) then
            net.Start("FIB_QuickSync")
            net.WriteTable(onlineData)
            net.Send(ply)
        end
    end
end

function FIB_SyncAllAgents()
    BroadcastFullSync()
end

net.Receive("FIB_RequestSync", function(len, ply)
    if not ply:GetNWBool("FIB_Authenticated", false) then return end
    
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

-- Global sync fonksiyonları
FIB.BroadcastFullSync = BroadcastFullSync
FIB.BroadcastQuickSync = BroadcastQuickSync
FIB.SendSyncToPlayer = function(ply)
    if not IsValid(ply) then return end
    
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

-- Periyodik senkronizasyon
timer.Create("FIB_PeriodicSync", 30, 0, function()
    FIB_SyncAllAgents()
end)

-- ============================================
-- OYUNCU HOOK'LARI
-- ============================================
hook.Add("PlayerDisconnected", "FIB_PlayerLeft", function(ply)
    if ply:GetNWBool("FIB_Authenticated", false) then
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
                if p:GetNWBool("FIB_Authenticated", false) then
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
    if IsValid(ply) and ply:GetNWBool("FIB_Authenticated", false) then
        -- Gizli moddaysa silahları ver
        if ply:GetNWBool("FIB_Undercover", false) then
            timer.Simple(1, function()
                if IsValid(ply) then
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
            BroadcastQuickSync()
        end)
    end
end)

-- ============================================
-- DEDEKTÖR ENTEGRASYONU
-- ============================================
hook.Add("PlayerUse", "FIB_DetectorIntegration", function(ply, ent)
    -- Dedektör kontrolü
    if IsValid(ent) and (ent:GetClass() == "weapon_detector" or ent:GetClass() == "metal_detector") then
        -- Taranıyor
        timer.Simple(2, function()
            if IsValid(ply) and ply:GetNWBool("FIB_Authenticated", false) then
                -- FIB ajanı tespit edildi
                for _, v in ipairs(player.GetAll()) do
                    if v:GetPos():Distance(ent:GetPos()) < 500 then
                        -- DarkRP polis kontrolü
                        if (v.isCP and v:isCP()) or (v.Team and v:Team() == TEAM_POLICE) then
                            v:ChatPrint("[DEDEKTÖR] UYARI: Bu kisi FIB ajani!")
                        end
                    end
                end
            end
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
    print("Sync timer: " .. (timer.Exists("FIB_PeriodicSync") and "AKTIF" or "KAPALI"))
    
    local onlineAgents = 0
    local undercoverAgents = 0
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v:GetNWBool("FIB_Authenticated", false) then
            onlineAgents = onlineAgents + 1
            if v:GetNWBool("FIB_Undercover", false) then
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

-- ============================================
-- BASIT ADMIN KOMUTLARI
-- ============================================
concommand.Add("fib_add_admin", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    local steamid = args[1] or "STEAM_0:0:11111111"
    local username = args[2] or "admin"
    local password = args[3] or "admin123"
    
    FIB.Config.Users[steamid] = {
        username = username,
        password = password,
        rank = "Sef"
    }
    
    SaveConfig()
    print("[FIB] Admin eklendi - SteamID: " .. steamid .. " | Username: " .. username)
end)

concommand.Add("fib_list_agents", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    print("\n[FIB] Kayitli Ajanlar:")
    print("=====================================")
    for steamid, data in pairs(FIB.Config.Users) do
        print("SteamID: " .. steamid)
        print("Username: " .. data.username)
        print("Rank: " .. data.rank)
        print("-------------------------------------")
    end
    print("Toplam: " .. table.Count(FIB.Config.Users) .. " ajan")
end)

print("[FIB SYSTEMS] ===================================")
print("[FIB SYSTEMS] Sistemler basariyla yuklendi!")
print("[FIB SYSTEMS] Versiyon: 13.0 COMPLETE (838 satir)")
print("[FIB SYSTEMS] ===================================")