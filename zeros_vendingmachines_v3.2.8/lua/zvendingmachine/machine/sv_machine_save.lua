/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Machine = zvm.Machine or {}

/*

	This system handels the saving / loading of the vendingmachines

*/

// Gets called from client to save all vendignmachines
util.AddNetworkString("zvm_Machine_Save")
net.Receive("zvm_Machine_Save", function(len,ply)
	zclib.Debug("zvm_Machine_Edit_Finished Netlen: " .. len)
	if zclib.Player.Timeout(nil,ply) then return end
	if zclib.Player.IsAdmin(ply) == false then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

	zclib.STM.Save("zvm_machine")
	zclib.Notify(ply, "Vendingmachines have been saved for the map " .. game.GetMap() .. "!", 0)
end)

concommand.Add("zvm_save_vendingmachines", function(ply, cmd, args)
	if IsValid(ply) and zclib.Player.IsAdmin(ply) then
		zclib.STM.Save("zvm_machine")
		zclib.Notify(ply, "Vendingmachines have been saved for the map " .. game.GetMap() .. "!", 0)
	end
end)

concommand.Add("zvm_load_vendingmachines", function(ply, cmd, args)
    if IsValid(ply) and zclib.Player.IsAdmin(ply) then
        for k, v in pairs(zvm.Vendingmachines) do
            if IsValid(v) then
                v:Remove()
            end
        end
        zclib.STM.Load("zvm_machine")
    end
end)

concommand.Add("zvm_remove_vendingmachines", function(ply, cmd, args)
	if IsValid(ply) and zclib.Player.IsAdmin(ply) then
		zclib.STM.Remove("zvm_machine")
		zclib.Notify(ply, "Vendingmachines have been removed for the map " .. game.GetMap() .. "!", 0)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

file.CreateDir("zvm")
// Setsup the saving / loading and removing of the entity for the map
zclib.STM.Setup("zvm_machine", "zvm/" .. string.lower(game.GetMap()) .. "_vendingmachines" .. ".txt", function()
	local data = {}

	for u, j in pairs(zvm.Vendingmachines) do
		if IsValid(j) then
			// Sets its supply to endless
			j:SetPublicMachine(true)

			table.insert(data, {
				pos = j:GetPos(),
				ang = j:GetAngles(),
				content = j.Products,
				name = j.MachineName,
				moneytype = j.MoneyType,
				style = zvm.Machine.GetUniqueStyleID(j:GetStyleID()),
			})
		end
	end

	return data
end, function(data)
	for k, v in pairs(data) do
		local ent = ents.Create("zvm_machine")
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		ent:Activate()

		if v.style then ent:SetStyleID(zvm.Machine.GetStyleListID(v.style) or 1) end

		// Sets its supply to endless
		ent:SetPublicMachine(true)

		ent.MachineName = v.name
		ent.MoneyType = v.moneytype or 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

		timer.Simple(0, function()
			if IsValid(ent) then
				local phys = ent:GetPhysicsObject()

				if IsValid(phys) then
					phys:Wake()
					phys:EnableMotion(false)
				end
			end
		end)

		// This fix will make sure all unique ids will be changed to list ids
		local content = {}
		for _,dat in pairs(v.content) do table.insert(content,dat) end
		ent.Products = table.Copy(content)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

		// Precache the model so util.IsValidModel works correctly for clients
		for s, w in pairs(ent.Products) do if w.model then util.PrecacheModel( w.model ) end end
	end

	zvm.Print("Finished loading Vendingmachine Entities.")
end, function()
	for k, v in pairs(zvm.Vendingmachines) do
		if IsValid(v) then
			v:Remove()
		end
	end
end)
