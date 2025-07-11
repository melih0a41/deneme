/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

AddCSLuaFile()
zlm = zlm or {}

zlm.default_materials = zlm.default_materials or {}

zlm.default_materials["corb_fg"] = Material("materials/zerochain/zlm/zlm_corb_fg.png", "smooth")
zlm.default_materials["corb_bg"] = Material("materials/zerochain/zlm/zlm_corb_bg.png", "smooth")
zlm.default_materials["shadow_circle"] = Material("materials/zerochain/zlm/zlm_shadow_circle.png", "smooth")
zlm.default_materials["switch"] = Material("materials/zerochain/zlm/zlm_on_switch.png", "smooth")
zlm.default_materials["unload"] = Material("materials/zerochain/zlm/zlm_action_unload.png", "smooth")
zlm.default_materials["connect"] = Material("materials/zerochain/zlm/zlm_action_connect.png", "smooth")
zlm.default_materials["blades"] = Material("materials/zerochain/zlm/zlm_action_blades.png", "smooth")
zlm.default_materials["spawn_indicator"] = Material("materials/zerochain/zlm/zlm_spawn_indicator.png", "smooth")
zlm.default_materials["zlm_vehicle_tractor"] = Material("materials/zerochain/zlm/zlm_vehicle_tractor.png", "smooth")
zlm.default_materials["zlm_vehicle_trailer"] = Material("materials/zerochain/zlm/zlm_vehicle_trailer.png", "smooth")
zlm.default_materials["zlm_vehicle_tractor_glow"] = Material("materials/zerochain/zlm/zlm_vehicle_tractor_glow.png", "smooth")
zlm.default_materials["zlm_vehicle_trailer_glow"] = Material("materials/zerochain/zlm/zlm_vehicle_trailer_glow.png", "smooth")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

zlm.default_colors = zlm.default_colors or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zlm.default_colors["black01"] = Color(0, 0, 0, 250)
zlm.default_colors["black02"] = Color(0,0,0,115)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 729ea0f51a9cbc967c656b8b434d7a6bdbe5c41c92a572768a7e4dcc00640cad

zlm.default_colors["white01"] = Color(255, 255, 255, 255)
zlm.default_colors["white02"] = Color(200,200,200,25)
zlm.default_colors["white03"] = Color(255,255,255,150)
zlm.default_colors["white04"] = Color(255,255,255,100)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zlm.default_colors["grey01"] = Color(55, 55, 55, 255)
zlm.default_colors["grey02"] = Color(75, 75, 75, 255)
zlm.default_colors["grey03"] = Color(125, 125, 125, 255)
zlm.default_colors["grey04"] = Color(175, 175, 175, 255)

zlm.default_colors["orange01"] = Color(255,160,0,255)
zlm.default_colors["orange02"] = Color(244,177,61,255)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- deac9ee11c5c33949af935d4ccfdbf329ffd7e27c9b52b357a983949ef02b813

zlm.default_colors["red01"] = Color(200, 115, 115)
zlm.default_colors["red02"] = Color(125, 75, 75)

zlm.default_colors["green01"] = Color(115, 200, 115)
zlm.default_colors["green02"] = Color(166,195,96)
zlm.default_colors["green03"] = Color(75,125,75)
zlm.default_colors["green04"] = Color(100, 255, 100)
zlm.default_colors["green05"] = Color(115, 200, 115,150)
