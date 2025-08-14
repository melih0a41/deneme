-- fib_sistem/lua/autorun/server/sv_fib_sync_fix.lua
-- Senkronizasyon Sorunları Düzeltmesi

-- Network strings (eğer tanımlanmamışsa)
util.AddNetworkString("FIB_RequestSync")
util.AddNetworkString("FIB_FullSync")
util.AddNetworkString("FIB_AgentListUpdate")

-- Global FIB tablosu
FIB = FIB or {}
FIB.OnlineAgents = FIB.OnlineAgents or {}

-- ============================================
-- AJAN LİSTESİNİ GÜNCELLE
-- ============================================
function FIB.UpdateOnlineAgents()
    FIB.OnlineAgents = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            table.insert(FIB.OnlineAgents, {
                entity = ply,
                steamid = ply:SteamID(),
                nick = ply:Nick(),
                rank = ply.FIBRank or "Ajan",
                username = ply.FIBUsername or "Unknown",
                undercover = ply.FIBUndercover or false,
                loginTime = ply.FIBLoginTime or 0
            })
        end
    end
    
    print("[FIB SYNC] Online ajanlar guncellendi: " .. #FIB.OnlineAgents .. " ajan")
    
    -- Debug için listeyi yazdır
    for i, agent in ipairs(FIB.OnlineAgents) do
        print("  [" .. i .. "] " .. agent.nick .. " - " .. agent.rank .. " - " .. (agent.undercover and "Gizli" or "Normal"))
    end
end

-- ============================================
-- TÜM AJANLARA SYNC GÖNDER
-- ============================================
function FIB.BroadcastSync()
    FIB.UpdateOnlineAgents()
    
    -- Tüm FIB ajanlarına gönder
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            net.Start("FIB_FullSync")
            net.WriteTable(FIB.OnlineAgents)
            net.WriteTable(FIB.Config.Users or {})
            net.WriteTable(FIB.Missions or {})
            net.Send(ply)
            
            print("[FIB SYNC] Sync gonderildi: " .. ply:Nick())
        end
    end
end

-- ============================================
-- TEK BİR AJANA SYNC GÖNDER
-- ============================================
function FIB.SendSyncToPlayer(ply)
    if not IsValid(ply) or not ply.FIBAuthenticated then return end
    
    FIB.UpdateOnlineAgents()
    
    net.Start("FIB_FullSync")
    net.WriteTable(FIB.OnlineAgents)
    net.WriteTable(FIB.Config.Users or {})
    net.WriteTable(FIB.Missions or {})
    net.Send(ply)
    
    print("[FIB SYNC] Ozel sync gonderildi: " .. ply:Nick())
end

-- ============================================
-- CLIENT'TAN SYNC İSTEĞİ
-- ============================================
net.Receive("FIB_RequestSync", function(len, ply)
    if not ply.FIBAuthenticated then
        print("[FIB SYNC] Yetkisiz sync istegi: " .. ply:Nick())
        return
    end
    
    print("[FIB SYNC] Sync istegi alindi: " .. ply:Nick())
    FIB.SendSyncToPlayer(ply)
end)

-- ============================================
-- AJAN GİRİŞ YAPTIĞINDA
-- ============================================
hook.Add("FIB_AgentLogin", "FIB_SyncOnLogin", function(ply)
    print("[FIB SYNC] Ajan giris yapti, sync baslatiliyor: " .. ply:Nick())
    
    -- 1 saniye bekle (client'ın hazır olması için)
    timer.Simple(1, function()
        if IsValid(ply) and ply.FIBAuthenticated then
            -- Bu ajana tüm veriyi gönder
            FIB.SendSyncToPlayer(ply)
            
            -- 2 saniye sonra herkese sync gönder
            timer.Simple(2, function()
                FIB.BroadcastSync()
            end)
        end
    end)
end)

-- ============================================
-- AJAN EKLEME/SİLME SONRASI SYNC
-- ============================================
hook.Add("FIB_AgentAdded", "FIB_SyncOnAdd", function(steamid)
    print("[FIB SYNC] Yeni ajan eklendi, sync gonderiliyor...")
    timer.Simple(0.5, function()
        FIB.BroadcastSync()
    end)
end)

hook.Add("FIB_AgentRemoved", "FIB_SyncOnRemove", function(steamid)
    print("[FIB SYNC] Ajan silindi, sync gonderiliyor...")
    timer.Simple(0.5, function()
        FIB.BroadcastSync()
    end)
end)

-- ============================================
-- OYUNCU ÇIKIŞ YAPTIĞINDA
-- ============================================
hook.Add("PlayerDisconnected", "FIB_SyncOnDisconnect", function(ply)
    if ply.FIBAuthenticated then
        print("[FIB SYNC] FIB ajani cikis yapti: " .. ply:Nick())
        
        -- 1 saniye bekle ve sync gönder
        timer.Simple(1, function()
            FIB.BroadcastSync()
        end)
    end
end)

-- ============================================
-- PERİYODİK SYNC (Her 15 saniyede bir)
-- ============================================
timer.Create("FIB_PeriodicFullSync", 15, 0, function()
    local agentCount = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply.FIBAuthenticated then
            agentCount = agentCount + 1
        end
    end
    
    if agentCount > 0 then
        print("[FIB SYNC] Periyodik sync (" .. agentCount .. " ajan online)")
        FIB.BroadcastSync()
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
    FIB.BroadcastSync()
    
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
    print("Online Ajanlar:")
    
    local count = 0
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            count = count + 1
            print("  [" .. count .. "] " .. v:Nick())
            print("      - SteamID: " .. v:SteamID())
            print("      - Rank: " .. (v.FIBRank or "YOK"))
            print("      - Username: " .. (v.FIBUsername or "YOK"))
            print("      - Undercover: " .. tostring(v.FIBUndercover or false))
        end
    end
    
    print("Toplam: " .. count .. " online ajan")
    print("Config'deki toplam ajan: " .. table.Count(FIB.Config.Users or {}))
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Debug bilgisi konsola yazildi")
    end
end)

print("[FIB SYNC] Senkronizasyon sistemi yuklendi!")
print("[FIB SYNC] Periyodik sync: 15 saniye")