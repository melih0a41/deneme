/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Machine = zvm.Machine or {}

/*

	This system handels the lockpicking Feature

*/

local function CanLockPick_Vendingmachine(ent)

	if zvm.config.Vendingmachine.LockPick.Enabled == false then
		return false
	end

	if IsValid(ent:GetMachineUser()) then
		return false
	end

	if ent:GetPublicMachine() then
		return false
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

	if ent:GetEarnings() <= 0 then

		if zvm.config.Vendingmachine.LockPick.Reward_Item > 0 then
			if table.Count(ent.Products) > 0 then
				return true
			else
				return false
			end
		else
			return false
		end
	end

	return true
end
zclib.Hook.Add("canLockpick", "a_zvm_canLockpick", function(ply, ent)

	if IsValid(ent) and ent:GetClass() == "zvm_machine" and ply:IsPlayer() then
		if CanLockPick_Vendingmachine(ent) then

			local police
			if table.Count(zclib.config.Police.Jobs) > 0 then
				police = zclib.Police.Get()
			else
				police = true
			end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

			if police then
				return true
			else
				return false
			end
		else
			return false
		end
	end
end)

zclib.Hook.Add("lockpickTime", "a_zvm_lockpickTime", function(ply, ent)
	if (IsValid(ent) and ent:GetClass() == "zvm_machine" and ent:GetPublicMachine() == false and IsValid(ply) and ply:IsPlayer()) then
		return zvm.config.Vendingmachine.LockPick.Time
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function zvm.Machine.StealContent(machine,ply)

	// Lets get all the items in a clean list
	local content = {}
	for k, v in pairs(machine.Products) do
		for i = 1, v.amount do
			table.insert(content, k)
		end
	end

	// Calculate steal amount
	local steal_amount = math.Round(table.Count(content) * zvm.config.Vendingmachine.LockPick.Reward_Item)

	if table.Count(content) <= 3 then
		steal_amount = table.Count(content)
	end

	// Get random items from the content list
	local steal_content = {}
	for i = 1, steal_amount do
		local val, key = table.Random(content)
		table.insert(steal_content, val)
		table.remove(content, key)
	end

	// Remove Items from machine and adds the to the final content
	local final_content = {}
	for k, v in pairs(steal_content) do
		local itemData = machine.Products[v]
		local amount = math.Clamp(itemData.amount - 1,0,999)

		if amount <= 0 then
			zclib.Debug(itemData.name .. " is empty, Removed!")

			machine.Products[v] = nil
		else
			zclib.Debug(itemData.name .. " has " .. amount .. "x left!")
			machine.Products[v].amount = amount
		end

		table.insert(final_content,itemData)
	end

	// Spawn Crate
	timer.Simple(0.8,function()
		if IsValid(machine) then

			local crate = zvm.Machine.SpawnCrate(machine,final_content)

			crate:EmitSound("zvm_box_hit")

			zvm.Player.AddPackage(ply,crate)

			zclib.Player.SetOwner(crate, ply)
		end
	end)

	// Play output animation
	zclib.NetEvent.Create("zvm_machine_output", {machine})

	// Create spark effect to show machine being manipulated
	zclib.Effect.Generic("ManhackSparks", machine:GetPos() + machine:GetRight() * -25 + machine:GetUp() * 75 + machine:GetForward() * -17)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	machine:EmitSound("zvm_machine_hijack")

	zvm.Machine.UpdateMachineData(machine)
end

zclib.Hook.Add("onLockpickCompleted", "a_zvm_onLockpickCompleted", function(ply, success, ent)
	if IsValid(ent) and ent:GetClass() == "zvm_machine" and ply:IsPlayer() and CanLockPick_Vendingmachine(ent) and success then

		local reward = ent:GetEarnings() * zvm.config.Vendingmachine.LockPick.Reward
		if reward > 0 then
			ent:SetEarnings(math.Clamp(ent:GetEarnings() - reward,0,9999999999))
			zclib.Money.Give(ply, reward)
			zclib.Notify(ply, "+ " .. zvm.Money.Display(reward, zvm.Money.GetSymbol(1)), 0)
		end

		if table.Count(ent.Products) > 0 and zvm.config.Vendingmachine.LockPick.Reward_Item > 0 then zvm.Machine.StealContent(ent,ply) end

		zclib.Police.MakeWanted(ply,zvm.config.Vendingmachine.LockPick.Wanted_Message,zvm.config.Vendingmachine.LockPick.Wanted_Time)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
