local Reward = Minigames.CreateNewReward()

Reward:SetName("Brick's Credit Store")
Reward:SetNameAmount(function(credits)
    return credits .. " Credits"
end)
Reward:SetIcon("minigames/icons/brick_icon.png")

Reward:SetFunctionReward(function(owner, ply, credits)
    RunConsoleCommand("addcredits", ply:SteamID64(), credits)
end)

Reward:AddArgument({ --> credits
    ["Name"] = "Credits",
    ["Type"] = "Slider",
    ["Default"] = 20,
    ["Min"] = 0,
    ["Max"] = 250,
})

Minigames.RegisterReward(Reward)