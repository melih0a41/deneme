AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "deskbuilder_base"

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")

    self:NetworkVar("String", 0, "DeskClass")

    self:NetworkVar("Int", 0, "CorpID")

    timer.Simple(0, function()
        if !IsValid(self) then return end
        
        self:SetDeskClass("corporate_desk")
    end)
end