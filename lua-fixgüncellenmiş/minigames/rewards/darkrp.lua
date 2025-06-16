local Reward = Minigames.CreateNewReward()

Reward:SetName("DarkRP Money")
Reward:SetNameAmount(function(amount)
    return "$" .. string.Comma( amount )
end)
Reward:SetIcon("icon16/money.png")

Reward:SetFunctionReward(function(owner, ply, amount)
    local money = isnumber( amount ) and math.Round( amount, 0 ) or 0

    owner:ConCommand("darkrp addmoney " .. ply:Nick() .. " " .. money)
end)

Reward:SetEnabled(function()
    return DarkRP and DarkRP.createMoneyBag
end)

Reward:AddArgument({ --> Amount
    ["Name"] = "Money",
    ["Type"] = "Text",
    ["Default"] = 10000,
    ["Placeholder"] = "$10000",
    ["Numeric"] = true
})

Minigames.RegisterReward(Reward)