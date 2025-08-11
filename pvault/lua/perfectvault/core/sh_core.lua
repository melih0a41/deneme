function perfectVault.Core.Access(user)
	return perfectVault.Config.AccessGroups[user:GetUserGroup()] or perfectVault.Config.AccessGroups[user:SteamID64()] or perfectVault.Config.AccessGroups[user:SteamID()]
end

---
--- Lockpicking code
---
local function lockpickable()
	if !perfectVault.Config.PicklockUnlock then return false end

	local cops = 0
	for k, v in pairs(player.GetAll()) do
		if v:isCP() then cops = cops + 1 continue end
		if perfectVault.Config.Government[v:Team()] then cops = cops + 1 continue end
	end
	if !(player.GetCount()*perfectVault.Config.NeededCops <= cops) then if SERVER then perfectVault.Core.Msg(perfectVault.Translation.Chat.NotEnoughCops) end return false end

	return true

end

hook.Add("canLockpick", "pvault_lockpick", function(ply, ent)
	if not IsValid(ent) then return end
	if ent:GetClass() == "pvault_door" or ent:GetClass() == "pvault_floor" then
		if !ent:GetLocked() then return false end
		if !ent:GetRobable() then return false end
		return lockpickable()
	end
end)

hook.Add("onLockpickCompleted", "pvault_lockpick_complete", function(ply, bool, ent)
	if not IsValid(ent) then return end
	if ent:GetClass() == "pvault_door" or ent:GetClass() == "pvault_floor" then
		if bool then
			if SERVER then
				ent:Unlock()
				hook.Run("pVaultVaultCracked", ent, ply)
			end
		end
	end
end)
