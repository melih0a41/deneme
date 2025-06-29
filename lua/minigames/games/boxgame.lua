--[[--------------------------------------------
                    Box Game
--------------------------------------------]]--

local MainOffset = 142.3

local RedColor = Color(255, 0, 0)
local KillBoxHeight = Vector(0, 0, 60)
local KillBoxOffset = Vector(500, -500, 0)

local CeilingHeight = Vector(0, 0, 500)
local LOOP_MUSIC = true

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Box Game")
GameScript:AddHeader("!gameconfig")

GameScript:AddConfig("DelayBetweenDrops", {
    min = 0.5,
    max = 4,
    def = 2,
    dec = 1
})

GameScript:AddConfig("DropDelay", {
    min = 0.5,
    max = 5,
    def = 2,
    dec = 1
})

GameScript:AddConfig("DropReaction", {
    min = 0.1,
    max = 2.5,
    def = 0.2,
    dec = 2
})

GameScript:AddConfig("StartBoxes", {
    min = 0,
    max = 64,
    def = 3,
})

GameScript:AddConfig("MaxBoxes", {
    min = 1,
    max = 64,
    def = 3,
})

GameScript:AddConfig("AddMoreBoxes", {
    min = 0,
    max = 8,
    def = 1,
})

GameScript:AddHeader("!playzoneconfig")

GameScript:AddConfig("SizeX", {
    min = 2,
    max = 6,
    def = 4,
})

GameScript:AddConfig("SizeY", {
    min = 2,
    max = 6,
    def = 4,
})

GameScript:AddConfig("Height", {
    min = 150,
    max = 2048,
    def = 150
})

GameScript:AddConfig("Offset", {
    min = 0,
    max = 130,
    def = 25,
    dec = 1
})


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

GameScript:AddNewVar("Ceiling", "number", 0)

--[[----------------------------
          Box Game Logic
----------------------------]]--

-- Move Ceiling to Floor with math.ease.InExpo
local function LerpFunctionToMove(fraction, from, to)
    return Lerp( math.ease.OutBounce(fraction), from, to )
end

function GameScript:MoveCeilingToFloor(ceiling)
    local CeilingName = "Minigame.Ceiling." .. ceiling:EntIndex()

    local CeilingPos = ceiling:GetPos()
    local CeilingTarget = CeilingPos - CeilingHeight

    local StartTime = CurTime()

    if hook.GetTable()["Think"] and hook.GetTable()["Think"][CeilingName] then
        hook.Remove("Think", CeilingName)
        ceiling:SetPos( ceiling.OriginalPos )
        ceiling:SetState(0)
    end

    hook.Add("Think", CeilingName, function()
        if not IsValid(ceiling) then
            hook.Remove("Think", CeilingName)
            return
        end

        if not self:IsActive() then
            hook.Remove("Think", CeilingName)
            ceiling:SetPos( ceiling.OriginalPos )
            ceiling:SetState(0)
            return
        end

        local fraction = math.Clamp( ( CurTime() - StartTime ) / self.DropDelay - self.DropReaction, 0, 1 )
        local NewPos = LerpFunctionToMove(fraction, CeilingPos, CeilingTarget)

        ceiling:SetPos(NewPos)

        if fraction == 1 then
            hook.Remove("Think", CeilingName)

            if IsValid(ceiling) then
                ceiling:SetPos( ceiling.OriginalPos )
                ceiling:SetState(0)
            end
        end
    end)
end


function GameScript:SelectRandomBoxSpawn(opt)
    local AmountBoxes = opt or self.AmountBoxes
    local AllBoxes = table.Copy( self:GetAllEntities("CeilingBoxes") )
    local Boxes = {}

    for i = 1, AmountBoxes do
        local BoxPos = math.random(1, #AllBoxes)
        local Box = table.remove(AllBoxes, BoxPos)
        table.insert(Boxes, Box)
    end

    for _, Box in ipairs(Boxes) do
        Box:SetState(2)

        self:MoveCeilingToFloor(Box)
    end
end


--[[----------------------------
        Game Constructor
----------------------------]]--

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
              Base Floor
    ------------------------]]--
    for i = 0, SizeX - 1 do
        local square = self:CreateEntity("minigame_bigsquare", "Floor")
        square:SetPos( Pos + Vector( (Offset + MainOffset) * i, 0, 0 ) )
        square:SetState(1)
        square:Spawn()

        local CeilingBoxes = self:CreateEntity("minigame_boxgame", "CeilingBoxes")
        CeilingBoxes:SetPos( Pos + Vector( (Offset + MainOffset) * i, 0, 0 ) + CeilingHeight )
        CeilingBoxes:SetState(0)
        CeilingBoxes:Spawn()

        CeilingBoxes.OriginalPos = CeilingBoxes:GetPos()

        for y = 1, SizeY - 1 do
            local g_square = self:CreateEntity("minigame_bigsquare", "Floor")
            g_square:SetPos( square:GetPos() + Vector(0, -( Offset + MainOffset ) * y ) )
            g_square:Spawn()
            g_square:SetState(1)

            local g_CeilingBoxes = self:CreateEntity("minigame_boxgame", "CeilingBoxes")
            g_CeilingBoxes:SetPos( CeilingBoxes:GetPos() + Vector(0, -( Offset + MainOffset ) * y ) )
            g_CeilingBoxes:Spawn()
            g_CeilingBoxes:SetState(0)

            g_CeilingBoxes.OriginalPos = g_CeilingBoxes:GetPos()
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
          Main Functions
----------------------------]]--

function GameScript:BoxGame()
    local DelayBetweenDrops = self.DelayBetweenDrops
    local PostDelay = self.DropDelay + self.DropReaction
    local AddMoreBoxes = self.AddMoreBoxes
    local StartBoxes = self.StartBoxes
    local MaxBoxes = self.MaxBoxes

    self.MainTimer = self:CreateTimer("Main")
    self.MainTimer:SetLoop(true)
    self.MainTimer:SetVariable({
        ["Amount"] = StartBoxes
    })

    self.MainTimer:Wait(DelayBetweenDrops)
    self.MainTimer:AddAction(function(Var)
        Var.Amount = math.min(Var.Amount + AddMoreBoxes, MaxBoxes)

        self:SelectRandomBoxSpawn(Var.Amount)
    end)
    self.MainTimer:Wait(PostDelay)
    self.MainTimer:Start()

    if Minigames.Config["PlayMusic"] then
        self:PlayWorldSound( "sound/" .. Minigames.Config["BackgroundMusic"], LOOP_MUSIC )
    end
end


function GameScript:StartGame()
    self:TeleportPlayers(self:GetAllEntities("Floor"))

    self.BeginTimer = self:CreateTimer("Begin")
    self.BeginTimer:SetLoop(7)
    self.BeginTimer:SetVariable({
        ["Start"] = 0,
        ["Entities"] = self:GetAllEntities("Floor")
    })

    self.BeginTimer:AddAction(function(Var, SelfTimer)
        if ( Var["Start"] % 2 == 0 ) then
            for _, ent in ipairs( Var["Entities"] ) do
                ent:SetState(11)
            end
        else
            for _, ent in ipairs( Var["Entities"] ) do
                ent:SetState(1)
            end
        end

        if Var["Start"] == 6 then
            self:BoxGame()
        end

        Var["Start"] = Var["Start"] + 1
    end)
    self.BeginTimer:Wait(0.5)
    self.BeginTimer:Start()

    self:PlayGameStartSound()

    return Minigames.GameStart( self )
end

function GameScript:StopGame()
    self:RemoveTimer("Begin")
    self:RemoveTimer("Main")

    for _, ent in ipairs( self:GetAllEntities("Floor") ) do
        ent:SetState(1)
    end

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()
    local Result = false

    -- Time Config
    self.DelayBetweenDrops = self:GetOwnerConfig("DelayBetweenDrops")
    self.DropReaction = self:GetOwnerConfig("DropReaction")
    self.DropDelay = self:GetOwnerConfig("DropDelay")

    -- Box Config
    self.AddMoreBoxes = self:GetOwnerConfig("AddMoreBoxes")
    self.StartBoxes = self:GetOwnerConfig("StartBoxes")
    self.MaxBoxes = self:GetOwnerConfig("MaxBoxes")

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

if CLIENT then

local CachePos = vector_origin
local CacheBounds = vector_origin

function GameScript:CeilingBoxPreview()
    hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    hook.Add("PostDrawTranslucentRenderables", "Minigames.DrawCeilingBox", function()
        render.DrawWireframeBox( CachePos, angle_zero, CacheBounds, -CacheBounds, color_white, true )
    end)
end

function GameScript:UpdateBoxGame( trace )
    if Minigames.GetOwnerGame( LocalPlayer() ) then self:CeilingBoxPreview() return end

    local Offset = MainOffset + self:GetOwnerConfig("Offset")
    local SizeX = Offset * ( self:GetOwnerConfig("SizeX") ) - self:GetOwnerConfig("Offset")
    local SizeY = Offset * ( self:GetOwnerConfig("SizeY") ) - self:GetOwnerConfig("Offset")
    local HitPos = trace.HitPos + trace.HitNormal * ( self:GetOwnerConfig("Height") )

    local Bounds = Vector( SizeX - ( SizeX / 2 ), -SizeY - ( -SizeY / 2 ), 6.4 )
    local KillBox = Bounds + KillBoxOffset

    if ( CachePos ~= HitPos ) or ( CacheBounds ~= Bounds ) then
        CachePos = HitPos + CeilingHeight
        CacheBounds = Bounds
        self:CeilingBoxPreview()
    end

    if
        ( not trace.Hit ) or
        ( IsValid( trace.Entity ) and trace.Entity:IsPlayer() )
    then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
    else
        hook.Add("PostDrawTranslucentRenderables", "Minigames.DrawBox", function()
            render.DrawWireframeBox( HitPos - KillBoxHeight, angle_zero, KillBox, -KillBox, RedColor, true )
            render.DrawWireframeBox( HitPos, angle_zero, Bounds, -Bounds, color_white, true )
            render.DrawWireframeBox( HitPos + CeilingHeight, angle_zero, Bounds, -Bounds, color_white, true )
        end)
    end
end

end



--[[----------------------------
        Action Functions
----------------------------]]--

function GameScript:LeftClick( trace, owner, FirstTime )
    local Result = true

    if FirstTime then
        Result = self:SpawnGame( trace, owner )
    else
        if IsValid( trace.Entity ) and trace.Entity:IsPlayer() then
            Result = self:TogglePlayer( trace.Entity )
        end
    end

    return Result
end

function GameScript:RightClick( trace, owner )
    return self:ToggleGame()
end

function GameScript:Reload( trace, owner )

end

function GameScript:Think( trace, owner )
    if CLIENT then
        self:UpdateBoxGame( trace, owner )
    end
end

function GameScript:RollUp( trace, owner )
    if CLIENT then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawBox")
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawCeilingBox")
    end
end

Minigames.RegisterNewGame(GameScript)