/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Data = ztm.Data or {}

if not file.Exists("ztm", "DATA") then
    file.CreateDir("ztm")
end

if not file.Exists("ztm/data/", "DATA") then
    file.CreateDir("ztm/data/")
end

function ztm.Data.Changed(ply)
    if not ply.ztm_DataChanged then
        ply.ztm_DataChanged = true
    end
end

function ztm.Data.PlayerDisconnect(ply)
    zclib.Debug("ztm.Data.PlayerDisconnect")

    if (ply.ztm_DataChanged) then
        ztm.Data.Save(ply)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zclib.Hook.Add("PlayerDisconnected", "ztm.levelsys", ztm.Data.PlayerDisconnect)

function ztm.Data.Init(ply)
    if ply.ztm_data then return end
    zclib.Debug("ztm.Data.Init: " .. ply:Nick())
    local plyID = ply:SteamID64()

    if ztm.config.TrashSWEP.data_save == true and file.Exists("ztm/data/" .. plyID .. ".txt", "DATA") then
        local data = file.Read("ztm/data/" .. plyID .. ".txt", "DATA")
        data = util.JSONToTable(data)
        ply.ztm_data = data
        zclib.Debug("Level Data fully loaded!")
    else
        ply.ztm_data = {
            xp = 0,
            lvl = 1
        }

        zclib.Debug("Level Data created!")
    end

    ztm.Data.Changed(ply)
end

function ztm.Data.AddXP(ply, xp)
    //zclib.Debug("ztm.Data.AddXP")
    ply.ztm_data = {
        xp = (ply.ztm_data.xp or 0) + xp,
        lvl = ply.ztm_data.lvl
    }

    ztm.Data.LevelUP_Check(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ztm.Data.GetLevel(ply)
    if ply.ztm_data and ply.ztm_data.lvl then
        return ply.ztm_data.lvl
    else
        return 0
    end
end

function ztm.Data.LevelUP_Check(ply)
    // zclib.Debug("ztm.Data.LevelUP_Check")
    // 288688181
    // Checks if there is a level after the current one
    if ztm.config.TrashSWEP.level[ply.ztm_data.lvl + 1] then
        local nextXP = ztm.config.TrashSWEP.level[ply.ztm_data.lvl].next_xp

        // Checks if we can level up
        if ply.ztm_data.xp >= nextXP then
            ply.ztm_data = {
                xp = 0,
                lvl = ply.ztm_data.lvl + 1
            }

            ztm.Data.Save(ply)
        end
    end

    ztm.Data.Changed(ply)
    ztm.Data.UpdateSWEP(ply)
end

function ztm.Data.UpdateSWEP(ply)
    //zclib.Debug("ztm.Data.UpdateSWEP")
    local swep = ply:GetWeapon("ztm_trashcollector")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    if swep and IsValid(swep) then
        swep:SetPlayerLevel(ply.ztm_data.lvl)
        swep:SetPlayerXP(ply.ztm_data.xp)
    end
end

function ztm.Data.Save(ply)
    if ztm.config.TrashSWEP.data_save == false then return end
    if zclib.Player.RankCheck(ply, ztm.config.TrashSWEP.data_save_whitelist) == false then return end
    zclib.Debug("ztm.Data.Save")
    local plyID = ply:SteamID64()
    file.Write("ztm/data/" .. tostring(plyID) .. ".txt", util.TableToJSON(ply.ztm_data))
end

function ztm.Data.Save_All()
    for k, v in pairs(zclib.Player.List) do
        if (v.ztm_DataChanged) then
            ztm.Data.Save(v)
        end
    end
end

timer.Simple(0, function()
    zclib.Timer.Remove("ztm_DataSaver_timer")

    if ztm.config.TrashSWEP.data_save then
        zclib.Timer.Create("ztm_DataSaver_timer", ztm.config.TrashSWEP.data_save_interval, 0, ztm.Data.Save_All)
    end
end)

concommand.Add("ztm_lvlsys_reset", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        ply.ztm_data = {
            xp = 0,
            lvl = 1
        }
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

        ztm.Data.Save(ply)
        ztm.Data.UpdateSWEP(ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

concommand.Add("ztm_lvlsys_max", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        ply.ztm_data = {
            xp = 0,
            lvl = table.Count(ztm.config.TrashSWEP.level)
        }

        ztm.Data.Save(ply)
        ztm.Data.UpdateSWEP(ply)
    end
end)

concommand.Add("ztm_lvlsys_givexp", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		local xp = args[ 1 ]
		if not xp then return end
		xp = tonumber(xp)
		if not xp then return end
		local tr = ply:GetEyeTrace()

		if tr and IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:Alive() then
			local target = tr.Entity
			ztm.Data.AddXP(target, xp)
			ztm.Data.Save(target)
			ztm.Data.UpdateSWEP(target)
		end
	end
end)
concommand.Add("ztm_data_purge", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        for k, v in pairs(zclib.Player.List) do
            if IsValid(v) then
                v.ztm_data = {
                    xp = 0,
                    lvl = 1
                }
            end
        end

        local files, _ = file.Find("ztm/data/*", "DATA")

        for k, v in pairs(files) do
            if file.Exists("ztm/data/" .. v, "DATA") then
                file.Delete("ztm/data/" .. v)
            end
        end
    end
end)
