/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

OnePrint.Cfg = {}                           -- DON'T REMOVE/COMMENT THIS LINE !

-- Misc
OnePrint.Cfg.Language = "tr"                -- Script language [en, fr]
OnePrint.Cfg.MaxUsers = 8                   -- Max users that can be added to a printer, 0 will disable the users feature [min = 0, max = 8]
OnePrint.Cfg.ServerLimit = {                -- Max servers per printer (depending on the player usergroup) if the group is not added it'll not be limited [min = 1, max = 6]
    [ "user" ] = 4,
	[ "bronzvip" ] = 4,
	[ "silvervip" ] = 5,
	[ "goldvip" ] = 6,
	[ "platinumvip" ] = 6,
	[ "diamondvip" ] = 6,
	[ "rp+" ] = 6,
	[ "viprehber" ] = 6,
	[ "moderator" ] = 6,
	[ "moderator+" ] = 6,
	[ "admin" ] = 6,
	[ "admin+" ] = 6,
	[ "basadmin" ] = 6,
	[ "superadmin" ] = 6,
	
}

--[[ Which jobs can use printers ]]
OnePrint.Cfg.CanUsePrinter = {
["*"] = true,
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

--[[ 
    - Every {Cfg.MoneyDelay} seconds, the printer will generate {Cfg.ServerIncome X (Amount of servers in the printer)}.
    - If a server is overclocked it will generate {Cfg.ServerIncome X Cfg.OverclockingIncome} every {Cfg.MoneyDelay} seconds
    - The printer won't be able to store more money than {Cfg.ServerStorage X (Amount of servers in the printer)}
]]--
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

-- Money
OnePrint.Cfg.MoneyDelay = 60                 -- Cooldown before the printer generates money
OnePrint.Cfg.ServerIncome = 1600              -- Income per server (for 1 server and without any upgrade)
OnePrint.Cfg.OverclockingIncome = 10        -- % of income added per level of overclocking
OnePrint.Cfg.ServerStorage = 400000          -- Max storage per server

OnePrint.Cfg.CPDestroyReward = 20000         -- Reward a CP for destroying a printer [min = 0]
OnePrint.Cfg.CPRewardSelf = false           -- true: CPs are rewarded if they destroy their own printer
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 34f0f5c25ee43df9204f27becf532270747d889e3165d4c6c31143942f13c884

-- Upgrades/Shop
OnePrint.Cfg.ServerPrice = 8000           -- Server price
OnePrint.Cfg.WatercoolingPrice = 3500        -- Watercooling price
OnePrint.Cfg.PowerPrice = 3500               -- Power price
OnePrint.Cfg.OverclockingPrice = 3500        -- Overclocking price
OnePrint.Cfg.SecurityPrice = 2500            -- Security price (against hacking)
OnePrint.Cfg.DefensePrice = 2000             -- Defense boost price
OnePrint.Cfg.DefenseBoost = 50              -- Max HP added for each boost upgrade bought
OnePrint.Cfg.DefenseMax = 8                 -- Max boosts buyables [min = 1, max = 32]
OnePrint.Cfg.SilencerPrice = 1000            -- Silencer price
OnePrint.Cfg.HackNotifyPrice = 35000         -- Hack notification price
OnePrint.Cfg.LowHPNotifyPrice = 20000        -- Low HP notification price

OnePrint.Cfg.NotifyAllUsers = false         -- true: Notify all printer users on printer hack/low hp, false: Only notify owner on printer hack/low hp

-- Health/Damage
OnePrint.Cfg.MaxHealth = 100                -- Base HP of a printer (without defense upgrades)
OnePrint.Cfg.RepairPrice = 2000             -- Max repair price (if the printer is almost fully destroyed)
OnePrint.Cfg.DamageChance = 80              -- Percentage of chance to take damage if the temperature is too high [min = 0, max = 100]
OnePrint.Cfg.DamageTemperature = 80         -- Temperature on which the printer will start take damage
OnePrint.Cfg.DamageMultiplier = 4           -- The higher this value is, the more damage will be inflicted to the printer in case of overheating
OnePrint.Cfg.TemperatureMultiplier = 2      -- The higher this value is, the faster temperature will increase/decrease
OnePrint.Cfg.CrititalCondition = 50         -- Under this percentage of health, the printer will be condidered as in critical condition [min = 0, max = 99]

-- DarkRP Fire System (ignore if this script isn't installed)
OnePrint.Cfg.FireOnExplosion = true         -- If this is set to true, the printer explosion will create a fire
OnePrint.Cfg.FireChance = 50               -- Percentage of chance that an explosion creates a fire

-- Logs
OnePrint.Cfg.MaxActionsHistory = 10         -- Max entries saved in the actions history [min = 1, max = 10]
OnePrint.Cfg.MaxIncomeHistory = 16          -- Max entries saved in the income history [min = 6, max = 24]
OnePrint.Cfg.IncomeHistoryDelay = 30        -- Next save occurrence in the income history, in seconds [min = 5, max = 3600]

-- Hacking
OnePrint.Cfg.HackingEnabled = true          -- true : Enable the hacking feature, false : Disable
OnePrint.Cfg.HackingOwnedPrinter = false    -- true : Allow players to hack their own printer
OnePrint.Cfg.HackingErrorMargin = 10        -- The higher this value is, the farther your point can be from the target to pass a hacking step (higher = easier) [min = 0, max = 50]
OnePrint.Cfg.HackingSpeedMin = 0.2          -- Min rotation speed for the hacking minigame [min = 0.1, max = 2]
OnePrint.Cfg.HackingSpeedMax = 1.5          -- Max rotation speed for the hacking minigame [min = 0.1, max = 2]
OnePrint.Cfg.HackingSecurityMax = 16        -- Amount of security upgrades buyable on this printer (hacking step needed to unlock) [min = 1, max = 32]
OnePrint.Cfg.HackingJobs = {
-- Whitelist of jobs allowed to hack other players printers. Leave empty to allow all jobs: OnePrint.Cfg.HackingJobs = {}
}

OnePrint.Cfg.CanUpgradeAll = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4c13a57cde97666341e0e2cb8b9997a9bad4b7988015f3aefbac53e57f9ea740

-- UI
OnePrint.Cfg.Colors = {
    [ 0 ] = Color( 22, 23, 27 ),            -- Background
    [ 1 ] = Color( 29, 30, 34 ),            -- Container
    [ 2 ] = Color( 72, 73, 77 ),            -- Highlight
    [ 3 ] = Color( 46, 204, 113 ),          -- Positive
    [ 4 ] = Color( 255, 65, 67 ),           -- Negative
    [ 5 ] = Color( 255, 255, 255 ),         -- Text
    [ 6 ] = Color( 46, 204, 113 ),          -- Main
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

-- Community logo shown on lockscreen (false to disable)
OnePrint.Cfg.CommunityLogo = "https://i.imgur.com/nBH1MMS.jpeg"
