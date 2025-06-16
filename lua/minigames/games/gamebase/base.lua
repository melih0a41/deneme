--[[--------------------------------------------
              Minigame Games Module
--------------------------------------------]]--

if SERVER then
    util.AddNetworkString("Minigames.NewGame")
end

--[[----------------------------
         Minigame Module
----------------------------]]--

MinigameObject = {}

--[[----------------------------
           Properties
----------------------------]]--

MinigameObject.Name = ""
MinigameObject.GameID = ""

MinigameObject.__CustomVars = {}

MinigameObject.ThrowError = Minigames.ThrowError
function MinigameObject:Checker(...)
    Minigames.Checker(...)
end

if SERVER then
    Minigames.SendCS("minigames/games/gamebase/base_cl.lua")
    Minigames.SendCS("minigames/games/gamebase/config.lua")
else
    Minigames.AddInc("minigames/games/gamebase/base_cl.lua")
end
Minigames.AddInc("minigames/games/gamebase/config.lua")

--[[----------------------------
         Event Functions
----------------------------]]--

function MinigameObject:LeftClick(Trace, Owner, FirstTime)
    self:Checker(Trace, "table", 1)
    self:Checker(Owner, "player", 2)
end

function MinigameObject:RightClick(Trace, Owner)
    self:Checker(Trace, "table", 1)
    self:Checker(Owner, "player", 2)
end

function MinigameObject:Reload(Trace, Owner)
    self:Checker(Trace, "table", 1)
    self:Checker(Owner, "player", 2)
end

function MinigameObject:Think(Trace, Owner)
    -- NO CHECKER, IS TOO EXPENSIVE
end

function MinigameObject:Deploy(Trace, Owner)
    self:Checker(Trace, "table", 1)
    self:Checker(Owner, "player", 2)
end

function MinigameObject:RollUp(Trace, Owner)
    self:Checker(Trace, "table", 1)
    self:Checker(Owner, "player", 2)
end


--[[----------------------------
            Variables
----------------------------]]--

function MinigameObject:SetGameName(Name)
    self:Checker(Name, "string", 1)
    self.Name = Name
end

function MinigameObject:GetGameID()
    if ( self.GameID == "" ) then
        self.ThrowError([[The GameID is empty.]], self.GameID, "string")
    end

    return self.GameID
end


--[[----------------------------
           Game State
----------------------------]]--

if SERVER then
    Minigames.SendCS("minigames/games/gamebase/customvar.lua")
end
Minigames.AddInc("minigames/games/gamebase/customvar.lua")

MinigameObject:AddNewVar("Active", "bool", false)


--[[----------------------------
         Extra Modules
----------------------------]]--

if SERVER then
    Minigames.AddInc("minigames/games/gamebase/owner.lua")
    Minigames.AddInc("minigames/games/gamebase/network.lua")
    Minigames.AddInc("minigames/games/gamebase/player.lua")
    Minigames.AddInc("minigames/games/gamebase/entity.lua")
    Minigames.AddInc("minigames/games/gamebase/trigger.lua")
    Minigames.AddInc("minigames/games/gamebase/timer.lua")
    Minigames.AddInc("minigames/games/gamebase/hook.lua")
    Minigames.AddInc("minigames/games/gamebase/sound.lua")
    Minigames.AddInc("minigames/games/gamebase/voice.lua")
    Minigames.AddInc("minigames/games/gamebase/playerlist.lua")
    Minigames.AddInc("minigames/games/gamebase/bot.lua")
    Minigames.AddInc("minigames/games/gamebase/reward.lua")

    Minigames.SendCS("minigames/games/gamebase/owner.lua")
    Minigames.SendCS("minigames/games/gamebase/network.lua")
    Minigames.SendCS("minigames/games/gamebase/sound.lua")
    Minigames.SendCS("minigames/games/gamebase/reward.lua")
else
    Minigames.AddInc("minigames/games/gamebase/owner.lua")
    Minigames.AddInc("minigames/games/gamebase/network.lua")
    Minigames.AddInc("minigames/games/gamebase/sound.lua")
    Minigames.AddInc("minigames/games/gamebase/reward.lua")
end


--[[----------------------------
       Spawning Functions
----------------------------]]--

function MinigameObject:CreateNewActiveGame(owner)
    hook.Run("Minigames.PreNewGame", owner, self:GetGameID())

    self.CreateNewActiveGame = nil
    self:SetOwner( owner )

    if SERVER then
        net.Start("Minigames.NewGame")
            net.WriteBool( true )
            net.WritePlayer( owner )
            net.WriteString( self:GetGameID() )
        net.Broadcast()
    end

    hook.Run("Minigames.PostNewGame", owner, self)

    return self
end

function MinigameObject:SafeRemoveActiveGame()
    if SERVER and self:IsActive() then return false end

    local CurrentOwner = self:GetOwner()
    CurrentOwner:SetNWBool("Minigames.HasGame", false)

    hook.Run("Minigames.PreRemoveGame", CurrentOwner, self)

    if SERVER then
        self:RemoveHooks()
        self:RemoveAllTimers()
        for Name, Chrono in ipairs( self.__Chronometers ) do
            self:RemoveChronometer( Name )
        end
        self:RemoveAllPlayers()

        hook.Remove("PostPlayerDeath", "Minigames.PostPlayerDeath." .. self:GetGameID() .. "." .. self:GetOwnerID() )
        hook.Remove("Minigames.PostBotDeath", "Minigames.PostBotDeath." .. self:GetGameID() .. "." .. self:GetOwnerID() )

        net.Start("Minigames.NewGame")
            net.WriteBool( false )
            net.WritePlayer( CurrentOwner )
        net.Broadcast()
    end

    Minigames.ActiveGames[ CurrentOwner ] = nil

    hook.Run("Minigames.PostRemoveGame", CurrentOwner)
end

function MinigameObject:SpawnPlayZone()
    undo.Create("minigame." .. self:GetGameID() .. "." .. self:GetOwnerID())
        undo.SetPlayer( self:GetOwner() )

        for _, ent in ipairs( self:GetEntities(true) ) do
            undo.AddEntity( ent )
        end

        for _, AliasTable in pairs( self.__EntitiesAlias ) do
            for _, ent in ipairs( AliasTable ) do
                undo.AddEntity( ent )
            end
        end

        for _, ent in ipairs( self:GetTriggers(true) ) do
            undo.AddEntity( ent )
        end

        local InjectScript = hook.Run("Minigames.SpawnPlayZone", self:GetOwner(), self)
        if isfunction(InjectScript) then
            undo.AddFunction(InjectScript)
        end

        undo.SetPlayer( self:GetOwner() )
    undo.Finish(self.Name .. " - " .. self:GetOwner():Nick())
end

MinigameObject.__index = MinigameObject


--[[----------------------------
           Networking
----------------------------]]--

if CLIENT then
    net.Receive("Minigames.NewGame", function()
        local IsNew = net.ReadBool()
        local Owner = net.ReadPlayer()

        if ( IsNew == false ) and Minigames.ActiveGames[ Owner ] then
            Minigames.ActiveGames[ Owner ]:SafeRemoveActiveGame()
            return
        end

        local GameID = net.ReadString()
        if Minigames.Games[GameID] == nil then return end

        local GameScript = table.Copy( Minigames.Games[GameID] )
        GameScript:CreateNewActiveGame( Owner )

        Minigames.ActiveGames[ Owner ] = GameScript
    end)
end


--[[----------------------------
          Game Register
----------------------------]]--

local LocalizedGameScript = MinigameObject
MinigameObject = nil

function Minigames.CreateNewGame()
    local GameScript = table.Copy( LocalizedGameScript )
    GameScript.GameID = string.StripExtension( string.GetFileFromFilename(debug.getinfo(2, "S").short_src) )

    return GameScript
end

function Minigames.RegisterNewGame(GameScript)
    if GameScript == nil then return end

    if ( hook.Run("Minigames.PreRegisterGame", GameScript:GetGameID(), GameScript) == false ) then
        GameScript = nil
        return
    end

    Minigames.Games[ GameScript:GetGameID() ] = GameScript

    if CLIENT then
        for _, All in ipairs( GameScript:GetAllConfig() ) do
            if ( All["Header"] ) then continue end

            local ConVarName = "minigames_" .. GameScript:GetGameID() .. "_" .. string.lower( All["Name"] )
            local ConVarValue = 0
            local ConVarDesc = All["Config"]["desc"] or Minigames.GetPhrase( GameScript:GetGameID() .. "." .. string.lower( All["Name"] ) .. ".desc" )

            if ( isbool( All["Config"]["def"] ) ) then
                ConVarValue = ( All["Config"]["def"] == true ) and 1 or 0
                All["Config"]["min"] = 0
                All["Config"]["max"] = 1
            elseif istable( All["Config"]["def"] ) then
                ConVarValue = 1
                All["Config"]["min"] = 1
                All["Config"]["max"] = #All["Config"]["def"]
            else
                ConVarValue = All["Config"]["def"] or All["Config"]["min"]
            end

            if (ConVarValue == nil) then
                Minigames.ThrowError("The default value is not valid", ConVarValue, "bool/number")
            end

            CreateClientConVar( ConVarName, ConVarValue, true, true, ConVarDesc, All["Config"]["min"], All["Config"]["max"] )
        end
    end

    hook.Run("Minigames.PostRegisterGame", GameScript:GetGameID(), GameScript)
end