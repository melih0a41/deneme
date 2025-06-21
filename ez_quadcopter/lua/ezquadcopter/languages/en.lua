if (easzy.quadcopter.config.language != "en") then return end

easzy.quadcopter.languages = easzy.quadcopter.languages or {}

local languages = easzy.quadcopter.languages

languages.buy = "Buy"
languages.reset = "Reset"
languages.quit = "Quit"
languages.maximum = "Maximum"
languages.remove = "Remove"

languages.on = "ON"
languages.off = "OFF"
languages.equipments = "EQUIPMENTS"
languages.colors = "COLORS"
languages.upgrades = "UPGRADES"

languages.pressToRepair = "Press E to repair"
languages.pressToUpgrade = "Press E to upgrade"
languages.cameraAngle = "Camera angle"

languages.repair = "Repair"
languages.repairQuadcopter = "Repair the quadcopter"

-- Equipments
languages.c4 = "C4"
languages.camera = "Camera"
languages.bombHook = "Bomb hook"
languages.bomb = "Bomb"
languages.light = "Light"
languages.speaker = "Speaker"
languages.battery = "Battery"

languages.c4Description = "Explosive attached to the drone."
languages.cameraDescription = "Camera for remote control of the drone."
languages.bombHookDescription = "Hook for dropping bombs."
languages.bombDescription = "Bomb to attach to hook."
languages.lightDescription = "Light attached to drone."
languages.speakerDescription = "Speaker on the drone."
languages.batteryDescription = "Drone battery."

languages.c4Information = "Press R to explode"
languages.cameraDJIInformation = "Up/Down Arrows to move the camera | N to activate night vision"
languages.cameraFPVInformation = "Up/Down Arrows to move the camera"
languages.bombInformation = "Press R to drop the bomb"
languages.lightInformation = "Press Shift to turn on the light"
languages.speakerInformation = "Press E to toggle the speaker on/off and hold the key to speak"

-- Colors
languages.propellers = "Propellers"
languages.motors = "Motors"
languages.frame = "Frame"

languages.propellersColorDescription = "Change the color of the propellers."
languages.motorsColorDescription = "Change the color of the motors."
languages.frameColorDescription = "Change frame color."
languages.batteryColorDescription = "Change the color of the battery."

-- Upgrades
languages.speed = "Speed"
languages.resistance = "Resistance"
languages.distance = "Distance"
languages.battery = "Battery"
languages.untraceable = "Untraceable"

languages.speedDescription = "Increase drone speed."
languages.resistanceDescription = "Increase the drone's resistance."
languages.distanceDescription = "Increase the drone's range."
languages.batteryUpgradeDescription = "Increase battery life."
languages.untraceableDescription = "Makes the drone untrackable by radar."
