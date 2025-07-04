VOTING.Theme = {}
--
-- Mayor Voting Theme - Modern & Enhanced
--

-- Ana pencere renkleri - Modern gradient efekti için
VOTING.Theme.WindowColor = Color(15, 20, 30, 245) -- Koyu mavi/siyah ton
VOTING.Theme.WindowGradientTop = Color(25, 35, 50, 250)
VOTING.Theme.WindowGradientBottom = Color(10, 15, 25, 250)

-- Kontrol renkleri - Modern görünüm
VOTING.Theme.ControlColor = Color(45, 55, 75, 200) -- Panel arkaplanı
VOTING.Theme.ControlHoverColor = Color(65, 85, 115, 220) -- Hover efekti
VOTING.Theme.ControlSelectedColor = Color(85, 125, 175, 240) -- Seçili durum

-- Yazı renkleri
VOTING.Theme.TitleTextColor = Color(255, 255, 255, 255) -- Başlık beyaz
VOTING.Theme.PlayerNameColor = Color(220, 230, 255, 255) -- Oyuncu isimleri açık mavi
VOTING.Theme.VoteCountColor = Color(100, 255, 150, 255) -- Oy sayıları yeşil
VOTING.Theme.WinnerTextColor = Color(255, 215, 0, 255) -- Kazanan altın sarısı
VOTING.Theme.TimerTextColor = Color(255, 100, 100, 255) -- Geri sayım kırmızı

-- Chat bildirimleri
VOTING.Theme.NoticePrefixColor = Color(100, 150, 255) -- Mavi prefix
VOTING.Theme.NoticeTextColor = Color(255, 255, 255) -- Beyaz metin

-- Efekt renkleri
VOTING.Theme.GlowColor = Color(100, 150, 255, 100) -- Parıltı efekti
VOTING.Theme.ShadowColor = Color(0, 0, 0, 150) -- Gölge efekti
VOTING.Theme.BorderColor = Color(80, 120, 180, 200) -- Çerçeve rengi

VOTING.Settings = {}
--
-- Mayor Voting Settings - Enhanced
--
VOTING.Settings.VotingTitle = "BASKANLIK SECIMLERI" -- Emoji'siz başlık
VOTING.Settings.ResultsTitle = "YENI BASKAN SECILDI!" -- Kazanan başlığı
VOTING.Settings.NoticePrefix = "[SECIMLER]" -- Emoji'siz prefix

VOTING.Settings.NPCEnabled = true
VOTING.Settings.NPCTitleText = "Baskan Sekreteri" -- Emoji'siz NPC başlığı
VOTING.Settings.NPCModel = "models/player/mossman.mdl"
VOTING.Settings.NPCSequence = "pose_standing_01"

VOTING.Settings.CloseTimeAfterVoteEnds = 12 -- Daha uzun gösterim süresi
VOTING.Settings.ShowVoteTickerUpdates = true
VOTING.Settings.ForceMouseCursor = true -- Mouse'u zorla aç
VOTING.Settings.ShowCloseButton = true

-- Ses efektleri - Daha etkileyici sesler
VOTING.Settings.MenuSounds = true
VOTING.Settings.NewVoteSound = "ambient/alarms/train_horn_distant1.wav" -- Seçim başlangıcı
VOTING.Settings.VoteResultsSound = "vo/npc/male01/fantastic01.wav" -- Kazanan açıklaması
VOTING.Settings.VoteCastSound = "buttons/button24.wav" -- Oy verme sesi
VOTING.Settings.HoverSound = "ui/buttonrollover.wav" -- Hover sesi
VOTING.Settings.CountdownSound = "buttons/button17.wav" -- Geri sayım sesi

-- Animasyon ayarları
VOTING.Settings.AnimationSpeed = 500 -- Animasyon hızı
VOTING.Settings.FadeInTime = 1.5 -- Fade in süresi
VOTING.Settings.PulseEffect = false -- Nabız efektini kapat
VOTING.Settings.GlowEffect = false -- Parıltı efektini kapat

--
-- Mayor Voting Configuration Options
--

VOTING.MayorTeamName = "Başkan"
VOTING.MaximumCandidates = 4
VOTING.MinimumCandidates = 1
VOTING.AboutToBeginTime = 60
VOTING.VoteTime = 45
VOTING.AllowCandidatesToVote = true
VOTING.OnlyEnterUsingNPC = true
VOTING.CandidateCost = 25000
VOTING.DemoteMayorOnDeath = true
VOTING.MinutesUntilNextElection = 1
VOTING.AllowNewElectionOnDeath = true
VOTING.AllowNewElectionWithMayor = false
VOTING.DemoteOtherMayorsOnWin = true

-- Özel mesajlar
VOTING.Messages = {
    VoteStarting = "SECIM BASLIYOR! Oyunuzu kullanin!",
    VoteEnding = "Secim bitiyor! Son sansiniz!",
    NoVotes = "Hic oy kullanilmadi, secim iptal edildi.",
    Winner = "Tebrikler %s! Yeni baskan!",
    VoteCast = "%s icin %s oy kullandi",
    Registered = "%s secime katildi!"
}

--Custom Vote Entry Check
--VOTING.CanEnterVotingCustomFunction = function(ply) if ply:Level() > 5 then return true end end
--VOTING.CustomFunctionFailed = "Belediye başkanlığı seçimine girecek kadar yüksek seviyede değilsiniz!"