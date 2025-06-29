AddCSLuaFile()
DEFINE_BASECLASS( "minigame_square_base" )

--[[------------------------------------------------
                    Minigame Square
------------------------------------------------]]--

ENT.PrintName = "Minigame Square"

function ENT:Initialize()
    BaseClass.Initialize( self )

    self:SetModel("models/props_phx/construct/plastic/plastic_panel2x2.mdl")
    self:SetType("minigame_square")

    -- Materials
    local Materials = self:GetMaterials()
    for k, v in ipairs( Materials ) do
        self:SetSubMaterial(k-1, string.Replace( v, "phoenix_storms", "minigames" ))
    end
end