easzy.quadcopter.config = easzy.quadcopter.config or {}
local config = easzy.quadcopter.config

-- GENERAL CONFIGURATION
config.language = "tr" -- "en", "fr", "es", "de", "uk", "hu", "ru", "pl", "tr"

config.speedUnit = "Km/h" -- "Mph", "Km/h"

config.clickSound = true -- Play sound when clicking on the user interface
config.bluredBackground = true -- Blur the menu background
config.blackAndWhiteCam = false -- Set the quadcopter camera in black and white

config.repairPrice = 100 -- Price to repair a quadcopter

-- DRONE FLIGHT IMPROVEMENTS - BALANCED
config.counterGravity = true -- Counter the gravity force
config.counterGravityValue = 9 -- Reduced for better ground detection

-- AUTO HOVER SYSTEM - SMART
config.autoHover = true -- Enable automatic hover mode when no input
config.autoHoverDelay = 3 -- Increased to 3 seconds before entering hover mode
config.hoverStabilization = 20 -- Reduced hover correction strength
config.groundDetection = true -- Enable ground collision detection

-- ENHANCED DURABILITY 
config.durabilityMultiplier = 4 -- Makes drones 4x more durable
config.collisionResistance = 3 -- 3x more collision resistant

-- BATTERY IMPROVEMENTS
config.batteryLifeMultiplier = 1.5 -- 50% longer battery life
config.batteryDrainReduction = 0.5 -- Reduces battery drain by 50%

-- MOVEMENT ENHANCEMENTS - SMOOTH
config.enhancedMovement = true -- Enable enhanced movement system
config.movementMultiplier = 1.2 -- 20% faster movement
config.smoothStabilization = true -- Enable smooth stabilization
config.stabilizationStrength = 8 -- Reduced anti-gravity force

-- UI IMPROVEMENTS
config.modernUI = true -- Enable modern UI design
config.animatedInterface = true -- Enable interface animations
config.improvedFonts = true -- Use better font system
config.showControls = true -- Show control instructions on drone screen

-- PHYSICS IMPROVEMENTS
config.smartPhysics = true -- Enable smart physics detection
config.groundCheckDistance = 30 -- Distance to check for ground collision
config.hoverTolerance = 5 -- Height difference tolerance before correction

-- In order to configure the quadcopters prices go in lua/darkrp_modules/ez_quadcopter/sh_init.lua
-- In order to configure the upgrades and equipments prices go in lua/ezquadcopter_quadcopters_config.lua