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
    
    -- SPAWN OLDUĞUNDA GAG TEMİZLE - YENİ EKLENDİ!
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[ply] then
        DEX_GAGGED_PLAYERS[ply] = nil
        
        -- Client'lara bildir
        net.Start("dex_UpdateGagged")
            net.WriteEntity(ply)
            net.WriteBool(false)
        net.Broadcast()
    end
end)

-- ====================================================

hook.Add("PlayerDeath", "dex_StopSanityTimer", function(ply)
    timer.Remove("dex_SanityDrain_" .. ply:SteamID())
    
    -- ÖLÜNCE GAG TEMİZLE - YENİ EKLENDİ!
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[ply] then
        DEX_GAGGED_PLAYERS[ply] = nil
        
        -- Client'lara bildir
        net.Start("dex_UpdateGagged")
            net.WriteEntity(ply)
            net.WriteBool(false)
        net.Broadcast()
    end
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

-- GAG SİSTEMİ İÇİN EK GÜVENLİK - YENİ EKLENDİ!
hook.Add("PlayerDisconnected", "dex_CleanGagOnDisconnect", function(ply)
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[ply] then
        DEX_GAGGED_PLAYERS[ply] = nil
    end
end)

-- Sunucu başladığında gag tablosunu temizle - YENİ EKLENDİ!
hook.Add("Initialize", "dex_InitGagSystem", function()
    DEX_GAGGED_PLAYERS = {}
end)

-- Her 5 dakikada bir geçersiz gag kayıtlarını temizle - YENİ EKLENDİ!
timer.Create("dex_CleanupInvalidGags", 300, 0, function()
    if not DEX_GAGGED_PLAYERS then return end
    
    for ply, _ in pairs(DEX_GAGGED_PLAYERS) do
        if not IsValid(ply) or not ply:IsPlayer() then
            DEX_GAGGED_PLAYERS[ply] = nil
        end
    end
end)