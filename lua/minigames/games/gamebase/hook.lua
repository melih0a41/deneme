--[[--------------------------------------------
            Minigame Module - Hook
--------------------------------------------]]--

MinigameObject.__Hooks = {}

--[[----------------------------
         Hook Functions
----------------------------]]--

function MinigameObject:AddHook(...)
    for _, HookName in ipairs({...}) do
        self:Checker(HookName, "string", 1)

        if not Minigames.Enum[HookName] then
            self.ThrowError("The hook " .. HookName .. " does not exist.")
        end

        local HookAlias, HookSubName = string.Split( HookName, " " )[1], string.Split( HookName, " " )[2]
        local FullHook = string.Trim( "Minigames." .. self:GetGameID() .. "." .. self:GetOwnerID() .. ( HookAlias ~= nil and "." .. HookAlias or "" ) )

        table.insert(self.__Hooks, {
            ["Name"] = HookSubName or HookAlias,
            ["FullName"] = FullHook,
            ["Function"] = Minigames.Enum[HookName]
        })
    end
end

function MinigameObject:GenerateHooks()
    for _, HookData in ipairs(self.__Hooks) do
        hook.Add(HookData["Name"], HookData["FullName"], HookData["Function"])
    end
end

function MinigameObject:RemoveHooks()
    for _, HookData in ipairs(self.__Hooks) do
        hook.Remove(HookData["Name"], HookData["FullName"])
    end
end

--[[----------------------------
          Custom Hooks
----------------------------]]--

hook.Add("Minigames.GameStart", "Minigames.StripWeaponsOwner", function(Owner, GameScript)
    if GameScript:GetPlayer(Owner) ~= nil and Minigames.Config["StripWeaponsOnGame"] then
        Owner:StripWeapons()
    end
end)