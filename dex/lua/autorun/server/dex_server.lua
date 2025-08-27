-- ====================================================

util.AddNetworkString("dex_UpdateSanity")
util.AddNetworkString("dex_PlaySanitySounds")

-- ====================================================

local function StartSanityDrain(ply)
    if not DEX_CONFIG.SanitySystemEnabled then return end

    -- Cooldown ile senkronize sanity düşüşü
    timer.Create("dex_SanityDrain_" .. ply:SteamID(), 5, 0, function()
        if not IsValid(ply) or not ply:Alive() or not DEX_CONFIG.IsSerialKiller(ply) then return end

        -- Cooldown durumunu kontrol et
        local onCooldown, timeLeft = IsOnCooldown(ply)
        
        if onCooldown then
            -- Cooldown varsa, kalan süreye göre sanity düşüşünü ayarla
            local cooldownProgress = 1 - (timeLeft / 600) -- 0'dan 1'e doğru ilerler
            
            local targetSanity
            if cooldownProgress < 0.7 then
                -- İlk 7 dakika: 100'den 50'ye yavaş düşüş
                targetSanity = 100 - (50 * (cooldownProgress / 0.7))
            else
                -- Son 3 dakika: 50'den 20'ye hızlı düşüş
                local lastPhase = (cooldownProgress - 0.7) / 0.3
                targetSanity = 50 - (30 * lastPhase)
            end
            
            -- Sanity'yi hedef değere doğru ayarla
            if ply.Sanity > targetSanity then
                ply.Sanity = math.max(20, targetSanity)
            end
        else
            -- Cooldown yoksa normal düşüş (çok yavaş)
            ply.Sanity = math.max(0, ply.Sanity - 0.5)
        end

        net.Start("dex_UpdateSanity")
        net.WriteInt(ply.Sanity, 8)
        net.Send(ply)

        -- Kritik seviyede ses efektleri
        if DEX_CONFIG.SanityEnableEffects and ply.Sanity <= (DEX_CONFIG.SanityCritical or 20) then
            net.Start("dex_PlaySanitySounds")
            net.Send(ply)
        end
    end)
end

-- Öldürme sonrası sanity yenileme
function RefreshSanityAfterKill(ply)
    if not IsValid(ply) or not DEX_CONFIG.IsSerialKiller(ply) then return end
    
    ply.Sanity = 100 -- Tam tatmin
    
    net.Start("dex_UpdateSanity")
    net.WriteInt(ply.Sanity, 8)
    net.Send(ply)
    
    -- Bildirim gönder
    if DarkRP then
        DarkRP.notify(ply, 0, 5, "Öldürme isteğin tatmin oldu... Şimdilik.")
    end
end

-- ====================================================

hook.Add("PlayerSpawn", "dex_InitSanity", function(ply)
    if not DEX_CONFIG.SanitySystemEnabled then return end
    if DEX_CONFIG.IsSerialKiller(ply) then
        -- Spawn'da sanity kontrolü
        local onCooldown, timeLeft = IsOnCooldown(ply)
        if onCooldown then
            -- Cooldown varsa kalan süreye göre sanity ayarla
            local cooldownProgress = 1 - (timeLeft / 600)
            if cooldownProgress < 0.7 then
                ply.Sanity = 100 - (50 * (cooldownProgress / 0.7))
            else
                local lastPhase = (cooldownProgress - 0.7) / 0.3
                ply.Sanity = 50 - (30 * lastPhase)
            end
        else
            ply.Sanity = DEX_CONFIG.SanityStart or 100
        end
        
        StartSanityDrain(ply)
    end
    
    -- SPAWN OLDUĞUNDA GAG TEMİZLE
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[ply] then
        DEX_GAGGED_PLAYERS[ply] = nil
        
        net.Start("dex_UpdateGagged")
            net.WriteEntity(ply)
            net.WriteBool(false)
        net.Broadcast()
    end
end)

-- ====================================================

hook.Add("PlayerDeath", "dex_StopSanityTimer", function(ply)
    timer.Remove("dex_SanityDrain_" .. ply:SteamID())
    
    -- ÖLÜNCE GAG TEMİZLE
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[ply] then
        DEX_GAGGED_PLAYERS[ply] = nil
        
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

-- GAG SİSTEMİ İÇİN EK GÜVENLİK
hook.Add("PlayerDisconnected", "dex_CleanGagOnDisconnect", function(ply)
    if DEX_GAGGED_PLAYERS and DEX_GAGGED_PLAYERS[ply] then
        DEX_GAGGED_PLAYERS[ply] = nil
    end
end)

hook.Add("Initialize", "dex_InitGagSystem", function()
    DEX_GAGGED_PLAYERS = {}
end)

timer.Create("dex_CleanupInvalidGags", 300, 0, function()
    if not DEX_GAGGED_PLAYERS then return end
    
    for ply, _ in pairs(DEX_GAGGED_PLAYERS) do
        if not IsValid(ply) or not ply:IsPlayer() then
            DEX_GAGGED_PLAYERS[ply] = nil
        end
    end
end)