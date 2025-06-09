local Reward = Minigames.CreateNewReward()

Reward:SetName("mTokens")
Reward:SetNameAmount(function(tokens)
    return tokens .. " mTokens"
end)
Reward:SetIcon("minigames/icons/mtokens_icon.png")

Reward:SetFunctionReward(function(owner, ply, tokens)
    RunConsoleCommand("mtokens_givetokens", ply:SteamID64(), tokens)
end)

Reward:AddArgument({ --> Amount
    ["Name"] = "Tokens",
    ["Type"] = "Slider",
    ["Min"] = 1,
    ["Max"] = 300,
    ["Default"] = 50,
})

Minigames.RegisterReward(Reward)