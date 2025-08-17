-- fib_sistem/lua/autorun/server/sv_fib_sync_fix.lua
-- Senkronizasyon Sorunları Düzeltmesi - STABLE VERSION

-- Network strings (eğer tanımlanmamışsa)
util.AddNetworkString("FIB_RequestSync")
util.AddNetworkString("FIB_FullSync")
util.AddNetworkString("FIB_AgentListUpdate")
util.AddNetworkString("FIB_QuickSync")
util.AddNetworkString("FIB_AgentJoined")
util.AddNetworkString("FIB_AgentLeft")

-- Global FIB tablosu
FIB = FIB or {}
FIB.OnlineAgents = FIB.OnlineAgents or {}

-- ============================================
-- AJAN LİSTESİNİ GÜNCELLE - STABLE
-- ============================================
function FIB.UpdateOnlineAgents()
    local newList = {}
    
    -- Tüm oyuncuları kontrol et
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply.FIBAuthenticated then
            table.insert(newList, {
                steamid = ply:SteamID(),
                nick = ply:Nick(),
                rank = ply.FIBRank or "Ajan",
                username = ply.FIBUsername or "Unknown",
                undercover = ply.FIBUndercover or false,
                loginTime = ply.FIBLoginTime or 0
            })
        end
    end
    
    FIB.OnlineAgents = newList
    
    print("[FIB SYNC] Online ajanlar guncellendi: " .. #FIB.OnlineAgents .. " ajan")
    
    -- Debug için listeyi yazdır
    if #FIB.OnlineAgents > 0 then
        for i, agent in ipairs(FIB.OnlineAgents) do
            print("  [" .. i .. "] " .. agent.nick .. " (" .. agent.steamid .. ") - " .. agent.rank)
        end
    end
    
    return newList
end

-- ============================================
-- TÜM AJANLARA FULL SYNC GÖNDER
-- ============================================
function FIB.BroadcastFullSync()
    -- Önce listeyi güncelle
    local agents = FIB.UpdateOnlineAgents()
    
    -- Boş liste kontrolü
    if not agents then
        print("[FIB SYNC] Ajan listesi bos veya hata var!")
        return
    end
    
    -- Tüm FIB ajanlarına gönder
    local sentCount = 0
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply.FIBAuthenticated then
            net.Start("FIB_FullSync")
            net.WriteTable(agents)
            net.WriteTable(FIB.Config.Users or {})
            net.WriteTable(FIB.Missions or {})
            net.Send(ply)
            sentCount = sentCount + 1
        end
    end
    
    print("[FIB SYNC] Full sync gonderildi: " .. sentCount .. " ajana")
end

-- ============================================
-- TEK BİR AJANA SYNC GÖNDER
-- ============================================
function FIB.SendSyncToPlayer(ply)
    if not IsValid(ply) or not ply.FIBAuthenticated then 
        print("[FIB SYNC] Gecersiz oyuncu veya yetkisiz!")
        return 
    end
    
    -- Güncel listeyi al
    local agents = FIB.UpdateOnlineAgents()
    
    net.Start("FIB_FullSync")
    net.WriteTable(agents)
    net.WriteTable(FIB.Config.Users or {})
    net.WriteTable(FIB.Missions or {})
    net.Send(ply)
    
    print("[FIB SYNC] Ozel sync gonderildi: " .. ply:Nick() .. " - " .. #agents .. " ajan")
end

-- ============================================
-- CLIENT'TAN SYNC İSTEĞİ
-- ============================================
net.Receive("FIB_RequestSync", function(len, ply)
    if not IsValid(ply) or not ply.FIBAuthenticated then
        print("[FIB SYNC] Yetkisiz sync istegi!")
        return
    end
    
    print("[FIB SYNC] Sync istegi alindi: " .. ply:Nick())
    
    -- Tek oyuncuya gönder
    FIB.SendSyncToPlayer(ply)
end)

-- ============================================
-- AJAN GİRİŞ YAPTIĞINDA
-- ============================================
hook.Add("FIB_AgentLogin", "FIB_SyncOnLogin", function(ply)
    if not IsValid(ply) then return end
    
    print("[FIB SYNC] Ajan giris yapti: " .. ply:Nick())
    
    -- 0.5 saniye bekle ve sync gönder
    timer.Simple(0.5, function()
        if IsValid(ply) and ply.FIBAuthenticated then
            -- Önce giriş yapana gönder
            FIB.SendSyncToPlayer(ply)
            
            -- Sonra herkese bildir
            timer.Simple(0.5, function()
                FIB.BroadcastFullSync()
            end)
        end
    end)
end)

-- ============================================
-- GİZLİ MOD DEĞİŞTİĞİNDE
-- ============================================
hook.Add("FIB_UndercoverChanged", "FIB_SyncOnUndercover", function(ply)
    if not IsValid(ply) then return end
    
    print("[FIB SYNC] Gizli mod degisti: " .. ply:Nick() .. " - " .. tostring(ply.FIBUndercover))
    
    -- 0.2 saniye bekle ve sync
    timer.Simple(0.2, function()
        FIB.BroadcastFullSync()
    end)
end)

-- ============================================
-- OYUNCU ÇIKIŞ YAPTIĞINDA
-- ============================================
hook.Add("PlayerDisconnected", "FIB_SyncOnDisconnect", function(ply)
    if ply.FIBAuthenticated then
        local steamid = ply:SteamID()
        local nick = ply:Nick()
        
        print("[FIB SYNC] FIB ajani cikis yapti: " .. nick)
        
        -- Hemen listeyi güncelle
        timer.Simple(0.5, function()
            FIB.UpdateOnlineAgents()
            
            -- Herkese çıkış bilgisi gönder
            for _, p in ipairs(player.GetAll()) do
                if IsValid(p) and p.FIBAuthenticated then
                    net.Start("FIB_AgentLeft")
                    net.WriteString(steamid)
                    net.WriteString(nick)
                    net.Send(p)
                end
            end
            
            -- 1 saniye sonra full sync
            timer.Simple(0.5, function()
                FIB.BroadcastFullSync()
            end)
        end)
    end
end)

-- ============================================
-- PERİYODİK SYNC (Her 15 saniyede bir)
-- ============================================
timer.Create("FIB_PeriodicFullSync", 15, 0, function()
    local agentCount = 0
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply.FIBAuthenticated then
            agentCount = agentCount + 1
        end
    end
    
    if agentCount > 0 then
        print("[FIB SYNC] Periyodik sync yapiliyor...")
        FIB.BroadcastFullSync()
    end
end)

-- ============================================
-- MANUEL SYNC KOMUTU
-- ============================================
concommand.Add("fib_force_sync", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    print("[FIB SYNC] Manuel sync baslatiliyor...")
    FIB.BroadcastFullSync()
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Senkronizasyon gonderildi!")
    end
end)

-- ============================================
-- DEBUG KOMUTU
-- ============================================
concommand.Add("fib_sync_debug", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    print("[FIB SYNC] === SYNC DEBUG ===")
    print("FIB.OnlineAgents tablosu: " .. #FIB.OnlineAgents .. " kayit")
    
    print("\nOnline Ajanlar (REALTIME):")
    local count = 0
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v.FIBAuthenticated then
            count = count + 1
            print("  [" .. count .. "] " .. v:Nick())
            print("      - SteamID: " .. v:SteamID())
            print("      - Rank: " .. (v.FIBRank or "YOK"))
            print("      - Undercover: " .. tostring(v.FIBUndercover or false))
        end
    end
    
    print("\nToplam: " .. count .. " online ajan")
    print("Config'deki toplam ajan: " .. table.Count(FIB.Config.Users or {}))
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Debug bilgisi konsola yazildi")
    end
end)

-- ============================================
-- AJAN EKLEME/SİLME SONRASI SYNC
-- ============================================
hook.Add("FIB_AgentAdded", "FIB_SyncOnAdd", function(steamid)
    print("[FIB SYNC] Yeni ajan eklendi, sync gonderiliyor...")
    timer.Simple(1, function()
        FIB.BroadcastFullSync()
    end)
end)

hook.Add("FIB_AgentRemoved", "FIB_SyncOnRemove", function(steamid)
    print("[FIB SYNC] Ajan silindi, sync gonderiliyor...")
    timer.Simple(1, function()
        FIB.BroadcastFullSync()
    end)
end)

print("[FIB SYNC] Senkronizasyon sistemi yuklendi! (v5.0 - Stable)")
print("[FIB SYNC] Periyodik sync: 15 saniye")