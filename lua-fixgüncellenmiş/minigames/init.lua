--[[--------------------------------------------
              Minigame Server-Side
--------------------------------------------]]--

util.AddNetworkString("Minigames.GameScript")
util.AddNetworkString("Minigames.GameScriptPlayers")
util.AddNetworkString("Minigames.GameToggle")
util.AddNetworkString("Minigames.ToolRollUp")
util.AddNetworkString("Minigames.RefreshFiles")
util.AddNetworkString("Minigames.Message")
util.AddNetworkString("Minigames.SetupMenu")
util.AddNetworkString("Minigames.TransmitData")
util.AddNetworkString("Minigames.ToolTip")
util.AddNetworkString("Minigames.PlayerMusicReady")

--[[----------------------------
        Network Functions
----------------------------]]--

function Minigames.BroadcastMessage(str, ply, prefix)
    prefix = prefix or "Minigames Tool"

    net.Start("Minigames.Message")
        net.WriteString(str)
        net.WriteString(prefix)
    if IsValid(ply) and ( ply:IsPlayer() or istable(ply) ) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function Minigames.SendToolTip(ply, gameid)
    net.Start("Minigames.ToolTip")
        net.WriteString(gameid)
    net.Send(ply)
end

--[[----------------------------
        Weapon Functions
----------------------------]]--

local SavedWeapons = {}

function Minigames.StripWeapons(ply)
    if not IsValid(ply) then return end
    if ply:GetClass() == "minigame_npc" then return end

    local PlayerWeapons = {
        ["weapons"] = {},
        ["ammo"] = ply:GetAmmo()
    }

    for _, wep in ipairs( ply:GetWeapons() ) do
        table.insert(PlayerWeapons["weapons"], wep:GetClass())
    end

    SavedWeapons[ ply ] = PlayerWeapons

    if Minigames.ActiveGames[ ply ] then return end
    ply:StripWeapons()
end

function Minigames.GiveWeapons(ply)
    if not IsValid(ply) then return end
    if ply:GetClass() == "minigame_npc" then return end
    if not SavedWeapons[ ply ] then return end
    if #ply:GetWeapons() == #SavedWeapons[ ply ]["weapons"] then return end

    if ply:Alive() then
        ply:StripWeapons()

        local PlayerWeapons = SavedWeapons[ ply ]
        for _, wep in ipairs( PlayerWeapons["weapons"] ) do
            ply:Give(wep)
        end

        for id, ammo in ipairs( PlayerWeapons["ammo"] ) do
            ply:GiveAmmo(ammo, id)
        end

        SavedWeapons[ ply ] = nil
    else
        local PreviousTeam = ply:Team()
        hook.Add("PlayerSpawn", "Minigames.PostGameDeath." .. ply:SteamID(), function(PostPly)
            if ( PostPly ~= ply) then return end

            if ( PostPly:Team() == PreviousTeam ) then
                Minigames.GiveWeapons(PostPly)
            end

            hook.Remove("PlayerSpawn", "Minigames.PostGameDeath." .. ply:SteamID())
        end)
    end
end

--[[----------------------------
          Util Functions
----------------------------]]--

function Minigames.GameStart( GameScript )
    local Owner = GameScript:GetOwner()

    GameScript:GenerateHooks()
    GameScript:SetActive(true)

    if Minigames.Config["ForceDisableNoclip"] then
        for _, ply in ipairs( GameScript:GetPlayers(true) ) do
            ply:SetMoveType(MOVETYPE_WALK)
        end
    end

    Minigames.SendToolTip(Owner, GameScript:GetGameID())

    hook.Run("Minigames.GameStart", Owner, GameScript)

    net.Start("Minigames.GameToggle")
        net.WriteEntity(Owner)
        net.WriteBool(true)
    net.Broadcast()

    return true
end

function Minigames.GameStop( GameScript )
    GameScript:StopAllWorldSounds()
    GameScript:PlayGameEndSound()

    GameScript:RemoveAllPlayers(true)
    GameScript:RemoveHooks()

    GameScript:SetActive(false)

    hook.Run("Minigames.GameStop", GameScript)

    net.Start("Minigames.GameToggle")
        net.WriteEntity(GameScript:GetOwner())
        net.WriteBool(false)
    net.Broadcast()

    return true
end



--[[----------------------------
            Tool Events
----------------------------]]--

function Minigames.RunEvent.LeftClick(trace, owner)
    local Result = false
    if not Minigames.IsAllowed(owner) then return Result end

    local GameToSpawn = owner:GetInfo("minigames_game")
    if Minigames.Games[ GameToSpawn ] == nil then
        Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("minigames.error.gamedontexists"), GameToSpawn ), owner )

        return Result
    end

    local GameScript = Minigames.GetOwnerGame( owner )
    if ( GameScript == nil ) then
        GameScript = table.Copy( Minigames.Games[ GameToSpawn ] )
        GameScript:CreateNewActiveGame( owner )

        Minigames.ActiveGames[ owner ] = GameScript

        Result = GameScript:LeftClick( trace, owner, true )
    else
        Result = GameScript:LeftClick( trace, owner, false )
    end

    return Result
end

function Minigames.RunEvent.RightClick(trace, owner)
    local Result = false

    if not Minigames.IsAllowed(owner) then return end
    if not Minigames.ActiveGames[ owner ] then return end

    Result = Minigames.ActiveGames[ owner ]:RightClick( trace, owner )

    return Result
end

--[[----------------------------
               Hooks
----------------------------]]--

hook.Add("CanUndo", "Minigames.CanUndo", function(owner, tbl)
    if table.IsEmpty(tbl) then return end
    if tbl.Name == nil then return end

    local UndoInfo = string.Split( tbl.Name, "." )
    if ( #UndoInfo == 3 ) and ( UndoInfo[1] == "minigame" ) then
        local GameScript = Minigames.GetOwnerGame( owner )

        if GameScript then
            if GameScript:IsActive() then
                Minigames.BroadcastMessage( Minigames.GetPhrase("minigames.error.gameisactive"), owner )

                return false
            else
                GameScript:SafeRemoveActiveGame()
            end
        end
    end
end)

hook.Add("PreCleanupMap", "Minigames.PostCleanup", function()
    --[[----------------------------
          Remove Owner Minigame
    ----------------------------]]--
    for owner, GameScript in pairs( Minigames.ActiveGames ) do
        if ( IsValid( owner ) and IsValid(GameScript) ) then
            Minigames.ActiveGames[ owner ]:SafeRemoveActiveGame()
        end
    end

    --[[----------------------------
         Reset all Active Games
    ----------------------------]]--
    Minigames.ActiveGames = {}

    net.Start("Minigames.NewGame")
        net.WriteBool(false)
    net.Broadcast()
end)

hook.Add("PlayerDisconnected", "Minigames.DisconnectFallback", function(ply)
    --[[----------------------------
         Remove Player from Game
    ----------------------------]]--
    local steamid = ply:SteamID()
    local InGame, Owner = Minigames.PlayerInGame( ply )
    if InGame and ( Owner ~= ply ) then
        Minigames.ActiveGames[ Owner ]:RemovePlayer( ply )
    end

    hook.Remove("PlayerSpawn", "Minigames.PostGameDeath." .. ply:SteamID())

    --[[----------------------------
          Remove Owner Minigame
    ----------------------------]]--

    if Minigames.ActiveGames[ ply ] then
        local WhatUndo = nil

        -- This thing is VERY expensive
        for _, MegaTable in ipairs( undo.GetTable() ) do
            if istable( WhatUndo ) then break end

            for _, tbl in ipairs( MegaTable ) do
                if tbl["Name"] then
                    local Parts = string.Split(tbl["Name"], ".")
                    if ( Parts[1] == "minigame" ) and ( Parts[3] == steamid ) then
                        WhatUndo = tbl
                        break
                    end
                end
            end
        end

        undo.Do_Undo(WhatUndo)
        Minigames.ActiveGames[ ply ]:SafeRemoveActiveGame()
    end
end)

hook.Add("PlayerNoClip", "Minigames.NoclipFallback", function(ply, InNoclip)
    if not Minigames.Config["ForceDisableNoclip"] then return end

    local InGame, Owner = Minigames.PlayerInGame(ply)
    if ( InGame ) then
        if not InNoclip then
            return true
        end

        if Owner == ply and not Minigames.ActiveGames[ ply ]:IsActive() then
            return true
        end

        return false
    end
end)

hook.Add("PlayerButtonDown", "Minigames.ToggleGameCS", function(ply, button)
    if Minigames.IsAllowed( ply ) and ( Minigames.Config["ToggleGameShortcut"] == button ) then
        Minigames.RunEvent.RightClick(ply:GetEyeTrace(), ply)
    end
end)

-- Prevent players from take any type of damage if they are in a minigame
hook.Add("EntityTakeDamage", "Minigames.PreventDamage", function(target, dmginfo)
    if not Minigames.Config["DisableDamageInGame"] then return end
    if not ( IsValid(target) and target:IsPlayer() ) then return end

    local InGame, _ = Minigames.PlayerInGame(target)
    if InGame then
        return true
    end
end)

hook.Remove("EntityTakeDamage", "Minigames.PreventDamage")

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

--[[----------------------------
            Network
----------------------------]]--

net.Receive("Minigames.SetupMenu", function(_, ply)
    if not Minigames.IsAllowed(ply) then return end

    local trace = ply:GetEyeTrace()
    Minigames.RunEvent.RightClick(trace, ply)
end)

--[[----------------------------
            Gamemode
----------------------------]]--

Minigames.AddInc("minigames/sandbox.lua")

if ( DarkRP or engine.ActiveGamemode() == "darkrp" ) then
    Minigames.AddInc("minigames/darkrp.lua")
end