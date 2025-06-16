local AShopNormal = Minigames.CreateNewReward()

AShopNormal:SetName("AShop Coins")
AShopNormal:SetIcon("minigames/icons/ashop.png")
AShopNormal:SetNameAmount(function(amount)
    return "AShop Coins x" .. amount
end)

AShopNormal:SetFunctionReward(function(owner, ply, amount)
    if ashop then
        ply:ashop_addCoinsSafe(amount, false)
    end
end)

AShopNormal:AddArgument({
    Name = "Amount",
    Type = "Slider",
    Min = 1,
    Max = 200,
    Default = 10
})

Minigames.RegisterReward(AShopNormal)


local AShopPremium = Minigames.CreateNewReward()

AShopPremium:SetName("AShop Premium Coins")
AShopPremium:SetIcon("minigames/icons/ashop.png")
AShopPremium:SetNameAmount(function(amount)
    return "AShop Premium Coins x" .. amount
end)

-- Function Reward
AShopPremium:SetFunctionReward(function(owner, ply, amount)
    if ashop then
        ply:ashop_addCoinsSafe(amount, true)
    end
end)

AShopPremium:AddArgument({
    Name = "Amount",
    Type = "Slider",
    Min = 1,
    Max = 200,
    Default = 10
})

Minigames.RegisterReward(AShopPremium)