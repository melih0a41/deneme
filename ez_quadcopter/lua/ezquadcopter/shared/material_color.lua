if SERVER then
    util.AddNetworkString("ezquadcopter_broadcast_material_color")

    function easzy.quadcopter.BroadcastMaterialColor(quadcopter, subMaterialIndex, partName, color)
        net.Start("ezquadcopter_broadcast_material_color")
        net.WriteEntity(quadcopter)
        net.WriteUInt(subMaterialIndex, 8)
        net.WriteString(partName)
        net.WriteColor(color)
        net.Broadcast()
    end
else
    net.Receive("ezquadcopter_broadcast_material_color", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        local subMaterialIndex = net.ReadUInt(8)
        if not subMaterialIndex then return end

        local partName = net.ReadString()
        if not partName then return end

        local color = net.ReadColor()

        easzy.quadcopter.ChangeSubMaterialColor(quadcopter, subMaterialIndex, partName, color)
    end)
end

