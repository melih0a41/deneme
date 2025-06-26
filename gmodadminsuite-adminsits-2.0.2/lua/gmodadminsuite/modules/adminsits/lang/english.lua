return {
	Name = "English",
	Flag = "flags16/gb.png",
	Phrases = function() return {

        module_name = "Admin Oturumları",

        NotAllowedInSit = "Oturumdayken bunu yapamazsın!",
        PlayerMayBeStuck = "PLY_NAME teleport edildi, ama sıkışmış olabilir!",
        DisconnectedPlayerReconnected = "PLY_NAME (PLY_STEAMID) oturum SIT_ID'den yeniden bağlandı!",
        NoSitPosition = "Bu harita için oturma pozisyonu ayarlanmadı! Oturma pozisyonu ayarlamak için !sitpos yazın.",

        AdminSit = "Admin Oturumu",
        Unknown = "Bilinmiyor",
        Dismiss = "Kapat",
        Error = "Hata",
        Yes = "Evet",
        No = "Hayır",

        LeaveSit = "Oturumdan Çık",

        Hours = "%s saat",
        Never = "Hiçbir Zaman",
        VACBans = "VAC Yasakları: %s",
        LastBan = "Son ban'dan bu yana geçen gün: %s",
        GameBans = "Oyun Yasakları: %s",
        TradeBanned = "Takas Yasağı: %s",
        MemberSince = "Üyelik Tarihi: %s",
        CheckPocketNone = "Cebinde hiç eşya yok",
        NoSteamAPIKey = "Sunucu sahibi Steam API anahtarını ayarlamadığı için bu özellik kullanılamıyor :(\nLütfen sunucu sahibinden/geliştiricisinden GmodAdminSuite konfig eklentisinde gmodadminsuite_steam_apikey.lua dosyasını yapılandırmasını isteyin.",
        CheckSteamFamilySharing_Error = "Steam sunucularından veri alınırken bir hata oluştu. Sunucular şu anda kullanılamıyor olabilir.\nLütfen sunucu sahibinin GmodAdminSuite konfig eklentisindeki gmodadminsuite_steam_apikey.lua dosyasına doğru Steam API anahtarını girdiğinden emin olun.",
        CheckSteamFamilySharingYes = "%s, %s ile Garry's Mod için Steam Aile Paylaşımı kullanıyor.",
        CheckSteamFamilySharingNo = "%s kimseyle Steam Aile Paylaşımı üzerinden Garry's Mod paylaşmıyor.",

        SteamFriendStatusYes = "%s, %s ile Steam'de arkadaş!",
        SteamFriendStatusNo = "%s, %s ile Steam'de arkadaş değil!",
        PlayerOfflineError = "Bu işlemi yapmak için hedef oyuncu sunucuda olmalı.",

        SteamProfile_Failure = "Steam profili alınamadı! (%s)\nSteam durumunu veya ağ bağlantınızı kontrol edin.",
        SteamProfile_CheckGmodPlaytime_Failed = "Steam profilinden Gmod oynama süresi alınamadı.\nKullanıcı topluluk profilini yapılandırmamış olabilir veya gizlilik ayarları bu veriyi gizleyecek şekilde ayarlanmıştır.",
        SteamProfile_CheckSteamAge_Failed = "Steam profilinden hesap yaşı alınamadı.\nKullanıcı topluluk profilini yapılandırmamış olabilir veya gizlilik ayarları bu veriyi gizleyecek şekilde ayarlanmıştır.",

        NoWeapons = "Silah Yok",
        Screenshot = "Ekran Görüntüsü",
        ScreenshotTip = "%s [%s] kullanıcısından %s tarihinde alınan ekran görüntüsü",
        ScreenshotTip2 = "Ekran görüntüsü siyah ise, bir hile ekran görüntüsünün alınmasını engelliyor olabilir.",

        PlayerLine_Active = "Aktif",
        PlayerLine_Inactive = "AFK / Sekme Dışı",
        PlayerLine_Unreachable = "Zaman Aşıyor",

        RemoveFromSit      = "Oturumdan Çıkart",
        TeleportToSit      = "Oturumu Teleport Et",
        MuteMicrophone     = "Mikrofonu Kapat",
        UnmuteMicrophone   = "Mikrofonu Aç",
        DisableTextChat    = "Yazılı Sohbeti Kapat",
        EnableTextChat     = "Yazılı Sohbeti Aç",
        SteamProfile       = "Steam Profili",
        CopySteamID        = "SteamID'i Kopyala",
        CopySteamID64      = "SteamID64'ü Kopyala",
        CopyIPAddress      = "IP Adresini Kopyala",
        TakeScreenshot     = "Ekran Görüntüsü Al",
        CheckWeapons       = "Silahları Kontrol Et",
        CheckSteamFriends  = "Steam Arkadaşlarını Kontrol Et",
        CheckSteamGroups   = "Steam Gruplarını Kontrol Et",
        CheckSteamAge      = "Steam Hesap Yaşını Kontrol Et",
        CheckWallet        = "Cüzdanı Kontrol Et",
        CheckPocket        = "Cebi Kontrol Et",
        CheckValveBans     = "Valve Yasaklarını Kontrol Et",
        CheckGmodPlaytime  = "GMod Oynama Süresini Kontrol Et",
        CheckSteamFamShare = "Steam Aile Paylaşımını Kontrol Et",
        FlashWindow        = "Windows görev çubuğunu yanıp sönmeye zorl",

        NoPermission = "Oturum sistemini kullanmak için izniniz yok!",
        NoPermission_TargetStaff = "PLY_NAME'i oturumdan çıkarmak için izniniz yok!",
        ChatCommand_MultipleMatches = "ARG_COUNT çakışan oyuncu adı bulundu: MATCH_FAILS - lütfen daha spesifik olun",
        ChatCommand_MatchFailed = "İsim içinde MATCH_FAILS geçen MATCH_COUNT oyuncu bulunamadı",
        ChatCommand_MatchFailed_Plural = "İsim içinde MATCH_FAILS geçen MATCH_COUNT oyuncu bulunamadı",
        ChatCommand_AlreadyInSit = "PLY_NAME zaten bir oturumda! Aktif oturumları görmek için !sits yazın.",
        ChatCommand_Clash = "Bu oyuncular farklı durumlarda oldukları için ne yapmak istediğinizi anlayamadık - lütfen bir oyuncu ile aynı anda !sit komutunu deneyin.",
        ChatCommand_Clash_AddToSit = "PLY_NAME bir oturumda değil (MATCH_FAIL)",
        ChatCommand_Clash_RemoveFromSit = "PLY_NAME bir oturumda (MATCH_FAIL)",
        ChatCommand_NoResitArgs = "Bilinen önceki bir oturumunuz yok veya önceki oturumunuz geçersiz hale geldi (tüm oyuncular bağlantıyı kesti)",
        ChatCommand_InviteSent = "PLY_NAME'e oturuma katılma daveti gönderildi!",

        SitInviteReceivedTitle = "Admin Oturum Daveti",
        SitInviteReceived = "%s tarafından bir oturuma davet edildiniz, katılmak için tıklayın!",
        JoinSit = "KATIL",

        AddPlayer = "Oyuncu Ekle",
        AddPlayerEllipsis = "Oyuncu ekle...",
        EndSit = "Oturumu Bitir",
        EndSitAreYouSure = "Bu oturumu sonlandırmak istediğinizden emin misiniz?",
        PlayerAlreadyInSit = "Bu oyuncu zaten bir oturumda; hangi oturumda olduğunu görmek için !sits yazın.",
        PlayerInvitedToSit = "Oyuncu oturuma davet edildi!",

        ScreenshotFailedText = "Ekran görüntüsü sunucuya yüklenemedi!\nYa ekran görüntüsü sunucusu çalışmıyor ya da oyuncu/sunucunun ağı ekran görüntüsü sunucusuna bağlantıları engelliyor.\nHileciler, ekran görüntüsü sunucusunu kendi ağlarında engelleyerek veya Lua ile bu özelliği bozan kodlar çalıştırarak bunu yapabilir.",
        ScreenshotFailed = "Ekran Görüntüsü Başarısız",

        AllStaffDisconnected = "Oturumdaki tüm yetkililer bağlantıyı kesti; oturum sonlandırıldı.",
        AllPlayersDisconnected = "Oturumdaki tüm oyuncular bağlantıyı kesti, tekrar katılırlarsa geri eklenecekler.",
        AllPlayersDisconnected2 = "Oturumu sonlandırırsanız, oyuncu(lar) tekrar katıldığında bilgilendirileceksiniz.",

        TakingScreenshot = "Ekran görüntüsü alınıyor...",
        Staff = "Yetkili",

        ShowDisconnectReason = "PLY_NAME oturum sırasında sunucudan ayrıldı (DISCONNECT_REASON)",
        ShowDisconnectReason_NoReason = "PLY_NAME oturum sırasında sunucudan ayrıldı",

        ReloadTip = "R tuşuna basarak adminsit başlat",
        ReloadTipRemove = "R tuşuna basarak adminsiti kapat",

        SitID = "Oturum #%d",
        JoinSitLine = "Oturuma Katıl",

        Refresh = "Yenile",

        SitPosFailed = "Oturma pozisyonu ayarlanamadı! Dünyada olduğunuzdan ve sıkışmadığınızdan emin olun.",
        SitPosSuccess = "Oturma pozisyonu başarıyla ayarlandı!",

        NoActiveSits = "Aktif oturum yok",

        --## Admin Prison ##--

        AdminPrison = "Admin Hapishanesi",
        AdminPrison_ChatCommand_NoMatches = "Bu ada, SteamID veya SteamID64'e sahip bir oyuncu bulunamadı!",
        AdminPrison_ChatCommand_OverQualified = "ARG_COUNT çakışan oyuncu adı bulundu: MATCH_FAILS - lütfen daha spesifik olun",
        AdminPrison_Prisoner = "Mahkum",
        AdminPrison_ImprisonmentTime = "Hapis Süresi",
        AdminPrison_Reason = "Sebep",
        AdminPrison_Imprison = "Hapse At",
        AdminPrison_PlayerDisconnected = "Oyuncu hapse atmadan önce bağlantısını kesti :(",
        AdminPrison_ClickToFocus = "Odaklanmak için tıkla",
        AdminPrison_NoPermission = "Bunu kullanmak için izniniz yok!",
        AdminPrison_SentToPrison_Success = "PLY_NAME, RELEASE_TIME süresiyle hapse atıldı",
        AdminPrison_ReleasedFromPrison = "Hapsedildiğiniz yerden serbest bırakıldınız!",

    } end
}
