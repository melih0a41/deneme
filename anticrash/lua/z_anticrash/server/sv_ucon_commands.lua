-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

/* 
	A compact console command system
*/

function SV_ANTICRASH.CMD.IsConsole(ply)

	if ply == NULL or ply:IsWorld() then 
		return true
	end
	
	return false
	
end

function SV_ANTICRASH.CMD.CanExecute(ply)
	
	if SV_ANTICRASH.CMD.IsConsole(ply) then 
		return true
	end
	
	return SH_ANTICRASH.HasAccess(ply,"global")
	
end

function SV_ANTICRASH.CMD.Help(ply, cmd, args)

	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "Help:")
	
	for cmd, data in pairs(SV_ANTICRASH.CMD.REGISTERED) do
	
		if data.info then
			SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o anticrash "..cmd.." - "..data.info, true)
		end
	end
	
end
SV_ANTICRASH.CMD.RegisterCMD("help",nil, SV_ANTICRASH.CMD.Help)

function SV_ANTICRASH.CMD.AntiCrash(ply, cmd, args)

	if !SV_ANTICRASH.CMD.CanExecute(ply) then return end
	
	local arg = args[1]
	
	if !arg then 
		SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "If you need help, please type \"anticrash help\" in your console.")
		return
	end
	
	local cmd = SV_ANTICRASH.CMD.REGISTERED[arg:lower()]
	
	if !cmd then return end	
	
	cmd.func(ply, cmd, args)
	
end
concommand.Add( "anticrash", SV_ANTICRASH.CMD.AntiCrash )

local function PrintServerInfo(ply, cmd, args)
	
	local entTbl = ents.GetAll()
	
	local lag, collisions, props, frozenProps, npcs, vehicles = 0,0,0,0,0,0
	local players, uptime, entities, spawned, tickrate = 0,0,0,0,0
	
	for i=1, #entTbl do
	
		local ent = entTbl[i]
		
		entities = entities + 1
		
		if string.StartWith(ent:GetClass(),"prop_") then
			
			props = props + 1
			
			local physObj = ent:GetPhysicsObject()
		
			if IsValid(physObj) and !physObj:IsMotionEnabled() then
				frozenProps = frozenProps + 1
			end
			
		end
		
		if ent:IsNPC() or ent:IsNextBot() then
		
			npcs = npcs + 1
			
		elseif ent:IsVehicle() and ent:GetClass() ~= "prop_vehicle_prisoner_pod" then
		
			-- only driving vehicles
			if ent:GetDriver() ~= NULL then
		
				vehicles = vehicles + 1
				
			end

		end
	
	end
	
	lag = math.Clamp(math.Round(100*(GetGlobalFloat("z_anticrash_Lag")/SH_ANTICRASH.SETTINGS.LAG.Delay)),0,100) 
	collisions = GetGlobalInt("z_anticrash_CollisionCount")
	spawned = GetGlobalInt("z_anticrash_Spawned")
	players = player.GetCount()
	uptime = SH_ANTICRASH.UTILS.TIME.Format(CurTime())
	tickrate = math.floor(1/engine.TickInterval())
	
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "Info:")
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #lag: "..lag, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #collisions: "..collisions, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #props: "..props, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #propsFrozen: "..frozenProps, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #npcs: "..npcs, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #vehicles: "..vehicles, true)
	
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "------------", true)
	
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #players: "..players, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #uptime: "..uptime, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #entities: "..entities, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #spawned: "..spawned, true)
	SH_ANTICRASH.UTILS.LOG.ConsolePrint(ply, "o #tickrate: "..tickrate, true)

end
SV_ANTICRASH.CMD.RegisterCMD("info","Print server info to console", PrintServerInfo)