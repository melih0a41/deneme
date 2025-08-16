-- fib_sistem/lua/autorun/server/sv_fib_systems.lua
-- FIB Sistemleri - TÜM GÜNCELLEMELER DAHİL

-- ============================================
-- NETWORK STRING TANIMLARI (EN BAŞTA OLMALI!)
-- ============================================
util.AddNetworkString("FIB_UpdateUndercover")
util.AddNetworkString("FIB_ChatMessage")
util.AddNetworkString("FIB_MissionUpdate")
util.AddNetworkString("FIB_DepartmentUpdate")
util.AddNetworkString("FIB_SyncData")
util.AddNetworkString("FIB_AddAgent")      -- Ajan ekleme için
util.AddNetworkString("FIB_RemoveAgent")   -- Ajan silme için
util.AddNetworkString("FIB_RequestSync")   -- Sync isteği için
util.AddNetworkString("FIB_FullSync")      -- Full sync için
util.AddNetworkString("FIB_AgentListUpdate") -- Liste güncellemesi için
util.AddNetworkString("FIB_KickedFromSystem")  -- Sistemden atılma için

print("[FIB SYSTEMS] Network string'ler tanimlandi!")

-- ============================================
-- GİZLİ MOD SİSTEMİ
-- ============================================
concommand.Add("fibgec", function(ply)
    -- FIB yetkisi kontrolü
    if not ply.FIBAuthenticated then
        ply:ChatPrint("[FIB] Bu komutu kullanmak icin FIB sistemine giris yapmalisiniz!")
        return
    end
    
    -- Toggle undercover
    ply.FIBUndercover = not ply.FIBUndercover
    
    if ply.FIBUndercover then
        -- Gizli moda geç
        ply:ChatPrint("[FIB] Gizli mod AKTIF - Diger ajanlar sizi gorebilir")
        
        -- Silahları ver (varsa)
        if weapons.Get("weapon_fib_pistol") then
            ply:Give("weapon_fib_pistol")
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
            if v.FIBAuthenticated and v != ply then
                v:ChatPrint("[FIB] " .. ply:Nick() .. " gizli moda gecti")
            end
        end
        
        -- Log
        ServerLog("[FIB] " .. ply:Nick() .. " gizli moda gecti\n")
    else
        -- Normal moda dön
        ply:ChatPrint("[FIB] Gizli mod KAPALI - Normal moddasiniz")
        
        -- FIB silahlarını al (normal silahları bırak)
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
        
        -- Log
        ServerLog("[FIB] " .. ply:Nick() .. " normal moda dondu\n")
    end
    
    -- Client'ı güncelle
    net.Start("FIB_UpdateUndercover")
    net.WriteBool(ply.FIBUndercover)
    net.Send(ply)
    
    -- Tüm FIB ajanlarına senkronize et
    FIB_SyncAllAgents()
end)

-- ============================================
-- FIB ÖZEL CHAT SİSTEMİ
-- ============================================
concommand.Add("fib_chat", function(ply, cmd, args)
    if not ply.FIBAuthenticated then
        return
    end
    
    local message = table.concat(args, " ")
    if message == "" then return end
    
    -- Tüm FIB ajanlarına mesajı gönder
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            net.Start("FIB_ChatMessage")
            net.WriteEntity(ply)
            net.WriteString(message)
            net.WriteString(ply.FIBRank or "Ajan")
            net.WriteBool(ply.FIBUndercover or false)
            net.Send(v)
            
            -- Chat'e de yaz (sadece FIB ajanları görür)
            v:ChatPrint(Color(0, 120, 255), "[FIB-OZEL] ", 
                       Color(255, 200, 0), "(" .. (ply.FIBRank or "Ajan") .. ") ",
                       team.GetColor(ply:Team()), ply:Nick(), 
                       Color(255, 255, 255), ": " .. message)
        end
    end
    
    -- Log
    ServerLog("[FIB-CHAT] " .. ply:Nick() .. ": " .. message .. "\n")
end)

-- ============================================
-- CLIENT SYNC İSTEĞİ RECEIVER
-- ============================================
net.Receive("FIB_RequestSync", function(len, ply)
    if not ply.FIBAuthenticated then
        print("[FIB SYNC] Yetkisiz sync istegi: " .. ply:Nick())
        return
    end
    
    print("[FIB SYNC] Sync istegi alindi: " .. ply:Nick())
    
    if FIB.SendSyncToPlayer then
        FIB.SendSyncToPlayer(ply)
    else
        -- Fallback
        FIB_SyncAllAgents()
    end
end)

-- ============================================
-- AJAN EKLEME NET RECEIVER
-- ============================================
net.Receive("FIB_AddAgent", function(len, ply)
    -- Debug
    print("[FIB] AddAgent istegi alindi: " .. ply:Nick())
    
    -- Yetki kontrolü
    if not ply.FIBAuthenticated then
        ply:ChatPrint("[FIB] Sisteme giris yapmalisiniz!")
        return
    end
    
    if ply.FIBRank != "Sef" then
        ply:ChatPrint("[FIB] Bu islemi sadece sefler yapabilir!")
        print("[FIB] Yetkisiz ekleme denemesi: " .. ply:Nick() .. " - Rutbe: " .. (ply.FIBRank or "YOK"))
        return
    end
    
    local target = net.ReadEntity()
    local username = net.ReadString()
    local password = net.ReadString()
    local rank = net.ReadString()
    
    -- Entity validasyon
    if not IsValid(target) then 
        ply:ChatPrint("[FIB] Gecersiz oyuncu!")
        print("[FIB] Gecersiz entity!")
        return 
    end
    
    local steamid = target:SteamID()
    
    -- Zaten sistemde mi kontrol et
    if FIB.Config.Users[steamid] then
        ply:ChatPrint("[FIB] Bu oyuncu zaten sistemde!")
        return
    end
    
    print("[FIB] Yeni ajan ekleniyor:")
    print("  - Hedef: " .. target:Nick() .. " (" .. steamid .. ")")
    print("  - Username: " .. username)
    print("  - Rank: " .. rank)
    print("  - Ekleyen: " .. ply:Nick())
    
    -- Kullanıcıyı ekle
    FIB.Config.Users[steamid] = {
        username = username,
        password = password,
        rank = rank,
        added_by = ply:Nick(),
        added_date = os.time()
    }
    
    -- Veriyi kaydet (eğer persistence sistemi varsa)
    if FIB.SaveAgents then
        FIB.SaveAgents()
        print("[FIB] Veri kaydedildi!")
    end
    
    -- Hedef oyuncuya bildir
    target:ChatPrint("[FIB] ===============================")
    target:ChatPrint("[FIB] SISTEME EKLENDINIZ!")
    target:ChatPrint("[FIB] Kullanici Adi: " .. username)
    target:ChatPrint("[FIB] Sifre: " .. password)
    target:ChatPrint("[FIB] Rutbe: " .. rank)
    target:ChatPrint("[FIB] !fib yazarak giris yapabilirsiniz")
    target:ChatPrint("[FIB] ===============================")
    
    -- Ekleyen kişiye onay
    ply:ChatPrint("[FIB] " .. target:Nick() .. " basariyla sisteme eklendi!")
    
    -- Tüm FIB ajanlarına bildir
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated and v != ply and v != target then
            v:ChatPrint("[FIB] " .. target:Nick() .. " sisteme eklendi (" .. rank .. ")")
        end
    end
    
    -- Departman güncellemesi gönder
    net.Start("FIB_DepartmentUpdate")
    net.WriteString("add")
    net.WriteString(steamid)
    net.WriteString(username)
    net.WriteString(rank)
    net.Broadcast()
    
    -- Hook'u tetikle (sync için)
    hook.Run("FIB_AgentAdded", steamid)
    
    -- Log
    ServerLog("[FIB] " .. ply:Nick() .. " tarafindan " .. target:Nick() .. " sisteme eklendi (Rank: " .. rank .. ")\n")
end)

-- ============================================
-- AJAN SİLME NET RECEIVER
-- ============================================
-- ============================================
-- AJAN SİLME NET RECEIVER - GÜNCELLENMİŞ
-- ============================================
net.Receive("FIB_RemoveAgent", function(len, ply)
    -- Debug
    print("[FIB] RemoveAgent istegi alindi: " .. ply:Nick())
    
    -- Yetki kontrolü
    if not ply.FIBAuthenticated then
        ply:ChatPrint("[FIB] Sisteme giris yapmalisiniz!")
        return
    end
    
    if ply.FIBRank != "Sef" then
        ply:ChatPrint("[FIB] Bu islemi sadece sefler yapabilir!")
        print("[FIB] Yetkisiz silme denemesi: " .. ply:Nick() .. " - Rutbe: " .. (ply.FIBRank or "YOK"))
        return
    end
    
    local steamid = net.ReadString()
    
    print("[FIB] Silinecek SteamID: " .. steamid)
    
    -- Kullanıcı var mı kontrol et
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
    
    print("[FIB] Ajan siliniyor:")
    print("  - Username: " .. removedUser)
    print("  - Rank: " .. removedRank)
    print("  - Silen: " .. ply:Nick())
    
    -- Kullanıcıyı sil
    FIB.Config.Users[steamid] = nil
    
    -- Veriyi kaydet (eğer persistence sistemi varsa)
    if FIB.SaveAgents then
        FIB.SaveAgents()
        print("[FIB] Veri kaydedildi!")
    end
    
    -- Online ise sistemden çık ve KICKED mesajı gönder
    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            -- ÖNCE kicked mesajını gönder
            net.Start("FIB_KickedFromSystem")
            net.Send(v)
            
            -- Sonra değişkenleri temizle
            timer.Simple(0.1, function()
                if IsValid(v) then
                    v.FIBAuthenticated = false
                    v.FIBRank = nil
                    v.FIBUsername = nil
                    v.FIBUndercover = false
                    v:ChatPrint("[FIB] ===============================")
                    v:ChatPrint("[FIB] SISTEM ERISIMINIZ KALDIRILDI!")
                    v:ChatPrint("[FIB] ===============================")
                end
            end)
            break
        end
    end
    
    -- Silen kişiye onay
    ply:ChatPrint("[FIB] " .. removedUser .. " (" .. removedRank .. ") sistemden cikarildi!")
    
    -- Tüm FIB ajanlarına bildir
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated and v != ply then
            v:ChatPrint("[FIB] " .. removedUser .. " sistemden cikarildi")
        end
    end
    
    -- Departman güncellemesi gönder
    net.Start("FIB_DepartmentUpdate")
    net.WriteString("remove")
    net.WriteString(steamid)
    net.Broadcast()
    
    -- Hook'u tetikle (sync için)
    hook.Run("FIB_AgentRemoved", steamid)
    
    -- Log
    ServerLog("[FIB] " .. ply:Nick() .. " tarafindan " .. removedUser .. " (" .. steamid .. ") sistemden cikarildi\n")
end)

-- ============================================
-- KONSOL ADMIN KOMUTLARI
-- ============================================
concommand.Add("fib_admin_add", function(ply, cmd, args)
    if IsValid(ply) and (not ply.FIBAuthenticated or ply.FIBRank != "Sef") then
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
        
        -- Veriyi kaydet
        if FIB.SaveAgents then
            FIB.SaveAgents()
        end
        
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
        
        -- Hook'u tetikle (sync için)
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
    if IsValid(ply) and (not ply.FIBAuthenticated or ply.FIBRank != "Sef") then
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
                v.FIBAuthenticated = false
                v.FIBRank = nil
                v.FIBUndercover = false
                v:ChatPrint("[FIB] Sistem erisiminiz kaldirildi!")
                break
            end
        end
        
        FIB.Config.Users[steamid] = nil
        
        -- Veriyi kaydet
        if FIB.SaveAgents then
            FIB.SaveAgents()
        end
        
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
        
        -- Hook'u tetikle (sync için)
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
-- GÖREV SİSTEMİ
-- ============================================
FIB.Missions = FIB.Missions or {}

concommand.Add("fib_mission_create", function(ply, cmd, args)
    if not ply.FIBAuthenticated or (ply.FIBRank != "Sef" and ply.FIBRank != "Kidemli Ajan") then
        ply:ChatPrint("[FIB] Bu komutu sadece sef ve kidemli ajanlar kullanabilir!")
        return
    end
    
    local missionName = args[1] or "Isimsiz Gorev"
    local target = args[2] or "Belirtilmemis"
    local priority = args[3] or "NORMAL"
    
    local mission = {
        id = #FIB.Missions + 1,
        name = missionName,
        target = target,
        priority = priority,
        status = "Aktif",
        creator = ply:Nick(),
        assigned = {},
        created = os.time()
    }
    
    table.insert(FIB.Missions, mission)
    
    -- Veriyi kaydet
    if FIB.SaveMissions then
        FIB.SaveMissions()
        print("[FIB] Yeni gorev veritabanina kaydedildi: " .. missionName)
    end
    
    -- Tüm ajanlara bildir
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
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
    if not ply.FIBAuthenticated or (ply.FIBRank != "Sef" and ply.FIBRank != "Kidemli Ajan") then
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
    if FIB.SaveMissions then
        FIB.SaveMissions()
    end
    
    -- Bildir
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            v:ChatPrint("[FIB] Gorev silindi: " .. missionName)
        end
    end
    
    ServerLog("[FIB] " .. ply:Nick() .. " gorevi sildi: " .. missionName .. "\n")
end)

concommand.Add("fib_mission_complete", function(ply, cmd, args)
    if not ply.FIBAuthenticated then
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
    if FIB.SaveMissions then
        FIB.SaveMissions()
    end
    
    -- Bildir
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            v:ChatPrint("[FIB] Gorev tamamlandi: " .. FIB.Missions[missionId].name)
            v:ChatPrint("[FIB] Tamamlayan: " .. ply:Nick())
        end
    end
    
    ServerLog("[FIB] " .. ply:Nick() .. " gorevi tamamladi: " .. FIB.Missions[missionId].name .. "\n")
end)

concommand.Add("fib_mission_list", function(ply)
    if not ply.FIBAuthenticated then
        ply:ChatPrint("[FIB] Bu komutu kullanmak icin FIB ajani olmalisiniz!")
        return
    end
    
    ply:ChatPrint("[FIB] === AKTIF GOREVLER ===")
    
    for id, mission in ipairs(FIB.Missions) do
        if mission.status == "Aktif" then
            ply:ChatPrint("[" .. id .. "] " .. mission.name .. " - Hedef: " .. mission.target .. " - Oncelik: " .. mission.priority)
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
-- SENKRONİZASYON
-- ============================================
function FIB_SyncAllAgents()
    local agentData = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            table.insert(agentData, {
                entity = ply,
                steamid = ply:SteamID(),
                nick = ply:Nick(),
                rank = ply.FIBRank,
                username = ply.FIBUsername,
                undercover = ply.FIBUndercover or false,
                pos = ply:GetPos()
            })
        end
    end
    
    -- Tüm FIB ajanlarına gönder
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            net.Start("FIB_FullSync")
            net.WriteTable(agentData)
            net.WriteTable(FIB.Config.Users or {})
            net.WriteTable(FIB.Missions or {})
            net.Send(ply)
        end
    end
end

-- Periyodik senkronizasyon (30 saniyede bir - optimize edildi)
timer.Create("FIB_PeriodicSync", 30, 0, function()
    FIB_SyncAllAgents()
end)

-- ============================================
-- DEDEKTÖR ENTEGRASYONU
-- ============================================
hook.Add("PlayerUse", "FIB_DetectorIntegration", function(ply, ent)
    -- Dedektör kontrolü (örnek)
    if IsValid(ent) and (ent:GetClass() == "weapon_detector" or ent:GetClass() == "metal_detector") then
        -- Taranıyor
        timer.Simple(2, function()
            if IsValid(ply) and ply.FIBAuthenticated then
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
-- OYUNCU SPAWN HOOK'U
-- ============================================
hook.Add("PlayerSpawn", "FIB_PlayerSpawn", function(ply)
    if ply.FIBAuthenticated then
        -- Gizli moddaysa silahları ver
        if ply.FIBUndercover then
            timer.Simple(1, function()
                if IsValid(ply) then
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
            FIB_SyncAllAgents()
        end)
    end
end)

-- ============================================
-- DEBUG KOMUTLARI
-- ============================================
concommand.Add("fib_systems_debug", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    print("[FIB SYSTEMS] === DEBUG ===")
    print("Network string'ler: OK")
    print("Gorev sayisi: " .. #FIB.Missions)
    print("Sync timer: " .. (timer.Exists("FIB_PeriodicSync") and "AKTIF" or "KAPALI"))
    
    local onlineAgents = 0
    local undercoverAgents = 0
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            onlineAgents = onlineAgents + 1
            if v.FIBUndercover then
                undercoverAgents = undercoverAgents + 1
            end
        end
    end
    
    print("Online ajanlar: " .. onlineAgents)
    print("Gizli moddakiler: " .. undercoverAgents)
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB SYSTEMS] Debug bilgisi konsola yazildi")
    end
end)

print("[FIB SYSTEMS] ===================================")
print("[FIB SYSTEMS] Sistemler basariyla yuklendi!")
print("[FIB SYSTEMS] Versiyon: 2.1 (Full Sync Destekli)")
print("[FIB SYSTEMS] ===================================")