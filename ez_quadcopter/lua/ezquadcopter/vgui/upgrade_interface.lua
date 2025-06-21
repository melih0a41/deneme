local PANEL = {}

AccessorFunc(PANEL, "color", "Color")
AccessorFunc(PANEL, "textcolor", "TextColor")
AccessorFunc(PANEL, "layoutsize", "LayoutSize")

AccessorFunc(PANEL, "quadcopter", "Quadcopter")
AccessorFunc(PANEL, "quadcopterview", "QuadcopterView")
AccessorFunc(PANEL, "quadcopterbodygroups", "QuadcopterBodygroups")
AccessorFunc(PANEL, "quadcopterdata", "QuadcopterData")

function PANEL:Init()
    local scrW = ScrW()
    local scrH = ScrH()

    self:SetPos(0, 0)
    self:SetSize(scrW, scrH)
    self:Center()
    self:SetColor(Color(15, 15, 15, 230))
    self:SetTextColor(Color(255, 255, 255))

    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self.lblTitle:Hide()

    self.startTime = SysTime()
    self.animProgress = 0
end

function PANEL:Reload()
    timer.Simple(0.2, function()
        if not IsValid(self) then return end
        self:Clear()
        self:LoadQuitButton()
        self:LoadInterface()
    end)
end

function PANEL:ResetBodygroups()
    -- The timer is used to let the time to the model to update its bodygroups
    timer.Simple(0.2, function()
        if not IsValid(self) then return end
        local quadcopter = self:GetQuadcopter()
        local quadcopterView = self:GetQuadcopterView()
        for _, bodygroup in ipairs(quadcopter:GetBodyGroups()) do
            local value = quadcopter:GetBodygroup(bodygroup.id)
            quadcopterView:SetBodygroup(bodygroup.id, value)
        end
    end)
end

function PANEL:LoadEquipments()
    local quadcopter = self:GetQuadcopter()
    local size = self:GetLayoutSize()
    local quadcopterData = self:GetQuadcopterData()
    local equipments = quadcopterData.equipments
    local quadcopterView = self:GetQuadcopterView()

    -- Modern card container
    local equipmentsContainer = vgui.Create("DPanel", self)
    equipmentsContainer:SetPos(easzy.quadcopter.RespX(80), easzy.quadcopter.RespY(380)) -- Daha aşağı aldık
    equipmentsContainer:SetSize(size * table.Count(equipments) + 80, size + 140)
    equipmentsContainer.Paint = function(s, w, h)
        -- Modern card background
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 200))
        draw.RoundedBox(12, 2, 2, w-4, h-4, Color(0, 0, 0, 30)) -- Border effect
        
        -- Title
        draw.SimpleText(easzy.quadcopter.languages.equipments, "EZFont30", w/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Subtitle line
        surface.SetDrawColor(Color(0, 123, 255, 150))
        surface.DrawRect(w/2 - 50, 35, 100, 2)
    end

    local equipmentsLayout = vgui.Create("DIconLayout", equipmentsContainer)
    equipmentsLayout:SetPos(20, 60) -- Başlangıç pozisyonunu aşağı aldık
    equipmentsLayout:SetSize(size * table.Count(equipments), size)
    equipmentsLayout:SetSpaceY(0)
    equipmentsLayout:SetSpaceX(20) -- Boşlukları artırdık

    -- Create blacklist
    local blackList = {}
    for name, equipped in pairs(quadcopter.equipments) do
        if equipped then
            for _, equipment in ipairs(equipments[name].blackList) do
                blackList[equipment] = true
            end
        end
    end

    for _, equipment in pairs(equipments) do
        local equipmentButton = equipmentsLayout:Add("DButton")
        equipmentButton:SetSize(size, size)
        equipmentButton:SetText("")
        
        -- Animation variables
        equipmentButton.hoverProgress = 0
        equipmentButton.isEquipped = quadcopter.equipments[equipment.key] or false
        
        equipmentButton.Paint = function(s, w, h)
            -- Smooth hover animation
            local target = s:IsHovered() and 1 or 0
            s.hoverProgress = Lerp(FrameTime() * 8, s.hoverProgress, target)
            
            local baseColor = s.isEquipped and Color(40, 167, 69) or Color(35, 35, 35)
            local hoverColor = s.isEquipped and Color(34, 139, 59) or Color(0, 123, 255)
            local finalColor = Color(
                Lerp(s.hoverProgress, baseColor.r, hoverColor.r),
                Lerp(s.hoverProgress, baseColor.g, hoverColor.g),
                Lerp(s.hoverProgress, baseColor.b, hoverColor.b),
                200
            )
            
            -- Card background with shadow
            draw.RoundedBox(10, 3, 3, w, h, Color(0, 0, 0, 50))
            draw.RoundedBox(10, 0, 0, w, h, finalColor)
            
            -- Icon
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(equipment.icon)
            local iconSize = w * 0.6
            surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
            
            -- Equipment indicator
            if s.isEquipped then
                draw.RoundedBox(4, w - 12, 4, 8, 8, Color(255, 255, 255))
            end
            
            return true
        end
        
        equipmentButton.PaintOver = function(s, w, h)
            -- Modern text styling with better spacing
            draw.SimpleText(equipment.name, "EZFont20", w/2, h + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            local priceColor = s.isEquipped and Color(40, 167, 69) or Color(0, 123, 255)
            draw.SimpleText(easzy.quadcopter.FormatCurrency(equipment.price), "EZFont20", w/2, h + 45, priceColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        
        equipmentButton.DoClick = function()
            if easzy.quadcopter.buyFrame then return end

            easzy.quadcopter.SetBodygroupByName(quadcopterView, equipment.bodygroup, equipment.value)

            local buyEquipment = vgui.Create("EZQuadcopterBuyEquipment", self)
            buyEquipment:SetSize(easzy.quadcopter.RespX(450), easzy.quadcopter.RespY(250))
            buyEquipment:SetPos((ScrW() - easzy.quadcopter.RespX(450))/2, (ScrH() - easzy.quadcopter.RespY(250))/2)
            buyEquipment:SetQuadcopter(quadcopter)
            buyEquipment:SetEquipment(equipment)
            buyEquipment:LoadInterface()
            buyEquipment.OnRemove = function(s)
                self:ResetBodygroups()
                easzy.quadcopter.buyFrame = nil
                self:Reload()
            end

            easzy.quadcopter.buyFrame = buyEquipment
        end

        -- Disable if requirements not met
        local localPlayer = LocalPlayer()
        if not equipment.customCheck(quadcopter, localPlayer) or blackList[equipment.key] then
            equipmentButton.Paint = function(s, w, h)
                -- Disabled styling
                draw.RoundedBox(10, 3, 3, w, h, Color(0, 0, 0, 50))
                draw.RoundedBox(10, 0, 0, w, h, Color(60, 60, 60, 150))
                
                surface.SetDrawColor(Color(120, 120, 120, 255))
                surface.SetMaterial(equipment.icon)
                local iconSize = w * 0.6
                surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
                
                return true
            end
            equipmentButton.DoClick = function() end
        end
    end
end

function PANEL:LoadColors()
    local size = self:GetLayoutSize()
    local quadcopter = self:GetQuadcopter()
    local quadcopterData = self:GetQuadcopterData()
    local colors = quadcopterData.colors
    local quadcopterView = self:GetQuadcopterView()

    -- Modern card container for colors
    local colorsContainer = vgui.Create("DPanel", self)
    colorsContainer:SetPos(easzy.quadcopter.RespX(80), easzy.quadcopter.RespY(200)) -- Ekipmanlardan yukarı aldık
    colorsContainer:SetSize(size * table.Count(colors) + 80, size + 140)
    colorsContainer.Paint = function(s, w, h)
        -- Modern card background
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 200))
        draw.RoundedBox(12, 2, 2, w-4, h-4, Color(0, 0, 0, 30))
        
        -- Title
        draw.SimpleText(easzy.quadcopter.languages.colors, "EZFont30", w/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Subtitle line
        surface.SetDrawColor(Color(156, 39, 176, 150))
        surface.DrawRect(w/2 - 50, 35, 100, 2)
    end

    local colorsLayout = vgui.Create("DIconLayout", colorsContainer)
    colorsLayout:SetPos(20, 60) -- Başlangıç pozisyonunu aşağı aldık
    colorsLayout:SetSize(size * table.Count(colors), size)
    colorsLayout:SetSpaceY(0)
    colorsLayout:SetSpaceX(20) -- Boşlukları artırdık

    for _, part in pairs(colors) do
        local colorButton = colorsLayout:Add("DButton")
        colorButton:SetSize(size, size)
        colorButton:SetText("")
        colorButton.hoverProgress = 0
        
        colorButton.Paint = function(s, w, h)
            local target = s:IsHovered() and 1 or 0
            s.hoverProgress = Lerp(FrameTime() * 8, s.hoverProgress, target)
            
            local baseColor = Color(35, 35, 35)
            local hoverColor = Color(156, 39, 176)
            local finalColor = Color(
                Lerp(s.hoverProgress, baseColor.r, hoverColor.r),
                Lerp(s.hoverProgress, baseColor.g, hoverColor.g),
                Lerp(s.hoverProgress, baseColor.b, hoverColor.b),
                200
            )
            
            draw.RoundedBox(10, 3, 3, w, h, Color(0, 0, 0, 50))
            draw.RoundedBox(10, 0, 0, w, h, finalColor)
            
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(part.icon)
            local iconSize = w * 0.6
            surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
            
            return true
        end
        
        colorButton.PaintOver = function(s, w, h)
            draw.SimpleText(part.name, "EZFont20", w/2, h + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText(easzy.quadcopter.FormatCurrency(part.price), "EZFont20", w/2, h + 45, Color(156, 39, 176), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        
        colorButton.DoClick = function()
            if easzy.quadcopter.buyFrame then return end

            local buyColor = vgui.Create("EZQuadcopterBuyColor", self)
            buyColor:SetSize(easzy.quadcopter.RespX(450), easzy.quadcopter.RespY(300))
            buyColor:SetPos((ScrW() - easzy.quadcopter.RespX(450))/2, (ScrH() - easzy.quadcopter.RespY(300))/2)
            buyColor:SetQuadcopter(quadcopter)
            buyColor:SetQuadcopterView(quadcopterView)
            buyColor:SetPart(part)
            buyColor:LoadInterface()

            easzy.quadcopter.buyFrame = buyColor
        end

        -- Set the good subMaterials for the 3D model
        for index, material in ipairs(quadcopterView:GetMaterials()) do
            if material == part.material then
                easzy.quadcopter.ResetSubMaterialColor(quadcopter, quadcopterView, index, part.key)
                break
            end
        end
    end
end

function PANEL:LoadUpgrades()
    local size = self:GetLayoutSize()
    local quadcopter = self:GetQuadcopter()
    local quadcopterData = self:GetQuadcopterData()
    local upgrades = quadcopterData.upgrades

    -- Modern card container for upgrades
    local upgradesContainer = vgui.Create("DPanel", self)
    upgradesContainer:SetPos(ScrW() - easzy.quadcopter.RespX(size * table.Count(upgrades) + 160), easzy.quadcopter.RespY(200))
    upgradesContainer:SetSize(size * table.Count(upgrades) + 80, size + 140)
    upgradesContainer.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 200))
        draw.RoundedBox(12, 2, 2, w-4, h-4, Color(0, 0, 0, 30))
        
        draw.SimpleText(easzy.quadcopter.languages.upgrades, "EZFont30", w/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(Color(255, 193, 7, 150))
        surface.DrawRect(w/2 - 50, 35, 100, 2)
    end

    local upgradesLayout = vgui.Create("DIconLayout", upgradesContainer)
    upgradesLayout:SetPos(20, 60) -- Başlangıç pozisyonunu aşağı aldık
    upgradesLayout:SetSize(size * table.Count(upgrades), size)
    upgradesLayout:SetSpaceY(0)
    upgradesLayout:SetSpaceX(20) -- Boşlukları artırdık

    for _, upgrade in pairs(upgrades) do
        local currentUpgradeLevel = quadcopter.upgrades[upgrade.key]
        local upgradePrice = upgrade.prices[currentUpgradeLevel]
        local maxLevel = currentUpgradeLevel == table.Count(upgrade.levels)

        local upgradeButton = upgradesLayout:Add("DButton")
        upgradeButton:SetSize(size, size)
        upgradeButton:SetText("")
        upgradeButton.hoverProgress = 0
        upgradeButton.isMaxLevel = maxLevel
        
        upgradeButton.Paint = function(s, w, h)
            local target = s:IsHovered() and 1 or 0
            s.hoverProgress = Lerp(FrameTime() * 8, s.hoverProgress, target)
            
            local baseColor = s.isMaxLevel and Color(255, 193, 7) or Color(35, 35, 35)
            local hoverColor = s.isMaxLevel and Color(255, 160, 0) or Color(255, 193, 7)
            local finalColor = Color(
                Lerp(s.hoverProgress, baseColor.r, hoverColor.r),
                Lerp(s.hoverProgress, baseColor.g, hoverColor.g),
                Lerp(s.hoverProgress, baseColor.b, hoverColor.b),
                200
            )
            
            draw.RoundedBox(10, 3, 3, w, h, Color(0, 0, 0, 50))
            draw.RoundedBox(10, 0, 0, w, h, finalColor)
            
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(upgrade.icon)
            local iconSize = w * 0.6
            surface.DrawTexturedRect(w/2 - iconSize/2, h/2 - iconSize/2, iconSize, iconSize)
            
            -- Level indicator - konumu düzeltelim
            local levelText = currentUpgradeLevel .. "/" .. table.Count(upgrade.levels)
            draw.SimpleText(levelText, "EZFont20", w - 8, 8, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            
            return true
        end
        
        upgradeButton.PaintOver = function(s, w, h)
            draw.SimpleText(upgrade.name, "EZFont20", w/2, h + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            local priceText = upgradePrice and easzy.quadcopter.FormatCurrency(upgradePrice) or easzy.quadcopter.languages.maximum
            local priceColor = s.isMaxLevel and Color(255, 193, 7) or Color(40, 167, 69)
            draw.SimpleText(priceText, "EZFont20", w/2, h + 45, priceColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        
        upgradeButton.DoClick = function()
            if easzy.quadcopter.buyFrame then return end

            local buyUpgrade = vgui.Create("EZQuadcopterBuyUpgrade", self)
            buyUpgrade:SetSize(easzy.quadcopter.RespX(450), easzy.quadcopter.RespY(250))
            buyUpgrade:SetPos((ScrW() - easzy.quadcopter.RespX(450))/2, (ScrH() - easzy.quadcopter.RespY(250))/2)
            buyUpgrade:SetQuadcopter(quadcopter)
            buyUpgrade:SetUpgrade(upgrade)
            buyUpgrade:LoadInterface()
            buyUpgrade.OnRemove = function(s)
                easzy.quadcopter.buyFrame = nil
                self:Reload()
            end

            easzy.quadcopter.buyFrame = buyUpgrade
        end
    end
end

function PANEL:LoadInterface()
    local quadcopter = self:GetQuadcopter()
    local class = quadcopter:GetClass()

    -- 3D model of the quadcopter in the center of the screen
    local model = vgui.Create("DModelPanel", self)
    model:SetPos(ScrW()/2 - 200, ScrH()/2 - 200) -- Y pozisyonunu yukarı aldık
    model:SetSize(400, 300)
    model:SetModel(quadcopter:GetModel())
    model:SetAnimated(true)
    
    -- Modern model container
    model.Paint = function(s, w, h)
        draw.RoundedBox(15, 0, 0, w, h, Color(20, 20, 20, 180))
        draw.RoundedBox(15, 2, 2, w-4, h-4, Color(0, 123, 255, 30))
    end

    -- Save the model entity and its bodygroups
    self:SetQuadcopterView(model:GetEntity())
    local quadcopterView = self:GetQuadcopterView()

    self:ResetBodygroups()

    function model:LayoutEntity(entity)
        local bone = entity:LookupBone(class == "ez_quadcopter_dji" and "dji_quadcopter" or "fpv_quadcopter")
        local bonePos = entity:GetBonePosition(bone)

        model:SetLookAt(bonePos)
        model:SetCamPos(bonePos + Vector(-40, 0, 20))

        entity:SetSequence("rotation")
        self:RunAnimation()

        entity:SetAngles(Angle(0, -(RealTime() * 20 % 360), 0))
    end

    self:SetQuadcopterData(easzy.quadcopter.quadcoptersData[quadcopter:GetClass()])
    self:SetLayoutSize(easzy.quadcopter.RespY(75)) -- Boyutu küçülttük

    -- Info panel
    local infoPanel = vgui.Create("DPanel", self)
    infoPanel:SetPos(ScrW()/2 - 150, ScrH() - 120) -- Biraz daha aşağı aldık
    infoPanel:SetSize(300, 70)
    infoPanel.Paint = function(s, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(25, 25, 25, 200))
        
        -- Battery info
        local batteryPercent = math.Round(quadcopter.battery)
        local batteryColor = batteryPercent > 50 and Color(40, 167, 69) or (batteryPercent > 20 and Color(255, 193, 7) or Color(220, 53, 69))
        
        draw.SimpleText("Batarya: %" .. batteryPercent, "EZFont20", 10, 10, batteryColor)
        
        -- Status
        local statusText = quadcopter.on and "AÇIK" or (quadcopter.broken and "ARIZALI" or "KAPALI")
        local statusColor = quadcopter.on and Color(40, 167, 69) or (quadcopter.broken and Color(220, 53, 69) or Color(108, 117, 125))
        
        draw.SimpleText("Durum: " .. statusText, "EZFont20", 10, 35, statusColor)
        
        -- Battery bar
        local barW = 100
        local barH = 8
        local barX = w - barW - 10
        local barY = 25
        
        draw.RoundedBox(4, barX, barY, barW, barH, Color(60, 60, 60))
        draw.RoundedBox(4, barX, barY, (barW * batteryPercent / 100), barH, batteryColor)
    end

    -- Load modules
    self:LoadEquipments()
    self:LoadColors()
    self:LoadUpgrades()
end

function PANEL:OnRemove()
    easzy.quadcopter.interface = nil
    easzy.quadcopter.buyFrame = nil
end

function PANEL:Think()
    -- Smooth entrance animation
    if self.animProgress < 1 then
        self.animProgress = math.min(self.animProgress + FrameTime() * 3, 1)
    end
end

function PANEL:Paint(w, h)
    -- Enhanced blur effect
    if easzy.quadcopter.config.bluredBackground then
        Derma_DrawBackgroundBlur(self, 0.6)
    end

    -- Animated background
    local alpha = 200 * self.animProgress
    draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 15, alpha))
    
    -- Gradient overlay
    for i = 0, h, 10 do
        local gradientAlpha = math.sin(i / h * math.pi) * 30 * self.animProgress
        surface.SetDrawColor(Color(0, 123, 255, gradientAlpha))
        surface.DrawRect(0, i, w, 10)
    end
    
    -- Grid pattern
    surface.SetDrawColor(Color(255, 255, 255, 5 * self.animProgress))
    for i = 0, w, 50 do
        surface.DrawLine(i, 0, i, h)
    end
    for i = 0, h, 50 do
        surface.DrawLine(0, i, w, i)
    end
end

vgui.Register("EZQuadcopterMenu", PANEL, "EZQuadcopterFrame")