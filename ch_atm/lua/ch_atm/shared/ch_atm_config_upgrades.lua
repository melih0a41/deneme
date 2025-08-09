--[[
	Bank Account Levels Config
	InterestRate = How much percentage of the players bank account to give in interest rates.
	MaxInterestToEarn = How much can a player maximum earn in interest per interval? Set to 0 to disable the max
	MaxMoney = How much money can the players bank account maximum hold? 0 for unlimited.
	UpgradePrice = How much does it cost the player to upgrade to this level?
	
	NOTE: The first one [ 1 ] is the default level.
--]]
CH_ATM.Config.AccountLevels = {
	[ 1 ] = {
		InterestRate = 0.1,
		MaxInterestToEarn = 10000,
		MaxMoney = 1000000,
		UpgradePrice = 0,
	},
	[ 2 ] = {
		InterestRate = 0.2,
		MaxInterestToEarn = 20000,
		MaxMoney = 2750000,
		UpgradePrice = 50000,
	},
	[ 3 ] = {
		InterestRate = 0.3,
		MaxInterestToEarn = 30000,
		MaxMoney = 3500000,
		UpgradePrice = 100000,
	},
	[ 4 ] = {
		InterestRate = 0.4,
		MaxInterestToEarn = 40000,
		MaxMoney = 5000000,
		UpgradePrice = 200000,
	},
	[ 5 ] = {
		InterestRate = 0.5,
		MaxInterestToEarn = 50000,
		MaxMoney = 6000000,
		UpgradePrice = 300000,
	},
	[ 6 ] = {
		InterestRate = 0.6,
		MaxInterestToEarn = 60000,
		MaxMoney = 8000000,
		UpgradePrice = 400000,
	},
	[ 7 ] = {
		InterestRate = 0.7,
		MaxInterestToEarn = 70000,
		MaxMoney = 10000000,
		UpgradePrice = 500000,
	},
	[ 8 ] = {
		InterestRate = 0.8,
		MaxInterestToEarn = 80000,
		MaxMoney = 15000000,
		UpgradePrice = 600000,
	},
	[ 9 ] = {
		InterestRate = 0.9,
		MaxInterestToEarn = 90000,
		MaxMoney = 20000000,
		UpgradePrice = 700000,
	},
	[ 10 ] = {
		InterestRate = 1.0,
		MaxInterestToEarn = 100000,
		MaxMoney = 0,
		UpgradePrice = 800000,
	},
}