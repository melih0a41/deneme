-- Open menu
if SERVER then
    util.AddNetworkString("ezquadcopter_menu")

    function easzy.quadcopter.Menu(quadcopter, ply)
        if not easzy.quadcopter.GetInDistance(quadcopter, ply, 100) then return end
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        net.Start("ezquadcopter_menu")
        net.WriteEntity(quadcopter)
        net.Send(ply)
    end
else
    net.Receive("ezquadcopter_menu", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        if easzy.quadcopter.interface then return end

        local interface = vgui.Create("EZQuadcopterMenu")
        interface:SetQuadcopter(quadcopter)
        interface:LoadInterface()

        easzy.quadcopter.interface = interface
    end)
end

-- Open repair menu
if SERVER then
    util.AddNetworkString("ezquadcopter_repair_menu")

    function easzy.quadcopter.RepairMenu(quadcopter, ply)
        if not easzy.quadcopter.GetInDistance(quadcopter, ply, 150) then return end
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        net.Start("ezquadcopter_repair_menu")
        net.WriteEntity(quadcopter)
        net.Send(ply)
    end
else
    net.Receive("ezquadcopter_repair_menu", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        local class = quadcopter:GetClass()

        if easzy.quadcopter.interface then return end

        local interface = vgui.Create("EZQuadcopterFrame")
        interface:SetSize(easzy.quadcopter.RespX(400), easzy.quadcopter.RespY(180))
        interface:SetPos((ScrW() - easzy.quadcopter.RespX(400))/2, (ScrH() - easzy.quadcopter.RespY(300))/2)
        interface:MakePopup()
        interface.quit.DoClick = function(s)
            interface:Remove()
        end
        interface.OnRemove = function()
            easzy.quadcopter.interface = nil
        end

        local containter = vgui.Create("DPanel", interface)
        containter:Dock(FILL)
        containter:DockMargin(0, 0, 0, easzy.quadcopter.RespY(20))
        containter.Paint = function(s, w, h) end

        local iconSize = easzy.quadcopter.RespY(128)
        local icon = vgui.Create("DPanel", containter)
        icon:SetWide(iconSize * 1.4)
        icon:Dock(LEFT)
        icon.Paint = function(s, w, h)
            surface.SetDrawColor(easzy.quadcopter.colors.white:Unpack())

            if class == "ez_quadcopter_dji" then
                surface.SetMaterial(easzy.quadcopter.materials.djiQuadcopter)
            else
                surface.SetMaterial(easzy.quadcopter.materials.fpvQuadcopter)
            end

            surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
        end

        -- Label with text wrapping
        local description = vgui.Create("DLabel", containter)
        description:Dock(FILL)
        description:DockMargin(0, 0, easzy.quadcopter.RespX(10), 0)
        description:SetFont("EZFont20")
        description:SetColor(easzy.quadcopter.colors.black)
        description:SetText(easzy.quadcopter.languages.repairQuadcopter)
        description:SetWrap(true)

        local action = vgui.Create("EZQuadcopterButton", interface)
        action:Dock(BOTTOM)
        action:SetTall(easzy.quadcopter.RespY(40))
        action:SetText(easzy.quadcopter.languages.repair .. " " .. easzy.quadcopter.FormatCurrency(easzy.quadcopter.config.repairPrice))
        action.DoClick = function()
            easzy.quadcopter.RepairQuadcopter(quadcopter)
            interface:Remove()
        end

        easzy.quadcopter.interface = interface
    end)
end

-- Buy equipment
if SERVER then
    util.AddNetworkString("ezquadcopter_buy_equipment")

    net.Receive("ezquadcopter_buy_equipment", function(len, ply)
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        if not easzy.quadcopter.GetInDistance(quadcopter, ply, 100) then return end
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        local equipmentName = net.ReadString()
        if not equipmentName then return end

        local quadcopterClass = quadcopter:GetClass()
        if not quadcopterClass then return end

        local equipment = easzy.quadcopter.quadcoptersData[quadcopterClass].equipments[equipmentName]
        if not equipment then return end

        if not equipment.customCheck(quadcopter, ply) then
            easzy.quadcopter.Notify(ply, equipment.customCheckMessage, 4, 0)
            return
        end

        if not easzy.quadcopter.Pay(ply, equipment.price) then return end

        -- Recharge the battery
        if equipment.action then equipment.action(quadcopter) end

        easzy.quadcopter.SetBodygroupByName(quadcopter, equipment.bodygroup, equipment.value)

        -- If false, set to true else don't add (for the battery)
        if quadcopter.equipments[equipment.key] != nil then quadcopter.equipments[equipment.key] = true end

        -- Update quadcopter table on client side
        easzy.quadcopter.SyncQuadcopter(quadcopter)
    end)
else
    function easzy.quadcopter.BuyEquipment(quadcopter, equipmentName)
        net.Start("ezquadcopter_buy_equipment")
        net.WriteEntity(quadcopter)
        net.WriteString(equipmentName)
        net.SendToServer()
    end
end

-- Remove equipment
if SERVER then
    util.AddNetworkString("ezquadcopter_remove_equipment")

    net.Receive("ezquadcopter_remove_equipment", function(len, ply)
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        if not easzy.quadcopter.GetInDistance(quadcopter, ply, 100) then return end
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        local equipmentName = net.ReadString()
        if not equipmentName then return end

        local quadcopterClass = quadcopter:GetClass()
        if not quadcopterClass then return end

        local equipment = easzy.quadcopter.quadcoptersData[quadcopterClass].equipments[equipmentName]
        if not equipment then return end

        easzy.quadcopter.SetBodygroupByName(quadcopter, equipment.bodygroup, "")
        quadcopter.equipments[equipment.key] = false

        -- Update quadcopter table on client side
        easzy.quadcopter.SyncQuadcopter(quadcopter)
    end)
else
    function easzy.quadcopter.RemoveEquipment(quadcopter, equipmentName)
        net.Start("ezquadcopter_remove_equipment")
        net.WriteEntity(quadcopter)
        net.WriteString(equipmentName)
        net.SendToServer()
    end
end

-- Upgrade
if SERVER then
    util.AddNetworkString("ezquadcopter_upgrade")

    net.Receive("ezquadcopter_upgrade", function(len, ply)
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        if not easzy.quadcopter.GetInDistance(quadcopter, ply, 100) then return end
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        local upgradeName = net.ReadString()
        if not upgradeName then return end

        local quadcopterClass = quadcopter:GetClass()
        if not quadcopterClass then return end

        local upgrade = easzy.quadcopter.quadcoptersData[quadcopterClass].upgrades[upgradeName]
        if not upgrade then return end

        local currentUpgradeLevel = quadcopter.upgrades[upgradeName]
        local upgradePrice = upgrade.prices[currentUpgradeLevel]

        if not easzy.quadcopter.Pay(ply, upgradePrice) then return end

        quadcopter.upgrades[upgradeName] = currentUpgradeLevel + 1

        -- Update quadcopter table on client side
        easzy.quadcopter.SyncQuadcopter(quadcopter)
    end)
else
    function easzy.quadcopter.Upgrade(quadcopter, upgradeName)
        net.Start("ezquadcopter_upgrade")
        net.WriteEntity(quadcopter)
        net.WriteString(upgradeName)
        net.SendToServer()
    end
end

-- Buy color
if SERVER then
    util.AddNetworkString("ezquadcopter_buy_color")

    net.Receive("ezquadcopter_buy_color", function(len, ply)
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        if not easzy.quadcopter.GetInDistance(quadcopter, ply, 100) then return end
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        local subMaterialIndex = net.ReadUInt(8)
        if not subMaterialIndex then return end

        local partName = net.ReadString()
        if not partName then return end

        local color = net.ReadColor()

        local quadcopterClass = quadcopter:GetClass()
        if not quadcopterClass then return end

        local colorData = easzy.quadcopter.quadcoptersData[quadcopterClass].colors[partName]
        if not colorData then return end

        if not easzy.quadcopter.Pay(ply, colorData.price) then return end

        quadcopter.colors[partName] = color

        -- Update quadcopter table on client side
        easzy.quadcopter.BroadcastMaterialColor(quadcopter, subMaterialIndex, partName, color)
    end)
else
    function easzy.quadcopter.BuyColor(quadcopter, subMaterialIndex, partName, color)
        net.Start("ezquadcopter_buy_color")
        net.WriteEntity(quadcopter)
        net.WriteUInt(subMaterialIndex, 8)
        net.WriteString(partName)
        net.WriteColor(color)
        net.SendToServer()
    end
end

-- Repair quadcopter
if SERVER then
    util.AddNetworkString("ezquadcopter_repair_quadcopter")

    net.Receive("ezquadcopter_repair_quadcopter", function(len, ply)
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        if not easzy.quadcopter.GetInDistance(quadcopter, ply, 100) then return end
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        if not easzy.quadcopter.Pay(ply, easzy.quadcopter.config.repairPrice) then return end

        quadcopter.broken = false

    	easzy.quadcopter.SyncQuadcopter(quadcopter)
    end)
else
    function easzy.quadcopter.RepairQuadcopter(quadcopter)
        net.Start("ezquadcopter_repair_quadcopter")
        net.WriteEntity(quadcopter)
        net.SendToServer()
    end
end
