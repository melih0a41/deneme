ArcCW.AmmoEntToArcCW = {
    -- TTT
    ["item_ammo_pistol_ttt"] = "arccw_ammo_pistol",
    ["item_ammo_smg1_ttt"] = "arccw_ammo_smg1",
    ["item_ammo_revolver_ttt"] = "arccw_ammo_357",
    ["item_ammo_357_ttt"] = "arccw_ammo_sniper",
    ["item_box_buckshot_ttt"] = "arccw_ammo_buckshot",

    -- HL2
    ["item_ammo_357"] = "arccw_ammo_357",
    ["item_ammo_357_large"] = "arccw_ammo_357_large",
    ["item_ammo_ar2"] = "arccw_ammo_ar2",
    ["item_ammo_ar2_large"] = "arccw_ammo_ar2_large",
    ["item_ammo_pistol"] = "arccw_ammo_pistol",
    ["item_ammo_pistol_large"] = "arccw_ammo_pistol_large",
    ["item_ammo_smg1"] = "arccw_ammo_smg1",
    ["item_ammo_smg1_large"] = "arccw_ammo_smg1_large",
    ["item_ammo_smg1_grenade"] = "arccw_ammo_smg1_grenade",
    ["item_ammo_crossbow"] = "arccw_ammo_sniper",
    ["item_box_buckshot"] = "arccw_ammo_buckshot",
    ["item_ammo_ar2_altfire"] = "arccw_ammo_smg1_grenade",

    -- HL:S
    ["ammo_357"] = "arccw_ammo_357",
    ["ammo_crossbow"] = "arccw_ammo_sniper",
    ["ammo_glockclip"] = "arccw_ammo_pistol",
    ["ammo_9mmbox"] = "arccw_ammo_ar2",
    ["ammo_mp5clip"] = "arccw_ammo_smg1",
    ["ammo_mp5grenades"] = "arccw_ammo_smg1_grenade",
    ["ammo_rpgclip"] = "arccw_ammo_smg1_grenade_large",
    ["ammo_buckshot"] = "arccw_ammo_buckshot",
    ["ammo_gaussclip"] = "arccw_ammo_ar2_large"
}

function ArcCW:AddGrenadeAmmo()
    if ArcCW.ConVars["equipmentammo"]:GetBool() and !ArcCW.ConVars["equipmentsingleton"]:GetBool() then
        for i, k in pairs(weapons.GetList()) do
            local class = k.ClassName
            local wpntbl = weapons.Get(class)
            if !wpntbl.ArcCW then continue end

            if (wpntbl.Throwing or wpntbl.Disposable) and !wpntbl.Singleton and !wpntbl.DoNotEquipmentAmmo then
                -- ammoid check will cause inconsistency between SV/CL on map change
                -- Initialize is only run once anyways, so it should be fine
                --local ammoid = game.GetAmmoID(class)
                --if ammoid == -1 then
                    -- if ammo type does not exist, build it
                    game.AddAmmoType({
                        name = class,
                    })
                    print("ArcCW adding ammo type " .. class)
                    if CLIENT then
                        language.Add(class .. "_ammo", wpntbl.PrintName)
                    end
                    ArcCW.LangTable["en"]["ammo." .. class] = wpntbl.PrintName
                --end

                k.Primary.Ammo = class
                k.OldAmmo = class
            end
        end
    end
end

hook.Add("Initialize", "ArcCW_AddGrenadeAmmo", ArcCW.AddGrenadeAmmo)

if SERVER then
    hook.Add( "OnEntityCreated", "ArcCW_AmmoReplacement", function(ent)
        if ((engine.ActiveGamemode() == "terrortown" and ArcCW.ConVars["ttt_ammo"]:GetBool()) or
            (engine.ActiveGamemode() != "terrortown" and ArcCW.ConVars["ammo_replace"]:GetBool()))
                and ArcCW.AmmoEntToArcCW[ent:GetClass()] then
            timer.Simple(0, function()
                if !IsValid(ent) then return end
                local ammoent = ents.Create(ArcCW.AmmoEntToArcCW[ent:GetClass()])
                ammoent:SetPos(ent:GetPos())
                ammoent:SetAngles(ent:GetAngles())
                ammoent:Spawn()
                SafeRemoveEntityDelayed(ent, 0) -- remove next tick
                if engine.ActiveGamemode() == "terrortown" then
                    -- Setting owner prevents pickup
                    if IsValid(ent:GetOwner()) then
                        ammoent:SetOwner(ent:GetOwner())
                        timer.Simple(2, function()
                            if IsValid(ammoent) then ammoent:SetOwner(nil) end
                        end)
                        ammoent.AmmoCount = ent.AmmoAmount
                    end
                    --[[]
                    if ent:GetClass() == "item_ammo_pistol_ttt" and ent.AmmoCount == 20 then
                        -- Extremely ugly hack: TTT pistol ammo only gives 20 rounds but we want it to be 30
                        -- Because most SMGs use pistol ammo (unlike vanilla TTT) and it runs out quickly
                        ammoent.AmmoCount = 30
                    end
                    ]]
                    ammoent:SetNWInt("truecount", ammoent.AmmoCount)
                end
            end)
        end
    end)
end