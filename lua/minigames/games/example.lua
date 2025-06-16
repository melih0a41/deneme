--[[--------------------------------------------
                Example Minigame
--------------------------------------------]]--

-- We don't need this game
if true then return end

--[[----------------------------
       Initial Game Config
----------------------------]]--

local GameScript = Minigames.CreateNewGame()

GameScript:SetGameName("Example")

GameScript:AddHeader("Example Header")
--[[
    This adds a header to the setupmenu, you can add as many as you want
    This work in this way:
        GameScript:AddHeader("Example Header")  -> Example Header
        GameScript:AddHeader("#exampleheader")  -> example.header.exampleheader (GameID.header.HeaderName)
        GameScript:AddHeader("!exampleheader")  -> minigames.exampleheader
--]]
GameScript:AddConfig("MyEpicConfig", {
    min = 1,
    max = 20,
    def = 5, -- or you can use "true" to set the default value to the minimum value
    desc = "You can set your own description here or in language.lua"

    -- In language you need to set it in this format:
    --      [ "name_of_the_lua.myepicconfig.desc" ] = "Correct Syntax"
    --      [ "example.myepicconfig.desc" ] = "Correct Syntax"
    --
    -- Invalid synthax:
    --      [ "example.lua.MyEpicConfig.desc"] = "Incorrect Syntax (Invalid Format)"
    --      [ "gungame.MyEpicConfig.desc"] = "Incorrect Syntax (Uppercase Letters)"
})


--[[----------------------------
        Trigger Events
----------------------------]]--

GameScript:AddHook( "PostPlayerDeath", "GetFallDamage" ) -- The player loss when they die in someway or by the fall damage

function GameScript:OnPlayerChanged(ply, Joined) -- Who and if the player joined or left the game
    if not self:IsActive() then return end

    local CurrentPlayers = self:GetPlayers(true)
    if #CurrentPlayers == 1 then
        self:SetPlayerWinner( CurrentPlayers ) -- Win on last player alive
    end
end

--[[----------------------------
          Main Functions
----------------------------]]--

function GameScript:StartGame()
    return Minigames.GameStart( self )
end

function GameScript:StopGame()
    self:RemoveAllPlayers(true) -- Remove all players silently

    return Minigames.GameStop( self )
end

function GameScript:ToggleGame()    -- (Optional)
    local Result = false

    if self:IsActive() then

        Result = self:StopGame()
        self:SetActive(false)

    else

        Result = self:StartGame()
        self:SetActive(true)

    end

    return Result
end

--[[----------------------------
        Action Functions
----------------------------]]--

-- Server-side
function GameScript:LeftClick( trace, owner, FirstTime )
    local Result = true

    return Result -- YOU MUST RETURN THE RESULT!!
end

-- Server-side
function GameScript:RightClick( trace, owner )

end

-- Shared
function GameScript:Reload( trace, owner )

end

-- Shared
function GameScript:Think( trace, owner )

end

-- Shared
function GameScript:Deploy( trace, owner )
    -- This is called when the player deploy our toolgun
end

-- Shared
function GameScript:RollUp( trace, owner )
    --[[----------------------------------------------------
    This is the opposite of deploy, this is called when the
    player roll up our toolgun. This works in any case like:

    - The player has changed their tool mode
    - The player has been killed while is holding the toolgun
    - The player changes their weapon
    ----------------------------------------------------]]-- 
end

-- Client-side
function GameScript:DrawHUD()

end

--[[----------------------------
      Setup Game to server
----------------------------]]--

Minigames.RegisterNewGame(GameScript)