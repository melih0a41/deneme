--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"Corporate Takeover", -- Name
	"cto", 
	Color(0,128,255), -- Color
	function() -- Check
		return  Corporate_Takeover != nil
	end,
	true -- delayed
)


mLogs.addCategoryDefinitions("cto", {
    corp_created = function(data) return mLogs.doLogReplace({"^player1", "created the corporation", "^name"},data) end,
    cto_corp_deleted = function(data) return mLogs.doLogReplace({"^player1", "lost the corporation", "^name"},data) end,
    cto_corp_damaged = function(data) return mLogs.doLogReplace({"^player2", "dealt "..data.dmg, "damage to", "^class", "by", "^player1"},data) end,
    cto_corp_destroyed = function(data) return mLogs.doLogReplace({"^player2", "destroyed", "^class", "by", "^player1"},data) end,
    cto_corp_withdrew = function(data) return mLogs.doLogReplace({"^player2", "withdrew", "^amount"},data) end,
    cto_corp_deposited = function(data) return mLogs.doLogReplace({"^player2", "deposited", "^amount"},data) end,
    cto_corp_deposited = function(data) return mLogs.doLogReplace({"^player2", "deposited", "^amount"},data) end,
    cto_corp_bought = function(data) return mLogs.doLogReplace({"^player2", "bought", "^class"},data) end,
})