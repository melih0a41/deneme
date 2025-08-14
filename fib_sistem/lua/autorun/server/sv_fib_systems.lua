-- fib_sistem/lua/autorun/server/sv_fib_systems.lua

-- Network strings
util.AddNetworkString("FIB_UpdateUndercover")
util.AddNetworkString("FIB_ChatMessage")
util.AddNetworkString("FIB_MissionUpdate")
util.AddNetworkString("FIB_DepartmentUpdate")
util.AddNetworkString("FIB_SyncData")

-- Gizli mod sistemi
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
        
        -- Silahları ver
        ply:Give("weapon_fib_pistol") -- Özel FIB silahı (varsa)
        ply:Give("dsr_lockpick") -- Maymuncuk
        ply:Give("bkeypads_cracker") -- Keypad cracker
        ply:Give("weapon_kidnap") -- Kaçırma aleti
        
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
        ply:StripWeapon("dsr_lockpick")
        ply:StripWeapon("bkeypads_cracker")
        ply:StripWeapon("weapon_kidnap")
        
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

-- FIB özel chat sistemi
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

-- Admin komutları (departman yönetimi)
concommand.Add("fib_admin_add", function(ply, cmd, args)
    if not ply.FIBAuthenticated or ply.FIBRank != "Sef" then
        ply:ChatPrint("[FIB] Bu komutu sadece sefler kullanabilir!")
        return
    end
    
    local targetName = args[1]
    if not targetName then return end
    
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
            rank = "Ajan"
        }
        
        ply:ChatPrint("[FIB] " .. target:Nick() .. " sisteme eklendi.")
        ply:ChatPrint("[FIB] Kullanici: " .. username .. " | Sifre: " .. password)
        target:ChatPrint("[FIB] Sisteme eklendiniz! !fib yazarak giris yapabilirsiniz.")
        target:ChatPrint("[FIB] Kullanici: " .. username .. " | Sifre: " .. password)
        
        -- Departman güncellemesi
        net.Start("FIB_DepartmentUpdate")
        net.WriteString("add")
        net.WriteString(steamid)
        net.WriteString(username)
        net.WriteString("Ajan")
        net.Broadcast()
        
        ServerLog("[FIB-ADMIN] " .. ply:Nick() .. " tarafindan " .. target:Nick() .. " eklendi\n")
    else
        ply:ChatPrint("[FIB] Oyuncu bulunamadi!")
    end
end)

concommand.Add("fib_admin_remove", function(ply, cmd, args)
    if not ply.FIBAuthenticated or ply.FIBRank != "Sef" then
        ply:ChatPrint("[FIB] Bu komutu sadece sefler kullanabilir!")
        return
    end
    
    local steamid = args[1]
    if not steamid then return end
    
    if FIB.Config.Users[steamid] then
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
        ply:ChatPrint("[FIB] Kullanici sistemden silindi: " .. steamid)
        
        -- Departman güncellemesi
        net.Start("FIB_DepartmentUpdate")
        net.WriteString("remove")
        net.WriteString(steamid)
        net.Broadcast()
        
        ServerLog("[FIB-ADMIN] " .. ply:Nick() .. " tarafindan " .. steamid .. " silindi\n")
    else
        ply:ChatPrint("[FIB] Bu kullanici sistemde bulunamadi!")
    end
end)

-- Görev sistemi (basit)
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

-- Senkronizasyon
function FIB_SyncAllAgents()
    local agentData = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            table.insert(agentData, {
                entity = ply,
                nick = ply:Nick(),
                rank = ply.FIBRank,
                undercover = ply.FIBUndercover or false,
                pos = ply:GetPos()
            })
        end
    end
    
    -- Tüm FIB ajanlarına gönder
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            net.Start("FIB_SyncData")
            net.WriteTable(agentData)
            net.WriteTable(FIB.Missions or {})
            net.Send(ply)
        end
    end
end

-- Periyodik senkronizasyon
timer.Create("FIB_PeriodicSync", 5, 0, function()
    FIB_SyncAllAgents()
end)

-- Dedektör entegrasyonu (eğer dedektör sistemi varsa)
hook.Add("PlayerUse", "FIB_DetectorIntegration", function(ply, ent)
    -- Dedektör kontrolü (örnek)
    if ent:GetClass() == "weapon_detector" or ent:GetClass() == "metal_detector" then
        -- Taranıyor
        timer.Simple(2, function()
            if IsValid(ply) and ply.FIBAuthenticated then
                -- FIB ajanı tespit edildi
                for _, v in ipairs(player.GetAll()) do
                    if v:GetPos():Distance(ent:GetPos()) < 500 then
                        if v:isCP() or v:Team() == TEAM_POLICE then -- DarkRP polis kontrolü
                            v:ChatPrint("[DEDEKTÖR] UYARI: Bu kisi FIB ajani!")
                        end
                    end
                end
            end
        end)
    end
end)

-- Oyuncu spawn olduğunda
hook.Add("PlayerSpawn", "FIB_PlayerSpawn", function(ply)
    if ply.FIBAuthenticated then
        -- Gizli moddaysa silahları ver
        if ply.FIBUndercover then
            timer.Simple(1, function()
                if IsValid(ply) then
                    ply:Give("dsr_lockpick")
                    ply:Give("bkeypads_cracker")
                    ply:Give("weapon_kidnap")
                end
            end)
        end
        
        -- Senkronize et
        timer.Simple(2, function()
            FIB_SyncAllAgents()
        end)
    end
end)