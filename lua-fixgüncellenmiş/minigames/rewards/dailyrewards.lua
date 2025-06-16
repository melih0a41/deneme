local Reward = Minigames.CreateNewReward()

Reward:SetName("Daily Rewards")
Reward:SetNameAmount("Daily Rewards Premium")
Reward:SetIcon("minigames/icons/dailyrewards.png")

Reward:SetFunctionReward(function(owner, ply, season)
    RunConsoleCommand( "dailyrewards_giveprem", ply:SteamID64(), season )
end)

Reward:AddArgument({
    ["Name"] = "Season",
    ["Type"] = "Text",
    ["Default"] = "season1",
    ["Placeholder"] = "The season name"
})

Minigames.RegisterReward(Reward)