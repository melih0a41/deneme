ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money Stack"
ENT.Author = "Owain Owjo & The One Free-Man"
ENT.Category = "pVault"
ENT.Spawnable = false
ENT.AdminSpawnable = true

perfectVault.Core.RegisterEntity("pvault_stack_money", {
	-- General data
	general = {
		value = {d = 5000, t = "num"}, -- Max amount of money bags
		respawn = {d = 600, t = "num"}, -- Max amount of money bags
	},
	--Other
	other = {
		wanted = {d = true, t = "bool"}, -- Should the raider get wanted on cracking? 
			wantedReason = {d = "Stealing money from the bank", t = "string", r = "wanted"}, -- The wanted reason
		smartWant = {d = false, t = "bool"} -- Should the server try and predict the people assisting and want them too?
	}
},
"models/freeman/vault/pvault_moneywad.mdl")