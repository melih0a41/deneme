AddCSLuaFile()
DEFINE_BASECLASS( "minigame_bigsquare" )

--[[------------------------------------------------
                Minigame Small Square
------------------------------------------------]]--

ENT.PrintName = "Minigame Box Game Square"

function ENT:Initialize()
    BaseClass.Initialize( self )

    self:SetModel("models/hunter/blocks/cube3x3x025.mdl")
    self:SetSubMaterial(0, "minigames/myplastic")

    -- No fear no more
    if CLIENT then return end

    function self:IsBoxActive()
        return self:GetState() == 2
    end

    self:SetTrigger(true)
end

function ENT:Touch(ent)
    if not Minigames.GetOwnerGame(self:Getowning_ent()):IsActive() then return end

    if
        self:IsBoxActive() and
        ent:IsPlayer()
    then
        local InGame, Owner = Minigames.PlayerInGame(ent)
        if InGame and ( Owner == self:Getowning_ent() ) then
            ent:Kill()
        end
    end
end