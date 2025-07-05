/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

local ITEM = XeninInventory:CreateItemV2()
ITEM:SetMaxStack(1)
ITEM:SetModel("models/zerochain/props_pizza/zpizmak_pizza.mdl")

ITEM:SetDescription(function(self, tbl)
	return zpiz.Pizza.GetDesc(tbl.data.PizzaID)
end)

function ITEM:OnPickup(ply, ent)
	if (not IsValid(ent)) then return end
	if ent:GetPizzaState() < 3 then
		return
	end

	local info = {
		ent = self:GetEntityClass(ent),
		dropEnt = self:GetDropEntityClass(ent),
		amount = self:GetEntityAmount(ent),
		data = self:GetData(ent)
	}

	self:Pickup(ply, ent, info)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	return true
end

ITEM:AddDrop(function(self, ply, ent, tbl, tr)
	ent:SetPizzaID(tbl.data.PizzaID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	timer.Simple(0.1, function()
		if IsValid(ent) then
			zpiz.Pizza.ItemStoreDrop(ent)
		end
	end)

	zclib.Player.SetOwner(ent, ply)
end)

function ITEM:GetData(ent)
	return {
		PizzaID = ent:GetPizzaID(),
	}
end

function ITEM:GetDisplayName(item)
	return self:GetName(item)
end

function ITEM:GetName(item)
	local ent = isentity(item)
	local PizzaID = ent and item:GetPizzaID() or item.data.PizzaID
	return zpiz.Pizza.GetName(PizzaID)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

function ITEM:GetCameraModifiers(tbl)
	return {
		FOV = 40,
		X = 0,
		Y = -22,
		Z = 25,
		Angles = Angle(0, -190, 0),
		Pos = Vector(0, 0, -1)
	}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

function ITEM:GetClientsideModel(tbl, mdlPanel)
	mdlPanel.Entity:SetSkin(1)
end

ITEM:Register("zpiz_pizza")
