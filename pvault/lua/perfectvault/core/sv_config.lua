-- Config
function perfectVault.Core.CreateEnt(class, settings, pos, ang, id)
	local ent = ents.Create(class)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	
	ent.DatabaseID = id
	ent.data = settings

	ent:PostData()

	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end
	phys:EnableMotion(false)
end


net.Receive("pvault_config_create_entity", function(_, ply)
	if not perfectVault.Core.Access(ply) then return end
	
	local entity = net.ReadString()
	local settings = net.ReadTable()
	local pos = net.ReadVector()
	local ang = net.ReadAngle()

	if not perfectVault.Core.Entites[entity] then return end

	local id = perfectVault.Database.CreateEntity(entity, settings, pos, ang)['id']
	perfectVault.Core.CreateEnt(entity, settings, pos, ang, id)
end)

net.Receive("pvault_requestdata_send", function(_, ply)
	local entity = net.ReadEntity()
	if (not entity) or (not IsValid(entity)) then return end
	if not string.match(entity:GetClass(), "pvault") then return end
	if not entity.data then return end

	net.Start("pvault_requestdata_response")
		net.WriteEntity(entity)
		net.WriteTable(entity.data)
	net.Send(ply)
end)

hook.Add("InitPostEntity", "pvault_spawn_ents", function()
	perfectVault.Database.Startup()
	local vaults = perfectVault.Database.GetEntites()

	if not istable(vaults) or table.IsEmpty(vaults) then return end
	
	for k, v in pairs(vaults) do
		local settings = util.JSONToTable(v.settings)
		local pos = util.JSONToTable(v.pos)
		pos = Vector(pos.x, pos.y, pos.z)
		local ang = util.JSONToTable(v.ang)
		ang = Angle(ang.x, ang.y, ang.z)

		perfectVault.Core.CreateEnt(v.class, settings, pos, ang, v.id)
	end
end)


hook.Add("PostCleanupMap", "pvault_spawn_ents", function()
	local vaults = perfectVault.Database.GetEntites()

	if not istable(vaults) or table.IsEmpty(vaults) then return end
	
	for k, v in pairs(vaults) do
		local settings = util.JSONToTable(v.settings)
		local pos = util.JSONToTable(v.pos)
		pos = Vector(pos.x, pos.y, pos.z)
		local ang = util.JSONToTable(v.ang)
		ang = Angle(ang.x, ang.y, ang.z)

		perfectVault.Core.CreateEnt(v.class, settings, pos, ang, v.id)
	end
end)