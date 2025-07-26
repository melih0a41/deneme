ENT.Type 				= "anim"
ENT.Base 				= "cto_base"

ENT.PrintName 			= "Corporate Desk"
ENT.Author 				= "KiwontaTv"
ENT.Contact 			= "https://steamcommunity.com/id/KiwontaTv"
ENT.Purpose 			= ""
ENT.Instructions 		= ""
ENT.Category 			= "Corporate Takeover" 
ENT.Spawnable 			= false
ENT.AdminSpawnable 		= false

function ENT:SetupDataTables()
    self:NetworkVar('Entity', 0, 'owning_ent')

    self:NetworkVar("Int", 0, "CorpID")

    self:NetworkVar("String", 1, "DeskClass")
end