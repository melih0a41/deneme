--[[--------------------------------------------
            Minigame Module - Timer
--------------------------------------------]]--

MinigameObject.__Timers = {}

local ReturnSameValue = function(v) return v end

--[[----------------------------
          Timer Object
----------------------------]]--

local TimerObject = {}

TimerObject.Name = ""
TimerObject.Owner = NULL
TimerObject.OwnerID = 0
TimerObject.GameScript = {}
TimerObject.Timers = {}

TimerObject.Current = 0
TimerObject.CurrentLoop = 0
TimerObject.CurrentPause = 0
TimerObject.SubTimerID = 0
TimerObject.IsLoop = false
TimerObject.Running = false
TimerObject.PersistentVar = ""
TimerObject.PersistentVarFunc = ""
TimerObject.OnStopTimerFunc = nil


function TimerObject:SetOwner(Owner)
    if not ( IsValid(Owner) and Owner:IsPlayer() ) then
        Minigames.ThrowError("The first argument of TimerObject:SetOwner() must be a valid player.", Owner, "Player")
    end

    self["Owner"] = Owner
    self.OwnerID = Owner:SteamID64()
end

function TimerObject:SetLoop(Loop)
    if not ( isnumber(Loop) or isbool(Loop) ) then
        Minigames.ThrowError("The first argument of TimerObject:SetLoop() must be a valid type.", Loop, "number/boolean")
    end

    self.IsLoop = Loop
end

local ALLOWED_VARS = {
    ["table"] = true,
    ["number"] = true,
    ["string"] = true,
    ["function"] = true
}
function TimerObject:SetVariable(Var)
    if not ALLOWED_VARS[type(Var)] then
        Minigames.ThrowError("The first argument of TimerObject:SetVariables() must be a valid type.", Var, "table/number/string/function")
    end

    if isfunction(Var) then
        self.PersistentVar = Var()
        self.PersistentVarFunc = Var
    else
        self.PersistentVar = Var
    end
end

function TimerObject:GetVariable()
    return self.PersistentVar
end

function TimerObject:SetOnStopTimer(Func)
    Minigames.Checker(Func, "function", 1)

    self.OnStopTimerFunc = Func
end

function TimerObject:Wait(Delay, Func)
    Minigames.Checker(Delay, "number", 1)

    if ( Func ~= nil ) then
        Minigames.Checker(Func, "function", 2)
    else
        Func = ReturnSameValue
    end

    self.SubTimerID = self.SubTimerID + 1

    local WaitFunc = function()
        Delay = math.max( Func(Delay), .01 )

        timer.Create( "Minigames.Timer." .. self.OwnerID .. "." .. self.Name .. "." .. self.SubTimerID, Delay, 1, function()
            self:Next()
        end)
    end

    table.insert( self.Timers, WaitFunc )
end

function TimerObject:WaitUntil(Trigger, FallbackDelay)
    Minigames.Checker(Trigger, "function", 1)
    Minigames.Checker(FallbackDelay, "number", 2)

    if FallbackDelay < 0 then
        Minigames.ThrowError("The second argument of TimerObject:WaitUntil() must be a positive number.", FallbackDelay, "number")
    end

    self.SubTimerID = self.SubTimerID + 1

    local FullName = "Minigames.Timer." .. self.OwnerID .. "." .. self.Name .. "." .. self.SubTimerID
    local WaitFunc = function(PersistentVar)
        if Trigger( PersistentVar ) then -- First tick is true
            self:Next()
        else
            local StartTime = CurTime()
            local EndTime = StartTime + FallbackDelay
            hook.Add("Think", FullName, function()
                if Trigger( PersistentVar ) then
                    hook.Remove("Think", FullName)
                    self:Next()

                elseif CurTime() >= EndTime then
                    hook.Remove("Think", FullName)
                    self:Next()
                end
            end)
        end
    end

    table.insert( self.Timers, WaitFunc )
end

function TimerObject:AddAction(Func)
    Minigames.Checker(Func, "function", 1)

    self.SubTimerID = self.SubTimerID + 1

    local ActionFunc = function(PersistentVar)
        local NeedToStop = ( Func( PersistentVar ) == true )
        if NeedToStop then
            self:Stop()
        else
            self:Next()
        end
    end

    table.insert( self.Timers, ActionFunc )
end

function TimerObject:Next()
    self.Current = self.Current + 1

    if self.Timers[self.Current] then -- If there is a next timer
        self.Timers[self.Current]( self.PersistentVar )

    elseif ( self.IsLoop == false) then -- If there is no next timer and timer isn't a loop
        self:Stop()

    else -- Reset the timer
        self.Current = 0
        if isfunction(self.PersistentVarFunc) then
            self.PersistentVar = self.PersistentVarFunc()
        end

        if ( self.IsLoop == true ) then
            self:Next()
        elseif ( self.IsLoop > self.CurrentLoop ) then
            self.CurrentLoop = self.CurrentLoop + 1
            self:Next()
        end
    end
end

function TimerObject:Pause(State)
    self.PauseCurrent = self.Current

    if ( State == true ) then
        for i = 1, self.SubTimerID do
            hook.Remove("Think", "Minigames.Timer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
            timer.Pause("Minigames.Timer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
        end
    else
        self.Timers[self.PauseCurrent]( self.PersistentVar )
    end
end

function TimerObject:Stop()
    self.Running = false

    for i = 1, self.SubTimerID do
        hook.Remove("Think", "Minigames.Timer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
        timer.Remove("Minigames.Timer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
    end

    if isfunction(self.OnStopTimerFunc) then
        self.OnStopTimerFunc( self.PersistentVar )
    end
end

function TimerObject:Start()
    self.Running = true
    self:Next()
end

function TimerObject:IsRunning()
    return self.Running
end

--[[----------------------------
         Timer Functions
----------------------------]]--

function MinigameObject:CreateTimer(TimerName)
    self:Checker(TimerName, "string", 1)

    local FullName = "Minigames.Timer." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName

    if self.__Timers[FullName] then
        Minigames.ThrowError("The Timer " .. TimerName .. " already exists.", TimerName, "string")
    end

    local NewTimer = table.Copy( TimerObject )
    NewTimer.Name = TimerName
    NewTimer.GameScript = self
    NewTimer:SetOwner( self:GetOwner() )

    self.__Timers[FullName] = NewTimer

    return NewTimer
end

function MinigameObject:RemoveTimer(TimerName)
    self:Checker(TimerName, "string", 1)

    local FullName = "Minigames.Timer." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName

    if self.__Timers[FullName] then
        self.__Timers[FullName]:Stop()
    end

    self.__Timers[FullName] = nil
end

function MinigameObject:RemoveAllTimers()
    for TimerName, Timer in pairs( self.__Timers ) do
        Timer:Stop()
        self.__Timers[TimerName] = nil
    end
end