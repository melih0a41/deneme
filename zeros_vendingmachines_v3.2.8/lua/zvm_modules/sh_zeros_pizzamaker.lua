/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Pizzamaker
//https://www.gmodstore.com/market/view/zero-s-pizzamaker-food-script

zvm.Definition.Add("zpiz_ingredient", {
	OnItemDataCatch = function(data, ent)
		data.ing_id = ent:GetIngredientID()
	end,
	OnItemDataApply = function(data, ent)
		local ingredientData = zpiz.Ingredient.GetData(data.ing_id)
		if ingredientData == nil then return end
		ent:SetIngredientID(data.ing_id)
		ent:SetModel(ingredientData.model)
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS)
		ent:PhysWake()
	end,
	OnItemDataName = function(data, ent) return zpiz.Ingredient.GetName(data.ing_id) end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.ing_id == data.ing_id end
})

zvm.Definition.Add("zpiz_pizza", {
	OnItemDataCatch = function(data, ent)
		data.pizza_id = ent:GetPizzaID()
	end,
	OnItemDataApply = function(data, ent)
		if data.pizza_id == -1 then return end
		ent:SetModel("models/zerochain/props_pizza/zpizmak_pizza.mdl")
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS)
		local phys = ent:GetPhysicsObject()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion(true)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

		ent:SetColor(zpiz.colors[ "brown01" ])
		ent:SetSkin(1)
		ent:SetBakeTime(-1)
		ent:SetPizzaState(3)
		ent:SetPizzaID(data.pizza_id)
	end,
	OnItemDataName = function(data, ent)
		if data.pizza_id == -1 then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

		return zpiz.Pizza.GetName(data.pizza_id)
	end,
	BlockItemCheck = function(other, Machine)
		if other:GetPizzaState() >= 4 or other:GetPizzaState() == 1 or other:GetPizzaState() == 2 then return true end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.pizza_id == data.pizza_id end
})

zclib.Snapshoter.SetPath("zpiz_pizza", function(ItemData)
	if ItemData.extraData.pizza_id and ItemData.extraData.pizza_id > 0 then return "zpiz/" .. ItemData.extraData.pizza_id end
end)

hook.Add("zclib_PostRenderProductImage", "zclib_PostRenderProductImage_ZerosPizzamaker", function(cEnt, ItemData)
	if zpiz and ItemData.class == "zpiz_pizza" and ItemData.extraData and ItemData.extraData.pizza_id ~= -1 then
		local pizzaIcon = zpiz.Pizza.GetIcon(ItemData.extraData.pizza_id)

		if pizzaIcon then
			cam.Start3D2D(cEnt:LocalToWorld(Vector(0, 0, 2)), cEnt:GetAngles(), 1)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(pizzaIcon)
			surface.DrawTexturedRect(-11, -11, 22, 22)
			cam.End3D2D()
		end
	end
end)
