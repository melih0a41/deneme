function perfectVault.Database.Startup()
	if not sql.TableExists("pvault_ents") then
		sql.Query("CREATE TABLE pvault_ents(id INTEGER PRIMARY KEY AUTOINCREMENT, class VARCHAR(32) NOT NULL, settings TEXT, pos TEXT, ang TEXT, map TEXT);")
	end
end

function perfectVault.Database.CreateEntity(class, settings, pos, ang)
	if not perfectVault.Core.Entites[class] then return end
	if not pos then return end
	if not ang then return end
	sql.Query(string.format("INSERT INTO pvault_ents(class, settings, pos, ang, map) VALUES('%s', '%s', '%s', '%s', '%s');",
		sql.SQLStr(class, true),
		util.TableToJSON(settings or perfectVault.Core.Entites[class].config),
		util.TableToJSON({x = pos.x, y = pos.y, z = pos.z}),
		util.TableToJSON({x = ang.x, y = ang.y, z = ang.z}),
		sql.SQLStr(game.GetMap(), true)
	))

	return sql.QueryRow("SELECT id FROM pvault_ents ORDER BY id DESC;")
end

function perfectVault.Database.GetEntites()
	return sql.Query(string.format("SELECT * FROM pvault_ents WHERE map = '%s';", sql.SQLStr(game.GetMap(), true)))
end

function perfectVault.Database.DeleteEntityByID(id)
	return sql.Query(string.format("DELETE FROM pvault_ents WHERE id = %i;", id))
end