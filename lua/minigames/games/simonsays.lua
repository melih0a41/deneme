--[[--------------------------------------------
                    Simon Says
--------------------------------------------]]--

local MainOffset = 94.95968

local RedColor = Color(255, 0, 0)

local FakeOffset = 305
local FakeBoundsX = 142.849998
local FakeBoundsY = 5.3625
local FakeHeight = Vector(0, 0, FakeBoundsX + 4)
local FakeScreenBounds = Vector( FakeBoundsX / 2, -FakeBoundsX / 2, FakeBoundsY )

local KillBoxOffset = Vector(300, -300, 0)
local KillBoxHeight = Vector(0, 0, 60)

local NorthVec = Vector( 0, 200, 150 )
local SouthVec = Vector( 0, -200, 150 )
local EastVec = Vector( 200, 0, 150 )
local WestVec = Vector( -200, 0, 150 )

local AngY = Angle(90, 90, 0)
local AngX = Angle(90, 180, 0)

local LOOP_MUSIC = true

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Simon Says")

GameScript:AddHeader("!gameconfig")

GameScript:AddConfig("SameColors", {
    def = true
})

GameScript:AddConfig("AmountColors", {
    min = 2,
    max = 7,
    def = 4
})

GameScript:AddConfig("TimeReaction", {
    min = 0.1,
    max = 2,
    dec = 2,
    def = 0.5
})

GameScript:AddConfig("SubstractTimeReaction", {
    min = 0,
    max = 0.5,
    dec = 2,
    def = 0.06
})

GameScript:AddConfig("Delay", {
    min = 0.1,
    max = 6,
    dec = 1,
    def = 2.4
})

GameScript:AddConfig("SubstractTime", {
    min = 0,
    max = 0.6,
    dec = 2,
    def = 0.15
})

GameScript:AddHeader("!playzoneconfig")

GameScript:AddConfig("SizeX", {
    min = 4,
    max = 20,
    def = 5
})

GameScript:AddConfig("SizeY", {
    min = 4,
    max = 20,
    def = 5
})

GameScript:AddConfig("Offset", {
    min = 0,
    max = 200,
    def = 50,
    dec = 1
})

GameScript:AddConfig("Height", {
    min = 150,
    max = 2048,
    def = 150
})

GameScript:ListenToConfig("SameColors", function(self, NewVal)
    self.AmountColors = NewVal
    self:ShuffleColors()
end)


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
           Variables
----------------------------]]--

GameScript.TeleportOffset = Vector(0, 0, 20)

GameScript:AddNewVar("GamePaused", "bool", false)

function GameScript:Pause()
    if not self:IsActive() then return false end

    local State = self:ToggleGamePaused()

    if self.MainTimer then
        self.MainTimer:Pause(State)
    end

    if self.BeginTimer then
        self.BeginTimer:Pause(State)
    end

    return true
end

--[[--------------------------------
          Squares Management
--------------------------------]]--

function GameScript:ShuffleColors()
    local AmountColors = self.AmountColors or self:GetOwnerConfig("AmountColors")
    local AllEntities = self:GetAllEntities("Floor")

    local ColorPerSquare = math.floor( #AllEntities / AmountColors )
    self.EntitiesColored = {}

    for i = 1, AmountColors do
        self.EntitiesColored[i] = {}

        for j = 1, ColorPerSquare do
            local Square = table.remove( AllEntities, math.random( #AllEntities ) )
            table.insert( self.EntitiesColored[i], Square )
        end
    end

    local Rest = #AllEntities
    for i = 1, Rest do
        local Square = table.remove( AllEntities, math.random( #AllEntities ) )
        table.insert( self.EntitiesColored[math.random( #self.EntitiesColored )], Square )
    end

    for NewColor, Entities in pairs( self.EntitiesColored ) do
        for _, Square in ipairs( Entities ) do
            Square:SetState(NewColor)
        end
    end
end

function GameScript:DissapearSquares( state )
    for NewColor, Entities in pairs( self.EntitiesColored ) do
        if ( NewColor == state ) then continue end

        for _, Square in ipairs( Entities ) do
            Square:SetState(0)
        end
    end
end

function GameScript:ResetSquares()
    if self.SameColors then
        for NewColor, Entities in pairs( self.EntitiesColored ) do
            for _, Square in ipairs( Entities ) do
                Square:SetState(NewColor)
            end
        end
    else
        self:ShuffleColors()
    end
end


--[[--------------------------------
          Minigame Creation
--------------------------------]]--

function GameScript:SpawnGame( trace )

    --[[--------------------------------
            Initial Configuration
    --------------------------------]]--
    local SizeX = self:GetOwnerConfig("SizeX")
    local SizeY = self:GetOwnerConfig("SizeY")
    local Offset = self:GetOwnerConfig("Offset")
    local Height = self:GetOwnerConfig("Height")


    --[[--------------------------------
              Initial Game Pos
    --------------------------------]]--
    local CenterPos = trace.HitPos + trace.HitNormal * Height
    local PosOffset = Vector(
        math.Round( ( ( Offset + MainOffset ) * ( SizeX - 1 ) ) / 2, 0 ),
        math.Round( ( -( Offset + MainOffset ) * ( SizeY - 1 ) ) / 2, 0 ),
        0
    )
    local Pos = CenterPos - PosOffset

    local UpperRight = vector_origin
    local UpperLeft = vector_origin
    local LowerRight = vector_origin
    local LowerLeft = vector_origin

    --[[------------------------
                Floor
    ------------------------]]--
    for X = 0, SizeX - 1 do
        local SquareX = self:CreateEntity("minigame_square", "Floor")
        SquareX:SetPos( Pos + Vector( (Offset + MainOffset) * X, 0, 0 ) )
        SquareX:Spawn()

        if X == 0 then
            UpperLeft = SquareX:GetPos()
        elseif X == SizeX - 1 then
            UpperRight = SquareX:GetPos()
        end

        for Y = 1, SizeY - 1 do
            local SquareY = self:CreateEntity("minigame_square", "Floor")
            SquareY:SetPos( SquareX:GetPos() + Vector(0, -( Offset + MainOffset ) * Y ) )
            SquareY:Spawn()

            if X == 0 then
                LowerLeft = SquareY:GetPos()
            elseif X == SizeX - 1 then
                LowerRight = SquareY:GetPos()
            end
        end
    end

    self:ShuffleColors()

    --[[------------------------
            Screen Colors
    ------------------------]]--
    local NorthScreen = self:CreateEntity("minigame_bigsquare", "Screens")
    NorthScreen:SetPos( LerpVector( 0.5, UpperLeft, UpperRight ) + NorthVec )
    NorthScreen:SetAngles( AngY )
    NorthScreen:Spawn()

    local SouthScreen = self:CreateEntity("minigame_bigsquare", "Screens")
    SouthScreen:SetPos( LerpVector( 0.5, LowerLeft, LowerRight ) + SouthVec )
    SouthScreen:SetAngles( AngY )
    SouthScreen:Spawn()

    local EastScreen = self:CreateEntity("minigame_bigsquare", "Screens")
    EastScreen:SetPos( LerpVector( 0.5, UpperRight, LowerRight ) + EastVec )
    EastScreen:SetAngles( AngX )
    EastScreen:Spawn()

    local WestScreen = self:CreateEntity("minigame_bigsquare", "Screens")
    WestScreen:SetPos( LerpVector( 0.5, UpperLeft, LowerLeft ) + WestVec )
    WestScreen:SetAngles( AngX )
    WestScreen:Spawn()

    for _, screens in ipairs( self:GetAllEntities("Screens") ) do
        screens:SetState(-2)
    end

    --[[------------------------
              Kill Box
    ------------------------]]--
    local KillBoxPos = trace.HitPos + trace.HitNormal * ( Height + 3 ) - KillBoxHeight
    local KillBoxX = ( Offset + MainOffset - 1 ) * SizeX
    local KillBoxY = ( Offset + MainOffset - 1 ) * SizeY
    local KillBoxBounds = Vector( KillBoxX - ( KillBoxX / 2 ), -KillBoxY - ( -KillBoxY / 2 ), 1.5 ) + KillBoxOffset

    self:CreateTrigger(KillBoxPos + KillBoxBounds, KillBoxPos + -KillBoxBounds, Minigames.Enum.KILL_ONTOUCH)
    self:SpawnPlayZone()

    self.DefaultTeleportEntities = self:GetAllEntities("Floor")

    return true
end


--[[--------------------------------
        Minigame Management
--------------------------------]]--

function GameScript:FullyStartGame()
    local SubstractTimeReaction = self.SubstractTimeReaction
    local SubstractTime = self.SubstractTime
    local TimeReaction = self.TimeReaction
    local AmountColors = self.AmountColors
    local Delay = self.Delay

    local MainTimer = self:CreateChronometer("Main")
    MainTimer:SetLoop(true)
    MainTimer:SetVariable({["RandomColor"] = -1, ["Screens"] = self:GetAllEntities("Screens")})

    MainTimer:Wait(Delay, function(v) return math.max(v - SubstractTime, 0.1) end)
    MainTimer:AddAction(function(var)
        var["RandomColor"] = math.random( AmountColors )

        for _, screens in ipairs( self:GetAllEntities("Screens") ) do
            screens:SetState(var["RandomColor"])
        end
    end)

    MainTimer:Wait(TimeReaction, function(v) return math.max(v - SubstractTimeReaction, 0.1) end)
    MainTimer:AddAction(function(var)
        self:DissapearSquares(var["RandomColor"])
    end)
    MainTimer:Wait(0.8)
    MainTimer:AddAction(function(var)
        self:ResetSquares()

        for _, screens in ipairs( self:GetAllEntities("Screens") ) do
            screens:SetState(-2)
        end
    end)
    MainTimer:Start()

    if Minigames.Config["PlayMusic"] then
        self:PlayWorldSound( "sound/" .. Minigames.Config["BackgroundMusic"], LOOP_MUSIC )
    end

    self.FullyStarted = true
end

function GameScript:StartGame()
    self:TeleportPlayers(self:GetAllEntities("Floor"))
    self:ShuffleColors()

    local Players = self:GetPlayers(true)
    for _, ply in ipairs( Players ) do
        ply:SetLocalVelocity( vector_origin )
    end

    local BeginTimer = self:CreateChronometer("Begin")
    BeginTimer:SetLoop(8)
    BeginTimer:SetVariable({["Count"] = 1})

    BeginTimer:AddAction(function(Var)
        if Var.Count % 2 == 0 then
            for _, ent in ipairs( self:GetAllEntities("Screens") ) do
                ent:SetState(-12)
            end
        else
            for _, ent in ipairs( self:GetAllEntities("Screens") ) do
                ent:SetState(-2)
            end
        end

        if Var.Count == 8 then
            self:FullyStartGame()
        end

        Var.Count = Var.Count + 1
    end)
    BeginTimer:Wait(3.5 / 8)
    BeginTimer:Start()

    self:PlayGameStartSound()
    return Minigames.GameStart( self:GetOwner() )
end

function GameScript:StopGame()
    self:RemoveChronometer("Begin")
    self:RemoveChronometer("Main")

    self:ResetSquares()
    for _, Screen in ipairs( self:GetAllEntities("Screens") ) do
        Screen:SetState(-2)
    end

    return Minigames.GameStop( self:GetOwner() )
end

function GameScript:ToggleGame()
    local Result = false

    self.SubstractTimeReaction = self:GetOwnerConfig("SubstractTimeReaction")
    self.SubstractTime = self:GetOwnerConfig("SubstractTime")
    self.TimeReaction = self:GetOwnerConfig("TimeReaction")
    self.AmountColors = self:GetOwnerConfig("AmountColors")
    self.SameColors = self:GetOwnerConfig("SameColors")
    self.Delay = self:GetOwnerConfig("Delay")

    if self:IsActive() then
        Result = self:StopGame()
    else
        Result = self:StartGame()
    end

    return Result
end

--[[----------------------------
           Pre-Render
----------------------------]]--

function GameScript:UpdateBoxGame( trace )
    if Minigames.GetOwnerGame( LocalPlayer() ) then hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox") return end

    local Offset = MainOffset + self:GetOwnerConfig("Offset")
    local SizeX = Offset * ( self:GetOwnerConfig("SizeX") ) - self:GetOwnerConfig("Offset")
    local SizeY = Offset * ( self:GetOwnerConfig("SizeY") ) - self:GetOwnerConfig("Offset")
    local HitPos = trace.HitPos + trace.HitNormal * ( self:GetOwnerConfig("Height") + 3 )

    local Bounds = Vector( SizeX - ( SizeX / 2 ), -SizeY - ( -SizeY / 2 ), 1.5 )
    local KillBox = Bounds + KillBoxOffset

    local TopLevel = HitPos + FakeHeight

    -- Dependiendo del tamaño de la variable SizeX, alejar la pantalla norte
    local NorthScreen = LerpVector( 0.5, TopLevel + NorthVec, TopLevel - NorthVec + Vector( 0, -SizeY - FakeOffset, 0 ) )
    local SouthScreen = LerpVector( 0.5, TopLevel + SouthVec, TopLevel - SouthVec + Vector( 0, SizeY + FakeOffset, 0 ) )
    local WestScreen = LerpVector( 0.5, TopLevel + WestVec, TopLevel - WestVec + Vector( SizeX + FakeOffset, 0, 0 ) )
    local EastScreen = LerpVector( 0.5, TopLevel + EastVec, TopLevel - EastVec + Vector( -SizeX - FakeOffset, 0, 0 ) )


    if
        ( not trace.Hit ) or
        ( IsValid( trace.Entity ) and trace.Entity:IsPlayer() )
    then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    else
        hook.Add("PostDrawTranslucentRenderables", "Minigames.DrawBox", function()
            render.DrawWireframeBox( HitPos - KillBoxHeight, angle_zero, KillBox, -KillBox, RedColor, true )
            render.DrawWireframeBox( HitPos, angle_zero, Bounds, -Bounds, color_white, true )
            render.DrawWireframeBox( WestScreen, AngX, FakeScreenBounds, -FakeScreenBounds, color_white, true )
            render.DrawWireframeBox( EastScreen, AngX, FakeScreenBounds, -FakeScreenBounds, color_white, true )
            render.DrawWireframeBox( NorthScreen, AngY, FakeScreenBounds, -FakeScreenBounds, color_white, true )
            render.DrawWireframeBox( SouthScreen, AngY, FakeScreenBounds, -FakeScreenBounds, color_white, true )
        end)
    end
end

--[[----------------------------
          Main Functions
----------------------------]]--

function GameScript:LeftClick( trace, owner, FirstTime )
    local Response = false

    if FirstTime then
        Response = self:SpawnGame( trace, owner )
    else
        if IsEntity( trace.Entity ) and trace.Entity:IsPlayer() then
            Response = self:TogglePlayer( trace.Entity )
        end
    end

    return Response
end

function GameScript:RightClick( trace, owner )
    return self:ToggleGame()
end

function GameScript:Reload( trace, owner )
    if SERVER then
        self:Pause()
    end
end

function GameScript:Think( trace, owner )
    if CLIENT then
        self:UpdateBoxGame( trace )
    end
end

function GameScript:Deploy( trace, owner )

end

function GameScript:RollUp( trace )
    if CLIENT then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    end
end

Minigames.RegisterNewGame(GameScript)