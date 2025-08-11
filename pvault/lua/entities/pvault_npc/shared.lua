ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "NPC"
ENT.Author = "Owain Owjo & The One Free-Man"
ENT.Category = "pVault"
ENT.Spawnable = false
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Holding")
end

perfectVault.Core.RegisterEntity("pvault_npc", {
	-- General data
	general = {
		model = {d = "models/breen.mdl", t = "string"}, -- The NPC model
		negotiate = {d = true, t = "bool"} -- Should the NPC negotiate for a cut?
	},
	-- Snitch
	snitch = {
		snitch = {d = false, t = "bool"}, -- Should the NPC snitch on a bad deal?
		minChance = {d = 5, t = "num"}, -- The minimum chance that he snitches
		maxChance = {d = 20, t = "num"} -- The maximum chance that he snitches
	},
	-- Cut
	cut = {
		minCut = {d = 5, t = "num"}, -- The minimum cut the banker will take
		maxCut = {d = 15, t = "num"} -- The maximum cut the banker will take
	}
},
"models/breen.mdl")