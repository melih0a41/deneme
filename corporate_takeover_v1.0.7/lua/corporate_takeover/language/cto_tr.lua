local lang = {}
 
lang.name = "Türkçe"
lang.short = "tr"

// Made by https://www.gmodstore.com/users/shazam
 
lang.lang = {
    // Genel
    err = "Bir şeyler yanlış gitti. Lütfen tekrar deneyin!",
    no_space = "Yeterli alan yok!",
    max = "Maks.",
    level = "Seviye",
    xp = "XP",
    energy = "Enerji",
    wage = "Maaş",
    age = "Yaş",
    earnings = "Kazanç",
    profit = "Kâr",
 
    cto_missing_admin = "Bunu yapmak için yönetici olmanız gerekiyor!",
    cto_missing_donator = "Bunu yapmak için VIP olmanız gerekiyor!",
 
    key_place_desk = "LMB: Masayı yerleştir",
    key_cancel_desk = "RMB: İptal et",
 
    // İzinler
    not_yours = "Bu senin masa kurucun değil!",
    not_your_desk = "Bu sana ait değil!",
 
    // Şirket
    corp_exists = "Zaten bir şirkete sahipsin. Onunla ilgilenmek istemiyor musun?",
    create_corp = "Şirket Kur",
    create_corp_button = "Şirket Kur (%price)", -- %price
    corp_name = "Şirket adı",
    old_corp = "Bu, eski şirketine ait!",
    placeholder_name = "Şirketim",
 
    corp_created = "'%name' adlı şirketi başarıyla kurdun", -- %name
    no_money_to_create_corp = "Bir şirket kurmak için %money paran yok!", -- %money
    corp_insufficient_level = "Şirketin henüz %level seviyesini geçmedi!", -- %level
    corpname_too_long = "Şirket adın 30 karakteri geçmemeli!",
    corpname_empty = "Şirket adı boş olamaz!",
    corpname_too_short = "Şirket adı en az 5 karakter uzunluğunda olmalı!",
    corpname_default = "Lütfen şirketin için farklı bir isim kullan!",
 
    corp_reached_level = "%name, %level seviyesine ulaştı",
 
    // Masalarla ilgili
    desk_limit = "Bu masa için sınırına ulaştın!",
    desk_no_money = "Şirketinin bu masayı satın almak için yeterli parası yok!",
    deskbuilder_limit = "Masa kurucu sınırına ulaştın!",
    dismantle = "Masayı sök",
    dismantle_vault = "Kasayı sök",
    cant_sell = "Bu masayı satamazsın!",
    desk_sold = "%name adlı masayı %price karşılığında sattın",
    sell_desk = "Masayı sat",
    build_desk = "Masa kur",
 
    // Kahve
    coffee_limit = "Kahve sınırına ulaştın!",
    coffee_no_money = "Şirketinin bu kahveyi almak için yeterli parası yok!",
 
    coffee_black = "Sade kahve",
    coffee_black_sugar = "Şekerli sade kahve",
    coffee_bean = "Çekirdek kahve",
    coffee_bean_sugar = "Şekerli çekirdek kahve",
 
    // Para yatırma/çekme
    withdraw_money = "Para çek",
    money_amount = "Para miktarı",
    deposit_money = "Para yatır",
    withdrew_money = "%amount çektin",
    deposited_money = "%amount yatırdın",
    vault_expanded = "Kasayı %price karşılığında %amount kapasiteye genişlettin",
    no_money = "Şirket kasanda yeterli para yok!",
    no_money_user = "Yeterli paran yok!",
    money_too_low = "Seçtiğin miktar 0 veya daha düşük olamaz!",
 
    // Kasa
    open_vault = "Kasayı aç",
    close_vault = "Kasayı kapat",
    sell_vault = "Kasayı sat",
    build_vault = "Kasa kur",
    upgrade_vault = "Kasayı yükselt",
 
    // Çalışanlar
    select_worker = "Çalışan seç",
    hire_worker = "%s işe al",
    worker_hired = "%name adlı kişiyi yeni çalışan olarak işe aldın!",
    worker_wage_unpayable = "Şirketin %name için maaş ödeyemiyor!",
    too_tired = "%name çalışamayacak kadar yorgun!",
    select_worker_first = "Önce bir çalışan seçmelisin!",
    fire_worker = "Çalışanı kov",
    worker_fired = "%name adlı çalışanı kovdun",
    asleep = "Uyuyor - Uyandırmak için [%key]",
    new_workers_in = "Yeni çalışanlar geliyor",
 
    // Yıkım
    corp_rebellion = "Çalışanların isyan çıkardı ve her şeyi yaktılar!",
    corp_bankrupt = "Çalışanların maaşlarını ödeyemediğin için işi bıraktılar!",
    corp_lost = "Şirket masan yok edildi. Şirketin kayboldu :(",
 
    // Masa isimleri
    corporate_desk = "Şirket Masası",
    basic_worker_desk = "Temel Çalışan Masası",
    intermediate_worker_desk = "Orta Seviye Çalışan Masası",
    advanced_worker_desk = "İleri Seviye Çalışan Masası",
    ultimate_worker_desk = "Nihai Çalışan Masası",
    secretary_desk = "Sekreter Masası",
    research_desk = "Araştırma Masası",
    vault = "Şirket Kasası",
 
    // Araştırmalar
    research_waiting = "Bekleniyor",
    research_description = "Burada araştırmanın açıklaması olacak",
    wakeup_employees = "Çalışanları uyandır",
    start_research = "Araştırmayı başlat",
    select_research_first = "Önce bir araştırma seçeneği seçmelisin!",
    research_open = "Açıklamasını görmek için bir araştırma seçeneği aç!",
    research_finished = "%name araştırmasını tamamladın",
 
    research_in_progress = "Zaten devam eden bir araştırma var!",
    research_no_money = "Bu araştırmayı başlatmak için yeterli paran yok!",
    research_needed = "Önce %name araştırmasını yapmalısın!",
    research_started = "%name araştırmasına başladın",
 
    research_efficiency = "Hızlı Araştırmacı",
    research_price_drop = "Pazarlıkçı",
    xp_worker_1 = "Zeki Çalışan I",
    xp_worker_2 = "Zeki Çalışan II",
    xp_corp_1 = "Zeki Şirket I",
    xp_corp_2 = "Zeki Şirket II",
    research_wage_1 = "Ucuz İşçiler I",
    research_wage_2 = "Ucuz İşçiler II",
    research_wage_3 = "Ucuz İşçiler III",
    automatic_coffee_self = "Kendine Hizmet Eden",
    automatic_coffee = "Hizmetçi",
    wakeup_employees_research = "Uyandır!",
 
    research_efficiency_desc = "Tüm araştırmalar %10 daha hızlı tamamlanır.",
    research_price_drop_desc = "Tüm araştırmaların maliyeti %10 azalır.",
    xp_worker_1_desc = "Çalışanların %10 daha fazla XP kazanır.",
    xp_worker_2_desc = "Çalışanların %10 daha fazla XP kazanır.",
    xp_corp_1_desc = "Şirketin %25 daha fazla XP kazanır.",
    xp_corp_2_desc = "Şirketin %10 daha fazla XP kazanır.",
    research_wage_1_desc = "Çalışanlarının maaşı %10 düşer.",
    research_wage_2_desc = "Çalışanlarının maaşı ek olarak %10 daha düşer.",
    research_wage_3_desc = "Çalışanlarının maaşı ek olarak %10 daha düşer.",
 
    wakeup_employees_desc = "Sekreter masası, enerjisi yeterli olan tüm uyuyan çalışanları uyandırabilir.",
    automatic_coffee_desc = "Sekreter masası, kendisi hariç tüm çalışanların enerjisini yenileyebilir.",
    automatic_coffee_self_desc = "Sekreter masası, kendi enerjisini yenileyebilir.",
}
 
Corporate_Takeover:RegisterLang(lang.name, lang.short, lang.lang)