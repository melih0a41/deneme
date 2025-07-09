/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.PlayerTrash = ztm.PlayerTrash or {}
ztm.Player = ztm.Player or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

zclib.Player.CleanUp_Add("ztm_trashbag")
zclib.Player.CleanUp_Add("ztm_trashburner")
zclib.Player.CleanUp_Add("ztm_recycler")

zclib.Gamemode.AssignOwnerOnBuy("ztm_trashburner")
zclib.Gamemode.AssignOwnerOnBuy("ztm_recycler")

local function DropTrashOnDeath(ply)
    local swep = ply:GetWeapon("ztm_trashcollector")
    if not IsValid(swep) then return end
    local m_trash = swep:GetTrash()
    swep:SetTrash(0)
    if m_trash <= 0 then return end

    while m_trash > 0 do
        local add = 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

        if m_trash > ztm.config.Trashbags.capacity then
            add = ztm.config.Trashbags.capacity
        else
            add = m_trash
        end

        if add <= 0 then return end
        local ent = ents.Create("ztm_trashbag")
        ent:SetPos(ply:GetPos() + zclib.util.GetRandomPositionInsideCircle(50, 100, 50))
        ent:Spawn()
        ent:Activate()
        ent:SetTrash(add)
        zclib.Player.SetOwner(ent, ply)
        m_trash = m_trash - add
    end
end

zclib.Hook.Add("PlayerDeath", "ztm_DropTrash", function(vic, infl, attack)
    if IsValid(vic) and ztm.config.TrashSWEP.DropTrashOnDeath then
        DropTrashOnDeath(vic)
    end
end)

function ztm.PlayerTrash.SetRandomPlayerDirty()
    local valid_plys = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

    for k, v in pairs(zclib.Player.List) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and /*ztm.Player.IsTrashman(v) == false and*/ v:GetNWFloat("ztm_trash", 0) <= 0 then
            if table.Count(ztm.config.PlayerTrash.jobs) > 0 then
                if ztm.config.PlayerTrash.jobs[zclib.Player.GetJobName(v)] then
                    table.insert(valid_plys, v)
                end
            else
                table.insert(valid_plys, v)
            end
        end
    end

    if valid_plys and table.Count(valid_plys) > 0 then
        local rnd_ply = valid_plys[math.random(#valid_plys)]
        ztm.Player.MakeDirty(rnd_ply)
    end
end

timer.Simple(0, function()
    zclib.Timer.Remove("ztm_PlayerTrash_timer")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if ztm.config.PlayerTrash.Enabled then
        zclib.Timer.Create("ztm_PlayerTrash_timer", ztm.config.PlayerTrash.Interval, 0, function()
            ztm.PlayerTrash.SetRandomPlayerDirty()
        end)
    end
end)

function ztm.Player.MakeDirty(ply)
    if not IsValid(ply) then return end
    local amount = math.random(ztm.config.PlayerTrash.trash_min, ztm.config.PlayerTrash.trash_max)
    ply:SetNWFloat("ztm_trash", math.Clamp(ply:GetNWFloat("ztm_trash", 0) + amount, 0, ztm.config.PlayerTrash.Limit))
    zclib.Debug("Set " .. ply:Nick() .. " dirty with " .. amount .. ztm.config.UoW .. " of trash!")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

zclib.Hook.Add("PlayerChangedTeam", "ztm_player_trash", function(ply, before, after)
    if ztm.config.Jobs[after] then
        ply:SetNWFloat("ztm_trash", 0)
    end
end)

concommand.Add("ztm_debug_addbots_to_playerlist", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        for k, v in pairs(player.GetBots()) do
            if IsValid(v) and v:Alive() then
                zclib.Player.Add(v)
            end
        end
    end
end)
