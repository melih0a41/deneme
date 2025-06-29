/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Player = zvm.Player or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

function zvm.Player.AddPackage(ply,crate)
    if ply.zvm_packages == nil then ply.zvm_packages = {} end
    table.insert(ply.zvm_packages,crate)
end
function zvm.Player.RemovePackage(ply,crate)
    if ply.zvm_packages == nil then ply.zvm_packages = {} end
    table.RemoveByValue( ply.zvm_packages, crate )
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function zvm.Player.GetPackageCount(ply)
    local count = 0
    if ply.zvm_packages then
        count = table.Count(ply.zvm_packages)
    end
    zclib.Debug("GetPackageCount: " .. count)

    return count
end


zclib.Player.CleanUp_Add("zvm_crate")
zclib.Player.CleanUp_Add("zvm_machine")

zclib.Gamemode.AssignOwnerOnBuy("zvm_machine")

zclib.Hook.Add("zclib_PlayerJoined", "zvm_PlayerJoined", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        zclib.Data.Send("zvm_machine_styles",ply)
    end)
end)


zclib.Hook.Add("zclib_PlayerDisconnect", "zvm_PlayerDisconnect", function(steamid)
    local machine = zvm.Vendingmachines_Interactions[steamid]
    if IsValid(machine) then
        zvm.Machine.RemovePlayer(machine)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zclib.Hook.Add("PlayerDeath", "zvm_machine", function(victim, inflictor, attacker)
    if IsValid(victim.zvm_Machine) then
        zvm.Machine.RemovePlayer(victim.zvm_Machine)
    end
end)

zclib.Hook.Add("PlayerSay", "zvm_save", function(ply, text)
    if string.sub(string.lower(text), 1, 8) == "!savezvm" then
        if zclib.Player.IsAdmin(ply) then
            zclib.STM.Save("zvm_machine")
            zclib.Notify(ply, "Vendingmachines have been saved for the map " .. game.GetMap() .. "!", 0)
        else
            zclib.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
        end
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
