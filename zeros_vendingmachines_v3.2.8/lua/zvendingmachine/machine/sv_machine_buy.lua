/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Machine = zvm.Machine or {}

/*

	Those functions get called to buy items from the vendingmachine

*/
// Gets called from client when a player presses the pay button
util.AddNetworkString("zvm_Machine_Buy_Request")
net.Receive("zvm_Machine_Buy_Request", function(len, ply)
	zclib.Debug("zvm_Machine_Buy_Request Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	local dataLength = net.ReadUInt(16)
	local dataDecompressed = util.Decompress(net.ReadData(dataLength))
	if dataDecompressed == nil then return end
	local BuyList = util.JSONToTable(dataDecompressed)

	if IsValid(machine) and machine:GetClass() == "zvm_machine" and zclib.util.InDistance(ply:GetPos(), machine:GetPos(), 500) and machine:GetMachineUser() == ply then
		zvm.Machine.BuyRequest(machine, BuyList, ply)
	end
end)
function zvm.Machine.BuyRequest(machine,BuyList,ply)
	local IsPublicMachine = machine:GetPublicMachine()

	local limit = zvm.util.GetFirstValidRank(ply,zvm.config.Vendingmachine.ItemLimit,zvm.config.Vendingmachine.ItemLimit["Default"])

	local content = {}
	local cost = 0
	local itemCount = 0
	local InCorrectRank = false
	local InCorrectJob = false
	local ItemExciedsAmount = false

	for k, v in pairs(BuyList) do

		if v <= 0 then continue end

		local itemData = machine.Products[k]
		if itemData == nil then continue end

		// If some module wants to modify the product data before purchase
		local ChangedData = zvm.Module.ModifyProductDataOnPurchase(itemData.class, itemdata, ply)
		if ChangedData then itemData = ChangedData end

		// Check if the player has the correct rank for this item
		InCorrectRank = zvm.Machine.RankCheck(ply, itemData) == false
		if InCorrectRank then break end

		// Check if the player has the correct job for this item
		InCorrectJob = zvm.Machine.JobCheck(ply, itemData) == false
		if InCorrectJob then break end

		for i = 1,v do
			table.insert(content, itemData)
			itemCount = itemCount + 1
		end

		// If the machine has not infite supply and the player wants to buy more items then it has, then we stop
		if IsPublicMachine == false and v > itemData.amount then ItemExciedsAmount = true
			break
		end

		cost = cost + (itemData.price * v)
	end

	if InCorrectRank then
		zclib.Debug("InCorrectRank")
		return
	end

	if InCorrectJob then
		zclib.Debug("InCorrectJob")
		return
	end

	if IsPublicMachine == true and itemCount > limit then
		zclib.Debug("BuyLimitReached")
		return
	end

	if IsPublicMachine == false and ItemExciedsAmount then
		zclib.Debug("BuyLimitReached")
		return
	end

	if zvm.Player.GetPackageCount(ply) >= zvm.config.Vendingmachine.PackageLimit then
		zclib.Notify(ply, zvm.language.General["BuyLimitReached"], 1)
		zvm.Machine.RemovePlayer(machine)
		return
	end

	if zvm.Money.HasMoney(ply,machine.MoneyType,cost) then

		if IsPublicMachine == false then

			// Remove Items from machine
			for k, v in pairs(BuyList) do
				local itemData = machine.Products[k]
				if itemData == nil then continue end

				local amount = math.Clamp(itemData.amount - v,0,999)

				if amount <= 0 then
					zclib.Debug(itemData.name .. " is empty, Removed!")
					machine.Products[k] = nil
				else
					zclib.Debug(itemData.name .. " has " .. amount .. "x left!")
					machine.Products[k].amount = amount
				end
			end

			//Add money to machine
			machine:SetEarnings(machine:GetEarnings() + cost)
		end

		// Take Money
		zvm.Money.TakeMoney(ply,machine.MoneyType,cost)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

		// Spawn Crate
		timer.Simple(0.8,function()
			if IsValid(machine) then

				local crate = zvm.Machine.SpawnCrate(machine,content)

				// Custom Hook
				hook.Run("zvm_OnItemBought" ,ply, machine, crate, cost)

				crate:EmitSound("zvm_box_hit")

				zvm.Player.AddPackage(ply,crate)

				zclib.Player.SetOwner(crate, ply)
			end
		end)

		// Play output animation
		zclib.NetEvent.Create("zvm_machine_output", {machine})

		zclib.Notify(ply, zvm.language.General["PurchaseSuccessful"], 0)

		zvm.Machine.UpdateMachineData(machine)
	else
		zclib.Notify(ply, zvm.language.General["NotEnoughMoney"], 1)
	end

	zvm.Machine.RemovePlayer(machine)
end

// Spawns the crate
function zvm.Machine.SpawnCrate(Machine,content)
	zclib.Debug("Machine_SpawnCrate")

	local ent = ents.Create("zvm_crate")
	ent:SetPos(Machine:GetPos() + Machine:GetUp() * 25 + Machine:GetRight() * -45)
	ent:Spawn()
	ent:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	ent.Content = content
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

// Gets called from client to stop interfacting with the machine
util.AddNetworkString("zvm_Machine_Buy_Cancel")
net.Receive("zvm_Machine_Buy_Cancel", function(len,ply)
	zclib.Debug("zvm_Machine_Buy_Cancel Netlen: " .. len)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()

	if IsValid(machine) and machine:GetClass() == "zvm_machine" and zclib.util.InDistance(ply:GetPos(), machine:GetPos(), 500) then
		zvm.Machine.RemovePlayer(machine)
	end
end)
