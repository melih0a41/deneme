-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local debugMat = Material("editor/wireframe")
local enableDebug = false

local function IsValidEnt(ent)
	return IsValid(ent) and !ent:IsWorld() and ent:z_anticrashHasCreator() and !ent.__markedForDelete
end

local function DebugDraw()

	if !enableDebug then return end

	local entTbl = ents.GetAll()
	local offsetVector = SH_ANTICRASH.VARS.NEIGHBOUROFFSETVECTOR
	
	cam.Start3D()
		
		for i=1, #entTbl do
			
			local ent = entTbl[i]
			
			if !IsValidEnt(ent) then
				continue
			end
			
			local neighbours = SH_ANTICRASH.GetNeighboringEnts(ent)
			local validNeightbours = {}
			for ii=1, #neighbours do
			
				local ent2 = neighbours[ii]
				
				if !IsValidEnt(ent2) or ent == ent2 then
					continue
				end
				
				table.insert(validNeightbours, ent2) 
			
			end
			
			local hasNeighbours = #validNeightbours > 0
			local debugCol = hasNeighbours and SH_ANTICRASH.VARS.COLOR.RED or color_white
		
			render.SetMaterial(debugMat)
			
			-- Search box
			render.DrawBox(ent:GetPos(), ent:GetAngles(), ent:OBBMins()-offsetVector, ent:OBBMaxs()+offsetVector, debugCol)
			
			-- Find in box lines
			local worldMins = LocalToWorld(ent:OBBMins()-offsetVector, Angle(0,0,0), ent:GetPos(), ent:GetAngles())
			local worldMaxs = LocalToWorld(ent:OBBMaxs()+offsetVector, Angle(0,0,0), ent:GetPos(), ent:GetAngles())
			
			render.DrawLine(worldMins, worldMaxs, SH_ANTICRASH.VARS.COLOR.BLUE)
			
			-- World pos
			render.DrawLine(ent:GetPos()-Vector(0,3,0), ent:GetPos()+Vector(0,3,0), SH_ANTICRASH.VARS.COLOR.GREEN)
			render.DrawLine(ent:GetPos()-Vector(0,0,3), ent:GetPos()+Vector(0,0,3), SH_ANTICRASH.VARS.COLOR.GREEN)
		
		end
			
	cam.End3D()

end
hook.Add("HUDPaint","cl_anticrash_DebugDraw",DebugDraw)