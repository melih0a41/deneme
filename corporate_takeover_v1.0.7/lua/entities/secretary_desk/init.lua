AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:ProcessTick(Corp, worker, CorpID)
	local owner = player.GetBySteamID(Corp.owner)
	if(owner) then
		if(self.CacheDelay < CurTime()) then
			self.CacheDelay = CurTime() + 20
			self.Cache = {}
			for k, v in ents.Iterator() do
				if(v.CTO && v.Getowning_ent && v:Getowning_ent() == owner) then
					self.Cache[#self.Cache + 1] = v
				else
					continue
				end
			end
		end

		local coffee = Corp.researches["automatic_coffee"] || false
		local coffee_self = Corp.researches["automatic_coffee_self"] || false
		local wakeup = Corp.researches["wakeup_employees"] || false

		if(!coffee && !wakeup) then return false end

		for k, v in ipairs(self.Cache) do
			if(!v || !IsValid(v)) then
				self.Cache[k] = nil
				continue
			end

			if(v == self) then
				if(!coffee_self) then
					continue
				end
			end

			if(coffee) then
				if(v.GetWorking && v:GetWorking()) then
					local energy = 100 - v:GetWorkerEnergy()
					if(energy > 0) then
						local price = Corporate_Takeover.Config.SecretaryCoffeeCost * energy
						local money = Corp.money
						if(money >= price) then
							Corporate_Takeover:AddMoney(CorpID, -price)
							self:SetLoss(price)
							self:SetProfitDiff(self:GetProfitDiff() - price)
							v:SetWorkerEnergy(100)
						end
					end
				end
			end

			if(wakeup) then
	            if(v.GetSleeping && v:GetSleeping()) then
	                local energy = v:GetWorkerEnergy()
	                if(energy >= 20) then
	                	local npc = v.npc
	                	if(npc && IsValid(npc)) then
		                    local ind = #Corporate_Takeover.Config.Sounds.sorry[npc.gender]
		                    local snd = Corporate_Takeover.Config.Sounds.sorry[npc.gender][math.random(1, ind)]
		                    npc:EmitSound(snd)
		                    v:SetSleeping(false)
		                    v:SetWorking(true)
		                    npc.sequence = "sitchair1"
		                    npc:SetAsleep(false)
	                	end
	                end
	            end
			end
		end
	end
end

