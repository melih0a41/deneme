ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.SetAutomaticFrameAdvance = true
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "Corporate Desk NPC"
ENT.Author = "KiwontaTv"
ENT.Category = "Corporate Takeover"
ENT.Instructions = "" 
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar('Bool', 0, 'Asleep')
end