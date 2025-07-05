/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

ITEM.Name = "Pizza"
ITEM.Description = "A tasty Pizza"
ITEM.Model = "models/zerochain/props_pizza/zpizmak_pizza.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	return self:GetData("Name", zpiz.Pizza.GetName(self:GetData("PizzaID")))
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

function ITEM:GetDescription()
	local pizzaID = self:GetData("PizzaID")
	local desc = zpiz.Pizza.GetDesc(pizzaID) .. " | Health: " .. zpiz.Pizza.GetHealth(pizzaID) .. " | Price: " .. zclib.Money.Display(zpiz.Pizza.GetPrice(pizzaID))

	return self:GetData("Description", desc)
end

function ITEM:Use(ply, con, slot)
	zpiz.Pizza.Eat(nil,self:GetData("PizzaID"),ply)
	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

function ITEM:CanPickup(pl, ent)
	if ent:GetPizzaState() == 3 then
		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47

function ITEM:SaveData(ent)
	self:SetData("PizzaID", ent:GetPizzaID())
end

function ITEM:LoadData(ent)
	ent:SetPizzaID(self:GetData("PizzaID"))

	//Call function to change entity state to fully baked pizza
	timer.Simple(0.1, function()
		if IsValid(ent) then
			zpiz.Pizza.ItemStoreDrop(ent)
		end
	end)
end

function ITEM:Drop(ply, con, slot, ent)
	zclib.Player.SetOwner(ent, ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47
