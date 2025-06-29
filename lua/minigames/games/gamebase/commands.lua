--[[--------------------------------------------
            Minigame Module - Commands
--------------------------------------------]]--

local COMMAND_TABLE = string.Split(Minigames.Config["JoinGameCommand"], " ")
local COMMAND = string.lower( COMMAND_TABLE[1] )

--[[----------------------------
            Commands
----------------------------]]--

hook.Add("PlayerSay", "Minigames.StopGame", function(ply, str)
    if not Minigames.IsAllowed(ply) then return end
    local GameScript = Minigames.GetOwnerGame(ply)

    if not GameScript then return end
    if not GameScript:IsActive() then return end

    str = string.Trim( string.lower( str ) )
    if ( str == "!stopgame" ) then
        GameScript:ToggleGame()
    end
end)

hook.Add("PlayerSay", "Minigames.JoinGame", function(ply, text, toteam)
    if toteam then return end
    if Minigames.PlayerIsPlaying(ply) then return end

    text = string.lower( string.Trim(text) )
    if not string.StartsWith(text, COMMAND) then return end

    local CommandArgs = string.Split(text, " ")
    if #CommandArgs ~= #COMMAND_TABLE then return end

    local params = {}
    for i, part in ipairs(COMMAND_TABLE) do
        if string.match(part, "^{.+}$") then
            local key = string.sub(part, 2, -2)
            params[key] = CommandArgs[i]
        elseif part ~= CommandArgs[i] then
            return
        end
    end

    if not params["id"] then return end
    local playerID = tonumber(params["id"])
    if not playerID then return end

    local GameScript = Minigames.GetOwnerGame( Player(playerID) )
    if not GameScript then return end

    GameScript:AddPlayer(ply, true)

    return ""
end)

hook.Add("PlayerSay", "Minigames.LeaveGame", function(ply, str)
    if string.Trim( string.lower(str) ) ~= Minigames.Config["LeaveGameCommand"] then return end

    local InGame, Owner = Minigames.PlayerInGame(ply)
    if not InGame then return end

    local GameScript = Minigames.GetOwnerGame(Owner)
    if not GameScript then return end

    GameScript:RemovePlayer(ply)
    Minigames.ReturnPlayer(ply)
    return ""
end)