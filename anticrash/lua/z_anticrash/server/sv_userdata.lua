-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local nextUpdateData = 0
local updateDelay = 5

local function UpdateUserData()
	
	if nextUpdateData < CurTime() then
	
		local entTbl = ents.GetAll()
		local plys = player.GetAll()
		local plyConstraintTbl = {}
		
		for i=1, #entTbl do
			
			local ent = entTbl[i]
			
			if ent:IsConstraint() then
				
				local creator = ent:z_anticrashGetCreator()
				
				if IsValid(creator) then
					plyConstraintTbl[creator] = (plyConstraintTbl[creator] or 0) + 1
				end
			
			end

		end
		
		for i=1, #plys do
			
			local ply = plys[i]
			local plyVal = plyConstraintTbl[ply]
			
			if plyVal then
				ply:z_anticrashSetConstraintCount(plyVal)
			else
				ply:z_anticrashSetConstraintCount(0)
			end
		
		end
		
		nextUpdateData = CurTime() + updateDelay
	
	end

end
hook.Add("Think","sv_anticrash_UpdateUserData",UpdateUserData)
