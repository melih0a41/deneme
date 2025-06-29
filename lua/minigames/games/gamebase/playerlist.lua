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
    [PlayerListAction.ADD]      = function( Game, Ply ) Game:AddPlayer(Ply) end,
    [PlayerListAction.REMOVE]   = function( Game, Ply ) Game:RemovePlayer(Ply) end,
    [PlayerListAction.TOGGLE]   = function( Game, Ply ) Game:TogglePlayer(Ply) end,
    [PlayerListAction.SENDTOGAME]   = function( Game, Ply ) if not Minigames.IsAllowedAdmin(Ply) then return end Game:TeleportPlayer(Ply) end,
    [PlayerListAction.SENDTOOLDPOS] = function( Game, Ply ) Minigames.ReturnPlayer(Ply) end,
    [PlayerListAction.SENDTOSPAWN]  = function( Game, Ply ) Ply:Spawn() end,
    [PlayerListAction.MUTE]     = function( Game, Ply ) Game:MutePlayer(Ply) end,
    [PlayerListAction.UNMUTE]   = function( Game, Ply ) Game:UnmutePlayer(Ply) end
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

local BROADCAST_WAIT_LIST = {}

net.Receive("Minigames.BroadcastGameJoin", function(len, ply)
    if not Minigames.IsAllowed(ply) then return end
    if BROADCAST_WAIT_LIST[ply] and BROADCAST_WAIT_LIST[ply] > CurTime() then return end

    local GameScript = Minigames.GetOwnerGame(ply)
    if not GameScript then return end
    if GameScript:IsActive() then return end

    BROADCAST_WAIT_LIST[ply] = CurTime() + Minigames.Config["JoinGameCommandDelay"]

    net.Start("Minigames.BroadcastGameJoin")
        net.WritePlayer(ply)
    net.Broadcast()
end)

hook.Add("Minigames.PreRemoveGame", "Minigames.BroadcastGameJoin", function(Owner)
    if BROADCAST_WAIT_LIST[Owner] == nil then return end
    if BROADCAST_WAIT_LIST[Owner] < CurTime() then return end

    BROADCAST_WAIT_LIST[Owner] = 0

    Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("playerlist.broadcast.gameremoved"), Owner ) )
end)

hook.Add("Minigames.GameStart", "Minigames.BroadcastGameJoin", function(Owner, GameScript)
    BROADCAST_WAIT_LIST[Owner] = 0

    local Players = GameScript:GetPlayers(true)
    if #Players == 1 and Players[1] == Owner then return end
    if #Players < 1 then return end

    Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("playerlist.broadcast.gamestarted"), Owner ) )
end)