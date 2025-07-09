/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.PollutionSystem = zmlab2.PollutionSystem or {}

zmlab2.PollutionSystem.PolutedAreas = zmlab2.PollutionSystem.PolutedAreas or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

function zmlab2.PollutionSystem.GetSize()
    return 100
end

// Returns the Pump Duration
function zmlab2.PollutionSystem.GetPosition(raw_pos)
    local size = zmlab2.PollutionSystem.GetSize()
    return Vector(math.Round(zclib.util.SnapValue(size,raw_pos.x)),math.Round(zclib.util.SnapValue(size,raw_pos.y)),math.Round(zclib.util.SnapValue(size,raw_pos.z)))
end

function zmlab2.PollutionSystem.FindNearest(pos,dist)
    local id
    if zmlab2.PollutionSystem.PolutedAreas and #zmlab2.PollutionSystem.PolutedAreas > 0 then
        for k,v in pairs(zmlab2.PollutionSystem.PolutedAreas) do
            if v == nil then continue end
            if v.pos == nil then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

            //debugoverlay.Sphere(v.pos,10,1,Color( 255, 255, 255 ,50),true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

            if zclib.util.InDistance(v.pos, pos, dist) then
                //debugoverlay.Sphere(v.pos,25,1,Color( 0, 255, 0 ,50),true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69

                id = k
                break
            end
        end
    end
    return id
end
