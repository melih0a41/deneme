local Reward = Minigames.CreateNewReward()

Reward:SetName("Magic Wand Rewrite")
Reward:SetNameAmount(function(item)
    return "The spell \"" .. item .. "\""
end)
Reward:SetIcon("minigames/icons/hwprewrite_icon.png")

Reward:SetFunctionReward(function(owner, ply, spell)
    if HpwRewrite then
        HpwRewrite:SaveAndGiveSpell(ply, spell)
    end
end)

Reward:AddArgument({ --> spell
    ["Name"] = "Spell",
    ["Type"] = "Text",
    ["Default"] = "hpw_reducto",
    ["Placeholder"] = "Spell name"
})

--[[
local Spells = {}
for spell, value in pairs( HpwRewrite:GetSpells() ) do
    Spells[spell] = string.Replace(spell, " ", "_")
end

Reward:AddArgument({
    Options = Spells,
    Convert = function(v) return v end
})
--]]

Minigames.RegisterReward(Reward)