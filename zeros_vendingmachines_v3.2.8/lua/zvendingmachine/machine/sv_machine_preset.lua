/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Machine = zvm.Machine or {}

file.CreateDir("zvm/presets/")
function zvm.Machine.GetPresets()
	local files = file.Find("zvm/presets/*", "DATA","datedesc")
	local presets = {}
	for k,v in pairs(files) do
		local content = file.Read("zvm/presets/" .. v, "DATA")
		if content == nil then continue end
		content = util.JSONToTable(content)
		if content == nil then continue end
		table.insert(presets,{
			name = v,
			m_name = content.machine_name,

			// Convert the uniqueid to a ListID
			style = zvm.Machine.GetStyleListID(content.machine_style) or 1,

			count = table.Count(content.products or {}),
		})
	end
	return presets
end

// Gets called from client to collect money
util.AddNetworkString("zvm_Machine_RequestPresets")
net.Receive("zvm_Machine_RequestPresets", function(len,ply)
	zclib.Debug("zvm_Machine_RequestPresets Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end
	if zclib.Player.IsAdmin(ply) == false then return end

	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end

	zvm.Machine.RequestPresets(Machine,ply)
end)
function zvm.Machine.RequestPresets(Machine,ply)

	// Get all saved preset savefiles
	local presets = zvm.Machine.GetPresets() or {}
	local PresetCount = table.Count(presets)

	net.Start("zvm_Machine_RequestPresets")
	net.WriteEntity(Machine)
	net.WriteUInt(PresetCount,32)
	for k,v in ipairs(presets) do
		net.WriteString(v.name)
		net.WriteString(v.m_name)
		net.WriteUInt(v.style,32)
		net.WriteUInt(v.count,32)
	end
	net.Send(ply)
end

util.AddNetworkString("zvm_Machine_SavePreset")
net.Receive("zvm_Machine_SavePreset", function(len,ply)
	zclib.Debug("zvm_Machine_SavePreset Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end
	if zclib.Player.IsAdmin(ply) == false then return end

	local Machine = net.ReadEntity()
	local savefilename = net.ReadString()
	if not IsValid(Machine) then return end
	if savefilename == nil then return end

	zvm.Machine.SavePreset(Machine,savefilename,ply)
end)

function zvm.Machine.SavePreset(Machine,savefilename,ply)

	// Remove any savefile that shares the same filename
	for k, v in pairs(file.Find("zvm/presets/*", "DATA", "datedesc")) do
		if v == savefilename .. ".txt" then
			file.Delete("zvm/presets/" .. savefilename .. ".txt")
		end
	end

	// Save the style / loadout from the vendingmachine
	local content = {
		machine_name = Machine.MachineName,
		machine_moneytype = Machine.MoneyType,
		machine_style = zvm.Machine.GetUniqueStyleID(Machine:GetStyleID()),
		products = Machine.Products
	}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	file.Write("zvm/presets/" .. savefilename .. ".txt",util.TableToJSON(content,true))

	zclib.Notify(ply, "Vendingmachine preset " .. savefilename .. ".txt saved!", 0)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

util.AddNetworkString("zvm_Machine_LoadPreset")
net.Receive("zvm_Machine_LoadPreset", function(len,ply)
	zclib.Debug("zvm_Machine_LoadPreset Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end
	if zclib.Player.IsAdmin(ply) == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

	local savefilename = net.ReadString()
	local Machine = net.ReadEntity()
	if not IsValid(Machine) then return end
	if savefilename == nil then return end

	zvm.Machine.LoadPreset(Machine,savefilename,ply)
end)
function zvm.Machine.LoadPreset(Machine, savefilename, ply)
	local content = file.Read("zvm/presets/" .. savefilename, "DATA")
	if content == nil then return end
	content = util.JSONToTable(content)
	if content == nil then return end

	Machine.MachineName = content.machine_name

	if content.machine_style then Machine:SetStyleID(zvm.Machine.GetStyleListID(content.machine_style)) end

	Machine.MoneyType = content.machine_moneytype
	Machine.Products = table.Copy(content.products)

	// Precache the model so util.IsValidModel works correctly for clients
	for s, w in pairs(content.products) do
		if w.model then util.PrecacheModel( w.model ) end
	end

	// Sends the updated machine data to all clients
	timer.Simple(0.25,function()
		if IsValid(Machine) then
			zvm.Machine.UpdateMachineData(Machine)
		end
	end)

	zclib.Notify(ply, "Vendingmachine preset " .. savefilename .. " loaded!", 0)
end


util.AddNetworkString("zvm_Machine_DeletePreset")
net.Receive("zvm_Machine_DeletePreset", function(len,ply)
	zclib.Debug("zvm_Machine_DeletePreset Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end
	if zclib.Player.IsAdmin(ply) == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	local savefilename = net.ReadString()
	if savefilename == nil then return end

	zvm.Machine.DeletePreset(savefilename,ply)
end)
function zvm.Machine.DeletePreset(savefilename, ply)
	file.Delete("zvm/presets/" .. savefilename)
	zclib.Notify(ply, "Vendingmachine preset " .. savefilename .. " deleted!", 0)
end



                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

/*

	This concommand is used to copy the style / loadout from the vendingmachine the player is looking at and pastes it on every other vendingmachine on the map
	NOTE This might get be useless once the preset system gets implemented

*/
concommand.Add("zvm_vendingmachine_mirror", function(ply, cmd, args)
	if IsValid(ply) and zclib.Player.IsAdmin(ply) then
		local tr = ply:GetEyeTrace()

		if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zvm_machine" then
			local ent = tr.Entity

			local Count = 0
			for k,v in pairs(zvm.Vendingmachines) do
				if not IsValid(v) then continue end
				if v ~= ent then
					v.Products = table.Copy(ent.Products)
					v:SetStyleID(ent:GetStyleID())
					v:SetPublicMachine(true)
					v.MachineName = ent.MachineName
					v.MoneyType = ent.MoneyType

					Count = Count + 1
				end
			end

			zclib.Notify(ply, "Finished copying vendingmachine loadout to " .. Count .. " other vendingmachines on the map!", 0)
		end
	end
end)
////////////////////////////////////////////
////////////////////////////////////////////
