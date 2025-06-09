/*---------------------------------------------------------------------------
							 Anteik Daily Rewards
								Made by Anteik
								 Version 1.2.6
---------------------------------------------------------------------------*/

ADRewards = ADRewards or {}
ADRewards.Rewards = ADRewards.Rewards or {}
ADRewards.Tasks = ADRewards.Tasks or {}
ADRewards.Themes = ADRewards.Themes or {}
ADRewards.Config = ADRewards.Config or {}
ADRewards.RewardsQueue = ADRewards.RewardsQueue or {}
ADRewards.TasksQueue = ADRewards.TasksQueue or {}
/*---------------------------------------------------------------------------
------------------------------------CONFIG-----------------------------------
---------------------------------------------------------------------------*/
ADRewards.Config.ForceLanguage = false -- Set false to match the language to the users game language. Or use language codes to force language selection: "en", "uk", "ru", "fr", "de", "pl", "es-ES", "tr"

ADRewards.Config.KEY = false-- Button to show the emoji circle. List of buttons: https://wiki.facepunch.com/gmod/Enums/KEY . Or false to disable

ADRewards.Config.OpenJoin = true -- Open menu when a player joins the server

ADRewards.Config.AutoRewardClaim = false -- Whether the reward is automatically given out or the player has to collect it himself

ADRewards.Config.TasksForClaim = false -- Does the player need to complete all the tasks for the day to get the reward? If false and there is no task reward, disables daily tasks

ADRewards.Config.PremiumURL = "https://discord.gg/basodark" -- Which link opens when you click the "Premium" button

ADRewards.Config.Admins = { -- Who can use administrator commands
	["superadmin"] = true,
}

ADRewards.Config.PremiumGropus = { -- Which user groups are considered premium automatically
	["superadmin"] = true,
}

ADRewards.Config.DisabledTasks = { -- You can disable the task module if you set it to true
	--["KillNPC"] = true,
}





//------------------------------------------------//
//--DONT TOUCH IF YOU DONT KNOW WHAT YOURE DOING--//
//------------------------------------------------//
ADRewards.Config.TaskBit = 10 -- Number of bits for transmitting task status data. https://wiki.facepunch.com/gmod/net.WriteUInt
