util.AddNetworkString("VoidCases_NotifyPlayer")


hook.Add("PlayerSay", "VoidCases.PlayerCommand", function (ply, text)
    if (!VoidCases.HasTLoaded) then return end
    if (string.lower(text) == VoidCases.Config.MenuCommand or string.lower(text) == "!voidcases") then
        ply:ConCommand("voidcases")
    end
end)
