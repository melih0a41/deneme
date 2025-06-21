if SERVER then
    util.AddNetworkString("eztuning_compatibilities_stamina")

    function easzy.quadcopter.toggleStamina(quadcopter, enable)
        local owner = quadcopter:CPPIGetOwner()
        if not IsValid(owner) then return end

        if not IsValid(quadcopter) or not quadcopter.on or quadcopter.broken or quadcopter.battery <= 0 or not easzy.quadcopter.IsHoldingRadioController(owner) then
            enable = true
        end

        if owner.oldInitStamina == nil then
            owner.oldInitStamina = owner.InitStamina
        end

        local newInitStamina = not enable and enable or owner.oldInitStamina
        if owner.InitStamina != newInitStamina then
            net.Start("eztuning_compatibilities_stamina")
            net.WriteBool(newInitStamina)
            net.Send(owner)
        end
    end
else
    net.Receive("eztuning_compatibilities_stamina", function()
        local localPlayer = LocalPlayer()
        local enable = net.ReadBool()
        localPlayer.InitStamina = enable
    end)
end
