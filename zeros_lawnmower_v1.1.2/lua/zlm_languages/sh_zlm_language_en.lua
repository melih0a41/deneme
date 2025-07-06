/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm or {}
zlm.language = zlm.language or {}
zlm.language.General = zlm.language.General or {}

if (zlm.config.SelectedLanguage == "en") then  -- Dil kontrolünü "tr" olarak değiştirdik

    zlm.language.General["GrassBuyerTitle"] = "Çim Rulo Alıcısı"
    zlm.language.General["Storage"] = "Depo"
    zlm.language.General["UpgradeSpeed"] = "Hızı Yükselt"
    zlm.language.General["MaxLevel"] = "Son Seviye!" -- Kullanıcıya maksimum yükseltme seviyesine ulaşıldığını bildirir
    zlm.language.General["SellGrass"] = "Çim Sat"

    zlm.language.General["NotEnoughMoney"] = "Yeterli paranız yok!"
    zlm.language.General["GrassRollLimitReached"] = "Çim Rulo Limiti Doldu!"
    zlm.language.General["GrassPressSpeedIncreased"] = "Çim Pres Hızı Arttırıldı!"

    zlm.language.General["TrailerEmpty"] = "Römork boş!"
    zlm.language.General["NoBuyerNPCFound"] = "Çim Alıcısı NPC bulunamadı!"

    zlm.language.General["GrassBasketMissing"] = "Çim Sepeti takılı değil!"
    zlm.language.General["GrassBasketAttached"] = "Çim Sepeti takıldı!"

    zlm.language.General["NotEnoughFuel"] = "Yeterli yakıt yok!"

    zlm.language.General["GrassStorageFull"] = "Çim Deposu Dolu!"
    zlm.language.General["GrassStorageEmpty"] = "Çim Deposu Boş!"

    zlm.language.General["NoTrailerBasketFound"] = "Römork veya Çim Sepeti bulunamadı!"

    zlm.language.General["TrailerAttached"] = "Römork takıldı!"
    zlm.language.General["TrailerDeAttached"] = "Römork çıkarıldı!" -- 'dettached' kelimesi İngilizce'de de hatalı yazılmış, 'detached' olmalıydı. Türkçe çevirisi 'çıkarıldı'.

    zlm.language.General["TrailerNotCloseEnough"] = "Römorka yaklaşın, Bağlantı Başarısız!"

    zlm.language.General["GrassPressFull"] = "Çim Presinde yeterli alan yok!"

    zlm.language.General["NoGrassPressFound"] = "Çim Presi bulunamadı!"
    zlm.language.General["UnloadingLawnMower"] = "Çim Biçme Makinesi Boşaltılıyor"


    // Güncelleme 1.0.8
    zlm.language.General["VehicleShop"] = "Araç Mağazası"
    zlm.language.General["WrongJob"] = "Yanlış Meslek!"
    zlm.language.General["NofreeVehicleSpawn"] =  "Boş Araç Doğma Noktası bulunamadı!"
    zlm.language.General["YouallreadyownaLawnMower"] =  "Zaten bir Çim Biçme Makineniz var!"
    zlm.language.General["YouallreadyownaTrailer"] =  "Zaten bir Römorkunuz var!"
    zlm.language.General["VehiclePurchased"] =  "Araç Satın Alındı!"
    zlm.language.General["Cost"] =  "Fiyat"

end
