easzy.quadcopter.config = easzy.quadcopter.config or {}
local config = easzy.quadcopter.config

-- GENERAL CONFIGURATION
config.language = "tr" -- "en", "fr", "es", "de", "uk", "hu", "ru", "pl", "tr"

config.speedUnit = "Km/h" -- "Mph", "Km/h"

config.clickSound = true -- Play sound when clicking on the user interface
config.bluredBackground = true -- Blur the menu background
config.blackAndWhiteCam = false -- Set the quadcopter camera in black and white

config.repairPrice = 100 -- Price to repair a quadcopter

-- IF YOUR QUADCOPTER DOSEN'T GO UP SET IT TO TRUE
config.counterGravity = false -- Counter the gravity force
config.counterGravityValue = 18 -- Increase it until the drone flys and is stable in the air when not moving it

-- In order to configure the quadcopters prices go in lua/darkrp_modules/ez_quadcopter/sh_init.lua
-- In order to configure the upgrades and equipments prices go in lua/ezquadcopter_quadcopters_config.lua
