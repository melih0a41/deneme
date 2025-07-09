/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.Storage = zmlab2.Storage or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function zmlab2.Storage.BuyCheck(ply,id)
    local data = zmlab2.config.Storage.Shop[id]
    if data == nil then return false end
    if data.rank and istable(data.rank) and table.Count(data.rank) > 0 and zclib.Player.RankCheck(ply,data.rank) == false then return false end
    if data.job and istable(data.job) and table.Count(data.job) > 0 and data.job[zclib.Player.GetJob(ply)] == nil then return false end
    if data.customcheck and data.customcheck(ply) == false then return false end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c52dc6fb5982deaf8f0712a67eec0164d06de6aef08979289a611c0f151d588
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- f7893371c9c45e517706bcf930eeb86beb240190a31d3585595b7cde29a6cb69
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 95d55545aebda8f4c665fa04328873b37962e65243c7f7e1a4865897228bf6bf

    return true
end
