VoidLib.SQL:Connect()

util.AddNetworkString("VoidCases_RequestInventory")
util.AddNetworkString("VoidCases_NetworkInventory")
util.AddNetworkString("VoidCases_NetworkMarketplace")
util.AddNetworkString("VoidCases_NetworkItem")

util.AddNetworkString("VoidCases_NetworkEquippedOne")
util.AddNetworkString("VoidCases_NetworkEquipped")

util.AddNetworkString("VoidCases_EquipPerma")
util.AddNetworkString("VoidCases_DeleteInventoryItem")

util.AddNetworkString("VoidCases_RequestAdminInventory")
util.AddNetworkString("VoidCases_NetworkAdminInventory")
util.AddNetworkString("VoidCases_AddAdminItem")

local L = VoidCases.Lang.GetPhrase

VoidCases.PlayerInventories = VoidCases.PlayerInventories or {}
VoidCases.EquippedPermas = VoidCases.EquippedPermas or {}

function VoidCases.OldInventoryCompat()
	-- Fuck SQLite
	if (VoidLib.SQL.module == "sqlite") then
		-- Copy the table (SQLite)
		VoidCases.Print("SQLite old inventory conversion running!")

		local query = VoidLib.SQL:Create("voidcases_inventory_copy")
			query:Create("sid", "VARCHAR(30) NOT NULL")
			query:Create("item", "INTEGER NOT NULL")
			query:Create("amount", "INTEGER NOT NULL")
			query:PrimaryKey("item, sid")
			query:Callback(function ()
				VoidCases.Print("Created cloned table!")
				VoidLib.SQL:RawQuery([[INSERT INTO voidcases_inventory_copy (sid, item, amount)
   										SELECT sid, item, amount FROM voidcases_inventory;]], function (result)
					VoidCases.Print("Cloned table info!")
					local query = VoidLib.SQL:Drop("voidcases_inventory")
					query:Callback(function ()
						VoidCases.Print("Dropped old table!")
						VoidLib.SQL:RawQuery('ALTER TABLE voidcases_inventory_copy RENAME TO voidcases_inventory;', function () 
							VoidCases.Print("Renamed new table!")
							VoidCases.Print("Conversion done.")
						end)
					end)
					query:Execute()
					
				end)
			end)
		query:Execute()

		
	else
		-- Alter (MySQL)
		VoidCases.Print("MySQL old inventory conversion running!")
		VoidLib.SQL:RawQuery([[ALTER TABLE voidcases_inventory 
								DROP slot,
								DROP PRIMARY KEY, 
								ADD PRIMARY KEY (item, sid);]], function (result)
			VoidCases.Print("Conversion done.")
		end)
	end
end

function VoidCases.PendingMoneyCompat()
	VoidCases.Print("Running voidcases_pendingmoney database conversion!")

	VoidLib.SQL:RawQuery([[ALTER TABLE voidcases_pendingmoney 
							ADD currency VARCHAR(80)
							]],
	function (result)
		VoidCases.Print("Conversion done.")
	end)
end

function VoidCases.OldPurchasesCompat()
	VoidCases.Print("Running voidcases_purchases database backwards compatibility conversion!")

	VoidLib.SQL:RawQuery([[ALTER TABLE voidcases_purchases
							ADD amount INTEGER
							]],
	function (result)
		VoidCases.Print("Conversion done.")
	end)
end

hook.Add("VoidLib.DatabaseConnected", "VoidCases.InitDatabase", function()

	local query = VoidLib.SQL:Create("voidcases_inventory")
		query:Create("sid", "VARCHAR(30) NOT NULL")
		query:Create("item", "INTEGER NOT NULL")
		query:Create("amount", "INTEGER NOT NULL")
		query:PrimaryKey("item, sid")
	query:Execute()

	local query = VoidLib.SQL:Create("voidcases_purchases")
		query:Create("purchaseid", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("sid", "VARCHAR(30) NOT NULL")
		query:Create("item", "INTEGER NOT NULL")
		query:Create("timestamp", "INTEGER")
		query:Create("amount", "INTEGER")
		query:PrimaryKey("purchaseid")
	query:Execute()


	local query = VoidLib.SQL:Create("voidcases_marketplace")
		query:Create("listingid", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("sid", "VARCHAR(30) NOT NULL")
		query:Create("item", "INTEGER NOT NULL")
		query:Create("amount", "INTEGER NOT NULL")
		query:Create("price", "BIGINT NOT NULL")
		query:Create("timestamp", "INTEGER")
		query:PrimaryKey("listingid")
	query:Execute()

	local query = VoidLib.SQL:Create("voidcases_equippedperma")
		query:Create("sid", "VARCHAR(30) NOT NULL")
		query:Create("item", "INTEGER NOT NULL")
		query:PrimaryKey("item, sid")
	query:Execute()

	local query = VoidLib.SQL:Create("voidcases_pendingmoney")
		query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		query:Create("sid", "VARCHAR(30) NOT NULL")
		query:Create("money", "BIGINT NOT NULL")
		query:Create("currency", "VARCHAR(80) NOT NULL")
		query:PrimaryKey("id")
	query:Execute()

	timer.Simple(2, function ()
		if (VoidLib.SQL.module == "sqlite") then
			VoidLib.SQL:RawQuery([[PRAGMA table_info(voidcases_inventory)]], function (result)
				if (#result > 3) then
					VoidCases.OldInventoryCompat()
				end
			end)

			VoidLib.SQL:RawQuery([[PRAGMA table_info(voidcases_pendingmoney)]], function (result)
				if (#result < 4) then
					VoidCases.PendingMoneyCompat()
				end
			end)

			VoidLib.SQL:RawQuery([[PRAGMA table_info(voidcases_purchases)]], function (result)
				if (#result < 5) then
					VoidCases.OldPurchasesCompat()
				end
			end)

		else
			VoidLib.SQL:RawQuery([[SHOW COLUMNS FROM voidcases_inventory]], function (result)
				if (#result > 3) then
					VoidCases.OldInventoryCompat()
				end
			end)

			VoidLib.SQL:RawQuery([[SHOW COLUMNS FROM voidcases_pendingmoney]], function (result)
				if (#result < 4) then
					VoidCases.PendingMoneyCompat()
				end
			end)

			VoidLib.SQL:RawQuery([[SHOW COLUMNS FROM voidcases_purchases]], function (result)
				if (#result < 5) then
					VoidCases.OldPurchasesCompat()
				end
			end)
			
		end
	end)

	timer.Simple(15, function ()
		VoidCases.AutomaticItemsFeature()
	end)

end)

concommand.Add("voidcases_wipedata", function (pPlayer)
	if (!pPlayer:IsSuperAdmin()) then return end

	VoidLib.SQL:Drop("voidcases_inventory"):Execute()
	VoidLib.SQL:Drop("voidcases_purchases"):Execute()
	VoidLib.SQL:Drop("voidcases_marketplace"):Execute()
	VoidLib.SQL:Drop("voidcases_equippedperma"):Execute()
	VoidLib.SQL:Drop("voidcases_pendingmoney"):Execute()

	-- Save to a backup file
	local json = util.TableToJSON(VoidCases.Config)
	file.Write("voidcases_backup.json", json)
	file.Write("voidcases_config.txt", "")

	VoidCases.Print("WIPED ALL VOIDCASES DATA, RESTARTING IN 5 SECONDS!")
	pPlayer:ChatPrint("WIPED ALL VOIDCASES DATA, RESTARTING IN 5 SECONDS!")

	timer.Simple(5, function ()
		RunConsoleCommand("_RESTART")
	end)
end)



local function netReceiveInventoryRequest(len, ply)
	if (ply.vcases_requestedInventory) then return end
	ply.vcases_requestedInventory = true

	VoidCases.NetworkInventory(ply)
	VoidCases.NetworkMarketplace(ply)
	VoidCases.NetworkEquippedItems(ply)

end
net.Receive("VoidCases_RequestInventory", netReceiveInventoryRequest)

function VoidCases.NetworkItem(ply, item, amount)
	net.Start("VoidCases_NetworkItem")
		net.WriteUInt(item, 32)
		net.WriteInt(amount, 32)
	net.Send(ply)
end

function VoidCases.NetworkEquippedItem(ply, item, bool)

	if (!IsValid(ply)) then return end

	net.Start("VoidCases_NetworkEquippedOne")
		net.WriteUInt(item, 32)
		net.WriteBool(bool)
	net.Send(ply)
end

function VoidCases.NetworkEquippedItems(ply)

	if (!IsValid(ply)) then return end

	local query = VoidLib.SQL:Select("voidcases_equippedperma")
		query:Where("sid", ply:SteamID64())
		query:Callback(function (result, status, lastID)
			if (result and #result > 0) then

				local items = {}
				for k, v in ipairs(result) do
					items[tonumber(v.item)] = true
				end
				
				net.Start("VoidCases_NetworkEquipped")
					net.WriteTable(items)
				net.Send(ply)

			end
		end) 

	query:Execute(true)
end

net.Receive("VoidCases_DeleteInventoryItem", function (len, ply)
	local item = net.ReadUInt(32)
	local amountToDel = net.ReadUInt(32)

	local isAdmin = net.ReadBool()
	local sid = nil
	if (isAdmin) then
		sid = net.ReadString()

		if (!CAMI.PlayerHasAccess(ply, "VoidCases_EditInventories")) then return end
		if (!sid) then return end
	end

	local plyReceiver = player.GetBySteamID64(sid) or ply

	local itemObj = VoidCases.Config.Items[item]
	if (!itemObj) then return end

	local amount = VoidCases.GetPlayerInventoryItem(sid or ply:SteamID64(), item)
	if (!amount) then return end

	if (tonumber(amount) >= amountToDel) then
		VoidCases.AddItem(sid or ply:SteamID64(), item, -amountToDel)
		VoidCases.NetworkItem(plyReceiver, item, -amountToDel)

		VoidLib.Notify(ply, L"success", L("delete_success", {
			amount = amountToDel .. "x",
			name = itemObj.name
		}), VoidUI.Colors.Green, 5)
	end
end)

local function netPermaEquip(len, ply)
	local item = net.ReadUInt(32)

	if (!VoidCases.EquippedPermas[ply]) then
		VoidCases.EquippedPermas[ply] = 0
	end

	if (!VoidCases.Config.Items[item]) then return end

	if (DarkRP and ply:isArrested()) then return end

	local amount = VoidCases.GetPlayerInventoryItem(ply:SteamID64(), item)
	if (!amount) then return end
	
	local itemObj = VoidCases.Config.Items[item]
	if (!itemObj.info.isPermanent) then return end

	if (tonumber(amount) > 0) then
		VoidCases.IsPermaEquipped(ply, item, function (bool)
			local val = !bool and 1 or -1

			if (VoidCases.EquippedPermas[ply] and !bool and VoidCases.Config.MaxEquipped and tonumber(VoidCases.Config.MaxEquipped) != 0 and tonumber(VoidCases.EquippedPermas[ply]) >= tonumber(VoidCases.Config.MaxEquipped)) then
				VoidLib.Notify(ply, L"couldnt_equip", string.format(L"limit_reached_perma", VoidCases.Config.MaxEquipped), Color(206, 83, 83), 4)
				return
			end

			VoidCases.EquippedPermas[ply] = VoidCases.EquippedPermas[ply] + val
			if (IsValid(ply)) then
				VoidCases.PermaEquip(ply, item, !bool)
			end
		end)
	end

end
net.Receive("VoidCases_EquipPerma", netPermaEquip)

net.Receive("VoidCases_AddAdminItem", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidCases_EditInventories")) then return end

	local sid64 = net.ReadString()
	local itemId = net.ReadUInt(32)

	local item = VoidCases.Config.Items[itemId]
	if (!item) then return end

	VoidCases.AddItem(sid64, itemId, 1)
	
	local playerReceiver = player.GetBySteamID64(sid64)
	if (IsValid(playerReceiver)) then
		VoidCases.NetworkItem(playerReceiver, itemId, 1)
	end
end)

net.Receive("VoidCases_RequestAdminInventory", function (len, ply)
	if (!CAMI.PlayerHasAccess(ply, "VoidCases_EditInventories")) then return end
	local sid64 = net.ReadString()

	VoidCases.GetPlayerInventory(sid64, function (inventory)
		if (IsValid(ply)) then
			local inv = {}
			for k, v in pairs(inventory or {}) do
				inv[tonumber(v.item)] = tonumber(v.amount)
			end
			
			net.Start("VoidCases_NetworkAdminInventory")
				net.WriteTable(inv)
				net.WriteString(sid64)
			net.Send(ply)
		end
	end)
end)

function VoidCases.PermaEquip(ply, item, bool, b)

	local itemInfo = VoidCases.Config.Items[tonumber(item)]
	if (!itemInfo) then return end

	if (bool) then
		local query = VoidLib.SQL:Replace("voidcases_equippedperma")
			query:Insert("sid", (!b and ply:SteamID64()) or ply)
			query:Insert("item", item)
			query:Callback(function ()
				if (b) then
					ply = player.GetBySteamID64(ply)
				end
				VoidCases.NetworkEquippedItem(ply, item, true)

				if (engine.ActiveGamemode() != "terrortown") then
					// Give weapon
					local wep = ply:Give(itemInfo.info.actionValue)
					if (IsValid(wep)) then
						wep.isPermanent = true
					end
				end
			end)
		query:Execute(true)
	else
		local query = VoidLib.SQL:Delete("voidcases_equippedperma")
			query:Where("sid", (!b and ply:SteamID64()) or ply)
			query:Where("item", item)
			query:Callback(function ()
				if (b) then
					ply = player.GetBySteamID64(ply)
				end
				VoidCases.NetworkEquippedItem(ply, item, false)

				if (engine.ActiveGamemode() != "terrortown") then
					// Take weapon
					if (ply:HasWeapon(itemInfo.info.actionValue)) then
						ply:StripWeapon(itemInfo.info.actionValue)
					end
				end
			end)
		query:Execute(true)
	end
end

function VoidCases.GetPermaWeapons(ply, callback)
	local query = VoidLib.SQL:Select("voidcases_equippedperma")
		query:Where("sid", ply:SteamID64())
		query:Callback(function (result, status, lastID)
			if (result and #result > 0) then
				callback(result)
			end
		end) 

	query:Execute(true)
end

function VoidCases.IsPermaEquipped(ply, item, callback)
	local query = VoidLib.SQL:Select("voidcases_equippedperma")
		query:Where("sid", ply:SteamID64())
		query:Where("item", item)
		query:Callback(function (result, status, lastID)
			if (result and #result > 0) then
				callback(true)
			else
				callback(false)
			end
		end) 

	query:Execute(true)
end


function VoidCases.NetworkInventory(ply)
	local result = VoidCases.GetPlayerInventory(ply:SteamID64())
	if (result and table.Count(result) > 0) then
		net.Start("VoidCases_NetworkInventory")
			net.WriteTable(result)
		net.Send(ply)
	end
		
end

function VoidCases.GetMarketplace(callback)
	local query = VoidLib.SQL:Select("voidcases_marketplace")
		query:OrderByDesc("timestamp")
		query:Callback(function (result, status, lastID)
			callback(result)
		end)

	query:Execute(true)
end

function VoidCases.AddItem(sid64, item, amount, cb)
	if tostring(sid64):lower():StartWith("steam_") then
		sid64 = util.SteamIDTo64(sid64)
	end

    // Check if player has an item
	local plyInv = VoidCases.PlayerInventories[sid64]
	local invItem = plyInv[tonumber(item)]

	if (invItem) then
		VoidCases.PlayerInventories[sid64][tonumber(item)] = invItem + amount
	else
		VoidCases.PlayerInventories[sid64][tonumber(item)] = amount
	end

	invItem = VoidCases.PlayerInventories[sid64][tonumber(item)]

	if (invItem and invItem < 1) then
		VoidCases.PlayerInventories[sid64][tonumber(item)] = nil
	end
	
	VoidCases.AddItemToSlot(sid64, item, amount, cb)
end


function VoidCases.DeletePermaItem(sid64, item)
	local itemType = VoidCases.Config.Items[tonumber(item)]
	if (!itemType) then return end

	if (itemType.type == VoidCases.ItemTypes.Unboxable and itemType.info.isPermanent) then
		VoidCases.PermaEquip(sid64, item, false, true)
	end
end

function VoidCases.AddItemToSlot(sid64, item, amount, cb)

	local itemType = VoidCases.Config.Items[tonumber(item)]
	if (!itemType) then return end

	local strQuery = string.format([[
						INSERT INTO voidcases_inventory (sid, item, amount) VALUES ('%s', %s, %s) 
						ON DUPLICATE KEY UPDATE amount = IF(amount + %s > 0, amount + %s, 0);
						DELETE FROM voidcases_inventory WHERE amount < 1;]], sid64, item, amount, amount, amount)

	if (VoidLib.SQL.module == "sqlite") then
		local operationSymbol = "+"
		if (amount < 0) then
			operationSymbol = "-"
		end
		strQuery = string.format([[
			INSERT INTO voidcases_inventory (sid, item, amount)
			VALUES ('%s', %s, %s)
			ON CONFLICT(sid, item) DO UPDATE SET amount = amount ]] .. operationSymbol .. [[ %s;
			DELETE FROM voidcases_inventory WHERE amount < 1;
		]], sid64, item, amount, math.abs(amount))
	end


	VoidLib.SQL:RawQuery(strQuery, function (result)
		if (cb) then
			cb()
		end

		if (itemType.type == VoidCases.ItemTypes.Unboxable and itemType.info.isPermanent) then
			VoidCases.GetPlayerInventoryItem(sid64, item, function (itemResult)
				if (!itemResult or #itemResult < 1) then
					VoidCases.DeletePermaItem(sid64, item)
				end
			end)
		end
	end)

	
end

function VoidCases.GetPlayerInventoryItem(sid64, item, callback)

	if (callback) then
		local query = VoidLib.SQL:Select("voidcases_inventory")
			query:Where("sid", sid64)
			query:Where("item", item)
			query:Callback(function (result, status, lastID)
				callback(result)
			end)

		query:Execute(true)
	else
		return VoidCases.PlayerInventories[sid64][item]
	end
end

function VoidCases.GetPlayerInventory(sid64, cb)

	if (cb) then
		local query = VoidLib.SQL:Select("voidcases_inventory")
			query:Where("sid", sid64)
			query:Callback(function (result, status, lastID)
				cb(result)
			end)

		query:Execute(true)
	else
		return VoidCases.PlayerInventories[sid64]
	end

end


hook.Add("PlayerInitialSpawn", "VoidCases.PlayerJoinInventory", function (ply)
	local sid64 = ply:SteamID64()
	VoidCases.GetPlayerInventory(sid64, function (inventory)
		if (IsValid(ply)) then
			local inv = {}
			for k, v in pairs(inventory or {}) do
				inv[tonumber(v.item)] = tonumber(v.amount)
			end
			VoidCases.PlayerInventories[sid64] = inv
		end
	end)
end)

hook.Add("PlayerDisconnected", "Voidcases.PlayerClearInventory", function (ply)
	local sid64 = ply:SteamID64()

	VoidCases.PlayerInventories[sid64] = nil
end)


-- Think hook yerine timer kullan (0.1 saniye = 100ms)
timer.Create("VoidLib_SQL_Timer", 0.1, 0, function()
	VoidLib.SQL:Think()
end)
