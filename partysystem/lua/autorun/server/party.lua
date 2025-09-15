-- Dosya: lua/autorun/server/party.lua
-- 20 dakika minimum kalma süresi eklendi

parties = {}
PartyJoinTimes = PartyJoinTimes or {} -- Parti katılım zamanları

-- DevNote 225
if party.DarkrpGamemode then
	timer.Simple(1, function()
		for k, v in pairs (party.AutoGroupedJobs) do
			parties[k] = {}  
			parties[k].members = {}
			if party.AutoGroupedJobs[k].Name then
				parties[k].name = party.AutoGroupedJobs[k].Name
			else
				parties[k].name = team.GetName(party.AutoGroupedJobs[k]["Jobs"][1])
			end
			parties[k].Autogrouped = true
		end
	end)
end

local meta = FindMetaTable("Player")
  
util.AddNetworkString("party") 
util.AddNetworkString("partiesmenu")
util.AddNetworkString("joinrequest")
util.AddNetworkString("partyinvite")
util.AddNetworkString("onepartytoparty")
util.AddNetworkString("oneparty")
util.AddNetworkString("PartyLeaveTimeInfo") -- Yeni: Kalan süre bildirimi

-- ============================
-- PARTİ KATILIM ZAMANI FONKSİYONLARI
-- ============================
function SetPartyJoinTime(ply, partyID)
    if not IsValid(ply) or not partyID then return end
    
    local steamID = ply:SteamID64()
    PartyJoinTimes[steamID] = {
        partyID = partyID,
        joinTime = CurTime(),
        canLeaveTime = CurTime() + (party.MinimumStayTime or 1200) -- 20 dakika varsayılan
    }
    
    -- Oyuncuya bilgi ver
    local minutes = (party.MinimumStayTime or 1200) / 60
    ply:ChatPrint("Partiye katıldınız! En az " .. minutes .. " dakika partide kalmalısınız.")
    
    -- Client'a bilgi gönder
    net.Start("PartyLeaveTimeInfo")
        net.WriteFloat(PartyJoinTimes[steamID].canLeaveTime)
    net.Send(ply)
end

function CanPlayerLeaveParty(ply)
    if not IsValid(ply) then return false, "Geçersiz oyuncu!" end
    
    local steamID = ply:SteamID64()
    local joinData = PartyJoinTimes[steamID]
    
    -- Hiç parti verisi yoksa çıkabilir
    if not joinData then return true, "OK" end
    
    -- Admin kontrolü - adminler hemen çıkabilir
    if ply:IsAdmin() or ply:IsSuperAdmin() or table.HasValue(party.Admins, ply:GetUserGroup()) or table.HasValue(party.SteamIDAdmins, steamID) then
        return true, "Admin bypass"
    end
    
    -- Parti lideri kendi partisinden hemen çıkabilir
    if ply:GetParty() == steamID then
        return true, "Party leader"
    end
    
    -- Zaman kontrolü
    local timeLeft = joinData.canLeaveTime - CurTime()
    if timeLeft > 0 then
        local minutesLeft = math.ceil(timeLeft / 60)
        return false, "Partiden ayrılmak için " .. minutesLeft .. " dakika daha beklemelisiniz!"
    end
    
    return true, "OK"
end

function ClearPartyJoinTime(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    PartyJoinTimes[steamID] = nil
end

-- ============================
-- MEVCUT FONKSİYONLAR
-- ============================
function sendpartiestocl(ply)
	local ply = ply
	if istable(ply) then
		local plytab = {}
		for v,k in pairs(ply)do
			table.insert(plytab, player.GetBySteamID64(k))
		end
		ply = plytab
	end
	net.Start("party")
	net.WriteTable(parties)
	net.Send(ply)
end

function sendonepartiestocl(party, ply)
	net.Start("oneparty")
		net.WriteString(party)
		if parties[party] then
			net.WriteTable(parties[party])
		else
			net.WriteTable({name = "DeleteMe"}) 
		end
		net.Send(ply)
end

function SendOnePartyToEveryone(party)
	for v,k in pairs(player.GetAll()) do
		sendonepartiestocl(party , k)
	end
end

function sendonepartiestoparty(party)
	SendOnePartyToEveryone(party)
	if parties[party] != nil then
		local plytab = {}
		for v,k in pairs(parties[party].members)do
			table.insert(plytab, player.GetBySteamID64(k))
		end
		net.Start("onepartytoparty")
		net.WriteString(party)
		net.WriteTable(parties[party])
		net.Send(plytab)					
	end
end

function openpartymenu( ply, text )
	if (text == party.chatcommand )then
		net.Start("partiesmenu", ply)
		net.Send(ply)
		sendpartiestocl(ply)
		return ""
	end
end
hook.Add( "PlayerSay", "openpartymenu", openpartymenu )

function meta:Startparty(name)
	local CanJoin = hook.Call( "CanJoinParty" ,nil , self, self:SteamID64()  )
	if CanJoin != false then
			self:LeaveParty()
			parties[self:SteamID64()] = {}
			parties[self:SteamID64()].members = {self:SteamID64()}
			if name != "" then
				parties[self:SteamID64()].name = string.Left( name , 20 )
			else
				parties[self:SteamID64()].name = self:Nick()
			end
			sendonepartiestoparty(self:SteamID64())
			self.invitedcheck = {}
			self.invited = {}
			
			-- Parti kurucusu için zaman kaydını temizle (kendi partisinden hemen çıkabilir)
			ClearPartyJoinTime(self)
			
			hook.Run("SPSStartParty", self, parties[self:SteamID64()] )
	end
end

util.AddNetworkString( "StartParty" )

net.Receive( "StartParty", function( len, ply )
	if ply.NextRequest == nil then 
		ply.NextRequest = 0
	end
	
	if ( ply.NextRequest < CurTime() ) then
		ply.NextRequest = CurTime() + party.joinrequestcooldown
		local name = net.ReadString()	
		ply:Startparty(name)
	end
end )

function meta:joinparty(jointheparty)
	local CanJoin = hook.Call( "CanJoinParty" ,nil , self, jointheparty  )
	if CanJoin then
		self:LeaveParty()
		for v, k in pairs(parties) do
			if v != self:SteamID64() then
				if self:GetParty() == v then
					self:LeaveParty()
				end
			end
		end
		if !table.HasValue(jointheparty.members , self:SteamID64()) then
			if (table.Count(jointheparty.members) < party.maxplayers) or jointheparty.Autogrouped then
				table.insert(jointheparty.members, self:SteamID64())
				
				-- Katılım zamanını kaydet
				local partyID = nil
				for id, pData in pairs(parties) do
					if pData == jointheparty then
						partyID = id
						break
					end
				end
				if partyID then
					SetPartyJoinTime(self, partyID)
				end
				
				hook.Run("SPSJoinParty", self, jointheparty )
				sendonepartiestoparty(self:GetParty())
			else
				self:ChatPrint( party.language["Maximum number of players in this party."].." (" .. party.maxplayers .. ")" )	
			end
		end
	else
		self:ChatPrint( party.language["You are not allowed to join this party."])
	end
end

function meta:requestjoin(steam64)
	local CanJoin = hook.Call( "CanJoinParty" ,nil , self, steam64  )
	if CanJoin != false then
		self.requestedtojoin = steam64
		if self.NextRequest == nil then 
			self.NextRequest = 0
		end
		if ( self.NextRequest < CurTime() ) then
			self.NextRequest = CurTime() + party.joinrequestcooldown
			for v, k in pairs(parties) do
				if v == steam64 then
					net.Start("joinrequest")
					net.WriteString(self:SteamID64() )
					net.Send(player.GetBySteamID64(steam64))
					hook.Run("SPSRequestJoin", self, parties[steam64])
				end
			end
		else 
			self:ChatPrint( party.language["Please wait"].." " ..party.joinrequestcooldown.. " "..party.language["seconds between party requests."] )
		end
	else
		self:ChatPrint( party.language["You are not allowed to join this party."])
	end
end

util.AddNetworkString( "RequestJoin" )

net.Receive( "RequestJoin", function( len, ply )
	 local id = net.ReadString()
		ply:requestjoin(id)
end )

function meta:answerjoinrequest(steamid64joiner, bool)
	if bool == true then
		if player.GetBySteamID64(steamid64joiner).requestedtojoin == self:SteamID64() then
			player.GetBySteamID64(steamid64joiner):joinparty(parties[self:SteamID64()])
			player.GetBySteamID64(steamid64joiner).requestedtojoin = nil
			player.GetBySteamID64(steamid64joiner):ChatPrint( self:Nick().. ": "..party.language["accepted your party request."] )
			hook.Run("SPSRequestResponse", self,parties[self:SteamID64()], player.GetBySteamID64(steamid64joiner), true)
		end
	elseif bool == false then
		player.GetBySteamID64(steamid64joiner).requestedtojoin = nil
		player.GetBySteamID64(steamid64joiner):ChatPrint( self:Nick().. ": "..party.language["declined your party request."] )
		hook.Run("SPSRequestResponse", self, parties[self:SteamID64()], player.GetBySteamID64(steamid64joiner), false)
	end
end

util.AddNetworkString( "RequestedJoin" )
local delay1 = party.invitecooldown
local lastOccurance1 = -delay1

net.Receive( "RequestedJoin", function( len, ply )
	local timeElapsed = CurTime() - lastOccurance1
	if timeElapsed < delay1 then
		ply:ChatPrint( "You are sending join requests too fast" )
	else
		local id = net.ReadString()
		local tfbool = net.ReadBool()
		ply:answerjoinrequest(id, tfbool)
		lastOccurance1 = CurTime()
	end
end )

function meta:answerinvite(steamid64inviter, bool)
	local CanJoin = hook.Call( "CanJoinParty" ,nil , player.GetBySteamID64(self:SteamID64()), steamid64inviter  )
	if player.GetBySteamID64(steamid64inviter) != false then
		if player.GetBySteamID64(steamid64inviter).invitedcheck then
			if CanJoin then
				if bool == true then
					if table.HasValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64()) then
						self:joinparty(parties[steamid64inviter])
						player.GetBySteamID64(steamid64inviter):ChatPrint( self:Nick().. ": "..party.language["accepted your party invite."] )
						table.RemoveByValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64() )
					end
				end
			else
				if table.HasValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64()) then
					player.GetBySteamID64(steamid64inviter).requestedtojoin = nil
					player.GetBySteamID64(steamid64inviter):ChatPrint( self:Nick().. ": "..party.language["declined your party invite."] )
					table.RemoveByValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64() )
				end
			end
			if bool == false then
				if table.HasValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64()) then
					player.GetBySteamID64(steamid64inviter).requestedtojoin = nil
					player.GetBySteamID64(steamid64inviter):ChatPrint( self:Nick().. ": "..party.language["declined your party invite."] )
					table.RemoveByValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64() )
				end
			end
		else
			self:ChatPrint( "This party is no longer valid" )
		end
	end
	if party.AutoGroupedJobs[tonumber(steamid64inviter)] != nil then
		if CanJoin then
			if bool == true then
				self:joinparty(parties[tonumber(steamid64inviter)])	
			end
			if bool == false then	 
				table.RemoveByValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64() )
			end
		else
			table.RemoveByValue(player.GetBySteamID64(steamid64inviter).invitedcheck, self:SteamID64() )
		end
	end
end 

util.AddNetworkString( "AnswerInvite" )

net.Receive( "AnswerInvite", function( len, ply )
	 local id = net.ReadString()
	 local tfbool = net.ReadBool()
		ply:answerinvite(id, tfbool)
end )

function meta:partyinvite(steamid)
	local CanJoin = hook.Call( "CanJoinParty" ,nil , player.GetBySteamID64(steamid), self:SteamID64()  )
	if CanJoin != false then
		if self.invited[steamid] == nil then
			self.invited[steamid] = {}
		end
		if self.invited[steamid].curtime == nil then 
			self.invited[steamid].curtime = 0
		end
		if ( self.invited[steamid].curtime < CurTime() ) then
			self.invited[steamid].curtime = CurTime() + party.invitecooldown
				net.Start("partyinvite")
				net.WriteString(self:SteamID64())
				net.Send(player.GetBySteamID64(steamid))
				hook.Run("SPSPartyInvite", self, parties[self:SteamID64()], player.GetBySteamID64(steamid) )
		else 
			self:ChatPrint( party.language["Please wait"].." "..party.invitecooldown.." "..party.language["seconds between party invites."] )
		end
	end
end

util.AddNetworkString( "PartyInvite" )
local delay = party.invitecooldown
local lastOccurance = -delay

net.Receive( "PartyInvite", function( len, ply )
	local timeElapsed = CurTime() - lastOccurance
		if timeElapsed < delay then
			ply:ChatPrint( "You are sending invites too fast" )
		else
			local timeElapsed = CurTime() - lastOccurance
			local id = net.ReadString()
			ply:partyinvite(id)
			table.insert(ply.invitedcheck,id)
			lastOccurance = CurTime()
		end
end )

function meta:LeaveParty()
	-- 20 dakika kontrolü
	local canLeave, reason = CanPlayerLeaveParty(self)
	if not canLeave then
		self:ChatPrint(reason)
		
		-- Kalan süreyi göster
		local steamID = self:SteamID64()
		local joinData = PartyJoinTimes[steamID]
		if joinData then
			net.Start("PartyLeaveTimeInfo")
				net.WriteFloat(joinData.canLeaveTime)
			net.Send(self)
		end
		
		return false
	end
	
	local CanLeaveHook = hook.Call( "CanLeaveParty" ,nil , self, self:GetParty()  )
	if CanLeaveHook != false then
		for v, k in pairs(parties) do
			if v == self:SteamID64() then
				self:disbandparty(self:SteamID64())
				self.invitedcheck = nil
			else
				if table.HasValue(parties[v].members, self:SteamID64()) then
					table.RemoveByValue(parties[v].members, self:SteamID64() )
					hook.Run("SPSLeaveParty",self, parties[v])
					sendonepartiestocl(v, self)
					sendonepartiestoparty(v)
				end
			end
		end
		
		-- Katılım zamanını temizle
		ClearPartyJoinTime(self)
		
		return true
	end
	
	return false
end

function meta:kickfromparty(steam64)
	for v, k in pairs(parties) do
		if table.HasValue(parties[v].members, steam64) then
			if v == self:SteamID64() or self:IsAdmin() or table.HasValue(party.Admins, self:GetNWString("usergroup")) or table.HasValue(party.SteamIDAdmins, self:SteamID64()) then
				if player.GetBySteamID64(steam64) != false then
					hook.Run("SPSKickedParty", self, player.GetBySteamID64(steam64), parties[player.GetBySteamID64(steam64):GetParty()])
					
					-- Kicklenen oyuncunun katılım zamanını temizle
					ClearPartyJoinTime(player.GetBySteamID64(steam64))
					
					player.GetBySteamID64(steam64):LeaveParty()
					player.GetBySteamID64(steam64):ChatPrint( self:Nick().. ": "..party.language["kicked you from the party."] )
				else
					for v, k in pairs(parties) do
						if table.HasValue(parties[v].members, steam64) then
							hook.Run("SPSKickedParty", self, player.GetBySteamID64(steam64), parties[player.GetBySteamID64(steam64):GetParty()])
							table.RemoveByValue(parties[v].members, steam64 )
							sendonepartiestocl(v, player.GetBySteamID64(steam64))
							sendonepartiestoparty(v)
							player.GetBySteamID64(steam64):ChatPrint( self:Nick().. ": "..party.language["kicked you from the party."] )
						end
					end
				end
			end
		end
	end
end

util.AddNetworkString( "KickFromParty" )

net.Receive( "KickFromParty", function( len, ply )
	local id = net.ReadString()
	ply:kickfromparty(id)
end )

function meta:disbandparty(steam64)
	for v, k in pairs(parties) do
		if parties[steam64] then
			if self:IsAdmin() or (self == player.GetBySteamID64(steam64)) or table.HasValue(party.Admins, self:GetNWString("usergroup")) or table.HasValue(party.SteamIDAdmins, self:SteamID64()) then
				hook.Run("SPSDisbandedParty", self, parties[v])
				
				-- Tüm üyelerin katılım zamanlarını temizle
				if parties[steam64] and parties[steam64].members then
					for _, memberID in pairs(parties[steam64].members) do
						local member = player.GetBySteamID64(memberID)
						if IsValid(member) then
							ClearPartyJoinTime(member)
						end
					end
				end
				
				local members = parties[steam64].members
				parties[steam64] = nil
				sendonepartiestoparty(steam64)
				sendpartiestocl(members)
				if player.GetBySteamID64(steam64) != false then
					player.GetBySteamID64(steam64):ChatPrint( self:Nick().. ": "..party.language["disbanded your party."] )
				end
			end
		end
	end
end

util.AddNetworkString( "DisbandParty" )

net.Receive( "DisbandParty", function( len, ply )
	local id = net.ReadString()
	ply:disbandparty(id)
end )

util.AddNetworkString( "LeaveParty" )

net.Receive( "LeaveParty", function( len, ply )
	ply:LeaveParty()
end )

function partyleaderleft( ply )
	for v, k in pairs(parties) do
		if v == ply:SteamID64() then
			hook.Run("SPSPartyLeaderLeft", ply, parties[v])
			
			-- Tüm üyelerin katılım zamanlarını temizle
			if parties[v] and parties[v].members then
				for _, memberID in pairs(parties[v].members) do
					local member = player.GetBySteamID64(memberID)
					if IsValid(member) then
						ClearPartyJoinTime(member)
					end
				end
			end
			
			local members = parties[v].members
			parties[v] = nil
			ply.invitedcheck = nil
			sendonepartiestoparty(v)
			sendpartiestocl(members)
		else
			if party.kickondisconnect then
				if table.HasValue(parties[v].members, ply:SteamID64()) then
					table.RemoveByValue(parties[v].members, ply:SteamID64() )
					sendonepartiestoparty(v)
				end
			end
		end
	end
	
	-- Disconnect olan oyuncunun katılım zamanını temizle
	ClearPartyJoinTime(ply)
end
hook.Add( "PlayerDisconnected", "partyleaderleft", partyleaderleft )

function partydamage(victim, attacker )
	if party.PartyDamage != true then
		if victim:IsPlayer() and attacker:IsPlayer() then
			if (victim:GetParty() != nil) and (attacker:GetParty() != nil ) then
				if (victim:GetParty() == attacker:GetParty()) then
					if victim != attacker then
						return false
					end
				end
			end
		end
	end
end
hook.Add( "PlayerShouldTakeDamage", "partydamage", partydamage)

if party.DarkrpGamemode then
	function Party_TeamChange(ply, before, after)
	local GroupedJobJoin
		for v,k in pairs (party.AutoGroupedJobs) do
			if table.HasValue(party.AutoGroupedJobs[v]["Jobs"], after) then
				GroupedJobJoin = v
			end
		end
		for v,k in pairs (party.AutoGroupedJobs) do
			if table.HasValue(party.AutoGroupedJobs[v]["Jobs"], before) then
				if ply:GetParty() == v then
					ply:LeaveParty()
				end
			end
		end
		
		if GroupedJobJoin != nil then
			if party.ForceJobParty == true then
				ply:LeaveParty()
				ply:joinparty(parties[GroupedJobJoin])
			else
				TeamPartyInvite(ply:SteamID64(), GroupedJobJoin)
			end
		end
		if party.KickBlacklistJobs == true then
			if table.HasValue(party.BlacklistJobs, after) then
				ply:ChatPrint( party.language["You joined a job that is not allowed to be in a party. Kicking you from party"])
				ply:LeaveParty()
			end
		end
	end
	hook.Add("OnPlayerChangedTeam", "Party_PlayerChangedTeams", Party_TeamChange)
end

function TeamPartyInvite(steamid, team)
	local CanJoin = hook.Call( "CanJoinParty" ,nil , player.GetBySteamID64(steamid), team  )
	if CanJoin != false then
		net.Start("partyinvite")
		net.WriteString(team)
		net.Send(player.GetBySteamID64(steamid))
	end
end

function GroupedCanJoin(ply, tojoinparty)
	local canjoin = true
	if table.HasValue(party.BlacklistJobs, ply:Team()) then
		print(ply:Team())
		canjoin = false
	end
	
	if party.ForceJobParty == true then
		if party.AutoGroupedJobs[tojoinparty] then
			if !table.HasValue(party.AutoGroupedJobs[tojoinparty]["Jobs"], ply:Team()) then
				canjoin = false
			end
		end
		for v,k in pairs(party.AutoGroupedJobs)do
			if ply:GetParty() == v and tojoinparty != parties[ply:GetParty()]then
				ply:ChatPrint( party.language["You are currently in a forced party, change jobs."])
				canjoin = false
			end
		end
	end
	
	return canjoin
end
hook.Add("CanJoinParty", "GroupedCanJoin" , GroupedCanJoin )

function GroupedCanLeave(ply, toleaveparty)
if party.ForceJobParty == true then
	for v,k in pairs(party.AutoGroupedJobs)do
			if party.AutoGroupedJobs[toleaveparty] then
				if table.HasValue(party.AutoGroupedJobs[toleaveparty]["Jobs"], ply:Team()) then
					return false
				end
			end
		end
	end
end
hook.Add("CanLeaveParty", "GroupedCanLeave" , GroupedCanLeave )

local function partyspawn( ply )
	sendpartiestocl(ply)
end
hook.Add( "PlayerInitialSpawn", "partyspawn", partyspawn )

-- ============================
-- CHAT KOMUTLARI
-- ============================
hook.Add("PlayerSay", "Party_ChatCommands", function(ply, text)
    local args = string.Explode(" ", text:lower())
    
    if args[1] == "!partikalan" or args[1] == "!partytime" then
        local steamID = ply:SteamID64()
        local joinData = PartyJoinTimes[steamID]
        
        if not joinData then
            ply:ChatPrint("Bir partide değilsiniz veya süre sınırlaması yok.")
        else
            local timeLeft = joinData.canLeaveTime - CurTime()
            if timeLeft > 0 then
                local minutesLeft = math.ceil(timeLeft / 60)
                ply:ChatPrint("Partiden ayrılmak için " .. minutesLeft .. " dakika daha beklemelisiniz.")
            else
                ply:ChatPrint("Partiden istediğiniz zaman ayrılabilirsiniz.")
            end
        end
        
        return ""
    end
end)