if SERVER then
    util.AddNetworkString("ezquadcopter_quadcopter_sync_quadcopter")
    util.AddNetworkString("ezquadcopter_quadcopter_sync_radio_controller")

    function easzy.quadcopter.SyncQuadcopter(quadcopter)
        local equipmentsLenght = table.Count(quadcopter.equipments)
        local colorsLenght = table.Count(quadcopter.colors)
        local upgradesLenght = table.Count(quadcopter.upgrades)

        net.Start("ezquadcopter_quadcopter_sync_quadcopter")

        -- Send quadcopter
        net.WriteEntity(quadcopter)

        net.WriteBool(quadcopter.on)
        net.WriteBool(quadcopter.broken)
        net.WriteUInt(quadcopter.battery, 8)

        -- Send equipments
        net.WriteUInt(equipmentsLenght, 8)
        for equipment, value in pairs(quadcopter.equipments) do
            net.WriteString(equipment)
            net.WriteBool(value)
        end

        -- Send colors
        net.WriteUInt(colorsLenght, 8)
        for part, color in pairs(quadcopter.colors) do
            net.WriteString(part)
            net.WriteColor(color)
        end

        -- Send upgrades
        net.WriteUInt(upgradesLenght, 8)
        for upgrade, level in pairs(quadcopter.upgrades) do
            net.WriteString(upgrade)
            net.WriteUInt(level, 8)
        end

        net.WriteBool(quadcopter.lightOn)
        net.WriteBool(quadcopter.speakerOn)

        net.Broadcast()
    end

    -- Sync
    net.Receive("ezquadcopter_quadcopter_sync_radio_controller", function()
        local radioController = net.ReadEntity()
        if not IsValid(radioController) then return end

        local owner = radioController:GetOwner()
        easzy.quadcopter.SyncRadioController(radioController, owner)
    end)

    function easzy.quadcopter.SyncRadioController(radioController)
        local owner = radioController:GetOwner()

        net.Start("ezquadcopter_quadcopter_sync_radio_controller")
        net.WriteEntity(radioController) -- Send radio controller
        net.WriteEntity(radioController.quadcopter) -- Send quadcopter
        net.Send(owner)
    end
else
    function easzy.quadcopter.SyncRadioController(radioController)
        net.Start("ezquadcopter_quadcopter_sync_radio_controller")
        net.WriteEntity(radioController) -- Send radio controller
        net.SendToServer()
    end

    -- Sync
    net.Receive("ezquadcopter_quadcopter_sync_quadcopter", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        quadcopter.on = net.ReadBool()
        quadcopter.broken = net.ReadBool()
        quadcopter.battery = net.ReadUInt(8)

        -- Receive equipments
        local equipmentsLenght = net.ReadUInt(8)
        for i = 1, equipmentsLenght do
            local key = net.ReadString()
            local value = net.ReadBool()
            quadcopter.equipments[key] = value
        end

        -- Receive colors
        local colorsLenght = net.ReadUInt(8)
        for i = 1, colorsLenght do
            local part = net.ReadString()
            local color = net.ReadColor()
            quadcopter.colors[part] = color
        end

        -- Receive upgrades
        local upgradesLenght = net.ReadUInt(8)
        for i = 1, upgradesLenght do
            local upgrade = net.ReadString()
            local level = net.ReadUInt(8)
            quadcopter.upgrades[upgrade] = level
        end

        quadcopter.lightOn = net.ReadBool()
        quadcopter.speakerOn = net.ReadBool()
    end)

    -- Sync
    net.Receive("ezquadcopter_quadcopter_sync_radio_controller", function()
        local radioController = net.ReadEntity()
        if not IsValid(radioController) then return end

        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        radioController.quadcopter = quadcopter
    end)
end
