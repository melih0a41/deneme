--[[------------------------------------------------
           Minigame NPC - Speak / Comments
------------------------------------------------]]--

util.AddNetworkString("Minigames.NPCComment")

--[[----------------------------
          NPC Comments
----------------------------]]--

local DefaultNPCSound = {
    ["Positive"] = {
        "vo/npc/male01/ok01.wav",
        "vo/npc/male01/yeah02.wav",
        "vo/npc/male01/squad_affirm04.wav",
    },

    ["Negative"] = {
        "vo/npc/male01/no02.wav",
        "vo/npc/male01/sorry01.wav",
        "vo/npc/male01/answer37.wav",
        "vo/npc/male01/answer39.wav",
    },

    ["Comments"] = {
        "vo/npc/male01/finally.wav",
        "vo/npc/male01/whoops01.wav",
        "vo/npc/male01/uhoh.wav",
        "vo/npc/male01/squad_affirm06.wav",
    }
}

function ENT:Comment(SoundStr)
    if CLIENT then return end
    if not self:IsNPC() then return end
    if not Minigames.Config["BotsCanTalk"] then return end

    SoundStr = SoundStr or DefaultNPCSound["Comments"][ math.random( #DefaultNPCSound["Comments"] ) ]

    net.Start("Minigames.NPCComment")
        net.WriteVector( self:GetPos() )
        net.WriteString( SoundStr )
    net.Broadcast()
end

function ENT:PositiveComment()
    local SoundStr = DefaultNPCSound["Positive"][ math.random( #DefaultNPCSound["Positive"] ) ]

    self:Comment(SoundStr)
end

function ENT:NegativeComment()
    local SoundStr = DefaultNPCSound["Negative"][ math.random( #DefaultNPCSound["Negative"] ) ]

    self:Comment(SoundStr)
end

hook.Add("InitPostEntity", "Minigames.UpdateDefaultDummySound", function()
    DefaultDummySound = Minigames.Config["BotComment"]
end)