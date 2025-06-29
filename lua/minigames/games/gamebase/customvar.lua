--[[--------------------------------------------
            Minigame Module - Variables
--------------------------------------------]]--

if SERVER then
    util.AddNetworkString("Minigames.ReplicateVar")
end

--[[----------------------------
         Main Functions
----------------------------]]--

function MinigameObject:ReplicateVar(VarName)
    if CLIENT then return end

    self:Checker(VarName, "string", 1)

    if ( self.__CustomVars[VarName] == nil ) then
        self.ThrowError([[The variable "]] .. VarName .. [[" does not exist.]], VarName, "existing variable")
    end

    net.Start("Minigames.ReplicateVar")
        net.WritePlayer(self:GetOwner())
        net.WriteString(VarName)
        net.WriteType(self.__CustomVars[VarName])
    net.Broadcast()
end

function MinigameObject:AddNewVar(VarName, VarType, Default)
    self:Checker(VarName, "string", 1)
    self:Checker(VarType, "string", 2)

    local Result = false

    if ( Default ~= nil ) then
        self:Checker(Default, VarType, 3)
    else
        ThrowError([[The third argument of AddNewVar() must not be nil.]], Default, VarType)
    end

    if ( VarType == "bool" ) or ( VarType == "boolean" ) then
        self:Checker(Default, "boolean", 3)

        self["Set" .. VarName] = function(SubSelf, Value)
            SubSelf:Checker(Value, "boolean", 1)
            SubSelf.__CustomVars[VarName] = Value

            SubSelf:ReplicateVar(VarName)
        end

        self["Is" .. VarName] = function(SubSelf)
            return SubSelf.__CustomVars[VarName]
        end

        self["Toggle" .. VarName] = function(SubSelf)
            SubSelf.__CustomVars[VarName] = not SubSelf.__CustomVars[VarName]
            return SubSelf.__CustomVars[VarName]
        end

        Result = true

    elseif ( VarType == "number" ) then
        self:Checker(Default, "number", 3)

        self["Set" .. VarName] = function(SubSelf, Value)
            SubSelf:Checker(Value, "number", 1)
            SubSelf.__CustomVars[VarName] = Value

            SubSelf:ReplicateVar(VarName)
        end

        Result = true
    end

    self.__CustomVars[VarName] = Default
    self["Get" .. VarName] = function(SubSelf)
        return SubSelf.__CustomVars[VarName]
    end

    if ( Result ~= true ) then
        ThrowError([[There was an error when creating the variable.]], VarType, "boolean or number")
    end
end


--[[----------------------------
             Network
----------------------------]]--

if CLIENT then
    net.Receive("Minigames.ReplicateVar", function()
        local Player = net.ReadPlayer()
        if ( Minigames.ActiveGames[Player] == nil ) then return end

        local VarName = net.ReadString()
        local VarValue = net.ReadType()

        Minigames.ActiveGames[Player].__CustomVars[VarName] = VarValue
    end)
end