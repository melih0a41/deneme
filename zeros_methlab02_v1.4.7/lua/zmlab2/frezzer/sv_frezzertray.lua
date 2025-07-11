/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.FrezzerTray = zmlab2.FrezzerTray or {}

/*
    ProcessState
    0 = Empty
    1 = Liquid
    2 = Frozen
*/


function zmlab2.FrezzerTray.Initialize(FrezzerTray)
    zclib.EntityTracker.Add(FrezzerTray)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function zmlab2.FrezzerTray.OnRemove(FrezzerTray)
    zclib.EntityTracker.Remove(FrezzerTray)
end

function zmlab2.FrezzerTray.GetState(FrezzerTray)
    return FrezzerTray:GetProcessState()
end

function zmlab2.FrezzerTray.OnUse(FrezzerTray, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

    if zmlab2.Player.CanInteract(ply, FrezzerTray) == false then return end

    local _state = zmlab2.FrezzerTray.GetState(FrezzerTray)

    if _state == 2 or _state == 3 then

        if FrezzerTray.NextManualIceBreak and CurTime() < FrezzerTray.NextManualIceBreak then return end
        FrezzerTray.NextManualIceBreak = CurTime() + zmlab2.config.Packing.Manual_IceBreak_Interval

        zmlab2.FrezzerTray.BreakIce(FrezzerTray,ply)
    end
end

function zmlab2.FrezzerTray.AddLiquid(FrezzerTray,MethType,MethAmount,MethQuality)
    zclib.Debug("zmlab2.FrezzerTray.AddLiquid")
    FrezzerTray:SetBodygroup(0,1)

    FrezzerTray:SetMethType(MethType)
    FrezzerTray:SetMethAmount(MethAmount)
    FrezzerTray:SetMethQuality(MethQuality)

    local MethData = zmlab2.config.MethTypes[MethType]
    local qual_fract = (1 / 100) * MethQuality
    local col = MethData.color
    local h,s,v = ColorToHSV(col)
    s = s * qual_fract
    col = HSVToColor(h,s,v)
    FrezzerTray:SetColor(col)

    // Tell tray it has liquid
    FrezzerTray:SetProcessState(1)
end

function zmlab2.FrezzerTray.FrezzeLiquid(FrezzerTray)
    zclib.Debug("zmlab2.FrezzerTray.FrezzeLiquid")

    FrezzerTray:SetBodygroup(0,2)
    FrezzerTray:SetSkin(0)

    // Liquid is now frozen
    FrezzerTray:SetProcessState(2)
    FrezzerTray.BreakHits = 6//math.random(2,4)
end

function zmlab2.FrezzerTray.BreakIce(FrezzerTray,ply)
    zclib.Debug("zmlab2.FrezzerTray.BreakIce")

    zclib.Sound.EmitFromEntity("meth_breaking", FrezzerTray)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    FrezzerTray:SetProcessState(3)

    if IsValid(ply) then
        local tr = ply:GetEyeTrace()
        if tr and tr.Hit and tr.HitPos and IsValid(tr.Entity) and (tr.Entity:GetClass() == "zmlab2_item_frezzertray" or tr.Entity:GetClass() == "zmlab2_table") then

            zclib.NetEvent.Create("meth_break",{[1] = tr.HitPos,[2] = FrezzerTray:GetMethType()})
        end
    else
        zclib.NetEvent.Create("meth_break",{[1] = FrezzerTray:GetPos(),[2] = FrezzerTray:GetMethType()})
    end

    if FrezzerTray.BreakHits == 6 then
        FrezzerTray:SetBodygroup(0,2)
        FrezzerTray:SetSkin(1)
    elseif FrezzerTray.BreakHits == 5 then
        FrezzerTray:SetBodygroup(0,2)
        FrezzerTray:SetSkin(2)
    elseif FrezzerTray.BreakHits == 4 then
        FrezzerTray:SetBodygroup(0,3)
    elseif FrezzerTray.BreakHits == 3 then
        FrezzerTray:SetBodygroup(0,4)
    elseif FrezzerTray.BreakHits == 2 then
        FrezzerTray:SetBodygroup(0,5)
    elseif FrezzerTray.BreakHits == 1 then
        FrezzerTray:SetBodygroup(0,6)
    end

    FrezzerTray.BreakHits = FrezzerTray.BreakHits - 1
    if FrezzerTray.BreakHits <= 0 then
        zmlab2.FrezzerTray.SpawnMeth(FrezzerTray,ply)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function zmlab2.FrezzerTray.SpawnMeth(FrezzerTray,ply)
    zclib.Debug("zmlab2.FrezzerTray.SpawnMeth")

	local mType = FrezzerTray:GetMethType()
	local mAmount = FrezzerTray:GetMethAmount()
	local mQuality = FrezzerTray:GetMethQuality()

    // If the tray is on a table and the table has a crate then
    if IsValid(FrezzerTray:GetParent()) and FrezzerTray:GetParent():GetClass() == "zmlab2_table" and zmlab2.Table.CanTransfer(FrezzerTray:GetParent()) then
        zmlab2.Table.TransferMeth(FrezzerTray:GetParent())

        hook.Run("zmlab2_OnMethMade", ply, FrezzerTray, FrezzerTray:GetParent():GetCrate(),mType,mAmount,mQuality)
        return
    end

    local ent = ents.Create("zmlab2_item_meth")
    if not IsValid(ent) then return end
    ent:SetPos(FrezzerTray:GetPos() + Vector(0, 0, 15))
    ent:SetAngles(angle_zero)
    ent:Spawn()
    ent:Activate()
    ent.AntiSpamUse = (CurTime() + 1)

    ent:SetMethType(FrezzerTray:GetMethType())
    ent:SetMethAmount(FrezzerTray:GetMethAmount())
    ent:SetMethQuality(FrezzerTray:GetMethQuality())

    zmlab2.FrezzerTray.Reset(FrezzerTray)

    zclib.Player.SetOwner(ent, ply)

    hook.Run("zmlab2_OnMethMade",ply, FrezzerTray, ent,mType,mAmount,mQuality)
end

function zmlab2.FrezzerTray.Reset(FrezzerTray)
    zclib.Debug("zmlab2.FrezzerTray.Reset")
    FrezzerTray:SetBodygroup(0,0)
    FrezzerTray:SetSkin(0)
    FrezzerTray:SetProcessState(0)

    FrezzerTray:SetMethType(1)
    FrezzerTray:SetMethAmount(0)
    FrezzerTray:SetMethQuality(1)

    FrezzerTray:SetColor(color_white)
end

concommand.Add("zmlab2_debug_FrezzerTray_Test", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zmlab2_item_frezzertray" then

            local state = tr.Entity:GetProcessState()

            if state == 0 then
                zmlab2.FrezzerTray.AddLiquid(tr.Entity,tr.Entity:GetMethType(),100,100)
            elseif state == 1 then
                zmlab2.FrezzerTray.FrezzeLiquid(tr.Entity)
            elseif state == 2 then
                zmlab2.FrezzerTray.BreakIce(tr.Entity)
            elseif state == 3 then
                zmlab2.FrezzerTray.Reset(tr.Entity)
            end
        end
    end
end)

concommand.Add("zmlab2_debug_FrezzerTray_Material_Test", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        local tr = ply:GetEyeTrace()

        if tr.Hit and tr.HitPos then

            for k,v in ipairs(zmlab2.config.MethTypes) do

                // State
                for i = 1,3 do

                    local ent = ents.Create("zmlab2_item_frezzertray")
                    if not IsValid(ent) then return end
                    ent:SetPos(tr.HitPos + Vector(30 * k, 30 * i, 10))
                    ent:SetAngles(angle_zero)
                    ent:Spawn()
                    ent:Activate()

                    //ent:SetColor(v.color)

                    ent:SetBodygroup(0,1)

                    ent:SetMethType(k)

                    ent:SetMethQuality(100)

                    if i == 1 then

                        zmlab2.FrezzerTray.AddLiquid(ent,k,100)
                    elseif i == 2 then
                        zmlab2.FrezzerTray.FrezzeLiquid(ent)
                    elseif i == 3 then
                        zmlab2.FrezzerTray.BreakIce(ent)
                    end
                end
            end
        end
    end
end)

concommand.Add("zmlab2_debug_FrezzerTray_Break_Test", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        local tr = ply:GetEyeTrace()

        if tr.Hit and tr.HitPos then

            // State
            for i = 1,10 do

                local ent = ents.Create("zmlab2_item_frezzertray")
                if not IsValid(ent) then return end
                ent:SetPos(tr.HitPos + Vector(30, 30, 10 * i))
                ent:SetAngles(angle_zero)
                ent:Spawn()
                ent:Activate()

                //ent:SetColor(v.color)

                ent:SetBodygroup(0,1)

                local phys = ent:GetPhysicsObject()

            	if IsValid(phys) then
            		phys:Wake()
            		phys:EnableMotion(true)
            	end

                zmlab2.FrezzerTray.AddLiquid(ent,2,100,100)

                zmlab2.FrezzerTray.FrezzeLiquid(ent)
            end
        end
    end
end)
