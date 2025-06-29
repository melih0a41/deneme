/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

zvm = zvm or {}
zvm.language = zvm.language or {}
zvm.language.General = zvm.language.General or {}

if (zvm.config.SelectedLanguage == "tr") then

    zvm.language.General["Pay"] = "Ode"
    zvm.language.General["Back"] = "Geri"
    zvm.language.General["InCorrectRank"] = "Dogru rutbeye sahip degilsiniz!"
    zvm.language.General["BuyLimitReached"] = "Satin alma limitine ulasildi!"
    zvm.language.General["NotEnoughMoney"] = "Yeterli paraniz yok!"
    zvm.language.General["PressToStart"] = "Baslamak icin basin!"
    zvm.language.General["Occupied"] = "Mesgul!"
    zvm.language.General["EditProducts"] = "Urunleri Duzenle"
    zvm.language.General["Customization"] = "Ozellestirme"
    zvm.language.General["Apply"] = "Uygula"
    zvm.language.General["Products"] = "Urunler"
    zvm.language.General["ChangeRank"] = "Rutbe Grubunu Degistir"
    zvm.language.General["ChangeName"] = "Ismi Degistir"
    zvm.language.General["ChangePrice"] = "Fiyati Degistir"
    zvm.language.General["ChangeColor"] = "Rengi Degistir"
    zvm.language.General["Skins"] = "Kaplamalar"
    zvm.language.General["None"] = "Hicbiri"
    zvm.language.General["PurchaseSuccessful"] = "Satin alma basarili!"

    zvm.language.General["PackageOpens"] = "Paket aciliyor"
    zvm.language.General["YouDontOwnThis"] = "Buna sahip degilsiniz!"
    zvm.language.General["ChangeJob"] = "Meslek Grubunu Degistir"
    zvm.language.General["Restrictions"] = "Kisitlemalar"
    zvm.language.General["Appearance"] = "Gorunum"
    zvm.language.General["ChangeBackgroundColor"] = "Arka Plan Rengini Degistir"
    zvm.language.General["WrongJob"] = "Yanlis Meslek!"

    zvm.language.General["OutofOrder"] = "Ariza"
    zvm.language.General["Payout"] = "Odeme"

    zvm.language.General["CurrencyType"] = "Para Birimi Turu"
    zvm.language.General["Money"] = "Para"
    zvm.language.General["ChangeCurrency"] = "Para Birimini Degistir"

    // Guncelleme 1.7
    zvm.language.General["Weapon Skin"] = "Silah Kaplamasi"
    zvm.language.General["Edit"] = "Duzenleme Modu" -- "Edit Mode" idi, "Duzenle" yerine daha uygun
    zvm.language.General["DisplayOrder"] = "Gosterim Sirasi"

    // Guncelleme 2.1.0
    zvm.language.General["Global"] = "Global" -- Global olarak birakilabilir veya "Genel" kullanilabilir
    zvm.language.General["Save All"] = "Tumunu Kaydet"
    zvm.language.General["Presets"] = "On Ayarlar"
    zvm.language.General["ItemCount"] = "$Amount Oge" -- $Amount degiskeni korundu
    zvm.language.General["New"] = "Yeni"
    zvm.language.General["Load"] = "Yukle"
    zvm.language.General["Delete"] = "Sil"

    // Guncelleme 3.0.0
    zvm.language.General["AppearanceEditor"] = "Gorunum Duzenleyici"
    zvm.language.General["StyleSelection"] = "Stil - Secim"
    zvm.language.General["StyleEditor"] = "Stil - Duzenleyici"
    zvm.language.General["Close"] = "Kapat"
    zvm.language.General["CachedImages"] = "Onbelleklenen Resimler"
    zvm.language.General["OpenCachedImages"] = "Onbelleklenen resimleri ac"
    zvm.language.General["DeleteStyle"] = "Secili stili sil" -- Bu asagidaki ile ayni olacak, soru formu icin asagidakini kullan
    zvm.language.General["EditStyle"] = "Secili stili duzenle"
    zvm.language.General["DuplicateStyle"] = "Secili stili cogalt" -- Bu asagidaki ile ayni olacak, soru formu icin asagidakini kullan
    zvm.language.General["CreateStyle"] = "Yeni stil olustur"
    zvm.language.General["ApplyStyle"] = "Secili stili otomat makinesine uygula"
    zvm.language.General["SaveStyle"] = "Stili Kaydet"
    zvm.language.General["Material"] = "Malzeme"
    zvm.language.General["Imgur"] = "Imgur" -- Ozel isim, degistirilmedi
    zvm.language.General["Surface"] = "Yuzey"
    zvm.language.General["Fresnel"] = "Fresnel" -- Teknik terim, degistirilmedi
    zvm.language.General["Reflection"] = "Yansima"
    -- zvm.language.General["Surface"] = "Yuzey" -- Yukarida zaten tanimli
    zvm.language.General["ImgurID"] = "ImgurID" -- Ozel tanimlama, degistirilmedi
    zvm.language.General["PositionX"] = "Pozisyon X"
    zvm.language.General["PositionY"] = "Pozisyon Y"
    zvm.language.General["Scale"] = "Olcek"
    zvm.language.General["Touch"] = "[ Dokun ]"

    // Guncelleme 3.0.1
    zvm.language.General["DeleteStyle"] = "Bu stili sil?" -- Soru formu
    zvm.language.General["DuplicateStyle"] = "Bu stili cogalt?" -- Soru formu
    zvm.language.General["Yes"] = "Evet"
    zvm.language.General["No"] = "Hayir"
    zvm.language.General["Base Color"] = "Temel Renk"
    zvm.language.General["Reflection Color"] = "Yansima Rengi"
    zvm.language.General["Image Color"] = "Resim Rengi"
    zvm.language.General["Logo"] = "Logo" -- Logo olarak kalabilir
    zvm.language.General["Rotation"] = "Dondurme"
    zvm.language.General["2D Preview"] = "2D Onizleme"
    zvm.language.General["Emissive"] = "Yayici"
    zvm.language.General["Emissive Color"] = "Yayici Renk"
    zvm.language.General["Strength"] = "Guc"

    // Guncelleme 3.0.4
    zvm.language.General["Overwrite"] = "Uzerine Yaz"
end
