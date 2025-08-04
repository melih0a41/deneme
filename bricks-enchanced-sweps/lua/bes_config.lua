BES.CONFIG.Language = "english"

BES.CONFIG.DoorRam = {}
BES.CONFIG.DoorRam.DoorHealth = 100
BES.CONFIG.DoorRam.DamagePerHit = 15
BES.CONFIG.DoorRam.DoorRegenTime = 60
BES.CONFIG.DoorRam.InstantOpen = false
BES.CONFIG.DoorRam.InstantAdmin = false

BES.CONFIG.Keys = {}
BES.CONFIG.Keys.ServerLogo = "https://i.imgur.com/nBH1MMS.jpeg" -- The logo used on the keys (false to disable), requires an direct image URL e.g. https://i.imgur.com/fx49qdF.jpg

BES.CONFIG.Lockpick = {}
BES.CONFIG.Lockpick.Time = 10
BES.CONFIG.Lockpick.ClickTime = 2.5 -- How long the player has to click when the lock gets stuck
BES.CONFIG.Lockpick.ClicksReq = 4 -- How many clicks are needed per lockpick
BES.CONFIG.Lockpick.ShowHint = false -- Whether a hint should popup when they player needs to click

BES.CONFIG.Medkit = {}
BES.CONFIG.Medkit.PlyHeal = 25
BES.CONFIG.Medkit.SelfHeal = 25
BES.CONFIG.Medkit.HealTime = 4
BES.CONFIG.Medkit.SelfHealTime = 4
BES.CONFIG.Medkit.SlowdownSelfHeal = true

BES.CONFIG.HandCuffs = {}
BES.CONFIG.HandCuffs.CuffTime = 1
BES.CONFIG.HandCuffs.ShowHint = true
BES.CONFIG.HandCuffs.Blacklist = { "dsr_keys", "inventory", }
BES.CONFIG.HandCuffs.JobBlacklist = { "yetkili", "baskan", "polis", "baskomiser", "amir", "swat", "swatsihhiye", "swatkeskinnisanci", "swatagirzirh", "swatkomutani", "baskankorumasi", "hakim",} -- Jobs that cannot be handcuffed (add the job command to the list)

BES.CONFIG.Taser = {}
BES.CONFIG.Taser.JobBlacklist = { "yetkili", "cp" } -- Jobs that cannot be tasered (add the job command to the list)

BES.CONFIG.Themes = {}
BES.CONFIG.Themes.Primary = Color( 30, 33, 36 )
BES.CONFIG.Themes.Secondary = Color( 46, 49, 54 )
BES.CONFIG.Themes.Tertiary = Color( 54, 57, 62 )
BES.CONFIG.Themes.Red = Color( 240, 71, 71 )
BES.CONFIG.Themes.Hover = Color( 255, 255, 255, 2 )
BES.CONFIG.Themes.Text = Color( 220, 221, 222 )