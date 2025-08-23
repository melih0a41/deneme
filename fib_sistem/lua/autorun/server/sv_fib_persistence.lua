-- fib_sistem/lua/autorun/server/sv_fib_persistence.lua
-- FIB Veri Kalıcılık Sistemi - FIXED CONFIG v4.0

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

-- Cache sistemi
local dataCache = {
    agents = nil,
    missions = nil,
    lastSave = 0
}

-- ============================================
-- LUA CONFIG'DEN DEFAULT KULLANICILAR
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
    -- STEAM_0 formatı için de ekleyelim (güvenlik için)
    ["STEAM_0:1:441442821"] = {
        username = "kod01",
        password = "sikici123",
        rank = "Sef"
    }
}

-- ============================================
-- KAYDETME FONKSİYONLARI - FIXED
-- ============================================

-- Ajanları kaydet
function FIB.SaveAgents()
    -- Rate limiting
    if (CurTime() - (dataCache.lastAgentSave or 0)) < 5 then
        return false
    end
    dataCache.lastAgentSave = CurTime()
    
    -- Users'ın object olduğundan emin ol
    if type(FIB.Config.Users) ~= "table" then
        FIB.Config.Users = {}
    end
    
    -- Default kullanıcıları her zaman ekle
    for steamid, userData in pairs(DEFAULT_USERS) do
        if not FIB.Config.Users[steamid] then
            FIB.Config.Users[steamid] = userData
        end
    end
    
    local data = {
        version = "4.0",
        last_save = os.time(),
        users = FIB.Config.Users -- object olarak kaydet
    }
    
    local success, jsonData = pcall(util.TableToJSON, data, true)
    if not success then
        print("[FIB ERROR] Ajan verisi JSON'a cevrilemedi!")
        return false
    end
    
    file.Write(AGENTS_FILE, jsonData)
    
    print("[FIB] Ajanlar kaydedildi: " .. table.Count(FIB.Config.Users) .. " kullanici")
    
    -- Günlük backup
    local today = os.date("%Y%m%d")
    local backupFile = BACKUP_DIR .. "/agents_" .. today .. ".json"
    if not file.Exists(backupFile, "DATA") then
        file.Write(backupFile, jsonData)
    end
    
    return true
end

-- Görevleri kaydet
function FIB.SaveMissions()
    -- Rate limiting
    if (CurTime() - (dataCache.lastMissionSave or 0)) < 5 then
        return false
    end
    dataCache.lastMissionSave = CurTime()
    
    -- Missions'ın array olduğundan emin ol
    if type(FIB.Missions) ~= "table" then
        FIB.Missions = {}
    end
    
    local data = {
        version = "4.0",
        last_save = os.time(),
        missions = FIB.Missions
    }
    
    local success, jsonData = pcall(util.TableToJSON, data, true)
    if not success then
        print("[FIB ERROR] Gorev verisi JSON'a cevrilemedi!")
        return false
    end
    
    file.Write(MISSIONS_FILE, jsonData)
    
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
end

-- ============================================
-- YÜKLEME FONKSİYONLARI - FIXED
-- ============================================

-- Ajanları yükle
function FIB.LoadAgents()
    -- Önce default kullanıcıları yükle
    FIB.Config.Users = FIB.Config.Users or {}
    
    -- Default kullanıcıları ekle
    for steamid, userData in pairs(DEFAULT_USERS) do
        FIB.Config.Users[steamid] = userData
        print("[FIB] Default kullanici eklendi: " .. userData.username .. " (" .. steamid .. ")")
    end
    
    -- JSON dosyası varsa onu da yükle
    if file.Exists(AGENTS_FILE, "DATA") then
        local jsonData = file.Read(AGENTS_FILE, "DATA")
        if jsonData then
            local success, data = pcall(util.JSONToTable, jsonData)
            if success and data then
                -- Users field'ı object mi kontrol et
                if data.users and type(data.users) == "table" then
                    -- Array değil object olduğundan emin ol
                    local isArray = false
                    for k, v in pairs(data.users) do
                        if type(k) == "number" then
                            isArray = true
                            break
                        end
                    end
                    
                    if not isArray then
                        -- JSON'daki kullanıcıları ekle (default'ları ezmeden)
                        for steamid, userData in pairs(data.users) do
                            if not DEFAULT_USERS[steamid] then
                                FIB.Config.Users[steamid] = userData
                            end
                        end
                        print("[FIB] JSON'dan " .. table.Count(data.users) .. " ek kullanici yuklendi")
                    else
                        print("[FIB WARNING] users field'i array formatta, object'e cevriliyor...")
                    end
                end
            end
        end
    end
    
    print("[FIB] Toplam " .. table.Count(FIB.Config.Users) .. " kullanici yuklendi")
    
    -- Hemen kaydet (format düzeltmesi için)
    FIB.SaveAgents()
    
    return true
end

-- Görevleri yükle
function FIB.LoadMissions()
    FIB.Missions = {}
    
    if file.Exists(MISSIONS_FILE, "DATA") then
        local jsonData = file.Read(MISSIONS_FILE, "DATA")
        if jsonData then
            local success, data = pcall(util.JSONToTable, jsonData)
            if success and data and data.missions then
                FIB.Missions = data.missions
                print("[FIB] " .. #FIB.Missions .. " gorev yuklendi")
            end
        end
    end
    
    return true
end

-- Tüm verileri yükle
function FIB.LoadAllData()
    print("[FIB] ===== VERI YUKLEME BASLIYOR =====")
    
    FIB.LoadAgents()
    FIB.LoadMissions()
    
    print("[FIB] ===== VERI YUKLEME TAMAMLANDI =====")
    print("[FIB] Kayitli kullanicilar:")
    for steamid, userData in pairs(FIB.Config.Users) do
        print("  - " .. steamid .. ": " .. userData.username .. " (" .. userData.rank .. ")")
    end
end

-- ============================================
-- CONFIG FIX KOMUTU
-- ============================================
concommand.Add("fib_fix_config", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[FIB] Bu komutu sadece adminler kullanabilir!")
        return
    end
    
    -- Config'i sıfırla ve default kullanıcıları ekle
    FIB.Config.Users = {}
    for steamid, userData in pairs(DEFAULT_USERS) do
        FIB.Config.Users[steamid] = userData
    end
    
    -- Kaydet
    FIB.SaveAgents()
    
    local msg = "[FIB] Config duzeltildi! " .. table.Count(FIB.Config.Users) .. " kullanici eklendi."
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

-- ============================================
-- HOOK'LAR VE TIMER'LAR
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

-- Periyodik otomatik kaydetme
timer.Create("FIB_AutoSave", 120, 0, function()
    FIB.SaveAllData()
end)

-- Server kapanırken kaydet
hook.Add("ShutDown", "FIB_SaveOnShutdown", function()
    FIB.SaveAllData()
    print("[FIB] Server kapaniyor, veriler kaydedildi")
end)

-- ============================================
-- DEBUG KOMUTLARI
-- ============================================

concommand.Add("fib_list_users", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    print("[FIB] === KAYITLI KULLANICILAR ===")
    for steamid, userData in pairs(FIB.Config.Users) do
        print("SteamID: " .. steamid)
        print("  Username: " .. userData.username)
        print("  Password: " .. userData.password)
        print("  Rank: " .. userData.rank)
        print("  -----------")
    end
    print("Toplam: " .. table.Count(FIB.Config.Users) .. " kullanici")
    
    if IsValid(ply) then
        ply:ChatPrint("[FIB] Kullanici listesi konsola yazildi")
    end
end)

print("[FIB] Veri kalicilik sistemi yuklendi! (v4.0 - CONFIG FIXED)")
print("[FIB] Default kullanicilar eklendi")