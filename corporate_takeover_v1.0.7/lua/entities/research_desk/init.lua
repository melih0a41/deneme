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
	self:SetTickTime(0)
	self:SetTickTimeMax(0)
	self:SetWorkerName("")
	self:SetResearchingItem("")

	self.used = CurTime()
	self.TickDelay = CurTime() + 1
	self.payDelay = CurTime()

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

		ply.CTO_Selected_Desk = self

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

		if(self:GetWorkerID() == 0) then
			net.Start("cto_WorkerSelection")
				net.WriteUInt(self:GetCorpID(), 8)
			net.Send(ply)
		else
			net.Start("cto_openResearcher")
				net.WriteUInt(self:GetCorpID(), 8)
				net.WriteString(self:GetResearchingItem())
			net.Send(ply)
		end
	end
end

function ENT:ProcessTick(Corp, worker, CorpID)
	if(self:GetResearchingItem() == "") then
		return false
	end

	if(self:GetTickTime() <= 0) then
		local researchClass = self:GetResearchingItem()
		local research = Corporate_Takeover.Researches[researchClass]
		if(research) then
			local func = research.onFinish
			if(func) then
				func(Corp, CorpID, researchClass, self)
			end

			Corporate_Takeover.Corps[CorpID].researches[researchClass] = true
		end

		local message = Corporate_Takeover:Lang("research_finished")
		message = string.Replace(message, "%name", Corporate_Takeover:Lang(researchClass))
		DarkRP.notify(self:Getowning_ent(), 0, 5, message)

		self:SetResearchingItem("")
		self:SetTickTime(0)
		self:SetTickTimeMax(0)
		Corporate_Takeover:SyncResearches(CorpID)

		return false
	end
	self:SetTickTime(self:GetTickTime() - 1)
end

function ENT:Think()
	local CorpID = self:GetCorpID()
	if(CorpID != 0) then
		if(self.TickDelay <= CurTime()) then
			self.TickDelay = CurTime() + 1

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

				local totalCost = upkeepCost + workerCost
				if(self.payDelay <= CurTime()) then
					Corporate_Takeover:AddMoney(CorpID, -totalCost)
				end

				local working = self:GetWorking()
				if(working && !sleeping) then
					self:ProcessTick(Corp, worker, CorpID)
					if(self.payDelay <= CurTime()) then
						self:SetWorkerEnergy(self:GetWorkerEnergy() - math.random(0,2))
					end
				end
			end

			if(workerCost == 0 && self.payDelay <= CurTime()) then
				Corporate_Takeover:AddMoney(CorpID, -upkeepCost)
			end

			local npc = self.npc
			if(npc && IsValid(npc) && self.payDelay <= CurTime()) then
				if(!sleeping) then
					local energy = self:GetWorkerEnergy()
					local fallAsleep = false

					if(energy < 35) then
						fallAsleep = math.random(1, 8) == 8
					elseif(energy < 25) then
						fallAsleep = math.random(1, 4) == 4
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

			if(self.payDelay <= CurTime()) then
				self.payDelay = CurTime() + Corporate_Takeover.Config.TickDelay
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
		if(energy <= 50) then		
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
end

function ENT:FireWorker(Corp)
	if(IsValid(self.npc)) then
		self.npc:Remove()
	end

	self:SetWorkerID(0)
	self:SetWorking(false)
	self:SetSleeping(false)
	self:SetWorkerEnergy(100)

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