if gProtect.config.DisableBuddySystem then return end

util.AddNetworkString("gP:Buddies")

local weps = {
	"weapon_physcannon",
	"weapon_physgun",
	"gmod_tool",
	"canProperty",
	"canUse"
}

gProtect.TouchPermission = gProtect.TouchPermission or {}

hook.Add("PlayerSay", "gP:OpenBuddies", function( ply, text, public )
	if (( string.lower( text ) == "!buddies" )) then
		ply:ConCommand("gp_buddies")

		return ""
	end
end )

hook.Add("slib.FullLoaded", "gP:BuddiesLoad", function(ply)
    gProtect.networkTouchPermissions(ply)
end)

net.Receive("gP:Buddies", function(_, ply)
	if ply.lastBuddyRequest and ply.lastBuddyRequest > CurTime() then return end
	ply.lastBuddyRequest = CurTime() + .1
	local buddy = net.ReadInt(15)
	local weapon = net.ReadUInt(3)
	local todo = net.ReadBool()
	local sid = ply:SteamID()
	if !isnumber(buddy) or !isnumber(weapon) then return end

	if !todo then todo = nil end
	weapon = weps[weapon]
	
	buddy = ents.GetByIndex(buddy)

	if weapon == nil or !IsValid(buddy) or !buddy:IsPlayer() then return end
	
	gProtect.TouchPermission[sid] = gProtect.TouchPermission[sid] or {}
	gProtect.TouchPermission[sid][weapon] = gProtect.TouchPermission[sid][weapon] or {}
	gProtect.TouchPermission[sid][weapon][buddy:SteamID()] = todo
	
	gProtect.networkTouchPermissions(buddy, sid)
end)