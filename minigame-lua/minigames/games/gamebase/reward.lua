--[[--------------------------------------------
            Minigame Module - Reward
--------------------------------------------]]--

local MAX_ARGUMENTS = 3
local MAX_SIZEUINT = 8

if SERVER then
    util.AddNetworkString("Minigames.AddReward")
    util.AddNetworkString("Minigames.RemoveReward")
    util.AddNetworkString("Minigames.ClearRewards")
end

--[[----------------------------
        Reward Functions
----------------------------]]--

MinigameObject.__Rewards = {}

function MinigameObject:AddReward(Reward)
    self:Checker(Reward, "table", 1)

    local Index = table.insert( self.__Rewards, Reward )

    hook.Run("Minigames.RewardAdded", self:GetOwner(), Reward)

    if ( CLIENT ) then return end

    net.Start("Minigames.AddReward")
        net.WritePlayer( self:GetOwner() )
        net.WriteString( Reward:GetRewardID() )
        net.WriteUInt( Index, MAX_SIZEUINT )
        net.WriteUInt( #Reward.Values, MAX_ARGUMENTS )
        for _, value in ipairs( Reward.Values ) do
            net.WriteType(value)
        end
    net.Broadcast()
end

function MinigameObject:RemoveReward(Index)
    self:Checker(Index, "number", 1)

    table.remove( self.__Rewards, Index )

    hook.Run("Minigames.RewardRemoved", self:GetOwner(), Index)

    if ( CLIENT ) then return end

    net.Start("Minigames.RemoveReward")
        net.WritePlayer(self:GetOwner())
        net.WriteUInt(Index, MAX_SIZEUINT)
    net.Broadcast()
end

function MinigameObject:ClearRewards()
    self.__Rewards = {}

    if ( CLIENT ) then return end

    net.Start("Minigames.ClearRewards")
        net.WritePlayer(self:GetOwner())
    net.Broadcast()
end

function MinigameObject:GetRewards()
    return table.Copy(self.__Rewards)
end

function MinigameObject:GiveReward(TargetPlayers)
    local Owner = self:GetOwner()
    timer.Simple(0, function()
        for _, ply in ipairs(TargetPlayers) do
            if #self.__Rewards == 0 then
                Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("reward.none"), ply ) )
                continue
            end

            for _, Reward in ipairs(self.__Rewards) do
                Reward:GiveReward(Owner, ply)
                Minigames.BroadcastMessage( Minigames.StringFormat( Minigames.GetPhrase("reward.given"), ply, Reward:GetNameAmount() ) )
            end
        end
    end)
end


--[[----------------------------
           Networking
----------------------------]]--

if ( SERVER ) then

    net.Receive("Minigames.AddReward", function(_, ply)
        if not Minigames.IsAllowed(ply) then return end

        local GameScript = Minigames.GetOwnerGame(ply)
        if not GameScript then return end
        if GameScript:IsActive() then return end

        local Reward = Minigames.GetReward( net.ReadString() )
        local Amount = net.ReadUInt(MAX_ARGUMENTS)
        for i = 1, Amount do
            Reward:AddValue( net.ReadType() )
        end

        GameScript:AddReward(Reward)
    end)

    net.Receive("Minigames.RemoveReward", function(_, ply)
        if not Minigames.IsAllowed(ply) then return end

        local GameScript = Minigames.GetOwnerGame(ply)
        if not GameScript then return end
        if GameScript:IsActive() then return end

        local Index = net.ReadUInt(MAX_SIZEUINT)
        GameScript:RemoveReward(Index)
    end)

elseif ( CLIENT ) then

    net.Receive("Minigames.AddReward", function()
        local Owner = net.ReadPlayer()
        if not Minigames.ActiveGames[Owner] then return end

        local GameScript = Minigames.GetOwnerGame(Owner)
        local Reward = Minigames.GetReward( net.ReadString() )
        Reward.Index = net.ReadUInt(MAX_SIZEUINT)

        local Amount = net.ReadUInt(MAX_ARGUMENTS)
        for i = 1, Amount do
            Reward:AddValue( net.ReadType() )
        end

        GameScript:AddReward(Reward)
    end)

    net.Receive("Minigames.RemoveReward", function()
        local Owner = net.ReadPlayer()
        if not Minigames.ActiveGames[Owner] then return end

        local GameScript = Minigames.GetOwnerGame(Owner)
        local Index = net.ReadUInt(MAX_SIZEUINT)

        GameScript:RemoveReward(Index)
    end)

    net.Receive("Minigames.ClearRewards", function()
        local Owner = net.ReadPlayer()
        if not Minigames.ActiveGames[Owner] then return end

        local GameScript = Minigames.GetOwnerGame(Owner)
        GameScript:ClearRewards()
    end)

end