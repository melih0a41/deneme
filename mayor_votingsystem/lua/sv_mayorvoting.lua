--Mayor Voting System Server - Enhanced Edition
VOTING = {}
VOTING.CurrentCandidates = {}
VOTING.InProgress = false
VOTING.AboutToBegin = false
VOTING.DarkRPSetup = false
VOTING.LastElectionTime = 0

include('sh_votingconfig.lua')
include('sv_votingdata.lua')

-- Network strings
util.AddNetworkString("Voting_NewVote")
util.AddNetworkString("Voting_EndVote")
util.AddNetworkString("Voting_VoteCast")

function VOTING.Setup()
	timer.Simple(2, function()
		if VOTING.Settings.NPCEnabled then
			VOTING.SetupNPC(VOTING.Database.LoadNPC())
		end
		VOTING.SetupDarkRPTeam()
		print("[VOTING] Enhanced Mayor Voting System loaded successfully!")
	end)
end
hook.Add("InitPostEntity", "VOTING_Setup", VOTING.Setup)

-- DarkRP Mayor Team Functions
function VOTING.SetupDarkRPTeam()
	local TEAM
	for k, v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(VOTING.MayorTeamName) then
			TEAM = v
			VOTING.TeamID = k
		end
	end
	
	if not TEAM then 
		ErrorNoHalt("Invalid mayor team: " .. tostring(VOTING.MayorTeamName) .. " incorrect or does not exist!") 
		return false 
	end
	
	VOTING.DarkRPSetup = true
	VOTING.Team = TEAM
	TEAM.vote = false
	TEAM.customCheck = function(ply)
		if ply.VoteWinner then return true end
		if VOTING.OnlyEnterUsingNPC then 
			VOTING.Team.CustomCheckFailMsg = "Polis merkezinde bulunan sekreter ile konusarak secime katilmalisin!"
			return false
		else
			VOTING.Team.CustomCheckFailMsg = "Lutfen baskan adayliginizi onaylayin!"
			SendUserMessage("VOTING_Confirm", ply)
			return false
		end
	end
	TEAM.CustomCheckFailMsg = "Lutfen baskan adayliginizi onaylayin!"
end

function VOTING.CastVote(ply, cmd, args)
	if not IsValid(ply) or not args then return end
	if ply.CastVoteCommand and (ply.CastVoteCommand > CurTime()) then return end
	ply.CastVoteCommand = CurTime() + 3

	if ply.HasVoted then 
		VOTING.SendDarkRPNotice(ply, 1, 4, "Zaten oy kullandiniz!")
		return 
	end
	
	if not VOTING.AllowCandidatesToVote and ply.HasEnteredVoting then 
		VOTING.SendDarkRPNotice(ply, 1, 4, "Uzgunuz, adaylar secimde oy kullanamazlar.") 
		return 
	end

	local candidate = VOTING.CurrentCandidates[tonumber(args[1])]
	if candidate and IsValid(candidate.player) then
		table.insert(candidate.votes, ply)
		ply.HasVoted = true
		
		-- Network message
		net.Start("Voting_VoteCast")
			net.WriteEntity(candidate.player)
			net.WriteEntity(ply)
		net.Send(player.GetAll())
		
		-- Success notification
		VOTING.SendDarkRPNotice(ply, 0, 4, "Oyunuz " .. candidate.player:Nick() .. " icin kaydedildi!")
		
		-- Chat notification
		if VOTING.Settings.ShowVoteTickerUpdates then
			VOTING.ChatNotice(string.format("%s -> %s icin oy kullandi", ply:Nick(), candidate.player:Nick()))
		end
	else 
		VOTING.SendDarkRPNotice(ply, 1, 4, "Bu adaya oy verilemez.") 
	end
end
concommand.Add("mayor_vote", VOTING.CastVote)

function VOTING.EnterMayorVote(ply, cmd, args)
	if ply.NextEnterCommand and (ply.NextEnterCommand > CurTime()) then return end
	ply.NextEnterCommand = CurTime() + 3

	if not VOTING.DarkRPSetup then VOTING.SetupDarkRPTeam() end
	
	-- Cooldown check
	if VOTING.NextElectionAllowed and not (CurTime() >= VOTING.NextElectionAllowed) then
		local timemsg = string.format("Tekrar secime katilmak icin %i dakika beklemelisin!", math.Round((VOTING.NextElectionAllowed - CurTime()) / 60))
		VOTING.SendDarkRPNotice(ply, 1, 4, timemsg)
		return false 
	end
	
	-- Mayor already exists check
	if not VOTING.AllowNewElectionWithMayor then
		for k, v in pairs(player.GetAll()) do
			if v:Team() == VOTING.TeamID then
				VOTING.SendDarkRPNotice(ply, 1, 4, "Zaten secilmis bir baskan var!")
				return false
			end
		end
	end
	
	-- Election in progress check
	if VOTING.InProgress then
		VOTING.SendDarkRPNotice(ply, 1, 4, "Zaten devam eden bir secim var!")
		return false 
	end
	
	-- Already entered check
	if ply.HasEnteredVoting then
		VOTING.SendDarkRPNotice(ply, 1, 4, "Siz zaten bu secime girdiniz.")
		return false 
	end
	
	-- Custom function check
	if VOTING.CanEnterVotingCustomFunction and not VOTING.CanEnterVotingCustomFunction(ply) then
		VOTING.SendDarkRPNotice(ply, 1, 4, VOTING.CustomFunctionFailed)
		return false 
	end
	
	-- Maximum candidates check
	if #VOTING.CurrentCandidates >= VOTING.MaximumCandidates then
		VOTING.SendDarkRPNotice(ply, 1, 4, "Maksimum " .. tostring(VOTING.MaximumCandidates) .. " aday olabilir!")
		return false 
	end
		
	-- Cost check
	if VOTING.CandidateCost and VOTING.CandidateCost > 0 then
		if (ply.CanAfford and not ply:CanAfford(VOTING.CandidateCost)) or (ply.canAfford and not ply:canAfford(VOTING.CandidateCost)) then
			VOTING.SendDarkRPNotice(ply, 1, 4, "Giris masraflarini karsilayamiyorsunuz! (" .. (DarkRP and DarkRP.formatMoney(VOTING.CandidateCost) or VOTING.CandidateCost .. " TL") .. ")")
			return false 
		end
	
		if ply.AddMoney then 
			ply:AddMoney(-VOTING.CandidateCost)
		elseif ply.addMoney then 
			ply:addMoney(-VOTING.CandidateCost) 
		end
	end
	
	-- Enter player into mayor elections
	ply.HasEnteredVoting = true
	table.insert(VOTING.CurrentCandidates, {player = ply, time = CurTime(), votes = {}})
	VOTING.SendDarkRPNotice(ply, 0, 4, "Baskanlik secimlerine girdiniz! Iyi sanslar!")
	
	-- Announcement
	VOTING.ChatNotice(string.format("%s baskanlik secimlerine katildi! (%d/%d)", ply:Nick(), #VOTING.CurrentCandidates, VOTING.MaximumCandidates))

	if VOTING.AboutToBegin then return false end
	
	-- Start election if minimum candidates reached
	if #VOTING.CurrentCandidates >= VOTING.MinimumCandidates then
		VOTING.AboutToBegin = true
		VOTING.ChatNotice("SECIM BASLIYOR! " .. VOTING.Messages.VoteStarting .. " Baslama suresi: " .. tostring(VOTING.AboutToBeginTime) .. " saniye!")
		
		timer.Simple(VOTING.AboutToBeginTime, function()
			if #VOTING.CurrentCandidates < VOTING.MinimumCandidates then
				VOTING.ChatNotice("❌ Yetersiz aday sayısı! Seçim iptal edildi.")
				VOTING.ResetElection()
				return
			end
			
			if VOTING.MinutesUntilNextElection and VOTING.MinutesUntilNextElection > 0 then
				VOTING.NextElectionAllowed = CurTime() + (VOTING.MinutesUntilNextElection * 60)
			end
			
			VOTING.InProgress = true
			VOTING.LastElectionTime = CurTime()
			VOTING.ChatNotice("Oylama basladi! Oyunuzu kullanin! (" .. VOTING.VoteTime .. " saniye)")
			
			net.Start("Voting_NewVote")
				net.WriteTable(VOTING.CurrentCandidates)
			net.Send(player.GetAll())
			
			-- Warning timers
			timer.Simple(VOTING.VoteTime - 30, function()
				if VOTING.InProgress then
					VOTING.ChatNotice("Secim bitimine 30 saniye kaldi!")
				end
			end)
			
			timer.Simple(VOTING.VoteTime - 10, function()
				if VOTING.InProgress then
					VOTING.ChatNotice("" .. VOTING.Messages.VoteEnding)
				end
			end)
			
			timer.Simple(VOTING.VoteTime, VOTING.EndVote)
		end)	
	end
	return false
end
concommand.Add("mayor_vote_enter", VOTING.EnterMayorVote)

function VOTING.EndVote()
	if not VOTING.InProgress then return end
	
	-- Find winner
	local winningvotes = 0
	local candidate
	local tiedCandidates = {}
	
	for k, v in pairs(VOTING.CurrentCandidates) do
		if #v.votes > winningvotes then
			winningvotes = #v.votes
			candidate = v.player
			tiedCandidates = {v}
		elseif #v.votes == winningvotes and winningvotes > 0 then
			table.insert(tiedCandidates, v)
		end
	end
	
	-- Handle tie
	if #tiedCandidates > 1 then
		candidate = tiedCandidates[math.random(1, #tiedCandidates)].player
		VOTING.ChatNotice("Beraberlik! Rastgele secim yapildi.")
	end
	
	if winningvotes == 0 then
		VOTING.ChatNotice("" .. VOTING.Messages.NoVotes)
		net.Start("Voting_EndVote")
		net.Send(player.GetAll())
	elseif IsValid(candidate) then
		net.Start("Voting_EndVote")
			net.WriteEntity(candidate)
		net.Send(player.GetAll())
		
		VOTING.ChatNotice(string.format(VOTING.Messages.Winner, candidate:Nick()))
		
		-- Update player team
		candidate.VoteWinner = true
		
		-- Demote other mayors
		if VOTING.DemoteOtherMayorsOnWin then
			for k, v in pairs(player.GetAll()) do
				if v:Team() == VOTING.TeamID and v ~= candidate then
					if v.ChangeTeam then 
						v:ChangeTeam(TEAM_CITIZEN, true)
					elseif v.changeTeam then 
						v:changeTeam(TEAM_CITIZEN, true) 
					end
					VOTING.SendDarkRPNotice(v, 1, 4, "Yeni baskan secildi, pozisyonunuz degistirildi.")
				end
			end
		end
		
		-- Promote winner
		if candidate.changeTeam then
			candidate:changeTeam(VOTING.TeamID, true)
		elseif candidate.ChangeTeam then
			candidate:ChangeTeam(VOTING.TeamID, true)
		end
		
		-- Winner notification
		VOTING.SendDarkRPNotice(candidate, 0, 8, "Tebrikler! Baskan secildiniz!")
		
		-- Log election results
		print(string.format("[VOTING] Election completed. Winner: %s (%s) with %d votes", candidate:Nick(), candidate:SteamID(), winningvotes))
		
	else
		VOTING.ChatNotice("Kazanan baskan adayi sunucudan ayrildi!")
		net.Start("Voting_EndVote")
		net.Send(player.GetAll())
	end

	VOTING.ResetElection()
end

function VOTING.ResetElection()
	for k, v in pairs(player.GetAll()) do
		if IsValid(v) then 
			v.HasEnteredVoting = nil
			v.HasVoted = nil
			v.VoteWinner = false
		end
	end
	VOTING.AboutToBegin = false
	VOTING.InProgress = false
	VOTING.CurrentCandidates = {}
end

function VOTING.PlayerDeath(vic, wep, kil)
	if IsValid(vic) and VOTING.TeamID == vic:Team() then
		if VOTING.DemoteMayorOnDeath then
			if vic.ChangeTeam then 
				vic:ChangeTeam(TEAM_CITIZEN, true)
			elseif vic.changeTeam then 
				vic:changeTeam(TEAM_CITIZEN, true) 
			end
			
			VOTING.ChatNotice("Baskan olduruldu! Yeni bir baskan secilmeli!")
			
			if VOTING.AllowNewElectionOnDeath then
				VOTING.NextElectionAllowed = nil
			end
		end
	end
end
hook.Add("PlayerDeath", "VOTING_PlayerDeath", VOTING.PlayerDeath)

function VOTING.SendDarkRPNotice(ply, msgtype, len, msg)
	if DarkRP and DarkRP.notify then
		DarkRP.notify(ply, msgtype, len, msg)
	elseif GAMEMODE and GAMEMODE.Notify then
		GAMEMODE:Notify(ply, msgtype, len, msg)
	else
		ply:ChatPrint("[VOTING] " .. msg)
	end
end

function VOTING.ChatNotice(msg, ply)
	if not msg then return end
	if ply and IsValid(ply) then 
		umsg.Start("Voting_ChatNotice", ply)
			umsg.String(msg)
		umsg.End()
	elseif not ply then
		umsg.Start("Voting_ChatNotice")
			umsg.String(msg)
		umsg.End()
	end
end

-- NPC Functions
function VOTING.SetupNPC(pos, ang)
	if pos and ang then
		for k, v in pairs(ents.FindByClass("npc_mayorvoting")) do
			v:Remove()
		end
		
		local npc = ents.Create("npc_mayorvoting")
		npc:SetModel(VOTING.Settings.NPCModel)
		npc:SetPos(pos)
		npc:SetAngles(ang)
		npc:PhysWake()
		npc:Spawn()
		npc:Activate()
		local sequence = npc:LookupSequence(VOTING.Settings.NPCSequence)
		npc:ResetSequence(sequence or 1)
		
		print("[VOTING] NPC spawned at position: " .. tostring(pos))
	end
end

function VOTING.PlaceNPC(ply, cmd, args)
	if ply.NextPlaceNPC and (ply.NextPlaceNPC > CurTime()) then return end
	ply.NextPlaceNPC = CurTime() + 3

	if not VOTING.DarkRPSetup then VOTING.SetupDarkRPTeam() end
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	
	local pos = ply:GetPos()
	local ang = ply:GetAngles()
	VOTING.Database.SaveNPC(pos, ang)
	VOTING.SetupNPC(pos, ang)	
	VOTING.SendDarkRPNotice(ply, 0, 4, "NPC konumunuza yerlestirildi!") 
	ply:ConCommand("noclip")
end
concommand.Add("mayor_vote_placenpc", VOTING.PlaceNPC)

-- Debug Functions
function VOTING.DebugVote(ply, cmd, args)
	if ply.NextDebugVote and (ply.NextDebugVote > CurTime()) then return end
	ply.NextDebugVote = CurTime() + 3

	if not ply:IsSuperAdmin() then return end
	print("Starting mayor system debug...")
	
	VOTING.CurrentCandidates = {}
	VOTING.NextElectionAllowed = nil
	VOTING.InProgress = false
	VOTING.AboutToBegin = false
	
	-- Create bots for testing
	for i = 1, 4, 1 do
		ply:ConCommand("bot")
	end
	
	-- Add all players to election
	timer.Simple(1, function()
		for k, v in pairs(player.GetAll()) do
			if IsValid(v) and v ~= ply then
				v.HasEnteredVoting = false
				VOTING.EnterMayorVote(v, true)
			end
		end
	end)
	
	VOTING.SendDarkRPNotice(ply, 0, 4, "Debug secimi baslatildi!")
end
concommand.Add("mayor_vote_debug", VOTING.DebugVote)

-- Force end election command
function VOTING.ForceEndVote(ply, cmd, args)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	
	if VOTING.InProgress then
		VOTING.EndVote()
		VOTING.SendDarkRPNotice(ply, 0, 4, "Secim zorla sonlandirildi!")
	else
		VOTING.SendDarkRPNotice(ply, 1, 4, "Aktif bir secim yok!")
	end
end
concommand.Add("mayor_vote_forceend", VOTING.ForceEndVote)

-- Reset cooldown command
function VOTING.ResetCooldown(ply, cmd, args)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	
	VOTING.NextElectionAllowed = nil
	VOTING.SendDarkRPNotice(ply, 0, 4, "Secim bekleme suresi sifirlandi!")
end
concommand.Add("mayor_vote_resetcooldown", VOTING.ResetCooldown)

-- Election statistics
function VOTING.GetElectionStats(ply, cmd, args)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	
	local stats = {
		"Secim Istatistikleri:",
		"Current Candidates: " .. #VOTING.CurrentCandidates,
		"Election In Progress: " .. tostring(VOTING.InProgress),
		"About To Begin: " .. tostring(VOTING.AboutToBegin),
		"Last Election: " .. (VOTING.LastElectionTime > 0 and string.FormattedTime(CurTime() - VOTING.LastElectionTime, "%02i:%02i") .. " ago" or "Never"),
		"Next Election Allowed: " .. (VOTING.NextElectionAllowed and string.FormattedTime(VOTING.NextElectionAllowed - CurTime(), "%02i:%02i") or "Now")
	}
	
	for _, stat in ipairs(stats) do
		ply:ChatPrint(stat)
	end
end
concommand.Add("mayor_vote_stats", VOTING.GetElectionStats)

-- Hooks
hook.Add("PostCleanupMap", "VOTING_PostCleanupMap", function()
	if VOTING.Settings.NPCEnabled then
		VOTING.SetupNPC(VOTING.Database.LoadNPC())
	end
end)

hook.Add("canPocket", "VOTING_CantPocketNPC", function(owner, ent)
	if IsValid(ent) and ent:GetClass() == "npc_mayorvoting" then 
		return false, "🚫 You cannot pocket the election NPC!" 
	end
end)

-- Player disconnect handling
hook.Add("PlayerDisconnected", "VOTING_PlayerDisconnect", function(ply)
	-- Remove from candidates if disconnected
	for k, v in pairs(VOTING.CurrentCandidates) do
		if v.player == ply then
			table.remove(VOTING.CurrentCandidates, k)
			VOTING.ChatNotice("📤 " .. ply:Nick() .. " seçimden ayrıldı.")
			
			-- Cancel election if not enough candidates
			if #VOTING.CurrentCandidates < VOTING.MinimumCandidates and (VOTING.InProgress or VOTING.AboutToBegin) then
				VOTING.ChatNotice("❌ Yetersiz aday! Seçim iptal edildi.")
				VOTING.ResetElection()
			end
			break
		end
	end
end)

-- Server shutdown handling
hook.Add("ShutDown", "VOTING_ShutDown", function()
	if VOTING.InProgress then
		print("[VOTING] Server shutting down during election - saving state")
	end
end)

-- Auto-start elections when mayor dies
hook.Add("PlayerDeath", "VOTING_AutoStartOnMayorDeath", function(victim, inflictor, attacker)
	if IsValid(victim) and victim:Team() == VOTING.TeamID then
		if VOTING.AllowNewElectionOnDeath then
			timer.Simple(5, function()
				local hasMayor = false
				for _, v in pairs(player.GetAll()) do
					if v:Team() == VOTING.TeamID then
						hasMayor = true
						break
					end
				end
				
				if not hasMayor and not VOTING.InProgress and not VOTING.AboutToBegin then
					VOTING.ChatNotice("Baskan oldugu icin yeni secim otomatik olarak baslatilabilir!")
				end
			end)
		end
	end
end)

print("[VOTING] Enhanced Mayor Voting System loaded! 🗳️")
print("[VOTING] Available admin commands:")
print("  - mayor_vote_placenpc: Place election NPC")
print("  - mayor_vote_debug: Start debug election")
print("  - mayor_vote_forceend: Force end current election")
print("  - mayor_vote_resetcooldown: Reset election cooldown")
print("  - mayor_vote_stats: Show election statistics")