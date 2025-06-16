--[[--------------------------------------------
              Security Enhancements
--------------------------------------------]]--

Minigames.RateLimit = Minigames.RateLimit or {}

-- Rate limiting function
local function CheckRateLimit(ply, action, limit, timeWindow)
    if not IsValid(ply) then return false end
    
    limit = limit or 10
    timeWindow = timeWindow or 5
    
    local steamID = ply:SteamID()
    local currentTime = CurTime()
    
    if not Minigames.RateLimit[steamID] then
        Minigames.RateLimit[steamID] = {}
    end
    
    if not Minigames.RateLimit[steamID][action] then
        Minigames.RateLimit[steamID][action] = {count = 0, lastReset = currentTime}
    end
    
    local actionData = Minigames.RateLimit[steamID][action]
    
    if currentTime - actionData.lastReset > timeWindow then
        actionData.count = 0
        actionData.lastReset = currentTime
    end
    
    actionData.count = actionData.count + 1
    return actionData.count <= limit
end

-- Export globally
Minigames.CheckRateLimit = CheckRateLimit