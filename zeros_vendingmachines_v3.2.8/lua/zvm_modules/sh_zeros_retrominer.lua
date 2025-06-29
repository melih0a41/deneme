/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
// Zero´s RetroMiner
// https://www.gmodstore.com/market/view/zero-s-retrominer-mining-script
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zvm.Definition.Add("zrms_basket", {
	OnItemDataCatch = function(data, ent)
		data.ResourceAmount = ent:GetResourceAmount()
		data.ResourceType = ent:GetResourceType()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetResourceAmount(data.ResourceAmount)
		ent:SetResourceType(data.ResourceType)
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		zrmine.f.SetOwner(ent, ply)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zvm.Definition.Add("zrms_gravelcrate", {
	OnItemDataCatch = function(data, ent)
		data.Iron = ent:GetIron()
		data.Bronze = ent:GetBronze()
		data.Silver = ent:GetSilver()
		data.Gold = ent:GetGold()
		data.Coal = ent:GetCoal()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetIron(data.Iron)
		ent:SetBronze(data.Bronze)
		ent:SetSilver(data.Silver)
		ent:SetGold(data.Gold)
		ent:SetCoal(data.Coal)
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		zrmine.f.SetOwner(ent, ply)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zvm.Definition.Add("zrms_storagecrate", {
	OnItemDataCatch = function(data, ent)
		data.bIron = ent:GetbIron()
		data.bBronze = ent:GetbBronze()
		data.bSilver = ent:GetbSilver()
		data.bGold = ent:GetbGold()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetbIron(data.bIron)
		ent:SetbBronze(data.bBronze)
		ent:SetbSilver(data.bSilver)
		ent:SetbGold(data.bGold)
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		zrmine.f.SetOwner(ent, ply)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
