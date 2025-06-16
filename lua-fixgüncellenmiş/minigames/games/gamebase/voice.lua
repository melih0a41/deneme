--[[--------------------------------------------
            Minigame Module - Voice
--------------------------------------------]]--

local PlayerVoiceGrid = {}
local PlayerLinkedTo = {}
local PlayerMuted = {}

--[[----------------------------
         Main Functions
----------------------------]]--

function MinigameObject:MutePlayer(ply)
    self:Checker(ply, "player", 1)
    local Owner = self:GetOwner()

    if not PlayerVoiceGrid[ Owner ] then return end
    if not isbool(PlayerMuted[ ply ]) then return end

    PlayerMuted[ ply ] = true
end

function MinigameObject:UnmutePlayer(ply)
    self:Checker(ply, "player", 1)
    local Owner = self:GetOwner()

    if not PlayerVoiceGrid[ Owner ] then return end
    if not isbool(PlayerMuted[ ply ]) then return end

    PlayerMuted[ ply ] = false
end

--[[----------------------------
              Hooks
----------------------------]]--

hook.Add("Minigames.TogglePlayer", "Minigames.TogglePlayerVoice", function(ply, owner, joined)
    if not PlayerVoiceGrid[ owner ] then return end

    if joined then
        PlayerLinkedTo[ ply ] = owner
        PlayerMuted[ ply ] = false
    else
        PlayerLinkedTo[ ply ] = nil
        PlayerMuted[ ply ] = nil
    end
end)

hook.Add("Minigames.PostNewGame", "Minigames.AddOwnerToGrid", function(owner)
    PlayerVoiceGrid[ owner ] = {
        MuteAllPlayers = false,
        PlayersCanHearOwner = true,
        PlayersCanHearThemselves = true
    }

    PlayerLinkedTo[ owner ] = owner
end)

hook.Add("Minigames.PostRemoveGame", "Minigames.RemoveOwnerFromGrid", function(owner)
    PlayerLinkedTo[ owner ] = nil
    PlayerVoiceGrid[ owner ] = nil
end)

hook.Add("CanHearPlayersVoice", "Minigames.CanHearPlayersVoice", function(listener, talker)
    if not Minigames.Config["OwnerCanSetVoice"] then return end

    if not PlayerLinkedTo[ listener ] then return end
    if not PlayerLinkedTo[ talker ] then return end

    local Settings = PlayerLinkedTo[ listener ] and PlayerVoiceGrid[ listener ]

    if Settings.PlayersCanHearOwner and PlayerLinkedTo[ listener ] == talker then
        return true, false

    elseif Settings.MuteAllPlayers then
        return false

    elseif Settings.PlayersCanHearThemselves and PlayerLinkedTo[ talker ] == talker then
        return true, false
    end
end)