--Mayor Voting System Server Dist
VOTING.Database = {}

function VOTING.Database.Setup()
	sql.Query("CREATE TABLE IF NOT EXISTS voting_npcs(map VARCHAR(50) NOT NULL, x INTEGER NOT NULL, y INTEGER NOT NULL, z INTEGER NOT NULL, pitch INTEGER NOT NULL, yaw INTEGER NOT NULL, roll INTEGER NOT NULL, PRIMARY KEY(map));")
	print(sql.LastError() or "noerrorhere")
end
hook.Add("InitPostEntity","VOTING_InitSetupDatabase",VOTING.Database.Setup)

function VOTING.Database.SaveNPC(pos, ang)
	local map = string.lower(game.GetMap())
	sql.Query("REPLACE INTO voting_npcs VALUES(" .. sql.SQLStr(map) .. ", " .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ", " .. ang.p .. ", " .. ang.y .. ", " .. ang.r .. ");");
end

function VOTING.Database.LoadNPC()
	local map = string.lower(game.GetMap())
	local r = sql.Query("SELECT * FROM voting_npcs WHERE map = " .. sql.SQLStr(map) .. " ;")
	if r then
		for k, v in pairs(r) do
			local pos = Vector(tonumber(v.x), tonumber(v.y), tonumber(v.z))
			local ang = Angle(tonumber(v.pitch), tonumber(v.yaw), tonumber(v.roll))
			return pos,ang
		end
	else return false end
end

function VOTING.Database.ClearNPC()
	local map = string.lower(game.GetMap())
    sql.Query("DELETE FROM voting_npcs WHERE map = " .. sql.SQLStr(map) .. " ;")
end