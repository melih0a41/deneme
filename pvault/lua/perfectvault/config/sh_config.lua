-----------------------
--      IMPORTANT     -
-----------------------
-- With this new version, most of the entity based configuration is done in-game with the toolgun. You create and configure all the vaults and the Banker in-game.
-- This allows for you to easily have several of the same vault with different configurations, making the addon easier to use in the process.


/* ============
 General Config
=============*/

-- Chat prefix
perfectVault.Config.PrefixColor = Color(155, 0, 0)
perfectVault.Config.Prefix = "[pVault]"

-- Font used throughout the addon
perfectVault.Config.Font = "Calibri"


--- The usergroups/SteamIDs that get access to the in-game entity maker
perfectVault.Config.AccessGroups = {}
perfectVault.Config.AccessGroups["superadmin"] = true

/* =============
 Moneybag Config
==============*/

-- Button used to throw the bag (See: http://wiki.garrysmod.com/page/Enums/BUTTON_CODE for a list of button codes)
perfectVault.Config.ButtonToThrowBag = 17 -- 17 = G
-- Along with the code above, please also state the letter so that it can be used in user interfaces
perfectVault.Config.ButtonToThrowBagString = "G"

-- How many bags can a user hold on their back (Regardless of this amount, it will only actually show 1 bag visually)
perfectVault.Config.MaxBagCarry = 3

-- If you wish to alter the walk and run speed of someone holding moneybags, alter these values here (Set it to false to disable it)
perfectVault.Config.MoneybagWalkSpeed = 120
perfectVault.Config.MoneybagRunSpeed = 200

-- Should the player drop all the bags they are carrying when they die?
perfectVault.Config.DropBagsOnDeath = true



/* =======
 UI Config
========*/
-- You can increase or decrease how hard the derma unlock system is. By lowering these values, it will make the bar smaller, making it harder to hit. The numbers are 0% of the height of the black bar. You can set a max and min % the bar can be.
perfectVault.Config.DermaLevelMin = 0.05
perfectVault.Config.DermaLevelMax = 0.2

-- This is the speed of which the white bar moves. The higher this number, the faster it is
perfectVault.Config.DermaBarSpeed = 1.5

-- When you unlock a pin, should it play a sound?
perfectVault.Config.DermaSounds = true
-- If the above is true, what sound should it play?
perfectVault.Config.DermaSoundsDir = "plats/hall_elev_door.wav"

-- The alarm sound
perfectVault.Config.AlarmSound = "ambient/alarms/alarm1.wav"


/* =========
 Mask Config
==========*/
-- DEVELOPER NOTICE
-- I have a class that allows you to dsiplay "Masked person" as the user's name when they are wearing the mask.
-- The class is ply:MaskedName() and it is both client and server side. If they are not wearing a mask, it will return their normal name.
-- Open a ticket if you need any help with this.
-- END OF DEVELOPER NOTICE

-- Button used to put on the mask (See: http://wiki.garrysmod.com/page/Enums/BUTTON_CODE for a list of button codes)
perfectVault.Config.ButtonToMaskOn = 18 -- 18 = H
-- Along with the code above, please also state the letter so that it can be used in user interfaces
perfectVault.Config.ButtonToMaskOnString = "H"

-- Button used to drop the mask (See: http://wiki.garrysmod.com/page/Enums/BUTTON_CODE for a list of button codes)
perfectVault.Config.ButtonToMaskDrop = 20 -- 18 = J
-- Along with the code above, please also state the letter so that it can be used in user interfaces
perfectVault.Config.ButtonToMaskDropString = "J"

-- Should the user lose their mask on death?
perfectVault.Config.LoseMaskOnDeath = true

-- Should the mask be the halloween pumpkin hat?
perfectVault.Config.HalloweenModels = false



/* ========
 Job Config
=========*/

-- If this option is true, then anyone who is not government can rob the bank (Saves you adding every job to the criminal table.)
perfectVault.Config.AllowAnyoneToRob = false

hook.Add("loadCustomDarkRPItems", "pvault_load_jobs", function() -- Ignore this line, this just sets up the jobs so they load at the correct time.
    -- If you have your police jobs in the DarkRP government table (that thing at the bottom of the jobs.lua file) then they will be considered police without you needing to put the team in here. This is for the extra jobs.
    perfectVault.Config.Government = {}
    perfectVault.Config.Government[TEAM_POLIS] = true
	perfectVault.Config.Government[TEAM_BASKOMISER] = true
	perfectVault.Config.Government[TEAM_AMIR] = true
	perfectVault.Config.Government[TEAM_BASKAN] = true
	perfectVault.Config.Government[TEAM_POH] = true
	perfectVault.Config.Government[TEAM_POHSIHHIYE] = true
	perfectVault.Config.Government[TEAM_POHKESKIN] = true
	perfectVault.Config.Government[TEAM_POHKOMUTANI] = true
	perfectVault.Config.Government[TEAM_POHAGIRZIRH] = true
    
    -- List here all the jobs that can rob the bank
    perfectVault.Config.Criminals = {}
    perfectVault.Config.Criminals[TEAM_KAPKACCI] = true
    perfectVault.Config.Criminals[TEAM_HIRSIZ] = true 
	perfectVault.Config.Criminals[TEAM_ZMLAB2_COOK] = true 
	perfectVault.Config.Criminals[TEAM_INSANKACIRICISI] = true 
	perfectVault.Config.Criminals[TEAM_ZGO2_AMATEUR] = true 
	perfectVault.Config.Criminals[TEAM_MASON] = true 
	perfectVault.Config.Criminals[TEAM_GROVE] = true 
	perfectVault.Config.Criminals[TEAM_GROVELIDERI] = true 
	perfectVault.Config.Criminals[TEAM_BALLAS] = true 
	perfectVault.Config.Criminals[TEAM_BALLASLIDERI] = true 
	perfectVault.Config.Criminals[TEAM_GECEKULUBU] = true 
	perfectVault.Config.Criminals[TEAM_GECEKULUBUCALISANI] = true 
	perfectVault.Config.Criminals[TEAM_PROFHIRSIZ] = true 
	perfectVault.Config.Criminals[TEAM_MASONLIDERI] = true
	perfectVault.Config.Criminals[TEAM_MASON] = true
	perfectVault.Config.Criminals[TEAM_PROFADAMKACIRICI] = true
	perfectVault.Config.Criminals[TEAM_PROFESYONELKAPKACCI] = true
	perfectVault.Config.Criminals[TEAM_BITCOIN] = true
end) -- Ignore this line also