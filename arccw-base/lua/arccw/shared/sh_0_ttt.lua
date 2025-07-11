ArcCW.TTTAmmoToEntity = {
    ["pistol"] = "item_ammo_pistol_ttt",
    ["smg1"] = "item_ammo_smg1_ttt",
    ["AlyxGun"] = "item_ammo_revolver_ttt",
    ["357"] = "item_ammo_357_ttt",
    ["buckshot"] = "item_box_buckshot_ttt"
}
--[[
WEAPON_TYPE_RANDOM = 1
WEAPON_TYPE_MELEE = 2
WEAPON_TYPE_NADE = 3
WEAPON_TYPE_SHOTGUN = 4
WEAPON_TYPE_HEAVY = 5
WEAPON_TYPE_SNIPER = 6
WEAPON_TYPE_PISTOL = 7
WEAPON_TYPE_SPECIAL = 8
]]

ArcCW.AmmoToTTT = {
    ["357"] = "AlyxGun",
    ["SniperPenetratedRound"] = "357",
    ["ar2"] = "smg1",
}
ArcCW.TTTAmmoToClipMax = {
    ["357"] = 20,
    ["smg1"] = 60,
    ["pistol"] = 60,
    ["alyxgun"] = 36,
    ["buckshot"] = 24
}
-- translate TTT weapons to HL2 weapons, in order to recognize NPC weapon replacements.
ArcCW.TTTReplaceTable = {
    ["weapon_ttt_glock"] = "weapon_pistol",
    ["weapon_zm_mac10"] = "weapon_ar2",
    ["weapon_ttt_m16"] = "weapon_smg1",
    ["weapon_zm_pistol"] = "weapon_pistol",
    ["weapon_zm_revolver"] = "weapon_357",
    ["weapon_zm_rifle"] = "weapon_crossbow",
    ["weapon_zm_shotgun"] = "weapon_shotgun",
    ["weapon_zm_sledge"] = "weapon_ar2",
    ["weapon_ttt_smokegrenade"] = "weapon_grenade",
    ["weapon_ttt_confgrenade"] = "weapon_grenade",
    ["weapon_tttbasegrenade"] = "weapon_grenade",
    ["weapon_zm_molotov"] = "weapon_grenade",
}

if engine.ActiveGamemode() != "terrortown" then return end

hook.Add("OnGamemodeLoaded", "ArcCW_TTT", function()
    for i, wep in pairs(weapons.GetList()) do
        local weap = weapons.Get(wep.ClassName)
        if weap then
            if !weap.ArcCW then
                continue
            end
            if weap.ArcCW and !weap.Spawnable then
                continue
            end
        end

        if ArcCW.AmmoToTTT[wep.Primary.Ammo] then
            wep.Primary.Ammo = ArcCW.AmmoToTTT[wep.Primary.Ammo]
        end

        wep.AmmoEnt = ArcCW.TTTAmmoToEntity[wep.Primary.Ammo] or ""
        -- You can tell how desperate I am in blocking the base from spawning
        wep.AutoSpawnable = (wep.AutoSpawnable == nil and true) or wep.AutoSpawnable
        wep.AllowDrop = wep.AllowDrop or true

        -- We have to do this here because TTT2 does a check for .Kind in WeaponEquip,
        -- earlier than Initialize() which assigns .Kind
        if !wep.Kind and !wep.CanBuy then
            if wep.Throwing or weap.Throwing then
                wep.Slot = 3
                wep.Kind = WEAPON_NADE
                wep.spawnType = wep.spawnType or WEAPON_TYPE_NADE
            elseif wep.Slot == 0 then
                -- melee weapons
                wep.Slot = 6
                wep.Kind = WEAPON_MELEE or WEAPON_EQUIP1
                wep.spawnType = wep.spawnType or WEAPON_TYPE_MELEE
            elseif wep.Slot == 1 then
                -- sidearms
                wep.Kind = WEAPON_PISTOL
                wep.spawnType = wep.spawnType or WEAPON_TYPE_PISTOL
            else
                -- other weapons are considered primary
                -- try to determine spawntype if none exists
                if !wep.spawnType then
                    if wep.Primary.Ammo == "357" or (wep.Slot == 3 and (wep.Num or 1) == 1) then
                        wep.spawnType = WEAPON_TYPE_SNIPER
                    elseif wep.Primary.Ammo == "buckshot" or (wep.Num or 1) > 1 then
                        wep.spawnType = WEAPON_TYPE_SHOTGUN
                    else
                        wep.spawnType = WEAPON_TYPE_HEAVY
                    end
                end

                wep.Slot = 2
                wep.Kind = WEAPON_HEAVY
            end
        end

        local class = wep.ClassName
        local path = "arccw/weaponicons/" .. class
        local path2 = "arccw/ttticons/" .. class .. ".png"
        local path3 = "vgui/ttt/" .. class
        local path4 = "entities/" .. class .. ".png"

        if !Material(path2):IsError() then
            -- TTT icon (png)
            wep.Icon = path2
        elseif !Material(path3):IsError() then
            -- TTT icon (vtf)
            wep.Icon = path3
        elseif !Material(path4):IsError() then
            -- Entity spawn icon
            wep.Icon = path4
        elseif !Material(path):IsError() then
            -- Kill icon
            wep.Icon = path
        else
            -- fallback: display _something_
            wep.Icon = "arccw/hud/arccw_bird.png"
        end

    end

    --[[]
    local pistol_ammo = (scripted_ents.GetStored("arccw_ammo_pistol") or {}).t
    if pistol_ammo then
        pistol_ammo.AmmoCount = 30
    end
    ]]

    -- Language string(s)
    if CLIENT then
        local lang = TTT2 and "en" or "english"
        LANG.AddToLanguage(lang, "search_dmg_buckshot", "This person was blasted to pieces by buckshot.")
        LANG.AddToLanguage(lang, "search_dmg_nervegas", "Their face looks pale. It must have been some sort of nerve gas.")
        LANG.AddToLanguage(lang, "ammo_smg1_grenade", "Rifle Grenades")
    end
end)

hook.Add("DoPlayerDeath", "ArcCW_DetectiveSeeAtts", function(ply, attacker, dmginfo)
    local wep = util.WeaponFromDamage(dmginfo)
    timer.Simple(0, function()
        if ArcCW.ConVars["ttt_bodyattinfo"]:GetInt() > 0 and ply.server_ragdoll and IsValid(wep) and wep:IsWeapon() and wep.ArcCW and wep.Attachments then
            net.Start("arccw_ttt_bodyattinfo")
                net.WriteEntity(ply.server_ragdoll)
                net.WriteUInt(table.Count(wep.Attachments), 8)
                for i, info in pairs(wep.Attachments) do
                    if info.Installed then
                        net.WriteUInt(ArcCW.AttachmentTable[info.Installed].ID, ArcCW.GetBitNecessity())
                    else
                        net.WriteUInt(0, ArcCW.GetBitNecessity())
                    end
                end
            net.Broadcast()
        end
    end)
end)

hook.Add("ArcCW_OnAttLoad", "ArcCW_TTT", function(att)
    if att.Override_Ammo and ArcCW.AmmoToTTT[att.Override_Ammo] then
        att.Override_Ammo = ArcCW.AmmoToTTT[att.Override_Ammo]
    end
end)
