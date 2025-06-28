return {
	You = "Sen",
	Yourself = "Kendin",
	Themself = "Kendisi",
	Everyone = "Herkes",

	cant_use_as_console = "Bu komutu ({S Red}) kullanmak için oyuncu olman gerekiyor!",
	no_permission = "'{S Red}' komutunu kullanma iznin yok!",

	cant_target_multi_players = "Bu komutla birden fazla oyuncuyu hedef alamazsın!",
	invalid_id = "Geçersiz ID ({S Red})!",
	cant_target_player = "{S Red} oyuncusunu hedef alamazsın!",
	cant_target_self = "Bu komutla ({S Red}) kendini hedef alamazsın!",
	player_id_not_found = "{S Red} ID'li oyuncu bulunamadı!",
	found_multi_players = "Birden fazla oyuncu bulundu: {T}!",
	cant_find_target = "Hedef alınacak bir oyuncu bulunamadı ({S Red})!",

	invalid = "Geçersiz {S} ({S_2 Red})",
	default_reason = "yok",

	menu_help = "Admin mod menüsünü açar.",

	-- Sohbet Komutları
	pm_to = "-> {T}: {V}",
	pm_from = "{A} ->: {V}",
	pm_help = "Bir oyuncuya özel mesaj (PM) gönderir.",

	to_admins = "{A} adminlere: {V}",
	asay_help = "Adminlere bir mesaj gönderir.",

	mute = "{A}, {T} oyuncusunu {V} süreliğine susturdu. ({V_2})",
	mute_help = "Oyuncu(lar)ın sohbete mesaj göndermesini engeller.",

	unmute = "{A}, {T} oyuncusunun susturmasını kaldırdı.",
	unmute_help = "Oyuncu(lar)ın susturmasını kaldırır.",

	you_muted = "Susturuldun.",

	gag = "{A}, {T} oyuncusunu {V} süreliğine sesli sohbetten engelledi. ({V_2})",
	gag_help = "Oyuncu(lar)ın konuşmasını engeller.",

	ungag = "{A}, {T} oyuncusunun sesli sohbet engelini kaldırdı.",
	ungag_help = "Oyuncu(lar)ın sesli sohbet engelini kaldırır.",

	-- Eğlence Komutları
	slap = "{A}, {T}'i tokatladı.",
	slap_damage = "{A}, {T}'i {V} hasarla tokatladı.",
	slap_help = "Oyuncuları tokatlar.",

	slay = "{A}, {T}'i katletti.",
	slay_help = "Oyuncu(lar)ı katleder.",

	set_hp = "{A}, {T}'nin canını {V} olarak ayarladı.",
	hp_help = "Oyuncu(lar)ın canını ayarlar.",

	set_armor = "{A}, {T}'nin zırhını {V} olarak ayarladı.",
	armor_help = "Oyuncu(lar)ın zırhını ayarlar.",

	ignite = "{A}, {T}'i {V} saniyeliğine ateşe verdi.",
	ignite_help = "Oyuncu(lar)ı ateşe verir.",

	unignite = "{A}, {T}'i söndürdü.",
	unignite_help = "Oyuncu(lar)ı söndürür.",

	god = "{A}, {T} için ölümsüzlük modunu açtı.",
	god_help = "Oyuncu(lar) için ölümsüzlük modunu açar.",

	ungod = "{A}, {T} için ölümsüzlük modunu kapattı.",
	ungod_help = "Oyuncu(lar) için ölümsüzlük modunu kapatır.",

	freeze = "{A}, {T}'i dondurdu.",
	freeze_help = "Oyuncu(lar)ı dondurur.",

	unfreeze = "{A}, {T}'nin donmasını çözdü.",
	unfreeze_help = "Oyuncu(lar)ın donmasını çözer.",

	cloak = "{A}, {T}'i gizledi.",
	cloak_help = "Oyuncu(lar)ı gizler.",

	uncloak = "{A}, {T}'nin gizlenmesini kaldırdı.",
	uncloak_help = "Oyuncu(lar)ın gizlenmesini kaldırır.",

	jail = "{A}, {T}'i {V} süreliğine hapsetti. ({V_2})",
	jail_help = "Oyuncu(lar)ı hapseder.",

	unjail = "{A}, {T}'i hapisten çıkardı.",
	unjail_help = "Oyuncu(lar)ı hapisten çıkarır.",

	strip = "{A}, {T}'nin silahlarını aldı.",
	strip_help = "Oyuncu(lar)ın silahlarını alır.",

	respawn = "{A}, {T}'i yeniden doğdurdu.",
	respawn_help = "Oyuncu(lar)ı yeniden doğdurur.",

	setmodel = "{A}, {T}'nin modelini {V} olarak değiştirdi.",
	setmodel_help = "Oyuncu(lar)ın modelini değiştirir.",

	giveammo = "{A}, {T}'e {V} mermi verdi.",
	giveammo_help = "Oyuncu(lar)a mermi verir.",

	scale = "{A}, {T}'nin model boyutunu {V} olarak ayarladı.",
	scale_help = "Oyuncu(lar)ın boyutunu değiştirir.",

	freezeprops = "{A} tüm propları dondurdu.",
	freezeprops_help = "Haritadaki tüm propları dondurur.",

	-- Işınlanma Komutları
	dead = "Ölüsün!",
	leave_car = "Önce araçtan in!",

	bring = "{A}, {T}'i yanına ışınladı.",
	bring_help = "Bir oyuncuyu yanınıza getirir.",

	goto = "{A}, {T}'nin yanına ışınlandı.",
	goto_help = "Bir oyuncunun yanına gider.",

	no_location = "{T}'i geri döndürecek önceki bir konum yok.",
	returned = "{A}, {T}'i eski konumuna geri döndürdü.",
	return_help = "Bir oyuncuyu olduğu yere geri döndürür.",

	-- Kullanıcı Yönetim Komutları
	setrank = "{A}, {T}'nin rütbesini {V_2} süreliğine {V} olarak ayarladı.",
	setrank_help = "Bir oyuncunun rütbesini ayarlar.",
	setrankid_help = "Bir oyuncunun rütbesini steamid/steamid64 kullanarak ayarlar.",

	addrank = "{A}, {V} adında yeni bir rütbe oluşturdu.",
	addrank_help = "Yeni bir rütbe oluşturur.",

	removerank = "{A}, {V} rütbesini kaldırdı.",
	removerank_help = "Bir rütbeyi kaldırır.",

	super_admin_access = "superadmin her şeye erişebilir!",

	giveaccess = "{A}, {T} rütbesine {V} yetkisini verdi.",
	givepermission_help = "Bir rütbeye yetki verir.",

	takeaccess = "{A}, {T} rütbesinden {V} yetkisini aldı.",
	takepermission_help = "Bir rütbeden yetki alır.",

	renamerank = "{A}, {T} rütbesinin adını {V} olarak değiştirdi.",
	renamerank_help = "Bir rütbenin adını değiştirir.",

	changeinherit = "{A}, {T} rütbesinin kalıtım aldığı rütbeyi {V} olarak değiştirdi.",
	changeinherit_help = "Bir rütbenin kalıtım aldığı rütbeyi değiştirir.",

	rank_immunity = "{A}, {T} rütbesinin dokunulmazlığını {V} olarak değiştirdi.",
	changerankimmunity_help = "Rütbe dokunulmazlığını değiştirir.",

	rank_ban_limit = "{A}, {T} rütbesinin ban limitini {V} olarak değiştirdi.",
	changerankbanlimit_help = "Rütbe ban limitini değiştirir.",

	changeranklimit = "{A}, {T} rütbesinin {V} limitini {V_2} olarak değiştirdi.",
	changeranklimit_help = "Rütbe limitlerini değiştirir.",

	-- Yardımcı Komutlar
	map_change = "{A} 10 saniye içinde haritayı {V} olarak değiştiriyor.",
	map_change2 = "{A} 10 saniye içinde haritayı {V}, oyun modunu {V_2} olarak değiştiriyor.",
	map_help = "Mevcut haritayı ve oyun modunu değiştirir.",

	map_restart = "{A} 10 saniye içinde haritayı yeniden başlatıyor.",
	map_restart_help = "Mevcut haritayı yeniden başlatır.",

	mapreset = "{A} haritayı sıfırladı.",
	mapreset_help = "Haritayı sıfırlar.",

	kick = "{A}, {T}'i attı. Sebep: {V}.",
	kick_help = "Bir oyuncuyu atar.",

	ban = "{A}, {T}'i {V} süreliğine yasakladı ({V_2}).",
	ban_help = "Bir oyuncuyu yasaklar.",

	banid = "{A}, ${T} steamid'li oyuncuyu {V} süreliğine yasakladı ({V_2}).",
	banid_help = "Bir oyuncuyu steamid'sini kullanarak yasaklar.",

	-- admin adı olmadığında ban mesajı
	ban_message = [[


		Yasaklayan: {S}

		Sebep: {S_2}

		Yasağınız şu zaman sonra kaldırılacak: {S_3}]],

	-- admin adı olduğunda ban mesajı
	ban_message_2 = [[


		Yasaklayan: {S} ({S_2})

		Sebep: {S_3}

		Yasağınız şu zaman sonra kaldırılacak: {S_4}]],

	unban = "{A}, {T}'nin yasağını kaldırdı.",
	unban_help = "Bir oyuncunun yasağını steamid'sini kullanarak kaldırır.",

	noclip = "{A}, {T} için noclip'i açtı/kapattı.",
	noclip_help = "Oyuncu(lar) için noclip'i açar/kapatır.",

	cleardecals = "{A} tüm oyuncular için ragdoll'ları ve çıkartmaları temizledi.",
	cleardecals_help = "Tüm oyuncular için ragdoll'ları ve çıkartmaları temizler.",

	stopsound = "{A} tüm sesleri durdurdu.",
	stopsound_help = "Tüm oyuncular için bütün sesleri durdurur.",

	not_in_vehicle = "Bir araçta değilsin!",
	not_in_vehicle2 = "{S Blue} bir araçta değil!",
	exit_vehicle = "{A}, {T}'i araçtan zorla indirdi.",
	exit_vehicle_help = "Bir oyuncuyu araçtan zorla indirir.",

	time_your = "Toplam süren: {V}.",
	time_player = "{T} oyuncusunun toplam süresi: {V}.",
	time_help = "Bir oyuncunun toplam süresini kontrol eder.",

	admin_help = "Admin modunu aktif eder.",
	unadmin_help = "Admin modunu deaktif eder.",

	buddha = "{A}, {T} için buddha modunu açtı.",
	buddha_help = "Oyuncu(lar)ın canı 1 olduğunda ölümsüz olmasını sağlar.",

	unbuddha = "{A}, {T} için buddha modunu kapattı.",
	unbuddha_help = "Oyuncu(lar) için buddha modunu kapatır.",

	give = "{A}, {T}'e {V} verdi.",
	give_help = "Oyuncu(lar)a silah/eşya verir.",

	-- DarkRP Komutları
	arrest = "{A}, {T}'i süresiz olarak tutukladı.",
	arrest2 = "{A}, {T}'i {V} saniyeliğine tutukladı.",
	arrest_help = "Oyuncu(lar)ı tutuklar.",

	unarrest = "{A}, {T}'i serbest bıraktı.",
	unarrest_help = "Oyuncu(lar)ı serbest bırakır.",

	setmoney = "{A}, {T}'nin parasını {V} olarak ayarladı.",
	setmoney_help = "Bir oyuncunun parasını ayarlar.",

	addmoney = "{A}, {T}'e {V} para ekledi.",
	addmoney_help = "Bir oyuncuya para ekler.",

	door_invalid = "Satmak için geçersiz kapı.",
	door_no_owner = "Bu kapının sahibi yok.",

	selldoor = "{A}, {T} için bir kapı/araç sattı.",
	selldoor_help = "Baktığınız kapının/aracın sahipliğini kaldırır.",

	sellall = "{A}, {T} için sahip olunan tüm kapıları/araçları sattı.",
	sellall_help = "Bir oyuncunun sahip olduğu tüm kapıları/araçları satar.",

	s_jail_pos = "{A} yeni bir hapishane konumu belirledi.",
	setjailpos_help = "Tüm hapishane konumlarını sıfırlar ve bulunduğunuz yere yeni bir tane ayarlar.",

	a_jail_pos = "{A} yeni bir hapishane konumu ekledi.",
	addjailpos_help = "Bulunduğunuz konuma bir hapishane konumu ekler.",

	setjob = "{A}, {T}'nin mesleğini {V} olarak ayarladı.",
	setjob_help = "Bir oyuncunun mesleğini değiştirir.",

	shipment = "{A}, {V} sevkiyatı spawnladı.",
	shipment_help = "Bir sevkiyat spawnlar.",

	forcename = "{A}, {T}'nin adını {V} olarak değiştirdi.",
	forcename_taken = "Bu isim zaten alınmış. ({V})",
	forcename_help = "Bir oyuncunun adını zorla değiştirir.",

	report_claimed = "{A}, {T} tarafından gönderilen bir raporu üstlendi.",
	report_closed = "{A}, {T} tarafından gönderilen bir raporu kapattı.",
	report_aclosed = "Raporunuz kapatıldı. (Süre doldu)",

	rank_expired = "{T}'nin {V} rütbesinin süresi doldu.",

	-- TTT Komutları
	setslays = "{A}, {T} için otomatik öldürme sayısını {V} olarak ayarladı.",
	setslays_help = "Bir oyuncunun kaç tur otomatik olarak öldürüleceğini ayarlar.",

	setslays_slayed = "{T} otomatik olarak öldürüldü, kalan öldürme hakkı: {V}.",

	removeslays = "{A}, {T} için otomatik öldürmeleri kaldırdı.",
	removeslays_help = "Bir oyuncu için otomatik öldürmeleri kaldırır."
}