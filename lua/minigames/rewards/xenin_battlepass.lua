-- Battle Pass
local Pass = Minigames.CreateNewReward()

Pass:SetName("Xenin Battlepass")
Pass:SetNameAmount("Battlepass")
Pass:SetIcon("minigames/icons/xenin_bp_icon.png")

Pass:SetFunctionReward(function(owner, ply)
    RunConsoleCommand( "battlepass_give_pass", ply:SteamID64() )
end)

Minigames.RegisterReward(Pass)


-- Battle Pass Tiers
local Tiers = Minigames.CreateNewReward()

Tiers:SetName("Xenin Battlepass - Tiers")
Tiers:SetNameAmount(function(amount)
    return "Xenin Battlepass Tiers x" .. amount
end)
Tiers:SetIcon("minigames/icons/xenin_bp_icon.png")

Tiers:SetFunctionReward(function(owner, ply, amount)
    RunConsoleCommand( "battlepass_give_tier", ply:SteamID64(), amount )
end)

Tiers:AddArgument({ --> amount
    Name = "Tiers",
    Type = "slider",
    Min = 1,
    Max = 100,
    Default = 1
})

Minigames.RegisterReward(Tiers)