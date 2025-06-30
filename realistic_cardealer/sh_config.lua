/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.8 (stable)
*/

RCD = RCD or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2a19d6f765bd2510b41cead9e38d02b249f853e14001f8cafbb966fe57aec4c8

--[[ If you use mysql you have to activate this and configure the mysql information and restart your server !! ]]
RCD.Mysql = false

--[[ Which rank can have access to the admin configuration ]]
RCD.AdminRank = {
    ["superadmin"] = true,
    ["founder"] = false,
    ["admin"] = false,
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9eff57589167e9e41bec6130a6381227e9b74ae8bcbabd04e416f831a95d97a1

--[[ Sound for each models ]]
RCD.AccidentModule = {
    ["modelSound"] = { 
        ["models/player/zelpa/male_01_extended.mdl"] = "male",
        ["models/player/zelpa/male_02_extended.mdl"] = "male",
        ["models/player/zelpa/female_01_extended.mdl"] = "female",
        ["models/player/zelpa/female_07_extended.mdl"] = "female",
    },
}

--[[ Model blacklisted ]]
RCD.ModelBlacklisted = {
    ["models/dannio/gscooters.mdl"] = true,

    -- Gscooter'ın gerçek model path'ini buraya ekleyin
}

--[[ All colors used on the addon ]]
RCD.Colors = {
    ["black"] = Color(0, 0, 0),
    ["blackpurple"] = Color(23, 20, 35, 245),
    ["black18200"] = Color(18, 30, 42, 200),
    ["black18220"] = Color(18, 30, 42, 220),
    ["grey"] = Color(150, 150, 150),
    ["grey30"] = Color(150, 150, 150, 30),
    ["grey69"] = Color(69, 67, 79, 255),
    ["grey84"] = Color(84, 84, 88, 140),
    ["green97"] = Color(97, 181, 111),
    ["grey10010"] = Color(100, 100, 100, 10),
    ["grey10020"] = Color(100, 100, 100, 20),
    ["grey10050"] = Color(100, 100, 100, 50),
    ["grey134"] = Color(134, 119, 221, 20),
    ["grey187"] = Color(187, 178, -8, 108),
    ["notifycolor"] = Color(54, 140, 220),
    ["purple"] = Color(81, 56, 237),
    ["purple51"] = Color(84, 85, 165, 51),
    ["purple55"] = Color(55, 39, 134),
    ["purple84"] = Color(84, 86, 165),
    ["purple99"] = Color(99, 79, 210),
    ["purple120"] = Color(81, 56, 237, 100),
    ["red"] = Color(255, 0, 0, 255),
    ["red202"] = Color(202, 77, 68),
    ["speedoRed"] = Color(237, 56, 56),
    ["white"] = Color(248, 247, 252),
    ["white0"] = Color(255, 255, 255, 0),
    ["white2"] = Color(248, 247, 252, 2),
    ["white5"] = Color(248, 247, 252, 5),
    ["white20"] = Color(248, 247, 252, 10),
    ["white30"] = Color(248, 247, 252, 5),
    ["white80"] = Color(248, 247, 252, 80),
    ["white80248"] = Color(248, 247, 252, 80),
    ["white100"] = Color(248, 247, 252, 100),
    ["white120"] = Color(248, 247, 252, 120),
    ["white200"] = Color(248, 247, 252, 200),
    ["white200255"] = Color(200, 200, 200),
    ["white220"] = Color(255, 255, 255, 220),
    ["white250250"] = Color(250, 250, 250),
    ["white255200"] = Color(255, 255, 255, 200),
    ["white255"] = Color(255, 255, 255, 255),
    ["yellow"] = Color(183, 158, 55, 255),
}

RCD.UnitConvertion = {
    ["mph"] = 0.0568182, -- [[ Unit convertion to the mph ]]
    ["kmh"] = 0.09144, -- [[ Unit convertion to the kmh ]]
}

--[[ You can add more currency here ]]
RCD.Currencies = {
    ["t"] = function(money)
        return money.. "₺"
    end,
    ["€"] = function(money)
        return money.."€"
    end
}

--[[
    [vehicleId] = function(ply, vehcTable, vehicleId) -- If you put a star for the vehicleId all vehicle will be impacted 
        return false
    end
]]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198381307883

RCD.CustomCheck = {
    -- ["*"] = function(ply, vehcTable, vehicleId) 
    --     vehicleId = tonumber(vehicleId)

    --     if MRS && isfunction(MRS.GetNWdata) then
    --         local group = MRS.GetNWdata(ply, "Group")
    --         local rank = MRS.GetNWdata(ply, "Rank")
    
    --         if not MRS.Ranks or not MRS.Ranks[group] or not MRS.Ranks[group].ranks then return end
    
    --         local rank_tbl = MRS.Ranks[group].ranks[rank]
    --         local name = rank_tbl["name"]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198381307890

    --         local rankAccepted = {
    --             ["Officier"] = true,
    --             ["Recruit"] = false,
    --         }
    
    --         return rankAccepted[name]
    --     end
    -- end,
    -- [1] = function(ply, vehcTable, vehicleId)
    --     vehicleId = tonumber(vehicleId)

    --     if JobRanksConfig && isfunction(ply.GetJobRankName) then
    --         local rankName = ply:GetJobRankName()
        
    --         local rankAccepted = {
    --             ["Officier"] = true,
    --             ["Recruit"] = false,
    --         }
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 9eff57589167e9e41bec6130a6381227e9b74ae8bcbabd04e416f831a95d97a1
    
    --         return rankAccepted[rankName]
    --     end
    -- end,
}
