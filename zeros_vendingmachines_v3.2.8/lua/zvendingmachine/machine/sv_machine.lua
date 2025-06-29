/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Machine = zvm.Machine or {}

if zvm.Vendingmachines == nil then zvm.Vendingmachines = {} end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

zvm.Vendingmachines_Interactions = {}

function zvm.Machine.Initialize(Machine)
	zclib.Debug("Machine_Initialize")

	zclib.EntityTracker.Add(Machine)

	Machine.Products = {}
	Machine.MachineName = "Vendingmachine"

	//Defines what moneytype should be used
	Machine.MoneyType = 1
	/*
	    1 = Money
	    2 = PS Points
	    3 = PS2 Points
	    4 = PS2 PremiumPoints
	*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

	table.insert(zvm.Vendingmachines, Machine)
end

function zvm.Machine.USE(Machine, ply)
	zclib.Debug("Machine_USE")
	if not IsValid(Machine) then return end
	if not IsValid(ply) then return end

	if IsValid(Machine:GetMachineUser()) then
		if ply ~= Machine:GetMachineUser() then
		 	zclib.Notify(ply, zvm.language.General["Occupied"], 1)
	 	end
		return
	end

	if Machine:OnStartButton(ply) == false then return end
	if Machine:GetEditConfig() then return end

	if IsValid(zvm.Vendingmachines_Interactions[ply:SteamID()]) then
		zvm.Machine.RemovePlayer(zvm.Vendingmachines_Interactions[ply:SteamID()])
	end

	// Check if the machines has products
	if Machine.Products and table.Count(Machine.Products) <= 0 then
		return
	end

	local BlockInteraction = hook.Run("zvm_BlockInteraction",ply,Machine)
	if BlockInteraction then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	Machine:EmitSound("zvm_ui_click")

	zvm.Machine.AssignePlayer(Machine, ply)
end

function zvm.Machine.AssignePlayer(Machine, ply)
	zclib.Debug("Machine_AssignePlayer")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

	local timerid = "player_interaction_check_ent_" .. Machine:EntIndex()
	zclib.Timer.Create(timerid,1,0,function()
		if not IsValid(Machine) then return end

		if IsValid(Machine:GetMachineUser()) then
			if zclib.util.InDistance(Machine:GetPos(), Machine:GetMachineUser():GetPos(), 500) == false then
				zvm.Machine.RemovePlayer(Machine)
			end
		else
			zvm.Machine.RemovePlayer(Machine)
		end
	end)

	/*
		This will auto log off the player if he takes to long
	*/
	local timerid01 = "player_interaction_idle_ent_" .. ply:SteamID64()
	zclib.Timer.Remove(timerid01)
	zclib.Timer.Create(timerid01,zvm.config.Vendingmachine.IdleTime or 300,1,function()
		if IsValid(Machine) then
			zvm.Machine.RemovePlayer(Machine)
		end
	end)

	Machine:SetMachineUser(ply)

	zvm.Vendingmachines_Interactions[ply:SteamID()] = Machine
end

function zvm.Machine.RemovePlayer(Machine)
	zclib.Debug("Machine_RemovePlayer")

	local ply = Machine:GetMachineUser()

	if IsValid(ply) then zvm.Vendingmachines_Interactions[ply:SteamID()] = nil end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

	local timerid = "player_interaction_check_ent_" .. Machine:EntIndex()
	zclib.Timer.Remove(timerid)
	Machine:SetMachineUser(NULL)

	if Machine:GetAllowCollisionInput() == true then
		Machine:SetAllowCollisionInput(false)
	end

	if Machine:GetEditConfig() == true then
		Machine:SetEditConfig(false)

		// If the player got removed while editing the config we send the data we got to all clients
		zvm.Machine.UpdateMachineData(Machine)
	end
end

// Gets called from client to collect money
util.AddNetworkString("zvm_Machine_Payout")
net.Receive("zvm_Machine_Payout", function(len,ply)
	zclib.Debug("zvm_Machine_Payout Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()

	if IsValid(machine) and machine:GetClass() == "zvm_machine" and zclib.util.InDistance(ply:GetPos(), machine:GetPos(), 500) and zclib.Player.IsOwner(ply, machine) then
		zvm.Machine.Payout(machine,ply)
	end
end)
function zvm.Machine.Payout(Machine,ply)
	zclib.Debug("Machine_Payout")

	local earning = Machine:GetEarnings()

	zclib.Notify(ply, "+ " .. zvm.Money.Display(earning,zvm.Money.GetSymbol(Machine.MoneyType)), 0)
	zclib.Money.Give(ply, earning)

	Machine:SetEarnings(0)
end
