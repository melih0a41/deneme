ENT.PrintName	    = "DJI Quadcopter"
ENT.Author			= "Easzy"
ENT.Category	    = "Easzy's Quadcopter"

ENT.Type            = "ai"
ENT.Base            = "base_ai"

ENT.Spawnable		= true
ENT.AdminOnly       = true
ENT.Model           = "models/easzy/ez_quadcopter/dji_quadcopter/w_dji_quadcopter.mdl"

ENT.AutomaticFrameAdvance = true

-- State
ENT.on = false
ENT.broken = false
ENT.battery = 100

-- Default equipments
ENT.equipments = {
    ["C4"] = false,
    ["Camera"] = false,
    ["BombHook"] = false,
    ["Bomb"] = false,
    ["Speaker"] = false,
    ["Light"] = false
}

-- If light is equiped
ENT.lightOn = false
ENT.speakerOn = false

-- Default colors
ENT.colors = {
    ["Propellers"] = nil,
    ["Motors"] = nil,
    ["Frame"] = nil
}

-- All upgrades on level 1
ENT.upgrades = {
    ["Speed"] = 1,
    ["Resistance"] = 1,
    ["Distance"] = 1,
    ["Untraceable"] = 1,
    ["Battery"] = 1
}
