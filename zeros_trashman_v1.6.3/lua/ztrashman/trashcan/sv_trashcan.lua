/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Trashcan = ztm.Trashcan or {}
ztm.trashcans = ztm.trashcans or {}

function ztm.Trashcan.AddEntity(ent)
    ent:SetNWInt("ztm_trash", 0)
    table.insert(ztm.trashcans, ent)
end

timer.Simple(5, function()
    if ztm.config.TrashCans.Enabled then
        ztm.Trashcan.CatchEntities()
    end
end)

// Recatch the trashcans if we had a map cleanup
zclib.Hook.Add("PostCleanupMap", "ztm.Trashcan.CatchEntities", function()
	timer.Simple(1, function()
		ztm.trashcans = {}
		if ztm.config.TrashCans.Enabled then
	        ztm.Trashcan.CatchEntities()
	    end
	end)
end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ztm.Trashcan.CatchEntities()
    ztm.trashcans = {}

    for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and ztm.config.TrashCans.models[v:GetModel()] and ztm.config.TrashCans.class[v:GetClass()] then
            --debugoverlay.Sphere(v:GetPos() + v:GetRight() * math.random(-5, 5) + v:GetForward() * math.random(-5, 5), 5, 15, ztm.default_colors["white01"], true)
            ztm.Trashcan.AddEntity(v)
        end
    end
end

function ztm.Trashcan.RefreshTrashcans()
    for k, v in pairs(ztm.trashcans) do
        if IsValid(v) then
            local max = ztm.config.TrashCans.models[v:GetModel()]
            v:SetNWInt("ztm_trash", math.Clamp((v:GetNWInt("ztm_trash", 0) or 0) + ztm.config.TrashCans.Refresh_Amount, 0, max))
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

timer.Simple(0, function()
    if ztm.config.TrashCans.Enabled then
        zclib.Timer.Remove("ztm_trashcan_refresher")

        if ztm.config.TrashCans.Enabled then
            zclib.Timer.Create("ztm_trashcan_refresher", ztm.config.TrashCans.Refresh_Interval, 0, ztm.Trashcan.RefreshTrashcans)
        end
    end
end)

concommand.Add("ztm_debug_CatchTrashcans", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        ztm.Trashcan.CatchEntities()
    end
end)

concommand.Add("ztm_debug_GetModel", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

        if tr.Hit and IsValid(tr.Entity) then
            local model = tr.Entity:GetModel()

            if model then
                ztm.Print("Model: " .. model)
            end
        end
    end
end)
