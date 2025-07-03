-- This file contains the sales multipliers for different user groups.
-- The multiplier is applied to the final sale price of cigarettes.
-- If a player's user group is not listed here, the default multiplier is 1 (no bonus).

if SERVER then
    CF_RankMultipliers = {
        ["viprehber"] = 1.5,
        ["rp+"] = 2,
        ["silvervip"] = 1.25,
        ["moderator+"] = 1.5,
        ["moderator"] = 1.5,
        ["admin"] = 1.5,
        ["admin+"] = 1.5,
        ["basadmin"] = 1.5,
        ["goldvip"] = 1.35,
        ["platinumvip"] = 1.5,
        ["diamondvip"] = 2,
        ["superadmin"] = 3,
    }

    -- Function to get the sell multiplier for a specific player
    function CF_GetPlayerSellMultiplier(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return 1 end
        
        local userGroup = ply:GetUserGroup()
        
        -- Return the multiplier for the player's group, or 1 if not found
        return CF_RankMultipliers[userGroup] or 1
    end
end