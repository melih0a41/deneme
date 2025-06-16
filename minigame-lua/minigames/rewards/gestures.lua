local Reward = Minigames.CreateNewReward()

Reward:SetName("Gestures")
Reward:SetNameAmount("Gesture")
Reward:SetIcon("minigames/icons/gestures_icon.png")

Reward:SetFunctionReward(function(owner, ply, gesture)
    RunConsoleCommand("inc_gestures_give", ply:SteamID(), gesture)
end)

Reward:AddArgument({ --> gesture
    ["Name"] = "Gesture ID",
    ["Type"] = "Text",
    ["Default"] = 1,
    ["Placeholder"] = "Gesture ID"
})

Minigames.RegisterReward(Reward)