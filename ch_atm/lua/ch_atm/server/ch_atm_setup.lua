-- Workshop content
resource.AddWorkshop( "2742214519" )

-- Network strings
util.AddNetworkString( "CH_ATM_Net_ChangeATMColor" )
util.AddNetworkString( "CH_ATM_Net_InitializeScreen" )
util.AddNetworkString( "CH_ATM_Net_ATMInUseBy" )
util.AddNetworkString( "CH_ATM_Net_InsertCreditCard" )
util.AddNetworkString( "CH_ATM_Net_PullOutCreditCard" )

util.AddNetworkString( "CH_ATM_Net_NetworkBankAccount" )
util.AddNetworkString( "CH_ATM_Net_NetworkTransactions" )
util.AddNetworkString( "CH_ATM_Net_NetworkInterestRate" )

util.AddNetworkString( "CH_ATM_Net_DepositMoney" )
util.AddNetworkString( "CH_ATM_Net_WithdrawMoney" )
util.AddNetworkString( "CH_ATM_Net_SendMoney" )
util.AddNetworkString( "CH_ATM_Net_SendMoneyOffline" )

util.AddNetworkString( "CH_ATM_Net_UpgradeBankAccountLevel" )

util.AddNetworkString( "CH_ATM_Net_RestartHackCooldownTimer" )

util.AddNetworkString( "CH_ATM_Net_CardScanner_IsReadyToScan" )
util.AddNetworkString( "CH_ATM_Net_CardScanner_UpdatePrice" )

util.AddNetworkString( "CH_ATM_Net_AdminMenu" )
util.AddNetworkString( "CH_ATM_Net_AdminViewPlayer" )
util.AddNetworkString( "CH_ATM_Net_AdminViewPlayerMenu" )
util.AddNetworkString( "CH_ATM_Net_AdminGiveMoney" )
util.AddNetworkString( "CH_ATM_Net_AdminTakeMoney" )
util.AddNetworkString( "CH_ATM_Net_AdminResetAccountLevel" )
util.AddNetworkString( "CH_ATM_Net_AdminResetAllAccounts" )
util.AddNetworkString( "CH_ATM_Net_AdminATMEmergencyLockdown" )

util.AddNetworkString( "CH_ATM_Net_AdminShowOfflineAccount" )
util.AddNetworkString( "CH_ATM_Net_AdminCheckOfflineAccount" )
util.AddNetworkString( "CH_ATM_Net_AdminUpdateOfflineAccount" )

util.AddNetworkString( "CH_ATM_Net_ConvertAccountsFromSlownLS" )
util.AddNetworkString( "CH_ATM_Net_ConvertAccountsFromBlueATM" )
util.AddNetworkString( "CH_ATM_Net_ConvertAccountsFromBetterBanking" )
util.AddNetworkString( "CH_ATM_Net_ConvertAccountsFromGlorifiedBanking" )

util.AddNetworkString( "CH_ATM_Net_HUDPaintLoad" )

util.AddNetworkString( "CH_ATM_Net_NetworkLeaderboard" )

local map = string.lower( game.GetMap() )

--[[
	Initialize our serverside directories
--]]
local function CH_ATM_InitDirectories()
	if not file.IsDir( "craphead_scripts", "DATA" ) then
		file.CreateDir( "craphead_scripts", "DATA" )
	end

	if not file.IsDir( "craphead_scripts/ch_atm", "DATA" ) then
		file.CreateDir( "craphead_scripts/ch_atm", "DATA" )
	end
	
	if not file.IsDir( "craphead_scripts/ch_atm/entities", "DATA" ) then
		file.CreateDir( "craphead_scripts/ch_atm/entities", "DATA" )
	end
	
	if not file.IsDir( "craphead_scripts/ch_atm/entities/".. map, "DATA" ) then
		file.CreateDir( "craphead_scripts/ch_atm/entities/".. map, "DATA" )
	end
	
	if not file.IsDir( "craphead_scripts/ch_atm/entities/".. map .."/atm", "DATA" ) then
		file.CreateDir( "craphead_scripts/ch_atm/entities/".. map .."/atm", "DATA" )
	end
	
	if not file.IsDir( "craphead_scripts/ch_atm/entities/".. map .."/leaderboards", "DATA" ) then
		file.CreateDir( "craphead_scripts/ch_atm/entities/".. map .."/leaderboards", "DATA" )
	end
	
	-- ATM Entities
	CH_ATM.SpawnEntities()
end

--[[
	Initialize the addon
--]]
local function CH_ATM_Initialize()
	-- Setup Directories
	CH_ATM_InitDirectories()
end
hook.Add( "InitPostEntity", "CH_ATM_Initialize", CH_ATM_Initialize )

--[[
	Spawn entities
--]]
local function CH_ATM_PostCleanupMap()
	-- ATM Entities
	CH_ATM.SpawnEntities()
end
hook.Add( "PostCleanupMap", "CH_ATM_PostCleanupMap", CH_ATM_PostCleanupMap )