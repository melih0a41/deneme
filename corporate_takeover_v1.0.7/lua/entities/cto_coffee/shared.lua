ENT.Type 				= "anim"
ENT.Base 				= "cto_base"

ENT.PrintName 			= "Coffee"
ENT.Author 				= "KiwontaTv"
ENT.Contact 			= "https://steamcommunity.com/id/KiwontaTv"
ENT.Purpose 			= ""
ENT.Instructions 		= ""
ENT.Category 			= "Corporate Takeover" 
ENT.Spawnable 			= false
ENT.Energy = 50
ENT.health = 20

function ENT:SetupDataTables()
    self:NetworkVar('Entity', 0, 'owning_ent')
end