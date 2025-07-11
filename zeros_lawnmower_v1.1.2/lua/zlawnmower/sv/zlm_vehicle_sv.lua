/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if (not SERVER) then return end

zlm = zlm or {}
zlm.f = zlm.f or {}


hook.Add("PlayerEnteredVehicle", "a_zlm_PlayerEnteredVehicle", function(ply, veh, role)
    if IsValid(veh.zlm_LawnMower) then
        zlm.f.EnterVehicle(veh,ply)
    end
end)

function zlm.f.EnterVehicle(veh,ply)
    veh.zlm_LawnMower:SetIsRunning(true)
    ply.zlm_LawnMower = veh.zlm_LawnMower

    zlm.f.SetNWPlayerVars(ply)
end



hook.Add("PlayerLeaveVehicle", "a_zlm_PlayerLeaveVehicle", function(ply, veh)
    if IsValid(veh.zlm_LawnMower) then
        zlm.f.ExitVehicle(veh,ply)
    end
end)

function zlm.f.ExitVehicle(veh,ply)
    veh.zlm_LawnMower:SetIsRunning(false)
    zlm.f.Stop_Mowing(veh.zlm_LawnMower,ply)
    ply.zlm_LawnMower = nil

    zlm.f.SetNWPlayerVars(ply)
end



local function PlayerButtonLogic(ply,key)
    local lawnmower = ply.zlm_LawnMower
    local GrassStorage = lawnmower:GetGrassStorage()

    if key == zlm.config.LawnMower.Keys.StartBlades then

        if lawnmower:GetHasCorb () == false then
            zlm.f.Notify(ply, zlm.language.General["GrassBasketMissing"], 1)
            return
        end

        if lawnmower:GetIsMowing() then
            zlm.f.Stop_Mowing(lawnmower)
        else
            if zlm.f.VCMod_Installed() and lawnmower.Vehicle:VC_fuelGet(true) <= 0 then
                zlm.f.Notify(ply, zlm.language.General["NotEnoughFuel"], 1)
                return
            end

            if GrassStorage >= zlm.config.LawnMower.StorageCapacity then
                zlm.f.Notify(ply, zlm.language.General["GrassStorageFull"], 1)
                return
            end

            zlm.f.Start_Mowing(lawnmower)
        end

    elseif key == zlm.config.LawnMower.Keys.Unload then

        // Unloads the Grass to the Press or sells the grass rolls
        if IsValid(lawnmower.Trailer) then
            zlm.f.SellGrassRolls(ply,lawnmower.Trailer)
        elseif lawnmower:GetHasCorb() then
            zlm.f.UnloadingGrass(lawnmower,ply)
        end


    elseif key == zlm.config.LawnMower.Keys.Connect then

        zlm.f.ConnectLogic(ply,lawnmower)
    end
end

local zlm_PlayerButtonDown_CoolDown = -1
hook.Add("PlayerButtonDown", "a_zlm_PlayerButtonDown", function(ply, key)

    if IsValid(ply.zlm_LawnMower) and CurTime() > zlm_PlayerButtonDown_CoolDown then
        PlayerButtonLogic(ply,key)
        zlm_PlayerButtonDown_CoolDown = CurTime() + 0.25
    end
end)

function zlm.f.ConnectLogic(ply,tractor)

    if tractor:GetHasCorb() then

        // Dettach Corb
        zlm.f.DettachCorb(tractor)

        zlm.f.Stop_Mowing(tractor)
    else
        // If the tractor has a trailer attachen then we dettach the trailer or find a module that we can connect
        if IsValid(tractor.Trailer_contraint) then

            zlm.f.DettachTrailer(ply,tractor)
        else

            // Makes a list of corb or trailer entites in distance and attach the first entry in the table
            zlm.f.FindConnectModule(tractor,ply)
        end
    end
end

// Searches for a corb or trailer in distance to connect it to the tractor
function zlm.f.FindConnectModule(tractor,ply)

    local connectEnts = {}
    for k, v in pairs(ents.FindInSphere(tractor:GetPos(), 100)) do
        if IsValid(v) and (v:GetClass() == "zlm_tractor_trailer" or v:GetClass() == "zlm_corb") then
            table.insert(connectEnts,v)
        end
    end

    if table.Count(connectEnts) > 0 then

        if IsValid(connectEnts[1]) then

            if connectEnts[1]:GetClass() == "zlm_tractor_trailer" then

                // Connect Trailer
                zlm.f.AttachTrailer(ply,tractor,connectEnts[1])

            elseif connectEnts[1]:GetClass() == "zlm_corb" then

                // Connect Corb
                zlm.f.AttachCorb(tractor,connectEnts[1])
                zlm.f.Notify(ply, zlm.language.General["GrassBasketAttached"], 0)

            end
        end
    else

        zlm.f.Notify(ply, zlm.language.General["NoTrailerBasketFound"], 1)
    end
end



// Dettaches the corb to the tractor
function zlm.f.DettachCorb(tractor)

    local ent = ents.Create("zlm_corb")

    local ang = tractor:GetAngles()
    ang:RotateAroundAxis(tractor:GetUp(),-90)
    ent:SetAngles(ang)

    ent:SetPos(tractor:GetPos() + tractor:GetRight() * 95 + tractor:GetUp() * 25)
    ent:Spawn()
    ent:Activate()

    zlm.f.SetOwner(ent, zlm.f.GetOwner(tractor))

    tractor:DeleteOnRemove(ent)

    local tractor_grass = tractor:GetGrassStorage()

    if tractor_grass > 0 then
        ent:SetGrassStorage(tractor_grass)
        ent:SetBodygroup(0,1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

        // Resets the grassStorage of the tractor
        tractor:SetGrassStorage(0)
    end

    tractor.Vehicle:SetBodygroup(1, 0)
    tractor.Vehicle:SetBodygroup(2, 0)
    tractor:SetHasCorb(false)
end

// Attaches the corb to the tractor
function zlm.f.AttachCorb(tractor,corb)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

    // Transfer grass if there is some from the corb ent to the tractor
    local corb_grass = corb:GetGrassStorage()
    if corb_grass > 0 then
        tractor:SetGrassStorage(corb_grass)
    end

    corb:Remove()
    tractor.Vehicle:SetBodygroup(1, 1)
    tractor.Vehicle:SetBodygroup(2, 1)
    tractor:SetHasCorb(true)
end



// Checks if the trailer is close enough and connects it to the Tractor
function zlm.f.AttachTrailer(ply, tractor, trailer)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    local tPos = tractor:GetPos() + tractor:GetRight() * 65

    local attach = trailer.FrontAxl:GetAttachment(3)

    if zlm.f.InDistance(tPos, attach.Pos, 25) then

        constraint.NoCollide( tractor.Vehicle, trailer, 0, 0 )
        constraint.NoCollide( tractor.Vehicle, trailer.FrontAxl, 0, 0 )

        local fa_phys = trailer.FrontAxl:GetPhysicsObject()
        if IsValid(fa_phys) then
            fa_phys:Wake()
            fa_phys:EnableMotion(false)
        end

        local tr_phys = trailer:GetPhysicsObject()
        if IsValid(tr_phys) then
            tr_phys:Wake()
            tr_phys:EnableMotion(true)
        end

        local ang = tractor:GetAngles()
        ang:RotateAroundAxis(tractor:GetUp(),-90)
        trailer.FrontAxl:SetAngles(ang)

        local pos = tractor:GetPos() + tractor:GetRight() * 96 + tractor:GetUp() * -8

        trailer.FrontAxl:SetPos(pos)

        local vAttach = tractor.Vehicle:GetAttachment(13)
        local lPos01 = tractor.Vehicle:WorldToLocal(vAttach.Pos + vAttach.Ang:Right() * 2)
        local lPos02 = trailer.FrontAxl:WorldToLocal(vAttach.Pos)

        tractor.Trailer_contraint = constraint.Axis( tractor.Vehicle, trailer.FrontAxl, 0, 0, lPos01, lPos02, 0, 0, 0, 1, nil, false )


        timer.Simple(0.2, function()
            if IsValid(fa_phys) then
                fa_phys:Wake()
                fa_phys:EnableMotion(true)
            end
        end)


        tractor.Trailer = trailer

        tractor:SetHasTrailer(true)
        // 288688181
        zlm.f.Notify(ply, zlm.language.General["TrailerAttached"], 0)
    else
        zlm.f.Notify(ply, zlm.language.General["TrailerNotCloseEnough"], 1)
    end

    zlm.f.SetNWPlayerVars(ply)
end

// Dettaches the trailer
function zlm.f.DettachTrailer(ply,tractor)

    local fa_phys = tractor.Trailer.FrontAxl:GetPhysicsObject()
    if IsValid(fa_phys) then
        fa_phys:Wake()
        fa_phys:EnableMotion(false)
    end

    local tr_phys = tractor.Trailer:GetPhysicsObject()
    if IsValid(tr_phys) then
        tr_phys:Wake()
        tr_phys:EnableMotion(false)
    end

    tractor.Trailer_contraint:Remove()
    tractor.Trailer = nil
    tractor:SetHasTrailer(false)
    zlm.f.Notify(ply, zlm.language.General["TrailerDeAttached"], 0)

    zlm.f.SetNWPlayerVars(ply)
end

// This sets the NW Vars for the players 2d indication interface
function zlm.f.SetNWPlayerVars(ply)

    local inTractor = IsValid(ply.zlm_LawnMower)
    local hasTrailer

    if inTractor then
        hasTrailer = IsValid(ply.zlm_LawnMower.Trailer)
    else
        hasTrailer = false
    end

    ply:SetNWBool("zlm_InTractor", inTractor)
    ply:SetNWBool("zlm_HasTrailer", hasTrailer)

    zlm.f.Debug("zlm.f.SetNWPlayerVars")
    zlm.f.Debug("zlm_InTractor: " .. tostring(inTractor))
    zlm.f.Debug("zlm_HasTrailer: " .. tostring(hasTrailer))
    zlm.f.Debug("_____________________")
end



function zlm.f.Start_Mowing(lawnmower)
    lawnmower:SetIsMowing(true)
    zlm.f.Debug("Start LawnMower Blade")
end

function zlm.f.Stop_Mowing(lawnmower)
    lawnmower:SetIsMowing(false)
    zlm.f.Debug("Stop LawnMower Blade")
end

function zlm.f.UnloadingGrass(lawnmower,ply)


    if zlm.f.VCMod_Installed() and lawnmower.Vehicle:VC_fuelGet(true) <= 0 then
        zlm.f.Notify(ply, zlm.language.General["NotEnoughFuel"], 1)
        return
    end

    zlm.f.Stop_Mowing(lawnmower)

    local GrassStorage = lawnmower:GetGrassStorage()

    if GrassStorage <= 0 then
        zlm.f.Notify(ply, zlm.language.General["GrassStorageEmpty"], 1)
        return
    end

    local GrassPress

    for k, v in pairs(ents.FindInSphere(lawnmower:GetPos(),300)) do
        if IsValid(v) and v:GetClass() == "zlm_grasspress" then
            GrassPress = v
            break
        end
    end

    if IsValid(GrassPress) then

        if (GrassPress:GetGrassCount() + GrassStorage) > zlm.config.GrassPress.Capacity then
            zlm.f.Notify(ply, zlm.language.General["GrassPressFull"], 1)
            return
        end

        zlm.f.Start_Unloading(GrassPress,lawnmower,ply)
    else
        zlm.f.Notify(ply, zlm.language.General["NoGrassPressFound"], 1)
    end
end

function zlm.f.Start_Unloading(GrassPress,lawnmower,ply)

    lawnmower.Vehicle:SetBodygroup(0,1)
    lawnmower:SetIsUnloading(true)

    zlm.f.Debug("Unloading LawnMower")
    zlm.f.Notify(ply, zlm.language.General["UnloadingLawnMower"], 0)

    timer.Simple(3,function()
        if IsValid(lawnmower) and IsValid(GrassPress) then
            zlm.f.Finished_Unloading(GrassPress,lawnmower,ply)
        end
    end)
end

function zlm.f.Finished_Unloading(GrassPress,lawnmower,ply)

    local grassStorage = lawnmower:GetGrassStorage()

    zlm.f.AddGrass(GrassPress,grassStorage)

    lawnmower:SetGrassStorage(0)
    lawnmower.Vehicle:SetBodygroup(0,0)
    lawnmower:SetIsUnloading(false)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2


    zlm.f.Debug("Finised Unloading")
end

-- Think hook yerine akıllı Timer sistemi (Optimizasyon)
local function CheckAndFreezeVehicles()
    local hasUnloading = false
    
    if zlm_LawnMowers then
        for k, v in pairs(zlm_LawnMowers) do
            if IsValid(v) and IsValid(v.Vehicle) and v:GetIsUnloading() then
                hasUnloading = true
                local phys = v.Vehicle:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(phys:GetVelocity() * -1)
                end
            end
        end
    end
    
    -- Unloading yapan araç yoksa timer'ı durdur
    if not hasUnloading then
        timer.Remove("zlm_Timer_FreezeVehicles")
    end
end

-- Unloading başladığında timer'ı başlat
local oldStartUnloading = zlm.f.Start_Unloading
zlm.f.Start_Unloading = function(...)
    oldStartUnloading(...)
    if not timer.Exists("zlm_Timer_FreezeVehicles") then
        timer.Create("zlm_Timer_FreezeVehicles", 0.1, 0, CheckAndFreezeVehicles)
    end
end

function zlm.f.CrashedInWater(LawnMower)
    if LawnMower:GetIsMowing() then
        zlm.f.Stop_Mowing(LawnMower)
    end

    if LawnMower:GetIsRunning() then
        LawnMower:SetIsRunning(false)
    end
end

// This makes sure the trailer or its wheels can not be picked up
hook.Add("GravGunPickupAllowed","a_zlm_GravGunPickupAllowed",function(ply,ent)
    if IsValid(ent) and ent.zlm_GravgunDisabled then
        return false
    end
end)







// Global Lawnmower
concommand.Add( "zlm_save_lawnmower", function( ply, cmd, args )

    if IsValid(ply) and zlm.f.IsAdmin(ply) then
        zlm.f.Notify(ply, "Lawnmower entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zlm.f.Save_Lawnmower()
    end
end )

concommand.Add( "zlm_remove_lawnmower", function( ply, cmd, args )

    if IsValid(ply) and zlm.f.IsAdmin(ply) then
        zlm.f.Notify(ply, "Lawnmower entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zlm.f.Remove_Lawnmower()
    end
end )

function zlm.f.Save_Lawnmower()
    local data = {}

    for u, j in pairs(ents.FindByClass("zlm_tractor")) do
        table.insert(data, {
            pos = j:GetPos(),
            ang = j:GetAngles(),
            class = j:GetClass(),
        })
    end

    for u, j in pairs(ents.FindByClass("zlm_tractor_trailer")) do
        table.insert(data, {
            pos = j:GetPos(),
            ang = j:GetAngles(),
            class = j:GetClass(),
        })
    end

    if not file.Exists("zlm", "DATA") then
        file.CreateDir("zlm")
    end

    if table.Count(data) > 0 then

        file.Write("zlm/" .. string.lower(game.GetMap()) .. "_lawnmower" .. ".txt", util.TableToJSON(data))
    end
end

function zlm.f.Load_Lawnmower()
    if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_lawnmower" .. ".txt", "DATA") then
        local data = file.Read("zlm/" .. string.lower(game.GetMap()) .. "_lawnmower" .. ".txt", "DATA")
        data = util.JSONToTable(data)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create(v.class)
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()


                local phys = ent:GetPhysicsObject()

                if (phys:IsValid()) then
                    phys:Wake()
                    if v.class == "zlm_tractor_trailer" then
                        phys:EnableMotion(false)
                    else
                        phys:EnableMotion(true)
                    end
                end
            end

            print("[Zeros LawnMower] Finished loading Lawnmower Entities.")
        end
    else
        print("[Zeros LawnMower] No map data found for Lawnmower entities. Please place some and do !savezlm to create the data.")
    end
end

function zlm.f.Remove_Lawnmower()
    if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_lawnmower" .. ".txt", "DATA") then
        file.Delete("zlm/" .. string.lower(game.GetMap()) .. "_lawnmower" .. ".txt")
    end

    for k, v in pairs(ents.FindByClass("zlm_tractor")) do
        if IsValid(v) then
            v:Remove()
        end
    end

    for k, v in pairs(ents.FindByClass("zlm_tractor_trailer")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

timer.Simple(0, function()
    zlm.f.Load_Lawnmower()
end)
hook.Add("PostCleanupMap", "a_zlm_SpawnLawnmowerPostCleanUp", zlm.f.Load_Lawnmower)
