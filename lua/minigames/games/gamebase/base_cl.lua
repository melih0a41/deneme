--[[--------------------------------------------
        Minigame Games Module Client-Side
--------------------------------------------]]--

--[[----------------------------
         Event Functions
----------------------------]]--

function MinigameObject:DrawHUD()
    -- Anything you want to draw on the HUD
end


--[[----------------------------
      Shared Compatibility
----------------------------]]--

function MinigameObject:AddHook() end
function MinigameObject:OnPlayerChanged() end


--[[----------------------------
    All Networking Receivers
----------------------------]]--

net.Receive("Minigames.TogglePlayer", function()
    local PlayerTarget = net.ReadPlayer()
    local Owner = net.ReadPlayer()
    local State = net.ReadBool()

    hook.Run("Minigames.TogglePlayer", PlayerTarget, Owner, State)
end)

net.Receive("Minigames.GameToggle", function()
    local Owner = net.ReadPlayer()
    local GameStarted = net.ReadBool()

    local GameScript = Minigames.GetOwnerGame(Owner)
    if GameScript == nil then
        Minigames.ThrowError("GameScript of Owner is nil", Owner, "MinigameObject", true)
    end

    if GameStarted then
        hook.Run("Minigames.GameStart", Owner, GameScript)
    else
        hook.Run("Minigames.GameStop", Owner, GameScript)
    end
end)