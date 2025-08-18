-- fib_sistem/lua/autorun/server/sv_fib_persistence.lua
-- FIB Veri Kalıcılık Sistemi

-- Data klasörünü oluştur
if not file.IsDir("fib_data", "DATA") then
    file.CreateDir("fib_data")
    print("[FIB] Data klasoru olusturuldu: garrysmod/data/fib_data/")
end

-- JSON kütüphanesi (GMod built-in)
local json = util.JSONToTable
local jsonEncode = util.TableToJSON

-- Veri dosya yolları
local AGENTS_FILE = "fib_data/agents.json"
local MISSIONS_FILE = "fib_data/missions.json"
local BACKUP_DIR = "fib_data/backups"

-- Backup klasörü
if not file.IsDir(BACKUP_DIR, "DATA") then
    file.CreateDir(BACKUP_DIR)
end

-- Global değişkenler
FIB = FIB or {}
FIB.Config = FIB.Config or {}
FIB.Config.Users = FIB.Config.Users or {}
FIB.Missions = FIB.Missions or {}

-- ============================================
-- KAYDETME FONKSİYONLARI
-- ============================================

-- Ajanları kaydet
function FIB.SaveAgents()
    local data = {
        version = "1.0",
        last_save = os.time(),
        users = FIB.Config.Users
    }
    
    local jsonData = jsonEncode(data, true) -- true = pretty print
    file.Write(AGENTS_FILE, jsonData)
    
    print("[FIB] Ajanlar kaydedildi: " .. table.Count(FIB.Config.Users) .. " kullanici")
    
    -- Backup oluştur (günlük)
    local backupFile = BACKUP_DIR .. "/agents_" .. os.date("%Y%m%d") .. ".json"
    file.Write(backupFile, jsonData)
    
    return true
end

-- Görevleri kaydet
function FIB.SaveMissions()
    local data = {
        version = "1.0",
        last_save = os.time(),
        missions = FIB.Missions
    }
    
    local jsonData = jsonEncode(data, true)
    file.Write(MISSIONS_FILE, jsonData)
    
    print("[FIB] Gorevler kaydedildi: " .. #FIB.Missions .. " gorev")
    
    -- Backup oluştur
    local backupFile = BACKUP_DIR .. "/missions_" .. os.date("%Y%m%d") .. ".json"
    file.Write(backupFile, jsonData)
    
    return true
end

-- Tüm verileri kaydet
function FIB.SaveAllData()
    FIB.SaveAgents()
    FIB.SaveMissions()
    print("[FIB] Tum veriler kaydedildi!")
end

-- ============================================
-- YÜKLEME FONKSİYONLARI
-- ============================================

-- Ajanları yükle
function FIB.LoadAgents()
    if not file.Exists(AGENTS_FILE, "DATA") then
        print("[FIB] Ajan verisi bulunamadi, varsayilan ayarlar yukleniyor...")
        
        -- Varsayılan ajanları yükle (config'den)
        if FIB.Config.Users and table.Count(FIB.Config.Users) > 0 then
            FIB.SaveAgents() -- İlk kayıt
            return true
        end
        return false
    end
    
    local jsonData = file.Read(AGENTS_FILE, "DATA")
    if not jsonData then
        print("[FIB] Ajan verisi okunamadi!")
        return false
    end
    
    local data = json(jsonData)
    if not data or not data.users then
        print("[FIB] Ajan verisi bozuk!")
        return false
    end
    
    FIB.Config.Users = data.users
    
    print("[FIB] Ajanlar yuklendi: " .. table.Count(FIB.Config.Users) .. " kullanici")
    print("[FIB] Son kayit: " .. os.date("%Y-%m-%d %H:%M:%S", data.last_save))
    
    -- Yüklenen ajanları listele
    for steamid, userdata in pairs(FIB.Config.Users) do
        print("  - " .. userdata.username .. " (" .. userdata.rank .. ") - " .. steamid)
    end
    
    return true
end

-- Görevleri yükle
function FIB.LoadMissions()
    if not file.Exists(MISSIONS_FILE, "DATA") then
        print("[FIB] Gorev verisi bulunamadi, bos liste olusturuluyor...")
        FIB.Missions = {}
        FIB.SaveMissions() -- Boş dosya oluştur
        return true
    end
    
    local jsonData = file.Read(MISSIONS_FILE, "DATA")
    if not jsonData then
        print("[FIB] Gorev verisi okunamadi!")
        return false
    end
    
    local data = json(jsonData)
    if not data or not data.missions then
        print("[FIB] Gorev verisi bozuk!")
        FIB.Missions = {}
        return false
    end
    
    FIB.Missions = data.missions
    
    print("[FIB] Gorevler yuklendi: " .. #FIB.Missions .. " gorev")
    
    -- Yüklenen görevleri listele
    for i, mission in ipairs(FIB.Missions) do
        print("  - Gorev #" .. i .. ": " .. mission.name .. " (Oncelik: " .. mission.priority .. ")")
    end
    
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
    local agentsBackup = BACKUP_DIR .. "/agents_" .. dateStr .. "_" .. reason .. ".json"
    local agentsData = file.Read(AGENTS_FILE, "DATA")
    if agentsData then
        file.Write(agentsBackup, agentsData)
    end
    
    -- Görevler backup
    local missionsBackup = BACKUP_DIR .. "/missions_" .. dateStr .. "_" .. reason .. ".json"
    local missionsData = file.Read(MISSIONS_FILE, "DATA")
    if missionsData then
        file.Write(missionsBackup, missionsData)
    end
    
    print("[FIB] Backup olusturuldu: " .. dateStr .. " (" .. reason .. ")")
end

-- Backup'tan geri yükle
function FIB.RestoreFromBackup(backupDate)
    local agentsBackup = BACKUP_DIR .. "/agents_" .. backupDate .. ".json"
    local missionsBackup = BACKUP_DIR .. "/missions_" .. backupDate .. ".json"
    
    local success = true
    
    -- Ajanları geri yükle
    if file.Exists(agentsBackup, "DATA") then
        local data = file.Read(agentsBackup, "DATA")
        file.Write(AGENTS_FILE, data)
        FIB.LoadAgents()
        print("[FIB] Ajanlar geri yuklendi: " .. backupDate)
    else
        print("[FIB] Ajan backup bulunamadi: " .. backupDate)
        success = false
    end
    
    -- Görevleri geri yükle
    if file.Exists(missionsBackup, "DATA") then
        local data = file.Read(missionsBackup, "DATA")
        file.Write(MISSIONS_FILE, data)
        FIB.LoadMissions()
        print("[FIB] Gorevler geri yuklendi: " .. backupDate)
    else
        print("[FIB] Gorev backup bulunamadi: " .. backupDate)
        success = false
    end
    
    return success
end

-- ============================================
-- HOOK'LAR VE TIMER'LAR
-- ============================================

-- Server başlatıldığında verileri yükle
hook.Add("Initialize", "FIB_LoadData", function()
    timer.Simple(1, function() -- Config'in yüklenmesini bekle
        FIB.LoadAllData()
    end)
end)

-- Periyodik otomatik kaydetme (5 dakikada bir)
timer.Create("FIB_AutoSave", 300, 0, function()
    FIB.SaveAllData()
    print("[FIB] Otomatik kayit yapildi")
end)

-- Server kapanırken kaydet
hook.Add("ShutDown", "FIB_SaveOnShutdown", function()
    FIB.CreateBackup("shutdown")
    FIB.SaveAllData()
    print("[FIB] Server kapaniyor, veriler kaydedildi")
end)

-- Map değişirken kaydet
hook.Add("OnMapTransition", "FIB_SaveOnMapChange", function()
    FIB.CreateBackup("mapchange")
    FIB.SaveAllData()
    print("[FIB] Map degisiyor, veriler kaydedildi")
end)

-- Oyuncu disconnect olduğunda kaydet (son giriş zamanı için)
hook.Add("PlayerDisconnected", "FIB_SaveOnDisconnect", function(ply)
    if ply.FIBAuthenticated then
        -- Son görülme zamanını kaydet
        if FIB.Config.Users[ply:SteamID()] then
            FIB.Config.Users[ply:SteamID()].last_seen = os.time()
            FIB.SaveAgents()
        end
    end
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

-- Backup oluşturma komutu
concommand.Add("fib_backup", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    FIB.CreateBackup("admin")
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Backup olusturuldu!")
    else
        print("[FIB] Backup olusturuldu! (Console)")
    end
end)

-- Backup listesi
concommand.Add("fib_backup_list", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    local files = file.Find(BACKUP_DIR .. "/*.json", "DATA")
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] === BACKUP LISTESI ===")
        for _, filename in ipairs(files) do
            ply:ChatPrint("  - " .. filename)
        end
        ply:ChatPrint("[FIB] Toplam: " .. #files .. " backup")
    else
        print("[FIB] === BACKUP LISTESI ===")
        for _, filename in ipairs(files) do
            print("  - " .. filename)
        end
        print("[FIB] Toplam: " .. #files .. " backup")
    end
end)

-- Backup'tan geri yükleme
concommand.Add("fib_restore", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    if not args[1] then
        if IsValid(ply) then
            ply:ChatPrint("[FIB] Kullanim: fib_restore <tarih>")
            ply:ChatPrint("[FIB] Ornek: fib_restore 20241224")
        else
            print("[FIB] Kullanim: fib_restore <tarih>")
        end
        return
    end
    
    local success = FIB.RestoreFromBackup(args[1])
    
    if IsValid(ply) then
        if success then
            ply:ChatPrint("[FIB] Backup'tan geri yukleme basarili!")
        else
            ply:ChatPrint("[FIB] Backup'tan geri yukleme basarisiz!")
        end
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

print("[FIB] Veri kalicilik sistemi yuklendi!")
print("[FIB] Data klasoru: garrysmod/data/fib_data/")