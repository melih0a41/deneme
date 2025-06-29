/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Machine = zvm.Machine or {}


/*

	Those functions are used to add a new item to the vendingmachine using PhysicsCollide

*/
// Called when a entity collides with the machine
function zvm.Machine.PhysicsCollide(Machine, other)
	zclib.Debug("Machine_PhysicsCollide")
	if not IsValid(Machine) then return end
	if Machine:GetAllowCollisionInput() == false then return end
	if not IsValid(other) then return end
	if zclib.util.CollisionCooldown(other) then return end
	if zvm.Machine.ItemAllowed(other:GetClass()) == false then return end
	if zvm.Machine.ReachedItemLimit(Machine) then return end

	// Called to check for any reason why the entity cant be added
	local BlockEntity = zvm.Module.BlockItemCheck(other:GetClass(), other, Machine)
	if BlockEntity then return end

	zvm.Machine.AddProduct(Machine, other)
end

// Checks if the itemclass is allowed to be inputed
function zvm.Machine.ItemAllowed(itemclass)
	local allowed_item = false

	// If this item class has a definition then lets instant add it
	if zvm.Definition.List[itemclass] then return true end

	for _, allowed in pairs(zvm.config.Vendingmachine.AllowedItems) do
		if (itemclass:find(allowed)) then
			allowed_item = true
		end
	end

	for _, banned in pairs(zvm.config.Vendingmachine.BannedItems) do
		if (itemclass:find(banned)) then
			allowed_item = false
		end
	end

	zclib.Debug("Machine_Item: " .. itemclass .. " | Allowed: " .. tostring(allowed_item))
	return allowed_item
end

// Adds a new item to the Vendingmachine
function zvm.Machine.AddProduct(Machine,product)
	zclib.Debug("Machine_AddProduct")

	local entData = duplicator.CopyEntTable(product)

	local extraData = zvm.ItemData.Catch(product)

	local DoesExist, ProductKey = zvm.ItemData.DoesExist(Machine,product,extraData,entData)

	local amount = 1

	local p_modeldata = zvm.ItemData.GetModelData(product,entData)

	local p_class = product:GetClass()

	// Overrides the itemname if specified
	local p_name = zvm.ItemData.Name(product,extraData)
	local override_name = zvm.Module.OnItemDataName(p_class, product, extraData)
	if override_name then p_name = override_name end

	// Overrides the item price if specified
	local p_price = 500
	local override_price = zvm.Module.OnItemDataPrice(p_class, product, extraData)
	if override_price then p_price = override_price end

	if p_class == "spawned_weapon" then amount = entData.DT.amount end

	if Machine:GetPublicMachine() == false then
		if DoesExist then
			Machine.Products[ProductKey].amount = Machine.Products[ProductKey].amount + amount
			zclib.Debug("Increasing Product Amount! Amount: " .. Machine.Products[ProductKey].amount)
		else
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

			// Here we make sure the weapon will not be stacked since we set this amount information somewhereelse
			// Fixes duplication glitch
			if p_class == "spawned_weapon" then entData.DT.amount = 1 end

			zvm.Machine.CreateProduct(Machine,entData,p_class,p_name,p_modeldata,extraData,amount,p_price)
		end
	else

		if amount > 1 then p_name = p_name .. " x" .. amount end

		zvm.Machine.CreateProduct(Machine,entData,p_class,p_name,p_modeldata,extraData,amount,p_price)
	end

	// Removes the ent
	SafeRemoveEntityDelayed(product, 0)

	// Updates the machine interface for the user which is editing it
	local ply = Machine:GetMachineUser()
	if IsValid(ply) then zvm.Machine.UpdateMachineData(Machine,ply) end
end

function zvm.Machine.CreateProduct(Machine,p_entdata,p_class,p_name,p_modeldata,p_extradata,p_amount,p_price)

	// This is needed for the thumbnail render systems util.IsValidModel to work properly
	if p_modeldata.model then util.PrecacheModel( p_modeldata.model ) end

	local data = {
		class = p_class,
		name = p_name,
		price = p_price,

		model = p_modeldata.model,
		model_skin = p_modeldata.model_skin,
		model_material = p_modeldata.model_material,
		model_bg = p_modeldata.model_bg,
		model_color = p_modeldata.model_color,

		extraData = p_extradata,
		amount = p_amount,

		entdata = p_entdata,
	}

	local overwrite = hook.Run("zvm_PreCreateProduct",data)
	if overwrite then data = overwrite end

	table.insert(Machine.Products,data)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380


/*

	Those net message will be called to edit the machine

*/
// Gets called from client when a Vendingmachine being edited
util.AddNetworkString("zvm_Machine_EditMode_Request")
net.Receive("zvm_Machine_EditMode_Request", function(len,ply)
	zclib.Debug("zvm_Machine_EditMode_Request Netlen: " .. len)

	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	if IsValid(machine) then
		machine:SetEditConfig(true)
		zvm.Machine.AssignePlayer(machine, ply)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

// Gets called from client when we want to start the adding items mode
util.AddNetworkString("zvm_Machine_AllowCollision_Request")
net.Receive("zvm_Machine_AllowCollision_Request", function(len,ply)
	zclib.Debug("zvm_Machine_AllowCollision_Request Netlen: " .. len)

	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	local allow = net.ReadBool()

	if IsValid(machine) then
		machine:SetAllowCollisionInput(allow)
	end
end)

// Gets called from client to remove a item
util.AddNetworkString("zvm_Machine_ProductList_RemoveItem")
net.Receive("zvm_Machine_ProductList_RemoveItem", function(len,ply)
	zclib.Debug("zvm_Machine_ProductList_RemoveItem Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	//288688181
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	local productid = net.ReadUInt(16)
	if productid == nil then return end

	// Remove item
	table.remove(machine.Products,productid)

	// Sends updated productlist out to player
	zvm.Machine.UpdateMachineData(machine,ply)
end)

// Gets called from client to change the restrictions
util.AddNetworkString("zvm_Machine_ProductList_ChangeRestriction")
net.Receive("zvm_Machine_ProductList_ChangeRestriction", function(len,ply)
	zclib.Debug("zvm_Machine_ProductList_ChangeRestriction Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	//288688181
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	local productid = net.ReadUInt(16)
	if productid == nil then return end

	local rankid = net.ReadInt(16)
	if rankid == nil then return end

	local jobid = net.ReadInt(16)
	if jobid == nil then return end

	if machine.Products[productid] then
		if rankid == -1 then rankid = nil end
		if jobid == -1 then jobid = nil end
		machine.Products[productid].rankid = rankid
		machine.Products[productid].jobid = jobid

		// Sends updated productlist out to player
		zvm.Machine.UpdateMachineData(machine,ply)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

// Gets called from client to change the Appearance of a item
util.AddNetworkString("zvm_Machine_ProductList_ChangeAppearance")
net.Receive("zvm_Machine_ProductList_ChangeAppearance", function(len,ply)
	zclib.Debug("zvm_Machine_ProductList_ChangeAppearance Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	//288688181
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	local productid = net.ReadUInt(16)
	if productid == nil then return end

	local name = net.ReadString()
	local bg_color = net.ReadColor()

	if machine.Products[productid] then

		machine.Products[productid].name = name
		machine.Products[productid].bg_color = bg_color

		// Sends updated productlist out to player
		zvm.Machine.UpdateMachineData(machine,ply)
	end
end)

// Gets called from client to change the Appearance of a item
util.AddNetworkString("zvm_Machine_ProductList_ChangePrice")
net.Receive("zvm_Machine_ProductList_ChangePrice", function(len,ply)
	zclib.Debug("zvm_Machine_ProductList_ChangePrice Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	//288688181
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	local productid = net.ReadUInt(16)
	if productid == nil then return end

	local price = net.ReadFloat()
	if price == nil then return end

	if machine.Products[productid] then
		machine.Products[productid].price = math.Clamp(price, 0.00001, 99999999999)

		// Sends updated productlist out to player
		zvm.Machine.UpdateMachineData(machine,ply)
	end
end)

// Gets called from client when the productlist got finished
util.AddNetworkString("zvm_Machine_ProductList_Finished")
net.Receive("zvm_Machine_ProductList_Finished", function(len,ply)
	zclib.Debug("zvm_Machine_ProductList_Finished Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	machine:SetAllowCollisionInput(false)
end)

// Gets called from client to switch to product ids
util.AddNetworkString("zvm_Machine_ProductList_ChangeOrder")
net.Receive("zvm_Machine_ProductList_ChangeOrder", function(len,ply)
	zclib.Debug("zvm_Machine_ProductList_ChangeOrder Net: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	local id01 = net.ReadUInt(16)
	local id02 = net.ReadUInt(16)

	zvm.Machine.SwitchProducts(machine, id01,id02)
end)

// Gets called when the apperance got changed
util.AddNetworkString("zvm_Machine_Appearance_Update")
net.Receive("zvm_Machine_Appearance_Update", function(len,ply)
	zclib.Debug("zvm_Machine_Appearance_Update Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end

	local machine_name = net.ReadString()
	local machine_moneytype = net.ReadUInt(32)

	machine.MachineName = machine_name
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

	if zclib.Player.IsAdmin(ply) then
		machine.MoneyType = machine_moneytype
	end
end)

// Changes the style of the machine
util.AddNetworkString("zvm_Machine_Style_Update")
net.Receive("zvm_Machine_Style_Update", function(len,ply)
	zclib.Debug("zvm_Machine_Style_Update Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end
	local StyleID = net.ReadUInt(32)

	machine:SetStyleID(StyleID)
end)

// Gets called from client when a vending machine config got finished
util.AddNetworkString("zvm_Machine_Edit_Finished")
net.Receive("zvm_Machine_Edit_Finished", function(len,ply)
	zclib.Debug("zvm_Machine_Edit_Finished Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()
	if not IsValid(machine) then return end
	if machine:GetClass() ~= "zvm_machine" then return end
	if zclib.Player.IsAdmin(ply) == false and zclib.Player.IsOwner(ply, machine) == false then return end


	machine:SetEditConfig(false)
	machine:SetAllowCollisionInput(false)

	// Removes the admin as user from machine, which should made the machine switch to idle automatic
	zvm.Machine.RemovePlayer(machine)

	// Sends the updated machine data to all clients
	timer.Simple(0.25,function()
		if IsValid(machine) then
			zvm.Machine.UpdateMachineData(machine)
		end
	end)
end)
