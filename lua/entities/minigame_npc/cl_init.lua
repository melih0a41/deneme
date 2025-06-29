--[[------------------------------------------------
                    Minigame NPC
------------------------------------------------]]--

include("shared.lua")

function ENT:Initialize()
    -- TO DO
end


net.Receive("NPCBot.Comment", function()
    local Pos = net.ReadVector()
    local Response = net.ReadString()

    EmitSound( Response, Pos, 0, CHAN_AUTO, 1, Minigames.Config["BotTalkVolume"], 0, 100 )
end)