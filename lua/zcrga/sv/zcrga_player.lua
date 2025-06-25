/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

if (not SERVER) then return end
zcrga = zcrga or {}
zcrga.f = zcrga.f or {}

// How often are clients allowed to send net messages to the server
zcrga_NW_TIMEOUT = 0.25
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24d29d357f25d0e3dbcd1d408ccea85b467c8e0190b63644784fca3979a920a4

function zcrga.f.NW_Player_Timeout(ply)
    local Timeout = false

    if ply.zcrga_NWTimeout and ply.zcrga_NWTimeout > CurTime() then
        Timeout = true
    end

    ply.zcrga_NWTimeout = CurTime() + zcrga_NW_TIMEOUT

    return Timeout
end

if zcrga_PlayerList == nil then
    zcrga_PlayerList = {}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44

function zcrga.f.Add_Player(ply)
    table.insert(zcrga_PlayerList, ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5e79b2fdae865d1c82ff5984775d03ccb9b7c13532a81e0b579caa368ee75c44

hook.Add("PlayerInitialSpawn", "zcrga_PlayerInitialSpawn", function(ply)
    timer.Simple(1, function()
        zcrga.f.Add_Player(ply)
    end)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c342b127afdf542b621f89d5d7f1fe28190f83a669677e45d028bc5b66d3917c
