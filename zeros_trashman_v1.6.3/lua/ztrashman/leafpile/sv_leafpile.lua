/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Leafpile = ztm.Leafpile or {}
ztm.Leafpile.List = ztm.Leafpile.List or {}

function ztm.Leafpile.Add(leafpile)
    table.insert(ztm.Leafpile.List,leafpile)
    zclib.Debug("Leafpile added!")
end


function ztm.Leafpile.Initialize(leafpile)
    zclib.EntityTracker.Add(leafpile)
    ztm.Leafpile.Add(leafpile)
    leafpile.spawned_trash = {}
    leafpile.LastUsed = -9999
end

// Spawn function
function ztm.Leafpile.GetActiveCount()
    local count = 0
    for k, v in pairs(ztm.Leafpile.List) do
        if IsValid(v) and v:GetNoDraw() == false then
            count = count + 1
        end
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

    return count
end

function ztm.Leafpile.RefreshCheck()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

    if ztm.Leafpile.GetActiveCount() >= ztm.config.LeafPile.refresh_count then
        //zclib.Debug("Leafpile limit reached!")
        return
    end

    local ent = ztm.Leafpile.FindFreeEnt()

    if IsValid(ent) then
        ztm.Leafpile.Refresh(ent)
    end
end

function ztm.Leafpile.HasUnUsedTrash(leafpile)
    local hastrash = false
    for k, v in pairs(leafpile.spawned_trash) do
        if IsValid(v) then
            hastrash = true
            break
        end
    end
    return hastrash
end

function ztm.Leafpile.FindFreeEnt()
    ztm.Leafpile.List = zclib.table.randomize( ztm.Leafpile.List )

    local ent
    for k, v in pairs(ztm.Leafpile.List) do
        if IsValid(v) and v:GetNoDraw() == true and (v.LastUsed + ztm.config.LeafPile.refresh_cooldown) < CurTime() and ztm.Leafpile.HasUnUsedTrash(v) == false then
            ent = v
            break
        end
    end

    return ent
end

timer.Simple(1,function()
    zclib.Timer.Remove("ztm_leafpile_refresher")
    zclib.Timer.Create("ztm_leafpile_refresher", ztm.config.LeafPile.refresh_interval, 0, ztm.Leafpile.RefreshCheck)
end)



// Action function
function ztm.Leafpile.Explode(leafpile,ply)

    zclib.NetEvent.Create("ztm_leafpile_fx", {leafpile})

    // Spawn Trash
    if zclib.util.RandomChance(ztm.config.LeafPile.trash_chance) then
        local trash_count = math.random(1, ztm.config.LeafPile.trash_count)
        local trash_amount = math.random(ztm.config.LeafPile.trash_min, ztm.config.LeafPile.trash_max)
        leafpile.spawned_trash = {}
        for i = 1, trash_count do
            local pos = leafpile:GetPos() + leafpile:GetRight() * math.Rand(-55, 55) + leafpile:GetForward() * math.Rand(-55, 55)
            local ent = ztm.Trash.Create(pos, leafpile:GetAngles(), trash_amount / trash_count)
            local rad = ent:BoundingRadius()
            ent:SetPos(pos + Vector(0, 0, rad * 0.8))
            table.insert(leafpile.spawned_trash,ent)
        end
    end

    // Custom Hook
    hook.Run("ztm_OnLeafpileBlast", ply, leafpile)

    leafpile:SetNoDraw(true)
    leafpile:PhysicsInit( SOLID_NONE  )
    leafpile.LastUsed = CurTime()
end

function ztm.Leafpile.Refresh(leafpile)
    leafpile:SetNoDraw(false)

    leafpile:PhysicsInit(SOLID_VPHYSICS)
    leafpile:SetSolid(SOLID_VPHYSICS)
    leafpile:SetMoveType(MOVETYPE_VPHYSICS)
    leafpile:SetUseType(SIMPLE_USE)
    leafpile:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = leafpile:GetPhysicsObject()

    if (phys:IsValid()) then
        phys:Wake()
        phys:EnableMotion(false)
    end
end




                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389







///////////////////////////////////////////
timer.Simple(3, function()
    file.CreateDir("ztm")
    
    concommand.Add("ztm_leafpile_save", function(ply, cmd, args)
        if zclib.Player.IsAdmin(ply) then
            zclib.Notify(ply, "Leafpile entities have been saved for the map " .. game.GetMap() .. "!", 0)
            zclib.STM.Save("ztm_leafpile")
        end
    end)
    
    concommand.Add("ztm_leafpile_remove", function(ply, cmd, args)
        if zclib.Player.IsAdmin(ply) then
            zclib.Notify(ply, "Leafpile entities have been removed for the map " .. game.GetMap() .. "!", 0)
            zclib.STM.Remove("ztm_leafpile")
        end
    end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d
    
    concommand.Add("ztm_leafpile_refresh", function(ply, cmd, args)
        if zclib.Player.IsAdmin(ply) then
            for k, v in pairs(zclib.EntityTracker.GetList()) do
                if IsValid(v) and v:GetClass() == "ztm_leafpile" then
                    ztm.Leafpile.Refresh(v)
                end
            end
        end
    end)
    
    zclib.STM.Setup("ztm_leafpile", "ztm/" .. string.lower(game.GetMap()) .. "_leafpiles.txt", function()
        local data = {}
    
        for u, j in pairs(ztm.Leafpile.List) do
            if IsValid(j) then
                table.insert(data, {
                    pos = j:GetPos(),
                    ang = j:GetAngles()
                })
            end
        end
    
        return data
    end, function(data)
        for k, v in pairs(data) do
            local ent = ents.Create("ztm_leafpile")
            ent:SetPos(v.pos)
            ent:SetAngles(v.ang)
            ent:Spawn()
            ent:Activate()
            ent:SetNoDraw(true)
            ent:PhysicsInit(SOLID_NONE)
        end
    
        ztm.Print("Finished loading Leafpile Entities.")
    end, function()
        for k, v in pairs(ztm.Leafpile.List) do
            if IsValid(v) then
                v:Remove()
            end
        end
    end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d
