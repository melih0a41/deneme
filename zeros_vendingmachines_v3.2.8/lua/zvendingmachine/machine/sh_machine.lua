/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

zvm = zvm or {}
zvm.Machine = zvm.Machine or {}

// Changeging this value wont do much good, since it wont resize the items currently, Its just here for refrence
function zvm.Machine.PageItemLimit()
    return 12
end

function zvm.Machine.ItemLimit()
    return zvm.config.Vendingmachine.ItemCapacity
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

function zvm.Machine.ProductCount(Machine)
    return table.Count(Machine.Products)
end

function zvm.Machine.ReachedItemLimit(Machine)
    return zvm.Machine.ProductCount(Machine) >= zvm.Machine.ItemLimit()
end


function zvm.Machine.HasRankRestriction(ItemData)
    if ItemData and ItemData.rankid and ItemData.rankid > 0 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

function zvm.Machine.HasJobRestriction(ItemData)
    if ItemData and ItemData.jobid and ItemData.jobid > 0 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

function zvm.Machine.RankCheck(ply, ItemData)
    local rankid = ItemData.rankid
    if rankid == nil then return true end
    local rankgp = zvm.config.Vendingmachine.RankGroups[rankid]
    if rankgp == nil then return true end
    if rankgp.ranks == nil then return true end

    local result = zclib.Player.RankCheck(ply, rankgp.ranks)
    if result == false then
        zvm.Warning(ply,zvm.language.General["InCorrectRank"])
        zvm.Warning(ply,zclib.table.ToString(rankgp.ranks))
    end
    return result
end

function zvm.Machine.JobCheck(ply, ItemData)
    local jobid = ItemData.jobid
    if jobid == nil then return true end
    local jobgp = zvm.config.Vendingmachine.JobGroups[jobid]
    if jobgp == nil then return true end
    if jobgp.jobs == nil then return true end

    local result = jobgp.jobs[zclib.Player.GetJob(ply)] == true
    if result == false then
        zvm.Warning(ply,zvm.language.General["WrongJob"])
        local tbl = {}
        for k, v in pairs(jobgp.jobs) do table.insert(tbl,team.GetName(k)) end
        zvm.Warning(ply,table.concat(tbl, ", ", 1, #tbl))
    end
    return result
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function zvm.Machine.SwitchProducts(Machine,ID01,ID02)
    // The data we wanna move
    local dat_a = table.Copy(Machine.Products[ID01])
    local dat_b = table.Copy(Machine.Products[ID02])
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    // Do the switch
    Machine.Products[ID01] = dat_b
    Machine.Products[ID02] = dat_a
end
