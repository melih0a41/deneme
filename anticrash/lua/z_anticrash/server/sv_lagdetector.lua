-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

if game.SinglePlayer() then return end

local defaultTimeDiff = 0
local alertTimeDiff = 0
local dangerTimeDiff = 0

local alertRange = 1
local inAlertState = false
local alertTimerID = "z_anticrash_AlertTimer"

local startDetecting = false
local nextDebugPrint = 0

local lagStuckCounter = 0
local lagStuckTimerID = "z_anticrash_LagStuck"

local nextBroadcastLag = 0
local prevPlayers = 0

-- Start lag detector 20 seconds after startup
timer.Simple(20,function()
	startDetecting = true
end)

local function UpdateLagStuckCount()
	
	lagStuckCounter = lagStuckCounter + 1
	
	timer.Create(lagStuckTimerID, SH_ANTICRASH.SETTINGS.LAG.STUCKTIME, 1, function()
		lagStuckCounter = 0
	end)
	
end

local function UpdateTimeDiff(diff)
	
	defaultTimeDiff = diff
	alertTimeDiff = diff+alertRange
	dangerTimeDiff = diff+SH_ANTICRASH.SETTINGS.LAG.Delay
	
end

local function CheckForLag()

	-- Cannot accurately check lag when timescale is changed
	if !startDetecting or game.GetTimeScale() != 1 then return end 
	
	-- Don't check when no players
	if player.GetCount() == 0 and prevPlayers == 0 then return end
	prevPlayers = player.GetCount()
	
	local curTimeDiff = SysTime() - CurTime()

	if defaultTimeDiff == 0 then
		UpdateTimeDiff(curTimeDiff)
	end
	
	if nextBroadcastLag < CurTime() then
	
		local lag = math.max(SH_ANTICRASH.SETTINGS.LAG.Delay - (dangerTimeDiff-curTimeDiff),0)
		SetGlobalFloat("z_anticrash_Lag",lag)
		
		nextBroadcastLag = CurTime() + SH_ANTICRASH.SETTINGS.GRAPH.UPDATEDELAY
		
	end
	
	-- Lag is increasing
	if curTimeDiff > alertTimeDiff and !inAlertState then
	
		inAlertState = true
	
		-- Reset defaultTimeDiff if there was no significant increase in lag 
		timer.Create(alertTimerID, 30, 1, function()
		
			local newTimeDiff = SysTime() - CurTime()
			
			-- no increase in the past 30 seconds
			if curTimeDiff < dangerTimeDiff then
				UpdateTimeDiff(newTimeDiff)
				inAlertState = false
			end
			
			-- DEBUG
			-- print("LAG WARNING RESET> defaultTimeDiff:"..defaultTimeDiff, "dangerTimeDiff:"..dangerTimeDiff, "curTimeDiff:"..curTimeDiff)
			
		end)
		
		-- DEBUG
		-- print("LAG  WARNING> defaultTimeDiff:"..defaultTimeDiff, "dangerTimeDiff:"..dangerTimeDiff, "curTimeDiff:"..curTimeDiff)
		
	end
	
	-- Lag ongoing
	if curTimeDiff > dangerTimeDiff then
	
		SH_ANTICRASH.UTILS.LOG.Print("#heavyLag")	
		
		-- remove warning timer
		timer.Remove(alertTimerID)
		inAlertState = false
		
		
		if lagStuckCounter >= SH_ANTICRASH.SETTINGS.LAG.STUCK then
			
			SH_ANTICRASH.UTILS.LOG.Print("#lagIsStuck")	
			
			-- reset map
			if SH_ANTICRASH.SETTINGS.LAG.STUCKCLEANMAP then
				SV_ANTICRASH.CleanMap(true)
			else
				hook.Run("z_anticrash_LagDetect")
			end
		
		else
		
			-- run anti lag measures
			hook.Run("z_anticrash_LagDetect")
			
			UpdateLagStuckCount()
			
		end
		
		SH_ANTICRASH.UTILS.LOG.ChatPrintAll("#crashPrevented")
		
		UpdateTimeDiff(curTimeDiff)
		
	end
	
	-- DEBUG
	/*
	if nextDebugPrint < CurTime() then
		
		print("STATUS> defaultTimeDiff:"..defaultTimeDiff, "dangerTimeDiff:"..dangerTimeDiff, "curTimeDiff:"..curTimeDiff)
		
		nextDebugPrint = CurTime()+10
	
	end
	*/
	
end
hook.Add("Tick","z_anticrash_CheckForLag",CheckForLag)

local function PostGamemodeLoaded() 
	SH_ANTICRASH.UTILS.LOG.Print("#startingUp")	
end
hook.Add( "PostGamemodeLoaded", "z_anticrash_PostGamemodeLoaded", PostGamemodeLoaded )

local function ShutDown()
	SH_ANTICRASH.UTILS.LOG.Print("#shuttingDown")	
end
hook.Add( "ShutDown", "z_anticrash_Shutdown", ShutDown )