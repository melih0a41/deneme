-- fib_sistem/lua/autorun/a_fib_config.lua
-- Bu dosya hem client hem server tarafında yüklenir

FIB = FIB or {}
FIB.Config = FIB.Config or {}

-- Debug mesajı
if SERVER then
    print("[FIB] Config dosyası server tarafında yüklendi")
else
    print("[FIB] Config dosyası client tarafında yüklendi")
end

-- Whitelist ve Login Bilgileri
FIB.Config.Users = {
    ["STEAM_0:1:173464330"] = {
        username = "CHIEF_GEBZE",
        password = "FIB2024gebze",
        rank = "Sef"
    },
    ["STEAM_0:1:12345678"] = {
        username = "AGENT001",
        password = "FIB#2024$Alpha",
        rank = "Ajan"
    },
    ["STEAM_0:0:87654321"] = {
        username = "CHIEF007",
        password = "FIB#Chief$2024",
        rank = "Sef"
    },
}

-- Rütbe yetkileri
FIB.Config.Ranks = {
    ["Sef"] = {
        canAddAgents = true,
        canRemoveAgents = true,
        canCreateMissions = true,
        canAccessDepartment = true,
        canUseUndercover = true
    },
    ["Kidemli Ajan"] = {
        canAddAgents = false,
        canRemoveAgents = false,
        canCreateMissions = true,
        canAccessDepartment = false,
        canUseUndercover = true
    },
    ["Ajan"] = {
        canAddAgents = false,
        canRemoveAgents = false,
        canCreateMissions = false,
        canAccessDepartment = false,
        canUseUndercover = true
    }
}

-- Renk Teması - Daha karanlık ve modern
FIB.Config.Colors = {
    primary = Color(5, 10, 20, 255),         -- Çok koyu mavi-siyah
    secondary = Color(10, 20, 35, 255),      -- Koyu mavi panel
    accent = Color(0, 120, 255, 255),        -- FIB mavisi
    background = Color(2, 15, 35, 255),      -- Çok koyu parlament mavisi
    panel_bg = Color(5, 15, 30, 240),        -- Panel arka planı
    text = Color(255, 255, 255, 255),        -- Beyaz text
    text_dim = Color(180, 180, 190, 255),    -- Soluk text
    error = Color(255, 65, 65, 255),         -- Kırmızı error
    success = Color(65, 255, 65, 255),       -- Yeşil success
    warning = Color(255, 200, 0, 255),       -- Sarı uyarı
    hover = Color(0, 150, 255, 255),         -- Hover efekti
    glow = Color(0, 200, 255, 100),          -- Glow efekti
    border = Color(0, 100, 200, 200)         -- Kenarlık rengi
}

-- Türkçe Metinler - I harfleri düzeltildi
FIB.Config.Texts = {
    title = "FEDERAL ISTIHBARAT BUROSU",
    subtitle = "GUVENLI ERISIM TERMINALI",
    auth_required = "KIMLIK DOGRULAMA GEREKLI",
    agent_id = "AJAN KODU:",
    password = "SIFRE:",
    id_placeholder = "Ajan kodunuzu girin",
    pass_placeholder = "Sifrenizi girin",
    access_system = "SISTEME GIRIS YAP",
    authenticating = "Dogrulaniyor...",
    fill_fields = "! Tum alanlari doldurun",
    access_denied = "Erisim Reddedildi - Yetkisiz",
    invalid_creds = "Gecersiz Kimlik Bilgileri",
    access_granted = "Erisim Onaylandi - Hos Geldin",
    connecting = "Baglaniyor...",
    verifying = "Kimlik kontrol ediliyor...",
    welcome_title = "HOS GELDIN",
    system_ready = "Sistem Hazir",
    main_menu = "Ana Menuye Gec",
    
    -- Yeni animasyonlu mesajlar
    auth_step1 = "Sunucuya baglaniyor...",
    auth_step2 = "Kimlik bilgileri gonderiliyor...",
    auth_step3 = "Veritabani sorgusu yapiliyor...",
    auth_step4 = "Guvenlik protokolleri kontrol ediliyor...",
    auth_step5 = "Yetki seviyesi belirleniyor...",
    auth_success = "Kimlik dogrulandi!",
    auth_fail = "Kimlik dogrulama basarisiz!",
    
    -- Sistem mesajları
    system_init = "FIB Sistemi baslatiliyor...",
    system_secure = "Guvenli baglanti kuruldu",
    system_encrypt = "256-bit sifreleme aktif",
    database_connect = "FIB veritabanina baglaniyor...",
    database_query = "Kullanici bilgileri sorgulaniyor..."
}