/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Frezzer = zmlab2.Frezzer or {}

/*
        Frezzer:
			Add Freezer Liquid [5 Uses]
			Add full Freezer tray cart
			Press Start

        ProcessState
            0 = Needs Lox
            1 = Idle
            2 = Frezzing

*/

local function GetDeltaTime()
    local deltime = FrameTime() * 2
    if not game.SinglePlayer() then deltime = FrameTime() * 6 end
    return deltime
end

function zmlab2.Frezzer.Initialize(Frezzer)

    Frezzer:PhysicsInit(SOLID_VPHYSICS)
    Frezzer:SetSolid(SOLID_VPHYSICS)
    Frezzer:SetMoveType(MOVETYPE_VPHYSICS)
    Frezzer:SetUseType(SIMPLE_USE)

    Frezzer:UseClientSideAnimation()

    local phys = Frezzer:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end

    Frezzer:SetTrigger(true)

    Frezzer:SetMaxHealth( zmlab2.config.Damageable[Frezzer:GetClass()] )
    Frezzer:SetHealth(Frezzer:GetMaxHealth())

    zclib.EntityTracker.Add(Frezzer)

    if zmlab2.config.Equipment.PlayerCollide == false then
        Frezzer:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end

    Frezzer.Lox = 0

    Frezzer.Trays = {}

    Frezzer.ChildTrays = {}

    local delay = 0.05
    for i = 1, 6 do
        timer.Simple(delay,function()
            if not IsValid(Frezzer) then return end
            local ply = zclib.Player.GetOwner(Frezzer)

            local attach = Frezzer:GetAttachment(i)
            local tray = ents.Create("zmlab2_item_frezzertray")
            if not IsValid(tray) then return end
            tray:SetPos(attach.Pos)
            tray:SetAngles(attach.Ang)
            tray:Spawn()
            tray:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

            Frezzer.Trays[i] = tray

            tray:SetParent(Frezzer, i)

            if IsValid(ply) then
                zclib.Player.SetOwner(tray, ply)
            end

            Frezzer.ChildTrays[i] = tray
        end)
        delay = delay + 0.05
    end
end

function zmlab2.Frezzer.OnRemove(Frezzer)
    zclib.Timer.Remove("zmlab2_Frezzer_cycle_" .. Frezzer:EntIndex())

    // Remove any of its child trays
    for k,v in pairs(Frezzer.ChildTrays) do
        if IsValid(v) then
			v:SetParent(nil)
			v:SetPos(Frezzer:GetPos())
            //v:PhysicsInit(SOLID_NONE)
            SafeRemoveEntity(v)
        end
    end
end

function zmlab2.Frezzer.OnStartTouch(Frezzer,other)
    if not IsValid(Frezzer) then return end
    if not IsValid(other) then return end
    if zclib.util.CollisionCooldown(other) then return end
    if Frezzer.IsBusy == true then return end

    // Freezer is busy frezzing
    if Frezzer:GetProcessState() == 2 then return end

    if other:GetClass() == "zmlab2_item_lox" then

        // Do we even need Liquid Oxygen right now?
        if Frezzer.Lox > 0 then return end
        zmlab2.Frezzer.DelayedAction(Frezzer,GetDeltaTime(),function()
            zmlab2.Frezzer.AddLox(Frezzer,other)
        end)

    elseif other:GetClass() == "zmlab2_item_frezzertray" and other:GetProcessState() < 2 then
        zmlab2.Frezzer.DelayedAction(Frezzer,GetDeltaTime(),function()
            zmlab2.Frezzer.AddTray(Frezzer,other)
        end)
    end
end

// Adds the tray to the first free position it can find and returns the result
function zmlab2.Frezzer.AddTray(Frezzer, tray)
    if not IsValid(Frezzer) then return end
    if not IsValid(tray) then return end

    local Result, TrayPos = false

    local IsAlreadyInList = false
    for i = 1, 6 do
        if IsValid(Frezzer.Trays[i]) and IsValid(Frezzer.Trays[i]) == tray then
            IsAlreadyInList = true
            break
        end
    end

    if IsAlreadyInList == true then
        return Result, TrayPos
    end

    for i = 1, 6 do
        if not IsValid(Frezzer.Trays[i]) then
            DropEntityIfHeld(tray)
            Frezzer.Trays[i] = tray
            tray:SetMoveType(MOVETYPE_NONE)
            local attach = Frezzer:GetAttachment(i)
            tray:SetPos(attach.Pos)
            tray:SetAngles(attach.Ang)
            tray:SetParent(Frezzer, i)
            zclib.Player.SetOwner(tray, zclib.Player.GetOwner(Frezzer))
            zclib.Sound.EmitFromEntity("tray_add", tray)
            Result = true
            TrayPos = i
            break
        end
    end

    return Result, TrayPos
end

// Returns the first empty Tray and ID it can find
function zmlab2.Frezzer.GetEmptyTray(Frezzer)
    local tray,trayid
    for k,v in pairs(Frezzer.Trays) do
        if IsValid(v) and v:GetMethAmount() <= 0 then
            tray = v
            trayid = k
            break
        end
    end
    return tray,trayid
end

// Returns how many trays are full
function zmlab2.Frezzer.GetFullTrays(Frezzer)
    local full = 0

    for i = 1, 6 do
        if not IsValid(Frezzer.Trays[i]) then continue end
        if Frezzer.Trays[i]:GetMethAmount() <= 0 then continue end
        if Frezzer.Trays[i]:GetProcessState() ~= 1 then continue end
        full = full + 1
    end

    return full
end

// Returns a tray which can be dropped
function zmlab2.Frezzer.GetTray(Frezzer)
    local tray,trayid
    for k,v in pairs(Frezzer.Trays) do
        if IsValid(v) and v:GetProcessState() ~= 1 then
            tray = v
            trayid = k
            break
        end
    end
    return tray,trayid
end

// Adds the liquid ocican tank
function zmlab2.Frezzer.AddLox(Frezzer,Lox)
    if not IsValid(Frezzer) then return end
    if not IsValid(Lox) then return end

    Frezzer.Lox = zmlab2.config.Frezzer.Lox_Usage

    zclib.Sound.EmitFromEntity("lox_loaded", Frezzer)

    Frezzer:SetProcessState(1)

    // Enable fill bodygroup
    Frezzer:SetBodygroup(0,1)

    // Stop moving if you have physics
    
    local phys = Lox:GetPhysicsObject()
    if IsValid(phys) then phys:EnableMotion(false) end

    -- if Lox.PhysicsDestroy then Lox:PhysicsDestroy() end

    // Hide entity
    -- if Lox.SetNoDraw then Lox:SetNoDraw(true) end

    // This got taken from a Physcollide function but maybe its needed to prevent a crash
    -- SafeRemoveEntityDelayed(Lox, GetDeltaTime())
    Lox:Remove()
end

function zmlab2.Frezzer.GetState(Frezzer)
    return Frezzer:GetProcessState()
end

function zmlab2.Frezzer.SetBusy(Frezzer,time)
    Frezzer.IsBusy = true
    timer.Simple(time,function()
        if IsValid(Frezzer) then
            Frezzer.IsBusy = false
        end
    end)
end

function zmlab2.Frezzer.DelayedAction(Frezzer,time,action)
	// 288688181
    Frezzer.IsBusy = true
    timer.Simple(time,function()
        if IsValid(Frezzer) then
            Frezzer.IsBusy = false
            pcall(action)
        end
    end)
end

function zmlab2.Frezzer.OnUse(Frezzer, ply)

    if Frezzer.IsBusy == true then return end

    if zmlab2.Player.CanInteract(ply, Frezzer) == false then return end

    local _state = zmlab2.Frezzer.GetState(Frezzer)

    if _state < 2 then

        if Frezzer:OnDropTray(ply) then

            local tray,trayid = zmlab2.Frezzer.GetTray(Frezzer)
            if not IsValid(tray) then return end

            if Frezzer.Lox <= 0 then
                return
            end

            tray:SetParent(nil)
            tray:SetPos(Frezzer:LocalToWorld(Vector(20,30,20)))
            tray:SetAngles(Frezzer:LocalToWorldAngles(angle_zero))

            tray:PhysicsInit(SOLID_VPHYSICS)
            tray:SetSolid(SOLID_VPHYSICS)
            tray:SetMoveType(MOVETYPE_VPHYSICS)
            tray:SetUseType(SIMPLE_USE)
            tray:SetCollisionGroup(COLLISION_GROUP_WEAPON)

            local phys = tray:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:EnableMotion(true)
            end

            Frezzer.Trays[trayid] = nil

            zclib.Sound.EmitFromEntity("tray_drop", tray)
        elseif Frezzer:OnStart(ply) then

            if Frezzer.Lox <= 0 then
                return
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

            if zmlab2.Frezzer.GetFullTrays(Frezzer) <= 0 then
                zclib.Notify(ply, zmlab2.language["Frezzer_NeedTray"], 1)
                return
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

            zclib.Sound.EmitFromEntity("button_change", Frezzer)

            zmlab2.Frezzer.Cycle_Started(Frezzer)
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

// Starts the freezing cycle
function zmlab2.Frezzer.Cycle_Started(Frezzer)
    zclib.Debug("zmlab2.Frezzer.Cycle_Started")

    Frezzer:SetFrezzeStart(CurTime())

    Frezzer:SetProcessState(2)

    // Creates a pollution timer for the time being
    zmlab2.PollutionSystem.AddProducer(Frezzer,zmlab2.config.PollutionSystem.AmountPerMachine["Frezzing_Cycle"],zmlab2.config.Frezzer.Time)

    // Start the Frezzering process
    local timerid = "zmlab2_Frezzer_cycle_" .. Frezzer:EntIndex()
    zclib.Timer.Create(timerid,zmlab2.config.Frezzer.Time,1,function()
        if IsValid(Frezzer) then
            zmlab2.Frezzer.Cycle_Finished(Frezzer)
        end
        zclib.Timer.Remove(timerid)
    end)
end

function zmlab2.Frezzer.Cycle_Finished(Frezzer)
    zclib.Debug("zmlab2.Frezzer.Cycle_Finished")

    Frezzer.Lox = math.Clamp(Frezzer.Lox - 1,0,10)

    for k,v in pairs(Frezzer.Trays) do
        if not IsValid(v) then continue end
        if v:GetProcessState() == 1 then
            zmlab2.FrezzerTray.FrezzeLiquid(v)
        end
    end

    if Frezzer.Lox <= 0 then
        Frezzer:SetBodygroup(0,0)
        Frezzer:SetProcessState(0)
    else
        Frezzer:SetProcessState(1)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

concommand.Add("zmlab2_debug_Frezzer_Test", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        local tr = ply:GetEyeTrace()

        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zmlab2_machine_frezzer" then
            tr.Entity:SetMethType(1)
            tr.Entity:SetMethAmount(1000)
            tr.Entity:SetProcessState(1)
        end
    end
end)
