/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Filter = zmlab2.Filter or {}

/*

    The Filter combines Acid, Methylamin and Aluminium
        Filter Gameplay: https://i.imgur.com/GcXASku.png
            Small game which needs to be solved in a short amount of time

        Gameplay fail time depends on meth type

        Can change MethType:
            Normal meth
            Blue meth
            Kalaxian Crystal
            Glitter Meth (Cyberpunk 2077) https://cyberpunk.fandom.com/wiki/Glitter
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        Press Connection Button and select Pump Target to move the acid to the next machine

        Filter:GetProcessState()
            0 = Need Mixer Liquid
            1 = Press the Start Button
            2 = Filtering
            //3 = HasError <- This state doesent exist anymore
            4 = Move liquid to filler machine
            5 = Moving liquid
            6 = Needs to be cleaned
*/


function zmlab2.Filter.Initialize(Filter)
    zclib.EntityTracker.Add(Filter)

    if zmlab2.config.Equipment.PlayerCollide == false then
        Filter:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end

    Filter:SetMaxHealth( zmlab2.config.Damageable[Filter:GetClass()] )
    Filter:SetHealth(Filter:GetMaxHealth())
end

function zmlab2.Filter.OnRemove(Filter)
    zclib.Timer.Remove("zmlab2_Filter_cycle_" .. Filter:EntIndex())
end

function zmlab2.Filter.SetBusy(Filter,time)
    Filter.IsBusy = true
    timer.Simple(time,function()
        if IsValid(Filter) then
            Filter.IsBusy = false
        end
    end)
end

function zmlab2.Filter.OnUse(Filter, ply)
    if Filter.IsBusy == true then return end

    if not zmlab2.Player.CanInteract(ply, Filter) then return end

    local _state = zmlab2.Filter.GetState(Filter)

    // Filter Solution
    if _state == 1 and Filter:OnStart(ply) then
        zclib.Sound.EmitFromEntity("button_change", Filter)
        Filter:SetProgress(0)
        zmlab2.Filter.Cycle_Started(Filter)
    end

    // Open error mini game interface
    if Filter:GetErrorStart() > 0 and Filter:OnErrorButton(ply) then
        zclib.Sound.EmitFromEntity("button_change", Filter)

        zmlab2.MiniGame.Respond(Filter,ply)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    // Move liquid to next machine
    if _state == 4 and Filter:OnStart(ply) then
        zmlab2.PumpSystem.EnablePointer(Filter,ply)
    end

    // Cleaning action
    if _state == 6 then

        zmlab2.Cleaning.Inflict(Filter,ply,function()
            Filter:SetProcessState(0)
            Filter:SetBodygroup(0,0)
        end)
    end
end

function zmlab2.Filter.GetState(Filter)
    return Filter:GetProcessState()
end

function zmlab2.Filter.Cycle_Started(Filter)
    zclib.Debug("zmlab2.Filter.Cycle_Started")

    Filter:SetProcessState(2)

    local filter_time = zmlab2.Meth.GetFilterTime(Filter:GetMethType())

    // Start the filtering process
    local timerid = "zmlab2_Filter_cycle_" .. Filter:EntIndex()
    zclib.Timer.Create(timerid,1,0,function()

        if not IsValid(Filter) then
            zclib.Timer.Remove(timerid)
            return
        end

        // Every second it will filter

        // Instant pollution check instead of pollution producer timer
        zmlab2.Ventilation.Check(Filter:GetPos(),zmlab2.config.PollutionSystem.AmountPerMachine["Filter_Cycle"])

        // If we are currently having a error then stop
        if Filter:GetErrorStart() > 0 then
            return
        end

        // Increase progress
        Filter:SetProgress(Filter:GetProgress() + 1)

        // Are we finished?
        if Filter:GetProgress() >= filter_time then
            zmlab2.Filter.Finished(Filter)
            zclib.Timer.Remove(timerid)
            return
        end

        if Filter.NextError then
            if CurTime() > Filter.NextError then

                // Start the mini game
				zmlab2.MiniGame.StartRandom(Filter)

                Filter.NextError = nil
            end
        else
            local ErrorChance = math.random(100)
            local ErrorThreshold = 15 + (80 / 10) * zmlab2.Meth.GetDifficulty(Filter:GetMethType())

            if ErrorChance <= ErrorThreshold then
                local NextTime = (filter_time / 3) / (zmlab2.config.MiniGame.OccurrenceMultiplier or 1)

                NextTime = NextTime * math.Rand(0.8, 1)
                Filter.NextError = CurTime() + NextTime
            end
        end
    end)
end

function zmlab2.Filter.Finished(Filter)
    zclib.Debug("zmlab2.Filter.Cycle_Finished")
    Filter:SetProcessState(4)
end

function zmlab2.Filter.Reset(Filter)
    Filter:SetProgress(0)
    Filter:SetMethQuality(1)
    zclib.Timer.Remove("zmlab2_Filter_cycle_" .. Filter:EntIndex())
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6



// Get called when the Pumping System started unloading this Machine
function zmlab2.Filter.Unloading_Started(Filter)
    zclib.Debug("zmlab2.Filter.Unloading_Started")
    Filter:SetProcessState(5)
end

// Get called when the Pumping System finished unloading this Machine
function zmlab2.Filter.Unloading_Finished(Filter)
    zclib.Debug("zmlab2.Filter.Unloading_Finished")
    Filter:SetProcessState(6)
    Filter:SetBodygroup(0,1)
    zmlab2.Filter.Reset(Filter)
end

// Get called when the Pumping System started loading this Machine
function zmlab2.Filter.Loading_Started(Filter)
    zclib.Debug("zmlab2.Filter.Loading_Started")
    // NOT USED
end

// Get called when the Pumping System finished loading this Machine
function zmlab2.Filter.Loading_Finished(Filter,Mixer)
    zclib.Debug("zmlab2.Filter.Loading_Finished")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    Filter:SetMethType(Mixer:GetMethType())
    Filter:SetMethQuality(Mixer:GetMethQuality())

    Mixer:SetMethQuality(1)

    // Now we got the mixer liquid
    Filter:SetProcessState(1)
end

/*
concommand.Add("zmlab2_debug_Filter_Test", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        local tr = ply:GetEyeTrace()

        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zmlab2_machine_filter" then
            tr.Entity:SetProgress(0)
            tr.Entity:SetMethType(1)
            tr.Entity:SetMethQuality(80)
            tr.Entity:SetProcessState(1)
            tr.Entity.ErrorTime = math.random(4,8)
        end
    end
end)

concommand.Add("zmlab2_debug_Filter_Reset", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

        local tr = ply:GetEyeTrace()

        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zmlab2_machine_filter" then
            zmlab2.Filter.Reset(tr.Entity)
            tr.Entity:SetProcessState(0)
        end
    end
end)
*/
