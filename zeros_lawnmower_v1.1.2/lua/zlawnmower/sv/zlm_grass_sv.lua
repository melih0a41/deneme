/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if (not SERVER) then return end
zlm = zlm or {}
zlm.f = zlm.f or {}

////////////////////////////////////

if zlm_GrassSpots == nil then
    zlm_GrassSpots = {}
end

function zlm.f.Add_GrassSpot(pos,ID)

    for k, v in pairs(zlm_GrassSpots) do
        if zlm.f.InDistance(v.pos, pos, 20) then
            zlm_GrassSpots[k] = nil
        end
    end

    table.insert(zlm_GrassSpots, {
        pos = pos,
        id = ID,
        mowed = false,
        mowetime = -1
    })
end

function zlm.f.Remove_GrassSpot(tr_pos, radius)
    for k, v in pairs(zlm_GrassSpots) do
        if zlm.f.InDistance(v.pos, tr_pos, radius + 30) then
            zlm_GrassSpots[k] = nil
        end
    end
end

////////////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

util.AddNetworkString("zlm_GrassSpots_mowed")
function zlm.f.Mowed_GrassSpot(k)
    net.Start("zlm_GrassSpots_mowed")
    net.WriteInt(k,21)
    net.Broadcast()
end

util.AddNetworkString("zlm_GrassSpots_refresh")
function zlm.f.Refresh_GrassSpot(k)
    net.Start("zlm_GrassSpots_refresh")
    net.WriteInt(k,21)
    net.Broadcast()
end

////////////////////////////////////

util.AddNetworkString("zlm_GrassSpots_load")
function zlm.f.Send_GrassSpots_ToClient(ply)

    local data = {}

    for k, v in pairs(zlm_GrassSpots) do
        table.insert(data, {
            pos = v.pos,
            mowed = v.mowed,
            id = v.id,
        })
    end

    local dataString = util.TableToJSON(data)
    local dataCompressed = util.Compress(dataString)
    net.Start("zlm_GrassSpots_load")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

function zlm.f.Send_GrassSpots_ToClients()

    local data = {}
    for k, v in pairs(zlm_GrassSpots) do
        if v then
            table.insert(data, {
                pos = v.pos,
                mowed = v.mowed,
                id = v.id,
            })
        end
    end

    table.CopyFromTo( data, zlm_GrassSpots )

    local dataString = util.TableToJSON(data)
    local dataCompressed = util.Compress(dataString)

    net.Start("zlm_GrassSpots_load")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Broadcast()
end


////////////////////////////////////

if zlm_LawnMowers == nil then
    zlm_LawnMowers = {}
end

function zlm.f.Add_Tractor(tractor)
    table.insert(zlm_LawnMowers,tractor)
end


function zlm.f.MowLogic()

    for s, w in pairs(zlm_GrassSpots) do

        // If the CurTime is higher then the refresh time then we refresh the GrassSpot
        if w.mowetime and w.mowed == true and CurTime() > (w.mowetime + zlm.config.Grass.RefreshTime) then
            w.mowed = false
            zlm.f.Refresh_GrassSpot(s)
        end

        for k, v in pairs(zlm_LawnMowers) do
            if IsValid(v) and v:GetClass() == "zlm_tractor" then
                zlm.f.Tractor_Logic(v,w,s)
            end
        end
    end
end

function zlm.f.Tractor_Logic(veh,grass_val,grass_key)
    local IsMowing = veh:GetIsMowing()
    local GrassStorage = veh:GetGrassStorage()

    if IsMowing then
        if GrassStorage >= zlm.config.LawnMower.StorageCapacity then

            zlm.f.Stop_Mowing(veh)
        else
            if zlm.f.InDistance(grass_val.pos, veh:GetPos(), 70) and grass_val.mowed == false then
                grass_val.mowed = true
                grass_val.mowetime = CurTime()

                local driver = veh.Vehicle:GetDriver()
                if IsValid(driver) then
                    // Custom Hook
    			    hook.Run("zlm_OnGrassMowed", driver, veh.Vehicle)
                end

                veh:SetGrassStorage(GrassStorage + 1)
                zlm.f.Mowed_GrassSpot(grass_key)
            end
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function zlm.f.SimpleMowLogic()
    for k, v in pairs(zlm_LawnMowers) do

        if IsValid(v) and v:GetClass() == "zlm_tractor"  then

            local IsMowing = v:GetIsMowing()
            local GrassStorage = v:GetGrassStorage()

            if IsMowing and CurTime() > v.LastMowe and not zlm.f.InDistance(v.LastMowPos, v:GetPos(), 70)  and zlm.f.GrassTrace(v) then

                if GrassStorage >= zlm.config.LawnMower.StorageCapacity then
                    zlm.f.Stop_Mowing(v)
                else

                    local driver = v.Vehicle:GetDriver()
                    if IsValid(driver) then
                        // Custom Hook
                        hook.Run("zlm_OnGrassMowed", driver, v.Vehicle)
                    end

                    v.LastMowPos = v:GetPos()
                    v:SetGrassStorage(GrassStorage + 1)
                end
            end

            v.LastMowe = CurTime() + zlm.config.LawnMower.MoweInterval
        end
    end
end

function zlm.f.GrassTrace(veh)
    local tr = util.TraceLine( {
    	start = veh:GetPos() + veh:GetUp() * 5,
        endpos = veh:GetPos() - Vector(0,0,1000),
    	filter = {veh,veh.Vehicle,veh.Vehicle:GetDriver()}
    } )

    if tr.HitWorld then

        if table.HasValue(zlm.config.SimpleGrassMode.Textures,tr.HitTexture) then

            return true
        elseif zlm.config.SimpleGrassMode.Displacement and tr.HitTexture == "**displacement**" then

            return true
        else

            return false
        end

    end
end

timer.Create("zlm_Timer_Mowing", 0.1, 0, function()
    if zlm.config.SimpleGrassMode.Enabled then
        zlm.f.SimpleMowLogic()
    else
        zlm.f.MowLogic()
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

////////////////////////////////////

function zlm.f.Save_GrassSpots()

    if table.Count(zlm_GrassSpots) <= 0 then
        return
    end

    local data = {}

    for k, v in pairs(zlm_GrassSpots) do
        table.insert(data, {
            pos = v.pos,
            id = v.id
        })
    end

    if not file.Exists("zlm", "DATA") then
        file.CreateDir("zlm")
    end

    file.Write("zlm/" .. string.lower(game.GetMap()) .. "_grassspots" .. ".txt", util.TableToJSON(data,true))

    zlm.f.Send_GrassSpots_ToClients()
end

function zlm.f.Load_GrassSpots()
    if zlm.config.SimpleGrassMode.Enabled == false then
        if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_grassspots" .. ".txt", "DATA") then

            local data = file.Read("zlm/" .. string.lower(game.GetMap()) .. "_grassspots" .. ".txt", "DATA")
            data = util.JSONToTable(data)

            if data and table.Count(data) > 0 then
                for k, v in pairs(data) do
                    zlm.f.Add_GrassSpot(v.pos,v.id)
                end

                print("[Zeros LawnMower] Finished loading GrassSpots.")
            end
        else
            print("[Zeros LawnMower] No map data found for GrassSpots. Please place some and do !savezlm to create the data.")
        end
    end
end

function zlm.f.Remove_GrassSpots()
    if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_grassspots" .. ".txt", "DATA") then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

        file.Delete( "zlm/" .. string.lower(game.GetMap()) .. "_grassspots" .. ".txt")
    end

    zlm_GrassSpots = {}
    zlm.f.Send_GrassSpots_ToClients()
end

timer.Simple(0,function()
	zlm.f.Load_GrassSpots()
end)
function zlm.f.CleanUp_GrassSpots()
    if zlm.config.SimpleGrassMode.Enabled == false then
        zlm.f.Load_GrassSpots()
        timer.Simple(3,function()
            zlm.f.Send_GrassSpots_ToClients()
        end)
    end
end

hook.Add("PostCleanupMap", "a_zlm_PostCleanupMap_Load_GrassSpots", zlm.f.CleanUp_GrassSpots)

concommand.Add( "zlm_save_grassspots", function( ply, cmd, args )

    if IsValid(ply) and zlm.f.IsAdmin(ply) then
        zlm.f.Notify(ply, "GrassSpot´s have been saved for the map " .. game.GetMap() .. "!", 0)
        zlm.f.Save_GrassSpots()
    end
end )

concommand.Add( "zlm_remove_grassspots", function( ply, cmd, args )

    if IsValid(ply) and zlm.f.IsAdmin(ply) then
        zlm.f.Notify(ply, "GrassSpot´s have been removed for the map " .. game.GetMap() .. "!", 0)
        zlm.f.Remove_GrassSpots()
    end
end )


////////////////////////////////////
