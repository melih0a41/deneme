AddCSLuaFile()
DEFINE_BASECLASS( "minigame_square_base" )

--[[------------------------------------------------
                Minigame Small Square
------------------------------------------------]]--

ENT.PrintName = "Minigame Small Square"

function ENT:Initialize()
    BaseClass.Initialize( self )

    self:SetModel("models/props_phx/construct/metal_plate1.mdl")
    self:SetType("minigame_smallsquare")

    -- Materials
    local Materials = self:GetMaterials()
    for k, v in ipairs( Materials ) do
        self:SetSubMaterial(k-1, string.Replace( v, "phoenix_storms", "minigames" ))
    end
end