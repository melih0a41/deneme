local Reward = Minigames.CreateNewReward()

Reward:SetName("Weapon")
Reward:SetNameAmount(function(classname)
    local wpns = weapons.GetList()
    for k, v in ipairs(wpns) do
        if v.ClassName == classname then
            return v.PrintName
        end
    end

    return classname
end)

Reward:SetIcon("icon16/gun.png")

Reward:SetFunctionReward(function(owner, ply, classname)
    local wpn = ply:Give(classname)
    if IsValid(wpn) then
        ply:SetActiveWeapon( wpn )
    end
end)

Reward:AddArgument({ --> classname
    ["Name"] = "Weapon",
    ["Type"] = "Text",
    ["Default"] = "weapon_crowbar",
    ["Placeholder"] = "The weapon's classname"
})

Minigames.RegisterReward(Reward)