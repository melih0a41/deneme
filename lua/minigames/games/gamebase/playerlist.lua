--[[--------------------------------------------
            Minigame Module - PlayerList
--------------------------------------------]]--

util.AddNetworkString("Minigames.DoPlayerListAction")
util.AddNetworkString("Minigames.BroadcastGameJoin")

local PlayerListAction = {
    ADD = 1,
    REMOVE = 2,
    TOGGLE = 3,
    SENDTOGAME = 4,
    SENDTOOLDPOS = 5,
    SENDTOSPAWN = 6,
    MUTE = 7,
    UNMUTE = 8
}

local FuncPlayerListAction = {
    [PlayerListAction.ADD]      = function( Game, Player ) Game:AddPlayer(Player) end,
    [PlayerListAction.REMOVE]   = function( Game, Player ) Game:RemovePlayer(Player) end,
    [PlayerListAction.TOGGLE]   = function( Game, Player ) Game:TogglePlayer(Player) end,
    [PlayerListAction.SENDTOGAME]   = function( Game, Player ) Game:TeleportPlayer(Player) end,
    [PlayerListAction.SENDTOOLDPOS] = function( Game, Player ) Minigames.ReturnPlayer(Player) end,
    [PlayerListAction.SENDTOSPAWN]  = function( Game, Player ) Player:Spawn() end,
    [PlayerListAction.MUTE]     = function( Game, Player ) Game:MutePlayer(Player) end,
    [PlayerListAction.UNMUTE]   = function( Game, Player ) Game:UnmutePlayer(Player) end
}

--[[----------------------------
      PlayerList Functions
----------------------------]]--

function Minigames.PlayerListAction( Owner, TargetPlayer, Action )
    Minigames.Checker(Owner, "player", 1)
    Minigames.Checker(TargetPlayer, "player", 2)
    Minigames.Checker(Action, "number", 3)

    if Action == PlayerListAction.SENDTOOLDPOS then
        FuncPlayerListAction[Action](nil, TargetPlayer)
        return
    end

    local GameScript = Minigames.GetOwnerGame(Owner)
    if not GameScript then return end

    if not FuncPlayerListAction[Action] then
        GameScript.ThrowError("The player list action is invalid.", Action, "number")
    end

    FuncPlayerListAction[Action](GameScript, TargetPlayer)
end

net.Receive("Minigames.DoPlayerListAction", function(_, ply)
    if not Minigames.IsAllowed(ply) then return end

    local TargetPlayer = net.ReadPlayer()
    local Action = net.ReadUInt(4)

    Minigames.PlayerListAction(ply, TargetPlayer, Action)
end)

--[[----------------------------
            Broadcast
----------------------------]]--

function Minigames.CurrentBroadcast()
    return GetGlobal2Entity("Minigames.CurrentGameWaiting", NULL)
end

local function EnableBroadcastGameJoin(GameScript)
    hook.Add("PlayerSay", "Minigames.BroadcastGameJoin", function(ply, str, toteam)
        if toteam then return end
        if GameScript:HasPlayer(ply) then return end
        if ( string.lower(str) ~= Minigames.Config["JoinGameCommand"] ) then return end

        GameScript:AddPlayer(ply)

        if Minigames.Config["JoinGameCommandTeleport"] then
            GameScript:TeleportPlayer(ply)
        end

        return ""
    end)


    SetGlobal2Entity("Minigames.CurrentGameWaiting", GameScript:GetOwner())

    net.Start("Minigames.BroadcastGameJoin")
        net.WriteBool(true)
    net.Broadcast()
end

local function DisableBroadcastGameJoin()
    hook.Remove("PlayerSay", "Minigames.BroadcastGameJoin")
    SetGlobal2Entity("Minigames.CurrentGameWaiting", NULL)

    net.Start("Minigames.BroadcastGameJoin")
        net.WriteBool(false)
    net.Broadcast()
end

function MinigameObject:BroadcastGameJoin()
    if Minigames.Config["JoinGameCommandEnabled"] == false then return end

    local CurrentGameWaiting = GetGlobal2Entity("Minigames.CurrentGameWaiting", NULL)
    if IsValid(CurrentGameWaiting) then
        Minigames.BroadcastMessage( Minigames.GetPhrase("playerlist.broadcast.alreadywaiting"), self:GetOwner() )
        return
    end

    EnableBroadcastGameJoin(self)

    timer.Create("Minigames.BroadcastGameJoin", Minigames.Config["JoinGameCommandTime"], 1, function()
        DisableBroadcastGameJoin()
    end)

    Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("playerlist.broadcast.join"), self:GetOwner(), Minigames.Config["JoinGameCommand"] ) )
end

net.Receive("Minigames.BroadcastGameJoin", function(len, ply)
    if not Minigames.IsAllowed(ply) then return end

    local GameScript = Minigames.GetOwnerGame(ply)
    if not GameScript then return end

    GameScript:BroadcastGameJoin()
end)

hook.Add("Minigames.PreRemoveGame", "Minigames.BroadcastGameJoin", function(Owner)
    if ( GetGlobal2Entity("Minigames.CurrentGameWaiting", NULL) ~= Owner ) then return end

    timer.Remove("Minigames.BroadcastGameJoin")
    DisableBroadcastGameJoin()

    Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("playerlist.broadcast.gameremoved"), Owner ) )
end)

hook.Add("Minigames.GameStart", "Minigames.BroadcastGameJoin", function(Owner, GameScript)
    local Players = GameScript:GetPlayers(true)
    if #Players == 1 and Players[1] == Owner then return end
    if #Players < 1 then return end

    Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("playerlist.broadcast.gamestarted"), Owner ) )

    if ( GetGlobal2Entity("Minigames.CurrentGameWaiting", NULL) ~= Owner ) then return end

    timer.Remove("Minigames.BroadcastGameJoin")
    DisableBroadcastGameJoin()
end)