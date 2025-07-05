/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if (not SERVER) then return end
zpiz = zpiz or {}
zpiz.Oven = zpiz.Oven or {}

function zpiz.Oven.Initialize(Oven)
	Oven:SetModel(Oven.Model)
	Oven:PhysicsInit(SOLID_VPHYSICS)
	Oven:SetMoveType(MOVETYPE_VPHYSICS)
	Oven:SetSolid(SOLID_VPHYSICS)
	Oven:SetUseType(SIMPLE_USE)
	Oven:SetTrigger(true)

	local phys = Oven:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	Oven:UseClientSideAnimation()

	local door01 = zpiz.Oven.CreateProp(Oven,"zpiz_animbase", Oven:LocalToWorld(Vector(22.3,-4,38.6)), Oven:LocalToWorldAngles(Angle(0,0,0)))

	local door02 = zpiz.Oven.CreateProp(Oven,"zpiz_animbase", Oven:LocalToWorld(Vector(22.3,-4,56.6)), Oven:LocalToWorldAngles(Angle(0,0,0)))

	Oven.PizzaCount = 0

	Oven.Busy = false

	Oven.PizzaSpots = {
		[1] = {
			ent = nil,
			door = door01
		},
		[2] = {
			ent = nil,
			door = door02
		},
	}
end

function zpiz.Oven.CreateProp(Oven,class, pos, ang)
	local ent = ents.Create(class)
	ent:SetModel("models/zerochain/props_pizza/zpizmak_ovendoor.mdl")
	ent:SetAngles(ang)
	ent:SetPos(pos)
	ent:SetParent(Oven)
	ent:Spawn()
	ent:Activate()
	ent.PhysgunDisabled = zpiz.config.DisablePhysgun
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

	return ent
end

function zpiz.Oven.StartTouch(Oven,other)
	if not IsValid(Oven) then return end
	if Oven.Busy == true then return end

	if not IsValid(other) then return end
	if other:GetClass() ~= "zpiz_pizza" then return end

	if zclib.util.CollisionCooldown(other) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47

	local cook = zpiz.Player.GetNearPizzaChef(other)
	if (cook and other:GetPizzaState() == 2 and other.InOven == false) then
		local freeID = zpiz.Oven.HasFreeSpot(Oven)

		if (freeID) then
			DropEntityIfHeld(other)
			timer.Simple(0,function()
				if IsValid(Oven) and IsValid(other) and freeID then
					zpiz.Oven.AddPizza(Oven,other, freeID)
				end
			end)
		end
	end
end

//This creates a Trace for determining if the Screen got hit
function zpiz.Oven.OnUse(Oven,ply)

	if not IsValid(Oven) then return end

	if Oven.Busy == true then return end

	if zpiz.Player.CanInteract(ply,Oven) == false then return end

	local tr = ply:GetEyeTrace()
	if (tr and tr.Hit and zclib.util.InDistance(ply:GetPos(), tr.HitPos, 300) and IsValid(tr.Entity) and tr.Entity == Oven) then
		zpiz.Oven.UseLogic(Oven,tr)
	end
end

// Called when the Entity gets Damaged
function zpiz.Oven.TakeDamage(Oven, dmg)
	if not IsValid(Oven) then return end


	if (not Oven.m_bApplyingDamage) then

		Oven.m_bApplyingDamage = true
		Oven:TakeDamageInfo(dmg)
		local damage = dmg:GetDamage()
		local entHealth = zpiz.config.Damage["zpiz_oven"]

		if (entHealth <= 0) then return end

		Oven.CurrentHealth = (Oven.CurrentHealth or entHealth) - damage

		if Oven.CurrentHealth <= 0 then
			zclib.Effect.Generic("Explosion", Oven:GetPos())

			if table.Count(Oven.PizzaSpots) > 0 then
				for k, v in pairs(Oven.PizzaSpots) do
					if IsValid(v.ent) and v.ent:GetClass() == "zpiz_pizza" then
						SafeRemoveEntity(v.ent)
					end
				end
			end

			SafeRemoveEntity(Oven)
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed


		Oven.m_bApplyingDamage = false
	end
end




//Here do we check what Button the trace is hitting
function zpiz.Oven.UseLogic(Oven,trace)
	local lTrace = Oven:WorldToLocal(trace.HitPos)

	if zpiz.Oven.CalcWorldElementPos(lTrace, 27, -27, 70, 55) and IsValid(Oven.PizzaSpots[2].ent) then
		zpiz.Oven.RemovePizza(Oven,Oven.PizzaSpots[2].ent, 2)
	end

	if zpiz.Oven.CalcWorldElementPos(lTrace, 27, -27, 55, 38) and IsValid(Oven.PizzaSpots[1].ent) then
		zpiz.Oven.RemovePizza(Oven,Oven.PizzaSpots[1].ent, 1)
	end
end

//Check if we are inside a 2D area relativ from the Root of the Entity
function zpiz.Oven.CalcWorldElementPos(trace, xStart, xEnd, yStart, yEnd)
	if trace.y < xStart and trace.y > xEnd and trace.z < yStart and trace.z > yEnd then
		return true
	else
		return false
	end
end

// Places the Pizza
function zpiz.Oven.AddPizza(Oven,pizza, PosID)
	zclib.NetEvent.Create("zpiz_oven_close", {Oven.PizzaSpots[PosID].door})

	local attach = Oven:GetAttachment(PosID)

	pizza:SetPos(attach.Pos)
	pizza:SetParent(Oven, PosID)
	pizza:SetAngles(attach.Ang)

	Oven.PizzaSpots[PosID].ent = pizza
	pizza.InOven = true

	if PosID == 1 then
		Oven:SetPizzaSlot01(pizza)
	else
		Oven:SetPizzaSlot02(pizza)
	end

	DropEntityIfHeld(pizza)

	Oven.PizzaCount = math.Clamp(Oven.PizzaCount + 1,0,2)

	// Start Bake Timer
	zpiz.Oven.BakeTimerCheck(Oven)
end

// Removes the Pizza
function zpiz.Oven.RemovePizza(Oven,pizza, pos)
	Oven.Busy = true

	zclib.NetEvent.Create("zpiz_oven_open", {Oven.PizzaSpots[pos].door})

	Oven.PizzaSpots[pos].ent = nil

	if pos == 1 then
		Oven:SetPizzaSlot01(NULL)
	else
		Oven:SetPizzaSlot02(NULL)
	end

	Oven.PizzaCount = math.Clamp(Oven.PizzaCount - 1,0,2)

	timer.Simple(0.5, function()
		if IsValid(Oven) then
			pizza:SetParent(nil)
			pizza:SetPos(Oven:GetPos() + Oven:GetUp() * 35 + Oven:GetForward() * 50)
			pizza:PhysicsInit(SOLID_VPHYSICS)
			pizza:SetMoveType(MOVETYPE_VPHYSICS)
			pizza:SetSolid(SOLID_VPHYSICS)

			local phys = pizza:GetPhysicsObject()
			if phys:IsValid(phys) then
				phys:Wake()
				phys:EnableMotion(true)
			end

			pizza.InOven = false

			Oven.Busy = false
		end
	end)
	// 872185854
	// If there is no pizza left then we stop the timer
	zpiz.Oven.BakeTimerCheck(Oven)
end

// Returns a free pizza spot in the oven
function zpiz.Oven.HasFreeSpot(Oven)
	local hasFreeSpot

	for k, v in pairs(Oven.PizzaSpots) do
		if not IsValid(v.ent) then
			hasFreeSpot = k
			break
		end
	end

	return hasFreeSpot
end

// Bakes the Pizza
function zpiz.Oven.BakePizza(Pizza)
	Pizza:SetBakeTime(Pizza:GetBakeTime() + 1)

	local currentBakeTime = Pizza:GetBakeTime()
	local ply = zclib.Player.GetOwner(Pizza)

	local pizzaState = Pizza:GetPizzaState()

	local pizzaID = Pizza:GetPizzaID()
	local needBakeTime = zpiz.Pizza.GetBakeTime(pizzaID)

	if (currentBakeTime >= needBakeTime + zpiz.config.Oven.BurnTime) then
		zclib.Notify(ply, zpiz.language.Pizza_Burned, 1)

		// Call Burned Pizza Hook
		hook.Run("zpiz_OnPizzaBurned" ,Pizza, ply,pizzaID)

		if pizzaState == 3 then
			Pizza:SetPizzaState(4)
			zpiz.Pizza.UpdateVisuals(Pizza)
		end
	elseif (currentBakeTime == needBakeTime) then

		// Call Pizza Ready Hook
		hook.Run("zpiz_OnPizzaReady" ,Pizza, ply,pizzaID,Pizza:GetParent())

		zclib.Notify(ply, zpiz.language.Pizza_Ready, 0)
		Pizza:EmitSound("zpiz_sfx_ovendone")

		if pizzaState == 2 then
			Pizza:SetPizzaState(3)
			zpiz.Pizza.UpdateVisuals(Pizza)
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

	local t = 0
	local pizzaColor = zpiz.colors["brown03"]

	if pizzaState == 2 then
		t = (1 / needBakeTime) * currentBakeTime
		pizzaColor = zclib.util.LerpColor(t, Color(255, 255, 255), Color(200, 150, 119))
	elseif pizzaState == 3 then
		t = (1 / zpiz.config.Oven.BurnTime) * (currentBakeTime - needBakeTime)
		pizzaColor = zclib.util.LerpColor(t, Color(200, 150, 119), Color(48, 32, 23))
	end

	Pizza:SetColor(pizzaColor)
end

// Starts/Stops the Pizza Bake Timer
function zpiz.Oven.BakeTimerCheck(Oven)
	local timerID = "zpiz_oven_bake_" .. Oven:EntIndex() .. "_timer"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

	// Stop the Timer since no pizza is in it
	if Oven.PizzaCount <= 0 then
		zclib.Timer.Remove(timerID)
		return
	end

	// Restart the Pizza Bake timer
	zclib.Timer.Remove(timerID)

	zclib.Timer.Create(timerID, 1, 0, function()
		if not IsValid(Oven) then
			zclib.Timer.Remove(timerID)
			return
		end

		for k, v in pairs(Oven.PizzaSpots) do
			if IsValid(v.ent) and v.ent:GetPizzaState() < 4 then
				zclib.NetEvent.Create("zpiz_pizza_bake", {v.ent})
				zpiz.Oven.BakePizza(v.ent)
			end
		end
	end)
end
