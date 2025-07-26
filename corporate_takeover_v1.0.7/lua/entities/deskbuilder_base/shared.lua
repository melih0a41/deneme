ENT.Type 				= "anim"
ENT.Base 				= "cto_base"

ENT.PrintName 			= "Desk Builder"
ENT.Author 				= "KiwontaTv"
ENT.Contact 			= "https://steamcommunity.com/id/KiwontaTv"
ENT.Purpose 			= ""
ENT.Instructions 		= ""
ENT.Category 			= "Corporate Takeover" 
ENT.Spawnable 			= false
ENT.AdminSpawnable 		= false

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 1, "owning_ent")

    self:NetworkVar("String", 0, "DeskClass")

    self:NetworkVar("Int", 0, "CorpID")
end