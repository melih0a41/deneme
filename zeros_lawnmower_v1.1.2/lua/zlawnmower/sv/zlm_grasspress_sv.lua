/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if (not SERVER) then return end
zlm = zlm or {}
zlm.f = zlm.f or {}

function zlm.f.AddGrass(grasspress, amount)
    grasspress:SetGrassCount(grasspress:GetGrassCount() + amount)
    zlm.f.Debug("AddGrass: " .. grasspress:GetGrassCount())
    if zlm.f.GrassPress_RollCountCheck(grasspress) then
        zlm.f.GrassPress_ProductionCheck(grasspress)
    end
end

function zlm.f.GrassPress_Use(grasspress, ply)
    if grasspress.IsSpawningRoll then return end

    if grasspress:EnableButton(ply) then

        if zlm.f.GrassPress_RollCountCheck(grasspress) == false then
            zlm.f.Notify(ply, zlm.language.General["GrassRollLimitReached"], 1)
            return
        end

        grasspress:SetIsRunning(not grasspress:GetIsRunning())

        if grasspress:GetIsRunning() then
            // Start Machine
            zlm.f.GrassPress_ProductionCheck(grasspress)

        else
            // Stop Machine
            zlm.f.GrassPress_StopMachine(grasspress)
        end
    end

    if zlm.config.GrassPress.Upgrades.Enabled and grasspress:UpgradButton(ply) then
        zlm.f.GrassPress_Upgrade(grasspress, ply)
    end
end

function zlm.f.GrassPress_OnRemove(grasspress)
    zlm.f.Timer_Remove("zlm_grasspress_producetimer_" .. grasspress:EntIndex())
end

function zlm.f.GrassPress_ProductionCheck(grasspress)
    if grasspress:GetIsRunning() == false then return end
    local grassStorage = grasspress:GetGrassCount()

    if grasspress:GetProgressState() == 0 then
        if grassStorage >= zlm.config.GrassPress.Production_Amount then
            zlm.f.GrassPress_Produce_GrassRoll(grasspress)
            zlm.f.Debug("Starting Production")
        else
            zlm.f.Debug("Not enough Grass!")
        end
    else
        zlm.f.Debug("Machine is Busy!")
    end
end

function zlm.f.GrassPress_Produce_GrassRoll(grasspress)
    // Start Inserting Grass
    grasspress:SetProgressState(1)
    zlm.f.Debug("Start Inserting Grass")

    local p_Time
    if zlm.config.GrassPress.Upgrades.Enabled then
        //p_Time = zlm.config.GrassPress.Production_Time - ((zlm.config.GrassPress.Production_Time / zlm.config.GrassPress.Upgrades.Count) * grasspress:GetUpgradeLevel())
        p_Time = zlm.config.GrassPress.Production_Time - zlm.config.GrassPress.Production_TimeLimit
        p_Time = (p_Time / zlm.config.GrassPress.Upgrades.Count) * grasspress:GetUpgradeLevel()
        p_Time =  zlm.config.GrassPress.Production_Time - p_Time
        p_Time = math.Clamp(math.Round(p_Time), zlm.config.GrassPress.Production_TimeLimit, zlm.config.GrassPress.Production_Time)
    else
        p_Time = zlm.config.GrassPress.Production_Time
    end

    grasspress:SetProduction_TimeStamp(CurTime() + p_Time)

    zlm.f.Timer_Create("zlm_grasspress_producetimer_" .. grasspress:EntIndex(), p_Time, 1,function()
        if IsValid(grasspress) then

            grasspress:SetGrassCount(grasspress:GetGrassCount() - zlm.config.GrassPress.Production_Amount)

            // Release Grass Roll
            grasspress:SetProgressState(2)

            zlm.f.Debug("Release Grass Roll")
            grasspress.IsSpawningRoll = true

            grasspress:SetProduction_TimeStamp(-1)

            timer.Simple(2.33, function()
                if IsValid(grasspress) then

                    // Spawn Grass Roll
                    zlm.f.GrassPress_SpawnGrassRoll(grasspress)
                    grasspress.IsSpawningRoll = false
                end
            end)
        end
    end)
end

function zlm.f.GrassPress_StopMachine(grasspress)
    zlm.f.Timer_Remove("zlm_grasspress_producetimer_" .. grasspress:EntIndex())
    grasspress:SetProduction_TimeStamp(-1)
    grasspress:SetProgressState(0)
end

// Checks if the GrassPress is allowed to produce another grassroll
function zlm.f.GrassPress_RollCountCheck(grasspress)

    local count = 0

    for k, v in pairs(grasspress.ProducedRolls) do
        if IsValid(v) then
            count = count + 1
        end
    end

    if count < zlm.config.GrassPress.GrassRoll_Limit then
        return true
    else
        return false
    end
end

function zlm.f.GrassPress_SpawnGrassRoll(grasspress)
    zlm.f.Debug("SpawnGrassRoll")

    local ent = ents.Create("zlm_grassroll")
    ent:SetPos(grasspress:GetPos() - grasspress:GetForward() * 80 + grasspress:GetUp() * 40)
    ent:Spawn()
    ent:Activate()

    table.insert(grasspress.ProducedRolls,ent)

    if grasspress.IsPublicEntity == true then
        zlm.f.Timer_Create("zlm_GrassrollRemover_" .. ent:EntIndex(), 600, 1, function()
            if IsValid(ent) then
                SafeRemoveEntity(ent)
                zlm.f.Timer_Remove("zlm_GrassrollRemover_" .. ent:EntIndex())
            end
        end)
    end

    zlm.f.GrassPress_StopMachine(grasspress)

    if zlm.f.GrassPress_RollCountCheck(grasspress) then
        zlm.f.GrassPress_ProductionCheck(grasspress)
    else
        grasspress:SetIsRunning(false)
    end
end



function zlm.f.GrassPress_Upgrade(grasspress, ply)
    if table.Count(zlm.config.GrassPress.Upgrades.Ranks) > 0 and not table.HasValue(zlm.config.GrassPress.Upgrades.Ranks, ply:GetUserGroup()) then
        return
    end

    if grasspress:GetUpgradeLevel() >= zlm.config.GrassPress.Upgrades.Count then return end

    if CurTime() < grasspress:GetUCooldDown() then return end

    if not zlm.f.HasMoney(ply, zlm.config.GrassPress.Upgrades.Price) then
        zlm.f.Notify(ply, zlm.language.General["NotEnoughMoney"], 1)
        return
    end

    zlm.f.TakeMoney(ply, zlm.config.GrassPress.Upgrades.Price)

    local soundData = zlm.f.CatchSound("zlm_selling")
    grasspress:EmitSound(soundData.sound, soundData.lvl, soundData.pitch, soundData.volume, CHAN_STATIC)

    zlm.f.Machine_LevelUp(grasspress)

    zlm.f.Notify(ply, zlm.language.General["GrassPressSpeedIncreased"], 0)
    zlm.f.Notify(ply, "-" .. zlm.config.Currency .. zlm.config.GrassPress.Upgrades.Price, 0)
    // 288688181
    if grasspress:GetUpgradeLevel() < zlm.config.GrassPress.Upgrades.Count then
        grasspress:SetUCooldDown(CurTime() + zlm.config.GrassPress.Upgrades.Cooldown)
    end

    // If the machine is running then we restart it
    zlm.f.GrassPress_StopMachine(grasspress)
    zlm.f.GrassPress_ProductionCheck(grasspress)
end

function zlm.f.Machine_LevelUp(grasspress)
    grasspress:SetUpgradeLevel(grasspress:GetUpgradeLevel() + 1)
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

// Global GrassPress
concommand.Add( "zlm_save_grasspress", function( ply, cmd, args )

    if IsValid(ply) and zlm.f.IsAdmin(ply) then
        zlm.f.Notify(ply, "GrassPress entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zlm.f.Save_GrassPress()
    end
end )

concommand.Add( "zlm_remove_grasspress", function( ply, cmd, args )

    if IsValid(ply) and zlm.f.IsAdmin(ply) then
        zlm.f.Notify(ply, "GrassPress entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zlm.f.Remove_GrassPress()
    end
end )

function zlm.f.Save_GrassPress()
    local data = {}

    for u, j in pairs(ents.FindByClass("zlm_grasspress")) do
        table.insert(data, {
            pos = j:GetPos(),
            ang = j:GetAngles()
        })
    end

    if not file.Exists("zlm", "DATA") then
        file.CreateDir("zlm")
    end
    if table.Count(data) > 0 then
        file.Write("zlm/" .. string.lower(game.GetMap()) .. "_grasspress" .. ".txt", util.TableToJSON(data))
    end
end

function zlm.f.Load_GrassPress()
    if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_grasspress" .. ".txt", "DATA") then
        local data = file.Read("zlm/" .. string.lower(game.GetMap()) .. "_grasspress" .. ".txt", "DATA")
        data = util.JSONToTable(data)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("zlm_grasspress")
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()

                local phys = ent:GetPhysicsObject()

                if (phys:IsValid()) then
                    phys:Wake()
                    phys:EnableMotion(false)
                end

                ent.IsPublicEntity = true
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

            print("[Zeros LawnMower] Finished loading GrassPress Entities.")
        end
    else
        print("[Zeros LawnMower] No map data found for GrassPress entities. Please place some and do !savezlm to create the data.")
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function zlm.f.Remove_GrassPress()
    if file.Exists("zlm/" .. string.lower(game.GetMap()) .. "_grasspress" .. ".txt", "DATA") then
        file.Delete("zlm/" .. string.lower(game.GetMap()) .. "_grasspress" .. ".txt")
    end

    for k, v in pairs(ents.FindByClass("zlm_grasspress")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

timer.Simple(0,function()
	zlm.f.Load_GrassPress()
end)
hook.Add("PostCleanupMap", "a_zlm_SpawnGrassPressPostCleanUp", zlm.f.Load_GrassPress)
