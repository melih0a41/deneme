-- {{script_version_name}} Script Version

if party == nil then party = {} end					-- Don't Touch (allows for reloading config without restarting)

-- ============================
-- YENİ: PARTİ SÜRE AYARLARI
-- ============================
party.MinimumStayTime = 1200                       -- Minimum partide kalma süresi (20 dakika = 1200 saniye)
party.AdminCanBypass = true                        -- Adminler bu süreyi atlayabilir mi?
party.LeaderCanBypass = true                       -- Parti lideri kendi partisinden hemen çıkabilir mi?
party.ShowTimeWarnings = true                      -- Süre uyarılarını göster
party.ShowTimeInHUD = true                         -- HUD'da kalan süreyi göster

-- ============================
-- MEVCUT AYARLAR
-- ============================
party.buttoncolor = Color(100,100,100,200)			-- Invite/join request button color 
party.buttonhovercolor = Color(255,0,0,200)			-- Invite/join request button color when hovered
party.backgroundcolor = Color( 50, 50, 50, 255 )	-- Invite/join request background color  
party.partymenubutton = KEY_F5						-- Key to assign the party menu to (nil  to disable)																
party.fadediconsfadeamount = 50 					-- Recommend under 50 (reduce to make unused icons fadded out more then they are)
party.halos = true         							-- Shows a halo around fellow party members
party.hudverticalpos = 175							-- Up/down position of the hud (175 is a good spot for most agendas) (only first join setting, Does not change for all players when changed as players can set their own hud position)
party.hudhorizontalpos = 10							-- Left/Right position of the hud from the left side(only first join setting, Does not change for all players when changed as players can set their own hud position)
party.partychatcolr = Color(255,0,0,255) 			-- The color of [Party] in party chat									
party.partychatmsgcolr = Color(0,255,255,255)		-- Color of the party message text										
party.partychatnamecolr = Color(0,255,0,255)		-- Color of player name who sent party message							
party.chatcommand = "!parti"						-- Chat command to open party menu
party.maxplayers = 8 								-- Maximum number of players per party, if you dont want to use this set really high
party.joinrequestcooldown = 5 						-- Time between requests to join your party per players								
party.invitecooldown	= 5						-- Time between invites from the party leader per player invited					
party.partychatcommand = "/p"						-- Chat command used to chat with your party		
party.defaultlowend		= false						-- If you would like to use circles at players feet instead of halos set to true (clients can choose this option but this will be the default value)	
party.kickondisconnect = false						-- Kick a player from their party if they disconnect? 
party.DarkrpGamemode = true							-- Is your gamemode derived from darkrp?
party.ForceJobParty	= false							-- If this is set to false and the party.AutoGroupedJobs has teams then the players will recieve invites to those parties when they join the team instead of being placed in that party
party.PartyDamage = false							-- Should party members be able to damage eachother
party.KickBlacklistJobs = false						-- Kick players from their party if they join a job that is blacklisted from joining parties
party.DisplayParty = true							-- Display Party Name above player's heads. Defaults to true
party.Admins = {"rp+","rehber","viprehber","moderator","moderator+","admin","admin+","basadmin","superadmin"}				-- Usergroups that are considered Admins (also checks for "isAdmin"
party.SteamIDAdmins = {"76561198012625684"}			-- SteamID64 of the People you want to have admin access regardless of usergroup (this is AnaxMinos's ID by default)

timer.Simple(0, function() --DO NOT TOUCH! This gives darkrp time to load before trying to add teams
	party.BlacklistJobs = {TEAM_HOBO32, TEAM_UGLYDUCK} -- Jobs that can NOT join parties
end)

-- PARTY GROUPS!
party.AutoGroupedJobs = {}-- DONT TOUCH!
timer.Simple(0, function()	--DO NOT TOUCH! This gives darkrp time to load before trying to add teams 
--VVVVVVV Edit here VVVVVVVVV

	--party.AutoGroupedJobs[1] = {
	--Jobs = {"TEAM_HOBO, TEAM_MAYOR},
	--}																			-- Teams that will be given their own party seperated by groups
	
	--party.AutoGroupedJobs[2] = {Name = "Cops",                                -- Party name will automatically become the first team in each list or you can set it with the name option
	--Jobs = {TEAM_POLICE, TEAM_CHIEF},
	--}			
											
	--party.AutoGroupedJobs[4] = {nil}		-- ADD AS MANY GROUPS AS YOU WANT!
	
end)

-- Language Stuff default is english
party.language = {
	
	--Do not edit this side					-- Edit this side!
	-- Party Chat
	["[Party]"]								= "[Parti] ",		--Sohbet Etiketi	
	--Menu
	["Invited to join a party"] 			= "Bir partiye katılmak için davet edildiniz",
	["Has invited you to their party."] 	= "sizi partisine davet etti.",
	["Accept?"] 							= "Kabul et?",
	["YES"] 								= "EVET",
	["NO"] 									= "HAYIR",
	["Request To Join Your Party"] 			= "Partinize Katılma İsteği",
	["Would like to join your party"] 		= "partinize katılmak istiyor",
	["Party Menu"] 							= "Parti Menüsü",
	["Welcome to the party menu!"] 			= "Parti menüsüne hoş geldiniz!",
	["An easy way for you to"] 				= "Arkadaşlarınızla takım kurmanın",
	["team up with your friends!"] 			= "kolay bir yolu!",
	["Start Party"] 						= "Parti Başlat",
	["WARNING!"] 							= "UYARI!",
	["By starting a new party"] 			= "Yeni bir parti başlatarak",
	["you will be removed from"] 			= "mevcut partinizden",
	["your current party."]	 				= "çıkarılacaksınız.",
	["Start A New Party"] 					= "Yeni Bir Parti Başlat",
	["Party Name"] 							= "Parti Adı", -- Hem Menüde hem de HUD'da kullanılır
	["Join Party"] 							= "Partiye Katıl",
	["Members"] 							= "Üyeler",
	["Request Join"] 						= "Katılma İsteği Gönder",
	["Leave Party"] 						= "Partiden Ayrıl",
	["By leaving your party"] 				= "Partinizden ayrılarak",
	["you will no longer be protected"] 	= "artık eski parti üyelerinizden",
	["from damage from"] 					= "gelecek hasara karşı",
	["your former party members."] 			= "korunmayacaksınız.",
	["Leave Current Party"] 				= "Mevcut Partiden Ayrıl",
	["Manage Party"] 						= "Partiyi Yönet",
	["Kick From Party"] 					= "Partiden At",
	["offline"] 							= "Çevrimdışı",					--HUD'da da kullanılır
	["Invite To Party"] 					= "Partiye Davet Et",
	["Players"] 							= "Oyuncular",
	["Settings"] 							= "Ayarlar",
	["Color of party halo"] 				= "Parti halesinin rengi",
	["Lowend Halo"]							= "Haleleri Devre Dışı Bırak (FPS Düşmanı)",
	["Admin"] 								= "Admin",
	["Disband Party"] 						= "Partiyi Dağıt",
	["Parties"] 							= "Partiler",
	
	--HUD
	-- ["Party Name"] zaten yukarıda çevrildi
	["Alive"] 								= "Hayatta",
	["Dead"] 								= "Ölü",
	["Disable Hud?"]						= "HUD'u Devre Dışı Bırak?",
	["Kick"]								= "At",
	
	-- Messages sent to clients from the server(in chatbox) - GÜNCELLENMIŞ 	 
	["Maximum number of players in this party."]			= "Bu partideki maksimum oyuncu sayısına ulaşıldı.",
	["Please wait"]											= "Lütfen bekleyin",
	["seconds between party requests."]						= "saniye sonra tekrar parti isteği gönderebilirsiniz.",
	["seconds between party invites."]						= "saniye sonra tekrar parti daveti gönderebilirsiniz.",
	["accepted your party request."]						= "parti isteğinizi kabul etti.",
	["declined your party request."]						= "parti isteğinizi reddetti.",
	["accepted your party invite."]							= "parti davetinizi kabul etti.",
	["declined your party invite."]							= "parti davetinizi reddetti.",
	["kicked you from the party."]							= "sizi partiden attı.",
	["disbanded your party."]								= "partinizi dağıttı.",
	["You must be the same team!"]							= "Aynı takımda olmalısınız!",
	["You are not allowed to join this party."]				= "Bu partiye katılmanıza izin verilmiyor.",
	["You are currently in a forced party, change jobs."] 	= "Şu anda zorunlu bir partidesiniz, meslek değiştirin.",
	["You joined a job that is not allowed to be in a party. Kicking you from party"] = "Partiye girmesine izin verilmeyen bir mesleğe katıldınız. Partiden atılıyorsunuz.",
	
	-- YENİ: Süre mesajları
	["Time Left To Leave"] 					= "Ayrılmak için kalan süre",
	["Minutes Remaining"] 						= "dakika kaldı",
	["You can leave now"] 						= "Artık ayrılabilirsiniz",
	["Must wait to leave"] 					= "Ayrılmak için beklemelisiniz"
}

-- DO NOT TOUCH THIS OR YOU WILL BREAK THINGS