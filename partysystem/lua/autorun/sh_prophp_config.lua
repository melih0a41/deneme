-- Prop HP & Raid System Configuration
-- Dosya Yolu: lua/autorun/sh_prophp_config.lua
-- Versiyon: 2.0 STABLE

PropHP = PropHP or {}
PropHP.Config = {}

-- ============================
-- USERGROUP HP HAVUZU
-- ============================
PropHP.Config.PartyHPPool = {
    ["user"] = 200000,          -- 200K HP havuz
    ["bronzvip"] = 350000,      -- 350K HP havuz
    ["silvervip"] = 500000,     -- 500K HP havuz
    ["goldenvip"] = 700000,     -- 700K HP havuz
    ["platinumvip"] = 900000,   -- 900K HP havuz
    ["diamondvip"] = 1200000,   -- 1.2M HP havuz
    ["superadmin"] = 2000000    -- 2M HP havuz (test için)
}

-- ============================
-- MİNİMUM PROP HP DEĞERLERİ
-- ============================
PropHP.Config.MinPropHP = 1000  -- Bir prop'un minimum HP'si (çok fazla prop spamını önler)

-- ============================
-- SİLAH HASAR DEĞERLERİ
-- ============================
PropHP.Config.WeaponDamage = {
    -- Tabancalar
    ["weapon_pistol"] = 10,
    ["weapon_357"] = 25,
    ["weapon_glock"] = 15,
    ["weapon_deagle"] = 35,
    
    -- Tüfekler
    ["weapon_ar2"] = 20,
    ["weapon_smg1"] = 18,
    ["weapon_ak47"] = 25,
    ["weapon_m4a1"] = 23,
    
    -- Ağır silahlar
    ["weapon_rpg"] = 750,
    ["weapon_shotgun"] = 45,
    ["weapon_crossbow"] = 60,
    
    -- Özel raid silahları
    ["weapon_breachingcharge"] = 300,
    ["weapon_c4"] = 500,
    ["weapon_sledgehammer"] = 100,
    ["lockpick"] = 5,
    ["unarrest_stick"] = 5,
    ["arrest_stick"] = 5,
    ["stunstick"] = 15,
    
    -- Varsayılan
    ["default"] = 10
}

-- ============================
-- RAID SİSTEMİ AYARLARI
-- ============================
PropHP.Config.Raid = {
    MinPartyMembers = 1,         -- Minimum online parti üyesi (test için 1)
    MaxMemberDifference = 3,     -- Maksimum üye farkı (5v2 engellenir)
    PreparationTime = 60,        -- Hazırlık süresi (1 dakika)
    RaidDuration = 1800,         -- Raid süresi (30 dakika)
    RaidCooldown = 7200,         -- Aynı partiye raid cooldown (2 saat)
    DefenderBonus = 0.8,         -- Savunanlar %20 daha az hasar alır
    MinPropsToWin = 3,           -- Kazanmak için minimum yıkılması gereken prop
    AlertRadius = 2000,          -- Raid alert mesafe
    LootingDuration = 180,       -- Yağma süresi (3 dakika)
    
    -- Glow Ayarları
    UseRaidGlow = true,          -- Raid glow sistemini kullan
    TeamGlowSize = 5,            -- Takım glow boyutu
    TeamGlowPasses = 2,          -- Takım glow kalınlığı
    EnemyGlowSize = 5,           -- Düşman glow boyutu
    EnemyGlowPasses = 2,         -- Düşman glow kalınlığı
    TeamGlowColor = Color(0, 255, 0, 255),    -- Yeşil (takım)
    EnemyGlowColor = Color(255, 0, 0, 255),   -- Kırmızı (düşman)
}

-- ============================
-- GÖRSEL AYARLAR
-- ============================
PropHP.Config.Visual = {
    ShowPropHP = true,           -- Prop HP göster
    ShowDamageNumbers = true,    -- Hasar numaraları
    ShowRaidTimer = true,        -- Raid sayacı
    ShowPoolInfo = true,         -- HP havuz bilgisi
    ShowRaidGlow = true,         -- Raid glow efektleri
    ShowScoreboard = true,       -- 5v5 Scoreboard
    HPBarColor = {
        High = Color(0, 255, 0, 200),      -- Yeşil (75-100%)
        Medium = Color(255, 255, 0, 200),   -- Sarı (25-75%)
        Low = Color(255, 0, 0, 200),        -- Kırmızı (0-25%)
        Background = Color(0, 0, 0, 150)
    }
}

-- ============================
-- PERFORMANS AYARLARI
-- ============================
PropHP.Config.Performance = {
    NetworkUpdateRate = 0.5,     -- Network güncelleme sıklığı (saniye)
    MaxPropsPerParty = 100,      -- Parti başına maksimum prop
    HPRegenRate = 0.02,          -- Dakikada %2 regen (raid yoksa)
    HPUpdateDelay = 0.1,         -- HP güncelleme gecikmesi
}

-- ============================
-- DEBUG AYARLARI
-- ============================
PropHP.Config.Debug = {
    Enabled = false,             -- Debug modunu aç/kapa
    ShowLogs = false,            -- Konsol logları
    ShowNetworkTraffic = false   -- Network trafiğini göster
}

-- Config yüklendi bildirimi
if SERVER then
    print("[PropHP] Konfigürasyon dosyası yüklendi - v2.0")
else
    print("[PropHP] Client konfigürasyon yüklendi - v2.0")
end