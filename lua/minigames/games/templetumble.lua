--[[--------------------------------------------
                Example Minigame
--------------------------------------------]]--

local SmallSquares = 94.89968
local BigSquares = 142.352

-- local RampAngle = Angle(0, 0, 45)
local RampOffset = Vector(0, 90, 30)
local RockModel = "models/hunter/misc/sphere2x2.mdl"

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Temple Tumble")

GameScript:AddHeader("!gameconfig")

GameScript:AddConfig("RocksAmount", {
    min = 1,
    max = 5,
    def = 2
})

GameScript:AddHeader("!playzoneconfig")

GameScript:AddConfig("BigSquares", {
    def = false
})

GameScript:AddConfig("RampSize", {
    min = 2,
    max = 8,
    def = 2
})

GameScript:AddConfig("RampAngle", {
    min = 20,
    max = 80,
    def = 45
})

GameScript:AddConfig("Wide", {
    min = 1,
    max = 20,
    def = 5
})

GameScript:AddConfig("Offset", {
    min = 0,
    max = 100,
    def = 0
})

GameScript:AddConfig("Height", {
    min = 150,
    max = 2048,
    def = 200
})


--[[----------------------------
             Custom
----------------------------]]--

GameScript.RocksSpawnPos = {}


--[[----------------------------
        Trigger Events
----------------------------]]--

GameScript:AddHook( "PostPlayerDeath", "GetFallDamage" )

--[[----------------------------
          Main Functions
----------------------------]]--

function GameScript:StartGame()
    return Minigames.GameStart( self )
end

function GameScript:StopGame()
    self:RemoveAllPlayers(true)

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()
    local Result = false

    if self:IsActive() then

        Result = self:StopGame()
        self:SetActive(false)

    else

        Result = self:StartGame()
        self:SetActive(true)

    end

    return Result
end

function GameScript:SpawnGame( trace, owner )

    --[[--------------------------------
              Initial Prefabs
    --------------------------------]]--
    local UseBigSquares = self:GetOwnerConfig("BigSquares")
    local HeightOffset = self:GetOwnerConfig("Height")
    local RampSize = self:GetOwnerConfig("RampSize")
    local Offset = self:GetOwnerConfig("Offset")
    local Wide = self:GetOwnerConfig("Wide")

    local SquareSize = UseBigSquares and BigSquares or SmallSquares
    local SquareClass = UseBigSquares and "minigame_bigsquare" or "minigame_square"
    local RampAngle = Angle(0, 0, self:GetOwnerConfig("RampAngle"))

    local Pos = trace.HitPos + trace.HitNormal * HeightOffset
    local PosOffset = Vector(
        ( ( Offset + SquareSize ) * ( Wide - 1 ) ) / 2,
        0,
        0
    )

    Pos:Sub(PosOffset)

    for i = 0, Wide - 1 do
        square = self:CreateEntity(SquareClass)
        square:SetPos(Pos + Vector( (Offset + SquareSize) * i, 0, 0))
        square:Spawn()

        ramp = self:CreateEntity(SquareClass)
        ramp:SetPos( (Pos + RampOffset) + Vector( (Offset + SquareSize) * i, 0, 0) + RampOffset)
        ramp:SetAngles(RampAngle)
        ramp:Spawn()
        ramp:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

        for j = 1, RampSize - 1 do
            subramp = self:CreateEntity(SquareClass)
            subramp:SetPos( ramp:GetPos() + ( ramp:GetRight() * -j * SquareSize ) )
            subramp:SetAngles(RampAngle)
            subramp:Spawn()
            subramp:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

            if ( j == RampSize - 1 ) then
                table.insert(self.RocksSpawnPos, subramp:GetPos() + Vector(0, 0, 80))
            end
        end
    end

    self:SpawnPlayZone()

    self.DefaultTeleportEntities = self:GetEntities(true)

    return true
end

function GameScript:RenderGame(trace)

end

--[[----------------------------
        Action Functions
----------------------------]]--

function GameScript:LeftClick( trace, owner, FirstTime )
    local Result = true

    if FirstTime then
        Result = self:SpawnGame( trace )
    else
        if IsValid( trace.Entity ) and trace.Entity:IsPlayer() then
            Result = self:TogglePlayer( trace.Entity )
        end
    end

    return Result
end

function GameScript:RightClick( trace, owner )

end

function GameScript:Reload( trace, owner )

end

function GameScript:Think( trace, owner )
    if CLIENT then
        self:RenderGame(trace)
    end
end

function GameScript:Deploy( trace, owner )

end

function GameScript:RollUp( trace, owner )

end

-- Minigames.RegisterNewGame(GameScript)