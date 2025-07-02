ENT.PrintName	    = "FPV Quadcopter"
ENT.Author			= "Easzy"
ENT.Category	    = "Easzy's Quadcopter"

ENT.Type            = "ai"
ENT.Base            = "base_ai"

ENT.Spawnable		= true
ENT.AdminOnly       = true
ENT.Model           = "models/easzy/ez_quadcopter/fpv_quadcopter/w_fpv_quadcopter.mdl"

ENT.AutomaticFrameAdvance = true

-- State
ENT.on = false
ENT.broken = false
ENT.battery = 100

-- Default equipments
ENT.equipments = {
    ["Camera"] = false,
    ["C4"] = false
}

-- If light is equiped
ENT.lightOn = false
ENT.speakerOn = false

-- Default colors
ENT.colors = {
    ["Propellers"] = nil,
    ["Battery"] = nil
}

-- All upgrades on level 1
ENT.upgrades = {
    ["Speed"] = 1,
    ["Resistance"] = 1,
    ["Distance"] = 1,
    ["Battery"] = 1,
    ["Untraceable"] = 1,
    ["Ghost"] = 0  -- Yeni eklenen (varsayılan kapalı)
}

ENT.equipments = {
    ["Camera"] = false,
    ["C4"] = false,
    ["Microphone"] = false  -- Yeni eklenen
}
