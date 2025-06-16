--[[--------------------------------------------
                    Drop Out
--------------------------------------------]]--

local MainOffset = 94.95968

local RedColor = Color(255, 0, 0)
local KillBoxOffset = Vector(300, -300, 0)
local KillBoxHeight = Vector(0, 0, 60)

local RandomAngles = {}
for i = 1, 7 do
    table.insert( RandomAngles, Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)) )
end

local LOOP_MUSIC = true

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Drop Out Neo")
GameScript:AddHeader("!gameconfig")

GameScript:AddConfig("Increment", {
    min = 0,
    max = 20,
    def = 1
})
GameScript:AddConfig("Delay", {
    min = 0.1,
    max = 4,
    dec = 1,
    def = 2.2
})
GameScript:AddConfig("TimeReaction", {
    min = 0.2,
    max = 3,
    dec = 1,
    def = 0.8
})

GameScript:AddHeader("!playzoneconfig")

GameScript:AddConfig("SizeX", {
    min = 1,
    max = 20,
    def = 5
})
GameScript:AddConfig("SizeY", {
    min = 1,
    max = 20,
    def = 5
})
GameScript:AddConfig("Offset", {
    min = 0,
    max = 200,
    dec = 1,
    def = 0
})
GameScript:AddConfig("Height", {
    min = 150,
    max = 2048,
    def = 150
})


--[[----------------------------
           Custom Vars
----------------------------]]--

GameScript.TeleportOffset = Vector(0, 0, 50)
GameScript.FullyStarted = false

--[[----------------------------
        Trigger Events
----------------------------]]--

GameScript:AddHook( "PostPlayerDeath", "GetFallDamage" )

function GameScript:OnPlayerChanged(ply, Joined)
    if not self:IsActive() then return end

    local CurrentPlayers = self:GetPlayers(true)

    if #CurrentPlayers == 1 then
        self:SetPlayerWinner( CurrentPlayers[1] )
        self:StopGame()
    elseif #CurrentPlayers < 1 then
        self:StopGame()
    end

    -- Is very uncanny to see IsActive after check the game isn't active
    if
        Minigames.Config["PlayMusic"] and
        self:IsActive() and
        #CurrentPlayers <= Minigames.Config["PlayersToFastMusic"]
    then
        self:PlayWorldSound( "sound/" .. Minigames.Config["BackgroundMusicFast"], LOOP_MUSIC )
    end
end


--[[----------------------------
           Game Events
----------------------------]]--

GameScript:AddNewVar("GamePaused", "bool", false)

function GameScript:Pause()
    if not self:IsActive() then return false end

    local State = self:ToggleGamePaused()

    if self.MainTimer then
        self.MainTimer:Pause(State)
    elseif self.BeginTimer then
        self.BeginTimer:Pause(State)
    end

    return true
end


--[[----------------------------
        Plataforms Manager
----------------------------]]--

function GameScript:FirstStage(Amount, Entities)
    local RandomEntities = {}

    for i = 1, Amount do
        local ent = table.remove( Entities, math.random(1, #Entities) )
        table.insert( RandomEntities, ent )
    end

    return RandomEntities
end

function GameScript:SecondStage(Entities, State)
    for _, ent in ipairs( Entities ) do
        ent:SetState(State)
    end
end


--[[----------------------------
            Main Game
----------------------------]]--


function GameScript:FullyStartGame()
    local TimeReaction = math.max( self["TimeReaction"], 0.1 )
    local Increment = math.max( self["Increment"], 1 )
    local Delay = math.max( self["Delay"], 0.1 )

    self.MainTimer = self:CreateChronometer("Main")
    self.MainTimer:SetLoop(true)
    self.MainTimer:SetVariable({["Increment"] = Increment, Entities = self:GetAllEntities("Floor")})

    self.MainTimer:Wait(Delay)
    self.MainTimer:AddAction(function(Var)
        Var["Picked"] = self:FirstStage(Var["Increment"], Var["Entities"])

        self:SecondStage( Var["Picked"], 2 )
    end)

    self.MainTimer:Wait(TimeReaction)
    self.MainTimer:AddAction(function(Var)
        self:SecondStage( Var["Picked"], 0 )
    end)
    self.MainTimer:Start()

    if Minigames.Config["PlayMusic"] then
        self:PlayWorldSound( "sound/" .. Minigames.Config["BackgroundMusic"], LOOP_MUSIC )
    end

    self.FullyStarted = true
end

function GameScript:StartGame()
    self:TeleportPlayers(self:GetAllEntities("Floor"))

    self.BeginTimer = self:CreateChronometer("Begin")
    self.BeginTimer:SetLoop(7)
    self.BeginTimer:SetVariable({["Start"] = 0, ["Entities"] = self:GetAllEntities("Floor")})

    self.BeginTimer:AddAction(function(Var, SelfTimer)
        if ( Var["Start"] % 2 == 0 ) then
            self:SecondStage( Var["Entities"], 11 )
        else
            self:SecondStage( Var["Entities"], 1 )
        end

        if Var["Start"] == 6 then
            self:FullyStartGame()
        end

        Var["Start"] = Var["Start"] + 1
    end)
    self.BeginTimer:Wait(0.5)
    self.BeginTimer:Start()

    self:PlayGameStartSound()

    return Minigames.GameStart( self )
end

function GameScript:StopGame()
    self:RemoveChronometer("Begin")
    self:RemoveChronometer("Main")

    for _, ent in ipairs( self:GetAllEntities("Floor") ) do
        ent:SetState(1)
    end

    self.FullyStarted = false

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()
    local Result = false

    self.TimeReaction = self:GetOwnerConfig("TimeReaction")
    self.Increment = self:GetOwnerConfig("Increment")
    self.Delay = self:GetOwnerConfig("Delay")

    if self:IsActive() then
        Result = self:StopGame()
    else
        Result = self:StartGame()
    end

    return Result
end


function GameScript:SpawnGame( trace )

    --[[--------------------------------
            Initial Configuration
    --------------------------------]]--
    local SizeX = self:GetOwnerConfig("SizeX")
    local SizeY = self:GetOwnerConfig("SizeY")
    local Offset = self:GetOwnerConfig("Offset")

    --[[--------------------------------
              Initial Game Pos
    --------------------------------]]--
    local Pos = trace.HitPos + trace.HitNormal * self:GetOwnerConfig("Height")
    local PosOffset = Vector(
        math.Round( ( ( Offset + MainOffset ) * ( SizeX - 1 ) ) / 2, 0 ),
        math.Round( ( -( Offset + MainOffset ) * ( SizeY - 1 ) ) / 2, 0 ),
        0
    )
    Pos:Sub( PosOffset )

    --[[--------------------------------
              Creation of Game
    --------------------------------]]--

    --[[------------------------
              Plataforms
    ------------------------]]--
    for i = 0, SizeX - 1 do
        local square = self:CreateEntity("minigame_square", "Floor")
        square:SetPos( Pos + Vector( (Offset + MainOffset) * i, 0, 0 ) )
        square:SetState(1)
        square:Spawn()
        square.InitialPosition = square:GetPos()
        square.InitialAngles = square:GetAngles()

        for y = 1, SizeY - 1 do
            local g_square = self:CreateEntity("minigame_square", "Floor")
            g_square:SetPos( square:GetPos() + Vector(0, -( Offset + MainOffset ) * y ) )
            g_square:SetState(1)
            g_square:Spawn()
            g_square.InitialPosition = g_square:GetPos()
            g_square.InitialAngles = g_square:GetAngles()
        end
    end

    --[[------------------------
              Kill Box
    ------------------------]]--
    local KillBoxPos = trace.HitPos + trace.HitNormal * ( self:GetOwnerConfig("Height") + 3 ) - KillBoxHeight
    local KillBoxX = ( Offset + MainOffset - 1 ) * SizeX
    local KillBoxY = ( Offset + MainOffset - 1 ) * SizeY
    local KillBoxBounds = Vector( KillBoxX - ( KillBoxX / 2 ), -KillBoxY - ( -KillBoxY / 2 ), 1.5 ) + KillBoxOffset

    self:CreateTrigger(KillBoxPos + KillBoxBounds, KillBoxPos + -KillBoxBounds, Minigames.Enum.KILL_ONTOUCH)
    self:SpawnPlayZone()

    self.DefaultTeleportEntities = self:GetAllEntities("Floor")

    return true
end


--[[----------------------------
           Pre-Render
----------------------------]]--

function GameScript:UpdateBoxGame( trace, owner )
    local ClientGameScript = Minigames.GetOwnerGame( LocalPlayer() )

    local Offset = MainOffset + self:GetOwnerConfig("Offset")
    local SizeX = Offset * ( self:GetOwnerConfig("SizeX") ) - self:GetOwnerConfig("Offset")
    local SizeY = Offset * ( self:GetOwnerConfig("SizeY") ) - self:GetOwnerConfig("Offset")
    local HitPos = trace.HitPos + trace.HitNormal * ( self:GetOwnerConfig("Height") + 3 )

    local Bounds = Vector( SizeX - ( SizeX / 2 ), -SizeY - ( -SizeY / 2 ), 1.5 )
    local KillBox = Bounds + KillBoxOffset

    if
        ( not trace.Hit ) or
        ( IsValid( trace.Entity ) and trace.Entity:IsPlayer() ) or
        ( istable( ClientGameScript ) )
    then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    else
        hook.Add("PostDrawTranslucentRenderables", "Minigames.DrawBox", function()
            render.DrawWireframeBox( HitPos - KillBoxHeight, angle_zero, KillBox, -KillBox, RedColor, true )
            render.DrawWireframeBox( HitPos, angle_zero, Bounds, -Bounds, color_white, true )
        end)
    end
end


--[[----------------------------
            Spawn Game
----------------------------]]--

function GameScript:LeftClick( trace, owner, FirstTime )
    local Response = false

    if FirstTime then
        Response = self:SpawnGame( trace, owner )
    else
        if IsValid( trace.Entity ) and trace.Entity:IsPlayer() then
            Response = self:TogglePlayer( trace.Entity )
        end
    end

    return Response
end


function GameScript:RightClick( trace, owner )
    return self:ToggleGame()
end

function GameScript:Reload( trace )
    if SERVER then
        return self:Pause()
    end
end

function GameScript:Think( trace, owner )
    if CLIENT then
        self:UpdateBoxGame( trace )
    end
end

function GameScript:RollUp( trace )
    if CLIENT then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    end
end

Minigames.RegisterNewGame(GameScript)