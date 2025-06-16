local Reward = Minigames.CreateNewReward()

Reward:SetName("[ULX] Give usergroup")
Reward:SetNameAmount(function(usergroup)
    return "rank " .. usergroup
end)

Reward:SetIcon("minigames/icons/ulx_rank.png")

Reward:SetFunctionReward(function(owner, ply, usergroup)
    -- This prevents the event owner to give a rank higher than his own
    owner:ConCommand("ulx adduserid " .. ply:SteamID() .. " " .. usergroup)
end)

local Ranks = {}
if ULib then
    for rank, _ in pairs( ULib.ucl.groups ) do
        table.insert(Ranks, rank)
    end
else
    table.insert(Ranks, "user")
    table.insert(Ranks, "admin")
    table.insert(Ranks, "superadmin")
end

Reward:AddArgument({ --> usergroup
    ["Name"] = "Usergroup",
    ["Type"] = "List",
    ["Options"] = Ranks,
    ["Default"] = "user"
})

Minigames.RegisterReward(Reward)