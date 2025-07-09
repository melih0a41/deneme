/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if (not SERVER) then return end
ztm = ztm or {}
ztm.PublicEntities = ztm.PublicEntities or {}

zclib.Hook.Add("PlayerSay", "ztm_PublicEntities", function(ply, text)
    if string.sub(string.lower(text), 1, 8) == "!saveztm" and zclib.Player.IsAdmin(ply) then
        ztm.PublicEntities.SaveAll(ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ztm.PublicEntities.RemoveAll(ply)
    zclib.STM.Remove("ztm_leafpile")
    zclib.STM.Remove("ztm_manhole")
    zclib.STM.Remove("ztm_buyermachine")
    zclib.STM.Remove("ztm_recycler")
    zclib.STM.Remove("ztm_trash")
    zclib.STM.Remove("ztm_trashburner")
    zclib.Notify(ply, "All Trash entities have been removed for the map " .. game.GetMap() .. "!", 0)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ztm.PublicEntities.SaveAll(ply)
    zclib.STM.Save("ztm_leafpile")
    zclib.STM.Save("ztm_manhole")
    zclib.STM.Save("ztm_buyermachine")
    zclib.STM.Save("ztm_recycler")
    zclib.STM.Save("ztm_trash")
    zclib.STM.Save("ztm_trashburner")
    zclib.Notify(ply, "All Trash entities have been saved for the map " .. game.GetMap() .. "!", 0)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

concommand.Add("ztm_save_all", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        ztm.PublicEntities.SaveAll(ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

concommand.Add("ztm_remove_all", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        ztm.PublicEntities.RemoveAll(ply)
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a
