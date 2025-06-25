/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

if (not SERVER) then return end

zcrga = zcrga or {}
zcrga.f = zcrga.f or {}


function zcrga.f.Machine_Initialize(machine)
	zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", machine:GetPos(), machine:GetAngles(), "models/zerochain/props_arcade/zap_coinpusher_glass.mdl")
	machine.Chest = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", machine:GetPos(), machine:GetAngles(), "models/zerochain/props_arcade/zap_coinpusher_chest.mdl")
	machine.Coin = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", machine:GetPos(), machine:GetAngles(), "models/zerochain/props_arcade/zap_coinanim.mdl")
	machine.InsertCoin = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", machine:GetPos(), machine:GetAngles(), "models/zerochain/props_arcade/zap_coinanim.mdl")

	-- Field01
	machine.Field01_money = 0
	local Field01Pos = machine:GetPos() + machine:GetUp() * 6 + machine:GetForward() * 16
	machine.Field01_CoinPile = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field01Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coinpile.mdl")
	machine.Field01_CoinPile:SetBodygroup(0, 6)
	machine.Field01_CoinWin_small = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field01Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coin_win_small.mdl")
	machine.Field01_CoinWin_medium = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field01Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coin_win_medium.mdl")
	machine.Field01_CoinWin_big = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field01Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coin_win_big.mdl")
	machine.Field01_CoinWin_small:SetNoDraw(true)
	machine.Field01_CoinWin_medium:SetNoDraw(true)
	machine.Field01_CoinWin_big:SetNoDraw(true)

	-- Field01
	machine.Field02_money = 0
	local Field02Pos = machine:GetPos()
	machine.Field02_CoinPile = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field02Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coinpile.mdl")
	machine.Field02_CoinPile:SetBodygroup(0, 6)
	machine.Field02_CoinWin_small = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field02Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coin_win_small.mdl")
	machine.Field02_CoinWin_medium = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field02Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coin_win_medium.mdl")
	machine.Field02_CoinWin_big = zcrga.f.Machine_CreateProp(machine,"zcrga_animbase", Field02Pos, machine:GetAngles(), "models/zerochain/props_arcade/zap_coin_win_big.mdl")
	machine.Field02_CoinWin_small:SetNoDraw(true)
	machine.Field02_CoinWin_medium:SetNoDraw(true)
	machine.Field02_CoinWin_big:SetNoDraw(true)

	timer.Simple(1, function()
		if (IsValid(machine)) then
			zcrga_CreateAnimTable(machine, "run", 1)
		end
	end)

	if (zcrga.config.StartEmpty == false) then
		local startMoney = math.random(zcrga.config.TriggerAmount / 5, zcrga.config.TriggerAmount / 2)
		machine:SetMoneyCount(startMoney)
		machine.Field01_money = startMoney * 0.7
		machine.Field02_money = startMoney * 0.3
	end

	zcrga.f.Machine_UpdateVisual(machine,1)
	zcrga.f.Machine_UpdateVisual(machine,2)

	machine.InUse = false
	machine.LockPickTime = zcrga.config.LockPickTime
end

function zcrga.f.Machine_CreateProp(machine,class,pos,ang,model)
	local ent = ents.Create(class)
	ent:SetModel(model)
	ent:SetAngles( ang )
	ent:SetPos( pos )
	ent:SetParent(machine)
	ent:Spawn()
	ent:Activate()
	ent.PhysgunDisabled = false
	return ent
end

function zcrga.f.Machine_USE(machine,ply)
	if (machine.InUse) then return end
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end

	if table.Count(zcrga.config.OwnerJobs) > 0 and table.HasValue(zcrga.config.OwnerJobs, team.GetName(ply:Team())) then

		if machine:AddMoneyButton(ply) then

			if zcrga.f.Money_CanAfford(ply,zcrga.config.TransferAmount) then
				zcrga.f.Money_Take(ply, zcrga.config.TransferAmount)


				machine.Field01_money = machine.Field01_money + (zcrga.config.TransferAmount / 2)
				math.Clamp(machine.Field01_money,0,999999999999)

				machine.Field02_money = machine.Field02_money + (zcrga.config.TransferAmount / 2)
				math.Clamp(machine.Field02_money,0,999999999999)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

				zcrga.f.Machine_UpdateVisual(machine,1)
				zcrga.f.Machine_UpdateVisual(machine,2)

				zcrga.f.Notify(ply, "+" .. zcrga.config.Currency .. zcrga.config.TransferAmount, 2)
			else
				zcrga.f.Notify(ply, "You cant afford this!", 1)
			end
		elseif machine:RemoveMoneyButton(ply) then

			local curMoney = machine:GetMoneyCount()
			if curMoney > 0 then

				if curMoney > zcrga.config.TransferAmount then

					machine.Field01_money = curMoney / 2
					machine.Field02_money = curMoney / 2

					machine.Field01_money = machine.Field01_money - (zcrga.config.TransferAmount / 2)
					math.Clamp(machine.Field01_money, 0, 999999999999)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

					machine.Field02_money = machine.Field02_money - (zcrga.config.TransferAmount / 2)
					math.Clamp(machine.Field02_money, 0, 999999999999)

					zcrga.f.Money_Give(ply, zcrga.config.TransferAmount)
				else

					machine.Field01_money = 0

					machine.Field02_money = 0

					zcrga.f.Money_Give(ply, curMoney)
				end
				zcrga.f.Machine_UpdateVisual(machine,1)
				zcrga.f.Machine_UpdateVisual(machine,2)
			else
				zcrga.f.Notify(ply, "Machine is empty!", 1)
			end
		else
			zcrga.f.Machine_ValidPlayer(machine,ply)
		end
	else
		zcrga.f.Machine_ValidPlayer(machine,ply)
	end

end


local coinAnimData = {
	[1] = {
		anim = "coin_field01_shot01",
		Hit01_delay = 1,
		Hit02_delay = -1,
		Effect_delay = 1.1,
		EffectPos = "effect_pos03",
		field = 1
	},
	[2] = {
		anim = "coin_field01_shot02",
		Hit01_delay = 1,
		Hit02_delay = -1,
		Effect_delay = 1.1,
		EffectPos = "effect_pos04",
		field = 1
	},
	[3] = {
		anim = "coin_field02_shot01",
		Hit01_delay = 1,
		Hit02_delay = 1.25,
		Effect_delay = 1.6,
		EffectPos = "effect_pos01",
		field = 2
	},
	[4] = {
		anim = "coin_field02_shot02",
		Hit01_delay = 1,
		Hit02_delay = 1.25,
		Effect_delay = 1.6,
		EffectPos = "effect_pos02",
		field = 2
	}
}



-- Here we check if the player is allowed do play
function zcrga.f.Machine_ValidPlayer(machine,ply)

	-- Is this machine allready used by a player?
	if (IsValid(machine.InUse_Player) and machine.InUse_Player:IsPlayer()) then

		-- Does the player still play with it?
		if (CurTime() < machine.LastInteraction) then

			-- Is this the current Player who plays the machine?
			if (ply ~= machine.InUse_Player) then
				zcrga.f.Notify(ply, "Another Player is using this right now!", 1)

				return
			end
		else
			machine.InUse_Player = nil
		end

		if ply ~= machine.InUse_Player and ply.zcrga_LastInteraction and ply.zcrga_LastInteraction > CurTime() then

			local waitTime = ply.zcrga_LastInteraction - CurTime()
			zcrga.f.Notify(ply, "You have do wait " .. math.Round(waitTime) .. " seconds before you can use another machine!", 1)

			return
		end
	else
		-- Did the player allready interact with a machine?
		if ply.zcrga_LastInteraction and ply.zcrga_LastInteraction > CurTime() then

			local waitTime = ply.zcrga_LastInteraction - CurTime()
			zcrga.f.Notify(ply, "You have do wait " .. math.Round(waitTime) .. " seconds before you can use another machine!", 1)

			return
		end
	end

	-- Here we take the money of the player or return if he cant afford it
	if not zcrga.f.MoneyPay(ply) then return end

	machine.InUse_Player = ply
	machine.LastInteraction = CurTime() + zcrga.config.PlayerCoolDown
	ply.zcrga_LastInteraction = machine.LastInteraction

	-- This Starts the whole game
	machine.InUse = true
	zcrga.f.Machine_InsertTheCoin(machine,ply)
end

-- This Handles the insert Coin logic
function zcrga.f.Machine_InsertTheCoin(machine,ply)
	zcrga_CreateEffectTable(nil, "zap_coininsert", machine, machine:GetAngles(), machine:GetPos(), nil)
	zcrga_CreateAnimTable(machine.InsertCoin, "coin_insert", 1)

	-- Make Coin Visible
	timer.Simple(0.1, function()
		if (IsValid(machine)) then
			machine.InsertCoin:SetNoDraw(false)
		end
	end)

	local rndAnimData = coinAnimData[math.random(#coinAnimData)]

	-- Play Throw animation for coin
	timer.Simple(0.5, function()
		if (IsValid(machine)) then
			machine.InsertCoin:SetNoDraw(true)
			machine.Coin:SetNoDraw(false)
			zcrga_CreateAnimTable(machine.Coin, rndAnimData.anim, 1)
			zcrga_CreateEffectTable(nil, "zap_coinpusher_shoot", machine, machine:GetAngles(), machine:GetPos() + machine:GetUp() * 25 + machine:GetForward() * -7, nil)
		end
	end)

	-- Play first hit metal sound
	timer.Simple(rndAnimData.Hit01_delay, function()
		if (IsValid(machine)) then
			zcrga_CreateEffectTable(nil, "zap_coinpusher_coinhit_sfx", machine, machine:GetAngles(), machine:GetPos(), nil)
		end
	end)

	-- Play second hit metal sound
	if (rndAnimData.Hit02_delay ~= -1) then
		timer.Simple(rndAnimData.Hit02_delay, function()
			if (IsValid(machine)) then
				zcrga_CreateEffectTable(nil, "zap_coinpusher_coinhit_sfx", machine, machine:GetAngles(), machine:GetPos(), nil)
			end
		end)
	end

	-- Play hit coin pile sound
	timer.Simple(rndAnimData.Effect_delay, function()
		if (IsValid(machine)) then
			zcrga_CreateEffectTable("zap_coinpusher_coinhit", "zap_coinpusher_hitpile", machine, machine:GetAngles(), machine.Coin:GetAttachment(machine.Coin:LookupAttachment(rndAnimData.EffectPos)).Pos, nil)
			machine.Coin:SetNoDraw(true)

			if (rndAnimData.field == 1) then
				machine.Field01_money = machine.Field01_money + zcrga.config.PlayPrice
				zcrga.f.Machine_UpdateField01(machine,ply)
			elseif (rndAnimData.field == 2) then
				machine.Field02_money = machine.Field02_money + zcrga.config.PlayPrice
				zcrga.f.Machine_UpdateField02(machine,ply)
			end
		end
	end)
end

-- This Handles the logic for our first field
function zcrga.f.Machine_UpdateField01(machine,ply)
	local WinChance = zcrga.f.Machine_CalcWinChance(machine,1)

	if (WinChance == 0) then
		zcrga.f.Machine_NoWin(machine)
	else
		local DropAmount = zcrga.f.Machine_CalcWinAmount(machine,1)

		if (DropAmount == 0) then
			zcrga.f.Machine_NoWin(machine)
		else

			zcrga.f.Machine_PlayCoinFallAnim(machine,DropAmount, 1)
			local prizeMoney = 0

			if (machine.Field01_money < zcrga.config.Prize[DropAmount].Amount) then
				prizeMoney = machine.Field01_money
				machine.Field01_money = 0
			else
				prizeMoney = zcrga.config.Prize[DropAmount].Amount
				machine.Field01_money = machine.Field01_money - zcrga.config.Prize[DropAmount].Amount
			end

			-- This updates our coin pile
			zcrga.f.Machine_UpdateVisual(machine,1)

			timer.Simple(1, function()
				if (IsValid(machine)) then
					machine.Field02_money = machine.Field02_money + prizeMoney
					--Trigger next field and give him
					zcrga.f.Machine_UpdateField02(machine,ply)
				end
			end)
		end
	end

	-- This updates our coin pile
	zcrga.f.Machine_UpdateVisual(machine,1)
	zcrga.f.Machine_UpdateVisual(machine,2)
end

-- This Handles the logic for our second field
function zcrga.f.Machine_UpdateField02(machine,ply)
	local WinChance = zcrga.f.Machine_CalcWinChance(machine,2)

	if (WinChance == 0) then
		zcrga.f.Machine_NoWin(machine)
	else
		local PrizeSize = zcrga.f.Machine_CalcWinAmount(machine,2)

		if (PrizeSize == 0) then
			zcrga.f.Machine_NoWin(machine)
		else

			zcrga.f.Machine_PlayCoinFallAnim(machine,PrizeSize, 2)
			local prizeMoney = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44

			if (machine.Field02_money < zcrga.config.Prize[PrizeSize].Amount) then
				prizeMoney = machine.Field02_money
				machine.Field02_money = 0
			else
				prizeMoney = zcrga.config.Prize[PrizeSize].Amount
				machine.Field02_money = machine.Field02_money - zcrga.config.Prize[PrizeSize].Amount
			end

			timer.Simple(1.3, function()
				if (IsValid(machine)) then
					zcrga.f.Machine_GivePrize(machine,prizeMoney, ply)
				end
			end)
		end
	end

	-- This updates our coin pile
	zcrga.f.Machine_UpdateVisual(machine,1)
	zcrga.f.Machine_UpdateVisual(machine,2)
end

-- Here we check if the player wins something
function zcrga.f.Machine_CalcWinChance(machine,field)
	local currentMoney = 0
	local MoneyCap = zcrga.config.TriggerAmount / 2

	if (field == 1) then
		currentMoney = machine.Field01_money
	elseif (field == 2) then
		currentMoney = machine.Field02_money
	end

	local ItemChancePool = {}

	for i = 1, (100 - (100 * zcrga.config.WinChance)) do
		table.insert(ItemChancePool, 0)
	end

	for i = 1, (100 * zcrga.config.WinChance) do
		table.insert(ItemChancePool, 1)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	-- This Increases the chance of money dropping if there is allready much mony on the field
	if (currentMoney > MoneyCap) then
		local prizePoolCount = table.Count(ItemChancePool)
		prizePoolCount = prizePoolCount / 2

		for i = 1, prizePoolCount do
			table.insert(ItemChancePool, 1)
		end
	end

	return table.Random(ItemChancePool)
end

-- Here we check how much the player wins
function zcrga.f.Machine_CalcWinAmount(machine,field)
	local PrizeAmount = -1
	local PrizeAmountPool = {}
	local currentMoney

	if (field == 1) then
		currentMoney = machine.Field01_money
	elseif (field == 2) then
		currentMoney = machine.Field02_money
	end

	local MoneyCap = zcrga.config.TriggerAmount / 2

	if (currentMoney > MoneyCap / 3) then
		-- This builds the Basic Prize Amount Pool defined in the config
		for k, v in pairs(zcrga.config.Prize) do
			for i = 1, v.WinChance do
				table.insert(PrizeAmountPool, k)
			end
		end

		-- This will increase our chance of wining big if the machine gets too full
		-- More Money in Machine == We Win More
		local DropBoni

		if (currentMoney > MoneyCap) then
			-- Big Win
			DropBoni = 3
		end

		if (DropBoni) then
			-- This gives us the influence count our DropBoni has in the PrizePool
			local InfluenceChance = table.Count(PrizeAmountPool) * zcrga.config.TriggerChance -- 90% Chance our drop money influences the win

			-- Here we add the Bonus Drop Chance
			for i = 1, InfluenceChance do
				table.insert(PrizeAmountPool, DropBoni)
			end
		end

		PrizeAmount = table.Random(PrizeAmountPool)
	else
		-- No Win
		PrizeAmount = 0
	end

	return PrizeAmount
end

-- This Function gets called when the player wins nothing
function zcrga.f.Machine_NoWin(machine)
	machine.InUse = false
end


-- This function plays the coin fall animation depending on the win size
function zcrga.f.Machine_PlayCoinFallAnim(machine,size, field)
	local field_big
	local field_medium
	local field_small
	local effectPos

	if (field == 1) then
		field_big = machine.Field01_CoinWin_big
		field_medium = machine.Field01_CoinWin_medium
		field_small = machine.Field01_CoinWin_small
		effectPos = machine:GetPos() + machine:GetUp() * 6 + machine:GetForward() * 16
	elseif (field == 2) then
		effectPos = machine:GetPos()
		field_big = machine.Field02_CoinWin_big
		field_medium = machine.Field02_CoinWin_medium
		field_small = machine.Field02_CoinWin_small

		if (not zcrga.config.NoWinMusic) then
			if (size == 1) then
				zcrga_CreateEffectTable(nil, "zap_coinpusher_music_win_small", machine, machine:GetAngles(), machine:GetPos(), nil)
			elseif (size == 2) then
				zcrga_CreateEffectTable(nil, "zap_coinpusher_music_win_medium", machine, machine:GetAngles(), machine:GetPos(), nil)
			elseif (size == 3) then
				zcrga_CreateEffectTable(nil, "zap_coinpusher_music_win_big", machine, machine:GetAngles(), machine:GetPos(), nil)
			end
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44

	if (size == 1) then
		field_small:SetNoDraw(false)
		zcrga_CreateAnimTable(field_small, "win", 2)
		zcrga_CreateEffectTable("zap_coinpusher_win_coinexplo_small", "zap_coinpusher_coin_small", machine, machine:GetAngles(), effectPos, nil)
	elseif (size == 2) then
		field_medium:SetNoDraw(false)
		zcrga_CreateAnimTable(field_medium, "win", 2)
		zcrga_CreateEffectTable("zap_coinpusher_win_coinexplo_medium", "zap_coinpusher_coin_medium", machine, machine:GetAngles(), effectPos, nil)
	elseif (size == 3) then
		field_big:SetNoDraw(false)
		zcrga_CreateAnimTable(field_big, "win", 2)
		zcrga_CreateEffectTable("zap_coinpusher_win_coinexplo_big", "zap_coinpusher_coin_big", machine, machine:GetAngles(), effectPos, nil)
	end

	local resetTime = machine:SequenceDuration(machine:GetSequence())

	timer.Simple(resetTime, function()
		if (IsValid(machine)) then
			field_small:SetNoDraw(true)
			field_medium:SetNoDraw(true)
			field_big:SetNoDraw(true)
		end
	end)

	timer.Simple(0.5, function()
		if (IsValid(machine)) then
			if (field == 1) then
				zcrga_CreateEffectTable("zap_coinpusher_coinhit", "zap_coinpusher_hitpile", machine, machine:GetAngles(), machine:GetPos() + machine:GetUp() * 31 + machine:GetForward() * -3, nil)
				zcrga_CreateEffectTable("zap_coinpusher_coinhit", "zap_coinpusher_hitpile", machine, machine:GetAngles(), machine:GetPos() + machine:GetUp() * 31 + machine:GetForward() * -3 + machine:GetRight() * 7, nil)
				zcrga_CreateEffectTable("zap_coinpusher_coinhit", "zap_coinpusher_hitpile", machine, machine:GetAngles(), machine:GetPos() + machine:GetUp() * 31 + machine:GetForward() * -3 + machine:GetRight() * -7, nil)
			end

			if (size == 1) then
				zcrga_CreateEffectTable(nil, "zap_coinpusher_coin_small", machine, machine:GetAngles(), machine:GetPos(), nil)
			elseif (size == 2) then
				zcrga_CreateEffectTable(nil, "zap_coinpusher_coin_medium", machine, machine:GetAngles(), machine:GetPos(), nil)
			elseif (size == 3) then
				zcrga_CreateEffectTable(nil, "zap_coinpusher_coin_big", machine, machine:GetAngles(), machine:GetPos(), nil)
			end
		end
	end)
end

function zcrga.f.Machine_UpdateVisual(machine,field)
	local amount = (machine.Field01_money + machine.Field02_money)

	if (amount > zcrga.config.AmountToReset) then
		machine:SetMoneyCount(amount)
	else
		local startMoney = math.random(zcrga.config.TriggerAmount / 5, zcrga.config.TriggerAmount / 2)

		machine:SetMoneyCount(startMoney)
		machine.Field01_money = startMoney * 0.7
		machine.Field02_money = startMoney * 0.3
	end

	local currentMoney
	local coinPile
	local MoneyCap = zcrga.config.TriggerAmount / 2 -- We Half it because we have 2 fields
	local currentBG

	if (field == 1) then
		currentMoney = machine.Field01_money
		coinPile = machine.Field01_CoinPile
	elseif (field == 2) then
		currentMoney = machine.Field02_money
		coinPile = machine.Field02_CoinPile
	end

	if (currentMoney > 0) then
		if (currentMoney < MoneyCap / 6) then
			currentBG = 1
		elseif (currentMoney < MoneyCap / 5) then
			currentBG = 2
		elseif (currentMoney < MoneyCap / 4) then
			currentBG = 3
		elseif (currentMoney < MoneyCap / 3) then
			currentBG = 4
		elseif (currentMoney < MoneyCap / 2) then
			currentBG = 5
		elseif (currentMoney < MoneyCap) then
			currentBG = 6
		elseif (currentMoney >= MoneyCap) then
			currentBG = 7
		end

		coinPile:SetBodygroup(0, currentBG)
	else
		coinPile:SetBodygroup(0, 0)
	end
end




-- This function gives the player his prize
function zcrga.f.Machine_GivePrize(machine,PrizeMoney, ply)
	zcrga_CreateEffectTable(nil, "zap_coinpusher_door", machine, machine:GetAngles(), machine:GetPos(), nil)
	zcrga_CreateAnimTable(machine.Chest, "give", 2)

	timer.Simple(0.2, function()
		if (IsValid(machine)) then
			zcrga.f.MoneySend(ply, PrizeMoney)
			machine.InUse = false
		end
	end)
end


function zcrga.f.Machine_DebugFields(machine)
	print("End PlayStats")
	print("Field01: " .. machine.Field01_money)
	print("Field02: " .. machine.Field02_money)
	print("------------------------------")
end




hook.Add("canLockpick", "zcrga_canLockpick", function(ply, ent)

	if IsValid(ent) and ent:GetClass() == "zcrga_machine" then
		if zcrga.config.CanBeLockPicked and ent.InUse == false and ent:GetMoneyCount() > 0 then
			local police

			for k, v in pairs(zcrga_PlayerList) do
				if IsValid(v) and v:IsPlayer() and v:Alive() and table.HasValue(zcrga.config.TEAM_POLICE, team.GetName( v:Team() )) then
					police = v
					break
				end
			end

			if (police or table.Count(zcrga.config.TEAM_POLICE) == 0) then
				ent.InUse = true

				return true
			else
				return false
			end
		else
			return false
		end
	end
end)

hook.Add("lockpickTime", "zcrga_lockpickTime", function(ply, ent)
	if (IsValid(ent) and ent:GetClass() == "zcrga_machine" and ply:IsPlayer()) then
		return zcrga.config.LockPickTime
	end
end)

hook.Add("onLockpickCompleted", "zcrga_onLockpickCompleted", function(ply, success, ent)
	if (IsValid(ent) and ent:GetClass() == "zcrga_machine" and ply:IsPlayer()) then
		if (success) then
			local winPool = {}

			for i = 1, 100 * zcrga.config.LockPick_WinChance do
				table.insert(winPool, true)
			end

			for i = 1, 100 * (1 - zcrga.config.LockPick_WinChance) do
				table.insert(winPool, false)
			end

			local Win = table.Random(winPool)

			if (Win == true) then
				zcrga.f.Machine_PlayCoinFallAnim(ent,1, 1)
				zcrga.f.Machine_PlayCoinFallAnim(ent,1, 2)
				local money = ent:GetMoneyCount() * zcrga.config.LockPick_WinAmount

				zcrga.f.Machine_GivePrize(ent,money, ply)

				for k, v in pairs(zcrga_PlayerList) do
					if IsValid(v) and v:IsPlayer() and v:Alive() and table.HasValue(zcrga.config.TEAM_POLICE, team.GetName( v:Team() ) ) then
						ply:wanted(v, "PickLocked a ArcadeMachine!", 120)
					end
				end

				ent:SetMoneyCount(ent:GetMoneyCount() - money)
				ent.Field01_money = money * 0.7
				ent.Field02_money = money * 0.3

				zcrga.f.Machine_UpdateVisual(ent,1)
				zcrga.f.Machine_UpdateVisual(ent,2)
			else
				zcrga.f.Notify(ply, "It almost opened!", 1)
			end
		end

		ent.InUse = false
	end
end)
