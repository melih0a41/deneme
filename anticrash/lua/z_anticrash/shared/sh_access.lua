-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

SH_ANTICRASH.VARS.convertedPermissions = SH_ANTICRASH.VARS.convertedPermissions or {}

for k, v in pairs(SH_ANTICRASH.SETTINGS.ADMINS) do

	SH_ANTICRASH.VARS.convertedPermissions[k] = {}
	
	if istable(v) then
		
		-- new format (["rank"] = { permissions })
		for i=1, #v do
			
			local perm = v[i]
			SH_ANTICRASH.VARS.convertedPermissions[k][perm] = true
			
		end
		
	else
	
		-- backwards compatibility (["rank"] = true)
		SH_ANTICRASH.VARS.convertedPermissions[k]["stats"] = true
		SH_ANTICRASH.VARS.convertedPermissions[k]["users"] = true
		SH_ANTICRASH.VARS.convertedPermissions[k]["global"] = true
	
	end
	
end

function SH_ANTICRASH.HasAccess(ply,permission)
	
	if CLIENT and isstring(ply) or ply == nil then
		permission = ply
		ply = LocalPlayer()
	end

	if ply:IsSuperAdmin() then
		return true
	end
	
	local userGroup = ply:GetUserGroup():lower()
	local permissions = SH_ANTICRASH.VARS.convertedPermissions[userGroup]
	
	-- Check if user has any permissions
	if !permission then
		return permissions ~= nil
	end
	
	-- Check for specific user permission
	return permissions ~=nil and permissions[permission]
	
end