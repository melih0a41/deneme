/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

ITEM.Name = "Vendingmachine Package"
ITEM.Description = "A package from the Vendingmachine."
ITEM.Model = "models/zerochain/props_vendingmachine/zvm_package.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetDescription()

	local _content = self:GetData("Content")

	local desc = ""
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

	for k, v in pairs(_content) do
		desc = desc .. v.name .. ", "
	end

	return self:GetData("Description", desc)
end

function ITEM:SaveData(ent)
	self:SetData("Content", ent.Content)
end

function ITEM:LoadData(ent)
	timer.Simple(0.1,function()
		if IsValid(ent) then
			ent.Content = {}
			table.CopyFromTo(self:GetData("Content"), ent.Content)
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ITEM:Drop(ply, container,slot,ent)
	if not IsValid(ent) then return end
	if zvm.Player.GetPackageCount(ply) >= zvm.config.Vendingmachine.PackageLimit then
		ent.Content = {}
		table.CopyFromTo(self:GetData("Content"), ent.Content)
		ply:PickupItem( ent )
		zclib.Notify(ply, zvm.language.General["BuyLimitReached"], 1)
	else
		zvm.Player.AddPackage(ply,ent)
		ent:SetPos(ent:GetPos() + Vector(0,0,20))
		zclib.Player.SetOwner(ent, ply)
	end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

function ITEM:CanPickup(ply, ent)
	if ent.IsOpening == true or ent.Wait == true then
		return false
	else
		return true
	end
end
