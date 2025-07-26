--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

local category = "cto"

mLogs.addLogger("Created","corp_created",category)
mLogs.addHook("cto_corp_created", category, function(ply, CorpName)
	if(!IsValid(ply)) then return end
    mLogs.log("corp_created", category, {player1=mLogs.logger.getPlayerData(ply), name=CorpName})
end)

mLogs.addLogger("Lost","cto_corp_deleted",category)
mLogs.addHook("cto_corp_deleted", category, function(ply, CorpName)
	if(!IsValid(ply)) then return end
    mLogs.log("cto_corp_deleted", category, {player1=mLogs.logger.getPlayerData(ply), name=CorpName})
end)

mLogs.addLogger("Damage","cto_corp_damaged",category)
mLogs.addHook("cto_corp_damaged", category, function(attacker, ply, damage, entclass, CorpName)
	if(!IsValid(ply)) then return end
	if(!IsValid(attacker)) then return end
    mLogs.log("cto_corp_damaged", category, {player1=mLogs.logger.getPlayerData(ply), player2=mLogs.logger.getPlayerData(attacker), dmg=damage, class=entclass, name=CorpName})
end)

mLogs.addLogger("Destruction","cto_corp_destroyed",category)
mLogs.addHook("cto_corp_destroyed", category, function(attacker, ply, entclass)
	if(!IsValid(ply)) then return end
	if(!IsValid(attacker)) then return end
    mLogs.log("cto_corp_destroyed", category, {player1=mLogs.logger.getPlayerData(ply), player2=mLogs.logger.getPlayerData(attacker), class=entclass})
end)

mLogs.addLogger("Money withdrawn","cto_corp_withdrew",category)
mLogs.addHook("cto_corp_withdrew", category, function(ply, money)
	if(!IsValid(ply)) then return end
    mLogs.log("cto_corp_withdrew", category, {player1=mLogs.logger.getPlayerData(ply), amount=money})
end)

mLogs.addLogger("Money deposited","cto_corp_deposited",category)
mLogs.addHook("cto_corp_deposited", category, function(ply, money)
	if(!IsValid(ply)) then return end
    mLogs.log("cto_corp_deposited", category, {player1=mLogs.logger.getPlayerData(ply), amount=money})
end)

mLogs.addLogger("Purchases","cto_corp_bought",category)
mLogs.addHook("cto_corp_bought", category, function(ply, entClass)
	if(!IsValid(ply)) then return end
    mLogs.log("cto_corp_bought", category, {player1=mLogs.logger.getPlayerData(ply), class=entClass})
end)