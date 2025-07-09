/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

if SERVER then return end
ztm = ztm or {}
ztm.HUD = ztm.HUD or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 265feda5fa4d4a3bb651bb0a3f3e5148281ff8e9bf9996fd1df908361b30ab1a

function ztm.HUD.DrawTrash(amount,pos)
    cam.Start3D2D(pos, zclib.HUD.GetLookAngles(), 0.1)
        draw.RoundedBox(5, -5, 80, 5, 250, ztm.default_colors["white01"])
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        surface.SetDrawColor(ztm.default_colors["grey01"])
        surface.SetMaterial(ztm.default_materials["ztm_trash_icon"])
        surface.DrawTexturedRect(-100, -100, 200, 200)

        draw.DrawText(amount .. ztm.config.UoW, zclib.GetFont("ztm_trash_font02"), 0, -20, ztm.default_colors["black02"], TEXT_ALIGN_CENTER)
        draw.DrawText(amount .. ztm.config.UoW, zclib.GetFont("ztm_trash_font01"), 0, -20, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b
