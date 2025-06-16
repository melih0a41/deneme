--[[--------------------------------------------
                 Minigame DarkRP
--------------------------------------------]]--

hook.Add("canArrest", "Minigames.canArrest", function(cop, criminal)
    if Minigames.PlayerIsPlaying(criminal) then
        return false
    end
end)

hook.Add("canBuyAmmo", "Minigames.canBuyAmmo", function(ply, ammo)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canBuyCustomEntity", "Minigames.canBuyCustomEntity", function(ply, ent)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canBuyShipment", "Minigames.canBuyShipment", function(ply, ent)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("PlayerJoinTeam", "Minigames.PlayerJoinTeam", function(ply, team)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

-- Disable battering ram on an user who is currently playing a minigame
hook.Add("canDoorRam", "Minigames.canDoorRam", function(ply, trace, door)
    if not door:isKeysOwned() then return end

    local owner = door:getDoorOwner()

    if Minigames.PlayerIsPlaying(ply) or Minigames.PlayerIsPlaying(owner) then
        return false
    end
end)

hook.Add("canDropPocketItem", "Minigames.canDropPocketItem", function(ply, item)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canDropWeapon", "Minigames.canDropWeapon", function(ply, wep)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canEditLaws", "Minigames.canEditLaws", function(ply, action, args)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canKeysLock", "Minigames.canKeysLock", function(ply, door)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canKeysUnLock", "Minigames.canKeysUnLock", function(ply, door)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canLockpick", "Minigames.canLockpick", function(ply, ent, trace)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end

    if ent:isDoor() and ent:isKeysOwned() then
        local owner = ent:getDoorOwner()

        if Minigames.PlayerIsPlaying(owner) then
            return false
        end
    end
end)

hook.Add("canPocket", "Minigames.canPocket", function(ply, ent)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)

hook.Add("canWanted", "Minigames.canWanted", function(suspect, cop, reason)
    if Minigames.PlayerIsPlaying(suspect) then
        return false
    end
end)

--[[ This hook is not working properly
hook.Add("PlayerCanPickupWeapon", "Minigames.PlayerCanPickupWeapon", function(ply, wep)
    if Minigames.PlayerIsPlaying(ply) then
        return false
    end
end)
--]]



-- Third-party addons compatibility

-- https://www.gmodstore.com/market/view/nlr-spzones-v2
if SPZones then
    hook.Add("Minigames.TogglePlayer", "SPZones.RemoveZone", function(ply, owner, isjoining)
        if isjoining == false then
            SPZones.ClearZones(ply)
        end
    end)
end