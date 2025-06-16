--[[--------------------------------------------
               English Translation
--------------------------------------------]]--

-- Translation made by me, vicentefelipechile
Minigames.Language["english"] = {
    -- General (Admin menüleri - İngilizce kalıyor)
    ["tool.desc"] = "Use this tool to create minigames automatically",
    ["tool.left"] = "Create Minigames - Add/Remove players from your minigame",
    ["tool.right"] = "Setup Minigames",
    ["tool.reload"] = "Special option, for example: Pause the minigame",
    ["tool.singleplayer"] = "Warning: You are playing in singleplayer mode, the reload button will not work correctly",

    ["setupmenu.title"] = "Minigame Tool Assistant - Setup",
    ["setupmenu.togglegame"] = "Start / Stop the current minigame",
    ["setupmenu.players"] = "Current players",

    ["reward.title"] = "Rewards",
    ["reward.select"] = "Select a reward",
    ["reward.desc"] = "Rewards are given at the end of the minigame. \nThe winning player will receive the reward according to what was selected and the amount.",
    ["reward.onlyone"] = "The prize is the same %str",
    ["reward.nothing"] = "No reward selected",
    ["reward.disabled"] = "You must have a game ready to add rewards",
    ["reward.add"] = "Add reward",
    ["reward.none"] = "%ply mini oyunu kazandı!", -- TÜRKÇE
    ["reward.given"] = "%ply %str kazandı!", -- TÜRKÇE

    ["playerlist.add"] = "Add player",
    ["playerlist.remove"] = "Remove player",
    ["playerlist.toggle"] = "Toggle player",
    ["playerlist.sendtogame"] = "Send player to minigame",
    ["playerlist.sendtooldpos"] = "Send player to their previous position",
    ["playerlist.sendtospawn"] = "Send player to their spawn",
    ["playerlist.mute"] = "Mute player",
    ["playerlist.unmute"] = "Unmute player",
    ["playerlist.hearowner"] = "Players can hear the owner",
    ["playerlist.muteall"] = "Mute all players",
    ["playerlist.hearself"] = "Use voice without proximity",

    ["playerlist.broadcast"] = "Create an announce to join the minigame",
    ["playerlist.broadcast.alreadywaiting"] = "Currently another minigame owner is looking for players, wait for it to finish before using this",
    ["playerlist.broadcast.join"] = "%ply bir mini oyun düzenliyor, katılmak için sohbete yazın: %str", -- TÜRKÇE
    ["playerlist.broadcast.gameremoved"] = "%ply'nin mini oyunu iptal edildi", -- TÜRKÇE
    ["playerlist.broadcast.gamestarted"] = "%ply'nin mini oyunu başladı, artık katılım kabul edilmiyor", -- TÜRKÇE

    ["minigames.title"] = "Minigames",
    ["minigames.desc"] = "Description:",
    ["minigames.selectone"] = "Select a minigame",
    ["minigames.gameconfig"] = "Game configuration",
    ["minigames.playzoneconfig"] = "Play zone",
    ["minigames.onjoin"] = "%ply oyuna katıldı", -- TÜRKÇE
    ["minigames.onleft"] = "%ply oyundan ayrıldı", -- TÜRKÇE
    ["minigames.onlose"] = "%ply oyunu kaybetti!", -- TÜRKÇE
    ["minigames.gamestopped"] = "Mini oyun iptal edildi, kimse kazanmadı!", -- TÜRKÇE
    ["minigames.removeyourgame"] = "Remove your current game before changing to another",

    ["minigames.player.notingame"] = "Player %ply is not in the game!",
    ["minigames.player.alreadyingame"] = "Player %ply is already in the game!",
    ["minigames.player.cantjoin"] = "%ply oyuna katılamıyor, zaten başka bir oyunda!", -- TÜRKÇE
    ["minigames.player.cantjoin.dead"] = "%ply ölü durumda!", -- TÜRKÇE
    ["minigames.player.cantjoin.you"] = "Bu oyuna katılamazsınız!", -- TÜRKÇE
    ["minigames.player.cantjoin.owner"] = "This player cannot join your game!",

    ["minigames.error.gameisactive"] = "You have to stop your game before deleting it!",
    ["minigames.error.gamedontexists"] = "That minigame does not exist!",
    ["minigames.error.gameneed"] = "You have not created a game yet!",

    ["minigame_ammo"] = "Mermi", -- TÜRKÇE
    ["minigame_health"] = "Can", -- TÜRKÇE
    ["minigame_spawnpoint"] = "Doğma Noktası", -- TÜRKÇE
    ["minigame_weapon"] = "Silah", -- TÜRKÇE
    ["minigame_armor"] = "Zırh", -- TÜRKÇE

    -- Platforms
    ["plataforms.name"] = "Platformlar", -- TÜRKÇE
    ["plataforms.desc"] = "Her turda daha fazla platform kaybolurken düşmemeye çalıştığınız bir platform oyunu.", -- TÜRKÇE
    ["plataforms.tip"] = "Oyunu duraklatmak için R tuşunu kullanın", -- TÜRKÇE
    ["plataforms.sizex"] = "Width",
    ["plataforms.sizex.desc"] = "Amount of platforms that will be created in width in the game",
    ["plataforms.sizey"] = "Length",
    ["plataforms.sizey.desc"] = "Amount of platforms that will be created in length in the game",
    ["plataforms.increment"] = "Increment per round",
    ["plataforms.increment.desc"] = "Amount of platforms that must disappear per round",
    ["plataforms.delay"] = "Delay",
    ["plataforms.delay.desc"] = "Time before the platform disappears completely",
    ["plataforms.min"] = "Start (Minimum)",
    ["plataforms.min.desc"] = "Minimum percentage of platforms with which the game will start",
    ["plataforms.max"] = "End (Maximum)",
    ["plataforms.max.desc"] = "Maximum percentage of platforms that must disappear",
    ["plataforms.timereaction"] = "Reaction time",
    ["plataforms.timereaction.desc"] = "Time that players have to react before the platform disappears",
    ["plataforms.offset"] = "Distance",
    ["plataforms.offset.desc"] = "Separation distance that will be between each platform",
    ["plataforms.height"] = "Height",
    ["plataforms.height.desc"] = "Height at which the game will be created",

    -- Drop Out
    ["dropout.name"] = "Düşen Platformlar", -- TÜRKÇE
    ["dropout.desc"] = "Platformlar sonsuza dek kaybolurken düşmemeye çalıştığınız bir platform oyunu.", -- TÜRKÇE
    ["dropout.tip"] = "Oyunu duraklatmak için R tuşunu kullanın", -- TÜRKÇE
    ["dropout.sizex"] = "Width",
    ["dropout.sizex.desc"] = "Width of the game in platforms",
    ["dropout.sizey"] = "Length",
    ["dropout.sizey.desc"] = "Length of the game in platforms",
    ["dropout.increment"] = "Increment per round",
    ["dropout.increment.desc"] = "Platforms that will disappear per round",
    ["dropout.delay"] = "Time per rounds",
    ["dropout.delay.desc"] = "How much time will pass since a platform disappears until the next one disappears",
    ["dropout.timereaction"] = "Reaction time",
    ["dropout.timereaction.desc"] = "Time that players have to react before the platform disappears",
    ["dropout.offset"] = "Distance",
    ["dropout.offset.desc"] = "Separation distance that will be between each platform",
    ["dropout.height"] = "Height",
    ["dropout.height.desc"] = "Height at which the game will be created",

    -- Red Light Green Light
    ["cigarrillo43.name"] = "Kırmızı Işık Yeşil Işık", -- TÜRKÇE
    ["cigarrillo43.desc"] = "Oyuncular sona ulaşmak için yoldan geçmeli, sona ilk ulaşan kazanır.", -- TÜRKÇE
    ["cigarrillo43.tip"] = "Kırmızı ve yeşil ışık arasında geçiş yapmak için R tuşunu kullanın", -- TÜRKÇE
    ["cigarrillo43.sizex"] = "Width",
    ["cigarrillo43.sizex.desc"] = "Amount of platforms that will be created in width in the game",
    ["cigarrillo43.sizey"] = "Length",
    ["cigarrillo43.sizey.desc"] = "Amount of platforms that will be created in length in the game",
    ["cigarrillo43.safetime"] = "Reaction time",
    ["cigarrillo43.safetime.desc"] = "How much time (In seconds) players have to react and stop when they say Red Light",
    ["cigarrillo43.height"] = "Height",
    ["cigarrillo43.height.desc"] = "Height at which the game will be created",
    ["cigarrillo43.onespawn"] = "One spawn",
    ["cigarrillo43.onespawn.desc"] = "By activating this, players will appear in a single spawn",

    -- Simon says
    ["simonsays.name"] = "Simon Der Ki", -- TÜRKÇE
    ["simonsays.desc"] = "Oyuncular ekranlarda gösterilen renkleri takip etmeli, ayakta kalan son oyuncu kazanır.", -- TÜRKÇE
    ["simonsays.tip"] = "Oyunu duraklatmak için R tuşunu kullanın", -- TÜRKÇE
    ["simonsays.sizex"] = "Width",
    ["simonsays.sizex.desc"] = "Amount of platforms that will be created in width in the game",
    ["simonsays.sizey"] = "Length",
    ["simonsays.sizey.desc"] = "Amount of platforms that will be created in length in the game",
    ["simonsays.offset"] = "Distance",
    ["simonsays.offset.desc"] = "Separation distance that will be between each platform",
    ["simonsays.timereaction"] = "Reaction time",
    ["simonsays.timereaction.desc"] = "Time that players have to react before the platform disappears",
    ["simonsays.substracttimereaction"] = "Faster reaction time",
    ["simonsays.substracttimereaction.desc"] = "How much the reaction time will be reduced per round",
    ["simonsays.delay"] = "Time per round",
    ["simonsays.delay.desc"] = "Time before the platform disappears completely (This time is affected by 'Subtract time')",
    ["simonsays.substracttime"] = "Faster rounds",
    ["simonsays.substracttime.desc"] = "How many seconds will make the game faster per round",
    ["simonsays.height"] = "Height",
    ["simonsays.height.desc"] = "Height at which the game will be created",
    ["simonsays.amountcolors"] = "Amount of colors",
    ["simonsays.amountcolors.desc"] = "Amount of colors that will be used in the game",
    ["simonsays.samecolors"] = "Same colors",
    ["simonsays.samecolors.desc"] = "By activating this, the colors will remain the same for each round",

    -- Russian Roulette
    ["russianroulette.name"] = "Rus Ruleti", -- TÜRKÇE
    ["russianroulette.desc"] = "Şansa dayalı mini oyun, oyuncuların ateş etme veya pas geçme seçeneği var, son kalan kazanır.", -- TÜRKÇE
    ["russianroulette.tip"] = "Sıranız geldiğinde bir silah alacaksınız.", -- TÜRKÇE
    ["russianroulette.decisiontime"] = "Decision time",
    ["russianroulette.decisiontime.desc"] = "Time that players have to decide whether to shoot or skip (Only if the decision time is activated)",
    ["russianroulette.magazinesize"] = "Magazine size",
    ["russianroulette.magazinesize.desc"] = "How many bullets the weapon's magazine will have",
    ["russianroulette.resetonfire"] = "Reset on fire",
    ["russianroulette.resetonfire.desc"] = "When a player fires the weapon, the magazine will change the bullet where the weapon is and the position will be reset",
    ["russianroulette.header.bots"] = "Bots",
    ["russianroulette.bots"] = "Amount of Bots",
    ["russianroulette.bots.desc"] = "How many bots will have the game",
    ["russianroulette.hud.primaryattack"] = "Şansınızı deneyin ve silahı ateşleyin", -- TÜRKÇE
    ["russianroulette.hud.secondaryattack"] = "Risk almayın ve sıranızı pas geçin", -- TÜRKÇE
    ["russianroulette.hud.cantskip"] = "Sıranızı pas geçemezsiniz", -- TÜRKÇE

    -- Box Game
    ["boxgame.name"] = "Kutu Oyunu", -- TÜRKÇE
    ["boxgame.desc"] = "Kutular tarafından ezilmemeye çalıştığınız oyun, ayakta kalan son oyuncu kazanır.", -- TÜRKÇE
    ["boxgame.tip"] = "Kutular sadece kırmızı olduklarında öldürür, dokunduğunuz anda ölürsünüz.", -- TÜRKÇE
    ["boxgame.delaybetweendrops"] = "Time between dropped boxes",
    ["boxgame.delaybetweendrops.desc"] = "How long will it take for the boxes to appear between each round.",
    ["boxgame.dropdelay"] = "Drop time",
    ["boxgame.dropdelay.desc"] = "How long will it take for the boxes to fall.",
    ["boxgame.dropreaction"] = "Reaction time",
    ["boxgame.dropreaction.desc"] = "How much time (In seconds) players have to react to the boxes.",
    ["boxgame.startboxes"] = "Initial boxes",
    ["boxgame.startboxes.desc"] = "Amount of boxes that will fall at the beginning of the game.",
    ["boxgame.maxboxes"] = "Maximum boxes",
    ["boxgame.maxboxes.desc"] = "Maximum amount of boxes that will fall in the game. (It is related to the amount of boxes that will increase per round)",
    ["boxgame.addmoreboxes"] = "Add boxes",
    ["boxgame.addmoreboxes.desc"] = "Amount of boxes that will be added per round.",
    ["boxgame.sizex"] = "Width",
    ["boxgame.sizex.desc"] = "Amount of platforms that will be created in width in the game",
    ["boxgame.sizey"] = "Length",
    ["boxgame.sizey.desc"] = "Amount of platforms that will be created in length in the game",
    ["boxgame.offset"] = "Distance",
    ["boxgame.offset.desc"] = "Separation distance that will be between each platform",
    ["boxgame.height"] = "Height",
    ["boxgame.height.desc"] = "Height at which the game will be created",

    -- Deathmatch
    ["deathmatch.name"] = "Ölüm Maçı", -- TÜRKÇE
    ["deathmatch.desc"] = "Diğer oyuncuları öldürmeye çalıştığınız ölüm maçı, en çok öldüren kazanır.", -- TÜRKÇE
    ["deathmatch.tip"] = "Oyunu duraklatmak için R tuşunu kullanın", -- TÜRKÇE
    ["deathmatch.insufficientspawns"] = "Oyunu başlatmak için en az %s doğma noktasına ihtiyacınız var", -- TÜRKÇE
    ["deathmatch.leaderboard"] = "Skor Tablosu", -- TÜRKÇE
    ["deathmatch.leaderboard.andmore"] = "ve %str kişi daha", -- TÜRKÇE
    ["deathmatch.tall"] = "Tall",
    ["deathmatch.tall.desc"] = "How tall the leaderboard will be",
    ["deathmatch.wide"] = "Wide",
    ["deathmatch.wide.desc"] = "How wide the leaderboard will be",
    ["deathmatch.heightoffset"] = "Height",
    ["deathmatch.heightoffset.desc"] = "Height above the ground that the leaderboard will appear",
    ["deathmatch.angleoffset"] = "Direction",
    ["deathmatch.angleoffset.desc"] = "Which direction the leaderboard will look",
    ["deathmatch.winbytime"] = "Win by time",
    ["deathmatch.winbytime.desc"] = "When active, the player with the most deaths at the end of the time will be the winner.\nWhen disabled, the player who reaches the number of deaths will be the winner.",
    ["deathmatch.time"] = "Time",
    ["deathmatch.time.desc"] = "How long the game will last",
    ["deathmatch.killstowin"] = "Kills to win",
    ["deathmatch.killstowin.desc"] = "Amount of deaths needed to win the game (Only works if \"Win by time\" is disabled)",
    ["deathmatch.falldamage"] = "Fall damage",
    ["deathmatch.falldamage.desc"] = "Players receive fall damage",
    ["deathmatch.respawntime"] = "Respawn time",
    ["deathmatch.respawntime.desc"] = "Time it will take for a player to respawn",
    ["deathmatch.respawnprotection"] = "Respawn protection",
    ["deathmatch.respawnprotection.desc"] = "Time a player will have protection when respawning",
    ["deathmatch.entitysettings"] = "Entities",
    ["deathmatch.spawnentitytype"] = "Entity type",
    ["deathmatch.spawnentitytype.desc"] = "The type of entity you are going to create for the minigame",
    ["deathmatch.spawnentitytypeoffset"] = "Height",
    ["deathmatch.spawnentitytypeoffset.desc"] = "Height above the ground that the entity will appear",
    ["deathmatch.spawnpointrotation"] = "Entity rotation",
    ["deathmatch.spawnpointrotation.desc"] = "Which direction entity will look",
    ["deathmatch.health"] = "Health",
    ["deathmatch.health.desc"] = "Amount of life that players will recover when they collect the health",
    ["deathmatch.healthrespawn"] = "Health (Respawn time)",
    ["deathmatch.healthrespawn.desc"] = "Time it will take for the health to respawn",
    ["deathmatch.armor"] = "Armor",
    ["deathmatch.armor.desc"] = "Amount of armor that players will recover when they collect the armor",
    ["deathmatch.armorrespawn"] = "Armor (Respawn time)",
    ["deathmatch.armorrespawn.desc"] = "Time it will take for the armor to respawn",
    ["deathmatch.ammo"] = "Ammo",
    ["deathmatch.ammo.desc"] = "Amount of ammunition that players will recover when they collect the ammunition",
    ["deathmatch.ammorespawn"] = "Ammo (Respawn time)",
    ["deathmatch.ammorespawn.desc"] = "Time it will take for the ammunition to respawn",
    ["deathmatch.weaponskit"] = "Weapons kit",
    ["deathmatch.weaponskit.desc"] = "The weapons kit that will appear in the game, to add categories and weapons edit your \"configuration.lua\" file"
}