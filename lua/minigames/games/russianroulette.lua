--[[--------------------------------------------
                Russian Roulette
--------------------------------------------]]--

local TableModel = "models/props_c17/FurnitureTable001a.mdl"
local TableOffsetPos = Vector(0, 0, 18)

local WeaponModel = "models/weapons/w_357.mdl"
local WeaponOffsetPos = Vector(-7, 3, 19)
local WeaponAngle = Angle(0, 0, 90)
local WeaponSoundEmpty = "weapons/pistol/pistol_empty.wav"
local WeaponSoundFire = "weapons/357/357_fire2.wav"
local WeaponSoundSpin = "weapons/357/357_spin1.wav"

local WeaponActivePos = Vector(0, 0, 37)
local WeaponActiveAngle = Angle(4, 0, 0)

local ColorTransparent = Color( 255, 255, 255, 150 )

local isnumber = isnumber

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Russian Roulette")

GameScript:AddHeader("!gameconfig")

GameScript:AddConfig("DecisionTime", {
    min = 5,
    max = 60,
    def = 10,
})

GameScript:AddConfig("MagazineSize", {
    min = 3,
    max = 8,
    def = 6,
})

--[[
GameScript:AddConfig("ResetOnFire", {
    def = true
})
--]]

GameScript:AddHeader("#bots")

GameScript:AddConfig("bots", {
    min = 0,
    max = 20,
    def = 5,
})


GameScript:AddNewVar("BulletPosition", "number", 0)
GameScript:AddNewVar("CurrentPosition", "number", 0)

--[[----------------------------
          Trigger Events
----------------------------]]--

GameScript:AddHook( "RUSSIANROULETTE PostPlayerDeath" )

function GameScript:OnPlayerChanged(ply, Joined)
    if not self:IsActive() then return end

    local AllPlayers = self:GetPlayers(true)
    local AllBots = self.__Bots

    -- 1. Only one bot left
    if #AllPlayers == 0 and #AllBots == 1 then
        self:SetPlayerWinner(AllBots[1])
        self:StopGame()
        return
    end

    -- 2. Player died in a game with only bots
    if #AllPlayers == 0 and #AllBots > 1 and not self.OnlyPlayingBots then
        self:SetPlayerWinner(AllBots[1])
        self:StopGame()
        return
    end

    -- 3. Only one player left
    if #AllPlayers == 1 and #AllBots == 0 then
        self:SetPlayerWinner(AllPlayers[1])
        self:StopGame()
        return
    end
end


--[[----------------------------
          Network Data
----------------------------]]--

GameScript.MagazineSize = 0

GameScript:RegisterNetworkData("CurrentPosition", isnumber, function(self)
    return self:GetCurrentPosition()
end)

GameScript:RegisterNetworkData("CurrentPositionBullet", isnumber, function(self)
    return self:GetBulletPosition()
end)

GameScript:RegisterNetworkData("MagazineSize", isnumber, function(self)
    return self.MagazineSize
end)


--[[----------------------------
            Bot Logic
----------------------------]]--

function GameScript:CanSkip(ply)
    return ply:GetNWBool("RussianRoulette.CanSkip", false)
end

function GameScript:SetCanSkip(ply, bool)
    ply:SetNWBool("RussianRoulette.CanSkip", bool)
end

function GameScript:BotThink(bot)
    local CanSkip = self:CanSkip(bot)
    local DecideToShoot = true

    if ( CanSkip and ( math.random(1, 100) >= 50 ) ) then
        DecideToShoot = false
    end

    if DecideToShoot then
        if ( CanSkip == false ) then
            self:SetCanSkip(bot, true)
        end
    else
        self:SetCanSkip(bot, false)
    end

    return DecideToShoot
end



--[[----------------------------
           Weapon Logic
----------------------------]]--

function GameScript:WeaponPlaySound(snd)
    self.MainWeapon:EmitSound(snd, 100, 100, 1, CHAN_WEAPON)
end

function GameScript:WeaponSetState(State)
    self.MainWeapon:SetPos(self.MainTable:GetPos() + (State and WeaponActivePos or WeaponOffsetPos))
    self.MainWeapon:SetAngles(State and WeaponActiveAngle or WeaponAngle)
end

function GameScript:PointTo(ent)
    if not IsValid(ent) then return end

    local ang = (ent:GetPos() - self.MainWeapon:GetPos()):Angle()
    ang.p = 4
    ang.r = 0

    self.MainWeapon:SetAngles(ang)
end

function GameScript:WeaponShuffleMagazine()
    local BulletPosition = math.random(2, self.MagazineSize - 1)

    self:SetBulletPosition(BulletPosition)
    self:SendNWCurrentPositionBullet()
end

function GameScript:WeaponFire(ply)
    self:SetCurrentPosition(self:GetCurrentPosition() + 1)

    local CurrentPos = self:GetCurrentPosition()

    if ( CurrentPos > self.MagazineSize ) then
        self:SetCurrentPosition(1)
    elseif ( CurrentPos == self.MagazineSize ) then
        self:WeaponShuffleMagazine()
    end

    return self:GetBulletPosition() == self:GetCurrentPosition()
end

function GameScript:BulletOnNextPosition()
    local CurrentPos = self:GetCurrentPosition() + 1

    if ( CurrentPos > self.MagazineSize ) then
        CurrentPos = 1
    end

    return self:GetBulletPosition() == CurrentPos
end


--[[----------------------------
        Minigame Creation
----------------------------]]--

function GameScript:SpawnGame( trace )
    -- Replicate to owner
    self:SendNWMagazineSize()
    self:SendNWCurrentPositionBullet()
    self:SendNWCurrentPosition()

    self.MainTable = self:CreateEntity("minigame_prop")
    self.MainTable:SetModel(TableModel)
    self.MainTable:SetPos(trace.HitPos + TableOffsetPos)
    self.MainTable:Spawn()

    -- constraint.Keepupright(self.MainTable, self.MainTable:GetAngles(), 0, 1000)

    self.MainWeapon = self:CreateEntity("minigame_prop")
    self.MainWeapon:SetModel(WeaponModel)
    self.MainWeapon:SetPos(self.MainTable:GetPos() + WeaponOffsetPos)
    self.MainWeapon:SetAngles(WeaponAngle)
    self.MainWeapon:Spawn()

    self:SpawnPlayZone()

    return true
end

--[[---------------------------
         Game Functions
---------------------------]]--

function GameScript:FullyStartGame()
    local GameLogic = self:CreateTimer("MainGame")
    GameLogic:SetLoop(true)
    GameLogic:SetVariable({
        Pos = 0,
        Players = self.AllPlayers,
        CurrentPlayer = NULL
    })

    GameLogic:AddAction(function(Var)
        if not self:IsActive() then return true end

        Var.Pos = Var.Pos + 1

        if ( Var.Pos > #Var.Players ) then
            Var.Pos = 1
        end

        Var.CurrentPlayer = Var.Players[Var.Pos]

        self:PointTo(Var.CurrentPlayer)

        if self:IsBot(Var.CurrentPlayer) then
            Var.CurrentPlayer:EnableWeapon()
        end

        self:WeaponPlaySound(WeaponSoundSpin)
    end)

    GameLogic:Wait(0.5)

    GameLogic:AddAction(function(Var)
        if not IsValid(Var.CurrentPlayer) then return end
        if self:IsBot(Var.CurrentPlayer) then return end

        Var.CurrentPlayer:Give("minigame_russianroulette")
        Var.CurrentPlayer:SelectWeapon("minigame_russianroulette")
    end)

    GameLogic:WaitUntil(function(Var)
        -- Player somehow got disconnected
        if not IsValid(Var.CurrentPlayer) then return true end

        return self:IsBot(Var.CurrentPlayer) or Var.CurrentPlayer:GetNWBool("RussianRoulette.Ready", false)
    end, self.DecisionTime)

    GameLogic:AddAction(function(Var)
        if not self:IsActive() then return true end
        if not IsValid(Var.CurrentPlayer) then
            table.remove(Var.Players, Var.Pos)
            return
        end

        local DecideToShoot = false
        local IsABot = self:IsBot(Var.CurrentPlayer)

        if IsABot then
            Var.CurrentPlayer:DisableWeapon()
            DecideToShoot = self:BotThink(Var.CurrentPlayer)
        else
            Var.CurrentPlayer:StripWeapon("minigame_russianroulette")
            DecideToShoot = ( Var.CurrentPlayer:GetNWBool("RussianRoulette.Ready", false) == false ) or Var.CurrentPlayer:GetNWBool("RussianRoulette.Decision", true)
        end

        if DecideToShoot then
            local IsDead = self:WeaponFire()

            if IsDead then
                local Loser = table.remove(Var.Players, Var.Pos)

                Var.Pos = Var.Pos - 1

                if IsABot then
                    self:RemoveBot(Loser)
                else
                    Loser:Kill()
                end

                self:WeaponPlaySound(WeaponSoundFire)
            else
                self:SetCanSkip(Var.CurrentPlayer, true)
                self:WeaponPlaySound(WeaponSoundEmpty)
            end
        else
            if IsABot then
                Var.CurrentPlayer:NegativeComment()
            end
            self:SetCanSkip(Var.CurrentPlayer, false)
        end

        Var.CurrentPlayer:SetNWBool("RussianRoulette.Ready", false)
        self:SendNWCurrentPosition()
    end)

    GameLogic:Wait(0.5)
    GameLogic:Start()
end

function GameScript:SetupPlayers()
    local BotsAmount = self:GetOwnerConfig("bots")
    self.AllPlayers = self:GetPlayers(true)

    local TotalPlayers = #self.AllPlayers + BotsAmount
    if TotalPlayers < 2 then return false end

    self.OnlyPlayingBots = (#self.AllPlayers == 0)

    for i = 1, BotsAmount do
        local Bot = self:AddBot()
        table.insert(self.AllPlayers, Bot)
    end

    table.Shuffle(self.AllPlayers)

    local PosRadius = (360 / TotalPlayers)
    local PosPos = 0
    local TablePos = self.MainTable:GetPos()

    local PosAwayFromTable = 100 + (TotalPlayers * 2)

    for i, ply in ipairs(self.AllPlayers) do
        ply:SetPos( TablePos + Vector(
            math.cos( math.rad(PosPos * PosRadius) ) * PosAwayFromTable,
            math.sin( math.rad(PosPos * PosRadius) ) * PosAwayFromTable,
            0
        ) ) -- IDK WHAT THIS DOES

        if self:IsBot(ply) then
            ply:SetAngles( (TablePos - ply:GetPos()):Angle() )
        else
            ply:SetVelocity( ply:GetVelocity() * -1 )
            ply:SetEyeAngles( (TablePos - ply:GetPos()):Angle() )
        end

        PosPos = PosPos + 1
    end

    local PreGame = self:CreateTimer("PreGame")
    PreGame:SetLoop(TotalPlayers)
    PreGame:SetVariable({Pos = 1})

    PreGame:Wait(2.1 / TotalPlayers)
    PreGame:AddAction(function(Var)
        Var.Pos = Var.Pos + 1
        self:PointTo( self.AllPlayers[Var.Pos] or self.AllPlayers[1] )

        if ( Var.Pos == TotalPlayers + 1 ) then
            self:FullyStartGame()
        end
    end)

    PreGame:Start()

    return true
end

--[[----------------------------
          Main Functions
----------------------------]]--

function GameScript:StartGame()
    local MoreThanOne = self:SetupPlayers()

    if MoreThanOne then
        self:SetCurrentPosition(1)
        self:WeaponShuffleMagazine()
        self:WeaponSetState(true)
        self:PlayGameStartSound()

        self:SendNWMagazineSize()
        self:SendNWCurrentPosition()

        for _, ply in ipairs(self:GetPlayers(true)) do
            ply:SetNWBool("RussianRoulette.Ready", false)
            ply:SetNWBool("RussianRoulette.Decision", false)
            self:SetCanSkip(ply, true)
        end

        return Minigames.GameStart( self )
    end

    return false
end

function GameScript:StopGame()
    self:RemoveTimer("PreGame")
    self:RemoveTimer("MainGame")

    for _, ply in ipairs(self:GetPlayers(true)) do
        ply:StripWeapon("minigame_russianroulette")
    end

    self:RemoveAllBots(true)

    self.MagazineSize = 0
    self:SetBulletPosition(0)
    self:SetCurrentPosition(0)

    self:SendNWMagazineSize()
    self:SendNWCurrentPositionBullet()
    self:SendNWCurrentPosition()

    self:WeaponSetState(false)

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()
    local Result = false

    self.ResetOnFire = self:GetOwnerConfig("ResetOnFire")
    self.DecisionTime = self:GetOwnerConfig("DecisionTime")
    self.MagazineSize = self:GetOwnerConfig("MagazineSize")

    if self:IsActive() then
        Result = self:StopGame()
    else
        Result = self:StartGame()
    end

    return Result
end

--[[----------------------------
        Clientside Script
----------------------------]]--

local CS_Data = {
    MagazineSize = 0,
    CurrentPosBullet = 0,
    CurrentPos = 0
}

if CLIENT then
    util.PrecacheModel(TableModel)
    util.PrecacheModel(WeaponModel)

    if IsValid( CS_TableModel ) then
        CS_TableModel:Remove()
    end

    if IsValid( CS_WeaponModel ) then
        CS_WeaponModel:Remove()
    end

    function GameScript:RenderGame( trace )
        if Minigames.GetOwnerGame( LocalPlayer() ) then return end

        if not IsValid( CS_TableModel ) then
            CS_TableModel = ClientsideModel( TableModel )
        end

        if not IsValid( CS_WeaponModel ) then
            CS_WeaponModel = ClientsideModel( WeaponModel )
        end

        CS_TableModel:SetRenderMode( RENDERMODE_TRANSCOLOR )
        CS_TableModel:SetColor( ColorTransparent )

        CS_WeaponModel:SetRenderMode( RENDERMODE_TRANSCOLOR )
        CS_WeaponModel:SetColor( ColorTransparent )

        CS_TableModel:SetPos( trace.HitPos + TableOffsetPos )
        CS_WeaponModel:SetPos( CS_TableModel:GetPos() + WeaponOffsetPos )
        CS_WeaponModel:SetAngles( WeaponAngle )
    end

    GameScript:CatchData("MagazineSize", function(Data, SubGameScript)
        CS_Data.MagazineSize = Data
    end)

    GameScript:CatchData("CurrentPositionBullet", function(Data)
        CS_Data.CurrentPosBullet = Data
    end)

    GameScript:CatchData("CurrentPosition", function(Data)
        CS_Data.CurrentPos = Data
    end)

    hook.Add("Minigames.PostNewGame", "Minigames.RemoveTable", function()
        if IsValid( CS_TableModel ) then
            CS_TableModel:Remove()
        end

        if IsValid( CS_WeaponModel ) then
            CS_WeaponModel:Remove()
        end
    end)

end


--[[----------------------------
        Action Functions
----------------------------]]--

function GameScript:LeftClick( trace, owner, FirstTime )
    local Response = false

    if FirstTime then
        Response = self:SpawnGame( trace )
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

function GameScript:Think( trace, owner )
    if CLIENT then
        self:RenderGame( trace )
    end
end

function GameScript:RollUp( trace, owner )
    if CLIENT then
        if IsValid( CS_TableModel ) then
            CS_TableModel:Remove()
        end

        if IsValid( CS_WeaponModel ) then
            CS_WeaponModel:Remove()
        end
    end
end

--[[--------------------------------------------
                  Draw HUD
--------------------------------------------]]--

local BlackColor = Color(0, 0, 0, 230)
local StateNoBullet = Color(100, 100, 100, 200)
local StateHadBullet = Color(180, 50, 50, 200)
local Round = 4

--[[----------------------------
           Main Config
----------------------------]]--

local DataCached = false
local CachedY, CachedX = 0, 0

function GameScript:DrawHUD()
    if not Minigames.GetOwnerGame( LocalPlayer() ) then return end
    if not DataCached then
        CachedX = math.max( ScrW() * 0.1, 100 )
        CachedY = ScrH() / 2
    end

    local MenuHeight = 90 + ( CS_Data.MagazineSize * 28 )
    CachedY = CachedY - ( MenuHeight * 0.4 )

    draw.RoundedBox( Round, CachedX, CachedY, 220, MenuHeight, BlackColor )
    draw.SimpleText( Minigames.GetPhrase("russianroulette.name"), "Minigames.SubTitle", CachedX + 110, CachedY + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    for i = 1, CS_Data.MagazineSize do
        local BulletX = CachedX + 110
        local BulletY = CachedY + 30 + ( i * 28 )

        draw.RoundedBox( Round, BulletX - 12.5, BulletY - 12.5, 25, 25, ( i == CS_Data.CurrentPosBullet ) and StateHadBullet or StateNoBullet )

        if ( i == CS_Data.CurrentPos ) then
            draw.RoundedBox( Round, BulletX - 5, BulletY - 5, 10, 10, Color(255, 255, 255) )
        end
    end
end

Minigames.RegisterNewGame(GameScript)