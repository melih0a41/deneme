--[[--------------------------------------------
             Minigame Reward Module
--------------------------------------------]]--

local REWARDS_REGISTERED = {}
local MAX_ARGUMENTS = 3
local MAX_SIZEUINT = 8


--[[----------------------------
          Reward Object
----------------------------]]--

local REWARD = {}

function REWARD:SetName(Name)
    Minigames.Checker(Name, "string", 1)

    self.Name = Name
end

function REWARD:SetNameAmount(NameAmount)
    Minigames.Checker(NameAmount, "string/function", 1)

    self.NameAmount = NameAmount
end

function REWARD:SetIcon(Icon)
    Minigames.Checker(Icon, "string", 1)

    if not file.Exists("materials/" .. Icon, "GAME") then return end

    self.Icon = Icon
end

function REWARD:SetRewardID(RewardID)
    Minigames.Checker(RewardID, "string", 1)

    self.RewardID = RewardID
end

function REWARD:GetName()
    return self.Name
end

function REWARD:GetNameAmount()
    if isfunction(self.NameAmount) then
        return self.NameAmount( unpack(self.Values) )
    else
        return self.NameAmount
    end
end

function REWARD:GetIcon()
    return self.Icon
end

function REWARD:GetRewardID()
    return self.RewardID
end

function REWARD:SetFunctionReward(Reward)
    Minigames.Checker(Reward, "function", 1)

    self.Reward = Reward
end

function REWARD:AddArgument(Argument)
    Minigames.Checker(Argument, "table", 1)

    --[[ Argument schema:
        @none: {}

        @text: {
            @Default: string,
            @Placeholder: string,
            @Convert: function = nil
        }

        @slider: {
            @Min: number,
            @Max: number,
            @Default: number,
            @Convert: function = nil
        }

        @list: {
            @Options: table[str],
            @Default: any,
            @Convert: function = nil
        }

        @list: {
            @Options: table[str: str],
            @Default: any,
            @Convert: function = nil
        }
    --]]

    if not isstring(Argument["Type"]) then
        Minigames.ThrowError("The type value of REWARD:AddArgument() is not a string", Argument["Type"], "table[Type: string]")
    else
        Argument["Type"] = string.lower(Argument["Type"])
    end

    if Argument["Type"] ~= "none" then

        if Argument["Default"] == nil then
            Argument["Default"] = ""
        end

        if Argument["Convert"] == nil then
            Argument["Convert"] = function(v) return v end
        elseif not isfunction(Argument["Convert"]) then
            Minigames.ThrowError("The function value of REWARD:AddArgument() is not a function", Argument["Convert"], "table[Convert: function]")
        end

    end

    if Argument["Type"] == "slider" then

        if not isnumber(Argument["Min"]) then
            Minigames.ThrowError("The min value of REWARD:AddArgument() is not a number", Argument["Min"], "table[Min: number]")
        end

        if not isnumber(Argument["Max"]) then
            Minigames.ThrowError("The max value of REWARD:AddArgument() is not a number", Argument["Max"], "table[Max: number]")
        end

        if Argument["Min"] > Argument["Max"] then
            Minigames.ThrowError("The min value of REWARD:AddArgument() is greater than the max value", Argument, "Min < Max")
        end

    elseif Argument["Type"] == "list" then
        if not istable(Argument["Options"]) then
            Minigames.ThrowError("The options value of REWARD:AddArgument() is not a table", Argument["Options"], "table[Options: table]")
        end

        local k, v = next(Argument["Options"])
        Argument["IsDictionary"] = isstring(k) and isstring(v)

    elseif Argument["Type"] == "text" then
        if not isstring(Argument["Placeholder"]) then
            Minigames.ThrowError("The placeholder value of REWARD:AddArgument() is not a string", Argument["Placeholder"], "table[Placeholder: string]")
        end

    elseif Argument["Type"] == "none" then
        Argument["Default"] = nil
    else
        Minigames.ThrowError("The first argument value of REWARD:AddArgument() is not allowed", Argument, "table")
    end

    table.insert(self.Arguments, Argument)
end

function REWARD:SetEnabled(Enabled)
    Minigames.Checker(Enabled, "function", 1)

    self.Enabled = Enabled
end

REWARD.__index = REWARD



--[[----------------------------
          Values Reward
----------------------------]]--

local function AddValue(self, Value)
    table.insert(self.Values, Value)
end

local function ClearValues(self)
    self.Values = {}
end

local function AddReward(self)
    if SERVER then return end
    if not Minigames.IsAllowed( LocalPlayer() ) then return end

   net.Start("Minigames.AddReward")
       net.WriteString(self.RewardID)

       net.WriteUInt(#self.Values, MAX_ARGUMENTS)
       for _, Value in ipairs(self.Values) do
           net.WriteType(Value)
       end

    net.SendToServer()
end

local function GiveReward(self, owner, ply)
    if not self.Enabled() then return end

    self.Reward(owner, ply, unpack(self.Values))
end

local function RemoveReward(self)
    if SERVER then return end
    if not Minigames.IsAllowed( LocalPlayer() ) then return end

    net.Start("Minigames.RemoveReward")
        net.WriteUInt(self.Index, MAX_SIZEUINT)
    net.SendToServer()
end



--[[----------------------------
         Reward Creation
----------------------------]]--

function Minigames.CreateNewReward()
    local o = {}
    o.Name = ""
    o.NameAmount = ""
    o.Icon = nil
    o.Arguments = {}
    o.Values = {}
    o.RewardID = ""
    o.Reward = function(owner, ply, ...) end
    o.ModuleIDHash = "76561198307194380"

    return setmetatable(o, REWARD)
end

function Minigames.RegisterReward(Reward)
    Minigames.Checker(Reward, "table", 1)

    if not Reward.Name then
        Minigames.ThrowError("The Name value of Minigames.RegisterReward() is not a string", Reward, "table[Name: string]")
    end

    -- Strip all spaces and special characters and make it lowercase
    Reward.RewardID = string.lower( string.gsub(Reward.Name, "[^%w]", "") )

    if not Reward.NameAmount then
        Minigames.ThrowError("The NameAmount value of Minigames.RegisterReward() is not a string/function", Reward, "table[NameAmount: string/function]")
    end

    if not Reward.RewardID then
        Minigames.ThrowError("The RewardID value of Minigames.RegisterReward() is not a string", Reward, "table[RewardID: string]")
    end

    if Reward.Enabled == nil then
        Reward.Enabled = function() return true end
    end

    local Result = Reward.Enabled()
    if ( Result ~= true ) or ( Result == nil) then
        return
    end

    if #Reward.Arguments == 0 then
        Reward:AddArgument({
            Name = Minigames.StringFormat( Minigames.GetPhrase("reward.onlyone"), Reward.Name ),
            Type = "none"
        })
    end

    Reward.AddValue = AddValue
    Reward.ClearValues = ClearValues
    Reward.AddReward = AddReward
    Reward.GiveReward = GiveReward
    Reward.RemoveReward = RemoveReward

    REWARDS_REGISTERED[Reward.RewardID] = Reward
end


--[[----------------------------
         Rewards Methods
----------------------------]]--

function Minigames.GetReward(RewardID)
    return table.Copy(REWARDS_REGISTERED[ RewardID ])
end

function Minigames.GetRewards()
    return REWARDS_REGISTERED
end

function Minigames.ClearRewards()
    REWARDS_REGISTERED = {}
end