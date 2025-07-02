easzy.quadcopter.quadcoptersData = easzy.quadcopter.quadcoptersData or {}
local quadcoptersData = easzy.quadcopter.quadcoptersData

quadcoptersData["ez_quadcopter_dji"] = {
    equipments = {
        ["C4"] = {
            key = "C4",
            name = easzy.quadcopter.languages.c4,
            bodygroup = "c4",
            value = "dji_quadcopter_c4.smd",
            price = 1000,
            description = easzy.quadcopter.languages.c4Description,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {"BombHook", "Bomb", "Speaker"},
            information = easzy.quadcopter.languages.c4Information
        },
        ["Camera"] = {
            key = "Camera",
            name = easzy.quadcopter.languages.camera,
            bodygroup = "camera",
            value = "dji_quadcopter_camera.smd",
            price = 50,
            description = easzy.quadcopter.languages.cameraDescription,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {},
            information = easzy.quadcopter.languages.cameraDJIInformation
        },
        ["BombHook"] = {
            key = "BombHook",
            name = easzy.quadcopter.languages.bombHook,
            bodygroup = "bomb_hook",
            value = "dji_quadcopter_bomb_hook.smd",
            price = 30,
            description = easzy.quadcopter.languages.bombHookDescription,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {"C4", "Speaker"}
        },
        ["Bomb"] = {
            key = "Bomb",
            name = easzy.quadcopter.languages.bomb,
            bodygroup = "bomb",
            value = "dji_quadcopter_bomb.smd",
            price = 300,
            description = easzy.quadcopter.languages.bombDescription,
            customCheck = function(quadcopter, ply) return quadcopter.equipments["BombHook"] end,
            customCheckMessage = "You don't have any bomb hook.",
            blackList = {"C4", "Speaker"},
            information = easzy.quadcopter.languages.bombInformation
        },
        ["Light"] = {
            key = "Light",
            name = easzy.quadcopter.languages.light,
            bodygroup = "light",
            value = "dji_quadcopter_light.smd",
            price = 100,
            description = easzy.quadcopter.languages.lightDescription,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {},
            information = easzy.quadcopter.languages.lightInformation
        },
        ["Speaker"] = {
            key = "Speaker",
            name = easzy.quadcopter.languages.speaker,
            bodygroup = "speaker",
            value = "dji_quadcopter_speaker.smd",
            price = 300,
            description = easzy.quadcopter.languages.speakerDescription,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {"BombHook", "Bomb", "C4"},
            information = easzy.quadcopter.languages.speakerInformation
        },
        ["Battery"] = {
            key = "Battery",
            name = easzy.quadcopter.languages.battery,
            bodygroup = "",
            value = "",
            price = 20,
            description = easzy.quadcopter.languages.batteryDescription,
            action = function(quadcopter)
                quadcopter.battery = 100
                easzy.quadcopter.SyncQuadcopter(quadcopter)
            end,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {}
        }
    },
    colors = {
        ["Propellers"] = {
            key = "Propellers",
            name = easzy.quadcopter.languages.propellers,
            material = "easzy/ez_quadcopter/dji_quadcopter/dji_quadcopter_propellers_color",
            price = 50,
            description = easzy.quadcopter.languages.propellersColorDescription
        },
        ["Motors"] = {
            key = "Motors",
            name = easzy.quadcopter.languages.motors,
            material = "easzy/ez_quadcopter/dji_quadcopter/dji_quadcopter_motors_color",
            price = 50,
            description = easzy.quadcopter.languages.motorsColorDescription
        },
        ["Frame"] = {
            key = "Frame",
            name = easzy.quadcopter.languages.frame,
            material = "easzy/ez_quadcopter/dji_quadcopter/dji_quadcopter_frame_color",
            price = 50,
            description = easzy.quadcopter.languages.frameColorDescription
        }
    },
    upgrades = {
        ["Speed"] = {
            key = "Speed",
            name = easzy.quadcopter.languages.speed,
            description = easzy.quadcopter.languages.speedDescription,
            levels = {1, 1.3, 1.5, 2},
            prices = {50, 100, 200}
        },
        ["Resistance"] = {
            key = "Resistance",
            name = easzy.quadcopter.languages.resistance,
            description = easzy.quadcopter.languages.resistanceDescription,
            levels = {1, 1.5, 2, 2.5, 3},
            prices = {50, 100, 200, 500}
        },
        ["Distance"] = {
            key = "Distance",
            name = easzy.quadcopter.languages.distance,
            description = easzy.quadcopter.languages.distanceDescription,
            levels = {400000, 1000000, 2250000, 90000000},
            prices = {50, 100, 200}
        },
        ["Battery"] = {
            key = "Battery",
            name = easzy.quadcopter.languages.battery,
            description = easzy.quadcopter.languages.batteryUpgradeDescription,
            levels = {3, 5, 7, 9},
            prices = {100, 300, 600}
        },
        -- ["Untraceable"] = {
        --     key = "Untraceable",
        --     name = easzy.quadcopter.languages.untraceable,
        --     description = easzy.quadcopter.languages.untraceableDescription,
        --     levels = {1, 2},
        --     prices = {1000}
        -- }
    }
}

quadcoptersData["ez_quadcopter_fpv"] = {
    equipments = {
        ["C4"] = {
            key = "C4",
            name = easzy.quadcopter.languages.c4,
            bodygroup = "c4",
            value = "fpv_quadcopter_c4.smd",
            price = 1000,
            description = easzy.quadcopter.languages.c4Description,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {"BombHook", "Bomb", "Speaker"},
            information = easzy.quadcopter.languages.c4Information
        },
        ["Camera"] = {
            key = "Camera",
            name = easzy.quadcopter.languages.camera,
            bodygroup = "camera",
            value = "fpv_quadcopter_camera.smd",
            price = 50,
            description = easzy.quadcopter.languages.cameraDescription,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {},
            information = easzy.quadcopter.languages.cameraFPVInformation
        },
        ["Battery"] = {
            key = "Battery",
            name = easzy.quadcopter.languages.battery,
            bodygroup = "",
            value = "",
            price = 20,
            description = easzy.quadcopter.languages.batteryDescription,
            action = function(quadcopter)
                quadcopter.battery = 100
                easzy.quadcopter.SyncQuadcopter(quadcopter)
            end,
            customCheck = function(quadcopter, ply) return true end,
            customCheckMessage = "",
            blackList = {}
        }
    },
    colors = {
        ["Propellers"] = {
            key = "Propellers",
            name = easzy.quadcopter.languages.propellers,
            material = "easzy/ez_quadcopter/fpv_quadcopter/fpv_quadcopter_propellers",
            price = 50,
            description = easzy.quadcopter.languages.propellersColorDescription
        },
        ["Battery"] = {
            key = "Battery",
            name = easzy.quadcopter.languages.battery,
            material = "easzy/ez_quadcopter/fpv_quadcopter/fpv_quadcopter_battery",
            price = 50,
            description = easzy.quadcopter.languages.batteryColorDescription
        }
    },
    upgrades = {
        ["Speed"] = {
            key = "Speed",
            name = easzy.quadcopter.languages.speed,
            description = easzy.quadcopter.languages.speedDescription,
            levels = {1.3, 1.5, 2, 2.5},
            prices = {50, 100, 200}
        },
        ["Resistance"] = {
            key = "Resistance",
            name = easzy.quadcopter.languages.resistance,
            description = easzy.quadcopter.languages.resistanceDescription,
            levels = {1, 1.3, 1.6, 2, 2.6},
            prices = {50, 100, 200, 500}
        },
        ["Distance"] = {
            key = "Distance",
            name = easzy.quadcopter.languages.distance,
            description = easzy.quadcopter.languages.distanceDescription,
            levels = {400000, 1000000, 2250000, 90000000},
            prices = {50, 100, 200}
        },
        ["Battery"] = {
            key = "Battery",
            name = easzy.quadcopter.languages.battery,
            description = easzy.quadcopter.languages.batteryUpgradeDescription,
            levels = {1.5, 3, 5, 7},
            prices = {100, 300, 600}
        },
        -- ["Untraceable"] = {
        --     key = "Untraceable",
        --     name = easzy.quadcopter.languages.untraceable,
        --     description = easzy.quadcopter.languages.untraceableDescription,
        --     levels = {1, 2},
        --     prices = {1000}
        -- }
    }
}

-- Don't touch if you are not sure
if CLIENT then
    -- DJI icons
    quadcoptersData["ez_quadcopter_dji"].equipments["C4"].icon = easzy.quadcopter.materials.djiC4
    quadcoptersData["ez_quadcopter_dji"].equipments["Camera"].icon = easzy.quadcopter.materials.djiCamera
    quadcoptersData["ez_quadcopter_dji"].equipments["BombHook"].icon = easzy.quadcopter.materials.djiBombHook
    quadcoptersData["ez_quadcopter_dji"].equipments["Bomb"].icon = easzy.quadcopter.materials.djiBomb
    quadcoptersData["ez_quadcopter_dji"].equipments["Speaker"].icon = easzy.quadcopter.materials.djiSpeaker
    quadcoptersData["ez_quadcopter_dji"].equipments["Light"].icon = easzy.quadcopter.materials.djiLight
    quadcoptersData["ez_quadcopter_dji"].equipments["Battery"].icon = easzy.quadcopter.materials.djiBattery

    quadcoptersData["ez_quadcopter_dji"].colors["Propellers"].icon = easzy.quadcopter.materials.djiPropeller
    quadcoptersData["ez_quadcopter_dji"].colors["Motors"].icon = easzy.quadcopter.materials.djiMotor
    quadcoptersData["ez_quadcopter_dji"].colors["Frame"].icon = easzy.quadcopter.materials.djiFrame

    quadcoptersData["ez_quadcopter_dji"].upgrades["Speed"].icon = easzy.quadcopter.materials.speed
    quadcoptersData["ez_quadcopter_dji"].upgrades["Resistance"].icon = easzy.quadcopter.materials.resistance
    quadcoptersData["ez_quadcopter_dji"].upgrades["Distance"].icon = easzy.quadcopter.materials.distance
    quadcoptersData["ez_quadcopter_dji"].upgrades["Battery"].icon = easzy.quadcopter.materials.battery
    -- quadcoptersData["ez_quadcopter_dji"].upgrades["Untraceable"].icon = easzy.quadcopter.materials.untraceable

    -- FPV icons
    quadcoptersData["ez_quadcopter_fpv"].equipments["C4"].icon = easzy.quadcopter.materials.fpvC4
    quadcoptersData["ez_quadcopter_fpv"].equipments["Camera"].icon = easzy.quadcopter.materials.fpvCamera
    quadcoptersData["ez_quadcopter_fpv"].equipments["Battery"].icon = easzy.quadcopter.materials.fpvBattery

    quadcoptersData["ez_quadcopter_fpv"].colors["Propellers"].icon = easzy.quadcopter.materials.fpvPropeller
    quadcoptersData["ez_quadcopter_fpv"].colors["Battery"].icon = easzy.quadcopter.materials.fpvBattery

    quadcoptersData["ez_quadcopter_fpv"].upgrades["Speed"].icon = easzy.quadcopter.materials.speed
    quadcoptersData["ez_quadcopter_fpv"].upgrades["Resistance"].icon = easzy.quadcopter.materials.resistance
    quadcoptersData["ez_quadcopter_fpv"].upgrades["Distance"].icon = easzy.quadcopter.materials.distance
    quadcoptersData["ez_quadcopter_fpv"].upgrades["Battery"].icon = easzy.quadcopter.materials.battery
    -- quadcoptersData["ez_quadcopter_fpv"].upgrades["Untraceable"].icon = easzy.quadcopter.materials.untraceable
end
