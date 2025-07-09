/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.Equipment = zmlab2.Equipment or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588

zmlab2.Equipment_Classes = {}
timer.Simple(2,function()
    for k,v in pairs(zmlab2.config.Equipment.List) do
        zmlab2.Equipment_Classes[v.class] = k
    end
end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

// Check if some player is in the way
function zmlab2.Equipment.AreaOccupied(pos,ignore)
    local IsOccupied = false
    for k,v in pairs(ents.FindInSphere(pos,15)) do
        if not IsValid(v) then continue end

        if ignore and v == ignore then continue end

        // We dont place a machine on top of another one
        if zmlab2.Equipment_Classes[v:GetClass()] then
            IsOccupied = true
            break
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

        // Dont place a machine on a player
        if v:IsPlayer() then
            IsOccupied = true
            break
        end
    end
    return IsOccupied
end
