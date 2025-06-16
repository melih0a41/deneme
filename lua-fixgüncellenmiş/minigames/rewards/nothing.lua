local Reward = Minigames.CreateNewReward()

Reward:SetName("Nothing")
Reward:SetNameAmount("Nothing")

Reward:SetFunctionReward(function() end)

Reward:AddArgument({
    ["Name"] = "Nothing",
    ["Type"] = "none"
})

Minigames.RegisterReward(Reward)