VoidCases.Print("Loaded VoidCases built-in currencies!")

-- DarkRP
if (DarkRP) then
    VoidCases.AddCurrency("DarkRP", function (ply)
        return ply:getDarkRPVar("money")
    end, function (ply, money)
        ply:addMoney(money)
    end)
end

--[[
-- BaseWars
if (BaseWars or Basewars or basewars) then
    VoidCases.AddCurrency("Basewars", function (ply)
        return ply:GetMoney()
    end, function (ply, money)
        ply:GiveMoney(money)
    end)
end

-- Nutscript currency
if (nut and nut.currency) then
    VoidCases.AddCurrency("NutScript", function (ply)
        return ply:getChar():getMoney()
    end, function (ply, money)
        ply:getChar():giveMoney(money)
    end)
end

-- Helix currency
if (ix and ix.currency) then
    VoidCases.AddCurrency("Helix", function (ply)
        return ply:GetCharacter():GetMoney()
    end, function (ply, money)
    if (money > 0) then
            ply:GetCharacter():GiveMoney(money)
        else
            ply:GetCharacter():TakeMoney(money)
        end
    end)
end

-- xStore
if (xStore) then
    VoidCases.AddCurrency("xStore", function (ply)
        return (xStore.Users[tostring(ply:SteamID64())] and xStore.Users[tostring(ply:SteamID64())].Points) or 0
    end, function (ply, money)
        xStore.AddPoints(ply, money)
    end)
end

-- Pointshop 1
if (PS) then
    VoidCases.AddCurrency("Pointshop 1", function (ply)
        return ply:PS_GetPoints()
    end, function (ply, money)
        ply:PS_GivePoints(money)
    end)
end

-- Pointshop 2
if (Pointshop2) then
    VoidCases.AddCurrency("Pointshop 2 (Standard)", function (ply)
        return (ply:PS2_GetWallet() and ply:PS2_GetWallet().points ) or 0
    end, function (ply, money)
        ply:PS2_AddStandardPoints( money )
    end)

    VoidCases.AddCurrency("Pointshop 2 (Premium)", function (ply)
        return (ply:PS2_GetWallet() and ply:PS2_GetWallet().premiumPoints ) or 0
    end, function (ply, money)
        ply:PS2_AddPremiumPoints( money )
    end)
end

-- mTokens
if (mTokens) then
    VoidCases.AddCurrency("mTokens", function (ply)
        return mTokens.GetPlayerTokens(ply)
    end, function (ply, money)
        mTokens.AddPlayerTokens(ply, money)
    end)
end

-- Bricks Credit Store
if (BRICKSCREDITSTORE) then
    VoidCases.AddCurrency("Bricks Credits", function (ply)
        return ply:GetBRCS_Credits()
    end, function(ply, money)
        ply:AddBRCS_Credits(money)
    end)
end

-- Pulsar Store
if (Lyth_Pulsar) then
    VoidCases.AddCurrency("Pulsar Credits", function(ply)
        return Lyth_Pulsar.DB.GetCredits(ply:SteamID64(), nil, true)
    end, function(ply, money)
        local currentCredits = Lyth_Pulsar.DB.GetCredits(ply:SteamID64(), _, true)
        Lyth_Pulsar.SetCredits(nil, ply, currentCredits + money)
    end)
end

-- Pulsar Store (another version lol)
if (PulsarStore) then
    VoidCases.AddCurrency("Pulsar Store Credits", function(ply)
        return PulsarStore.API.FetchUserCredits(ply:SteamID64())
    end, function(ply, amount)
        PulsarStore.API.GiveUserCredits(ply:SteamID64(), amount)
        PulsarStore.SendClientData(ply)
    end)
end

-- Onyx Credit store
if (onyx and onyx.creditstore) then
        VoidCases.AddCurrency("Onyx Store Credits", function(ply)
        return onyx.creditstore:GetCredits(ply)
    end, function(ply, amount)
        onyx.creditstore:TakeCredits(ply:SteamID64(), amount)
    end)
end
--]]