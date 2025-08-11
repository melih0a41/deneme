
VoidCases.CachedMaterials = {}
VoidCases.ImageProvider = "https://i.imgur.com/%s.png" // Change to imgur later.

file.CreateDir("voidcases")

hook.Add("InitPostEntity", "VoidCases.InitLogoLoad", function ()
    local files = file.Find("voidcases/*.png", "DATA")

    for k, v in pairs(files) do
        local str = string.Replace(v, ".png", "")
        VoidCases.CachedMaterials[str] = Material("data/voidcases/"..str..".png", "noclamp smooth")
    end
end)



if (CLIENT) then
    net.Receive("VoidCases_BroadcastLogoDL", function ()
        local id = net.ReadString()

        VoidCases.FetchImage(id, function ()

        end)
    end)
end

function VoidCases.FetchImage(id, callback)

    if (VoidCases.CachedMaterials[id]) then
        callback(VoidCases.CachedMaterials[id])
    else
        if (file.Exists("voidcases/" .. id .. ".png", "DATA")) then
            VoidCases.CachedMaterials[id] = Material("data/voidcases/"..id..".png", "noclamp smooth")
            callback(VoidCases.CachedMaterials[id])
        else
            http.Fetch(string.format(VoidCases.ImageProvider, id), function (body, size, headers, code)

                if (code != 200) then
                    callback(false)
                    return
                end
                
                if (!body or body == "") then 
                    callback(false)
                    return 
                end

                file.Write("voidcases/"..id..".png", body)
                VoidCases.CachedMaterials[id] = Material("data/voidcases/"..id..".png", "noclamp smooth")
                callback(VoidCases.CachedMaterials[id])
            end, function ()
                // Failure
                callback(false)
            end)
        end
    end
    
end


function VoidCases.GetChanceSum(unboxableItems)
    local chanceSum = 0

    for id, chanceNum in pairs(unboxableItems) do
        if (!isstring(v)) then
            chanceSum = chanceSum + chanceNum
        end
    end

    return chanceSum
end

function VoidCases.GetChance(chanceNum, chanceSum, asString)
    local chancePercentage = math.Round(100 / chanceSum * chanceNum)

    if asString then
        return chancePercentage .. "%"
    else
        return chancePercentage
    end
end

function VoidCases.SplitTableToChunks(tbl, step)
    local chunks = {}
    local totalChunks = math.ceil(table.Count(tbl) / step)

    local i = 1

    for k, v in pairs(tbl) do
        if (!chunks[i]) then
            chunks[i] = {}
        end

        if (table.Count(chunks[i]) < step) then
            chunks[i][k] = v
        else
            i = i + 1
            if (!chunks[i]) then
                chunks[i] = {}
            end

            chunks[i][k] = v
        end
    end

    return chunks, totalChunks
end

function VoidCases.LoadTableGradually(tbl, step, wait, loadFunction, finishFunction)
    local chunks = VoidCases.SplitTableToChunks(tbl, step)
    
    local function loadChunk(index)
        local nextIndex = index + 1

        local chunk = chunks[index]
        if (!chunk) then
            if (finishFunction) then finishFunction() end
            return
        end

        if (!loadFunction) then return end

        loadFunction(chunk, index)

        timer.Simple(wait, function ()
            loadChunk(nextIndex)
        end)
    end

    loadChunk(1)
end