/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Manhole = ztm.Manhole or {}
ztm.Manhole.List = ztm.Manhole.List or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca


function ztm.Manhole.Initialize(Manhole)
    zclib.EntityTracker.Add(Manhole)

    Manhole.IsBusy = false
    Manhole.Cooldown = 0

    table.insert(ztm.Manhole.List,Manhole)
end

function ztm.Manhole.USE(Manhole,ply)
    if Manhole.IsBusy then return end
    if ztm.Player.IsTrashman(ply) == false then return end
    ztm.Manhole.Switch(Manhole)
end

function ztm.Manhole.Switch(Manhole)

    Manhole:SetIsClosed( not Manhole:GetIsClosed())

    if Manhole:GetIsClosed() then
        ztm.Manhole.Close(Manhole)
    else
        ztm.Manhole.Open(Manhole)
    end
end

function ztm.Manhole.Open(Manhole)
    Manhole:SetIsClosed( false )
    Manhole.IsBusy = true
    zclib.Debug("Open manhole")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

    timer.Simple(1.1,function()
        if IsValid(Manhole) then
            Manhole.IsBusy = false
        end
    end)

    // If no player is in distance then we close the manhole after 10 seconds
    ztm.Manhole.StartAutoClose(Manhole)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    if Manhole.Cooldown < CurTime() then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

        if zclib.util.RandomChance(ztm.config.Manhole.chance) == false then
            zclib.Debug("No trash today!")
        else
            zclib.Debug("Rebuild Trash")
            Manhole:SetTrash(math.random(ztm.config.Manhole.min_amount,ztm.config.Manhole.max_amount))
        end

    else
        zclib.Debug("Cooldown: " .. math.Round(Manhole.Cooldown - CurTime()))
    end
    Manhole.Cooldown = ztm.config.Manhole.cooldown + CurTime()
end

function ztm.Manhole.Close(Manhole)
    Manhole:SetIsClosed( true )
    Manhole.IsBusy = true
    zclib.Debug("Close manhole")

    timer.Simple(1.1,function()
        if IsValid(Manhole) then
            Manhole.IsBusy = false
        end
    end)
end

function ztm.Manhole.StartAutoClose(Manhole)
    local timerID = "ztm_manhole_autocloser_" .. Manhole:EntIndex() .. "_timer"
    zclib.Timer.Remove(timerID)

    zclib.Timer.Create(timerID, 5, 1, function()
        zclib.Timer.Remove(timerID)

        if IsValid(Manhole) then
            if ztm.Manhole.PlayerInDistance(Manhole) then
                zclib.Debug("Player is in distance, Restart auto close timer!")
                ztm.Manhole.StartAutoClose(Manhole)
            else
                ztm.Manhole.Close(Manhole)
            end
        end
    end)
end

function ztm.Manhole.PlayerInDistance(Manhole)
    local _PlayerInDistance = false

    // Check if a player is in distance
    for k, v in pairs(zclib.Player.List) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and zclib.util.InDistance(Manhole:GetPos(), v:GetPos(), 200) then
            _PlayerInDistance = true
            break
        end
    end
    return _PlayerInDistance
end






///////////////////////////////////////////
file.CreateDir("ztm")

concommand.Add( "ztm_manhole_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Manhole entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Save("ztm_manhole")
    end
end )

concommand.Add( "ztm_manhole_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Manhole entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("ztm_manhole")
    end
end )

zclib.STM.Setup("ztm_manhole", "ztm/" .. string.lower(game.GetMap()) .. "_manholes.txt", function()
    local data = {}

    for u, j in pairs(ztm.Manhole.List) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

    return data
end, function(data)
    for k, v in pairs(data) do
        local ent = ents.Create("ztm_manhole")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()

        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end
    ztm.Print("Finished loading Manhole Entities.")
end, function()
    for k, v in pairs(ztm.Manhole.List) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)
