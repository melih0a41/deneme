/*
/////      ///////   //   //  /////////  ///////  ////////
///  ///   ///       // //       ///     ///      ///  ///
///  ///   //////     ///        ///     ///////  ///////
///  ///   ///       // //       ///     ///      ///  ///
/////      ///////  //   //      ///     ///////  ///  ///
*/

DEX_LANG = {}
DEX_CONFIG = DEX_CONFIG or {}
DEX_GAGGED_PLAYERS = DEX_GAGGED_PLAYERS or {}

DEX_CONFIG.Language = "tr" -- Can be "en", "pt", "tr", "es", "fr"

-- Minimum and maximum time (in seconds) the player will stay as ragdoll in syringe
DEX_CONFIG.RagdollTimeMin = 25
DEX_CONFIG.RagdollTimeMax = 35 

DEX_CONFIG.TimeToGetUp = 300 -- the player will stay in bed

DEX_CONFIG.OnlyJob = true        -- Only allow serial killer job to use phone

-- ========== ENTITY ==========

DEX_CONFIG.TimeBag = 300 -- Time in seconds before the bag despawns
DEX_CONFIG.EnableUndoForPurchasedProps = true  -- Enable or disable undo support for bought props
DEX_CONFIG.BoxSwep = "weapon_fists" -- Important to use a weapon the player normally holds, not the physgun, e.g. "weapon_fists", to avoid bugs
DEX_CONFIG.DisableDespawnOnJobChange = false -- Set to true to disable despawning when changing jobs
DEX_CONFIG.DisableSyringeSecondaryAttack = true  -- Set to true to disable right-click on the syringe
DEX_CONFIG.GiveBagSWEP = true -- If true, gives the dex_w_bag weapon to the player; if false, spawns the bag entity directly

-- ========== SANITY ==========
DEX_CONFIG.SanitySystemEnabled = true              -- Enable/disable the entire sanity system
DEX_CONFIG.SanityStart = 300                       -- Initial sanity
DEX_CONFIG.SanityDrainInterval = 30                -- Drain interval in seconds
DEX_CONFIG.SanityDrainAmount = 1                   -- Amount drained each time
DEX_CONFIG.SanityCritical = 15                     -- Critical value to trigger effects
DEX_CONFIG.SanityEnableEffects = true              -- Enable/disable effects (sounds, blood, screen)

-- ========== DAMAGE SETTINGS ==========
DEX_CONFIG.BoneDamageMultiplier = 1.0 -- Damage multiplier for bones (1.0 = normal, 2.0 = double, 0.5 = half, etc.)

-- ========== FILE INCLUSION ==========
local function lua_file(name, cl)
    local full_name = "dex/" .. name .. ".lua"
    AddCSLuaFile(full_name)

    if not (cl and SERVER) then
        include(full_name)
    end
end

lua_file("dismemberment")

function DEX_LANG.Get(key)
    local lang = DEX_CONFIG.Language or "en"
    return (DEX_LANG[lang] and DEX_LANG[lang][key]) or "[[" .. key .. "]]"
end

AddCSLuaFile("dex/dex_lang.lua")
include("dex/dex_lang.lua")

-- ========== ITEMS ==========
DEX_CONFIG.ItemsToBuy = {
    {
        name = DEX_LANG.Get("box_print_name"), 
        model = "models/blood/box.mdl",
        entidade = "dex_box", 
        price = 100,
        offset = 0,
        isSWEP = false,
        image = "vgui/items/box.png"
    },
    {
        name = DEX_LANG.Get("table_print_name"), 
        model = "models/blood/table.mdl",
        entidade = "dex_bed", 
        price = 150,
        offset = 20,
        isSWEP = false,
        image = "vgui/items/table.png"
    },
    {
        name = DEX_LANG.Get("syringe_printname"),
        model = "models/blood/c_syringe.mdl",
        entidade = "dex_syringe",
        price = 500,
        offset = 0,
        isSWEP = true,
        image = "vgui/items/syringe.png"
    },
    {
        name = DEX_LANG.Get("knife_printname"),
        model = "models/weapons/cstrike/c_knife_t.mdl",
        entidade = "dex_butcher_knife",
        price = 500,
        offset = 0,
        isSWEP = true,
        image = "vgui/items/knife.png"
    }
}
-- ========== FUNCTIONS ==========
timer.Simple(0, function()
    DEX_CONFIG.AllowedSerialKillerTeams = {
        TEAM_SERIALKILLER
    }
end)

function DEX_CONFIG.IsSerialKiller(ply)
    return table.HasValue(DEX_CONFIG.AllowedSerialKillerTeams or {}, ply:Team())
end
-- ========== HOOK ==========
hook.Add("PlayerCanHearPlayersVoice", "dex_BlockVoice", function(listener, talker)
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[talker] then
        return false, false
    end
end)

hook.Add("PlayerSay", "dex_BlockChat", function(ply, text)
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[ply] then
        return ""
    end
end)

hook.Add("PlayerSay", "dex_BlockCommandsWhenRagdoll", function(ply, text)
    if ply:GetNWBool("IsInRagdoll") and (string.StartWith(text, "!") or string.StartWith(text, "/")) then
        return ""
    end
end)

hook.Add("CanPlayerSuicide", "dex_BlockSuicideWhenRagdoll", function(ply)
    if ply:GetNWBool("IsInRagdoll") then
        return false
    end
end)

-- ========== LOGO ==========

list.Set( "ContentCategoryIcons", "Dex's Addons", "vgui/dexicon.png" )

print([[
/////      ///////   //   //  /////////  ///////  ////////
///  ///   ///       // //       ///     ///      ///  ///
///  ///   //////     ///        ///     ///////  ///////
///  ///   ///       // //       ///     ///      ///  ///
/////      ///////  //   //      ///     ///////  ///  ///
]])