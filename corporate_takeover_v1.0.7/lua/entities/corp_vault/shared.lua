ENT.Type 				= "anim"
ENT.Base 				= "cto_base"

ENT.PrintName 			= "Corporate Vault"
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

    self:NetworkVar("Bool", 0, "DoorOpen")
end