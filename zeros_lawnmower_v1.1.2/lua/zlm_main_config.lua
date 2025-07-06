/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm or {}
zlm.f = zlm.f or {}
zlm.config = zlm.config or {}

/////////////////////////////////////////////////////////////////////////////

// Bought by 76561198307194389
// Version v1.1.2


/////////////////////////// Zeros LawnMower /////////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242
// https://www.artstation.com/zerochain

/////////////////////////////////////////////////////////////////////////////

// This enables the Debug Mode
zlm.config.Debug = false

// Switches between FastDl and Workshop
zlm.config.EnableResourceAddfile = false

// Currency
zlm.config.Currency = "₺"

// The language , en , de, fr , es , pl , ru , cn
zlm.config.SelectedLanguage = "en"

// unit of weight
zlm.config.UoW = "kg"

// These Ranks are allowed to use the debug commands and save GrassSpots with !savezlm
// If xAdmin is installed this table will be ignored
zlm.config.AdminRanks = {
    ["superadmin"] = true,
    ["owner"] = true,
}

zlm.config.SimpleGrassMode = {

    // If set to true then no client grass will be Spawned and the LawnMower will be using Brush Textures / Displacment to determine if he is currently on Grass
    Enabled = false,

    // The Brush Textures that count as Grass (This does only check Brush Faces not Displacments)
    Textures = {},

    // Are we allowing Displacments to count as Grass?
    Displacement = true,
}

zlm.config.LawnMower = {

    // How much grass can it collect before its full
    StorageCapacity = 500,

    // This is only used if SimpleGrassMode is enabled
    MoweInterval = 0.1,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

    // Do we want the LawnMower to be NoCollide for the Players
    NoCollide = true,

    //http://wiki.garrysmod.com/page/Enums/BUTTON_CODE
    Keys = {

        // This Key toggles the blades
        StartBlades = KEY_T,

        // This Key unloads the grass basket to a grass press or sells the grass rolls to a npc if the player has the trailer connected and is near the npc
        Unload = KEY_F,

        // This Key connects the trailer or the grass basket
        Connect = KEY_C,
    },

    // If VCMod is installed then these values are used for fuel consumption when the blades are used for mowing
    // This dont defines the fuel usage for the vehicle itself but is more of a extra fuel consumption when the machines blades are enabled.
    Fuel = {

        // The amount of fuel that gets used
        fc_amount = 0.25,

        // The rate at which fuel gets used in seconds
        fc_time = 10,
    }
}

zlm.config.GrassPress = {
    // How much grass can the machine hold
    Capacity = 2000,

    // How much grass is needed to produce one Grass roll
    Production_Amount = 100,

    // How long does it take to press a grass roll
    Production_Time = 60,

    // The minimal production time that will be set after the player bought all the upgrades
    Production_TimeLimit = 40,

    // How many valid grassrolls are allowed to exist at the same time per grasspress. This Limit makes sure the player cant spamm the world with grassrolls
    GrassRoll_Limit = 10,

    // The upgrades gonna decrease the production time of the GrassPress
    Upgrades = {
        Enabled = true,

        // How many upgrades can the player buy
        Count = 10,

        // What ranks are allowed to buy upgrades, Leave Empty to disable the rank check
        Ranks = {},

        // How much does one upgrade cost
        Price = 10000,

        // How long until the player can buy another upgrade
        Cooldown = 120,
    }
}

zlm.config.Grass = {
    // How long till the grass re grows in seconds?
    RefreshTime = 120,

    // Only these job can see the grass, leave empty to allow everyone to see the grass
    RenderForJob = {
        [TEAM_ZLM_LAWNMOWERMAN] = true,
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

zlm.config.NPC = {
    // The model of the npc
    Model = "models/player/suits/npc/the_ortho_jew.mdl" ,

    // Setting this to false will improve network performance but disables the npc reactions for the player
    Capabilities = true,

    // The values below define the minimum and maximum buy rate of the npc in percentage.
    // The base money the player will recieve is still defined in the SellPrice var above but this modifies it to be diffrent from npc to npc.
    // If you dont want this then just set both to 100
    MaxBuyRate = 125,
    MinBuyRate = 75,

    // The Distance and what the player can sell to the npc
    SellDistance = 300,

    // The interval at which the buy rate changes in seconds, set to -1 to disable the refreshing of the price modifier
    RefreshRate = 600,
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    // These jobs are allowed to interact with the npc, Leave empty to allow everyone
    Interaction = {
        [TEAM_ZLM_LAWNMOWERMAN] = true
    },

    // The Shop prices
    Shop = {
        ["lawnmower"] = 5000,
        ["trailer"] = 5000,
    },

    // The sell price per GrassRoll
    SellPrice = {
        ["Default"] = 15000,
        ["silvervip"] = 20000,
        ["superadmin"] = 50000,
		["viprehber"] = 15000,
		["moderator"] = 15000,
		["moderator+"] = 17500,
		["goldvip"] = 25000,
		["platinumvip"] = 30000,
		["diamondvip"] = 35000,
		["rp+"] = 17500,		
    
	
	}
}

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

// Do we have VrondakisLevelSystem installed?
zlm.config.VrondakisLevelSystem = false
zlm.config.Vrondakis = {}
zlm.config.Vrondakis["Mowing"] = {XP = 1} // XP per cut down grass
zlm.config.Vrondakis["Selling"] = {XP = 1}	// XP per sold grassroll
