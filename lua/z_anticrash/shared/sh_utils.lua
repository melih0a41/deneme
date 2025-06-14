-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

SH_ANTICRASH.UTILS = {}
SH_ANTICRASH.UTILS.LOG = {}
SH_ANTICRASH.UTILS.TIME = {}
SH_ANTICRASH.UTILS.MATERIAL = {}
SH_ANTICRASH.UTILS.IsDedicated = game.IsDedicated()

// Time
function SH_ANTICRASH.UTILS.TIME.Format( seconds )

	seconds = seconds or 0
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds / 60) % 60)
	seconds = seconds % 60
	
	return string.format("%02i:%02i:%02i", hours, minutes, seconds)
	
end

// Material validation
function SH_ANTICRASH.UTILS.MATERIAL.ForceValid( material )

	local mats = list.Get( "RopeMaterials" )
	local isValidMat = table.HasValue(mats, material)
	
	if !isValidMat then		
		-- Default to cable 
		material = "cable/cable2"
	end
	
	return material

end

// Logging
local packedMSGFormat = {
	[1] = SH_ANTICRASH.VARS.COLOR.RED,
	[2] = "[Anti-Crash] ",
	[3] = color_white,
}

local function UnpackMSG(str,hasNL)
	
	local packedMSG = table.Copy(packedMSGFormat)
	packedMSG[4] = str..(hasNL and '\n' or '')
	
	return unpack(packedMSG)

end

function SH_ANTICRASH.UTILS.LOG.Print(str)
	
	if SERVER then
	
		SH_ANTICRASH.UTILS.LOG.ConsolePrintAdmins(str)
		
	else
	
		SH_ANTICRASH.UTILS.LOG.ConsolePrint(str)
		
	end
	
end

function SH_ANTICRASH.UTILS.LOG.PlyPrint(ply,str)
	SH_ANTICRASH.UTILS.LOG.Print(SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)..' '..str)
end

function SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)
	
	if IsValid(ply) then
	
		local steamID = ply:SteamID() or "STEAM_0:0:0"
		local nick = ply:Nick() or "ERROR"
	
		return "<"..steamID.."> "..nick	
	
	end
	
	return "Console"
	
end

function SH_ANTICRASH.UTILS.LOG.GetNick(ply)
	
	if IsValid(ply) then
		return ply:Nick()
	else
		return "Console"
	end

end

function SH_ANTICRASH.GetNeighboringEnts(ent)
	
	local neighbours = {}

	if IsValid(ent) then
	
		local offsetVector = SH_ANTICRASH.VARS.NEIGHBOUROFFSETVECTOR
		local worldMins = LocalToWorld(ent:OBBMins()-offsetVector, Angle(0,0,0), ent:GetPos(), ent:GetAngles())
		local worldMaxs = LocalToWorld(ent:OBBMaxs()+offsetVector, Angle(0,0,0), ent:GetPos(), ent:GetAngles())
		
		neighbours = ents.FindInBox( worldMins, worldMaxs )
		
	end
	
	return neighbours
	
end

-- Cheecky way to make our hook the first
function SH_ANTICRASH.PrioritizedAddHook(hookName, identifier, prioritizedFunc)

	hook.Add( "PostGamemodeLoaded", "z_anticrash_prioritizeHook_"..hookName, function()

		-- Shitty workaround to avoid conflicts
		timer.Simple(10, function()
			local prioritizedHookName = "z_anticrash_prioritized_"..hookName
			local hooks = hook.GetTable()[hookName] or {}
			
			-- Remove all hooks & add to alternate hook
			for name, func in pairs(hooks) do
				hook.Add(prioritizedHookName, name, func)
				hook.Remove(hookName, name)
			end
			
			-- Create delegator that calls prioritized func first
			local function DelegateFunc(...)
				local funcRes = prioritizedFunc(...)
				
				if funcRes == nil then
					funcRes = hook.Run(prioritizedHookName, ...)
				end
				
				return funcRes
				
			end

			-- Hook delegator
			hook.Add(hookName, identifier, DelegateFunc)
			
			-- Make sure future hooks run under the delegator
			local __oldHookAdd = hook.Add
			
			function hook.Add(name, id, func)
			
				if name == hookName then
					__oldHookAdd(prioritizedHookName, id, func)
				else
					__oldHookAdd(name, id, func)
				end
			
			end
		
		end)
	
	end)

end

function SH_ANTICRASH.CanFreeze(ent)

	-- Check for vehicles
	if SH_ANTICRASH.SETTINGS.FREEZEVEHICLES and !ent:IsVehicle() then
		return false
	end
	
	local class = ent:GetClass()
	
	-- Check entity freeze blacklist
	if SH_ANTICRASH.SETTINGS.FREEZEBLACKLIST[class] then
		return false
	end
	
	-- Freeze blacklist REG
	for freezeI=1, #SH_ANTICRASH.SETTINGS.FREEZEBLACKLISTREG do
		
		-- Check if class is in the blacklist
		if string.StartWith(class, SH_ANTICRASH.SETTINGS.FREEZEBLACKLISTREG[freezeI]) then
			return false
		end
	
	end
	
	return true

end

if CLIENT then

	local function ConsolePrint(len, ply)
	
		local str = isstring(len) and len or net.ReadString()
		local hidePrefix = net.ReadBool()
		
		-- Check for translation formats
		str = SH_ANTICRASH.Format(str)
		
		if !hidePrefix then
			MsgC(UnpackMSG(str,true))
		else
			print(str)
		end
	
	end
	net.Receive("cl_anticrash_ConsolePrint",ConsolePrint)

	local function ChatPrint(len, ply)
		
		local str = isstring(len) and len or net.ReadString()
		
		-- Check for translation formats
		str = SH_ANTICRASH.Format(str)
		
		chat.AddText(UnpackMSG(str))
	
	end
	net.Receive("cl_anticrash_ChatPrint",ChatPrint)
	
	function SH_ANTICRASH.UTILS.LOG.ChatPrint(str)
		ChatPrint(str)
	end
	
	function SH_ANTICRASH.UTILS.LOG.ConsolePrint(str)
		ConsolePrint(str)
	end

end


if SERVER then
	
	util.AddNetworkString("cl_anticrash_ChatPrint")
	function SH_ANTICRASH.UTILS.LOG.ChatPrint(ply,str)
	
		net.Start("cl_anticrash_ChatPrint")
			net.WriteString(str)
		net.Send(ply)
		
	end
	
	function SH_ANTICRASH.UTILS.LOG.ChatPrintAll(str)
		
		local plys = player.GetAll()
		
		for i=1, #plys do
			SH_ANTICRASH.UTILS.LOG.ChatPrint(plys[i],str)
		end
		
	end
	
	util.AddNetworkString("cl_anticrash_ConsolePrint")
	function SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply,str,hidePrefix)
	
		if ply ~= NULL and ply:IsPlayer() then
	
			net.Start("cl_anticrash_ConsolePrint")
				net.WriteString(str)
				net.WriteBool(hidePrefix)
			net.Send(ply)
			
		else
			SH_ANTICRASH.UTILS.LOG.ServerPrint(str,hidePrefix)
		end
		
	end
	
	function SH_ANTICRASH.UTILS.LOG.ServerPrint(str,hidePrefix)
	
		-- Server console
		local formattedStr = SH_ANTICRASH.Format(str)
	
		if SH_ANTICRASH.UTILS.IsDedicated then
			
			if !hidePrefix then
				MsgC(UnpackMSG(formattedStr,true))
			else
				print(formattedStr)
			end
			
		end
		
		SV_ANTICRASH.Log(formattedStr)
		
	end
	
	function SH_ANTICRASH.UTILS.LOG.ConsolePrintAdmins(str)
		
		-- Server Console
		SH_ANTICRASH.UTILS.LOG.ServerPrint(str)
		
		-- Admins
		for k, ply in pairs(player.GetAll()) do
		
			if SH_ANTICRASH.HasAccess(ply) then
				SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply,str)
			end
		
		end
		
	end
	
	function SH_ANTICRASH.UTILS.LOG.PlyConsolePrintAdmins(ply,str)
		SH_ANTICRASH.UTILS.LOG.ConsolePrintAdmins(SH_ANTICRASH.UTILS.LOG.GetPlayerFormat(ply)..' '..str)
	end
	
end