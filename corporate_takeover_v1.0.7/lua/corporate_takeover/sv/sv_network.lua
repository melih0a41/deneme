-- General
util.AddNetworkString("cto_CreateCorp")
util.AddNetworkString("cto_sync")
util.AddNetworkString("cto_MoneyAction")
util.AddNetworkString("cto_BuyItem")
util.AddNetworkString("cto_AddMoneyToCorp")

-- Vault
util.AddNetworkString("cto_OpenVaultMenu")
util.AddNetworkString("cto_ExpandVault")
util.AddNetworkString("cto_ToggleVaultDoor")

-- Worker
util.AddNetworkString("cto_WorkerSelection")
util.AddNetworkString("cto_WorkerManagement")
util.AddNetworkString("cto_openWorkerMenu")

-- Desk
util.AddNetworkString("cto_OpenDeskBuilder")
util.AddNetworkString("cto_OpenDeskBuilderMenu")
util.AddNetworkString("cto_dismantleDesk")
util.AddNetworkString("cto_deskPlacement")
util.AddNetworkString("cto_sellDesk")

-- Research
util.AddNetworkString("cto_openResearcher")
util.AddNetworkString("cto_startResearch")

// Netspam protection
function Corporate_Takeover:NetCooldown(ply)
	ply.CTO_NetMSG = ply.CTO_NetMSG or 0

	if ply.CTO_NetMSG < CurTime() then
		ply.CTO_NetMSG = CurTime() + 0.5
		return true
	end

	return false
end

// Sync data to everybody
function Corporate_Takeover:SyncCorps()
	local compressed = util.Compress(util.TableToJSON(Corporate_Takeover.Corps))
	local len = #compressed

	net.Start("cto_sync")
		net.WriteUInt(1, 5) -- Sync Corps
		net.WriteUInt(len, 32)
		net.WriteData(compressed, len)
	net.Broadcast()
end

function Corporate_Takeover:SyncCorp(CorpID)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		local compressed = util.Compress(util.TableToJSON(Corp))
		local len = #compressed

		net.Start("cto_sync")
			net.WriteUInt(2, 5) -- Sync Corp
			net.WriteUInt(CorpID, 8)
			net.WriteUInt(len, 32)
			net.WriteData(compressed, len)
		net.Broadcast()
	end
end

function Corporate_Takeover:SyncMoneyAndLevel(CorpID)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		net.Start("cto_sync")
			net.WriteUInt(3, 5) -- Sync Money and Level
			net.WriteUInt(CorpID, 8)
			net.WriteInt(Corp.money, 32)
			net.WriteUInt(Corp.maxMoney, 32)
			net.WriteUInt(Corp.level, 5)
			net.WriteUInt(Corp.xp, 32)
			net.WriteUInt(Corp.xpNeeded, 32)
		net.Broadcast()
	end
end

function Corporate_Takeover:SyncDesks(CorpID)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		local owner = player.GetBySteamID(Corp.owner)
		if(owner) then
			local compressed = util.Compress(util.TableToJSON(Corp.desks))
			local len = #compressed

			net.Start("cto_sync")
				net.WriteUInt(4, 5) -- Sync Desks
				net.WriteUInt(CorpID, 8)
				net.WriteUInt(len, 32)
				net.WriteData(compressed, len)
			net.Send(owner)
		end
	end
end

function Corporate_Takeover:SyncWorkers(CorpID)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		local owner = player.GetBySteamID(Corp.owner)
		if(owner) then
			local compressed = util.Compress(util.TableToJSON(Corporate_Takeover.Corps[CorpID].workers))
			local len = #compressed

			net.Start("cto_sync")
				net.WriteUInt(5, 5) -- Sync Workers
				net.WriteUInt(CorpID, 8)
				net.WriteUInt(len, 32)
				net.WriteData(compressed, len)
			net.Send(owner)
		end
	end
end

function Corporate_Takeover:SyncResearches(CorpID)
	local Corp = self:GetData(CorpID)
	if(Corp) then
		local owner = player.GetBySteamID(Corp.owner)
		if(owner) then
			local compressed = util.Compress(util.TableToJSON(Corporate_Takeover.Corps[CorpID].researches))
			local len = #compressed

			net.Start("cto_sync")
				net.WriteUInt(6, 5) -- Sync Researches
				net.WriteUInt(CorpID, 8)
				net.WriteUInt(len, 32)
				net.WriteData(compressed, len)
			net.Send(owner)
		end
	end
end

// Send Corps to newly connected player
hook.Add("PlayerInitialSpawn", "CTO_SyncCorpsOnSpawn", function(ply)
	Corporate_Takeover.InitialSpawnCache[ply] = true
end)
hook.Add("SetupMove", "CTO_SyncCorpsOnNetReady", function(ply, _, cmd)
	if Corporate_Takeover.InitialSpawnCache[ply] and not cmd:IsForced() then
		Corporate_Takeover.InitialSpawnCache[ply] = nil

		local compressed = util.Compress(util.TableToJSON(Corporate_Takeover.Corps))
		local len = #compressed

		net.Start("cto_sync")
			net.WriteUInt(1, 5) -- Sync Corps
			net.WriteUInt(len, 32)
			net.WriteData(compressed, len)
		net.Send(ply)
	end
end)