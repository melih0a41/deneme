ENT.Type 				= "anim"
ENT.Base 				= "cto_base"

ENT.PrintName 			= "CTO Desk base"
ENT.Author 				= "KiwontaTv"
ENT.Contact 			= "https://steamcommunity.com/id/KiwontaTv"
ENT.Purpose 			= ""
ENT.Instructions 		= ""
ENT.Category 			= "Corporate Takeover" 
ENT.Spawnable 			= false
ENT.AdminSpawnable 		= false
ENT.XP = true

function ENT:SetupDataTables()
    self:NetworkVar('Entity', 0, 'owning_ent')

    self:NetworkVar("Int", 0, "CorpID")
    self:NetworkVar("Int", 1, "WorkerID")
    self:NetworkVar("Int", 2, "WorkerEnergy")

    self:NetworkVar("Float", 0, "TickTime")

    self:NetworkVar("Float", 1, "FullProfit")
    self:NetworkVar("Float", 2, "Profit")
    self:NetworkVar("Float", 3, "Loss")
    self:NetworkVar("Float", 4, "ProfitDiff")

    self:NetworkVar("Bool", 0, "Working")
    self:NetworkVar("Bool", 1, "Sleeping")

    self:NetworkVar("String", 0, "DeskClass")
    self:NetworkVar("String", 1, "WorkerName")
end