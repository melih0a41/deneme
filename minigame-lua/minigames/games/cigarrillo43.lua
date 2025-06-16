--[[--------------------------------------------
            Red Light Green Light - FIXED
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

GameScript:SetGameName("Red Light Green Light")

GameScript:AddHeader("!gameconfig")
GameScript:AddConfig("Safetime", {
    min = 0.1,
    max = 1,
    dec = 1,
    def = 0.3
})

GameScript:AddConfig("GreenLightTime", {
    min = 0.5,
    max = 4,
    dec = 1,
    def = 2
})

GameScript:AddConfig("RedLightTime", {
    min = 1,
    max = 5,
    dec = 1,
    def = 2.5
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
GameScript:AddNewVar("CurrentPhase", "string", "green") -- "green" veya "red"

function GameScript:TogglePhase()
    local currentPhase = self:GetCurrentPhase()
    
    print("[DEBUG] Faz değişimi: " .. currentPhase .. " -> " .. (currentPhase == "green" and "red" or "green"))
    
    if currentPhase == "green" then
        -- Green Light'tan Red Light'a geç
        self:SetCurrentPhase("red")
        self:SetLookingBack(true)
        
        -- Ekranları kırmızı yap
        for _, screen in ipairs(self:GetAllEntities("Screen")) do
            screen:SetState(2) -- Kırmızı
        end
        
        -- Red Light sesini çal
        local Players = self:GetPlayers(true)
        table.insert(Players, self:GetOwner())
        self:PlaySound(Players, Minigames.Config["RedLight"])
        
        -- Red Light timer başlat
        self:CreateRedLightTimer()
        
    else
        -- Red Light'tan Green Light'a geç
        self:SetCurrentPhase("green")
        self:SetLookingBack(false)
        
        -- Ekranları yeşil yap
        for _, screen in ipairs(self:GetAllEntities("Screen")) do
            screen:SetState(1) -- Yeşil
        end
        
        -- Green Light sesini çal
        local Players = self:GetPlayers(true)
        table.insert(Players, self:GetOwner())
        self:PlaySound(Players, Minigames.Config["GreenLight"])
        
        -- Green Light timer başlat
        self:CreateGreenLightTimer()
    end
end

function GameScript:CreateGreenLightTimer()
    self:RemoveChronometer("PhaseTimer")
    
    self.PhaseTimer = self:CreateChronometer("PhaseTimer")
    self.PhaseTimer:Wait(self.GreenLightTime)
    self.PhaseTimer:AddAction(function()
        if self:IsActive() then
            self:TogglePhase() -- Green'den Red'e geç
        end
    end)
    self.PhaseTimer:Start()
end

function GameScript:CreateRedLightTimer()
    -- Önce güvenlik süresi ver
    self:RemoveChronometer("SafeTimer")
    self.SafeTimer = self:CreateChronometer("SafeTimer")
    self.SafeTimer:Wait(self.Safetime)
    self.SafeTimer:AddAction(function()
        -- Hareket eden oyuncuları öldür
        if self:IsActive() and self:IsLookingBack() then
            local KillKeys = table.GetKeys(self.KeyPressKill)
            for _, ply in ipairs(self:GetPlayers(true)) do
                for _, key in ipairs(KillKeys) do
                    if ply:KeyDown(key) then
                        ply:Kill()
                        break
                    end
                end
            end
        end
        
        -- Güvenlik süresi bittikten sonra Red Light timer başlat
        self:RemoveChronometer("PhaseTimer")
        self.PhaseTimer = self:CreateChronometer("PhaseTimer")
        self.PhaseTimer:Wait(self.RedLightTime)
        self.PhaseTimer:AddAction(function()
            if self:IsActive() then
                self:TogglePhase() -- Red'den Green'e geç
            end
        end)
        self.PhaseTimer:Start()
    end)
    self.SafeTimer:Start()
end

function GameScript:SpawnGame( trace )
    --[[--------------------------------
            Initial Configuration
    --------------------------------]]--
    self.SizeX = self:GetOwnerConfig("SizeX")
    self.SizeY = self:GetOwnerConfig("SizeY")

    local SizeX = self.SizeX
    local SizeY = self.SizeY

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
        screen:SetState(1) -- Başlangıçta yeşil
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

            -- Last Line (Başlangıç çizgisi)
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
    -- Konfigürasyonu al
    self.Safetime = self:GetOwnerConfig("Safetime")
    self.GreenLightTime = self:GetOwnerConfig("GreenLightTime")
    self.RedLightTime = self:GetOwnerConfig("RedLightTime")

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

    -- Başlangıç durumunu ayarla
    self:SetCurrentPhase("green")
    self:SetLookingBack(false)

    --[[------------------------
             PostGame
    ------------------------]]--
    self.TimerPreGame = self:CreateChronometer("PreGame")
    self.TimerPreGame:Wait(4)
    self.TimerPreGame:AddAction(function()
        -- Oyuncuları serbest bırak
        for _, ply in ipairs( Players ) do
            ply:SetMoveType( MOVETYPE_WALK )
            ply:Freeze( false )
        end

        -- İlk Green Light'ı başlat
        self:CreateGreenLightTimer()
        
        self.TimerPreGame:Stop()
    end)
    self.TimerPreGame:Start()

    self:PostPlayerDeath(function(ply)
        ply:SetCollisionGroup( ply:GetNWInt("Minigames.LastCollision", COLLISION_GROUP_PLAYER) )
    end)

    self:PlayGameStartSound()

    return Minigames.GameStart( self )
end

function GameScript:StopGame()
    self:RemoveChronometer("PreGame")
    self:RemoveChronometer("PhaseTimer")
    self:RemoveChronometer("SafeTimer")

    for _, ply in ipairs( self:GetPlayers(true) ) do
        ply:SetCollisionGroup( ply:GetNWInt("Minigames.LastCollision", COLLISION_GROUP_PLAYER) )
        ply:Freeze(false)
    end

    for _, screen in ipairs( self:GetAllEntities("Screen") ) do
        screen:SetState(1) -- Yeşil'e dön
    end

    self:SetLookingBack(false)
    self:SetCurrentPhase("green")

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()
    local Result = false

    if self:IsActive() then
        Result = self:StopGame()
    else
        Result = self:StartGame()
    end

    return Result
end

function GameScript:ToggleRun()
    -- Manuel kontrol için (R tuşu)
    if self:IsActive() then
        self:TogglePhase()
        return true
    end
    return false
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