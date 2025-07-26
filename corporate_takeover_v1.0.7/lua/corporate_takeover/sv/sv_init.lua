// Retrieve corporation data
function Corporate_Takeover:GetData(CorpID)
	if(Corporate_Takeover.Corps[CorpID]) then
		return Corporate_Takeover.Corps[CorpID]
	end

	return false
end

// Delete corporation
function Corporate_Takeover:DeleteCorp(CorpID)
	local Corp = self:GetData(CorpID)

	if(Corp) then
		local owner = player.GetBySteamID(Corp.owner)

		if(owner && IsValid(owner) && owner:IsPlayer()) then
			owner.CTOHasCorp = nil
			owner.CTOCorpID = nil
			hook.Run("cto_corp_deleted", owner, Corp.name)
		end

		Corporate_Takeover.Corps[Corp.CorpID] = nil
	end

	self:SyncCorps()
end

hook.Add("OnPlayerChangedTeam", "CTO_DeleteCorpIfThere", function(ply)
	if(ply.CTOHasCorp) then
		if(ply.CTOCorpID) then
			Corporate_Takeover:DeleteCorp(ply.CTOCorpID)

			for k, v in ents.Iterator() do
				if(v.CTO && v:Getowning_ent() == ply) then
					v:Remove()
				end
			end
		end
	end
end)

// Generate hireable workers
function Corporate_Takeover:GenerateWorkers(CorpID)
	local Corp = self:GetData(CorpID)

	if(Corp) then
		Corporate_Takeover.Corps[CorpID].hireableWorkers = {}

		for i = 1, Corporate_Takeover.Config.HierarbleWorkers do
			local gender = "male"
			if(math.random(1, 2) == 2) then
				gender = "female"
			end

			local name = Corporate_Takeover.Config.MaleNames[math.random(1, #Corporate_Takeover.Config.MaleNames)]
			if(gender == "female") then
				name = Corporate_Takeover.Config.FemaleNames[math.random(1, #Corporate_Takeover.Config.FemaleNames)]
			end

			local level = math.random(1, Corp.level + 2)
			if(level < 1) then
				level = 1
			end

			if(Corporate_Takeover.Config.MaxWorkerLevel != 0) then
				if(level >= Corporate_Takeover.Config.MaxWorkerLevel) then
					level = Corporate_Takeover.Config.MaxWorkerLevel
				end
			end

			local model = Corporate_Takeover.Config.MaleWorkerModels[math.random(1, #Corporate_Takeover.Config.MaleWorkerModels)]
			if(gender == "female") then
				model = Corporate_Takeover.Config.FemaleWorkerModels[math.random(1, #Corporate_Takeover.Config.FemaleWorkerModels)]
			end

			local wageMult = 1 + (0.1 * (level - 1))
			local wage = math.Round(math.random(50, 80) * wageMult, 0)

			Corporate_Takeover.Corps[CorpID].hireableWorkers[i] = {
				gender = gender,
				name = name,
				lastname = Corporate_Takeover.Config.Surnames[math.random(1, #Corporate_Takeover.Config.Surnames)],

				level = level,
				xp = 0,
				xpNeeded = Corporate_Takeover.Config.XPNeededForWorkerLevel(level),
				model = model,

				age = math.random(18, 69),
				wage = wage
			}
		end

		Corporate_Takeover.Corps[CorpID].GenerateWorkerDelay = CurTime() + Corporate_Takeover.Config.HierableWorkersDelay

		Corporate_Takeover:SyncCorp(CorpID)

		timer.Simple(Corporate_Takeover.Config.HierableWorkersDelay, function()
			if(Corp) then
				Corporate_Takeover:GenerateWorkers(CorpID)
			end
		end)
	end
end

Corporate_Takeover.cto_IDs = Corporate_Takeover.cto_IDs || 0

// Create corporation
function Corporate_Takeover:CreateCorp(ply, name)
	if(ply.CTOHasCorp) then
		DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("corp_exists"))
		return false
	end

	if(name == "") then
		DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("corpname_empty"))
		return false
	end
	if(#name > 30) then
		DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("corpname_too_long"))
		return false
	end
	if(#name < 5) then
		DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("corpname_too_short"))
		return false
	end
	if(name == Corporate_Takeover:Lang("placeholder_name")) then
		DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("corpname_default"))
		return false
	end
	
	local fee = Corporate_Takeover.Config.CompanyFee
	if(Corporate_Takeover:HasMoney(ply, fee)) then
		ply.CTOHasCorp = true
		ply:addMoney(-fee)

		// There mustn't be a company with the same ID. Even if the previous company is gone.
		local CorpID = Corporate_Takeover.cto_IDs + 1
		Corporate_Takeover.cto_IDs = Corporate_Takeover.cto_IDs + 1
		Corporate_Takeover.Corps[CorpID] = {
			["CorpID"] = CorpID,
			["name"] = name,
			["owner"] = ply:SteamID(),
			["money"] = Corporate_Takeover.Config.DefaultMoney,
			["maxMoney"] = Corporate_Takeover.Config.DefaultVault,
			["trusted"] = {},
			["workers"] = {},
			["researches"] = {},
			["desks"] = {},
			["hireableWorkers"] = {},
			["level"] = 1,
			["xp"] = 0,
			["xpNeeded"] = Corporate_Takeover.Config.XPNeededForCorpLevel(1),
		}

		ply.CTOCorpID = CorpID

		if(!IsValid(ply.CorpDesk)) then
			for k, v in ipairs(ents.FindByClass("corporate_desk")) do
				if(v:Getowning_ent() == ply) then
					ply.CorpDesk = v
					break
				end
			end
		end

		local desk = ply.CorpDesk
		if(desk) then
			desk:SetCorpID(CorpID)
			Corporate_Takeover.Corps[CorpID].desk = desk
		end

		Corporate_Takeover:GenerateWorkers(CorpID)

		Corporate_Takeover:SyncCorps()

		local message = Corporate_Takeover:Lang("corp_created")
		message = string.Replace(message, "%name", name)

		DarkRP.notify(ply, 0, 5, message)

		hook.Run("cto_corp_created", ply, name)
	else
		local message = Corporate_Takeover:Lang("corp_exists")
		message = string.Replace(message, "%money", DarkRP.formatMoney(fee))

		DarkRP.notify(ply, 1, 5, message)
	end
end
net.Receive("cto_CreateCorp", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end
	local name = net.ReadString()
	Corporate_Takeover:CreateCorp(ply, name)
end)

function Corporate_Takeover:BurnCorp(CorpID)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		if(Corp.Abandoned) then
			return false
		end

		Corporate_Takeover.Corps[CorpID].Abandoned = true

		for k, v in ents.Iterator() do
			if(v.CTO && v:Getowning_ent() == player.GetBySteamID(Corp.owner)) then
				if(v.npc && IsValid(v.npc)) then
					v.npc:Remove()
				end
				v:Ignite(10, 1)
				timer.Simple(10, function()
					if(v && IsValid(v)) then
						v:Remove()
					end
				end)
			end
		end

		local desk = Corp.desk
		if(desk && IsValid(desk)) then
			desk:Ignite(10, 1)
			timer.Simple(10, function()
				if(desk && IsValid(desk)) then
					desk:Remove()
				end
			end)
		end

		local owner = player.GetBySteamID(Corp.owner)
		if(owner && IsValid(owner) && owner:IsPlayer()) then
			DarkRP.notify(owner, 1, 5, Corporate_Takeover:Lang("corp_rebellion"))
		end

		Corporate_Takeover:SyncCorps()
	end
end

// Processing each corporate for each "Tick"
Corporate_Takeover.ThinkTime = CurTime()
-- Think hook'u kaldır
hook.Remove("Think", "cto_Think")

-- Timer ekle
timer.Create("cto_Think_Timer", Corporate_Takeover.Config.TickDelay or 1, 0, function()
	for k, Corp in pairs(Corporate_Takeover.Corps) do
		if(Corp.Bankrupt) then
			continue
		end

		local money = Corporate_Takeover.Corps[k].money
		if(Corporate_Takeover.Config.BankruptBorder > money) then
			local mode = Corporate_Takeover.Config.BankruptMode
			if(mode == 1) then
				Corporate_Takeover:BurnCorp(k)
			elseif(mode == 2) then
				Corporate_Takeover.Corps[k].Bankrupt = true

				local owner = player.GetBySteamID(Corp.owner)
				if(owner) then
					local numWorkers = #Corp.workers
					if(numWorkers != 0) then
						DarkRP.notify(owner, 1, 5, Corporate_Takeover:Lang("corp_bankrupt"))
					end

					for _, v in ents.Iterator() do
						if(v.CTO && v.Getowning_ent && v:Getowning_ent() == owner && v.GetCorpID && v:GetCorpID() == k && v.GetWorkerID) then
							local worker = v:GetWorkerID()
							if(worker != 0) then
								Corporate_Takeover.Corps[k].workers[worker] = nil
								if(v.npc && IsValid(v.npc)) then
									v.npc:Remove()
									v:SetWorkerID(0)
									v:SetWorkerEnergy(100)
									v:SetWorking(false)
									v.npc:SetAsleep(true)
									v:SetSleeping(false)
								end
							end
						end
					end
				end

				Corporate_Takeover:SyncCorps()
			end
		end
	end
end)

// true = Not allowed; false = allowed
function Corporate_Takeover:CheckRestriction(ply, restriction)
	local ug = ply:GetUserGroup()
	local isDon = Corporate_Takeover.Config.DonatorGroups[ug]
	local isStaff = Corporate_Takeover.Config.StaffGroups[ug]
	if(restriction == "admin") then
		return !isStaff
	end

	if(restriction == "donator") then
		if(Corporate_Takeover.Config.StaffIsDonator) then
			if(isDon || isStaff) then
				return false, true
			end
		end

		return !isDon, true
	end
	return true
end

// Buying a deskbuilder
function Corporate_Takeover:BuyDesk(ply, class)
	if(ply.CTOHasCorp) then
		if(!ply.CTOCorpID) then
			return false
		end

		local Corp = Corporate_Takeover:GetData(ply.CTOCorpID)
		if(Corp) then
			local desk_blueprint = Corporate_Takeover:GetDesk(class)

			if(!desk_blueprint) then
				DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("err"))
				return false
			end

			local level = Corp.level
			local levelNeeded = desk_blueprint.level || 0

			if(desk_blueprint) then
				if(level < levelNeeded) then
					local message = Corporate_Takeover:Lang("corp_insufficient_level")
					message = string.Replace(message, "%level", levelNeeded)

					DarkRP.notify(ply, 1, 5, message)
					return
				end

				local deskclass = desk_blueprint.deskclass
				local bpclass = desk_blueprint.class
				local max = desk_blueprint.max

				local amount = Corporate_Takeover:GetDeskCount(bpclass, deskclass, ply)

				if(amount >= max) then
					DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("desk_limit"))
					return false
				end

				local price = desk_blueprint.price || 0
				local money = Corp.money
				if(price > money) then
					DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("desk_no_money"))
					return false
				end

				local restricted = desk_blueprint.restriction
				if(restricted) then
					local useRestricted, missing = self:CheckRestriction(ply, restricted)
					if(useRestricted) then
						local text = "cto_missing_admin"
						if(missing) then
							text = "cto_missing_donator"
						end

						DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang(text))

						return false
					end
				end

				local numBuildersAllowed = Corporate_Takeover.Config.MaxDeskbuilders
				local builders = Corporate_Takeover:GetDeskBuilderCount(ply)
				if(numBuildersAllowed <= builders) then
					DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("deskbuilder_limit"))
					return false
				end

				Corporate_Takeover:AddMoney(Corp.CorpID, -price)

				local builder = ents.Create("deskbuilder_base")
				if(builder) then
					builder:Spawn()
					builder:Activate()
					builder:SetDeskClass(deskclass)
					builder:Setowning_ent(ply)
					builder:SetCorpID(Corp.CorpID)
					builder:CPPISetOwner(ply)

					local tr = ply:GetEyeTrace()

					local desk = Corp.desk
					if(desk && IsValid(desk)) then
						local ang = desk:GetAngles()
						local pos = desk:GetPos() + ang:Forward() * 40 + ang:Up() * 50 + ang:Right() * -42
						builder:SetPos(pos)
						builder:SetAngles(ang)

						if(!builder:IsInWorld()) then
							DarkRP.placeEntity(builder, tr, ply)
						end
					end

					ply:EmitSound("corporate_takeover/buy.wav")

					hook.Run("cto_corp_bought", ply, deskclass)
				end

				Corporate_Takeover:SyncCorps()
			end
		end
	end
end

net.Receive("cto_BuyItem", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end
	local desk = net.ReadBit() == 1

	if desk then
		Corporate_Takeover:BuyDesk(ply, net.ReadString())
	else
		Corporate_Takeover:BuyCoffee(ply, net.ReadUInt(5))
	end
end)

// Placing a desk
function Corporate_Takeover:PlaceDesk(ply, pos, ang)
	local CorpID = ply.CTOCorpID || -1
	local Corp = self:GetData(CorpID)

	local deskEnt = ply.PlacingDesk
	if(deskEnt && IsValid(deskEnt)) then
		local class = deskEnt:GetDeskClass()
		local desk_blueprint = self:GetDesk(class)

		if(desk_blueprint && desk_blueprint != "none") then
			local deskclass = desk_blueprint.deskclass
			local bpclass = desk_blueprint.class
			local max = desk_blueprint.max

			local amount = self:GetDeskCount(bpclass, deskclass, ply)

			if(amount >= max) then
				DarkRP.notify(ply, 0, 5, Corporate_Takeover:Lang("desk_limit"))
				return false
			end

			local desk = ents.Create(bpclass)

			if(!IsValid(desk)) then
				deskEnt:Remove()
				return false
			end
			desk:SetPos(pos)
			desk:SetAngles(ang)
			desk:CPPISetOwner(ply)
			if(desk_blueprint.model) then
				desk:SetModel(desk_blueprint.model)
			else
				desk:SetModel("models/corporate_takeover/nostras/worker_desk.mdl")
			end

			local can = self:CanPlaceDeskHere(ply, desk, deskEnt)
			if(can) then
				desk:SetPos(pos - Vector(0,0,1))
				desk:Spawn()
				desk:Activate()
				desk:Setowning_ent(ply)
				desk:SetDeskClass(deskclass)

				desk:PhysicsInit(SOLID_VPHYSICS)
				desk:SetMoveType(MOVETYPE_VPHYSICS)
				desk:SetSolid(SOLID_VPHYSICS)
				desk:SetTrigger()
			 
			    local phys = desk:GetPhysicsObject()
				if (phys:IsValid()) then
					phys:Wake()
				end

				if(desk_blueprint.bodygroups) then
					for k, v in ipairs(desk_blueprint.bodygroups) do
						local rand = math.random(1, v)
						desk:SetBodygroup(k, rand)
					end
				end

				if(desk_blueprint.skin) then
					desk:SetSkin(desk_blueprint.skin)
				end

				if(desk_blueprint.health) then
					desk.EntHealth = desk_blueprint.health
				end

				deskEnt:Remove()

				desk:EmitSound(Corporate_Takeover.Config.Sounds.General["placing_desk"])

				local phys = desk:GetPhysicsObject()
				if phys:IsValid()then
					phys:EnableMotion(false)
					phys:Sleep()
				end

				// Insert desk into corp
				if(Corp) then
					desk:SetCorpID(CorpID)

					local exists = Corporate_Takeover.Corps[CorpID].desks[deskclass]
					if(!exists) then
						Corporate_Takeover.Corps[CorpID].desks[deskclass] = 0
					end

					Corporate_Takeover.Corps[CorpID].desks[deskclass] = Corporate_Takeover.Corps[CorpID].desks[deskclass] + 1

					Corporate_Takeover:SyncDesks(CorpID)
				end

				ply.PlacingDesk = nil
			else
				DarkRP.notify(ply, 0, 5, Corporate_Takeover:Lang("no_space"))
				desk:Remove()
				ply.PlacingDesk = nil
			end
		end
	else
		ply.PlacingDesk = nil
	end
end

net.Receive("cto_deskPlacement", function(_, ply)
	local place = net.ReadBit() == 1

	if place then
		local pos = net.ReadVector()
		local ang = net.ReadAngle()

		Corporate_Takeover:PlaceDesk(ply, pos, ang)
	end

	ply.PlacingDesk = nil
end)

// Hire worker
function Corporate_Takeover:HireWorker(ply, WorkerID)
	local CorpID = ply.CTOCorpID
	if(!CorpID) then
		return false
	end

	local Corp = self:GetData(CorpID)
	if(Corp) then
		local worker = Corp.hireableWorkers[WorkerID]
		if(!worker) then
			return false
		end

		local wage = worker.wage
		if(wage > Corp.money) then
			local message = Corporate_Takeover:Lang("worker_wage_unpayable")
			message = string.Replace(message, "%name", worker.name.." "..worker.lastname)
			DarkRP.notify(ply, 1, 5, message)
			return false
		end

		local desk = ply.CTO_Selected_Desk
		if(!desk || !IsValid(desk)) then
			return false
		end

		local wID = #Corporate_Takeover.Corps[CorpID].workers + 1
		Corporate_Takeover.Corps[CorpID].workers[wID] = worker
		Corporate_Takeover.Corps[CorpID].hireableWorkers[WorkerID] = nil

		local workername = worker.name.." "..worker.lastname

		desk:SpawnWorker(worker.model, worker.gender)
		desk:SetWorkerID(wID)
		desk:SetWorking(true)
		desk:SetWorkerName(workername)

		Corporate_Takeover:SyncCorp(CorpID)

		local message = Corporate_Takeover:Lang("worker_hired")
		message = string.Replace(message, "%name", workername)
		DarkRP.notify(ply, 0, 5, message)
	end
end

net.Receive("cto_WorkerManagement", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end
	local hire = net.ReadBit() == 1

	if hire then
		Corporate_Takeover:HireWorker(ply, net.ReadUInt(6))
	else
		Corporate_Takeover:FireWorker(ply)
	end
end)

function Corporate_Takeover:ExpandVault(ply)
	if(!ply.CTOCorpID) then
		return false
	end
	local CorpID = ply.CTOCorpID

	local Corp = self:GetData(CorpID)
	if(Corp) then
		local vault = Corp.maxMoney
		local money = Corp.money
		local vaultLevel = Corp.vaultLevel or 1
		local Cost = math.Round(vault * Corporate_Takeover.Config.VaultExpansionPercent)

		if(money - Cost < 0) then
			DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("no_money"))
			return false
		end

		local newVault = math.Round(vault * 1.1, 0)

		self:AddMoney(CorpID, -Cost)
		Corporate_Takeover.Corps[CorpID].vaultLevel = vaultLevel + 1
		Corporate_Takeover.Corps[CorpID].maxMoney = newVault

		local message = Corporate_Takeover:Lang("vault_expanded")
		message = string.Replace(message, "%amount", DarkRP.formatMoney(newVault))
		message = string.Replace(message, "%price", DarkRP.formatMoney(Cost))

		DarkRP.notify(ply, 0, 5, message)

		ply:EmitSound("corporate_takeover/buy.wav")

		self:SyncCorp(CorpID)
	end
end

net.Receive("cto_ExpandVault", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end
	Corporate_Takeover:ExpandVault(ply)
end)

function Corporate_Takeover:BuyCoffee(ply, CoffeeID)
	if(ply.CTOHasCorp) then
		if(!ply.CTOCorpID) then
			return false
		end

		if(!Corporate_Takeover.Config.CoffeeBuyable) then
			return false
		end

		local Corp = Corporate_Takeover:GetData(ply.CTOCorpID)
		if(Corp) then
			local Coffee = Corporate_Takeover.Config.DefaultCoffee[CoffeeID]
			if(!Coffee) then
				DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("err"))
				return false
			end

			local level = Corp.level
			local levelNeeded = Coffee.level || 0


			if(level < levelNeeded) then
				local message = Corporate_Takeover:Lang("corp_insufficient_level")
				message = string.Replace(message, "%level", levelNeeded)

				DarkRP.notify(ply, 1, 5, message)
				return
			end

			local max = Corporate_Takeover.Config.MaxCoffees

			local amount = 0
			for k, v in ipairs(ents.FindByClass("cto_coffee")) do
				if(v.Getowning_ent && v:Getowning_ent() == ply) then
					amount = amount + 1
				end
			end

			if(amount >= max) then
				DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("coffee_limit"))
				return false
			end

			local price = Coffee.price || 0
			local money = Corp.money
			if(price > money) then
				DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("coffee_no_money"))
				return false
			end

			local restricted = Coffee.restriction
			if(restricted) then
				local useRestricted, missing = self:CheckRestriction(ply, restricted)
				if(useRestricted) then
					local text = "cto_missing_admin"
					if(missing) then
						text = "cto_missing_donator"
					end

					DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang(text))

					return false
				end
			end

			Corporate_Takeover:AddMoney(Corp.CorpID, -price)

			local tr = ply:GetEyeTrace()

			local mug = ents.Create("cto_coffee")
			if(mug) then
				mug:Spawn()
				mug:Activate()
				mug:CPPISetOwner(ply)
				mug:Setowning_ent(ply)
				mug.Energy = Coffee.energy || 50

				local desk = Corp.desk
				if(desk && IsValid(desk)) then
					local ang = desk:GetAngles()
					local pos = desk:GetPos() + ang:Forward() * 40 + ang:Up() * 50 + ang:Right() * -2
					mug:SetPos(pos)
					mug:SetAngles(ang)

					if(!mug:IsInWorld()) then
						DarkRP.placeEntity(mug, tr, ply)
					end
				else
					DarkRP.placeEntity(mug, tr, ply)
				end

				hook.Run("cto_corp_bought", ply, "coffee ["..mug.Energy.."%]")

				ply:EmitSound("corporate_takeover/buy.wav")
			end
		end
	end
end

function Corporate_Takeover:DismantleDesk(ply)
	local desk = ply.CTO_Selected_Desk
	if(desk && IsValid(desk) && desk.CTO) then
		// remove it
		local pos = desk:GetPos()
		local ang = desk:GetAngles()

		local builder = ents.Create("deskbuilder_base")
		if(builder) then
			builder:SetPos(pos)
			builder:SetAngles(ang)
			builder:Spawn()
			builder:Activate()
			builder:CPPISetOwner(ply)
			builder:SetDeskClass(desk:GetDeskClass())
			builder:Setowning_ent(ply)
			builder:SetCorpID(desk:GetCorpID())

			local tr = ply:GetEyeTrace()

			ply:EmitSound(Corporate_Takeover.Config.Sounds.General["dismantle_desk"])
		end

		desk:Remove()
	end
	ply.CTO_Selected_Desk = nil
end

net.Receive("cto_dismantleDesk", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end
	Corporate_Takeover:DismantleDesk(ply)
end)

function Corporate_Takeover:FireWorker(ply)
	local desk = ply.CTO_Selected_Desk
	if(desk && IsValid(desk) && desk.CTO) then
		// remove it
		local message = Corporate_Takeover:Lang("worker_fired")
		message = string.Replace(message, "%name", desk:GetWorkerName())

		DarkRP.notify(ply, 0, 5, message)

		desk:FireWorker()
	end
	ply.CTO_Selected_Desk = nil
end

function Corporate_Takeover:StartResearch(ply, class)
	if(!ply.CTOHasCorp) then
		return false
	end

	if(!ply.CTOCorpID) then
		return false
	end

	local Corp = Corporate_Takeover:GetData(ply.CTOCorpID)
	if(!Corp) then
		return false
	end

	local CorpID = Corp.CorpID

	local desk = ply.CTO_Selected_Desk

	if(desk && IsValid(desk) && desk.CTO) then
		local research = Corporate_Takeover.Researches[class]
		if(research) then
			local isResearching = desk:GetResearchingItem() != ""
			if(isResearching) then
				DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("research_in_progress"))
				return false
			end

			local price = research.price || 0

			if(Corp.researches["research_price_drop"]) then
				price = math.Round(price * .9, 1)
			end

			local money = Corp.money
			if(price > money) then
				DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("research_no_money"))
				return false
			end

			local level = Corp.level
			local levelNeeded = research.level || 0


			if(level < levelNeeded) then
				local message = Corporate_Takeover:Lang("corp_insufficient_level")
				message = string.Replace(message, "%level", levelNeeded)

				DarkRP.notify(ply, 1, 5, message)
				return false
			end

			local hasNeeded = true
			if(research.needed) then
				for k, v in pairs(research.needed) do
					if(!Corporate_Takeover.Corps[CorpID].researches[v]) then
						hasNeeded = v
					end
				end
			end
			if(hasNeeded != true) then
				local message = Corporate_Takeover:Lang("research_needed")
				message = string.Replace(message, "%name", Corporate_Takeover:Lang(hasNeeded))

				DarkRP.notify(ply, 1, 5, message)
				return false
			end

			local restricted = research.restriction
			if(restricted) then
				local useRestricted, missing = self:CheckRestriction(ply, restricted)
				if(useRestricted) then
					local text = "cto_missing_admin"
					if(missing) then
						text = "cto_missing_donator"
					end

					DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang(text))

					return false
				end
			end


			Corporate_Takeover:AddMoney(CorpID, -price)
			desk:SetResearchingItem(class)

			local time = research.time
			if(Corp.researches["research_efficiency"]) then
				time = math.Round(time * .9, 1)
			end

			desk:SetTickTime(time)
			desk:SetTickTimeMax(time)

			local message = Corporate_Takeover:Lang("research_started")
			message = string.Replace(message, "%name", Corporate_Takeover:Lang(class))

			DarkRP.notify(ply, 0, 5, message)
		end
	end
end

net.Receive("cto_startResearch", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end
	Corporate_Takeover:StartResearch(ply, net.ReadString())
end)