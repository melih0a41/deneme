/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if SERVER then return end
zlm = zlm or {}
zlm.f = zlm.f or {}

if zlm_GrassSpots == nil then
	zlm_GrassSpots = {}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

if zlm_GrassModels == nil then
	zlm_GrassModels = {}
end

if zlm_GrassModelCount == nil then
	zlm_GrassModelCount = 0
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

local zlm_LastThink = -1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad


net.Receive("zlm_GrassSpots_load", function(len)

	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))

	if d_Decompressed == nil then return end

	local newGrassSpots = util.JSONToTable(d_Decompressed)

	if (zlm_GrassModels and table.Count(zlm_GrassModels) > 0) then
		for s, w in pairs(zlm_GrassModels) do
			if IsValid(w) then
				w:Remove()
			end
		end
	end

	zlm_GrassSpots = {}
	zlm_GrassModels = {}
	zlm_GrassModelCount = 0

	if newGrassSpots then
		table.CopyFromTo( newGrassSpots, zlm_GrassSpots )
	end
	zlm.f.Debug("Grass Data Size: " .. len)
	zlm.f.Debug("Grass Data Loaded!")
end)

net.Receive("zlm_GrassSpots_mowed", function(len)
	local mowedID = net.ReadInt(21)
	local grassData = zlm_GrassSpots[mowedID]

	if grassData and grassData.pos and grassData.mowed ~= nil then
		if zlm.f.InDistance(grassData.pos, LocalPlayer():GetPos(), GetConVar("zlm_cl_vfx_updatedistance"):GetFloat()) and grassData.mowed == false then
			grassData.mowed = true
			ParticleEffect("zlm_mowe", grassData.pos, Angle(0, 0, 0), NULL)
		end
	else
		print("[    Zeros LawnMower    ] " .. "Mowed Grass doesent exist in Client Table!")
	end
end)

net.Receive("zlm_GrassSpots_refresh", function(len)
	local grass_ID = net.ReadInt(21)

	if zlm_GrassSpots[grass_ID] then
		zlm_GrassSpots[grass_ID].mowed = false
	end
end)

hook.Add("Think", "a_zlm_Think_GrassUpdate", function()
	if zlm_LastThink < CurTime() then

		if zlm_GrassSpots and table.Count(zlm_GrassSpots) > 0 then

			if table.Count(zlm.config.Grass.RenderForJob) > 0 then

				if zlm.config.Grass.RenderForJob[zlm.f.GetPlayerJob(LocalPlayer())] then

					zlm.f.Update_GrassSpots()
				else

					for i = 1, table.Count(zlm_GrassSpots) do
						local val = zlm_GrassSpots[i]

						if val and IsValid(val.ClientProp) then
							zlm.f.DeleteGrass(val)
						end
					end
				end
			else
				zlm.f.Update_GrassSpots()
			end
		end

		zlm_LastThink = CurTime() + GetConVar("zlm_cl_vfx_updateinterval"):GetFloat()
	end
end)

function zlm.f.Update_GrassSpots()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	for i = 1, table.Count(zlm_GrassSpots) do
		local key = math.random(#zlm_GrassSpots)
		local val = zlm_GrassSpots[key]

		if val and val.pos and val.mowed ~= nil then

			if IsValid(val.ClientProp) and zlm_GrassModelCount > GetConVar("zlm_cl_vfx_modelcount"):GetInt() then
				zlm.f.DeleteGrass(val)
			end

			// If we are close enough and the grass spot is not mowed then we populate the position with grass
			if zlm.f.InDistance(val.pos, LocalPlayer():GetPos(), GetConVar("zlm_cl_vfx_updatedistance"):GetFloat()) and val.mowed == false then

				if not IsValid(val.ClientProp) and zlm_GrassModelCount < GetConVar("zlm_cl_vfx_modelcount"):GetInt() then

					zlm.f.PopulatedGrass(val)
				end
			else

				if IsValid(val.ClientProp) then
					// 288688181
					// If we are to far away from this grass spot then we remove all of its client props
					zlm.f.DeleteGrass(val)
				end
			end
		end
	end
end

function zlm.f.PopulatedGrass(GrassSpot)
	// Create the Grass Model
	local grass = zlm.f.SpawnClientModel_Grass(GrassSpot)
	if IsValid(grass) then
		table.insert(zlm_GrassModels, grass)
		GrassSpot.ClientProp = grass
		//zlm.f.Debug("zlm.f.PopulatedGrass")
		zlm_GrassModelCount = math.Clamp(zlm_GrassModelCount + 1,0,1000)
	end
end

local l_ang = Angle(0, 0, 0)
local l_pos = Vector(0,0,1)
function zlm.f.SpawnClientModel_Grass(GrassSpot)
	//local grassData = zlm.Grass[math.random(#zlm.Grass)]
	local grassData

	for k, v in pairs(zlm.Grass) do
		if v.id == GrassSpot.id then
			grassData = v
			break
		end
	end
	if grassData == nil then
		return nil
	end
	local grass = ents.CreateClientProp(grassData.model)

	grass:SetPos(GrassSpot.pos)

	local ang = l_ang
	ang:RotateAroundAxis(l_pos, math.random(0, 360))
	grass:SetAngles(ang)

	grass:Spawn()
	grass:Activate()
	grass:SetModelScale(math.Rand(grassData.s_min, grassData.s_max))

	return grass
end

function zlm.f.DeleteGrass(GrassSpot)
	if IsValid(GrassSpot.ClientProp) then
		GrassSpot.ClientProp:Remove()
		GrassSpot.ClientProp = nil
		//zlm.f.Debug("zlm.f.DeleteGrass")
		zlm_GrassModelCount = math.Clamp(zlm_GrassModelCount - 1,0,1000)
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d
