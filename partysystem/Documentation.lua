--Functions
ply:GetParty()			--Will return the partyid (or leaders steamid64)
--returns partyid NUMBER


ply:GetPartyName()		--Will get the name that the party leader assigned to the players party 
--returns party name STRING


ply:LeaveParty()		--Will kick the player from the party, and disban a party if they are the leader
--returns nothing


	
	
--Hooks
CanJoinParty(ply, partyid) --You can prevent players from joining parties using this hook





--Example Usage
-------CanJoinParty(ply, partyid)-------
--[[
hook.Add("CanJoinParty" , "ForceSameTeam" , function (ply, partyid)
	if ply:Team() != "TEAM_HOBO" then -- This prevents all players who are not Hobos from joining teams
		return false
	end
end)
]]--

