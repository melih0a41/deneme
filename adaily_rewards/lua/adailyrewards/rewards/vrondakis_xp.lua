local Reward = {}

Reward.Name = "Vrondakis XP"

Reward.MaxAmount = 1000000

Reward.CanTaskReward = true

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	ply:addXP(amount)
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 1 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

local mat = Material( "adailyrewards/rewards/xp.png", "mips smooth" )
Reward.DrawFunc = function(key)
	return mat
end
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if LevelSystemConfiguration then return true end
	return false
end

ADRewards.CreateReward(Reward)