if CLIENT then return end

ArcCW.RandomWeaponCache = {}

hook.Add("PlayerSpawnedNPC", "ArcCW_PlayerSpawnedNPC", function( ply, ent )
    net.Start("arccw_npcgiverequest")
    net.Send(ply)

    ply.ArcCW_LastSpawnedNPC = ent
end)

net.Receive("arccw_npcgivereturn", function(len, ply)
    local class = net.ReadString()
    local ent = ply.ArcCW_LastSpawnedNPC

    if !ent then return end
    if !IsValid(ent) then return end
    if !ent:IsNPC() then return end
    if !class then return end

    local wpn = weapons.Get(class)

    if wpn and wpn.AdminOnly and !ply:IsPlayer() then return end
    if !ArcCW:WithinYearLimit(wpn) then
        return
    end

    local cap = ent:CapabilitiesGet()

    if bit.band(cap, CAP_USE_WEAPONS) != CAP_USE_WEAPONS then return end

    if weapons.IsBasedOn(class, "arccw_base") and wpn.Spawnable and !wpn.NotForNPCs and (!wpn.AdminOnly or ply:IsAdmin()) then
        ent:Give(class)
    end
end)

function ArcCW:GetRandomWeapon(wpn)
    local tbl = ArcCW.RandomWeaponCache[wpn] and ArcCW.RandomWeaponCache[wpn][2]
    local wgt = ArcCW.RandomWeaponCache[wpn] and ArcCW.RandomWeaponCache[wpn][1] or 0

    if !tbl then
        tbl = {}
        for i, k in pairs(weapons.GetList()) do
            if !weapons.IsBasedOn(k.ClassName, "arccw_base") then continue end
            if k.PrimaryBash then continue end
            if !k.Spawnable then continue end
            --if !nades and k.NotForNPCs then continue end -- what does nades do???
            if k.AutoSpawnable == false then continue end

            if !ArcCW:WithinYearLimit(k) then
                continue
            end

            local weight = k.NPCWeight or 0
            if engine.ActiveGamemode() == "terrortown" and k.TTTWeight then
                weight = k.TTTWeight
            end

            if wpn and engine.ActiveGamemode() == "terrortown" and k.TTTWeaponType then -- TTT weapon type(s) take priority over NPC weapon types
                if isstring(k.TTTWeaponType) then
                    if k.TTTWeaponType != wpn then continue end
                elseif istable(k.TTTWeaponType) then
                    if !table.HasValue(k.TTTWeaponType, wpn) then continue end
                end
            elseif wpn and k.NPCWeaponType then
                local class = wpn
                if engine.ActiveGamemode() == "terrortown" and ArcCW.TTTReplaceTable[wpn] then
                    class = ArcCW.TTTReplaceTable[wpn]
                end
                if isstring(k.NPCWeaponType) then
                    if k.NPCWeaponType != class then continue end
                elseif istable(k.NPCWeaponType) then
                    if !table.HasValue(k.NPCWeaponType, class) then continue end
                end
            else
                local og = weapons.Get(wpn)

                if og and og.ArcCW then continue end
                weight = 0 -- Don't spawn if there is none of either
            end

            if weight > 0 then
                -- Don't insert 0 weight, otherwise they still spawn
                wgt = wgt + weight
                table.insert(tbl, {k.ClassName, wgt})
            end
        end

        ArcCW.RandomWeaponCache[wpn] = {wgt, tbl}
    end

    local r = math.random(0, wgt)

    for _, i in pairs(tbl) do
        if i[2] >= r then
            return i[1]
        end
    end
end

hook.Add( "OnEntityCreated", "ArcCW_NPCWeaponReplacement", function(ent)
    if CLIENT then return end
    if ent:IsNPC() and ArcCW.ConVars["npc_replace"]:GetBool() then
        timer.Simple(0, function()
            if !ent:IsValid() then return end
            local cap = ent:CapabilitiesGet()

            if bit.band(cap, CAP_USE_WEAPONS) != CAP_USE_WEAPONS then return end

            local class

            if IsValid(ent:GetActiveWeapon()) then
                class = ent:GetActiveWeapon():GetClass()
            end

            if !class then return end

            local wpn

            wpn = ArcCW:GetRandomWeapon(class)

            if wpn then
                ent:Give(wpn)
            end
        end)
    elseif ent:IsWeapon() and ((engine.ActiveGamemode() == "terrortown" and ArcCW.ConVars["ttt_replace"]:GetBool()) or (engine.ActiveGamemode() != "terrortown" and ArcCW.ConVars["npc_replace"]:GetBool())) then
        timer.Simple(0, function()
            if !ent:IsValid() then return end
            if IsValid(ent:GetOwner()) then return end
            if ent.ArcCW then return end

            local class = ent:GetClass()

            local wpn = ArcCW:GetRandomWeapon(class)

            if wpn then
                local wpnent = ents.Create(wpn)
                wpnent:SetPos(ent:GetPos())
                wpnent:SetAngles(ent:GetAngles())

                wpnent:NPC_Initialize()

                wpnent:Spawn()

                timer.Simple(0, function()
                    if !ent:IsValid() then return end
                    wpnent:OnDrop(true)
                    ent:Remove()
                end)
            end
        end)
    end
end)

-- This hook steals attachments from dropped weapons when a player walks over.
-- Disabled cause this is called CONSTANTLY when player is over a weapon, causing massive network lag.
-- Also it's just weird and hard to understand.
-- hook.Add("PlayerCanPickupWeapon", "ArcCW_PlayerCanPickupWeapon", function(ply, wep)
--     if !wep.ArcCW then return end
--     if !ply:HasWeapon(wep:GetClass()) then return end

--     if wep.Singleton then return false end

--     if !ArcCW.EnableCustomization or ArcCW.ConVars["enable_customization"]:GetInt() < 0 or ArcCW.ConVars["attinv_free"]:GetBool() then return end

--     for _, i in pairs(wep.Attachments) do
--         if i.Installed then
--             ArcCW:PlayerGiveAtt(ply, i.Installed)
--         end

--         i.Installed = nil
--     end

--     ArcCW:PlayerSendAttInv(ply)
--     wep:NetworkWeapon()
-- end)

hook.Add("onDarkRPWeaponDropped", "ArcCW_DarkRP", function(ply, spawned_weapon, wep)
    if wep.ArcCW and wep.Attachments then
        for i, k in pairs(wep.Attachments) do
            if k.Installed then
                ArcCW:PlayerGiveAtt(ply, k.Installed, 1)
            end
        end
        -- Has to be sent to client or desync will happen
        ArcCW:PlayerSendAttInv(ply)
    end
end)

hook.Add("PlayerGiveSWEP", "ArcCW_SpawnRandomAttachments", function(ply, class, tbl)
    if weapons.IsBasedOn(class, "arccw_base") and ArcCW.ConVars["atts_spawnrand"]:GetBool() then
        -- We can't get the weapon entity here - it's spawned after the hook call.
        -- Mark the player to disable autosave tempoarily if we're spawning random attachments.
        ply.ArcCW_Sandbox_RandomAtts = true
        timer.Simple(0.0001, function()
            local wpn = ply:GetWeapon(class)
            if IsValid(ply) and IsValid(wpn) then
                wpn:NPC_SetupAttachments()

                if ply.ArcCW_Sandbox_FirstSpawn then
                    wpn:RestoreAmmo()
                    ply.ArcCW_Sandbox_FirstSpawn = nil
                end
            end
        end)
    end
end)

hook.Add("PlayerSpawnedSWEP", "ArcCW_SpawnRandomAttachments", function(ply, wep)
    if wep.ArcCW and ArcCW.ConVars["atts_spawnrand"]:GetBool() then
        wep:NPC_SetupAttachments()
    end
end)