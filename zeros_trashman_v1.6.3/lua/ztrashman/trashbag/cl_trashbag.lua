/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if SERVER then return end
ztm = ztm or {}
ztm.Trashbag = ztm.Trashbag or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

function ztm.Trashbag.Initialize(Trashbag)
    zclib.EntityTracker.Add(Trashbag)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 70f5e8d11f25113d538110eeb4fbf77af5d4f97215b5cf2e5f195ad3d3a00fca
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

function ztm.Trashbag.Draw(Trashbag)
    if zclib.Convar.Get("zclib_cl_drawui") == 1 and zclib.util.InDistance(LocalPlayer():GetPos(), Trashbag:GetPos(), 300) and ztm.Player.IsTrashman(LocalPlayer()) then
        ztm.HUD.DrawTrash(Trashbag:GetTrash(),Trashbag:GetPos() + Vector(0, 0, 35))
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389


function ztm.Trashbag.OnRemove(Trashbag)
    ztm.Effects.Trash(Trashbag:GetPos())
    ztm.Effects.Trash(Trashbag:GetPos())
    ztm.Effects.Trash(Trashbag:GetPos())
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b
