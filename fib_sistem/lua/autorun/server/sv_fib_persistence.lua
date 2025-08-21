-- fib_sistem/lua/autorun/server/sv_fib_persistence.lua
-- FIB Veri Kalıcılık Sistemi - OPTIMIZED v3.0

-- Data klasörünü oluştur
if not file.IsDir("fib_data", "DATA") then
    file.CreateDir("fib_data")
    print("[FIB] Data klasoru olusturuldu: garrysmod/data/fib_data/")
end

-- Backup klasörü
if not file.IsDir("fib_data/backups", "DATA") then
    file.CreateDir("fib_data/backups")
end

-- Veri dosya yolları
local AGENTS_FILE = "fib_data/agents.json"
local MISSIONS_FILE = "fib_data/missions.json"
local BACKUP_DIR = "fib_data/backups"

-- Global değişkenler
FIB = FIB or {}
FIB.Config = FIB.Config or {}
FIB.Config.Users = FIB.Config.Users or {}
FIB.Missions = FIB.Missions or {}

-- Cache sistemi (performans için)
local dataCache = {
    agents = nil,
    missions = nil,
    lastSave = 0
}

-- ============================================
-- KAYDETME FONKSİYONLARI - OPTIMIZED
-- ============================================

-- Ajanları kaydet
function FIB.SaveAgents()
    -- Rate limiting - 5 saniyede bir kaydet
    if (CurTime() - (dataCache.lastAgentSave or 0)) < 5 then
        return false
    end
    dataCache.lastAgentSave = CurTime()
    
    local data = {
        version = "3.0",
        last_save = os.time(),
        users = FIB.Config.Users
    }
    
    local success, jsonData = pcall(util.TableToJSON, data, true)
    if not success then
        print("[FIB ERROR] Ajan verisi JSON'a cevrilemedi!")
        return false
    end
    
    file.Write(AGENTS_FILE, jsonData)
    
    -- print("[FIB] Ajanlar kaydedildi: " .. table.Count(FIB.Config.Users) .. " kullanici")
    
    -- Günlük backup (performans için sadece günde bir)
    local today = os.date("%Y%m%d")
    local backupFile = BACKUP_DIR .. "/agents_" .. today .. ".json"
    if not file.Exists(backupFile, "DATA") then
        file.Write(backupFile, jsonData)
    end
    
    return true
end

-- Görevleri kaydet - KALICI
function FIB.SaveMissions()
    -- Rate limiting
    if (CurTime() - (dataCache.lastMissionSave or 0)) < 5 then
        return false
    end
    dataCache.lastMissionSave = CurTime()
    
    -- Görevleri temizle (örnek görevleri kaldır)
    local cleanMissions = {}
    for _, mission in ipairs(FIB.Missions) do
        -- Sadece gerçek görevleri sakla (id'si olan)
        if mission.id and mission.createdBy then
            table.insert(cleanMissions, mission)
        end
    end
    FIB.Missions = cleanMissions
    
    local data = {
        version = "3.0",
        last_save = os.time(),
        missions = FIB.Missions
    }
    
    local success, jsonData = pcall(util.TableToJSON, data, true)
    if not success then
        print("[FIB ERROR] Gorev verisi JSON'a cevrilemedi!")
        return false
    end
    
    file.Write(MISSIONS_FILE, jsonData)
    
    -- print("[FIB] Gorevler kaydedildi: " .. #FIB.Missions .. " gorev")
    
    -- Günlük backup
    local today = os.date("%Y%m%d")
    local backupFile = BACKUP_DIR .. "/missions_" .. today .. ".json"
    if not file.Exists(backupFile, "DATA") then
        file.Write(backupFile, jsonData)
    end
    
    return true
end

-- Tüm verileri kaydet
function FIB.SaveAllData()
    FIB.SaveAgents()
    FIB.SaveMissions()
    -- print("[FIB] Tum veriler kaydedildi!")
end

-- ============================================
-- YÜKLEME FONKSİYONLARI - OPTIMIZED
-- ============================================

-- Ajanları yükle
function FIB.LoadAgents()
    if not file.Exists(AGENTS_FILE, "DATA") then
        print("[FIB] Ajan verisi bulunamadi, varsayilan ayarlar yukleniyor...")
        
        -- Varsayılan ajanları config'den al
        if FIB.Config.Users and table.Count(FIB.Config.Users) > 0 then
            FIB.SaveAgents()
            return true
        end
        return false
    end
    
    local jsonData = file.Read(AGENTS_FILE, "DATA")
    if not jsonData then
        print("[FIB] Ajan verisi okunamadi!")
        return false
    end
    
    local success, data = pcall(util.JSONToTable, jsonData)
    if not success or not data or not data.users then
        print("[FIB] Ajan verisi bozuk! Backup'tan yukleniyor...")
        
        -- Backup'tan yüklemeyi dene
        local today = os.date("%Y%m%d")
        local yesterday = os.date("%Y%m%d", os.time() - 86400)
        
        for _, backupDate in ipairs({today, yesterday}) do
            local backupFile = BACKUP_DIR .. "/agents_" .. backupDate .. ".json"
            if file.Exists(backupFile, "DATA") then
                jsonData = file.Read(backupFile, "DATA")
                success, data = pcall(util.JSONToTable, jsonData)
                if success and data and data.users then
                    FIB.Config.Users = data.users
                    print("[FIB] Backup'tan yuklendi: " .. backupDate)
                    return true
                end
            end
        end
        
        return false
    end
    
    FIB.Config.Users = data.users
    
    print("[FIB] Ajanlar yuklendi: " .. table.Count(FIB.Config.Users) .. " kullanici")
    
    return true
end

-- Görevleri yükle - KALICI
function FIB.LoadMissions()
    if not file.Exists(MISSIONS_FILE, "DATA") then
        print("[FIB] Gorev verisi bulunamadi, bos liste olusturuluyor...")
        FIB.Missions = {}
        -- Boş dosya oluştur
        FIB.SaveMissions()
        return true
    end
    
    local jsonData = file.Read(MISSIONS_FILE, "DATA")
    if not jsonData then
        print("[FIB] Gorev verisi okunamadi!")
        FIB.Missions = {}
        return false
    end
    
    local success, data = pcall(util.JSONToTable, jsonData)
    if not success or not data then
        print("[FIB] Gorev verisi bozuk! Backup'tan yukleniyor...")
        
        -- Backup'tan yükle
        local today = os.date("%Y%m%d")
        local yesterday = os.date("%Y%m%d", os.time() - 86400)
        
        for _, backupDate in ipairs({today, yesterday}) do
            local backupFile = BACKUP_DIR .. "/missions_" .. backupDate .. ".json"
            if file.Exists(backupFile, "DATA") then
                jsonData = file.Read(backupFile, "DATA")
                success, data = pcall(util.JSONToTable, jsonData)
                if success and data and data.missions then
                    FIB.Missions = data.missions
                    print("[FIB] Gorevler backup'tan yuklendi: " .. backupDate)
                    return true
                end
            end
        end
        
        FIB.Missions = {}
        return false
    end
    
    FIB.Missions = data.missions or {}
    
    -- ID düzeltmesi (eğer yoksa ekle)
    for i, mission in ipairs(FIB.Missions) do
        if not mission.id then
            mission.id = i
        end
    end
    
    print("[FIB] Gorevler yuklendi: " .. #FIB.Missions .. " gorev")
    
    return true
end

-- Tüm verileri yükle
function FIB.LoadAllData()
    print("[FIB] ===== VERI YUKLEME BASLIYOR =====")
    
    local agentsLoaded = FIB.LoadAgents()
    local missionsLoaded = FIB.LoadMissions()
    
    if agentsLoaded and missionsLoaded then
        print("[FIB] Tum veriler basariyla yuklendi!")
    else
        print("[FIB] Bazi veriler yuklenemedi, varsayilanlar kullaniliyor.")
    end
    
    print("[FIB] ===== VERI YUKLEME TAMAMLANDI =====")
end

-- ============================================
-- BACKUP FONKSİYONLARI
-- ============================================

-- Backup oluştur
function FIB.CreateBackup(reason)
    reason = reason or "manual"
    
    local timestamp = os.time()
    local dateStr = os.date("%Y%m%d_%H%M%S", timestamp)
    
    -- Ajanlar backup
    if file.Exists(AGENTS_FILE, "DATA") then
        local agentsBackup = BACKUP_DIR .. "/agents_" .. dateStr .. "_" .. reason .. ".json"
        local agentsData = file.Read(AGENTS_FILE, "DATA")
        if agentsData then
            file.Write(agentsBackup, agentsData)
        end
    end
    
    -- Görevler backup
    if file.Exists(MISSIONS_FILE, "DATA") then
        local missionsBackup = BACKUP_DIR .. "/missions_" .. dateStr .. "_" .. reason .. ".json"
        local missionsData = file.Read(MISSIONS_FILE, "DATA")
        if missionsData then
            file.Write(missionsBackup, missionsData)
        end
    end
    
    print("[FIB] Backup olusturuldu: " .. dateStr .. " (" .. reason .. ")")
end

-- ============================================
-- HOOK'LAR VE TIMER'LAR - OPTIMIZED
-- ============================================

-- Server başlatıldığında verileri yükle
hook.Add("Initialize", "FIB_LoadData", function()
    timer.Simple(1, function()
        FIB.LoadAllData()
    end)
end)

-- InitPostEntity - daha güvenilir
hook.Add("InitPostEntity", "FIB_LoadDataPost", function()
    timer.Simple(2, function()
        if not dataCache.loaded then
            FIB.LoadAllData()
            dataCache.loaded = true
        end
    end)
end)

-- Periyodik otomatik kaydetme (2 dakikada bir - optimize edildi)
timer.Create("FIB_AutoSave", 120, 0, function()
    FIB.SaveAllData()
end)

-- Server kapanırken kaydet
hook.Add("ShutDown", "FIB_SaveOnShutdown", function()
    FIB.CreateBackup("shutdown")
    FIB.SaveAllData()
    print("[FIB] Server kapaniyor, veriler kaydedildi")
end)

-- Oyuncu disconnect olduğunda kaydet (son giriş zamanı için)
hook.Add("PlayerDisconnected", "FIB_SaveOnDisconnect", function(ply)
    if ply.FIBAuthenticated then
        -- Son görülme zamanını kaydet
        if FIB.Config.Users[ply:SteamID()] then
            FIB.Config.Users[ply:SteamID()].last_seen = os.time()
            
            -- Asenkron kaydet
            timer.Simple(1, function()
                FIB.SaveAgents()
            end)
        end
    end
end)

-- ============================================
-- GÖREV YÖNETİMİ HOOK'LARI
-- ============================================

-- Görev oluşturulduğunda
hook.Add("FIB_MissionCreated", "SaveMissionOnCreate", function(mission)
    timer.Simple(0.5, function()
        FIB.SaveMissions()
    end)
end)

-- Görev güncellendiğinde
hook.Add("FIB_MissionUpdated", "SaveMissionOnUpdate", function(mission)
    timer.Simple(0.5, function()
        FIB.SaveMissions()
    end)
end)

-- Görev silindiğinde
hook.Add("FIB_MissionDeleted", "SaveMissionOnDelete", function(missionId)
    timer.Simple(0.5, function()
        FIB.SaveMissions()
    end)
end)

-- ============================================
-- ADMIN KOMUTLARI
-- ============================================

-- Manuel kaydetme komutu
concommand.Add("fib_save", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    FIB.SaveAllData()
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Tum veriler kaydedildi!")
    else
        print("[FIB] Tum veriler kaydedildi! (Console)")
    end
end)

-- Manuel yükleme komutu
concommand.Add("fib_load", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    FIB.LoadAllData()
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Tum veriler yuklendi!")
    else
        print("[FIB] Tum veriler yuklendi! (Console)")
    end
end)

-- İstatistikler
concommand.Add("fib_stats", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    local agentCount = table.Count(FIB.Config.Users)
    local missionCount = #FIB.Missions
    local onlineCount = 0
    
    for _, v in ipairs(player.GetAll()) do
        if v.FIBAuthenticated then
            onlineCount = onlineCount + 1
        end
    end
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] === SISTEM ISTATISTIKLERI ===")
        ply:ChatPrint("[FIB] Toplam Ajan: " .. agentCount)
        ply:ChatPrint("[FIB] Online Ajan: " .. onlineCount)
        ply:ChatPrint("[FIB] Toplam Gorev: " .. missionCount)
        ply:ChatPrint("[FIB] Data Klasoru: garrysmod/data/fib_data/")
    else
        print("[FIB] === SISTEM ISTATISTIKLERI ===")
        print("[FIB] Toplam Ajan: " .. agentCount)
        print("[FIB] Online Ajan: " .. onlineCount)
        print("[FIB] Toplam Gorev: " .. missionCount)
        print("[FIB] Data Klasoru: garrysmod/data/fib_data/")
    end
end)

print("[FIB] Veri kalicilik sistemi yuklendi! (v3.0 - OPTIMIZED)")
print("[FIB] Data klasoru: garrysmod/data/fib_data/")