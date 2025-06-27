-- gscooters/lua/scooters/sh_config.lua
-- Scooter başına ödeme sistemi eklendi

-- TEAM TANIMLARI
TEAM_MARTI = TEAM_MARTI or 3 -- Veya sunucunuzda Marti job'ının team ID'si neyse onu yazın

gScooters.Config.Language = "english"

gScooters.Config.CurrencyOnLeft = false
gScooters.Config.CurrencySymbol = " ₺"

gScooters.Config.ScooterPickupRequirement = 5

gScooters.Config.RetrieverModel = "models/Humans/Group02/male_02.mdl"
gScooters.Config.Use3d2d = true

gScooters.Config.JobAcceptKey = KEY_J -- https://wiki.facepunch.com/gmod/Enums/KEY
gScooters.Config.JobSellKey = KEY_H -- https://wiki.facepunch.com/gmod/Enums/KEY

-- FİX: Eski sabit ödeme sistemini değiştir
gScooters.Config.JobPayment = 25000 -- DEPRECATED - artık kullanılmıyor
gScooters.Config.JobPaymentPerScooter = 30000 -- Her scooter için alınacak ödeme

gScooters.Config.RentalRate = 5000 -- How much money should be charged per minute of usage?
gScooters.Config.RentalMenuKey = KEY_B -- https://wiki.facepunch.com/gmod/Enums/KEY

gScooters.Config.AdminGroups = {
    ["superadmin"] = true,
}

-- DebugMode - production'da false yapın console spam'ını önlemek için
gScooters.Config.DebugMode = false -- true yapın debug mesajları görmek için

-- Scooter toplama sistemi ayarları
gScooters.Config.MinMovedDistance = 50 -- Scooter'ın spawn'dan kaç birim uzaklaşması gerekiyor toplanabilmesi için
gScooters.Config.MinCollectableScooters = 3 -- Görev göndermek için en az kaç toplanabilir scooter olması gerekiyor
gScooters.Config.JobCooldown = 300 -- Görev cooldown süresi saniye cinsinden (varsayılan 5 dakika)

local sConfigTheme = "dark"

if sConfigTheme == "dark" then
    gScooters.Config.PrimaryColor = Color(36, 36, 36)  
    gScooters.Config.SecondaryColor = Color(29, 29, 29)
    gScooters.Config.ButtonColor = Color(90, 90, 90)
    gScooters.Config.AccentColor = Color(0, 123, 253)
    gScooters.Config.TextColor =  Color(255, 255, 255)
    gScooters.Config.Light = false

elseif sConfigTheme == "light" then
    gScooters.Config.PrimaryColor = Color(224, 224, 224)
    gScooters.Config.SecondaryColor = Color(236, 236, 236) 
    gScooters.Config.ButtonColor = Color(90, 90, 90)
    gScooters.Config.AccentColor = Color(0, 123, 253)
    gScooters.Config.TextColor =  Color(59, 59, 59)
    gScooters.Config.Light = true

elseif sConfigTheme == "mytheme" then
    gScooters.Config.PrimaryColor = Color(36, 36, 36)  
    gScooters.Config.SecondaryColor = Color(29, 29, 29)
    gScooters.Config.ButtonColor = Color(90, 90, 90)
    gScooters.Config.AccentColor = Color(0, 123, 253)
    gScooters.Config.TextColor =  Color(255, 255, 255)
    gScooters.Config.Light = false
end

-- Only touch this area if you absolutely know what you are doing!

gScooters.Config.Van = {
    Name = "Mercedes Sprinter",
    Description = "Marti tasiyan arac",
    Model = "models/lonewolfie/merc_sprinter_swb.mdl",
    Script = "scripts/vehicles/LWCars/merc_sprinter_swb.txt",
    Color = Color(255, 255, 255),
    AddedPower = 100,
    Skin = 1,
    Bodygroups = {
        [1] = 1,
        [2] = 1,
        [3] = 0
    }
}

gScooters.Config.Scooter = {
    AddedPower = 0,
}

gScooters.Config.UIisEnabled = true -- If you want to just use the scooters without all the UI disable this