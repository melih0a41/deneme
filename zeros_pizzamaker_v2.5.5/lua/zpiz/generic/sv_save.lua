/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if (not SERVER) then return end
zpiz = zpiz or {}
file.CreateDir("zpizmak")

local function CatchEntities(class)
	local data = {}

	for u, j in pairs(ents.FindByClass(class)) do
		if not IsValid(j) then continue end

		table.insert(data, {
			class = j:GetClass(),
			pos = j:GetPos(),
			ang = j:GetAngles()
		})

		j:SetNWString("zpiz_Owner", "world")
	end

	return data
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70

local function RemoveEntities(class)
	for u, j in pairs(ents.FindByClass(class)) do
		if not IsValid(j) then continue end
		SafeRemoveEntity(j)
	end
end

local function SaveEntities(ply)
	if zclib.Player.IsAdmin(ply) == false then return end
	zclib.STM.Save("zpiz_ents")
	zclib.Notify(ply, "Public PizzaMaker Entities have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47

zclib.STM.Setup("zpiz_ents", "zpizmak/" .. string.lower(game.GetMap()) .. "_PublicEnts" .. ".txt", function()
	local data = {}
	table.Add(data, CatchEntities("zpiz_oven"))
	table.Add(data, CatchEntities("zpiz_customertable"))
	table.Add(data, CatchEntities("zpiz_fridge"))
	table.Add(data, CatchEntities("zpiz_opensign"))

	return data
end, function(data)
	for k, v in pairs(data) do
		local ent = ents.Create(v.class)
		if not IsValid(ent) then continue end
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		local phys = ent:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableMotion(false)
		end

		if (v.class == "zpiz_fridge") then
			ent:SetPos(v.pos)
			ent.IsPublicEntity = true
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47

	zpiz.Print("Finished loading Public PizzaMaker entities!")
end, function()
	RemoveEntities("zpiz_oven")
	RemoveEntities("zpiz_customertable")
	RemoveEntities("zpiz_fridge")
	RemoveEntities("zpiz_opensign")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

concommand.Add("zpiz_save", function(ply, cmd, args)
	SaveEntities(ply)
end)

concommand.Add("zpiz_remove", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) == false then return end
	zclib.STM.Remove("zpiz_ents")
	zclib.Notify(ply, "Public PizzaMaker Entities have been removed!", 0)
end)

hook.Add("PlayerSay", "zpiz_HandleConCanCommands", function(ply, text)
	if string.sub(string.lower(text), 1, 15) == "!savepizzamaker" then
		SaveEntities(ply)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
