L = {}
STL = {}

-- çevrilecek bir dize değil, ancak bir dilin kendi yazı tipine ihtiyacı olması durumunda
L["default_font"] = "Bahnschrift"

-- Eklenti Yuvaları
L["attslot.optic"] = "Optik"
L["attslot.bkoptic"] = "Yedek Optik"
L["attslot.muzzle"] = "Namlu Ucu"
L["attslot.barrel"] = "Namlu"
L["attslot.choke"] = "Şok"
L["attslot.underbarrel"] = "Namlu Altı"
L["attslot.tactical"] = "Taktiksel"
L["attslot.grip"] = "Kabza"
L["attslot.stock"] = "Dipçik"
L["attslot.fcg"] = "Ateşleme Grubu"
L["attslot.ammo"] = "Mühimmat Türü"
L["attslot.perk"] = "Yetenek"
L["attslot.charm"] = "Uğurluk"
L["attslot.skin"] = "Görünüm"
L["attslot.noatt"] = "Eklenti Yok"
L["attslot.optic.default"] = "Demir Nişangah"
L["attslot.muzzle.default"] = "Standart Namlu Ucu"
L["attslot.barrel.default"] = "Standart Namlu"
L["attslot.choke.default"] = "Standart Şok"
L["attslot.grip.default"] = "Standart Kabza"
L["attslot.stock.default"] = "Standart Dipçik"
L["attslot.stock.none"] = "Dipçik Yok"
L["attslot.fcg.default"] = "Standart Ateşleme Grubu"

-- Ek Bilgiler (Trivia)
L["trivia.class"] = "Sınıf"
L["trivia.year"] = "Yıl"
L["trivia.mechanism"] = "Mekanizma"
L["trivia.calibre"] = "Kalibre"
L["trivia.ammo"] = "Mühimmat Türü"
L["trivia.country"] = "Ülke"
L["trivia.manufacturer"] = "Üretici"
L["trivia.clipsize"] = "Şarjör Kapasitesi"
L["trivia.precision"] = "Hassasiyet"
L["trivia.noise"] = "Gürültü"
L["trivia.recoil"] = "Dikey Geri Tepme"
L["trivia.penetration"] = "Nüfuz Etme"
L["trivia.firerate"] = "Atış Hızı"
L["trivia.firerate_burst"] = "Darbeli Atış Hızı"
L["trivia.fusetime"] = "Fitil Süresi"

-- Sınıf
L["class.pistol"] = "Tabanca"
L["class.revolver"] = "Revolver"
L["class.machinepistol"] = "Makineli Tabanca"
L["class.smg"] = "Hafif Makineli Tüfek"
L["class.pdw"] = "Kişisel Savunma Silahı"
L["class.shotgun"] = "Pompalı Tüfek"
L["class.assaultcarbine"] = "Taarruz Karabinası"
L["class.carbine"] = "Karabina"
L["class.assaultrifle"] = "Taarruz Tüfeği"
L["class.rifle"] = "Tüfek"
L["class.battlerifle"] = "Savaş Tüfeği"
L["class.dmr"] = "DMR (Belirlenmiş Nişancı Tüfeği)"
L["class.sniperrifle"] = "Keskin Nişancı Tüfeği"
L["class.antimaterielrifle"] = "Anti-Materyal Tüfeği"
L["class.rocketlauncher"] = "Roketatar"
L["class.grenade"] = "El Bombası"
L["class.melee"] = "Yakın Dövüş Silahı"

-- Arayüz (UI)
L["ui.savepreset"] = "Hazır Ayarı Kaydet"
L["ui.loadpreset"] = "Hazır Ayarı Yükle"
L["ui.stats"] = "İstatistikler"
L["ui.trivia"] = "Ek Bilgiler"
L["ui.tttequip"] = "Ekipman"
L["ui.tttchat"] = "Hızlı Sohbet"
L["ui.position"] = "POZİSYON"
L["ui.positives"] = "ARTILARI:"
L["ui.negatives"] = "EKSİLERİ:"
L["ui.information"] = "BİLGİ:"

-- İstatistikler
L["stat.stat"] = "İstatistik" -- İstatistik sayfasının ilk satırında kullanılır
L["stat.original"] = "Orijinal"
L["stat.current"] = "Mevcut"
L["stat.damage"] = "Yakın Mesafe Hasarı"
L["stat.damage.tooltip"] = "Bu silahın çok yakın mesafeden ne kadar hasar verdiği."
L["stat.damagemin"] = "Uzak Mesafe Hasarı"
L["stat.damagemin.tooltip"] = "Bu silahın menzili dışında ne kadar hasar verdiği."
L["stat.range"] = "Menzil"
L["stat.range.tooltip"] = "Yakın mesafe hasarının uzak mesafe hasarına dönüştüğü metre cinsinden mesafe."
L["stat.firerate"] = "Atış Hızı"
L["stat.firerate.tooltip"] = "Bu silahın dakikadaki mermi (RPM) cinsinden atış döngü hızı."
L["stat.firerate.manual"] = "MANUEL" -- Manuel bir silah olduğunda RPM yerine gösterilir
L["stat.capacity"] = "Kapasite"
L["stat.capacity.tooltip"] = "Bu silahın kaç mermi alabildiği."
L["stat.precision"] = "Hassasiyet"
L["stat.precision.tooltip"] = "Silahın sabit dururken ve nişan alırken MOA (açı dakikası) cinsinden ne kadar hassas olduğu."
L["stat.hipdisp"] = "Kalçadan Atış Dağılımı"
L["stat.hipdisp.tooltip"] = "Silah kalçadan ateşlendiğinde ne kadar isabetsizlik eklendiği."
L["stat.movedisp"] = "Hareket Halinde İsabet"
L["stat.movedisp.tooltip"] = "Silah hareket halindeyken kullanıldığında ne kadar isabetsizlik eklendiği."
L["stat.recoil"] = "Geri Tepme"
L["stat.recoil.tooltip"] = "Her atışta üretilen tepme miktarı."
L["stat.recoilside"] = "Yanal Geri Tepme"
L["stat.recoilside.tooltip"] = "Her atışta üretilen yatay tepme miktarı."
L["stat.sighttime"] = "Kullanım Süresi"
L["stat.sighttime.tooltip"] = "Bu silahla koşudan nişan almaya veya nişan almadan koşuya geçişin ne kadar sürdüğü."
L["stat.speedmult"] = "Hareket Hızı"
L["stat.speedmult.tooltip"] = "Silahla hareket etme hızınız, orijinal hızın yüzdesi olarak."
L["stat.sightspeed"] = "Nişan Alırken Hız"
L["stat.sightspeed.tooltip"] = "Nişan alarak hareket ederken uygulanan ek yavaşlama."
L["stat.meleedamage"] = "Yakın Dövüş Vuruş Hasarı"
L["stat.meleedamage.tooltip"] = "Yakın dövüş vuruşunun ne kadar hasar verdiği."
L["stat.meleetime"] = "Yakın Dövüş Vuruş Süresi"
L["stat.meleetime.tooltip"] = "Bir yakın dövüş vuruşu yapmanın ne kadar sürdüğü."
L["stat.shootvol"] = "Ateşleme Sesi Seviyesi"
L["stat.shootvol.tooltip"] = "Silahın desibel cinsinden ne kadar gürültülü olduğu. Daha gürültülü silahlar daha uzaktan duyulabilir."
L["stat.barrellen"] = "Silah Uzunluğu"
L["stat.barrellen.tooltip"] = "Silahın Hammer birimi / inç cinsinden uzunluğu. Uzun namlular duvarlar tarafından daha kolay engellenir."
L["stat.pen"] = "Nüfuz Etme"
L["stat.pen.tooltip"] = "Bu silahın ne kadar malzemeye nüfuz edebildiği."

-- Otomatik İstatistikler
L["autostat.bipodrecoil"] = "Bipodda Geri Tepme"
L["autostat.bipoddisp"] = "Bipodda Dağılım"
L["autostat.damage"] = "Yakın mesafe hasarı"
L["autostat.damagemin"] = "Uzak mesafe hasarı"
L["autostat.damageboth"] = "Hasar" -- Hasar ve minimum hasar aynı değerde olduğunda
L["autostat.range"] = "Menzil"
L["autostat.penetration"] = "Nüfuz Etme"
L["autostat.muzzlevel"] = "Namlu Çıkış Hızı"
L["autostat.meleetime"] = "Yakın Dövüş Saldırı Süresi"
L["autostat.meleedamage"] = "Yakın Dövüş Hasarı"
L["autostat.meleerange"] = "Yakın Dövüş Menzili"
L["autostat.recoil"] = "Geri Tepme"
L["autostat.recoilside"] = "Yatay Geri Tepme"
L["autostat.firerate"] = "Atış Hızı"
L["autostat.precision"] = "İsabetsizlik"
L["autostat.hipdisp"] = "Kalçadan Atışta Yayılım"
L["autostat.sightdisp"] = "Nişan Alırken Yayılım"
L["autostat.movedisp"] = "Hareket Halinde Yayılım"
L["autostat.jumpdisp"] = "Havadayken Yayılım"
L["autostat.barrellength"] = "Silah Uzunluğu"
L["autostat.shootvol"] = "Silah Sesi Seviyesi"
L["autostat.speedmult"] = "Hareket Hızı"
L["autostat.sightspeed"] = "Nişan Alırken Hız"
L["autostat.shootspeed"] = "Ateş Ederken Hız"
L["autostat.reloadtime"] = "Şarjör Değiştirme Süresi"
L["autostat.drawtime"] = "Silah Çekme Süresi"
L["autostat.sighttime"] = "Kontrol"
L["autostat.cycletime"] = "Döngü Süresi"
L["autostat.magextender"] = "Genişletilmiş Şarjör Boyutu"
L["autostat.magreducer"] = "Küçültülmüş Şarjör Boyutu"
L["autostat.bipod"] = "Bipod Kullanılabilir"
L["autostat.holosight"] = "Hassas Nişangah Görünümü"
L["autostat.zoom"] = "Artırılmış Yakınlaştırma"
L["autostat.glint"] = "Görünür Dürbün Parıltısı"
L["autostat.thermal"] = "Termal Görüş"
L["autostat.silencer"] = "Ateşleme Sesini Bastırır"
L["autostat.norandspr"] = "Rastgele Yayılım Yok"
L["autostat.sway"] = "Nişan Alma Sallanması"
L["autostat.heatcap"] = "Isı Kapasitesi"
L["autostat.heatfix"] = "Aşırı Isınma Düzeltme Süresi"
L["autostat.heatdelay"] = "Isı Geri Kazanım Gecikmesi"
L["autostat.heatdrain"] = "Isı Geri Kazanım Hızı"

-- TTT
L["ttt.roundinfo"] = "ArcCW Yapılandırması"
L["ttt.roundinfo.replace"] = "TTT Silahlarını Otomatik Değiştir"
L["ttt.roundinfo.cmode"] = "Özelleştirme Modu:"
L["ttt.roundinfo.cmode0"] = "Kısıtlama Yok"
L["ttt.roundinfo.cmode1"] = "Kısıtlı"
L["ttt.roundinfo.cmode2"] = "Sadece Oyun Öncesi"
L["ttt.roundinfo.cmode3"] = "Sadece Hain/Dedektif"

L["ttt.roundinfo.attmode"] = "Eklenti Modu:"
L["ttt.roundinfo.free"] = "Ücretsiz"
L["ttt.roundinfo.locking"] = "Kilitlemeli"
L["ttt.roundinfo.inv"] = "Envanter" -- Duplicate key, using the same translation
L["ttt.roundinfo.persist"] = "Kalıcı"
L["ttt.roundinfo.drop"] = "Ölümde Düşer"
-- L["ttt.roundinfo.inv"] = "Envanter" -- This key is already defined above.
L["ttt.roundinfo.pickx"] = "Seç"

L["ttt.roundinfo.bmode"] = "Cesette Eklenti Bilgisi:"
L["ttt.roundinfo.bmode0"] = "Mevcut Değil"
L["ttt.roundinfo.bmode1"] = "Sadece Dedektifler"
L["ttt.roundinfo.bmode2"] = "Mevcut"

L["ttt.roundinfo.amode"] = "Mühimmat Patlaması:"
L["ttt.roundinfo.amode-1"] = "Devre Dışı"
L["ttt.roundinfo.amode0"] = "Basit"
L["ttt.roundinfo.amode1"] = "Şarapnel"
L["ttt.roundinfo.amode2"] = "Tam"
L["ttt.roundinfo.achain"] = "Zincirleme Patlamalar"

L["ttt.bodyatt.found"] = "Cinayet silahının..." // (İngilizce'de eksik cümle, Türkçe'ye daha uygun hale getirildi: "Cinayet silahının şöyle olduğunu düşünüyorsun:")
L["ttt.bodyatt.founddet"] = "Dedektiflik becerilerinle, cinayet silahının..." // ("Dedektiflik becerilerinle cinayet silahını şöyle tespit ettin:")
L["ttt.bodyatt.att1"] = " {att} takılı olduğunu." // ("...{att} takılıydı.")
L["ttt.bodyatt.att2"] = " {att1} ve {att2} takılı olduğunu." // ("...{att1} ve {att2} takılıydı.")
L["ttt.bodyatt.att3"] = " şu eklentilere sahip olduğunu: " // ("...şu eklentilere sahipti: ")

L["ttt.attachments"] = " Eklenti(ler): " -- TTT2 Hedef Kimliğinde kullanılır
L["ttt.ammo"] = "Mühimmat: " -- TTT2 Hedef Kimliğinde kullanılır

-- Eskiden CS+'da olan şeyler, neden acaba
L["info.togglesight"] = "Nişangahları değiştirmek için +KULLAN tuşuna çift basın"
L["info.toggleubgl"] = "Namlu altını değiştirmek için +YAKINLAŞTIR tuşuna çift basın" -- kullanımdan kaldırıldı
L["pro.ubgl"] = "Seçilebilir namlu altı fırlatıcı" -- kullanımdan kaldırıldı
L["pro.ubsg"] = "Seçilebilir namlu altı pompalı tüfek" -- kullanımdan kaldırıldı
L["con.obstruction"] = "Nişangahı engelleyebilir"
L["autostat.underwater"] = "Su altında ateş et"
L["autostat.sprintshoot"] = "Koşarken ateş et"
L["con.beam"] = "Görünür lazer ışını"
L["con.light"] = "Görünür fener ışını"
L["con.noscope"] = "Nişan noktası yok"
L["pro.invistracers"] = "Görünmez izli mermiler"

-- Uyumsuzluk Menüsü
L["incompatible.title"] = "ArcCW: UYUMSUZ EKLENTİLER"
L["incompatible.line1"] = "ArcCW ile çalışmadığı bilinen bazı eklentileriniz var."
L["incompatible.line2"] = "Onları devre dışı bırakın ya da hatalı davranışlar bekleyin!"
L["incompatible.confirm"] = "Anladım"
L["incompatible.wait"] = "{time}sn Bekle"
L["incompatible.never"] = "Beni bir daha asla uyarma"
L["incompatible.never.hover"] = "Sonuçlarını anladığınızdan kesinlikle emin misiniz?"
L["incompatible.never.confirm"] = "Uyumluluk uyarılarını bir daha asla göstermemeyi seçtiniz. Hatalarla veya bozuk davranışlarla karşılaşırsanız, bu sizin kendi sorumluluğunuzdadır."

-- 2020-12-11
L["hud.hp"] = "Can: " -- Varsayılan HUD'da kullanılır
L["fcg.safe"] = "Emniyet"
L["fcg.semi"] = "Yarı Otomatik"
L["fcg.auto"] = "Otomatik"
L["fcg.burst"] = "%d'li Darbe"
L["fcg.ubgl"] = "NAB" -- Namlu Altı Bombaatar

-- 2021-01-14
L["ui.toggle"] = "DEĞİŞTİR"
L["ui.whenmode"] = "%s Olduğunda"
L["ui.modex"] = "Mod %s"

-- 2021-01-25
L["attslot.magazine"] = "Şarjör"

-- 2021-03-13
L["trivia.damage"] = "Hasar"
L["trivia.range"] = "Menzil"
L["trivia.attackspersecond"] = "Saniyedeki Saldırı Sayısı"
L["trivia.description"] = "Açıklama"
L["trivia.meleedamagetype"] = "Hasar Türü"

-- Birimler
L["unit.rpm"] = "RPM" -- Dakikadaki Mermi Sayısı
L["unit.moa"] = "MOA" -- Açı Dakikası
L["unit.mm"] = "mm"
L["unit.db"] = "dB"
L["unit.bce"] = "BK" -- Balistik Katsayı
L["unit.aps"] = "SPS" -- Saniyedeki Saldırı

-- yakın dövüş hasar türleri
L["dmg.generic"] = "Silahsız"
L["dmg.bullet"] = "Delici"
L["dmg.slash"] = "Kesici"
L["dmg.club"] = "Ezici"
L["dmg.shock"] = "Şok"

L["ui.presets"] = "Hazır Ayarlar"
L["ui.customize"] = "Özelleştir"
L["ui.inventory"] = "Envanter"

-- 2021-05-05
L["ui.gamemode_buttons"] = "Oyun Moduna Özel Komutlar"
L["ui.gamemode_usehint"] = "Orijinal tuş atamalarına erişmek için KULLAN tuşuna basılı tutabilirsiniz."
L["ui.darkrpdrop"] = "Silahı Bırak"
L["ui.noatts"] = "Hiç eklentin yok"
L["ui.noatts_slot"] = "Bu yuva için hiç eklentin yok"
L["ui.lockinv"] = "Bu eklentiler tüm silahlar için açıktır."
L["autostat.ammotype"] = "Silah mühimmat türünü %s olarak değiştirir"

-- 2021-05-08
L["autostat.rangemin"] = "Minimum Menzil"

-- 2021-05-13
L["autostat.malfunctionmean"] = "Güvenilirlik"
L["ui.heat"] = "ISI"
L["ui.jammed"] = "TUTUKLUK"

-- 2021-05-15
L["trivia.muzzlevel"] = "Namlu Çıkış Hızı"
L["unit.mps"] = "m/s"
L["unit.lbfps"] = "lb-fps"
L["trivia.recoilside"] = "Yatay Geri Tepme"

--2021-05-27
L["ui.pickx"] = "Eklentiler: %d/%d"
L["ui.ballistics"] = "Balistik"

L["ammo.pistol"] = "Tabanca Mermisi"
L["ammo.357"] = "Magnum Mermisi"
L["ammo.smg1"] = "Karabina Mermisi"
L["ammo.ar2"] = "Tüfek Mermisi"
L["ammo.buckshot"] = "Pompalı Tüfek Saçması"
L["ammo.sniperpenetratedround"] = "Keskin Nişancı Mermisi"
L["ammo.smg1_grenade"] = "Tüfek Bombaları"

--2021-05-31
L["ui.nodata"] = "Veri Yok"
L["ui.createpreset"] = "Oluştur"
L["ui.deletepreset"] = "Sil"

--2021-06-09 güzel
L["autostat.clipsize"] = "%d mermilik şarjör kapasitesi"

--2021-06-30
L["autostat.bipod2"] = "Bipod kullanımına izin verir (-%d%% Dağılım, -%d%% Geri Tepme)"
L["autostat.nobipod"] = "Bipodu devre dışı bırakır"

--2021-07-01
L["fcg.safe2"] = "İndirilmiş"
L["fcg.dact"] = "Çift Hareketli"
L["fcg.sact"] = "Tek Hareketli"
L["fcg.bolt"] = "Sürgülü Mekanizma"
L["fcg.pump"] = "Pompalı"
L["fcg.lever"] = "Levyeli"
L["fcg.manual"] = "Manuel"
L["fcg.break"] = "Kırmalı"
L["fcg.sngl"] = "Tekli"
L["fcg.both"] = "Her İkisi"

--2021-08-11
L["autostat.clipsize.mod"] = "Şarjör kapasitesi" -- Add_ClipSize ve Mult_ClipSize için kullanılır

--2021-08-22
L["trivia.recoilscore"] = "Geri Tepme Puanı (Düşük olan daha iyidir)"
L["fcg.safe.abbrev"] = "EMN"
L["fcg.semi.abbrev"] = "YARI"
L["fcg.auto.abbrev"] = "OTO"
L["fcg.burst.abbrev"] = "%d-DRB"
L["fcg.ubgl.abbrev"] = "NAB"
L["fcg.safe2.abbrev"] = "İND"
L["fcg.dact.abbrev"] = "ÇFT-HRK"
L["fcg.sact.abbrev"] = "TEK-HRK"
L["fcg.bolt.abbrev"] = "SRG"
L["fcg.pump.abbrev"] = "PMP"
L["fcg.lever.abbrev"] = "LVY"
L["fcg.manual.abbrev"] = "MAN"
L["fcg.break.abbrev"] = "KRM"
L["fcg.sngl.abbrev"] = "TEK"
L["fcg.both.abbrev"] = "İKİSİ"

-- 2021-10-10
STL["lowered"] = "fcg.safe2"
STL["double-action"] = "fcg.dact"
STL["single-action"] = "fcg.sact"
STL["bolt-action"] = "fcg.bolt"
STL["pump-action"] = "fcg.pump"
STL["lever-action"] = "fcg.lever"
STL["manual-action"] = "fcg.manual"
STL["break-action"] = "fcg.break"
--STL["single"] = "fcg.sngl"
--STL["both"] = "fcg.both"

-- 2021-11-27
L["ui.hitgroup"] = "Vuruş Bölgesi"
L["ui.shotstokill"] = "Öldürmek İçin Gereken Atış Sayısı"
L["ui.hitgroup.head"] = "Kafa"
L["ui.hitgroup.torso"] = "Gövde" -- göğüs+karın aynı olduğunda
L["ui.hitgroup.chest"] = "Göğüs"
L["ui.hitgroup.stomach"] = "Karın"
L["ui.hitgroup.arms"] = "Kollar"
L["ui.hitgroup.legs"] = "Bacaklar"
L["ui.nonum"] = "İnsanları öldürmek için mermiye ihtiyacın var, şapşal." -- sayı 0 olduğunda

-- 2022-05-23
L["fcg.nade"] = "Bomba"
L["fcg.nade.abbrev"] = "BOMBA"

-- 2022-08-03
L["attslot.magazine"] = "Şarjör" -- Zaten tanımlı, aynı çeviri kullanılıyor.
L["attslot.magazine.default"] = "Standart Şarjör"

-- 2022-08-17
L["autostat.ubgl"] = "Seçilebilir namlu altı silah"
L["autostat.ubgl2"] = "Namlu altı silahı etkinleştirmek için KULLANMA ve ŞARJÖR DEĞİŞTİRME tuşlarınıza birlikte basın"
L["autostat.ammotypeubgl"] = "Namlu altı silah %s kullanır"

-- 2023-09-09
L["autostat.triggerdelay"] = "Tetik Gecikmesi"


--[[]
Herhangi bir rastgele silahın veya eklentinin ek bilgilerini ["desc.class_name"] ifadesini ekleyerek çevirebilirsiniz.
Benzer şekilde, eklenti ve silah adlarını ["name.class_name"] ile çevirebilirsiniz.
Silah adlarını çevirirken, gerçek ad için .true ekleyin, örneğin ["name.arccw_p228.true"]
Örnek:
 L["desc.fcg_auto"] = "falan filan otomatik ateşleme modu"
 L["name.fcg_auto"] = "Daha Havalı Otomatik"
Özel ateşleme modlarını "fcg.FIREMODE_NAME" ile de çevirebilirsiniz.
]]