/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Extinguisher = zmlab2.Extinguisher or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6

function zmlab2.Extinguisher.OnUse(Tent,ply)

    if (Tent:GetLastExtinguish() + zmlab2.config.Extinguisher.Interval) > CurTime() then return end

    net.Start("zmlab2_Extinguisher_Use")
    net.WriteEntity(Tent)
    net.Send(ply)
end

function zmlab2.Extinguisher.ExtinguishArea(pos)
    zclib.NetEvent.Create("extinguish",{[1] = pos})

    for k,v in pairs(ents.FindInSphere(pos,200)) do
        if IsValid(v) then
            v:Extinguish()
        end
    end
end


util.AddNetworkString("zmlab2_Extinguisher_Use")
net.Receive("zmlab2_Extinguisher_Use", function(len,ply)
    zclib.Debug_Net("zmlab2_Extinguisher_Use",len)
    if zclib.Player.Timeout(nil,ply) == true then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- cf9f1b5b6912c2b4140971a6d64f943e6843edfd520667e51bbad9ee0ede2ef6
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    local Machine = net.ReadEntity()
    local Tent = net.ReadEntity()

    if not IsValid(Tent) then return end

    if (Tent:GetLastExtinguish() + zmlab2.config.Extinguisher.Interval) > CurTime() then return end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

    if not IsValid(Machine) then
        local tr = ply:GetEyeTrace()
        if tr.Hit and tr.HitPos and zclib.util.InDistance(ply:GetPos(), tr.HitPos, 500) then
            zmlab2.Extinguisher.ExtinguishArea(tr.HitPos)

            Tent:SetLastExtinguish(CurTime())
        end

        return
    end

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

    //if Machine:IsOnFire() == false then return end
    if zclib.util.InDistance(ply:GetPos(), Machine:GetPos(), 1000) == false then return end

    Machine:Extinguish()
    Tent:SetLastExtinguish(CurTime())

    zmlab2.Extinguisher.ExtinguishArea(Machine:GetPos())
end)
