/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.Trashburner = ztm.Trashburner or {}
ztm.Trashburner.List = ztm.Trashburner.List or {}

function ztm.Trashburner.Initialize(TrashBurner)
    zclib.EntityTracker.Add(TrashBurner)

    TrashBurner.IsBusy = false
    TrashBurner.LastPlayer = nil

    table.insert(ztm.Trashburner.List,TrashBurner)
end

function ztm.Trashburner.Touch(TrashBurner, other)
    if TrashBurner.IsBusy then return end
    if TrashBurner:GetTrash() >= ztm.config.TrashBurner.burn_load then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "ztm_trashbag" and other:GetClass() ~= "ztm_trash" then return end
    if zclib.util.CollisionCooldown(other) then return end
    if other:GetTrash() <= 0 then return end
    if TrashBurner:GetIsClosed() then return end

    ztm.Trashburner.AddTrash(TrashBurner, other)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ztm.Trashburner.AddTrash(TrashBurner, trash)
    TrashBurner.IsBusy = true
    TrashBurner:SetTrash(TrashBurner:GetTrash() + trash:GetTrash())
    SafeRemoveEntity(trash)

    timer.Simple(1,function()
        if IsValid(TrashBurner) then
            TrashBurner.IsBusy = false
        end
    end)
end

function ztm.Trashburner.USE(TrashBurner,ply)
    if TrashBurner.IsBusy then return end

    if TrashBurner.IsPublicEntity == nil and zclib.Player.IsOwner(ply, TrashBurner) == false then
        return
    end

    if TrashBurner:OnCloseButton(ply) then
        ztm.Trashburner.SwitchDoor(TrashBurner)
        TrashBurner:EmitSound("ztm_ui_click")
    end

    if TrashBurner:OnStartButton(ply) then
        ztm.Trashburner.StartBurning(TrashBurner,ply)
    end
end

function ztm.Trashburner.SwitchDoor(TrashBurner)
    TrashBurner.IsBusy = true
    TrashBurner:SetIsClosed( not TrashBurner:GetIsClosed() )

    local timerID = "ztm_trashburner_switchdoor_" .. TrashBurner:EntIndex() .. "_timer"
    zclib.Timer.Remove(timerID)

    zclib.Timer.Create(timerID, 1, 1, function()
        zclib.Timer.Remove(timerID)

        if IsValid(TrashBurner) then
            TrashBurner.IsBusy = false
        end
    end)
end

function ztm.Trashburner.StartBurning(TrashBurner,ply)
    if TrashBurner:GetIsClosed() == false then return end
    if TrashBurner:GetTrash() <= 0 then return end

    TrashBurner.LastPlayer = ply
    TrashBurner:EmitSound("ztm_ui_click")

    TrashBurner:SetIsBurning(true)
    TrashBurner:SetStartTime(CurTime())
    TrashBurner.IsBusy = true

    local timerID = "ztm_trashburner_burn_" .. TrashBurner:EntIndex() .. "_timer"
    zclib.Timer.Remove(timerID)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    local exp_time = math.Clamp(TrashBurner:GetTrash() * ztm.config.TrashBurner.burn_time,1,ztm.config.TrashBurner.burn_load * ztm.config.TrashBurner.burn_time)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

    zclib.Timer.Create(timerID, exp_time, 1, function()
        zclib.Timer.Remove(timerID)

        if IsValid(TrashBurner) then
            ztm.Trashburner.FinishBurning(TrashBurner)
        end
    end)
end

function ztm.Trashburner.FinishBurning(TrashBurner)
    TrashBurner.IsBusy = false
    TrashBurner:SetIsBurning(false)
    TrashBurner:SetIsClosed(false)
    TrashBurner:SetStartTime(-1)

    // 288688181
    local trash = TrashBurner:GetTrash()

    local money = trash * ztm.config.TrashBurner.money_per_kg
	money = money * ztm.Player.GetTrashSellMultiplicator(TrashBurner.LastPlayer)

    // Custom Hook
    hook.Run("ztm_OnTrashBurned" ,TrashBurner.LastPlayer, TrashBurner, money, trash)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    // Spawn money
    local pos = TrashBurner:GetPos() +  TrashBurner:GetUp() * 35 + TrashBurner:GetForward() * -60
    ztm.config.MoneySpawn(pos,money,TrashBurner.LastPlayer)

    TrashBurner.LastPlayer = nil
    TrashBurner:SetTrash(0)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381



///////////////////////////////////////////
file.CreateDir("ztm")

concommand.Add( "ztm_trashburner_save", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Trashburner entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Save("ztm_trashburner")
    end
end )

concommand.Add( "ztm_trashburner_remove", function( ply, cmd, args )
    if zclib.Player.IsAdmin(ply) then
        zclib.Notify(ply, "Trashburner entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zclib.STM.Remove("ztm_trashburner")
    end
end )

zclib.STM.Setup("ztm_trashburner", "ztm/" .. string.lower(game.GetMap()) .. "_trashburners.txt", function()
    local data = {}

    for u, j in pairs(ztm.Trashburner.List) do
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
        local ent = ents.Create("ztm_trashburner")
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
        ent:Activate()
        ent.IsPublicEntity = true
        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end
    ztm.Print("Finished loading Trashburner Entities.")
end, function()
    for k, v in pairs(ztm.Trashburner.List) do
        if IsValid(v) then
            v:Remove()
        end
    end
end)
