--[[--------------------------------------------
                   Deathmatch
--------------------------------------------]]--


local SpawnPointBounds = Vector(6, 6, 6)
local ItemBounds = Vector(16, 16, 16)

local FrontLineColor = Color(70, 255, 70)

local LeaderboardBounds = 1

local ENTITY_TYPE = {
    "minigame_spawnpoint",
    "minigame_ammo",
    "minigame_weapon",
    "minigame_health",
    "minigame_armor",
}

local ENTITY_COLOR = {
    color_white,
    Color(255, 255, 0),
    Color(255, 150, 0),
    Color(0, 255, 0),
    Color(0, 255, 255),
}

local WEAPONS_KIT = {}

for _, NameKit in ipairs( table.GetKeys(Minigames.Config["WeaponsKit"]) ) do
    table.insert(WEAPONS_KIT, NameKit)
end

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Deathmatch")

GameScript:AddHeader("deathmatch.weaponskit")

GameScript:AddConfig("WeaponsKit", {
    def = WEAPONS_KIT
})

GameScript:AddHeader("deathmatch.entitysettings")

GameScript:AddConfig("SpawnEntityType", {
    def = ENTITY_TYPE
})

GameScript:AddConfig("SpawnEntityTypeOffset", {
    min = 1,
    max = 64,
    def = 16
})

GameScript:AddConfig("SpawnPointRotation", {
    min = 0,
    max = 360,
    def = 0
})

GameScript:AddHeader("deathmatch.health")

GameScript:AddConfig("Health", {
    min = 10,
    max = 100,
    def = 100
})

GameScript:AddConfig("HealthRespawn", {
    min = 1,
    max = 20,
    dec = 1,
    def = 5
})

GameScript:AddHeader("deathmatch.armor")

GameScript:AddConfig("Armor", {
    min = 10,
    max = 100,
    def = 0
})

GameScript:AddConfig("ArmorRespawn", {
    min = 1,
    max = 20,
    dec = 1,
    def = 5
})

GameScript:AddHeader("deathmatch.ammo")

--[[
GameScript:AddConfig("Ammo", {
    min = 1,
    max = 100,
    def = 100
})
--]]

GameScript:AddConfig("AmmoRespawn", {
    min = 1,
    max = 20,
    dec = 1,
    def = 5
})

GameScript:AddHeader("!gameconfig")

GameScript:AddConfig("WinByTime", {
    def = false
})

GameScript:AddConfig("Time", {
    min = 30,
    max = 600,
    def = 120
})

GameScript:AddConfig("KillsToWin", {
    min = 1,
    max = 100,
    def = 10
})

GameScript:AddConfig("FallDamage", {
    def = false
})

--[[
GameScript:AddConfig("RespawnTime", {
    min = 1,
    max = 20,
    def = 2,
    dec = 1
})

GameScript:AddConfig("RespawnProtection", {
    min = 0,
    max = 10,
    def = 2,
    dec = 1
})
--]]

GameScript:AddHeader("deathmatch.leaderboard")

GameScript:AddConfig("Tall", {
    min = 150,
    max = 450,
    def = 150
})

GameScript:AddConfig("Wide", {
    min = 200,
    max = 450,
    def = 200
})

GameScript:AddConfig("HeightOffset", {
    min = 10,
    max = 2048,
    def = 150
})

GameScript:AddConfig("AngleOffset", {
    min = 0,
    max = 360,
    def = 0
})

GameScript:ListenToConfig("WinByTime", function(self, NewVal)
    self.Leaderboard:SetTimeEnabled(NewVal)
end)

GameScript:ListenToConfig("FallDamage", function(self, NewVal)
    self.FallDamageEnabled = NewVal
end)


--[[----------------------------
         Trigger Events
----------------------------]]--

GameScript:AddHook("DEATHMATCH PlayerDeath")
GameScript:AddHook("DEATHMATCH PlayerSelectSpawn")
GameScript:AddHook("DEATHMATCH PlayerSpawn")
GameScript:AddHook("DEATHMATCH GetFallDamage")

GameScript.PlayerMaxHealth = {}

function GameScript:OnPlayerChanged(ply, Joined)
    if self:IsActive() then return end

    if Joined then
        self.Leaderboard:AddPlayer(ply)

        self.PlayerMaxHealth[ply] = ply:GetMaxHealth()
        ply:SetMaxHealth(100)
    else
        self.Leaderboard:RemovePlayer(ply)

        ply:SetMaxHealth(self.PlayerMaxHealth[ply])
        self.PlayerMaxHealth[ply] = nil
    end
end

--[[----------------------------
         Score Functions
----------------------------]]--

GameScript.PlayerScore = {}
GameScript.WinByTime = false
GameScript.KillsToWin = 0

function GameScript:AddPoint(ply)
    self.PlayerScore[ply] = self.PlayerScore[ply] + 1

    self.Leaderboard:AddPlayerPoint(ply, 1)

    if self.WinByTime then return end
    if self.PlayerScore[ply] >= self.KillsToWin then
        self:SetPlayerWinner(ply)
        self:StopGame()
    end
end


--[[----------------------------
        Player Functions
----------------------------]]--

function GameScript:Spectate(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Spectate(OBS_MODE_CHASE)
end

function GameScript:UnSpecate(ply)
    ply:UnSpectate()
    ply:Spawn()
end


--[[----------------------------
         Items Functions
----------------------------]]--

GameScript.Spawns = {}
GameScript.WeaponItem = {}
GameScript.HealthItem = {}
GameScript.ArmorItem = {}
GameScript.WeaponDefault = "weapon_crowbar"

function GameScript:SpawnItems()
    -- Items
    local HealthAmount, HealthRespawn = self:GetOwnerConfig("Health"), self:GetOwnerConfig("HealthRespawn")
    local ArmorAmount, ArmorRespawn = self:GetOwnerConfig("Armor"), self:GetOwnerConfig("ArmorRespawn")

    for _, item in ipairs(self.HealthItem) do
        item:SetActive(true)
        item:SetItemAmount(HealthAmount)
        item:SetItemRespawnTime(HealthRespawn)
    end

    for _, item in ipairs(self.ArmorItem) do
        item:SetActive(true)
        item:SetItemAmount(ArmorAmount)
        item:SetItemRespawnTime(ArmorRespawn)
    end

    -- Weapons
    local WeaponKit, WeaponRespawn = self:GetOwnerConfig("WeaponsKit"), self:GetOwnerConfig("AmmoRespawn")
    for _, item in ipairs(self.WeaponItem) do
        item:SetActive(true)
        item:SetItemWeaponKit( WEAPONS_KIT[WeaponKit] )
        item:SetItemRespawnTime(WeaponRespawn)
    end
end


function GameScript:CreateSpawn(trace)
    local SpawnPoint, Index = self:CreateEntity("minigame_item", "Spawns")
    local pos = trace.HitPos + trace.HitNormal * self:GetOwnerConfig("SpawnEntityTypeOffset")
    local ang = Angle(0, self:GetOwnerConfig("SpawnPointRotation"), 0)

    SpawnPoint:SetPos(pos)
    SpawnPoint:SetAngles(ang)
    SpawnPoint:Spawn()
    SpawnPoint:SetSpawnEntityType(1)

    table.insert(self.Spawns, SpawnPoint)
    table.insert(self.DefaultTeleportEntities, SpawnPoint)

    undo.Create("deathmatch." .. self:GetOwnerID() .. ".spawnpoint")
        undo.AddEntity(SpawnPoint)
        undo.SetPlayer(self:GetOwner())

        -- Remove entity on undo
        undo.AddFunction(function(_, CurrentOwner)
            if not IsValid(CurrentOwner) then return end
            if not Minigames.GetOwnerGame(CurrentOwner) then return end

            self:RemoveEntityByIndex(Index, "Spawns", false)
            table.RemoveByValue(self.DefaultTeleportEntities, SpawnPoint)
        end, self:GetOwner())
    undo.Finish("Minigame Deathmatch - Spawn Point")

    return true
end

function GameScript:CreateSpawnItem( trace )
    local SpawnItemEntity = self:GetOwnerConfig("SpawnEntityType")
    if SpawnItemEntity == 1 then
        return self:CreateSpawn(trace)
    end

    local pos = trace.HitPos + trace.HitNormal * self:GetOwnerConfig("SpawnEntityTypeOffset")
    local EntityPoint, Index = self:CreateEntity("minigame_item", "Items")

    EntityPoint:SetPos(pos)
    EntityPoint:SetAngles(angle_zero)
    EntityPoint:Spawn()
    EntityPoint:SetSpawnEntityType(SpawnItemEntity)

    undo.Create("deathmatch." .. self:GetOwnerID() .. ".spawnitem")
        undo.AddEntity(EntityPoint)
        undo.SetPlayer(self:GetOwner())

        -- Remove entity on undo
        undo.AddFunction(function(_, CurrentOwner, SubIndex)
            if not IsValid(CurrentOwner) then return end
            if not Minigames.GetOwnerGame(CurrentOwner) then return end

            self:RemoveEntityByIndex(SubIndex, "Items", false)
        end, self:GetOwner(), Index)

        if SpawnItemEntity == 3 then
            table.insert(self.WeaponItem, EntityPoint)
            undo.AddFunction(function(_, CurrentOwner)
                if not IsValid(CurrentOwner) then return end
                if not Minigames.GetOwnerGame(CurrentOwner) then return end

                table.RemoveByValue(self.WeaponItem, EntityPoint)
            end, self:GetOwner())

        elseif SpawnItemEntity == 4 then
            table.insert(self.HealthItem, EntityPoint)
            undo.AddFunction(function(_, CurrentOwner)
                if not IsValid(CurrentOwner) then return end
                if not Minigames.GetOwnerGame(CurrentOwner) then return end

                table.RemoveByValue(self.HealthItem, EntityPoint)
            end, self:GetOwner())

        elseif SpawnItemEntity == 5 then
            table.insert(self.ArmorItem, EntityPoint)
            undo.AddFunction(function(_, CurrentOwner)
                if not IsValid(CurrentOwner) then return end
                if not Minigames.GetOwnerGame(CurrentOwner) then return end

                table.RemoveByValue(self.ArmorItem, EntityPoint)
            end, self:GetOwner())
        end

    undo.Finish("Minigame Deathmatch - Spawn Item")

    return true
end


--[[----------------------------
         Main Functions
----------------------------]]--

function GameScript:SelectSpawnPoint(ply)
    local Spawns = self:GetAllEntities("Spawns")
    return Spawns[math.random(1, #Spawns)]
end

function GameScript:StartGame()
    local Players = self:GetPlayers(true)
    local Spawns = self:GetAllEntities("Spawns")

    if #Spawns < math.max(2, #Players) then
        self:SendToolTip({"deathmatch.insufficientspawns", math.max(2, #Players)}, 1)
        return false
    end

    if #self.Leaderboard.PlayerList >= 1 then
        self.Leaderboard:ResetPlayerList()

        for k, ply in ipairs(Players) do
            self.Leaderboard:AddPlayer(ply)
        end
    end
    -- self.Leaderboard:ResetPlayerList()

    self.WeaponDefault = Minigames.Config["WeaponsKit"][ WEAPONS_KIT[self:GetOwnerConfig("WeaponsKit")] ][1]

    for k, ply in ipairs(Players) do
        self.PlayerScore[ply] = 0
        local wpn = ply:Give(self.WeaponDefault)
        ply:SetActiveWeapon(wpn)
    end

    self:TeleportPlayers(Spawns)

    local Items = self:GetAllEntities("Items")
    for _, item in ipairs(Items) do
        item:SetActive(true)
    end

    self:SpawnItems()
    self:PlayGameStartSound()

    local WinByTime = self:GetOwnerConfig("WinByTime")

    if WinByTime then
        self.WinByTime = true
        self.KillsToWin = 0

        self.MainTimer = self:CreateChronometer("Game")
        self.MainTimer:SetLoop(true)
        self.MainTimer:SetVariable({Time = self:GetOwnerConfig("Time")})

        self.MainTimer:AddAction(function(Var)
            -- if not self:IsActive() then return true end

            self.Leaderboard:SetTime(Var.Time)

            Var.Time = Var.Time - 1

            if Var.Time < 0 then
                -- obtener los jugadores con el puntaje mas alto, si ambos jugadores tienen el mismo puntaje, darle el premio a ambos
                local CurrentPlayers = self:GetPlayers(true)
                local MaxScore = 0
                local Winners = {}

                for k, ply in ipairs(CurrentPlayers) do
                    if self.PlayerScore[ply] > MaxScore then
                        MaxScore = self.PlayerScore[ply]
                    end
                end

                for k, ply in ipairs(CurrentPlayers) do
                    if self.PlayerScore[ply] == MaxScore then
                        table.insert(Winners, ply)
                    end
                end

                self:SetPlayersWinner(Winners)

                self:StopGame()
                self:PlayGameEndSound()

                return true
            end
        end)

        self.MainTimer:Wait(1)

        self.MainTimer:Start()

    else
        self.WinByTime = false
        self.KillsToWin = self:GetOwnerConfig("KillsToWin")
    end

    self.FullyStarted = true

    return Minigames.GameStart( self )
end

function GameScript:StopGame()
    self:RemoveChronometer("Game")

    self.PlayerScore = {}

    local Items = self:GetAllEntities("Items")
    for _, item in ipairs(Items) do
        item:SetActive(false)
        item:SetIsCooldown(false)
    end

    self.FullyStarted = false

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()
    local Result = false

    if self:IsActive() then
        Result = self:StopGame()
    else
        Result = self:StartGame()
        if not Result then return false end
    end

    return Result
end

function GameScript:SpawnGame( trace, owner )

    self.Leaderboard = self:CreateEntity("minigame_leaderboard")
    self.Leaderboard:SetPos(trace.HitPos + trace.HitNormal * self:GetOwnerConfig("HeightOffset"))
    self.Leaderboard:SetAngles(Angle(0, self:GetOwnerConfig("AngleOffset"), 90))
    self.Leaderboard:SetWide( self:GetOwnerConfig("Wide") )
    self.Leaderboard:SetTall( self:GetOwnerConfig("Tall") )
    self.Leaderboard:Spawn()

    self.Leaderboard:SetTimeEnabled( self:GetOwnerConfig("WinByTime") )
    self.FallDamageEnabled = self:GetOwnerConfig("FallDamage")

    self:SpawnPlayZone()

    return true
end


--[[----------------------------
           Pre-Render
----------------------------]]--

function GameScript:PreviewLeaderboard( trace, owner )
    hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawSpawnPoints")

    local Offset = self:GetOwnerConfig("HeightOffset")
    local HitPos = trace.HitPos + trace.HitNormal * Offset

    local Tall = self:GetOwnerConfig("Tall")
    local Wide = self:GetOwnerConfig("Wide")
    local ang = self:GetOwnerConfig("AngleOffset")

    local FrontLine = Vector(math.cos(math.rad(ang - 90)), math.sin(math.rad(ang - 90)), 0) * 70
    local FrontLineRight = Vector(math.cos(math.rad(ang)), math.sin(math.rad(ang)), 0) * 10
    local FrontLineLeft = Vector(math.cos(math.rad(ang + 180)), math.sin(math.rad(ang + 180)), 0) * 10

    local Bounds = Vector(Wide, LeaderboardBounds, Tall)

    hook.Add("PostDrawTranslucentRenderables", "Minigames.DrawLeaderboard", function()
        render.DrawWireframeBox(HitPos, Angle(0, ang, 0), -Bounds, Bounds, color_white, true)
        -- Arrow
        render.DrawLine(HitPos, HitPos + FrontLine * 1.15, FrontLineColor, true)
        render.DrawLine(HitPos + FrontLine * 1.15, HitPos + FrontLine + FrontLineRight, FrontLineColor, true)
        render.DrawLine(HitPos + FrontLine * 1.15, HitPos + FrontLine + FrontLineLeft, FrontLineColor, true)
    end)
end

function GameScript:PreviewSpawnPoints( trace, owner )
    hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawLeaderboard")

    if Minigames.GetOwnerGame( LocalPlayer() ):IsActive() then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawSpawnPoints")
        return
    end

    hook.Add("PostDrawTranslucentRenderables", "Minigames.DrawSpawnPoints", function()
        local Offset = self:GetOwnerConfig("SpawnEntityTypeOffset")
        local StartPos = trace.HitNormal * Offset + trace.HitPos

        local SpawnEntityType = self:GetOwnerConfig("SpawnEntityType")
        local ColorBox = ENTITY_COLOR[SpawnEntityType]

        if SpawnEntityType == 1 then
            local ang = self:GetOwnerConfig("SpawnPointRotation")
            local BoxAngle = Angle(0, ang, 0)
            render.DrawWireframeBox(StartPos, BoxAngle, -SpawnPointBounds, SpawnPointBounds, ColorBox, true)

            local FrontLine = Vector(math.cos(math.rad(ang)), math.sin(math.rad(ang)), 0) * 16
            local FrontLineRight = Vector(math.cos(math.rad(ang + 90)), math.sin(math.rad(ang + 90)), 0) * 4
            local FrontLineLeft = Vector(math.cos(math.rad(ang - 90)), math.sin(math.rad(ang - 90)), 0) * 4

            render.DrawLine(StartPos, StartPos + FrontLine * 1.2, color_white, true)
            render.DrawLine(StartPos + FrontLine * 1.2, StartPos + FrontLine + FrontLineRight, color_white, true)
            render.DrawLine(StartPos + FrontLine * 1.2, StartPos + FrontLine + FrontLineLeft, color_white, true)
        else
            render.DrawWireframeBox(StartPos, angle_zero, -ItemBounds, ItemBounds, ColorBox, true)
        end
    end)

end


--[[----------------------------
        Action Functions
----------------------------]]--

function GameScript:LeftClick( trace, owner, FirstTime )
    local Result = true

    if FirstTime then
        Result = self:SpawnGame( trace, owner )
    else
        if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
            if SERVER and #self.Leaderboard.PlayerList >= 1 then
                self.Leaderboard:ResetPlayerList()
            end

            Result = self:TogglePlayer( trace.Entity )
        else
            Result = self:CreateSpawnItem( trace )
        end
    end

    return Result
end

function GameScript:RightClick( trace, owner )
    return self:ToggleGame()
end

local ReloadDelay = 0
function GameScript:Reload( trace, owner )
    if CLIENT then
        if self:IsActive() then return end
        if ReloadDelay > CurTime() then return end

        local spawnentity = self:GetConfigCvar("SpawnEntityType")
        local spawnentitytype = spawnentity:GetInt() + 1

        if spawnentitytype > #ENTITY_TYPE then
            spawnentitytype = 1
        end

        spawnentity:SetInt(spawnentitytype)
        ReloadDelay = CurTime() + 0.2
    end
end

function GameScript:Think( trace, owner )
    if CLIENT then
        if Minigames.GetOwnerGame( LocalPlayer() ) then
            self:PreviewSpawnPoints( trace, owner )
        else
            self:PreviewLeaderboard( trace, owner )
        end
    end
end

function GameScript:RollUp( trace, owner )
    if CLIENT then
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawLeaderboard")
        hook.Remove("PostDrawTranslucentRenderables", "Minigames.DrawSpawnPoints")
    end
end

-- Client-side
local BoxSizeWidth = 380
local BoxSizeHeight = 100
local BoxHeightOffset = 24
local BoxColor = Color(0, 0, 0, 230)
local EntityConvar = nil

function GameScript:DrawHUD()
    if not Minigames.ActiveGames[ LocalPlayer() ] then return end
    if Minigames.ActiveGames[ LocalPlayer() ]:IsActive() then return end
    if not EntityConvar then EntityConvar = self:GetConfigCvar("SpawnEntityType") end

    -- Draw a small box of the current spawn entity type
    local ScreenW, ScreenH = ScrW(), ScrH()

    draw.RoundedBox(8, ( ScreenW * 0.5 ) - ( BoxSizeWidth / 2 ), ScreenH - BoxSizeHeight - BoxHeightOffset, BoxSizeWidth, BoxSizeHeight, BoxColor)
    draw.SimpleText( Minigames.GetPhrase("deathmatch.spawnentitytype"), "Trebuchet24", ScreenW * 0.5, ScreenH - BoxSizeHeight * 0.75 - BoxHeightOffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local Phrase = Minigames.GetPhrase(ENTITY_TYPE[EntityConvar:GetInt()])

    draw.SimpleText( Phrase, "Trebuchet24", ScreenW * 0.5, ScreenH - BoxSizeHeight * 0.55 + 24 - BoxHeightOffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

Minigames.RegisterNewGame(GameScript)


--[[----------------------------
               Hooks
----------------------------]]--

hook.Add("CanUndo", "Minigames.CanUndo.Deathmatch", function(owner, tbl)
    if table.IsEmpty(tbl) then return end
    if tbl.Name == nil then return end

    local UndoInfo = string.Split( tbl.Name, "." )
    if ( #UndoInfo == 3 ) and ( UndoInfo[1] == "deathmatch" ) then
        local TargetGame = Minigames.GetOwnerGame( owner )

        if TargetGame and TargetGame:IsActive() then
            Minigames.BroadcastMessage( Minigames.GetPhrase("minigames.error.gameisactive"), owner )
            return false
        else
            return true
        end
    end
end)

-- Remove all deathmatch undos
hook.Add("Minigames.PreRemoveGame", "Minigames.RemoveDeathmatchUndos", function( owner, CurrentGame )
    if CurrentGame:GetGameID() ~= "deathmatch" then return end

    local OwnerUndos = undo.GetTable()[owner:UniqueID()]
    if not OwnerUndos then return end

    for k, UndoTbl in ipairs(OwnerUndos) do
        if not UndoTbl.Name then continue end

        local UndoInfo = string.Split( UndoTbl.Name, "." )
        if not ( table.IsEmpty(UndoInfo) ) and ( UndoInfo[1] == "deathmatch" ) then
            undo.Do_Undo( UndoTbl )
        end
    end
end)

if SERVER then
    hook.Add("Minigames.GameStart", "Minigames.Deathmatch.GiveOwnerWeapon", function(Owner, CurrentGame)
        if CurrentGame:GetGameID() ~= "deathmatch" then return end
        if not CurrentGame:HasPlayer(Owner) then return end

        timer.Simple(0.1, function()
            if not IsValid(Owner) then return end
            if not CurrentGame:IsActive() then return end

            local wpn = Owner:Give(CurrentGame.WeaponDefault)
            Owner:SetActiveWeapon(wpn)
        end)
    end)
end