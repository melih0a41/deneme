/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Trash = ztm.Trash or {}
ztm.Trash.List = ztm.Trash.List or {}
ztm.Trash.Spawns = ztm.Trash.Spawns or {}

function ztm.Trash.Initialize(Trash)
    Trash:SetModel(ztm.config.Trash.models[ math.random( #ztm.config.Trash.models ) ])
    Trash:PhysicsInit(SOLID_VPHYSICS)
    Trash:SetSolid(SOLID_VPHYSICS)
    Trash:SetMoveType(MOVETYPE_VPHYSICS)
    Trash:SetUseType(SIMPLE_USE)
    Trash:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    Trash:UseClientSideAnimation()

    local phys = Trash:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    zclib.EntityTracker.Add(Trash)

    Trash.lastpos = Trash:GetPos()
    Trash.idle_time = 0
    table.insert(ztm.Trash.List,Trash)
end



//CLEANUP
function ztm.Trash.Cleanup()

    for k, v in pairs(ztm.Trash.List) do
        if IsValid(v) then

            // Recalculate idle time
            if v.lastpos == v:GetPos() then
                v.idle_time = v.idle_time + 1
            else
                v.idle_time = 0
            end

            // Delete entity if to long idle
            if v.idle_time > ztm.config.Trash.cleanup_time then
                SafeRemoveEntity( v )
            else
                v.lastpos = v:GetPos()
            end
        end
    end
end

timer.Simple(0,function()
    zclib.Timer.Remove("ztm_TrashCleanup_timer")
    zclib.Timer.Create("ztm_TrashCleanup_timer", 1, 0, ztm.Trash.Cleanup)
end)



//SPAWN
function ztm.Trash.AddSpawnPos(pos,ply)
    table.insert(ztm.Trash.Spawns,pos)
    timer.Simple(0,function()
        zclib.Notify(ply, "Trash position added!", 0)
        ztm.Trash.ShowAll(ply)
    end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ztm.Trash.RemoveSpawnPos(pos,ply)

    local removed_pos = 0
    local old_pos = ztm.Trash.Spawns
    ztm.Trash.Spawns = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

    for k, v in pairs(old_pos) do
        if v:Distance(pos) > 25 then
            table.insert(ztm.Trash.Spawns,v)
        else
            removed_pos = removed_pos + 1
        end
    end

    if removed_pos > 0 then
        timer.Simple(0,function()
            zclib.Notify(ply, "Removed Trash positions: " .. removed_pos, 0)
            ztm.Trash.ShowAll(ply)
        end)
    end
end

util.AddNetworkString("ztm_trash_showall")
function ztm.Trash.ShowAll(ply)
    local dataString = util.TableToJSON(ztm.Trash.Spawns)
    local dataCompressed = util.Compress(dataString)

    net.Start("ztm_trash_showall")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end

util.AddNetworkString("ztm_trash_hideall")
function ztm.Trash.HideAll(ply)
    net.Start("ztm_trash_hideall")
    net.Send(ply)
end



timer.Simple(0,function()
    zclib.Timer.Remove("ztm_TrashSpawn_timer")
    if ztm.config.Trash.spawn.enabled then
        zclib.Timer.Create("ztm_TrashSpawn_timer", ztm.config.Trash.spawn.time, 0, function()
            ztm.Trash.Spawn()
        end)
    end
end)


// Returns the current valid count of trash entities spawned from the custom spawns
function ztm.Trash.GetValidCount()
    local count = 0
    for k, v in pairs(ztm.Trash.List) do
        if IsValid(v) and v.IsFromCustomSpawn ~= nil and v.IsFromCustomSpawn == true then
            count = count + 1
        end
    end

    return count
end

// Spawns trash at a random point
function ztm.Trash.Spawn()
	/*
	local FoundTrashman = false
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) and v:Team() == TEAM_ZTM_TRASHMAN then
			FoundTrashman = true
			break
		end
	end
	if not FoundTrashman then return end
	*/

    if ztm.Trash.Spawns == nil or table.Count(ztm.Trash.Spawns) <= 0 then
        //zclib.Debug("No Spawn Positions set!")
        return
    end

    if ztm.Trash.GetValidCount() >= ztm.config.Trash.spawn.count then
        //zclib.Debug("Trash limit reached!")
        return
    end

    local rndPos = ztm.Trash.Spawns[ math.random( #ztm.Trash.Spawns ) ]

    local trash_InDistance = false
    for k, v in pairs(ztm.Trash.List) do
        if IsValid(v) and zclib.util.InDistance(v:GetPos(), rndPos, 50) then

            trash_InDistance = true
            break
        end
    end


    if trash_InDistance == false then
        local ent = ztm.Trash.Create(rndPos, Angle(0,0,0), math.random(ztm.config.Trash.spawn.trash_min,ztm.config.Trash.spawn.trash_max))
        local rad = ent:BoundingRadius()
        ent:SetPos(rndPos + Vector(0, 0, rad * 0.8))
        ent.IsFromCustomSpawn = true
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

function ztm.Trash.Create(pos, ang, amount)
    local ent = ents.Create("ztm_trash")
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:SetTrash(amount)
    ent:Spawn()
    ent:Activate()

    ent.lastpos = pos
    ent.idle_time = 0

    return ent
end




///////////////////////////////////////////
file.CreateDir("ztm")

concommand.Add("ztm_trash_save", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Trash spawns have been saved for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Save("ztm_trash")
    end
end)

concommand.Add("ztm_trash_remove", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Trash spawns have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("ztm_trash")
        ztm.Trash.HideAll(ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

zclib.STM.Setup("ztm_trash", "ztm/" .. string.lower(game.GetMap()) .. "_trashspawns.txt", function()
    local data = {}

    for u, j in pairs(ztm.Trash.Spawns) do
        if j then
            table.insert(data, j)
        end
    end

    return data
end, function(data)
    ztm.Trash.Spawns = data
    ztm.Print("Finished loading Trash Spawns.")
end, function()
    for k, v in pairs(ztm.Trash.List) do
        if IsValid(v) then
            SafeRemoveEntity(v)
        end
    end

    ztm.Trash.Spawns = {}
end)
