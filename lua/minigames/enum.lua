--[[--------------------------------------------
              Minigame Enumeration
--------------------------------------------]]--

Minigames.Enum = Minigames.Enum or {}

-- Minigames.Enum["<Alias Name> <Hook Name>"] = function(GameScript, ...)

--[[----------------------------
           Kill Methods
----------------------------]]--

Minigames.Enum["KILL_ONTOUCH"] = function(self, ent)
    if not ( IsValid(ent) and ent:IsPlayer() ) then return end

    local TriggerOwner = self:Getowning_ent()
    local GameScript = Minigames.GetOwnerGame( TriggerOwner )

    local InGame, Owner = Minigames.PlayerInGame( ent )
    if InGame and ( Owner == TriggerOwner ) then
        if GameScript:IsActive() then
            ent:Kill()
        else
            GameScript:TeleportPlayer( ent )
        end
    end
end

Minigames.Enum["KILL_ONKEYPRESS KeyPress"] = function(ply, key)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if ply == Owner then return end

    local GameScript = Minigames.GetOwnerGame( Owner )
    if not GameScript then return end

    if InGame and GameScript:IsLookingBack() and GameScript.KeyPressKill[key] then
        ply:Kill()
    end
end



--[[----------------------------
           Win Methods
----------------------------]]--

Minigames.Enum["WIN_GENERIC"] = function(GameScript)
    local Players = GameScript:GetPlayers(true)

    if #Players > 0 then
        GameScript:SetPlayersWinner( Players[1] )
    end
end

Minigames.Enum["WIN_LASTSURVIVOR"] = function(GameScript)
    local Players = GameScript:GetPlayers(true)

    if #Players == 1 then
        GameScript:SetPlayerWinner( Players[1] )
        GameScript:StopGame()
    elseif #Players < 1 then
        GameScript:StopGame()
    end
end

Minigames.Enum["WIN_ONTOUCHTRIGGER"] = function(self, ent)
    if not ( self:IsActive() ) then return end
    if not ( IsValid(ent) and ent:IsPlayer() ) then return end

    local TriggerOwner = self:Getowning_ent()
    local GameScript = Minigames.GetOwnerGame( TriggerOwner )

    local InGame, Owner = Minigames.PlayerInGame( ent )
    if InGame and ( Owner == TriggerOwner ) then
        GameScript:SetPlayerWinner( ent )
        GameScript:StopGame()
    end
end

Minigames.Enum["WIN_RUSSIANROULETTE"] = function(GameScript)
    local Players = GameScript:GetPlayers(true)
    local Bots = GameScript:GetAllBots()

    if #Players == 1 and #Bots == 0 then
        GameScript:SetPlayerWinner( Players[1] )
    end

    if ( #Players == 0 and #Bots > 0 ) and not GameScript.OnlyBotsPlaying then
        GameScript:SetPlayerWinner( Bots[1] )
    end

    if GameScript.OnlyBotsPlaying and #Bots == 1 then
        GameScript:SetPlayerWinner( Bots[1] )
    end
end



--[[----------------------------
           Extra Methods
----------------------------]]--

Minigames.Enum["GetFallDamage"] = function(ply, speed)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if InGame then
        local GameScript = Minigames.GetOwnerGame( Owner )
        if GameScript:IsActive() then
            return ply:Health()
        end
    end
end

Minigames.Enum["PostPlayerDeath"] = function(ply)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if InGame then
        local GameScript = Minigames.GetOwnerGame( Owner )
        GameScript:RemovePlayer( ply )
    end
end



Minigames.Enum["STOP_ONNOBODY PostPlayerDeath"] = function(ply)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if InGame then
        local GameScript = Minigames.GetOwnerGame( Owner )
        GameScript:RemovePlayer( ply )

        if #GameScript:GetPlayers(true) == 0 then
            GameScript:StopGame()
        end
    end
end

Minigames.Enum["RUSSIANROULETTE PostPlayerDeath"] = function(ply)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if not InGame then return end

    local GameScript = Minigames.GetOwnerGame( Owner )
    if GameScript:GetGameID() ~= "russianroulette" then return end

    GameScript:RemovePlayer( ply )

    if GameScript.MainGameTimer then
        local Variable = GameScript.MainGameTimer:GetVariable()

        for k, inPlayer in ipairs(Variable.Players) do
            if ( inPlayer == ply ) then
                table.remove(Variable.Players, k)
                break
            end
        end
    end
end

Minigames.Enum["DEATHMATCH PlayerDeath"] = function(Victim, Inflictor, Attacker)
    local VictimInGame, VictimOwner = Minigames.PlayerInGame( Victim )
    if not VictimInGame then return end

    local GameScript = Minigames.GetOwnerGame( VictimOwner )
    if GameScript:GetGameID() ~= "deathmatch" then return end

    local AttackerInGame, AttackerOwner = Minigames.PlayerInGame( Attacker )
    if not AttackerInGame then return end

    if ( VictimOwner ~= AttackerOwner ) then return end
    if ( Victim == Attacker ) then return end

    GameScript:AddPoint( Attacker )
end

Minigames.Enum["DEATHMATCH PlayerSelectSpawn"] = function(ply)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if not InGame then return end

    local GameScript = Minigames.GetOwnerGame( Owner )
    if GameScript:GetGameID() ~= "deathmatch" then return end

    return GameScript:SelectSpawnPoint( ply )
end

Minigames.Enum["DEATHMATCH PlayerSpawn"] = function(ply)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if not InGame then return end

    local GameScript = Minigames.GetOwnerGame( Owner )
    if GameScript:GetGameID() ~= "deathmatch" then return end

    timer.Simple(0, function()
        ply:StripWeapons()
        ply:Give(GameScript.WeaponDefault)
        ply:SelectWeapon(GameScript.WeaponDefault)
    end)
end

Minigames.Enum["DEATHMATCH GetFallDamage"] = function(ply)
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if not InGame then return end

    local GameScript = Minigames.GetOwnerGame( Owner )
    if GameScript:GetGameID() ~= "deathmatch" then return end

    if not GameScript.FallDamageEnabled then
        return 0
    end
end