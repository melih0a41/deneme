/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if (not SERVER) then return end
zpiz = zpiz or {}
zpiz.Pizza = zpiz.Pizza or {}

function zpiz.Pizza.Initialize(Pizza)
	Pizza:SetModel(Pizza.Model)
	Pizza:PhysicsInit( SOLID_VPHYSICS )
	Pizza:SetMoveType( MOVETYPE_VPHYSICS )
	Pizza:SetSolid( SOLID_VPHYSICS )
	Pizza:SetUseType(SIMPLE_USE)
	Pizza:SetCollisionGroup(COLLISION_GROUP_WEAPON )
	Pizza:SetTrigger(true)
	local phys = Pizza:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
	Pizza:UseClientSideAnimation()

	Pizza.NeededIngredients = {}
	Pizza.InOven = false
	Pizza.Delivered = false
end

util.AddNetworkString("zpiz_pizza_open")
function zpiz.Pizza.OnUse(Pizza,ply)
	local pizzaState = Pizza:GetPizzaState()
	if (pizzaState == 3 or pizzaState == 4) then

		if (Pizza.InOven == false) then
			zpiz.Pizza.Eat(Pizza,Pizza:GetPizzaID(),ply)
		end
	elseif zpiz.Player.CanInteract(ply,Pizza) and Pizza:GetPizzaState() == 0 then

		net.Start("zpiz_pizza_open")
		net.WriteEntity(Pizza)
		net.Send(ply)

		ply._zpiz_dough = Pizza
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

function zpiz.Pizza.Touch(Pizza,other)
	if not IsValid(other) then return end
	//if string.sub(other:GetClass(), 1, 11) ~= "zpiz_ing" then return end

	if other:GetClass() ~= "zpiz_ingredient" then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

	if zclib.util.CollisionCooldown(other) then return end

	local cook = zpiz.Player.GetNearPizzaChef(other)
	if (cook and Pizza:GetPizzaState() == 1) then
		zpiz.Pizza.AddIngredient(Pizza,other)
	end
end



////// Select Recipe
util.AddNetworkString("zpiz_pizza_select")
net.Receive("zpiz_pizza_select", function(len, ply)
	if not IsValid(ply) then return end
	if zclib.Player.Timeout(nil,ply) then return end

	local val = net.ReadUInt(16)
	local dough = net.ReadEntity()

	if not IsValid(dough) then return end
	if dough:GetClass() ~= "zpiz_pizza" then return end
	if zclib.util.InDistance(ply:GetPos(), dough:GetPos(), 300) == false then return end
	if not ply:Alive() then return end
	if dough:GetPizzaID() ~= -1 then return end

	zpiz.Pizza.SelectRecipe(dough,val)
end)
function zpiz.Pizza.SelectRecipe(Pizza,pizzaID)
	local pizzaData = zpiz.config.Pizza[pizzaID]
	if pizzaData == nil then return end

	Pizza.SelectedRecipe = pizzaData.Name
	Pizza:SetPizzaID(pizzaID)
	table.Empty(Pizza.NeededIngredients)

	for k, v in pairs(zpiz.Pizza.GetRecipe(pizzaID)) do
		for i = 1, v do
			table.insert(Pizza.NeededIngredients, k)
		end
	end

	// This Updates the Visual Ingrediens Indicator on Client
	net.Start("zpiz_pizza_update_ingredients")
	net.WriteEntity(Pizza)
	net.WriteUInt(table.Count(Pizza.NeededIngredients),16)
	for k,v in ipairs(Pizza.NeededIngredients) do
		net.WriteUInt(v,8)
	end
	net.Broadcast()

	Pizza:SetPizzaState(1)
	zpiz.Pizza.UpdateVisuals(Pizza)
end

//////


////// Add Ingredients
util.AddNetworkString("zpiz_pizza_update_ingredients")
util.AddNetworkString("zpiz_pizza_add_ingredients")
function zpiz.Pizza.AddIngredient(Pizza,ing)
	local ingID = ing:GetIngredientID()

	if zpiz.Pizza.NeedsIngredient(Pizza,ingID) then

		SafeRemoveEntity(ing)

		table.remove(Pizza.NeededIngredients, table.KeyFromValue(Pizza.NeededIngredients, ingID))

		// This Updates the Visual Ingrediens Indicator on Client
		net.Start("zpiz_pizza_update_ingredients")
		net.WriteEntity(Pizza)
		net.WriteUInt(table.Count(Pizza.NeededIngredients),16)
		for k,v in ipairs(Pizza.NeededIngredients) do
			net.WriteUInt(v,8)
		end
		net.Broadcast()

		net.Start("zpiz_pizza_add_ingredients")
		net.WriteEntity(Pizza)
		net.WriteUInt(ingID,16)
		net.Broadcast()

		if (table.Count(Pizza.NeededIngredients) <= 0) then

			Pizza:SetPizzaState(2)
			zpiz.Pizza.UpdateVisuals(Pizza)
		end
	end
end

//This returns true if the given ingredient is needed to make the pizza
function zpiz.Pizza.NeedsIngredient(Pizza,ing)
	local correctIngredient = false

	for k, v in pairs(Pizza.NeededIngredients) do
		if (v == ing) then
			correctIngredient = true
			break
		end
	end

	return correctIngredient
end
//////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70



function zpiz.Pizza.UpdateVisuals(Pizza)
	local state = Pizza:GetPizzaState()

	if state > 0 then
		Pizza:SetModel("models/zerochain/props_pizza/zpizmak_pizza.mdl")
		-- Pizza:PhysicsInit(SOLID_VPHYSICS)
		Pizza:SetMoveType(MOVETYPE_VPHYSICS)
		Pizza:SetSolid(SOLID_VPHYSICS)
		local phys = Pizza:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
			phys:EnableMotion(true)
		end

		Pizza:SetAngles(Angle(0, 0, 0))
	end

	if (state >= 2) then
		Pizza:SetSkin(1)
	end

	if (state >= 3) then
		Pizza:SetColor(zpiz.colors["brown01"])
	end

	if (state >= 4) then
		Pizza:SetColor(zpiz.colors["brown02"])
	end
end

function zpiz.Pizza.ItemStoreDrop(Pizza)
	Pizza:SetModel("models/zerochain/props_pizza/zpizmak_pizza.mdl")
	Pizza:PhysicsInit(SOLID_VPHYSICS)
	Pizza:SetMoveType(MOVETYPE_VPHYSICS)
	Pizza:SetSolid(SOLID_VPHYSICS)
	local phys = Pizza:GetPhysicsObject()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	Pizza:SetColor(zpiz.colors["brown01"])
	Pizza:SetSkin(1)
	Pizza:SetBakeTime(-1)
	Pizza:SetPizzaState(3)
end

function zpiz.Pizza.Eat(Pizza,PizzaID,ply)
	local health = zpiz.Pizza.GetHealth(PizzaID)

	if (health > 0) then
		if (pizzaState == 4) then
			health = health * 0.3
		end

		if zpiz.UseHungermod() then
			local newEnergy = math.Clamp((ply:getDarkRPVar("Energy") or 100) + (health or 1), 1, 100)
			ply:setDarkRPVar("Energy", newEnergy)
		else
			local newHealth = ply:Health() + health

			if zpiz.config.HealthCap then
				newHealth = math.Clamp(newHealth, 1, ply:GetMaxHealth())
			end

			ply:SetHealth(newHealth)
		end

		ply:EmitSound("zpiz_eat")
	end

	if (pizzaState == 3) then
		zclib.Notify(ply, zpiz.language.PizzaConsum_Good[ math.random( #zpiz.language.PizzaConsum_Good ) ], 0)
	elseif (pizzaState == 4) then
		zclib.Notify(ply, zpiz.language.PizzaConsum_Bad[ math.random( #zpiz.language.PizzaConsum_Bad ) ], 1)
	end

	// Call Pizza Eat Hook
	hook.Run("zpiz_OnPizzaEaten" ,ply, PizzaID)

	if IsValid(Pizza) then SafeRemoveEntity(Pizza) end
end


concommand.Add("zpiz_pizza_all", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) == false then return end
	local tr = ply:GetEyeTrace()
	if tr == nil or tr.HitPos == nil then return end

	undo.Create("zpiz_pizza_all")
	for k,v in pairs(zpiz.config.Pizza) do
		local ent = ents.Create("zpiz_pizza")
		ent:SetPos(tr.HitPos + Vector(25 * k,0,15))
		ent:Spawn()
		ent:Activate()
		zclib.Player.SetOwner(ent, ply)
		ent:SetPizzaID(k)
		ent:SetPizzaState(3)
		zpiz.Pizza.UpdateVisuals(ent)
		undo.AddEntity(ent)
	end
	undo.SetPlayer(ply)
	undo.Finish()
end)
