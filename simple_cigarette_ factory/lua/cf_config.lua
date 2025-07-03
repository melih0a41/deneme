cf = {}

-- CONFIG --

-- REMEMBER TO DOWNLOAD THE WORKSHOP CONTENT!!! https://steamcommunity.com/sharedfiles/filedetails/?id=1514815567

-- Sell Mode | Setting it to false allows selling cigarettes without bringing them to the export van.
-- Note that if you're using default sell mode you need to save spawned vans using cf_save command! Otherwise vans will disappear after server restart.
cf.InstantSellMode = true
-- Maximum amount of tobacco machine can contain.
cf.maxTobaccoStorage = 3000

-- Maximum default paper storage.
cf.maxPaperStorage = 300

-- Time (in seconds) it takes to produce one pack.
cf.timeToProduce = 5

-- Amount of paper it takes to produce one pack.
cf.paperProductionCost = 2

-- Amount of tobacco it takes to produce one pack.
cf.tobaccoProductionCost = 20

-- Time (in seconds) it takes for a cigarette pack to despawn (reduces lag).
cf.cigAutoDespawnTime = 480

-- Engine performance multiplier after engine upgrade (1.5 makes it 50% more efficient).
cf.engineUpgradeBoost = 1.5

-- Amount of additional storage after storage upgrade.
cf.storageUpgradeBoostTobacco = 2000 
cf.storageUpgradeBoostPaper = 200

-- Base amount of $ you'll get for one pack sold.
cf.sellPrice = 500

-- How often should the price change (in seconds). 
cf.priceChangeTime = 60

-- Maximum difference in pack price.
cf.maxPriceDifference = 3

-- Max amount of packs that can fit into an export box.
cf.maxCigsBox = 128

-- Max amount of packs player can carry.
cf.maxCigsOnPlayer = 512

-- Machine maximum health
cf.maxMachineHealth = 300

-- Machine hp regen rate 
cf.machineRegen = 4

-- Cigarette SWEP compatibility ( REQUIRES https://steamcommunity.com/sharedfiles/filedetails/?id=793269226&searchtext=cigarette !!!)
cf.allowSwep = true

-- Translation
cf.StorageText = "DEPO YÜKSELTME"
cf.StorageDescText = "AUTO-CIG için depo kapasitesini artırır"
cf.ProductionOffText = "ÜRETİM DURDU"
cf.ProducingText = "ÜRETİMDE"
cf.RefillNeededText = "DOLUM GEREKLİ"
cf.EngineText = "MOTOR YÜKSELTME"
cf.EngineDescText = "AUTO-CIG için motor yükseltmesi"
cf.BoxText = "GÖNDERİ KUTUSU"
cf.BoxDescText1 = "Yalnızca"
cf.BoxDescText2 = "sigara ihracatı için tasarlanmış kutu."
cf.BoxDescText3 = "İçerideki paket sayısı: "
cf.BoxDescText4 = "Toplam değer: "
cf.CurrencyText = "₺"
cf.Notification1 = "En fazla "
cf.Notification2 = " sigara taşıyabilirsin!"
cf.Notification3 = "Bir kutu aldın, içinde "
cf.Notification4 = " paket var!"
cf.MachineHealth = "SAĞLIK"
cf.VanText = "İHRACAT ARACI"
cf.VanDescText1 = "Her sigara paketi için "
cf.VanDescText2 = " ödeme yapar"
cf.SellText1 = "Şu kadar sattın: "
cf.SellText2 = " sigara paketini sattın ve karşılığında "
cf.CommandText1 = "İhracat araçları kaydedildi"
cf.CommandText2 = "İhracat araçları yüklendi"

-- Fonts
if CLIENT then
	surface.CreateFont( "cf_machine_main", {
		font = "Impact",    
		size = 24
	})
	surface.CreateFont( "cf_machine_small", {
		font = "Impact",    
		size = 16,
		outline = true
	})
end