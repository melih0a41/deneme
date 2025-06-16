--[[--------------------------------------------
            Minigame Module - Bots
--------------------------------------------]]--

MinigameObject.__Bots = {}

--[[----------------------------
          Bot Functions
----------------------------]]--

function MinigameObject:AddBot()
    local Bot = self:CreateEntity("minigame_npc", "Bots")
    Bot:Spawn()
    Bot.LookUncannyToPlayers = false

    table.insert(self.__Bots, Bot)

    return Bot
end

function MinigameObject:RemoveBot(Bot, Silent)
    self:Checker(Bot, "entity", 1)

    hook.Run("Minigames.PostBotDeath", Bot, self:GetOwner())

    if not Silent then
        self:OnPlayerChanged(Bot, false)
    end

    Bot:Remove()
end

function MinigameObject:IsBot(Bot)
    return IsValid(Bot) and Bot:GetClass() == "minigame_npc"
end

MinigameObject.BotExists = MinigameObject.IsBot

function MinigameObject:GetAllBots()
    return self.__Bots
end

function MinigameObject:RemoveAllBots(Silent)
    for Index, Bot in pairs(self.__Bots) do
        if not IsValid(Bot) then continue end

        hook.Run("Minigames.PostBotDeath", Bot, self:GetOwner())

        if not Silent then
            self:OnPlayerChanged(Bot, false)
        end

        Bot:Remove()
    end

    self.__Bots = {}
    self.__EntitiesAlias["Bots"] = {}
end


--[[----------------------------
        Global Functions
----------------------------]]--

function Minigames.IsBot(Bot)
    Minigames.Checker(Bot, "entity", 1)

    if Bot:GetClass() ~= "minigame_npc" then return false, nil end

    local Owner = Bot:Getowning_ent()
    if not IsValid(Owner) then return true, nil end

    return Minigames.GetOwnerGame(Owner):IsBot(Bot), Owner
end