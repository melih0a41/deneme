// Add XP to corporation
function Corporate_Takeover:AddXP(CorpID, amount)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		local xp = Corporate_Takeover.Corps[CorpID].xp
		local xpNeeded = Corporate_Takeover.Corps[CorpID].xpNeeded
		local level = Corporate_Takeover.Corps[CorpID].level

		if(Corporate_Takeover.Config.MaxCorpLevel != 0) then
			local max = Corporate_Takeover.Config.MaxCorpLevel
			local level = Corporate_Takeover.Corps[CorpID].level
			if(level >= max) then
				Corporate_Takeover.Corps[CorpID].level = max
				Corporate_Takeover.Corps[CorpID].xp = 0
				Corporate_Takeover.Corps[CorpID].xpNeeded = 0
				return false
			end
		end

		Corporate_Takeover.Corps[CorpID].xp = math.Round(Corp.xp + amount, 0)

		if(xp >= xpNeeded) then
			Corporate_Takeover.Corps[CorpID].level = Corporate_Takeover.Corps[CorpID].level + 1
			Corporate_Takeover.Corps[CorpID].xp = Corporate_Takeover.Corps[CorpID].xp - xpNeeded
			Corporate_Takeover.Corps[CorpID].xpNeeded = Corporate_Takeover.Config.XPNeededForCorpLevel(Corporate_Takeover.Corps[CorpID].level)


			local owner = player.GetBySteamID(Corp.owner)
			if(owner) then
				local message = Corporate_Takeover:Lang("corp_reached_level")
				message = string.Replace(message, "%name", Corp.name)
				message = string.Replace(message, "%level", Corporate_Takeover.Corps[CorpID].level)
				DarkRP.notify(owner, 0, 5, message)
			end
		end
	end
end

// Add XP to worker
function Corporate_Takeover:AddWorkerXP(CorpID, WorkerID, amount)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		local worker = Corp.workers[WorkerID]
		if(worker) then
			Corporate_Takeover.Corps[CorpID].workers[WorkerID].xp = worker.xp + amount

			local xp = Corporate_Takeover.Corps[CorpID].workers[WorkerID].xp
			local xpNeeded = Corporate_Takeover.Config.XPNeededForWorkerLevel(worker.level)
			local level = Corporate_Takeover.Corps[CorpID].workers[WorkerID].level

			if(xp >= xpNeeded) then
				Corporate_Takeover.Corps[CorpID].workers[WorkerID].level = level + 1
				Corporate_Takeover.Corps[CorpID].workers[WorkerID].xp = xp - xpNeeded
				Corporate_Takeover.Corps[CorpID].workers[WorkerID].xpNeeded = Corporate_Takeover.Config.XPNeededForWorkerLevel(level + 1)
			end

			if(Corporate_Takeover.Config.MaxWorkerLevel != 0) then
				local max = Corporate_Takeover.Config.MaxWorkerLevel
				local level = Corporate_Takeover.Corps[CorpID].workers[WorkerID].level
				if(level >= max) then
					Corporate_Takeover.Corps[CorpID].workers[WorkerID].level = max
					Corporate_Takeover.Corps[CorpID].workers[WorkerID].xp = 0
					Corporate_Takeover.Corps[CorpID].workers[WorkerID].xpNeeded = 0
				end
			end

			Corporate_Takeover:SyncWorkers(CorpID)
		end
	end
end

// Check if the player has enough money
function Corporate_Takeover:HasMoney(ply, amount)
	local money = ply:getDarkRPVar("money")
	return ((money - amount) >= 0)
end

// Add or remove money from corporation
function Corporate_Takeover:AddMoney(CorpID, amount)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		local vault = Corp.maxMoney
		local money = Corp.money
		if(money + amount > vault) then
			// Too much :/
			local overweight = (money + amount) - vault
			Corporate_Takeover.Corps[CorpID].money = vault

			if(Corp.desk && IsValid(Corp.desk)) then
				Corp.desk:AddMoney(amount)
			end

			return false, overweight
		end

		local total = math.Round(Corporate_Takeover.Corps[CorpID].money + amount, 0)
		Corporate_Takeover.Corps[CorpID].money = total

		if(Corp.desk && IsValid(Corp.desk)) then
			Corp.desk:AddMoney(amount)
		end

		if(Corporate_Takeover.Corps[CorpID].Bankrupt) then
			if(total > 0) then
				Corporate_Takeover.Corps[CorpID].Bankrupt = nil
			end
		end

		return true, 0
	end
end

// Deposit Money
function Corporate_Takeover:DepositMoney(ply, amount)
	local CorpID = ply.CTOCorpID
	if(!CorpID) then
		return false
	end

	local Corp = self:GetData(CorpID)
	if(Corp) then
		local hasMoney = Corporate_Takeover:HasMoney(ply, amount)

		if(!hasMoney) then
			DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("no_money_user"))
			return false
		end

		if(amount <= 0) then
			DarkRP.notify(ply, 1, 5, Corporate_Takeover:Lang("money_too_low"))
			return false
		end

		ply:addMoney(-amount)
		local full, over = self:AddMoney(CorpID, amount)

		if(!full) then
			ply:addMoney(over)
			amount = amount - over
		end

		self:SyncMoneyAndLevel(CorpID)

		local message = Corporate_Takeover:Lang("deposited_money")
		message = string.Replace(message, "%amount", DarkRP.formatMoney(amount))
		DarkRP.notify(ply, 0, 5, message)

		hook.Run("cto_corp_deposited", ply, DarkRP.formatMoney(amount))

		ply:EmitSound("corporate_takeover/move_money.wav")
	end
end
net.Receive("cto_MoneyAction", function(_, ply)
	if !Corporate_Takeover:NetCooldown(ply) then return end
	local withdraw = net.ReadBit() == 1
	local max = net.ReadBit() == 1

	if max  then
		if withdraw then
			if(!ply.CTOCorpID) then
				return false
			end

			local CorpID = ply.CTOCorpID
			if(ply.CTOCorpID != CorpID) then
				return false
			end

			local Corp = Corporate_Takeover:GetData(CorpID)
			if(Corp) then
				Corporate_Takeover:WithdrawMoney(ply, Corp.money)
			end
		else
			Corporate_Takeover:DepositMoney(ply, ply:getDarkRPVar("money"))
		end
	else
		if withdraw then
			Corporate_Takeover:WithdrawMoney(ply, net.ReadUInt(32))
		else
			Corporate_Takeover:DepositMoney(ply, net.ReadUInt(32))
		end
	end
end)

// Withdraw money
function Corporate_Takeover:WithdrawMoney(ply, amount, surpress)
	local CorpID = ply.CTOCorpID
	if(!CorpID) then
		return false
	end

	local Corp = self:GetData(CorpID)
	if(Corp) then
		local money = Corp.money
		if(amount > money) then
			DarkRP.notify(ply, 0, 5, Corporate_Takeover:Lang("no_money_withdraw"))
			return false
		end

		if(amount <= 0) then
			DarkRP.notify(ply, 0, 5, Corporate_Takeover:Lang("money_too_low"))
			return false
		end

		ply:addMoney(amount)
		self:AddMoney(CorpID, -amount)
		self:SyncMoneyAndLevel(CorpID)

		if(!surpress) then
			local message = Corporate_Takeover:Lang("withdrew_money")
			message = string.Replace(message, "%amount", DarkRP.formatMoney(amount))
			DarkRP.notify(ply, 0, 5, message)
		end

		hook.Run("cto_corp_withdrew", ply, DarkRP.formatMoney(amount))

		ply:EmitSound("corporate_takeover/move_money.wav")
	end
end