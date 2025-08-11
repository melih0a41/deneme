-- A cooldown lib I stole from my community's lib
perfectVault.Cooldown.Timers = perfectVault.Cooldown.Timers or {}

function perfectVault.Cooldown.Check(id, time, ply)
	if not id then return true end
	if not time then return true end

	if not perfectVault.Cooldown.Timers[id] then
		perfectVault.Cooldown.Timers[id] = {}
		perfectVault.Cooldown.Timers[id].global = 0
	end

	if ply then
		if not perfectVault.Cooldown.Timers[id][ply:SteamID64()] then
			perfectVault.Cooldown.Timers[id][ply:SteamID64()] = 0
		end

		if perfectVault.Cooldown.Timers[id][ply:SteamID64()] > CurTime() then return true end

		perfectVault.Cooldown.Timers[id][ply:SteamID64()] = CurTime() + time

		return false
	else
		if perfectVault.Cooldown.Timers[id].global > CurTime() then return true end

		perfectVault.Cooldown.Timers[id].global = CurTime() + time

		return false
	end
end

function perfectVault.Cooldown.Get(id, ply)
	if not id then return 0 end
	if not time then return 0 end

	if not perfectVault.Cooldown.Timers[id] then return 0 end

	-- The correct returns
	if ply and perfectVault.Cooldown.Timers[id][ply:SteamID64()] then return perfectVault.Cooldown.Timers[id][ply:SteamID64()] end
	if not ply and perfectVault.Cooldown.Timers[id].global then return perfectVault.Cooldown.Timers[id].global end

	-- Failsafe
	return 0
end


function perfectVault.Cooldown.Reset(id, ply)
	if not id then return end

	if not perfectVault.Cooldown.Timers[id] then return end

	if ply then
		if not perfectVault.Cooldown.Timers[id][ply:SteamID64()] then return end
		perfectVault.Cooldown.Timers[id][ply:SteamID64()] = 0
	else
		perfectVault.Cooldown.Timers[id].global = 0
	end
end