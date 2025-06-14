-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

CL_ANTICRASH.GRAPH = {}

CL_ANTICRASH.GRAPH.COL = {
	PLAYERS = SH_ANTICRASH.VARS.COLOR.DARKGREY,
	UPTIME = SH_ANTICRASH.VARS.COLOR.DARKGREY,
	ENTITIES = SH_ANTICRASH.VARS.COLOR.DARKGREY,
	SPAWNED = SH_ANTICRASH.VARS.COLOR.DARKGREY,
	FPS = SH_ANTICRASH.VARS.COLOR.DARKGREY,
	TICKRATE = SH_ANTICRASH.VARS.COLOR.DARKGREY,
	ZLAG = SH_ANTICRASH.VARS.COLOR.RED,
	PROPS = SH_ANTICRASH.VARS.COLOR.BLUE,
	FROZENPROPS = SH_ANTICRASH.VARS.COLOR.LIGHTBLUE,
	COLLISIONS = SH_ANTICRASH.VARS.COLOR.ORANGE,
	NPCS = SH_ANTICRASH.VARS.COLOR.LIGHTYELLOW,
	VEHICLES = SH_ANTICRASH.VARS.COLOR.GREEN,
}

CL_ANTICRASH.GRAPH.INFO = {}
CL_ANTICRASH.GRAPH.INFO.PLAYERS = { cur = 0, max = game.MaxPlayers(), noDraw = true }
CL_ANTICRASH.GRAPH.INFO.UPTIME = { cur = 0, noDraw = true }
CL_ANTICRASH.GRAPH.INFO.ENTITIES = { cur = 0, noDraw = true }
CL_ANTICRASH.GRAPH.INFO.SPAWNED = { cur = 0, noDraw = true }
CL_ANTICRASH.GRAPH.INFO.FPS = { cur = 0, noDraw = true }
CL_ANTICRASH.GRAPH.INFO.TICKRATE = { cur = 0, noDraw = true }

CL_ANTICRASH.GRAPH.INFO.ZLAG = { cur = 0, max = SH_ANTICRASH.SETTINGS.LAG.Delay }
CL_ANTICRASH.GRAPH.INFO.PROPS = { cur = 0, max = 0 }
CL_ANTICRASH.GRAPH.INFO.FROZENPROPS = { cur = 0, noDraw = true }
CL_ANTICRASH.GRAPH.INFO.COLLISIONS = { cur = 0, max = 9999 }
CL_ANTICRASH.GRAPH.INFO.NPCS = { cur = 0, max = SH_ANTICRASH.SETTINGS.GRAPH.SCALE.MAXNPCS }
CL_ANTICRASH.GRAPH.INFO.VEHICLES = { cur = 0, max = SH_ANTICRASH.SETTINGS.GRAPH.SCALE.MAXVEHICLES }


CL_ANTICRASH.GRAPH.POINTS = {}
local function GraphPointUpdate()
	
	local points = {}
		
	for k, v in pairs(CL_ANTICRASH.GRAPH.INFO) do
	
		if v.noDraw then continue end
		
		CL_ANTICRASH.GRAPH.POINTS[k] = CL_ANTICRASH.GRAPH.POINTS[k] or {}
		
		table.insert(CL_ANTICRASH.GRAPH.POINTS[k], 1, {
			cur = v.cur,
			max = v.max
		})
		
		if #CL_ANTICRASH.GRAPH.POINTS[k] > SH_ANTICRASH.SETTINGS.GRAPH.TIMEWINDOW+2 then
			table.remove( CL_ANTICRASH.GRAPH.POINTS[k], SH_ANTICRASH.SETTINGS.GRAPH.TIMEWINDOW+3 )
		end
		
	end
	
end

local nextUpdate = 0
local function GraphInfoUpdate()

	if !SH_ANTICRASH.HasAccess("stats") then return end

	if !CL_ANTICRASH.MenuIsOpen() and !CL_ANTICRASH.OverlayIsOpen() and !SH_ANTICRASH.SETTINGS.GRAPH.ALWAYSUPDATE then return end
	
	if nextUpdate < CurTime() then
	 
		-- Players 
		CL_ANTICRASH.GRAPH.INFO.PLAYERS.cur = player.GetCount()
		
		-- Uptime
		CL_ANTICRASH.GRAPH.INFO.UPTIME.cur = SH_ANTICRASH.UTILS.TIME.Format(CurTime())
		
		-- Fps
		CL_ANTICRASH.GRAPH.INFO.FPS.cur = math.floor(1/RealFrameTime())
	
		-- Tickrate
		CL_ANTICRASH.GRAPH.INFO.TICKRATE.cur = math.floor(1/engine.ServerFrameTime()) -- engine.TickInterval()
		
		-- Lag
		CL_ANTICRASH.GRAPH.INFO.ZLAG.cur = GetGlobalFloat("z_anticrash_Lag")
		
		-- Spawned
		CL_ANTICRASH.GRAPH.INFO.SPAWNED.cur = GetGlobalInt("z_anticrash_Spawned")
		
		local entCount, propCount, npcCount, vehicleCount = 0, 0, 0, 0
		
		local entTbl = ents.GetAll()
		
		for i=1, #entTbl do
			
			local ent = entTbl[i]
			
			entCount = entCount + 1
		
			if string.StartWith(ent:GetClass(),"prop_") then
				
				propCount = propCount + 1
				
			end
			
			if ent:IsNPC() or ent:IsNextBot() then
			
				npcCount = npcCount + 1
				
			elseif ent:IsVehicle() and ent:GetClass() ~= "prop_vehicle_prisoner_pod" then
			
				-- Only driving vehicles
				if ent.GetDriver and ent:GetDriver() ~= NULL then
			
					vehicleCount = vehicleCount + 1
					
				end

			end
		
		end
		
		-- Entities
		CL_ANTICRASH.GRAPH.INFO.ENTITIES.cur = entCount
		
		-- Props
		CL_ANTICRASH.GRAPH.INFO.PROPS.cur = propCount
		local maxPropCount = SH_ANTICRASH.SETTINGS.GRAPH.SCALE.MAXPROPS
		
		if maxPropCount == -1 then
		
			local maxPropsPerPlayerConvar = GetConVar("sbox_maxprops")
			maxPropCount = CL_ANTICRASH.GRAPH.INFO.PLAYERS.cur * maxPropsPerPlayerConvar:GetInt()
			
		end
		
		CL_ANTICRASH.GRAPH.INFO.PROPS.max = maxPropCount
		
		-- Freeze count
		CL_ANTICRASH.GRAPH.INFO.FROZENPROPS.cur = GetGlobalInt("z_anticrash_FreezeCount")
		
		-- Collision count
		CL_ANTICRASH.GRAPH.INFO.COLLISIONS.cur = GetGlobalInt("z_anticrash_CollisionCount")
		CL_ANTICRASH.GRAPH.INFO.COLLISIONS.max = propCount * 8
		
		-- NPC Count
		CL_ANTICRASH.GRAPH.INFO.NPCS.cur = npcCount
		
		-- Vehicle Count
		CL_ANTICRASH.GRAPH.INFO.VEHICLES.cur = vehicleCount
		
		-- Update data points
		GraphPointUpdate()
		
		nextUpdate = CurTime() + SH_ANTICRASH.SETTINGS.GRAPH.UPDATEDELAY

	end

end
hook.Add("Think","cl_anticrash_GraphInfoUpdate",GraphInfoUpdate)
