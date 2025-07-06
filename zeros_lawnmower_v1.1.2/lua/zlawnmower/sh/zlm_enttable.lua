/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

zlm = zlm or {}
zlm.f = zlm.f or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813


-- List of all the zlm Entities on the server
if zlm.EntList == nil then
	zlm.EntList = {}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

function zlm.f.EntList_Add(ent)
	table.insert(zlm.EntList, ent)
end

if SERVER then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	concommand.Add("zlm_debug_EntList", function(ply, cmd, args)
		if IsValid(ply) and zlm.f.IsAdmin(ply) then
			PrintTable(zlm.EntList)
		end
	end)
end
