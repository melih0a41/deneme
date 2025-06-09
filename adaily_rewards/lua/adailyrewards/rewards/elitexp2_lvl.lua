local Reward = {}

Reward.Name = "EXP2 Lvl"

Reward.MaxAmount = 10000

Reward.CanTaskReward = true

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	local newlvl = EliteXP.GetLevel(ply)+amount
	ply:SetNWInt("Elite_XP", EliteXP.XP(newlvl))
	ply:SetNWInt("Elite_MaxLevelPS2", newlvl)
	EliteXP.LevelUpDown(ply)
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 1 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

local mat = Material( "adailyrewards/rewards/lvl.png", "mips smooth" )
Reward.DrawFunc = function(key)
	return mat
end
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if EliteXP then return true end
	return false
end

ADRewards.CreateReward(Reward)