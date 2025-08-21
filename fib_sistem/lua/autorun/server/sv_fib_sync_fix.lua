-- fib_sistem/lua/autorun/server/sv_fib_sync_fix.lua
-- Senkronizasyon Sistemi - OPTIMIZED v6.0

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

-- Rate limiting için
local syncRateLimit = {}
local lastFullSync = 0

-- ============================================
-- AJAN LİSTESİNİ GÜNCELLE - OPTIMIZED
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
    
    -- print("[FIB SYNC] Online ajanlar guncellendi: " .. #FIB.OnlineAgents .. " ajan")
    
    return newList
end

-- ============================================
-- TÜM AJANLARA FULL SYNC GÖNDER - OPTIMIZED
-- ============================================
function FIB.BroadcastFullSync()
    -- Rate limiting - 5 saniyede bir
    if (CurTime() - lastFullSync) < 5 then
        return
    end
    lastFullSync = CurTime()
    
    -- Önce listeyi güncelle
    local agents = FIB.UpdateOnlineAgents()
    
    -- Boş liste kontrolü
    if not agents then
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
    
    -- print("[FIB SYNC] Full sync gonderildi: " .. sentCount .. " ajana")
end

-- ============================================
-- TEK BİR AJANA SYNC GÖNDER - OPTIMIZED
-- ============================================
function FIB.SendSyncToPlayer(ply)
    if not IsValid(ply) or not ply.FIBAuthenticated then 
        return 
    end
    
    -- Rate limiting per player
    local steamid = ply:SteamID()
    syncRateLimit[steamid] = syncRateLimit[steamid] or 0
    if (CurTime() - syncRateLimit[steamid]) < 2 then
        return
    end
    syncRateLimit[steamid] = CurTime()
    
    -- Güncel listeyi al
    local agents = FIB.UpdateOnlineAgents()
    
    net.Start("FIB_FullSync")
    net.WriteTable(agents)
    net.WriteTable(FIB.Config.Users or {})
    net.WriteTable(FIB.Missions or {})
    net.Send(ply)
    
    -- print("[FIB SYNC] Ozel sync gonderildi: " .. ply:Nick())
end

-- ============================================
-- CLIENT'TAN SYNC İSTEĞİ - RATE LIMITED
-- ============================================
net.Receive("FIB_RequestSync", function(len, ply)
    -- Güvenlik kontrolleri
    if not IsValid(ply) or not ply.FIBAuthenticated then
        return
    end
    
    -- Size kontrolü
    if len > 1024 then
        print("[FIB SYNC] Cok buyuk sync istegi reddedildi: " .. ply:Nick())
        return
    end
    
    -- print("[FIB SYNC] Sync istegi alindi: " .. ply:Nick())
    
    -- Tek oyuncuya gönder (rate limited)
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
            
            -- Sonra herkese bildir (optimize edilmiş)
            timer.Simple(1, function()
                FIB.BroadcastFullSync()
            end)
        end
    end)
end)

-- ============================================
-- GİZLİ MOD DEĞİŞTİĞİNDE - QUICK SYNC
-- ============================================
hook.Add("FIB_UndercoverChanged", "FIB_SyncOnUndercover", function(ply)
    if not IsValid(ply) then return end
    
    -- print("[FIB SYNC] Gizli mod degisti: " .. ply:Nick())
    
    -- Sadece quick sync
    timer.Simple(0.2, function()
        FIB.BroadcastQuickSync()
    end)
end)

-- ============================================
-- OYUNCU ÇIKIŞ YAPTIĞINDA
-- ============================================
hook.Add("PlayerDisconnected", "FIB_SyncOnDisconnect", function(ply)
    if ply.FIBAuthenticated then
        local steamid = ply:SteamID()
        local nick = ply:Nick()
        
        -- print("[FIB SYNC] FIB ajani cikis yapti: " .. nick)
        
        -- Rate limit temizle
        syncRateLimit[steamid] = nil
        
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
            
            -- 1 saniye sonra quick sync
            timer.Simple(1, function()
                FIB.BroadcastQuickSync()
            end)
        end)
    end
end)

-- ============================================
-- QUICK SYNC - Sadece online listesi
-- ============================================
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

-- ============================================
-- PERİYODİK SYNC - OPTIMIZED (30 saniye)
-- ============================================
timer.Create("FIB_PeriodicFullSync", 30, 0, function()
    local agentCount = 0
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply.FIBAuthenticated then
            agentCount = agentCount + 1
        end
    end
    
    if agentCount > 0 then
        -- print("[FIB SYNC] Periyodik sync yapiliyor...")
        FIB.BroadcastQuickSync() -- Full yerine Quick sync
    end
end)

-- ============================================
-- GÖREV SYNC - Sadece görev değiştiğinde
-- ============================================
hook.Add("FIB_MissionCreated", "SyncMissionCreate", function(mission)
    timer.Simple(0.5, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply.FIBAuthenticated then
                net.Start("FIB_MissionUpdate")
                net.WriteString("create")
                net.WriteTable(mission)
                net.Send(ply)
            end
        end
    end)
end)

hook.Add("FIB_MissionDeleted", "SyncMissionDelete", function(missionId)
    timer.Simple(0.5, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply.FIBAuthenticated then
                net.Start("FIB_MissionUpdate")
                net.WriteString("delete")
                net.WriteFloat(missionId)
                net.Send(ply)
            end
        end
    end)
end)

-- ============================================
-- CLEANUP - Bellek temizliği
-- ============================================
timer.Create("FIB_CleanupSync", 300, 0, function()
    -- Eski rate limit kayıtlarını temizle
    local currentTime = CurTime()
    for steamid, lastTime in pairs(syncRateLimit) do
        if (currentTime - lastTime) > 300 then
            syncRateLimit[steamid] = nil
        end
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
    lastFullSync = 0 -- Rate limit'i bypass et
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
    print("Rate limit cache: " .. table.Count(syncRateLimit) .. " kayit")
    print("Son full sync: " .. (CurTime() - lastFullSync) .. " saniye once")
    
    print("\nOnline Ajanlar:")
    local count = 0
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v.FIBAuthenticated then
            count = count + 1
            print("  [" .. count .. "] " .. v:Nick() .. " - " .. v:SteamID())
        end
    end
    
    print("\nToplam: " .. count .. " online ajan")
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Debug bilgisi konsola yazildi")
    end
end)

print("[FIB SYNC] Senkronizasyon sistemi yuklendi! (v6.0 - OPTIMIZED)")
print("[FIB SYNC] Periyodik sync: 30 saniye")