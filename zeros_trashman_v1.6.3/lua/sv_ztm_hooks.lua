/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end

// Here are some Hooks you can use for Custom Code

// Called when a player trys to start a recycling machine, return false to prevent him from doing that
hook.Add("ztm_OnRecycleStart", "ztm_OnRecycleStart_Test", function(ply, recycler, recycle_type)
    /*
    print("ztm_OnRecycleStart")
    print("Player: " .. tostring(ply))
    print("Recycler: " .. tostring(recycler))
    print("RecycleType_ID: " .. recycle_type)
    print("RecycleType_Name: " .. ztm.config.Recycler.recycle_types[recycle_type].name)
    print("----------------")
    */


    // In this examble we define a Level value inside the recycle types config and check if the player is more or equal to the specified level.
    /*
        [2] = {
            name = "Aluminium",
            trash_per_block = 200,
            recycle_time = 30,
            money = 3000,
            mat = "zerochain/props_trashman/recycleblock/ztm_recycledblock_aluminium_diff",
            ranks = {},
            level = 5 // < The trashgun level
        },
    */
    /*
    local RecycleTypeData = ztm.config.Recycler.recycle_types[recycle_type]
    local ply_lvl = ztm.Data.GetLevel(ply)
    if RecycleTypeData.level and ply_lvl < RecycleTypeData.level then
        zclib.Notify(ply, "You dont have the correct level for this! [" .. RecycleTypeData.level .. " / " .. ply_lvl .. "]", 1)
        return false
    end
    */
end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca

// Called when a player burns trash
hook.Add("ztm_OnTrashBurned", "ztm_OnTrashBurned_Test", function(ply, trashburner, earning, trash)
    /*
    print("ztm_OnTrashBurned")
    print("Player who started the Burning Process: " .. tostring(ply))
    print("Trashburner: " .. tostring(trashburner))
    print("Money: " .. earning)
    print("Trash: " .. trash)
    print("----------------")
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

// Called when a player blows away a leafpile
hook.Add("ztm_OnLeafpileBlast", "ztm_OnLeafpileBlast_Test", function(ply, leafpile)
    /*
    print("ztm_OnLeafpileBlast")
    print("Player: " .. tostring(ply))
    print("Leafpile: " .. tostring(leafpile))
    print("----------------")
    */
end)

// Called when a player collects trash
hook.Add("ztm_OnTrashCollect", "ztm_OnTrashCollect_Test", function(ply, trash)
    /*
    print("ztm_OnTrashCollect")
    print("Player: " .. tostring(ply))
    print("Trash: " .. trash)
    print("----------------")
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

// Called when a player sells a recycled trash block
hook.Add("ztm_OnTrashBlockSold", "ztm_OnTrashBlockSold_Test", function(ply, buyermachine, earning)
    /*
    print("ztm_OnTrashBlockSold")
    print("Player: " .. tostring(ply))
    print("Buyermachine: " .. tostring(buyermachine))
    print("Money: " .. earning)
    print("----------------")
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

// Called when a player makes a recycled trash block
hook.Add("ztm_OnTrashBlockCreation", "ztm_OnTrashBlockCreation_Test", function(ply, recyclemachine, trashblock)
    /*
    print("ztm_OnTrashBlockCreation")
    print("Player: " .. tostring(ply))
    print("Recyclemachine: " .. tostring(recyclemachine))
    print("Trashblock: " ..  tostring(trashblock))
    print("----------------")
    */
end)
