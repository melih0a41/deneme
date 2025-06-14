-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

CL_ANTICRASH.ENTVISION = {}

local wireframeMat = Material( "models/wireframe" )
local chamsColor = SH_ANTICRASH.VARS.COLOR.FUCHSIA
local chamsColVector = Vector(chamsColor.r/1, chamsColor.g/1, chamsColor.b/1)

local viewingPlayers = {}
local globalVision = false

function CL_ANTICRASH.ENTVISION.AddPlayer(ply)

	if SH_ANTICRASH.HasAccess("users") then
		viewingPlayers[ply] = true
	end
	
end

function CL_ANTICRASH.ENTVISION.RemovePlayer(ply)

	if SH_ANTICRASH.HasAccess("users") then
		viewingPlayers[ply] = nil
	end

end 

function CL_ANTICRASH.ENTVISION.HasPlayer(ply)
	return viewingPlayers[ply] ~= nil
end


function CL_ANTICRASH.ENTVISION.SetGlobalVision(bool)

	if SH_ANTICRASH.HasAccess("global") then
		globalVision = bool
	end

end

function CL_ANTICRASH.ENTVISION.GetGlobalVision()
	return globalVision
end

local function EntityVision()

	if table.Count(viewingPlayers) == 0 and !globalVision then return end

	cam.Start3D()
	
		render.SuppressEngineLighting(true)
		render.MaterialOverride(wireframeMat)
		render.SetColorModulation (chamsColVector.x, chamsColVector.y, chamsColVector.z)

		local entTbl = ents.GetAll()
		
		for i=1, #entTbl do
		
			local ent = entTbl[i]
			local creator = ent:z_anticrashGetCreator()
			
			if creator ~= NULL and (viewingPlayers[creator] or globalVision) then
				ent:DrawModel()
			end
			
		end
	
		render.MaterialOverride()
		render.SuppressEngineLighting(false)
		
	cam.End3D()	
	
end
hook.Add("HUDPaint", "cl_anticrash_EntityVision", EntityVision)
