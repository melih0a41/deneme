AddCSLuaFile()
DEFINE_BASECLASS( "minigame_square_base" )

--[[------------------------------------------------
                Minigame Small Square
------------------------------------------------]]--

ENT.PrintName = "Minigame Big Square"

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube3x3x025.mdl")
    self:SetType("minigame_bigsquare")

    -- Materials
    self:SetSubMaterial(0, "minigames/myplastic")

    BaseClass.Initialize( self )
end