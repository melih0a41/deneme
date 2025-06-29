--[[--------------------------------------------
            Red Light Green Light
--------------------------------------------]]--

local MainOffset = 142.3

local ColorRed = Color(255, 0, 0)
local ColorGreen = Color(0, 255, 0)
local KillBoxHeight = Vector(0, 0, 60)
local KillBoxHeightMax = Vector(0, 0, -120)
local KillBoxOffset = Vector(500, -500, 0)
local WinningBoxHeight = Vector(0, 0, 140)
local LookingForward = Angle(0, 90, 0)

local ScreenOffset = Vector(0, 100, 150)
local ScreenAngle = Angle(0, 0, 90)

local GhostBoxOffset = Vector(0, 0, -11)

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Cigarrillo 43")

GameScript:AddHeader("!gameconfig")
GameScript:AddConfig("Safetime", {
    min = 0.1,
    max = 2,
    dec = 1,
    def = 0.4
})

GameScript:AddHeader("!playzoneconfig")
GameScript:AddConfig("SizeX", {
    min = 2,
    max = 8,
    def = 4
})

GameScript:AddConfig("SizeY", {
    min = 4,
    max = 28,
    def = 8
})
GameScript:AddConfig("Height", {
    min = 150,
    max = 2048,
    def = 150
})

GameScript.KeyPressKill = {
    [IN_BACK] = true,
    [IN_FORWARD] = true,
    [IN_MOVELEFT] = true,
    [IN_MOVERIGHT] = true,
}

--[[----------------------------
        Trigger Events
----------------------------]]--

GameScript:AddHook( "STOP_ONNOBODY PostPlayerDeath" )
GameScript:AddHook( "KILL_ONKEYPRESS KeyPress" )
GameScript:AddHook( "GetFallDamage" )

--[[----------------------------
          Game Events
----------------------------]]--

GameScript:AddNewVar("LookingBack", "bool", false)

function GameScript:SpawnGame( trace )

    --[[--------------------------------
            Initial Configuration
    --------------------------------]]--
    local SizeX = self:GetOwnerConfig("SizeX")
    local SizeY = self:GetOwnerConfig("SizeY")

    local WinningBoxMax, WinningBoxMin = vector_origin, vector_origin

    --[[--------------------------------
              Initial Game Pos
    --------------------------------]]--
    local Pos = trace.HitPos + ( trace.HitNormal * self:GetOwnerConfig("Height") )
    local PosOffset = Vector(
        math.Round( ( MainOffset * ( SizeX - 1 ) ) / 2, 0 ),
        math.Round( ( -MainOffset * ( SizeY - 1 ) ) / 2, 0 ),
        0
    )

    Pos:Sub( PosOffset )

    --[[--------------------------------
              Creation of Game
    --------------------------------]]--

    --[[------------------------
              Play Zone
    ------------------------]]--

    for i = 0, SizeX - 1 do
        local square = self:CreateEntity("minigame_bigsquare", "Floor")
        square:SetPos( Pos + Vector( MainOffset * i, 0, 0 ) )
        square:SetState(1)
        square:Spawn()

        local screen = self:CreateEntity("minigame_bigsquare", "Screen")
        screen:SetPos( square:GetPos() + ScreenOffset )
        screen:SetAngles( ScreenAngle )
        screen:SetState(2)
        screen:Spawn()

        if ( i == 0 ) then
            local FirstValue = square:GetModelBounds()
            WinningBoxMin = FirstValue + square:GetPos()

        elseif ( i == ( SizeX - 1 ) ) then
            local _, SecondValue = square:GetModelBounds()
            WinningBoxMax = SecondValue + square:GetPos() + WinningBoxHeight

        end

        for y = 1, SizeY - 1 do
            local g_square = self:CreateEntity("minigame_bigsquare", "Floor")
            g_square:SetPos( square:GetPos() + Vector(0, -MainOffset * y ) )
            g_square:SetState(-2)

            -- Last Line
            if ( y == ( SizeY - 1 ) ) then
                g_square:SetState(2)

                table.insert(self.DefaultTeleportEntities, g_square)

                if ( i == 0 ) then
                    self.StartPos = g_square:GetPos()["X"]
                    self.StartPosMin = g_square:GetPos()
                    self.StartPosMin["Z"] = self.StartPosMin["Z"] + 25

                elseif ( i == ( SizeX - 1 ) ) then
                    local ps = g_square:GetPos()

                    self.StartPos = Vector(self.StartPos, ps["Y"], ps["Z"] + 40)
                    self.StartPosMax = g_square:GetPos()
                    self.StartPosMax["Z"] = self.StartPosMax["Z"] + 25
                end
            end

            g_square:Spawn()
        end
    end

    --[[------------------------
              Kill Box
    ------------------------]]--
    local KillBoxPos = trace.HitPos + ( trace.HitNormal * self:GetOwnerConfig("Height") ) - KillBoxHeight
    local KillBoxX = ( MainOffset - 1 ) * SizeX
    local KillBoxY = ( MainOffset - 1 ) * SizeY
    local KillBoxBounds = Vector( KillBoxX - ( KillBoxX / 2 ), -KillBoxY - ( -( KillBoxY * 2 ) / 2 ), 1.5 ) + KillBoxOffset

    self.KillZone = self:CreateTrigger(KillBoxPos + KillBoxBounds, KillBoxPos + -KillBoxBounds, Minigames.Enum["KILL_ONTOUCH"])
    self.WinZone = self:CreateTrigger(WinningBoxMin, WinningBoxMax, Minigames.Enum["WIN_ONTOUCHTRIGGER"])
    self:SpawnPlayZone()

    self.TeleportOffset = Vector(0, 0, 50)
    self.DefaultTeleportEntities = self:GetAllEntities("Floor")

    return true
end

--[[----------------------------
            Game State
----------------------------]]--

function GameScript:StartGame()

    --[[------------------------
            Settings
    ------------------------]]--
    local Players = self:GetPlayers(true)

    if Minigames.Config["TeleportToGame"] and ( not table.IsEmpty( Players ) ) then
        local pos = 1 / #Players
        for i, ply in ipairs( Players ) do
            ply:SetNWInt( "Minigames.LastCollision", ply:GetCollisionGroup() )
            ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
            ply:SetEyeAngles( LookingForward )

            ply:SetVelocity( ply:GetVelocity() * -1 )
            ply:Freeze( true )

            ply:SetPos( LerpVector( i * pos, self.StartPosMin, self.StartPosMax ) )
        end
    end

    --[[------------------------
             PostGame
    ------------------------]]--
    self.TimerPreGame = self:CreateTimer("PreGame")
    self.TimerPreGame:Wait(4)
    self.TimerPreGame:AddAction(function()
        local all = self:GetPlayers(true)
        table.insert(all, self:GetOwner())
        self:PlaySound(all, Minigames.Config["GreenLight"])

        for _, ply in ipairs( Players ) do
            ply:SetMoveType( MOVETYPE_WALK )
            ply:Freeze( false )
        end

        for _, screen in ipairs( self:GetAllEntities("Screen") ) do
            screen:SetState(1)
        end

        self.TimerPreGame:Stop()
    end)
    self.TimerPreGame:Start()

    self:PostPlayerDeath(function(ply)
        ply:SetCollisionGroup( ply:GetNWInt("Minigames.LastCollision", COLLISION_GROUP_PLAYER) )
    end)

    self:SetLookingBack(false)
    self:PlayGameStartSound()

    return Minigames.GameStart( self )
end

function GameScript:StopGame()
    self:RemoveTimer("PreGame")
    self:RemoveTimer("SafeTime")

    for _, ply in ipairs( self:GetPlayers(true) ) do
        ply:SetCollisionGroup( ply:GetNWInt("Minigames.LastCollision", COLLISION_GROUP_PLAYER) )
        ply:Freeze(false)
    end

    for _, screen in ipairs( self:GetAllEntities("Screen") ) do
        screen:SetState(2)
    end

    self:SetLookingBack(false)

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()
    local Result = false

    self.Safetime = self:GetOwnerConfig("Safetime")

    if self:IsActive() then
        Result = self:StopGame()
    else
        Result = self:StartGame()
    end

    return Result
end

function GameScript:ToggleRun()
    local LookingBack = self:IsLookingBack()

    local Players = self:GetPlayers(true)
    table.insert(Players, self:GetOwner())

    --[[------------------------
        Case: Early Start
    ------------------------]]--
    if ( self.TimerPreGame ~= nil and self.TimerPreGame:IsRunning() ) then
        self.TimerPreGame:Stop()
        self:PlaySound(Players, Minigames.Config["GreenLight"])

        for _, ply in ipairs( self:GetPlayers(true) ) do
            ply:Freeze( false )
        end

        for _, screen in ipairs( self:GetAllEntities("Screen") ) do
            screen:SetState(1)
        end

    --[[------------------------
        Case: Is Looking Back  OR  Early Safe Time
    ------------------------]]--
    elseif LookingBack or ( self.TimerSafeTime ~= nil and self.TimerSafeTime:IsRunning() ) then
        self:SetLookingBack(false)
        self.TimerSafeTime:Stop()
        self:PlaySound(Players, Minigames.Config["GreenLight"])

        for _, Screen in ipairs( self:GetAllEntities("Screen") ) do
            Screen:SetState(1)
        end

    --[[------------------------
        Case: Is not Looking Back
    ------------------------]]--
    else
        self:PlaySound(Players, Minigames.Config["RedLight"])

        for _, Screen in ipairs( self:GetAllEntities("Screen") ) do
            Screen:SetState(2)
        end

        if self.TimerSafeTime ~= nil then
            self:RemoveTimer("SafeTime")
        end

        self.TimerSafeTime = self:CreateTimer("SafeTime")
        self.TimerSafeTime:Wait( self.Safetime )
        self.TimerSafeTime:AddAction(function()
            self:SetLookingBack(true)
            local KillKeys = table.GetKeys( self.KeyPressKill )

            for _, ply in ipairs( self:GetPlayers(true) ) do
                for _, key in ipairs( KillKeys ) do
                    if ply:KeyDown( key ) then
                        ply:Kill()
                        break
                    end
                end
            end
        end)
        self.TimerSafeTime:Start()
    end

    return true
end

--[[----------------------------
        Pre-render Game
----------------------------]]--


function GameScript:PreRenderGame( trace, owner )
    local SizeX = MainOffset * self:GetOwnerConfig("SizeX")
    local SizeY = MainOffset * self:GetOwnerConfig("SizeY")
    local Height = self:GetOwnerConfig("Height")

    local VectorOrigin = trace.HitPos + ( trace.HitNormal * Height )
    local Bounds = Vector( SizeX - ( SizeX / 2 ), -SizeY - ( -SizeY / 2 ), 6 )

    local WinningBoxMin = VectorOrigin - ( Bounds + GhostBoxOffset )
    local WinningBoxMax = WinningBoxMin + Vector(SizeX, -MainOffset, 140)

    local KillBoxMax = Bounds + KillBoxOffset - KillBoxHeight
    local KillBoxMin = -KillBoxMax + KillBoxHeightMax


    if ( not trace.Hit or IsValid( trace.Entity ) and trace.Entity:IsPlayer() ) then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    else
        hook.Add("PostDrawTranslucentRenderables", "Minigames.DrawBox", function()
            render.DrawWireframeBox( VectorOrigin, angle_zero, KillBoxMax, KillBoxMin, ColorRed, true )
            render.DrawWireframeBox( VectorOrigin, angle_zero, Bounds, -Bounds, color_white, true )
            render.DrawWireframeBox( vector_up, angle_zero, WinningBoxMin, WinningBoxMax, ColorGreen, true )
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
        if IsValid( trace.Entity ) and trace.Entity:IsPlayer() then
            Response = self:TogglePlayer( trace.Entity )
        end
    end

    return Response
end


function GameScript:RightClick( trace, owner )
    return self:ToggleGame()
end


function GameScript:Reload( trace, owner )
    if CLIENT then return end

    local Result = false

    if self:IsActive() then
        Result = self:ToggleRun()
    end

    return Result
end

function GameScript:Think( trace, owner )
    if CLIENT then
        if Minigames.GetOwnerGame( LocalPlayer() ) then
            hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
        else
            self:PreRenderGame( trace )
        end
    end
end

function GameScript:RollUp( trace, owner )
    if CLIENT then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    end
end

Minigames.RegisterNewGame(GameScript)