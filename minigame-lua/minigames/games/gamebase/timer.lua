--[[--------------------------------------------
            Minigame Module - Timer
--------------------------------------------]]--

MinigameObject.__Timer = {}
MinigameObject.__Chronometers = {}

local ReturnSameValue = function(v) return v end

--[[----------------------------
         Timer Functions
----------------------------]]--

function MinigameObject:TimerExists( TimerName )
    self:Checker(TimerName, "string", 1)

    local Exists = false
    local FullName = string.Trim( "Minigames." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName ) -- FIX: id yerine TimerName

    if self.__Timer[FullName] then
        if timer.Exists( FullName ) then
            Exists = true
        else
            self.__Timer[FullName] = nil
        end
    end

    return Exists
end

function MinigameObject:RemoveTimer( TimerName )
    self:Checker(TimerName, "string", 1)

    local FullName = string.Trim( "Minigames." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName ) -- FIX: id yerine TimerName

    timer.Remove( FullName )
    self.__Timer[FullName] = nil
end

function MinigameObject:CreateTimer( TimerName, Delay, Repetitions, Function )
    self:Checker(TimerName, "string", 1)
    self:Checker(Delay, "number", 2)
    self:Checker(Repetitions, "number", 3)
    self:Checker(Function, "function", 4)

    local FullName = string.Trim( "Minigames." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName ) -- FIX: id yerine TimerName

    if self.__Timer[FullName] then
        self:RemoveTimer( TimerName ) -- FIX: FullName yerine TimerName
    end

    self.__Timer[FullName] = true

    timer.Create( FullName, Delay, Repetitions, Function)
end

function MinigameObject:PauseTimer( TimerName )
    self:Checker(TimerName, "string", 1)

    local FullName = string.Trim( "Minigames." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName ) -- FIX

    timer.Pause( FullName )
end

function MinigameObject:StopTimer( TimerName )
    self:Checker(TimerName, "string", 1)

    local FullName = string.Trim( "Minigames." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName ) -- FIX

    timer.Stop( FullName )
end

function MinigameObject:UnPauseTimer( TimerName )
    self:Checker(TimerName, "string", 1)

    local FullName = string.Trim( "Minigames." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. TimerName ) -- FIX

    timer.UnPause( FullName )
end
MinigameObject.ResumeTimer = MinigameObject.UnPauseTimer

function MinigameObject:GetAllTimers(GetKeys)
    return (GetKeys == true) and table.GetKeys( self.__Timer ) or self.__Timer
end

function MinigameObject:RemoveAllTimers()
    for TimerName, _ in pairs( self.__Timer ) do -- FIX: GetAllTimers yerine direkt döngü
        timer.Remove( TimerName )
    end
    self.__Timer = {}
end

--[[----------------------------
           Chronometer
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

        timer.Create( "Minigames.Chronometer." .. self.OwnerID .. "." .. self.Name .. "." .. self.SubTimerID, Delay, 1, function()
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

    local FullName = "Minigames.Chronometer." .. self.OwnerID .. "." .. self.Name .. "." .. self.SubTimerID
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
            hook.Remove("Think", "Minigames.Chronometer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
            timer.Pause("Minigames.Chronometer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
        end
    else
        self.Timers[self.PauseCurrent]( self.PersistentVar )
    end
end

function TimerObject:Stop()
    self.Running = false

    for i = 1, self.SubTimerID do
        hook.Remove("Think", "Minigames.Chronometer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
        timer.Remove("Minigames.Chronometer." .. self.OwnerID .. "." .. self.Name .. "." .. i)
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

function MinigameObject:CreateChronometer(Name)
    self:Checker(Name, "string", 1)

    local FullName = "Minigames.Chronometer." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. Name

    if self.__Chronometers[FullName] then
        Minigames.ThrowError("The chronometer " .. Name .. " already exists.", Name, "string")
    end

    local Chrono = table.Copy( TimerObject )
    Chrono.Name = Name
    Chrono.GameScript = self
    Chrono:SetOwner( self:GetOwner() )

    self.__Chronometers[FullName] = Chrono

    return Chrono
end

function MinigameObject:RemoveChronometer(Name)
    self:Checker(Name, "string", 1)

    local FullName = "Minigames.Chronometer." .. self:GetGameID() .. "." .. self:GetOwnerID() .. "." .. Name

    if self.__Chronometers[FullName] then
        self.__Chronometers[FullName]:Stop()
    end

    self.__Chronometers[FullName] = nil
end