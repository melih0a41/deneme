--[[--------------------------------------------
            Minigames Configuration
--------------------------------------------]]--

-- Set the main language
Minigames.Config["MainLang"] = "english"


-- Remove the player from the game when he joins to any game
-- he would recover his weapons after the game ends or after spawn
-- for owner, he will strip his weapons when the game begins
Minigames.Config["StripWeaponsOnGame"] = true


-- When the game begins, the player will be teleported to the game
Minigames.Config["TeleportToGame"] = true


-- Force disable the noclip when the game begins (even if the player is an admin)
Minigames.Config["ForceDisableNoclip"] = true


-- Enable this to have a blur effect in VGUI menus
-- Disabling this will help to improve performance
Minigames.Config["BlurVGUI"] = true


-- Shortcut to toggle the state of current game
-- https://wiki.facepunch.com/gmod/Enums/KEY
-- Note: You can't use the RELOAD key, that key is reserved for
-- toolgun.
Minigames.Config["ToggleGameShortcut"] = KEY_NONE


-- Owner can set up voice chat during the minigame
Minigames.Config["OwnerCanSetVoice"] = true

-- Enable or disable the ability for owner to prompt players to join the game
Minigames.Config["JoinGameCommandEnabled"] = true

-- YOU ALWAYS NEED TO PUT "{id}" IN THIS STRING
Minigames.Config["JoinGameCommand"] = "!join {id}"
Minigames.Config["JoinGameCommandDelay"] = 30

Minigames.Config["LeaveGameCommand"] = "!leave"

-- Teleport joined players to the game
Minigames.Config["TeleportOnJoin"] = true


--[[------------------------------------
        Permissions Configuration
------------------------------------]]--


-- If you want to everybody to use the toolgun, set this to true
-- but if they don't have enough permissions, they cannot force to add players to the game
-- permission will be checked in the "AllowUserGroup" or "AllowUserFunction"
Minigames.Config["EverybodyCanUse"] = true

-- Set this to false if you want to restrict the toolgun usage to only certain usergroups
-- "AllowUserGroup" or "AllowUserFunction" will be used as fallback
Minigames.Config["EverybodyCanReward"] = false


-- Use the function instead of usergroups
Minigames.Config["UseFunction"] = false


-- What Usergroup is allowed to use the toolgun
Minigames.Config["AllowUserGroup"] = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["owner"] = true,
    ["eventmaker"] = true,
}

Minigames.Config["AllowUserFunction"] = function(ply)
    return ply:IsAdmin()
end



--[[------------------------------------
           Sound Configuration
------------------------------------]]--
-- relative to "sound/..."

Minigames.Config["PlayMusic"] = true
Minigames.Config["PlayMusicVolume"] = 1

Minigames.Config["BackgroundMusic"] = "minigames/beethoven_virus.wav"
Minigames.Config["BackgroundMusicFast"] = "minigames/beethoven_virus_fast.wav"
Minigames.Config["PlayersToFastMusic"] = 2


Minigames.Config["PlaySounds"] = true

Minigames.Config["OnBeginGameSound"] = "minigames/onbegingame.mp3"
Minigames.Config["OnStopGameSound"] = "minigames/onwingame.mp3"

Minigames.Config["GreenLight"] = "minigames/en/green_light.mp3"
Minigames.Config["RedLight"] = "minigames/en/red_light.mp3"


Minigames.Config["BotComment"] = {
    ["Positive"] = {
        "vo/npc/male01/ok01.wav",
        "vo/npc/male01/yeah02.wav",
        "vo/npc/male01/squad_affirm04.wav",
    },

    ["Negative"] = {
        "vo/npc/male01/no02.wav",
        "vo/npc/male01/sorry01.wav",
        "vo/npc/male01/answer37.wav",
        "vo/npc/male01/answer39.wav",
    },

    ["Comments"] = {
        "vo/npc/male01/finally.wav",
        "vo/npc/male01/whoops01.wav",
        "vo/npc/male01/uhoh.wav",
        "vo/npc/male01/squad_affirm06.wav",
    }
}



--[[------------------------------------
        Global Bot Configuration
------------------------------------]]--

Minigames.Config["BotsCanTalk"] = true

Minigames.Config["BotTalkVolume"] = 75



--[[------------------------------------
         Minigames Configuration
------------------------------------]]--

Minigames.Config["WeaponsKit"] = {
    ["Half Life 2 Kit"] = {
        "weapon_crowbar", -- First item will be the default weapon when the player spawns
        "weapon_physcannon",
        "weapon_pistol",
    },
    ["Heavy weapons"] = {
        "weapon_rpg",
        "weapon_ar2",
        "weapon_crossbow",
    },
    ["Light weapons"] = {
        "weapon_smg1",
        "weapon_shotgun",
        "weapon_357",
    },
    ["Special weapons"] = {
        "weapon_frag",
        "weapon_slam",
        "weapon_stunstick",
    }
}


--[[------------------------------------
         Developer Configuration
------------------------------------]]--

-- Enable this option to prevent players from taking damage while are in a minigame
Minigames.Config["DisableDamageInGame"] = true