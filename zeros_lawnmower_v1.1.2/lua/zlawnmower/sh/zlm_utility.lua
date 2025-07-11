/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm or {}
zlm.f = zlm.f or {}

////////////////////////////////////////////
/////////////// DEFAULT ////////////////////
////////////////////////////////////////////
if SERVER then

	// Basic notify function
	function zlm.f.Notify(ply, msg, ntfType)
		if DarkRP then
			DarkRP.notify(ply, ntfType, 8, msg)
		else
			ply:ChatPrint(msg)
		end
	end
else

	function zlm.f.LerpColor(t, c1, c2)
		local c3 = Color(0, 0, 0)
		c3.r = Lerp(t, c1.r, c2.r)
		c3.g = Lerp(t, c1.g, c2.g)
		c3.b = Lerp(t, c1.b, c2.b)
		c3.a = Lerp(t, c1.a, c2.a)

		return c3
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

	function zlm.f.PlayClientAnimation(ent,anim, speed)
		local sequence = ent:LookupSequence(anim)
		ent:SetCycle(0)
		ent:ResetSequence(sequence)
		ent:SetPlaybackRate(speed)
		ent:SetCycle(0)
	end
end

// Used for Debug
function zlm.f.Debug(mgs)
	if (zlm.config.Debug) then
		if istable(mgs) then
			print("[    DEBUG    ] Table Start >")
			PrintTable(mgs)
			print("[    DEBUG    ] Table End <")
		else
			print("[    DEBUG    ] " .. mgs)
		end
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

// Checks if the distance between pos01 and pos02 is smaller then dist
function zlm.f.InDistance(pos01, pos02, dist)
	local inDistance = pos01:DistToSqr(pos02) < (dist * dist)
	return  inDistance
end

function zlm.f.table_randomize( t )
	local out = { }

	while #t > 0 do
		table.insert( out, table.remove( t, math.random( #t ) ) )
	end

	return out
end

//Used to fix the Duplication Glitch
function zlm.f.CollisionCooldown(ent)
	if ent.zlm_CollisionCooldown == nil then
		ent.zlm_CollisionCooldown = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

		timer.Simple(0.1,function()
			if IsValid(ent) then
				ent.zlm_CollisionCooldown = false
			end
		end)

		return false
	else
		if ent.zlm_CollisionCooldown then
			return true
		else
			ent.zlm_CollisionCooldown = true

			timer.Simple(0.1,function()
				if IsValid(ent) then
					ent.zlm_CollisionCooldown = false
				end
			end)
			return false
		end
	end
end

// Tells us if the function is valid
function zlm.f.FunctionValidater(func)
	if (type(func) == "function") then return true end
	// 288688181
	return false
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////////// OWNER ////////////////////
////////////////////////////////////////////
if SERVER then
	// This saves the owners SteamID
	function zlm.f.SetOwnerByID(ent, id)
		ent:SetNWString("zlm_Owner", id)
	end

	// This saves the owners SteamID
	function zlm.f.SetOwner(ent, ply)
		if (IsValid(ply)) then
			ent:SetNWString("zlm_Owner", ply:SteamID())

			if CPPI then
				ent:CPPISetOwner(ply)
			end
		else
			ent:SetNWString("zlm_Owner", "world")
		end
	end
end

// This function tells us if the player is an Admin
function zlm.f.IsAdmin(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

	if IsValid(ply) and ply:IsPlayer() then

		//xAdmin Support
		if xAdmin then
			return ply:IsAdmin()
		else
			if zlm.config.AdminRanks[zlm.f.GetPlayerRank(ply)] then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

// This returns the entites owner SteamID
function zlm.f.GetOwnerID(ent)
	return ent:GetNWString("zlm_Owner", "nil")
end

// This returns the owner
function zlm.f.GetOwner(ent)
	if (IsValid(ent)) then
		local id = ent:GetNWString("zlm_Owner", "nil")
		local ply = player.GetBySteamID(id)

		if (IsValid(ply)) then
			return ply
		else
			return false
		end
	else
		return false
	end
end

// This returns true if the input is the owner
function zlm.f.IsOwner(ply, ent)
	if (IsValid(ent)) then
		local id = ent:GetNWString("zlm_Owner", "nil")
		local ply_id = ply:SteamID()

		if (IsValid(ply) and id == ply_id or id == "world") then
			return true
		else
			return false
		end
	else
		return false
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////////// Timer ////////////////////
////////////////////////////////////////////
concommand.Add("zlm_debug_Timer_PrintAll", function(ply, cmd, args)
	if zlm.f.IsAdmin(ply) then
		zlm.f.Timer_PrintAll()
	end
end)

if zlm_TimerList == nil then
	zlm_TimerList = {}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

function zlm.f.Timer_PrintAll()
	PrintTable(zlm_TimerList)
end

function zlm.f.Timer_Create(timerid, time, rep, func)
	if zlm.f.FunctionValidater(func) then
		timer.Create(timerid, time, rep, func)
		table.insert(zlm_TimerList, timerid)
		//zlm.f.Debug("Timer Created: " .. timerid)
	end
end

function zlm.f.Timer_Remove(timerid)
	if timer.Exists(timerid) then
		timer.Remove(timerid)
		table.RemoveByValue(zlm_TimerList, timerid)
		//zlm.f.Debug("Timer Removed: " .. timerid)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
////////////// Rank / Job //////////////////
////////////////////////////////////////////
// Returns the player rank / usergroup
function zlm.f.GetPlayerRank(ply)
	return ply:GetUserGroup()
end

// Returns the players job
function zlm.f.GetPlayerJobName(ply)
	return team.GetName( zlm.f.GetPlayerJob(ply) )
end

function zlm.f.GetPlayerJob(ply)
	return ply:Team()
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////////// CUSTOM ////////////////////
////////////////////////////////////////////
function zlm.f.VCMod_Installed()
	return VC ~= nil and not SVMOD
end

////////////////////////////////////////////
////////////////////////////////////////////
