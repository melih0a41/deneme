/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Dropoff = zmlab2.Dropoff or {}

zmlab2.Dropoff.List = zmlab2.Dropoff.List or {}

function zmlab2.Dropoff.Initialize(Dropoff)
    zclib.EntityTracker.Add(Dropoff)
    table.insert(zmlab2.Dropoff.List,Dropoff)
end

function zmlab2.Dropoff.OnRemove(Dropoff)
    if Dropoff.timerid then zclib.Timer.Remove(Dropoff.timerid) end
end

function zmlab2.Dropoff.OnUse(Dropoff,ply)
    zclib.Debug("zmlab2.Dropoff.OnUse")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

    if zmlab2.Player.IsMethSeller(ply) == false then
        zclib.Notify(ply, zmlab2.language["Interaction_Fail_Job"], 1)
        return
    end

    if ply ~= Dropoff.Deliver_Player then
        zclib.Notify(ply, zmlab2.language["Interaction_Fail_Dropoff"], 1)
        return
    end

    if zmlab2.NPC.GetSellMode(ply) ~= 3 then return end
    if zmlab2.Player.HasMeth(ply) == false then return end

    zmlab2.Dropoff.SellMeth(Dropoff, ply)
end

// Called when meth gets sold via use
function zmlab2.Dropoff.SellMeth(Dropoff,ply)
    if not IsValid(Dropoff) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

    zclib.NetEvent.Create("sell",{[1] = ply:GetPos()})

    zmlab2.NPC.SellMeth(ply,ply.zmlab2_MethList)
    ply.zmlab2_MethList = {}

    zclib.Timer.Remove(Dropoff.timerid)
    zmlab2.Dropoff.Close(Dropoff)
end

function zmlab2.Dropoff.OnStartTouch(Dropoff, other)
    if not IsValid(Dropoff) then return end
    if not IsValid(other) then return end
    if zclib.util.CollisionCooldown(other) then return end

    if Dropoff:GetIsClosed() == true then return end
    if not IsValid(Dropoff.Deliver_Player) then return end


    if other:GetClass() == "zmlab2_item_palette" and table.Count(other.MethList) > 0 then
        zmlab2.Dropoff.Sell(Dropoff, other, other.MethList)
    elseif other:GetClass() == "zmlab2_item_crate" and other:GetMethAmount() > 0 then
        zmlab2.Dropoff.Sell(Dropoff, other, {
            [1] = {t = other:GetMethType(),
            a = other:GetMethAmount(),
            q = other:GetMethQuality()}
        })
    end
end

function zmlab2.Dropoff.Sell(Dropoff,MethEnt,MethList)
    DropEntityIfHeld(MethEnt)

    zclib.NetEvent.Create("sell",{[1] = MethEnt:GetPos()})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

    local phys = MethEnt:GetPhysicsObject()
    if IsValid(phys) then phys:EnableMotion(false) end

    // Stop moving if you have physics
    -- if MethEnt.PhysicsDestroy then MethEnt:PhysicsDestroy() end

    // Hide entity
    -- if MethEnt.SetNoDraw then MethEnt:SetNoDraw(true) end

    // This got taken from a Physcollide function but maybe its needed to prevent a crash
    local ply = zclib.Player.GetOwner(MethEnt)
    if IsValid(ply) then 
        zmlab2.NPC.SellMeth(ply, MethList)
    end

    MethEnt:Remove()

    if Dropoff.timerid then zclib.Timer.Remove(Dropoff.timerid) end
    zmlab2.Dropoff.Close(Dropoff)
end

// Returns a dropoff point thats currently not used by anyone
function zmlab2.Dropoff.FindUnused()
    zclib.Debug("zmlab2.Dropoff.FindUnused")

    local UnUsedDropOffs = {}

    for k, v in pairs(zmlab2.Dropoff.List) do
        if IsValid(v) and not IsValid(v.Deliver_Player) then
            table.insert(UnUsedDropOffs, v)
        end
    end

    if (table.Count(UnUsedDropOffs) > 0) then
        return UnUsedDropOffs[math.random(#UnUsedDropOffs)]
    end
end

// Is the player allowed do get another droppoff point or is there still a cooldown to wait
function zmlab2.Dropoff.Request(ply)
    zclib.Debug("zmlab2.Dropoff.Request")
    if (ply.zmlab2_NextDropoffRequest == nil or ply.zmlab2_NextDropoffRequest < CurTime()) then
        return true
    else
        zclib.Notify(ply, zmlab2.language["Dropoff_cooldown"] .. " " .. zclib.util.FormatTime(math.Round(ply.zmlab2_NextDropoffRequest - CurTime())), 1)
        return false
    end
end

// Assigns a dropoff point to a player
function zmlab2.Dropoff.Assign(Dropoff,ply)
    zclib.Debug("zmlab2.Dropoff.Assign")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    zmlab2.Dropoff.Open(Dropoff, ply)

    zclib.Notify(ply, zmlab2.language["Dropoff_assinged"], 0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    hook.Run("zmlab2_OnDropOffPoint_Assigned", dropoffpoint,ply)
end


util.AddNetworkString("zmlab2_DropOff_AddHint")
util.AddNetworkString("zmlab2_DropOff_RemoveHint")
function zmlab2.Dropoff.Open(Dropoff, ply)
    zclib.Debug("zmlab2.Dropoff.Assign")

    net.Start("zmlab2_DropOff_AddHint")
    net.WriteVector(Dropoff:GetPos())
    net.Send(ply)

    Dropoff.Deliver_Player = ply
    ply.zmlab2_Dropoff = Dropoff

    Dropoff:SetIsClosed(false)

    local timerid = Dropoff:EntIndex() .. "_Dropoff_AutoCloseTimer_" .. ply:SteamID64()
    Dropoff.timerid = timerid
    zclib.Timer.Create(timerid,zmlab2.config.DropOffPoint.DeliverTime,1,function()
        if IsValid(Dropoff) then
            zmlab2.Dropoff.Close(Dropoff)
        end
        zclib.Timer.Remove(timerid)
    end)
end

function zmlab2.Dropoff.Close(Dropoff)
    zclib.Debug("zmlab2.Dropoff.Close")

    if IsValid(Dropoff.Deliver_Player) then
        net.Start("zmlab2_DropOff_RemoveHint")
        net.Send(Dropoff.Deliver_Player)

        Dropoff.Deliver_Player.zmlab2_Dropoff = nil
    end

    Dropoff.Deliver_Player = nil

    Dropoff:SetIsClosed(true)
end
