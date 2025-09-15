-- Prop HP & Raid System Configuration - OPTİMİZE EDİLMİŞ
-- Dosya Yolu: lua/autorun/sh_prophp_config.lua
-- Versiyon: 3.0 - Performans ve güvenlik iyileştirmeleri

PropHP = PropHP or {}
PropHP.Config = {}

-- ============================
-- USERGROUP HP HAVUZU
-- ============================
PropHP.Config.PartyHPPool = {
    ["user"] = 150000,          -- 150K HP havuz (düşürüldü)
    ["bronzvip"] = 250000,      -- 250K HP havuz
    ["silvervip"] = 400000,     -- 400K HP havuz
    ["goldenvip"] = 600000,     -- 600K HP havuz
    ["platinumvip"] = 800000,   -- 800K HP havuz
    ["diamondvip"] = 1000000,   -- 1M HP havuz
    ["superadmin"] = 1500000    -- 1.5M HP havuz (test için)
}

-- ============================
-- MİNİMUM PROP HP DEĞERLERİ
-- ============================
PropHP.Config.MinPropHP = 1500  -- Bir prop'un minimum HP'si (artırıldı)

-- ============================
-- SİLAH HASAR DEĞERLERİ - DENGELENDI
-- ============================
PropHP.Config.WeaponDamage = {
    -- Tabancalar
    ["weapon_pistol"] = 50,
    ["weapon_357"] = 150,
    ["weapon_glock"] = 75,
    ["weapon_deagle"] = 200,
    
    -- Tüfekler  
    ["weapon_ar2"] = 120,
    ["weapon_smg1"] = 100,
    ["weapon_ak47"] = 150,
    ["weapon_m4a1"] = 140,
    
    -- Özel Prop Kırma Silahları
    ["weapon_prophp_ar2"] = 50,     -- Yeni AR2 prop kırma silahı
    
    -- Ağır silahlar
    ["weapon_rpg"] = 1500,
    ["weapon_shotgun"] = 250,
    ["weapon_crossbow"] = 300,
    
    -- Özel raid silahları
    ["weapon_breachingcharge"] = 800,
    ["weapon_c4"] = 1200,
    ["weapon_sledgehammer"] = 400,
    ["lockpick"] = 25,
    ["unarrest_stick"] = 25,
    ["arrest_stick"] = 25,
    ["stunstick"] = 75,
    
    -- Varsayılan
    ["default"] = 100
}

-- ============================
-- PARTİ SİSTEMİ AYARLARI - YENİ
-- ============================
PropHP.Config.Party = {
    MinimumStayTime = 1200,      -- Minimum partide kalma süresi (20 dakika)
    ShowTimeWarning = true,       -- Süre uyarılarını göster
    AdminBypass = true,           -- Adminler hemen çıkabilir
    LeaderBypass = true,          -- Parti lideri kendi partisinden hemen çıkabilir
    WarnBeforeKick = 300,         -- Kick'ten önce uyarı süresi (5 dakika)
}

-- ============================
-- RAID SİSTEMİ AYARLARI - OPTİMİZE
-- ============================
PropHP.Config.Raid = {
    MinPartyMembers = 2,         -- Minimum online parti üyesi (artırıldı)
    MaxMemberDifference = 2,     -- Maksimum üye farkı (düşürüldü)
    PreparationTime = 60,        -- Hazırlık süresi (1 dakika)
    RaidDuration = 1200,         -- Raid süresi (20 dakika, düşürüldü)
    RaidCooldown = 3600,         -- Aynı partiye raid cooldown (1 saat)
    DefenderBonus = 0.8,         -- Savunanlar %20 daha az hasar alır
    MinPropsToWin = 5,           -- Kazanmak için minimum yıkılması gereken prop (artırıldı)
    AlertRadius = 2000,          -- Raid alert mesafe
    LootingDuration = 180,       -- Yağma süresi (3 dakika)
    
    -- Raid Ayarları - Silah sistemi eklendi
    AutoGiveWeapons = true,      -- Raid başladığında otomatik silah ver
    WeaponList = {               -- Verilecek silahlar
        "weapon_prophp_ar2"      -- Prop kırma silahı
    },
    UseRaidGlow = true,          -- Raid glow sistemini kullan
    TeamGlowSize = 3,            -- Takım glow boyutu (düşürüldü)
    TeamGlowPasses = 1,          -- Takım glow kalınlığı (düşürüldü)
    EnemyGlowSize = 3,           -- Düşman glow boyutu (düşürüldü)
    EnemyGlowPasses = 1,         -- Düşman glow kalınlığı (düşürüldü)
    TeamGlowColor = Color(0, 255, 0, 200),    -- Yeşil (takım)
    EnemyGlowColor = Color(255, 0, 0, 200),   -- Kırmızı (düşman)
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
    PropInfoDistance = 300,      -- Prop bilgi gösterim mesafesi
    HPBarColor = {
        High = Color(0, 255, 0, 200),      -- Yeşil (75-100%)
        Medium = Color(255, 255, 0, 200),   -- Sarı (25-75%)
        Low = Color(255, 0, 0, 200),        -- Kırmızı (0-25%)
        Background = Color(0, 0, 0, 150)
    }
}

-- ============================
-- PERFORMANS AYARLARI - OPTİMİZE
-- ============================
PropHP.Config.Performance = {
    NetworkUpdateRate = 1.0,     -- Network güncelleme sıklığı (saniye) - artırıldı
    MaxPropsPerParty = 50,       -- Parti başına maksimum prop - DÜŞÜRÜLDÜ
    HPRegenRate = 0,             -- HP rejenerasyonu kapatıldı
    HPUpdateDelay = 0.5,         -- HP güncelleme gecikmesi - artırıldı
    HUDUpdateRate = 0.1,         -- HUD güncelleme sıklığı
    GlowUpdateRate = 0.5,        -- Glow güncelleme sıklığı
    MaxDamageNumbers = 20,       -- Maksimum hasar numarası sayısı
}

-- ============================
-- GÜVENLİK AYARLARI - YENİ
-- ============================
PropHP.Config.Security = {
    EnableAntiExploit = true,    -- Anti-exploit sistemini aktif et
    MaxNetworkRate = 10,         -- Saniyede maksimum network mesajı
    ValidateAllInputs = true,    -- Tüm girdileri doğrula
    LogSuspiciousActivity = true,-- Şüpheli aktiviteleri logla
    BanOnExploit = false,        -- Exploit tespit edilince banla (dikkatli kullan)
}

-- ============================
-- DEBUG AYARLARI
-- ============================
PropHP.Config.Debug = {
    Enabled = false,             -- Debug modunu aç/kapa
    ShowLogs = false,            -- Konsol logları
    ShowNetworkTraffic = false,  -- Network trafiğini göster
    ShowPerformanceMetrics = false -- Performans metriklerini göster
}

-- ============================
-- DİL AYARLARI - YENİ
-- ============================
PropHP.Config.Language = {
    -- Raid Mesajları
    ["raid_started"] = "%s partisi %s partisine savaş açtı!",
    ["raid_preparation"] = "Hazırlık süresi başladı! %d dakikanız var.",
    ["raid_active"] = "Savaş başladı!",
    ["raid_ended"] = "Raid sona erdi! Kazanan: %s",
    ["raid_canceled"] = "%s partisi raid'i iptal etti!",
    ["raid_looting"] = "Yağma aşaması başladı!",
    
    -- Hata Mesajları
    ["error_no_party"] = "Bir partiye üye değilsiniz!",
    ["error_not_leader"] = "Parti lideri değilsiniz!",
    ["error_raid_active"] = "Zaten aktif bir raid var!",
    ["error_prop_limit"] = "Maksimum prop limitine ulaştınız!",
    ["error_nlr"] = "NLR kuralı nedeniyle hasar veremezsiniz!",
    
    -- Bilgi Mesajları
    ["info_prop_placed"] = "Prop yerleştirildi | Sağlam: %d/%d | HP/Prop: %s",
    ["info_prop_destroyed"] = "Prop yok edildi! Sağlam: %d/%d",
    ["info_prop_repaired"] = "%d prop tamir edildi!",
    ["info_hp_pool"] = "HP Havuzu: %s | Prop: %d | HP/Prop: %s",
}

-- ============================
-- ÖDÜL SİSTEMİ AYARLARI - DEVRE DIŞI
-- ============================
PropHP.Config.Rewards = {
    Enabled = false,             -- Ödül sistemi devre dışı
    WinnerReward = 0,           -- Kazanan ödülü
    LoserPenalty = 0,           -- Kaybeden cezası
    PropDestroyBonus = 0,       -- Prop yıkma bonusu
    DefenseBonus = 0,           -- Savunma bonusu
}

-- ============================
-- OTOMATİK AYAR KONTROLÜ
-- ============================
if SERVER then
    -- Sunucu tarafı ayar kontrolü
    hook.Add("Initialize", "PropHP_CheckConfig", function()
        -- Performans ayarlarını kontrol et
        if PropHP.Config.Performance.MaxPropsPerParty > 100 then
            PropHP.Config.Performance.MaxPropsPerParty = 100
            print("[PropHP] UYARI: MaxPropsPerParty 100'e düşürüldü (performans için)")
        end
        
        -- Network güvenliği kontrolü
        if not PropHP.Config.Security.EnableAntiExploit then
            print("[PropHP] UYARI: Anti-exploit sistemi devre dışı!")
        end
        
        -- Debug modu kontrolü
        if PropHP.Config.Debug.Enabled then
            print("[PropHP] UYARI: Debug modu aktif! Production'da kapatmayı unutmayın!")
        end
    end)
    
    print("[PropHP] Konfigürasyon dosyası yüklendi - v3.0 Optimize edilmiş")
else
    print("[PropHP] Client konfigürasyon yüklendi - v3.0")
end