--[[--------------------------------------------
            Minigames Configuration
--------------------------------------------]]--

-- Set the main language
Minigames.Config["MainLang"] = "english"

--[[------------------------------------
          Security Configuration
------------------------------------]]--

-- Performance settings
Minigames.Config["MaxEntitiesPerGame"] = 250
Minigames.Config["MaxPlayersPerGame"] = 32
Minigames.Config["EnableRateLimit"] = true
Minigames.Config["MaxGamesPerPlayer"] = 1
Minigames.Config["RequireAlivePlayer"] = true


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

-- Audio settings with validation
local function ValidateAudioPath(path)
    if not path or path == "" then return false end
    if string.find(path, "%.%.") then return false end
    return string.match(path, "%.mp3$") or string.match(path, "%.wav$") or string.match(path, "%.ogg$")
end


-- Owner can set the voice chat in the game
Minigames.Config["OwnerCanSetVoice"] = true



-- Enable or disable the ability for owner to request players to join the game
Minigames.Config["JoinGameCommandEnabled"] = true
Minigames.Config["JoinGameCommand"] = "!join"
Minigames.Config["JoinGameCommandTime"] = 30 -- how many seconds players can join the game

-- Teleport joined players to the game
Minigames.Config["JoinGameCommandTeleport"] = true


--[[------------------------------------
          Bypass Configuration
------------------------------------]]--

-- Use the function instead of usergroups
Minigames.Config["UseFunction"] = false


-- What Usergroup is allowed to use the toolgun
Minigames.Config["AllowUserGroup"] = {
    ["superadmin"] = true,
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

-- Validate weapon classes
local function ValidateWeaponClass(class)
    if not class or class == "" then return false end
    if string.find(class, "[^%w_]") then return false end
    return true
end

local function ValidateWeaponKit(kit)
    if not istable(kit) then return {} end
    
    local validated = {}
    for _, weapon in ipairs(kit) do
        if ValidateWeaponClass(weapon) then
            table.insert(validated, weapon)
        end
    end
    
    return validated
end

Minigames.Config["WeaponsKit"] = {
    ["Half Life 2 Kit"] = {
        "weapon_crowbar", -- First item will be the default weapon when the player spawns
        "weapon_physcannon",
        "arccw_mw2_deagle",
    },
    ["Heavy weapons"] = {
        "arccw_mw2_m240",
        "arccw_bo1_ak47",
        "arccw_mw2_ranger",
    },
    ["Light weapons"] = {
        "arccw_mw2_miniuzi",
        "arccw_mw2_spas12",
        "arccw_mw2_tmp",
    },
    ["Special weapons"] = {
        "arccw_bo2_m82",
        "arccw_bo1_chinalake",
        "arccw_waw_zombie",
    }
}


--[[------------------------------------
         Developer Configuration
------------------------------------]]--

-- Enable this option to prevent players from taking damage while are in a minigame
--[[------------------------------------
          Safety Configuration
------------------------------------]]--

Minigames.Config["DisableDamageInGame"] = true
Minigames.Config["PreventEntitySpam"] = true
Minigames.Config["AutoCleanupOnDisconnect"] = true
Minigames.Config["MaxGameDistance"] = 5000
Minigames.Config["MinPlayerDistance"] = 100
Minigames.Config["GameTimeout"] = 1800