--[[------------------------------------------------
                    Minigame Prop
------------------------------------------------]]--

AddCSLuaFile()

--[[--------------------
          Main
--------------------]]--

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Minigame Prop"
ENT.Category = "Minigame Tool Assistant"

ENT.Spawnable = false
ENT.AdminOnly = true


--[[--------------------
        Functions
--------------------]]--

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    self:DrawShadow(false)
end