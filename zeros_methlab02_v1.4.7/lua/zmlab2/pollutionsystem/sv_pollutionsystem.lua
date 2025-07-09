/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if CLIENT then return end

zmlab2 = zmlab2 or {}
zmlab2.PollutionSystem = zmlab2.PollutionSystem or {}
zmlab2.PollutionSystem.PolutedAreas = zmlab2.PollutionSystem.PolutedAreas or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

/*

    The PollutionSystem makes certain areas of the map dangurous
        Polluted Areas have damage the player if he goes closer
        On client it will display a poison cloud
        The size of the cloud and damage amount depends on the pollution amount
        Pollution disolves/reduces over time
*/

function zmlab2.PollutionSystem.AddProducer(ent,amount,rep)
	if not amount or amount <= 0 then return end

    // Creates pollution while heating
    local timerid01 = "zmlab2_pollution_producer_" .. ent:EntIndex()
    zclib.Timer.Remove(timerid01)
    zclib.Timer.Create(timerid01,1,rep,function()

        if not IsValid(ent) then
            zclib.Timer.Remove(timerid01)
            return
        end

        zmlab2.Ventilation.Check(ent:GetPos(),amount)
    end)
end

function zmlab2.PollutionSystem.AddPollution(pos,i_amount)
	if not i_amount or i_amount <= 0 then return end

    local snapedPos = zmlab2.PollutionSystem.GetPosition(pos)
    local amount = i_amount
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

    // Search for the neareast position if available
    local id = zmlab2.PollutionSystem.FindNearest(snapedPos,50)
    if id then
        zmlab2.PollutionSystem.PolutedAreas[id].amount = zmlab2.PollutionSystem.PolutedAreas[id].amount + amount
    else
        id = table.insert(zmlab2.PollutionSystem.PolutedAreas, {
            pos = snapedPos,
            amount = amount
        })
    end

    //zclib.Debug("zmlab2.PollutionSystem.AddPollution[" .. tostring(id) .. "][" .. zmlab2.PollutionSystem.PolutedAreas[id].amount .. "]")

	zmlab2.PollutionSystem.Update(id,zmlab2.PollutionSystem.PolutedAreas[id].amount,snapedPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 54469f81bdb1d2abe88f4caa9fa689701fe202147aed32d50385cadc588b0b1e

    zmlab2.PollutionSystem.TimerCheck()
end

function zmlab2.PollutionSystem.RemovePollution(pos,amount)

    local RemoveAmount

    // Search for the neareast pollution that can be moved
    local id = zmlab2.PollutionSystem.FindNearest(pos,zmlab2.config.Ventilation.Radius)
    if id then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

		local dat = zmlab2.PollutionSystem.PolutedAreas[id]

        RemoveAmount = math.Clamp(amount,0,dat.amount)
        dat.amount = math.Clamp(dat.amount - RemoveAmount,0,99999999)

        zclib.Debug("zmlab2.PollutionSystem.RemovePollution[" .. tostring(id) .. "][" .. dat.amount .. "]")

		zmlab2.PollutionSystem.Update(id,0,dat.pos)

        if dat.amount <= 0 then
            zmlab2.PollutionSystem.PolutedAreas[id] = nil
        end
    else
        // Could not find any pollution near this location
        return
    end

    return RemoveAmount
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

function zmlab2.PollutionSystem.TimerCheck()
    local timerid = "zmlab2_PollutionSystem_timer"
    if timer.Exists(timerid) == true then return end
    zclib.Timer.Remove(timerid)

    zclib.Timer.Create(timerid,1,0,function()
        if not zmlab2.config.PollutionSystem.Enabled then return end
        
        for area_id,pollution_data in pairs(zmlab2.PollutionSystem.PolutedAreas) do

            if zmlab2.PollutionSystem.PolutedAreas == nil or #zmlab2.PollutionSystem.PolutedAreas <= 0 then
                zclib.Timer.Remove(timerid)
                break
            end

            local count = math.Clamp(math.Round(pollution_data.amount / 10),1,10)

            local rad = 30 * count
            local dist = zmlab2.PollutionSystem.GetSize() + rad
            debugoverlay.Sphere(pollution_data.pos,dist,1,Color( 255, 125, 0 ,50),true)

            for k,v in pairs(zclib.Player.List) do
                if not IsValid(v) then continue end
                if not v:Alive() then continue end

                if zclib.util.InDistance(pollution_data.pos, v:GetPos(), dist) and zmlab2.config.PollutionSystem.ImmunityCheck(v) ~= true then

                    if zmlab2.config.PollutionSystem.UseTraces == true then
                        local c_trace = zclib.util.TraceLine({
                            start = pollution_data.pos + Vector(0,0,50),
                            endpos = v:GetPos() + Vector(0,0,10),
                            mask = MASK_SOLID_BRUSHONLY,
                        }, "PollutionSystem")

                        if c_trace and c_trace.Fraction >= 0.9 then
                            zmlab2.PollutionSystem.DamagePlayer(v,pollution_data)
                        end
                    else
                        zmlab2.PollutionSystem.DamagePlayer(v,pollution_data)
                    end
                end
            end

            pollution_data.amount = math.Clamp(pollution_data.amount - zmlab2.config.PollutionSystem.EvaporationAmount,0,9999999)

            if pollution_data.amount <= 0 then zmlab2.PollutionSystem.PolutedAreas[area_id] = nil end
        end
    end)
end

function zmlab2.PollutionSystem.DamagePlayer(ply,pollution_data)
    local dmg = math.Clamp(math.Round(pollution_data.amount / 10), zmlab2.config.PollutionSystem.Damage.min, zmlab2.config.PollutionSystem.Damage.max)

    local Attacker
	if zmlab2.config.PollutionSystem.DamageInflictorSelf then
		Attacker = ply
	else
		Attacker = game.GetWorld()
	end

    // Damage player
    local d = DamageInfo()
    d:SetDamage(dmg)
    d:SetAttacker(Attacker)
    d:SetInflictor(Attacker)
    d:SetDamageType(DMG_NERVEGAS)
    ply:TakeDamageInfo(d)
end

util.AddNetworkString("zmlab2_PollutionSystem_Update")
function zmlab2.PollutionSystem.Update(id,amount,pos)
	net.Start("zmlab2_PollutionSystem_Update")
    net.WriteUInt(id,32)
	net.WriteVector(pos)
    net.WriteUInt(amount,16)
    net.Broadcast()
end

concommand.Add("zmlab2_debug_PollutionSystem_AddPollution", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        local tr = ply:GetEyeTrace()

        if tr.Hit and tr.HitPos then
            zmlab2.PollutionSystem.AddPollution(tr.HitPos,100)
        end
    end
end)

concommand.Add("zmlab2_debug_PollutionSystem_ClearPollution", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then

        for k,v in pairs(zmlab2.PollutionSystem.PolutedAreas) do
        	zmlab2.PollutionSystem.Update(k,0,v.pos)
        end

		zmlab2.PollutionSystem.PolutedAreas = {}
    end
end)
