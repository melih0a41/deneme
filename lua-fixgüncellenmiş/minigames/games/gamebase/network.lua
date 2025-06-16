--[[--------------------------------------------
            Minigame Module - Network
--------------------------------------------]]--

if SERVER then
    util.AddNetworkString("Minigames.NetworkData")
end

local DefaultNetworkNameUInt = 4 --> 15

MinigameObject.__NetworkData = {}
MinigameObject.__RegisteredNetworks = {}

--[[----------------------------
        Network Functions
----------------------------]]--

function MinigameObject:RegisterNetworkData( NetworkName, TestFunc, Func )
    self:Checker(NetworkName, "string", 1)

    if self.__RegisteredNetworks[NetworkName] then
        self.ThrowError("The network data " .. NetworkName .. " is already registered.", NetworkName, "string")
    end

    self:Checker(TestFunc, "function", 2)
    self:Checker(Func, "function", 3)

    local NetworkIndex = table.insert(self.__NetworkData, {
        ["TestFunc"] = TestFunc,
        ["Func"] = Func
    })

    self.__RegisteredNetworks[NetworkName] = NetworkIndex

    if CLIENT then return end

    self["SendNW" .. NetworkName] = function( SubSelf, TargetPlayer )
        Target = TargetPlayer or SubSelf:GetOwner()

        local Result = Func(SubSelf)
        if not TestFunc(Result) then
            SubSelf.ThrowError("The network data \"" .. NetworkName .. "\" returned an invalid value.", Result, "any")
        end

        net.Start("Minigames.NetworkData")
            net.WriteString( SubSelf:GetGameID() )
            net.WriteUInt( NetworkIndex, DefaultNetworkNameUInt )
            net.WritePlayer( Target )
            net.WriteType( Result )
        net.Send(Target)
    end
end

function MinigameObject:CatchData( NetworkName, Func )
    if SERVER then return end

    self:Checker(NetworkName, "string", 1)
    self:Checker(Func, "function", 2)

    if not self.__RegisteredNetworks[NetworkName] then
        self.ThrowError("The network data " .. NetworkName .. " is not registered.", NetworkName, "string")
    end

    self.__NetworkData[ self.__RegisteredNetworks[NetworkName] ].Func = Func
end

if CLIENT then

    net.Receive("Minigames.NetworkData", function()
        local GameID = net.ReadString()
        local NetworkIndex = net.ReadUInt(DefaultNetworkNameUInt)

        if ( Minigames.Games[GameID] == nil ) then return end
        local Owner = net.ReadPlayer()
        local Data = net.ReadType()

        local GameScript = Minigames.GetOwnerGame(Owner)
        if not GameScript then return end

        GameScript.__NetworkData[NetworkIndex].Func(Data, GameScript)
    end)
end