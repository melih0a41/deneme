
-- ====================================================

util.AddNetworkString("dex_UpdateSanity")
util.AddNetworkString("dex_PlaySanitySounds")

-- ====================================================

local function StartSanityDrain(ply)
    if not DEX_CONFIG.SanitySystemEnabled then return end

    timer.Create("dex_SanityDrain_" .. ply:SteamID(), DEX_CONFIG.SanityDrainInterval or 10, 0, function()
        if not IsValid(ply) or not ply:Alive() or not DEX_CONFIG.IsSerialKiller(ply) then return end

        ply.Sanity = math.max(0, ply.Sanity - (DEX_CONFIG.SanityDrainAmount or 1))
        net.Start("dex_UpdateSanity")
        net.WriteInt(ply.Sanity, 8)
        net.Send(ply)

        if DEX_CONFIG.SanityEnableEffects and ply.Sanity <= (DEX_CONFIG.SanityCritical or 20) then
            net.Start("dex_PlaySanitySounds")
            net.Send(ply)
        end
    end)
end

-- ====================================================

hook.Add("PlayerSpawn", "dex_InitSanity", function(ply)
    if not DEX_CONFIG.SanitySystemEnabled then return end
    if DEX_CONFIG.IsSerialKiller(ply) then
        ply.Sanity = DEX_CONFIG.SanityStart or 100
        StartSanityDrain(ply)
    end
end)

-- ====================================================

hook.Add("PlayerDeath", "dex_StopSanityTimer", function(ply)
    timer.Remove("dex_SanityDrain_" .. ply:SteamID())
end)

-- ====================================================

local PlayerDeathTracker = {}

function PlayerDeathTracker:RegisterKill(killer, victim)
    if not killer.victimList then
        killer.victimList = {}
    end

    table.insert(killer.victimList, {
        name = victim:Nick(),
        model = victim:GetModel()
    })

    if #killer.victimList > 3 then
        table.remove(killer.victimList, 1)
    end
end

hook.Add("PlayerDeath", "dex_TrackPlayerKills", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
        PlayerDeathTracker:RegisterKill(attacker, victim)
    end
end)
