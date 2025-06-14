-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/*
	Compatibility with gProtect
*/

function SH_ANTICRASH.HasGProtect()
	return gProtect ~= nil
end

function SH_ANTICRASH.HasGProtectGhosting()
	if !SH_ANTICRASH.HasGProtect() then
		return false
	end

	local ghostingConf = gProtect.GetConfig(nil,"ghosting")

	return ghostingConf and ghostingConf.enabled
end