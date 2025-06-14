-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

SV_ANTICRASH.UTILS = {}

function SV_ANTICRASH.UTILS.FreezeEntity(ent, forceRagdolls)

	if !ent:IsRagdoll() or (ent:IsRagdoll() and !forceRagdolls) then

		local physObj = ent:GetPhysicsObject()
		
		if IsValid(physObj) then
			physObj:EnableMotion(false)
			physObj:Sleep()
			
			return true
		end
		
		return false
		
	else

		for i=0, ent:GetPhysicsObjectCount() - 1 do
			local physObj = ent:GetPhysicsObjectNum(i)
			
			if IsValid(physObj) then
				physObj:EnableMotion(false)
				physObj:Sleep()
			end
		end
		
		return true
		
	end
	
end

// Stop model manipulator from changing vehicle models into props
function SV_ANTICRASH.UTILS.ForceDupeVehicleModel(entityList) 
	for _, ent in pairs(entityList) do
		if ent.VehicleTable ~= nil and ent.VehicleTable.Model ~= nil then
			ent.Model = ent.VehicleTable.Model
		end
	end
end