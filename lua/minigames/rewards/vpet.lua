local Reward = Minigames.CreateNewReward()

Reward:SetName("VPet")
Reward:SetNameAmount(function(petname)
    return petname
end)

Reward:SetIcon("minigames/icons/vpet.png")

Reward:SetFunctionReward(function(owner, ply, petname)
    RunConsoleCommand("add_pet", ply:SteamID64(), petname)
end)

Reward:AddArgument({
    ["Name"] = "Pet",
    ["Type"] = "Text",
    ["Default"] = "Dog",
    ["Placeholder"] = "The pet's name"
})

Minigames.RegisterReward(Reward)