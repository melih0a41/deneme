/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

if (not SERVER) then return end
zlm = zlm or {}
zlm.f = zlm.f or {}


                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813



////////////////////////////////////////////
//////////////// NW Timeout ////////////////
////////////////////////////////////////////
// How often are clients allowed to send net messages to the server
zlm_NW_TIMEOUT = 0.1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function zlm.f.Player_Timeout(ply)

    if not IsValid(ply) then return false end

    local Timeout = false

    if ply.zlm_NWTimeout and ply.zlm_NWTimeout > CurTime() then
        zlm.f.Debug("Player_Timeout!")

        Timeout = true
    end

    ply.zlm_NWTimeout = CurTime() + zlm_NW_TIMEOUT

    return Timeout
end
////////////////////////////////////////////
////////////////////////////////////////////




////////////////////////////////////////////
///////////// Player Initialize ////////////
////////////////////////////////////////////
if zlm_PlayerList == nil then
    zlm_PlayerList = {}
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 56332c963001ede3d9d126f154d4338dbfa62fb2596793981078d8a19965d3a4

function zlm.f.Player_Add(ply)
    zlm_PlayerList[ply:SteamID()] = ply
end

function zlm.f.Player_Remove(steamid)
    zlm_PlayerList[steamid] = nil
end

util.AddNetworkString("zlm_Player_Initialize")
net.Receive("zlm_Player_Initialize", function(len, ply)

    if not IsValid(ply) then return end

    if ply.zlm_HasInitialized then
        return
    else
        ply.zlm_HasInitialized = true
    end

    zlm.f.Debug("zlm_Player_Initialize Netlen: " .. len)

    zlm.f.Player_Initialize(ply)
end)

function zlm.f.Player_Initialize(ply)
    zlm.f.Player_Add(ply)

    if zlm.config.SimpleGrassMode.Enabled == false then
        zlm.f.Send_GrassSpots_ToClient(ply)
    end
end
////////////////////////////////////////////
////////////////////////////////////////////
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813




hook.Add("PlayerSay", "a_zlm_PlayerSay_Save", function(ply, text)
    if string.sub(string.lower(text), 1, 8) == "!savezlm" then
        if zlm.f.IsAdmin(ply) then
            zlm.f.Save_GrassSpots()
            zlm.f.Notify(ply, "GrassSpot´s have been saved for the map " .. game.GetMap() .. "!", 0)

            zlm.f.Save_BuyerNPC()
            zlm.f.Notify(ply, "Grass Buyer NPC´s have been saved for the map " .. game.GetMap() .. "!", 0)

            zlm.f.Save_GrassPress()
            zlm.f.Notify(ply, "GrassPress entities have been saved for the map " .. game.GetMap() .. "!", 0)

            zlm.f.Save_Lawnmower()
            zlm.f.Notify(ply, "Lawnmower entities have been saved for the map " .. game.GetMap() .. "!", 0)

            zlm.f.Save_VehicleSpawns()
            zlm.f.Notify(ply, "Vehicle Spawns have been saved for the map " .. game.GetMap() .. "!", 0)
        else
            zlm.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
        end
    end
end)

local zlm_DeleteEnts = {
    ["zlm_grasspress"] = true,
    ["zlm_tractor"] = true,
    ["zlm_tractor_trailer"] = true,
    ["zlm_corb"] = true
}
function zlm.f.Player_Cleanup(ply)
    for k, v in pairs(zlm.EntList) do
        if IsValid(v) and zlm_DeleteEnts[v:GetClass()] and zlm.f.GetOwnerID(v) == ply:SteamID() then
            v:Remove()
        end
    end

    if IsValid(ply.zlm_Tractor) then
        ply.zlm_Tractor:Remove()
    end
    if IsValid(ply.zlm_Tractor_Trailer) then
        ply.zlm_Tractor_Trailer:Remove()
    end
end
hook.Add("PlayerChangedTeam", "a_zlm_PlayerChangedTeam", function(ply, before, after)

    if IsValid(ply) then
        zlm.f.Player_Cleanup(ply)
    end
end)

hook.Add("PlayerDisconnected", "a_zlm_PlayerDisconnected", function(ply)

    if IsValid(ply) then
        zlm.f.Player_Cleanup(ply)

        zlm.f.Player_Remove(ply:SteamID())
    end
end)

hook.Add("PlayerDeath", "a_zlm_PlayerDeath", function(victim, inflictor, attacker)

    // Close NPC interface
    zlm.f.NPC_CloseInterface(victim)
end)
