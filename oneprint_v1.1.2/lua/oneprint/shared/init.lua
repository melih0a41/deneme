/*
    Addon id: 8d4152af-5b9a-4a49-ad24-e734e40f6d16
    Version: v1.1.2 (stable)
*/

OnePrint.ServerFreq = 3.2
OnePrint.OCFreq = 1.4
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 481ae4e011cb29eef7b5c45fcb57303d8ca78cc8afbc9356244fc51109720c04

--[[

    DON'T EDIT ANYTHING BELOW THIS !!!!
    It serves as a reference and/or limitation for the script
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

]]--

local tCfgLimits = {
    [ "MaxUsers" ] = { min = 0, max = 8 },
    [ "MaxIncomeHistory" ] = { min = 6, max = 24 },
    [ "IncomeHistoryDelay" ] = { min = 5, max = 3600 },
    [ "MaxActionsHistory" ] = { min = 1, max = 10 },
    [ "DamageChance" ] = { min = 0, max = 100 },
    [ "CrititalCondition" ] = { min = 0, max = 99 },
    [ "CPDestroyReward" ] = { min = 0 },
    [ "RepairPrice" ] = { min = 0 },
    [ "ServerPrice" ] = { min = 0 },
    [ "ServerIncome" ] = { min = 0 },
    [ "ServerStorage" ] = { min = 0 },
    [ "FanPrice" ] = { min = 0 },
    [ "WatercoolingPrice" ] = { min = 0 },
    [ "PowerPrice" ] = { min = 0 },
    [ "OverclockingPrice" ] = { min = 0 },
    [ "OverclockingIncome" ] = { min = 0 },
    [ "HackingErrorMargin" ] = { min = 0, max = 50 },
    [ "HackingSpeedMin" ] = { min = .1, max = 2 },
    [ "HackingSpeedMax" ] = { min = .1, max = 2 },
    [ "HackingSecurityMax" ] = { min = 1, max = 32 },
    [ "DefensePrice" ] = { min = 0 },
    [ "DefenseBoost" ] = { min = 0 },
    [ "DefenseMax" ] = { min = 1, max = 32 },
    [ "FireChance" ] = { min = 0, max = 100 }
}

for k, v in pairs( tCfgLimits ) do
    local iCfgVal = OnePrint.Cfg[ k ]
    if iCfgVal then
        if v.min and ( iCfgVal < v.min ) then
            OnePrint.Cfg[ k ] = v.min
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 119ae5788ce457cb9ed600b2a4a4cb0beb2aeff12114aedc40734066cacc5d67
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        if v.max and ( iCfgVal > v.max ) then
            OnePrint.Cfg[ k ] = v.max
        end
    end
end

tCfgLimits = nil

OnePrint.Upgrade = {
    [ 1 ] = {
        name = OnePrint:L( "Servers" ),
        price = OnePrint.Cfg.ServerPrice,
        mutators = {
            income = OnePrint.Cfg.ServerIncome,
            storage = OnePrint.Cfg.ServerStorage,
            power = 1,
            heat = 32,
            overclocking = 1,
            watercooling = 1,
            maxSilencer = 1,
            maxSecurity = OnePrint.Cfg.HackingSecurityMax,
        },
    },
    [ 2 ] = {
        name = OnePrint:L( "Defense" ),
        price = OnePrint.Cfg.DefensePrice,
        mutators = {
            maxHealth = OnePrint.Cfg.DefenseBoost
        }
    },
    [ 3 ] = {
        name = OnePrint:L( "Watercooling" ),
        price = OnePrint.Cfg.WatercoolingPrice,
        mutators = {
            heat = -12
        }
    },
    [ 4 ] = {
        name = OnePrint:L( "Power" ),
        price = OnePrint.Cfg.PowerPrice,
        mutators = {
            heat = 8,
            watercooling = 2,
            overclocking = 1,
        }
    },
    [ 5 ] = {
        name = OnePrint:L( "Overclocking" ),
        price = OnePrint.Cfg.OverclockingPrice,
        mutators = {
            incomeP = OnePrint.Cfg.OverclockingIncome,
            heat = 4
        }
    },
    [ 6 ] = {
        name = OnePrint:L( "Security" ),
        price = OnePrint.Cfg.SecurityPrice,
        mutators = {
            security = 1
        }
    },
    [ 7 ] = {
        name = OnePrint:L( "Silencer" ),
        price = OnePrint.Cfg.SilencerPrice,
        mutators = {
            silencer = 1
        }
    },
    [ 8 ] = {
        name = OnePrint:L( "Hacking notification" ),
        price = OnePrint.Cfg.HackNotifyPrice,
        mutators = {
            hackNotify = 1
        }
    },
    [ 9 ] = {
        name = OnePrint:L( "Low HP notification" ),
        price = OnePrint.Cfg.LowHPNotifyPrice,
        mutators = {
            lowHPNotify = 1
        }
    },
}
