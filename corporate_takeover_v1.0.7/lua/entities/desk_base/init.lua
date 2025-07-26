AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/corporate_takeover/nostras/worker_desk.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger()
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetCorpID(0)
	self:SetWorkerID(0)
	self:SetWorking(false)
	self:SetSleeping(false)
	self:SetWorkerEnergy(100)
	self:SetTickTime(CurTime()  + Corporate_Takeover.Config.TickDelay)
	self:SetWorkerName("")

	self:SetFullProfit(0)
	self:SetProfit(0)
	self:SetLoss(0)

	self.used = CurTime()
	self.TickDelay = CurTime() + Corporate_Takeover.Config.TickDelay

	self:SpawnChair()
end

function ENT:SpawnWorker(model, gender)
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 270)

	// Chair pos
	pos = pos + ang:Right() * 6
	pos = pos - ang:Forward() * 33
	pos = pos - ang:Up() * 2

	self.npc = ents.Create("cto_citizen")
	self.npc:SetModel(model)
	self.npc:SetPos(pos)
	self.npc:SetAngles(ang)
	self.npc:Spawn()
	self.npc:Activate()
	self.npc:SetParent(self)
	self.npc.desk = self
	self.npc.gender = gender

	self:SetWorkerEnergy(100)
end

function ENT:SpawnChair()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)

	pos = pos + ang:Right() * 40
	pos = pos + ang:Forward() * 5
	pos = pos - ang:Up() * 0.2

	self.chair = ents.Create("prop_dynamic")
	self.chair:SetModel("models/nova/chair_office02.mdl")
	self.chair:SetPos(pos)
	self.chair:SetAngles(ang)
    self.chair:Spawn()
    self.chair:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self.chair:SetSolid(SOLID_VPHYSICS)
    self.chair:PhysicsInit(SOLID_VPHYSICS)
	self.chair:SetParent(self)
end

function ENT:Use(ply)
	if(self.used < CurTime()) then
		self.used = CurTime() + 1

		if(self:Getowning_ent() != ply) then
			DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("not_your_desk"))
			return false
		end

		if(self:GetCorpID() == 0) then
			return false
		end

		local Corp = Corporate_Takeover:GetData(self:GetCorpID())
		if(!Corp) then
			return false
		end

		ply.CTO_Selected_Desk = self

		if(self:GetWorkerID() == 0) then
			net.Start("cto_WorkerSelection")
				net.WriteUInt(self:GetCorpID(), 8)
			net.Send(ply)
			return false
		end

		net.Start("cto_openWorkerMenu")
			net.WriteEntity(Entity(self:EntIndex()))
		net.Send(ply)
	end
end

net.Receive("cto_WorkerSelection", function(_, ply)
	ply.CTO_Selected_Desk = nil
end)

function ENT:ProcessTick(Corp, worker, CorpID)
	local WorkerLevel = worker.level
	local levelMult = 0.025 * (WorkerLevel - 1)

	local CorpLevel = Corp.level
	local CorpLevelMult = 0.1 * (CorpLevel - 1)

	local WorkerBoost = 0

	local deskMult = 0
	local desk = Corporate_Takeover.Desks[self:GetDeskClass()]
	if(desk && desk.earningMultiplier) then
		deskMult = desk.earningMultiplier - 1
	end
	local totalMult = 1 + levelMult + CorpLevelMult + WorkerBoost + deskMult

	local range = Corporate_Takeover.Config.WorkerMoney
	local min, max = range[1], range[2]

	local production = math.Round((math.random(min, max) * totalMult), 0)

    -- VIP bonusu başlangıcı
    local owner = self:Getowning_ent()
    if IsValid(owner) and owner:IsPlayer() then
        local userGroup = owner:GetUserGroup()
        if Corporate_Takeover.Config.VipBonus[userGroup] then
            production = production * Corporate_Takeover.Config.VipBonus[userGroup]
        end
    end
    -- VIP bonusu sonu

	Corporate_Takeover:AddMoney(CorpID, production)

	self:SetFullProfit(self:GetFullProfit() + production)
	self:SetProfit(production)
	self:SetProfitDiff(self:GetProfitDiff() + production)

	if(deskMult <= 0) then
		deskMult = 1
	end

	local xp = (15 * totalMult) * deskMult
	local workerXP = xp * 0.5

	local xp_corp_1 = Corp.researches["xp_corp_1"] || false
	if(xp_corp_1) then
		xp = xp * 1.25
	end

	local xp_corp_2 = Corp.researches["xp_corp_2"] || false
	if(xp_corp_2) then
		xp = xp * 1.1
	end

	local xp_worker_1 = Corp.researches["xp_worker_1"] || false
	if(xp_worker_1) then
		workerXP = workerXP * 1.1
	end

	local xp_worker_2 = Corp.researches["xp_worker_2"] || false
	if(xp_worker_2) then
		workerXP = workerXP * 1.1
	end

	xp = math.Round(xp, 0)
	workerXP = math.Round(workerXP, 0)

	Corporate_Takeover:AddXP(CorpID, xp)
	Corporate_Takeover:AddWorkerXP(CorpID, self:GetWorkerID(), workerXP)
end

function ENT:Think()
	if(self.TickDelay <= CurTime()) then
		local CorpID = self:GetCorpID()
		if(CorpID != 0) then
			self.TickDelay = CurTime() + Corporate_Takeover.Config.TickDelay
			self:SetTickTime(CurTime() + Corporate_Takeover.Config.TickDelay)
			
			local Corp = Corporate_Takeover:GetData(CorpID)
			if(!Corp) then
				return false
			end
			
			local deskClass = self:GetDeskClass()
			if(deskClass == "none") then
				return false
			end

			local desk = Corporate_Takeover.Desks[deskClass]
			if(!desk) then
				return false
			end

			local upkeepCost = (Corporate_Takeover.Config.UpkeepBasecost * (desk.upkeepCost || 0))
			local workerCost = 0

			if Corp.Bankrupt and !Corporate_Takeover.Config.BankruptDeskUpkeep then
				upkeepCost = 0
			end

			local worker = Corp.workers[self:GetWorkerID()]
			local sleeping = self:GetSleeping() || false
			if(worker && worker != 0) then
				local level = worker.level - 3
				if(level < 0) then
					level = 1
				end
				local costMult = (1 + (0.05 * (level - 1)))
				workerCost = math.Round(worker.wage * costMult, 0)

				local research_wage_1 = Corp.researches["research_wage_1"] || false
				if(research_wage_1) then
					workerCost = workerCost * .9
				end

				local research_wage_2 = Corp.researches["research_wage_2"] || false
				if(research_wage_2) then
					workerCost = workerCost * .9
				end

				local research_wage_3 = Corp.researches["research_wage_3"] || false
				if(research_wage_3) then
					workerCost = workerCost * .9
				end

				workerCost = math.Round(workerCost, 1)

				local totalCost = upkeepCost + workerCost
				Corporate_Takeover:AddMoney(CorpID, -totalCost)
				self:SetLoss(totalCost)
				self:SetProfitDiff(self:GetProfitDiff() - totalCost)

				local working = self:GetWorking()
				if(working && !sleeping) then
					self:ProcessTick(Corp, worker, CorpID)
					self:SetWorkerEnergy(self:GetWorkerEnergy() - math.random(0,2))
				end
			end			

			if(workerCost == 0) then
				Corporate_Takeover:AddMoney(CorpID, -upkeepCost)
				self:SetLoss(upkeepCost)
				self:SetProfitDiff(self:GetProfitDiff() - upkeepCost)
			end

			local npc = self.npc
			if(npc && IsValid(npc)) then
				if(!sleeping) then
					local energy = self:GetWorkerEnergy()
					local fallAsleep = false

					local highChance = Corporate_Takeover.Config.SleepChance -- 1:4
					local lowChance = Corporate_Takeover.Config.SleepChanceLow -- 1:8
					local highThreshold = Corporate_Takeover.Config.SleepThreshold -- 35
					local lowThreshold = Corporate_Takeover.Config.SleepThresholdLow -- 25

					if(energy < highThreshold) then
						fallAsleep = math.random(highChance[1], highChance[2]) == highChance[2]
					elseif(energy < lowThreshold) then
						fallAsleep = math.random(lowChance[1], lowChance[2]) == lowChance[2]
					end

					if(energy <= 0) then
						self:SetWorkerEnergy(0)
						fallAsleep = true
					end

					if(fallAsleep) then
						npc.sequence = "sitchairtable1"
						self:SetWorking(false)
						self:SetSleeping(true)
						npc:SetAsleep(true)
						self:SetProfit(0)

						local ind = #Corporate_Takeover.Config.Sounds.sleeping[npc.gender]
						local snd = Corporate_Takeover.Config.Sounds.sleeping[npc.gender][math.random(1, ind)]
						npc:EmitSound(snd)
					end
				else
					local energy = self:GetWorkerEnergy()
					local add = math.random(2, 4)
					local total = energy + add
					if(total > 100) then
						total = 100
					end
					self:SetWorkerEnergy(total)
				end
			end

			
			Corporate_Takeover:SyncMoneyAndLevel(CorpID)
		end
	end
end

function ENT:Touch(ent)
	if ent.CTO_Removing then return end
	local class = ent:GetClass()

	if(Corporate_Takeover.Config.Coffee[class]) then
		local worker = self:GetWorkerID()
		local CorpID = self:GetCorpID()
		if(worker == 0 || CorpID == 0) then
			return false
		end

		local energy = self:GetWorkerEnergy()
		ent.CTO_Removing = true
		SafeRemoveEntityDelayed(ent, 0.1)
		
		local add = Corporate_Takeover.Config.Coffee[class]
		if(class == "cto_coffee") then
			add = ent.Energy || 50
		end
		local total = energy + add
		if(total > 100) then
			total = 100
		end
		self:SetWorkerEnergy(total)

		local npc = self.npc
		if(npc && IsValid(npc)) then
			local gender = npc.gender
			local ind = #Corporate_Takeover.Config.Sounds.thanks[gender]
			local snd = Corporate_Takeover.Config.Sounds.thanks[gender][math.random(1, ind)]
			npc:EmitSound(snd)
		end

        local effectData = EffectData()
        effectData:SetOrigin(ent:GetPos())
        util.Effect("MetalSpark", effectData)
	end
end

function ENT:FireWorker(Corp)
	if(IsValid(self.npc)) then
		self.npc:Remove()
	end

	// Remove desk from Corp
	if(Corp && Corp.workers && self && IsValid(self)) then
		local workers = Corp.workers
		if(workers) then
			for k, v in ipairs(workers) do
				if(k == self:GetWorkerID()) then
					// Removing worker...
					Corporate_Takeover.Corps[self:GetCorpID()]["workers"][k] = nil
					break
				end
			end
		end
	end

	self:SetWorkerID(0)
	self:SetWorking(false)
	self:SetSleeping(false)
	self:SetWorkerEnergy(100)
end

function ENT:OnRemove()

	if(IsValid(self.chair)) then
		self.chair:Remove()
	end

	local Corp = Corporate_Takeover:GetData(self:GetCorpID())

	if(!Corp) then
		return false
	end

	self:FireWorker(Corp)

	local deskclass = self:GetDeskClass()
	if(deskclass != "none" && Corp) then
		local exists = Corp.desks[deskclass]
		if(exists) then
			Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] = Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] - 1

			if(Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] <= 0) then
				Corporate_Takeover.Corps[Corp.CorpID].desks[deskclass] = 0
			end

			Corporate_Takeover:SyncDesks(Corp.CorpID)
		end
	end

	Corporate_Takeover:SyncDesks(CorpID)
	Corporate_Takeover:SyncWorkers(CorpID)
end