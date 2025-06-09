local Reward = Minigames.CreateNewReward()

Reward:SetName("VoidCases")
Reward:SetNameAmount(function(item, amount)
    return amount .. " cases of Case ID(" .. item .. ")"
end)
Reward:SetIcon("minigames/icons/voidcases_icon.png")

Reward:SetFunctionReward(function(owner, ply, item, amount)
    if not isnumber(amount) then amount = 1 end

    RunConsoleCommand("voidcases_giveitem", ply:SteamID64(), item, amount)
end)

Reward:AddArgument({ --> item
    Name = "Item",
    Type = "text",
    Default = "1",
    Placeholder = "Item ID",
    Numeric = true
})

Reward:AddArgument({ --> amount
    Name = "Amount",
    Type = "slider",
    Min = 1,
    Max = 15,
    Default = 1
})

Minigames.RegisterReward(Reward)