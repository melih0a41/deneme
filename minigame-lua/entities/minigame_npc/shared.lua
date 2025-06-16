--[[------------------------------------------------
                    Minigame NPC
------------------------------------------------]]--

ENT.Base = "base_nextbot"

ENT.PrintName = "Test Entity"
ENT.Author = "vicentefelipechile"
ENT.Contact = "STEAM_0:1:194224658"
ENT.Purpose = "A \"thinkable\" entity for minigames."

ENT.Category = "Minigames"
ENT.Spawnable = true



--[[----------------------------
            Functions
----------------------------]]--

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("String", 0, "Nickname")
    self:NetworkVar("Int", 0, "State")
end

function ENT:Nick()
    return self:GetNickname()
end

ENT.Name = ENT.Nick


--[[----------------------------
           Server-Side
----------------------------]]--

if CLIENT then return end

ENT.Model = "models/player/dewobedil/the_rising_of_the_shield_hero/raphtalia/default_f.mdl"
ENT.LookUncannyToPlayers = true
ENT.LastTarget = NULL

ENT.MG_MODULES = {}