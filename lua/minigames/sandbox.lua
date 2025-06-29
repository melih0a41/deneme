--[[--------------------------------------------
                Minigame Sandbox
--------------------------------------------]]--

local function AllowToSpawn(ply)
    local GameScript = Minigames.GetOwnerGame(ply)
    if not GameScript then return false end

    if GameScript:IsActive() and GameScript:HasPlayer(ply) then
        return false
    end

    return true
end

hook.Add("PlayerSpawnObject", "Minigames.PlayerSpawnObject", function(ply, model, skin)
    if AllowToSpawn(ply) then
        return true
    end

    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)