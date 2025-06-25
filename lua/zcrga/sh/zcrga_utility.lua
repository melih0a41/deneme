/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

zcrga = zcrga or {}
zcrga.f = zcrga.f or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24d29d357f25d0e3dbcd1d408ccea85b467c8e0190b63644784fca3979a920a4

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44

if SERVER then
	function zcrga.f.Notify(ply, msg, ntfType)
		if gmod.GetGamemode().Name == "DarkRP" then
			DarkRP.notify(ply, ntfType, 8, msg)
		else
			ply:ChatPrint(msg)
		end
	end
end

function zcrga.f.LerpColor(t, c1, c2)
	local c3 = Color(0, 0, 0)
	c3.r = Lerp(t, c1.r, c2.r)
	c3.g = Lerp(t, c1.g, c2.g)
	c3.b = Lerp(t, c1.b, c2.b)
	c3.a = Lerp(t, c1.a, c2.a)

	return c3
end

//Used to fix the Duplication Glitch
function zcrga.f.CollisionCooldown(ent)
	if ent.zcrga_CollisionCooldown == nil then
		ent.zcrga_CollisionCooldown = true

		timer.Simple(0.1,function()
			if IsValid(ent) then
				ent.zcrga_CollisionCooldown = false
			end
		end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

		return false
	else
		if ent.zcrga_CollisionCooldown then
			return true
		else
			ent.zcrga_CollisionCooldown = true

			timer.Simple(0.1,function()
				if IsValid(ent) then
					ent.zcrga_CollisionCooldown = false
				end
			end)
			return false
		end
	end
end


function zcrga.f.InDistance(pos01, pos02, dist)
	local inDistance = pos01:DistToSqr(pos02) < (dist * dist)
	return  inDistance
end

// This returns true if the player is a admin
function zcrga.f.IsAdmin(ply)
	if IsValid(ply) and ply:IsPlayer() then
		//xAdmin Support
		if xAdmin then
			return ply:IsAdmin()
		else
			if table.HasValue(zcrga.config.allowedRanks,ply:GetUserGroup()) then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
