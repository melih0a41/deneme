--[[--------------------------------------------
            Minigame Module - Player
--------------------------------------------]]--

util.AddNetworkString("Minigames.TogglePlayer")

MinigameObject.__Players = {}
MinigameObject.__PlayerAddedHooks = {}
MinigameObject.TeleportOffset = vector_origin
MinigameObject.DefaultTeleportEntities = {}


--[[----------------------------
        Player Management
----------------------------]]--

function MinigameObject:OnPlayerChanged(ply, AreAdded)
    -- Template
end

function MinigameObject:AddPlayer(NewPlayer)
    self:Checker(NewPlayer, "player", 1)

    if not IsValid( self:GetOwner() ) then
        self.ThrowError("There is no owner for this minigame.", self:GetOwner(), "player")
    end

    if self.__Players[NewPlayer] then
        Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.player.alreadyingame"), NewPlayer ), self:GetOwner() )
        return false
    end

    local CurrentOwner = self:GetOwner()
    local Response = false
    if self:IsActive() then return Response end

    if not NewPlayer:Alive() then
        Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.player.cantjoin.dead"), NewPlayer ), CurrentOwner )
        return Response
    end

    -- Hook checker
    local CanJoin, Message = hook.Run("Minigames.CanPlayerJoin", NewPlayer, CurrentOwner)
    if ( CanJoin == false ) then
        Minigames.BroadcastMessage( NewPlayer, Message or Minigames.GetPhrase("minigames.player.cantjoin.you") )
        Minigames.BroadcastMessage( CurrentOwner, Message or Minigames.StringFormat( Minigames.GetPhrase("minigames.player.cantjoin"), NewPlayer ) )
        return Response
    end

    NewPlayer:SetNWBool("Minigames.InGame", true)
    NewPlayer:SetNWEntity("Minigames.Owner", CurrentOwner)

    hook.Run("Minigames.TogglePlayer", NewPlayer, CurrentOwner, true)

    if Minigames.Config["StripWeaponsOnGame"] then
        Minigames.StripWeapons(NewPlayer)
    end

    self.__Players[NewPlayer] = true

    if NewPlayer:IsPlayer() then
        local Players = self:GetPlayers(true)
        table.insert( Players, NewPlayer )
        table.insert( Players, CurrentOwner )

        Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.onjoin"), NewPlayer ), Players )
    end

    self:TriggerOnPlayerAddedHooks( NewPlayer )

    net.Start("Minigames.TogglePlayer")
        net.WritePlayer( NewPlayer )
        net.WritePlayer( CurrentOwner )
        net.WriteBool( true )
    net.Broadcast()

    self:OnPlayerChanged(NewPlayer, true)

    return true
end

function MinigameObject:RemovePlayer(OldPlayer, Silent)
    self:Checker(OldPlayer, "player", 1)

    if not self.__Players[OldPlayer] then
        Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.player.notingame"), OldPlayer ), self:GetOwner() )
        return false
    end

    OldPlayer:SetNWEntity("Minigames.Owner", NULL)
    OldPlayer:SetNWBool("Minigames.InGame", false)

    hook.Run("Minigames.TogglePlayer", OldPlayer, self:GetOwner(), false)

    net.Start("Minigames.TogglePlayer")
        net.WritePlayer( OldPlayer )
        net.WritePlayer( self:GetOwner() )
        net.WriteBool( false )
    net.Broadcast()

    if Minigames.Config["StripWeaponsOnGame"] then
        Minigames.GiveWeapons(OldPlayer)
    end

    if not Silent then
        local Players = self:GetPlayers(true)
        table.insert( Players, OldPlayer )
        table.insert( Players, self:GetOwner() )

        if self:IsActive() then
            Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.onlose"), OldPlayer ), Players )
        else
            Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.onleft"), OldPlayer ), Players )
        end
    end

    self:StopAllWorldSounds(OldPlayer)

    self.__Players[OldPlayer] = nil

    if not Silent then
        self:OnPlayerChanged(OldPlayer, false)
    end

    return true
end

function MinigameObject:TogglePlayer( ply )
    if self:IsActive() then return false end
    if not ( IsValid( ply ) and ply:IsPlayer() ) then return end

    local Result = false
    local InGame, WhatOwner = Minigames.PlayerInGame( ply )

    if ( InGame == true ) then
        if ( WhatOwner == self:GetOwner() ) then
            Result = self:RemovePlayer( ply )
        else
            Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.player.cantjoin"), ply ), self:GetOwner() )
        end
    else
        Result = self:AddPlayer( ply )
    end

    return Result
end

function MinigameObject:GetPlayers(GetKeys)
    return ( GetKeys == true ) and table.GetKeys(self.__Players) or self.__Players
end

function MinigameObject:GetPlayer(TargetPlayer)
    self:Checker(TargetPlayer, "player", 1)

    return self.__Players[TargetPlayer]
end

function MinigameObject:HasPlayer(TargetPlayer)
    self:Checker(TargetPlayer, "player", 1)

    return self.__Players[TargetPlayer] ~= nil
end

function MinigameObject:RemoveAllPlayers(Silent)
    for _, ply in ipairs( self:GetPlayers(true) ) do
        self:RemovePlayer(ply, Silent)
    end

    self:RemoveAllBots(Silent)

    return true
end

--[[----------------------------
          Player Winner
----------------------------]]--

function MinigameObject:SetPlayerWinner(ply)
    if self:IsBot(ply) then return false end
    self:Checker(ply, "player", 1)

    local Response = self:PrePlayerWinner(ply)
    if ( Response == false ) then return Response end

    self:GiveReward({ply})
    self:RemovePlayer(ply, true)
    --[[
    self:SetActive(false)
    self:RemoveAllPlayers(true)

    local ResponseStop = self:StopGame()
    if ( ResponseStop == false ) then return ResponseStop end
    --]]
end

function MinigameObject:SetPlayersWinner(Players)
    self:Checker(Players, "table", 1)

    local Response = self:PrePlayerWinner(Players)
    if ( Response == false ) then return Response end

    self:GiveReward(Players)
    for _, ply in ipairs( Players ) do
        self:RemovePlayer(ply, true)
    end

    --[[
    self:SetActive(false)
    self:RemoveAllPlayers(true)

    local ResponseStop = self:StopGame()
    if ( ResponseStop == false ) then return ResponseStop end
    --]]
end


--[[----------------------------
          Player Events
----------------------------]]--

function MinigameObject:PrePlayerWinner(ply)
    -- Template
end

function MinigameObject:OnPlayerAdded(func)
    self:Checker(func, "function", 1)

    table.insert( self.__OnPlayerAddedHooks, func )
end

function MinigameObject:TriggerOnPlayerAddedHooks(ply)
    for _, func in ipairs( self.__PlayerAddedHooks ) do
        func( ply )
    end
end

function MinigameObject:PostPlayerDeath(func)
    hook.Add("PostPlayerDeath", "Minigames.PostPlayerDeath." .. self:GetGameID() .. "." .. self:GetOwnerID(), function(ply)
        local InGame, Owner = Minigames.PlayerInGame( ply )
        if InGame and ( Owner == self:GetOwner() ) then
            func(ply, false)
        end
    end)

    hook.Add("Minigame.PostBotDeath", "Minigames.PostBotDeath." .. self:GetGameID() .. "." .. self:GetOwnerID(), function(bot, Owner)
        if ( Owner == self:GetOwner() ) then
            func(bot, true)
        end
    end)
end


--[[----------------------------
          Util Methods
----------------------------]]--

function MinigameObject:TeleportPlayers(Entities, Offset)
    self:Checker(Entities, "table", 1)

    if ( Offset == nil ) then
        Offset = self.TeleportOffset
    end

    self:Checker(Offset, "vector", 2)

    local CurrentPlayers = self:GetPlayers(true)
    for _, ply in ipairs( CurrentPlayers ) do
        local RandomEntity = table.remove( Entities, math.random(1, #Entities) )
        ply.MG_OldPos = ply:GetPos()

        ply:SetPos( RandomEntity:GetPos() + Offset )
        ply:SetLocalVelocity( vector_origin )
    end
end

function MinigameObject:TeleportPlayer(TargetPlayer, Entities, Offset)
    self:Checker(TargetPlayer, "player", 1)

    if not istable(Entities) then
        Entities = self.DefaultTeleportEntities
    end

    if table.IsEmpty(Entities) then return end

    if ( Offset == nil ) then
        Offset = self.TeleportOffset
    end

    self:Checker(Offset, "vector", 3)

    local RandomEntity = Entities[ math.random(1, #Entities) ]
    TargetPlayer.MG_OldPos = TargetPlayer:GetPos()

    TargetPlayer:SetPos( RandomEntity:GetPos() + Offset )
    TargetPlayer:SetEyeAngles( RandomEntity:GetAngles() )
    TargetPlayer:SetLocalVelocity( vector_origin )
end

function MinigameObject:ReturnPlayers()
    local CurrentPlayers = self:GetPlayers(true)
    for _, ply in ipairs( CurrentPlayers ) do
        if isvector( ply.MG_OldPos ) then
            ply:SetPos( ply.MG_OldPos )
            ply.MG_OldPos = nil
        end
    end
end

function MinigameObject:ReturnPlayer(TargetPlayer)
    self:Checker(TargetPlayer, "player", 1)

    if not self.__Players[TargetPlayer] then return end

    if isvector( TargetPlayer.MG_OldPos ) then
        TargetPlayer:SetPos( TargetPlayer.MG_OldPos )
        TargetPlayer.MG_OldPos = nil
    end
end

function Minigames.ReturnPlayer(ply)
    if ply.MG_OldPos then
        ply:SetPos( ply.MG_OldPos )
        ply.MG_OldPos = nil
    end
end