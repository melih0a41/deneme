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
    self:SetColor(easzy.quadcopter.colors.black)
    self:SetTextColor(easzy.quadcopter.colors.white)

    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self.lblTitle:Hide()

    self.startTime = SysTime()
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

    local equipmentsLayout = vgui.Create("DIconLayout", self)
    equipmentsLayout:SetPos(easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(800))
    equipmentsLayout:SetSize(size * table.Count(equipments), size)
    equipmentsLayout:SetSpaceY(0)
    equipmentsLayout:SetSpaceX(0)
    equipmentsLayout:NoClipping(true)
    equipmentsLayout.PaintOver = function(s, w, h)
        draw.SimpleText(easzy.quadcopter.languages.equipments, "EZFont30", w/2, -easzy.quadcopter.RespY(10), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
        surface.DrawLine(w + easzy.quadcopter.RespX(30), -easzy.quadcopter.RespY(30), (ScrW()/2 - s:GetX())*0.6, (ScrH()/2 - s:GetY())*0.6)
    end

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
        local equipmentButton = equipmentsLayout:Add("EZQuadcopterButton")
        equipmentButton:SetColor(easzy.quadcopter.colors.transparentWhite)
        equipmentButton:SetHoveredColor(easzy.quadcopter.colors.transparent)
        equipmentButton:SetTextColor(easzy.quadcopter.colors.black)
        equipmentButton:SetSize(size, size)
        equipmentButton:SetText(equipment.name)
        equipmentButton:NoClipping(true)
        equipmentButton.Paint = function(s, w, h)
            local backgroundColor = s:GetSelect() and s:GetSelectColor() or (s:IsHovered() and s:GetHoveredColor() or s:GetColor())

        	surface.SetDrawColor(backgroundColor)
	        surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
            surface.DrawOutlinedRect(0, 0, w + 1, h, 1)

            surface.SetDrawColor(easzy.quadcopter.colors.white:Unpack())
            surface.SetMaterial(equipment.icon)
            surface.DrawTexturedRect(0, 0, w, h)

            return true
        end
        equipmentButton.PaintOver = function(s, w, h)
            draw.SimpleText(s:GetText(), s:GetFont(), w/2, h + easzy.quadcopter.RespY(10), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText(easzy.quadcopter.FormatCurrency(equipment.price), s:GetFont(), w/2, h + easzy.quadcopter.RespY(35), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        equipmentButton.DoClick = function()
            if easzy.quadcopter.buyFrame then return end

            easzy.quadcopter.SetBodygroupByName(quadcopterView, equipment.bodygroup, equipment.value)

            local buyEquipment = vgui.Create("EZQuadcopterBuyEquipment", self)
            buyEquipment:SetSize(easzy.quadcopter.RespX(400), easzy.quadcopter.RespY(200))
            buyEquipment:SetPos((ScrW() - easzy.quadcopter.RespX(300))/2, ScrH() - easzy.quadcopter.RespY(300))
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

        -- Display equipment but can't buy
        local localPlayer = LocalPlayer()
        if not equipment.customCheck(quadcopter, localPlayer) or blackList[equipment.key] then
            equipmentButton.PaintOver = function(s, w, h)
                surface.SetDrawColor(easzy.quadcopter.colors.transparentBlack)
	            surface.DrawRect(0, 0, w, h)

                draw.SimpleText(s:GetText(), s:GetFont(), w/2, h + easzy.quadcopter.RespY(10), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(easzy.quadcopter.FormatCurrency(equipment.price), s:GetFont(), w/2, h + easzy.quadcopter.RespY(35), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
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

    local colorsLayout = vgui.Create("DIconLayout", self)
    colorsLayout:SetPos(easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(100))
    colorsLayout:SetSize(size * table.Count(colors), size)
    colorsLayout:SetSpaceY(0)
    colorsLayout:SetSpaceX(0)
    colorsLayout:NoClipping(true)
    colorsLayout.PaintOver = function(s, w, h)
        draw.SimpleText(easzy.quadcopter.languages.colors, "EZFont30", w/2, -easzy.quadcopter.RespY(10), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
        surface.DrawLine(w + easzy.quadcopter.RespX(30), h + easzy.quadcopter.RespY(30), (ScrW()/2 - s:GetX())*0.6, (ScrH()/2 - s:GetY())*0.6)
    end

    for _, part in pairs(colors) do
        local colorButton = colorsLayout:Add("EZQuadcopterButton")
        colorButton:SetColor(easzy.quadcopter.colors.transparentWhite)
        colorButton:SetHoveredColor(easzy.quadcopter.colors.transparent)
        colorButton:SetTextColor(easzy.quadcopter.colors.black)
        colorButton:SetSize(size, size)
        colorButton:SetText(part.name)
        colorButton:NoClipping(true)
        colorButton.Paint = function(s, w, h)
            local backgroundColor = s:GetSelect() and s:GetSelectColor() or (s:IsHovered() and s:GetHoveredColor() or s:GetColor())

        	surface.SetDrawColor(backgroundColor)
	        surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
            surface.DrawOutlinedRect(0, 0, w + 1, h, 1)

            surface.SetDrawColor(easzy.quadcopter.colors.white:Unpack())
            surface.SetMaterial(part.icon)
            surface.DrawTexturedRect(0, 0, w, h)

            return true
        end
        colorButton.PaintOver = function(s, w, h)
            draw.SimpleText(s:GetText(), s:GetFont(), w/2, h + easzy.quadcopter.RespY(10), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText(easzy.quadcopter.FormatCurrency(part.price), s:GetFont(), w/2, h + easzy.quadcopter.RespY(35), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        colorButton.DoClick = function()
            if easzy.quadcopter.buyFrame then return end

            local buyColor = vgui.Create("EZQuadcopterBuyColor", self)
            buyColor:SetSize(easzy.quadcopter.RespX(400), easzy.quadcopter.RespY(220))
            buyColor:SetPos((ScrW() - easzy.quadcopter.RespX(300))/2, ScrH() - easzy.quadcopter.RespY(300))
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
    local quadcopterView = self:GetQuadcopterView()

    local upgradesLayout = vgui.Create("DIconLayout", self)
    upgradesLayout:SetPos(easzy.quadcopter.RespX(1400), easzy.quadcopter.RespY(200))
    upgradesLayout:SetSize(size * table.Count(upgrades), size)
    upgradesLayout:SetSpaceY(0)
    upgradesLayout:SetSpaceX(0)
    upgradesLayout:NoClipping(true)
    upgradesLayout.PaintOver = function(s, w, h)
        draw.SimpleText(easzy.quadcopter.languages.upgrades, "EZFont30", w/2, -easzy.quadcopter.RespY(10), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
        surface.DrawLine(-easzy.quadcopter.RespX(30), h + easzy.quadcopter.RespY(30), (ScrW()/2 - s:GetX())*0.4, (ScrH()/2 - s:GetY())*0.6)
    end

    for _, upgrade in pairs(upgrades) do
        local currentUpgradeLevel = quadcopter.upgrades[upgrade.key]
        local upgradePrice = upgrade.prices[currentUpgradeLevel]

        local upgradeButton = upgradesLayout:Add("EZQuadcopterButton")
        upgradeButton:SetColor(easzy.quadcopter.colors.transparentWhite)
        upgradeButton:SetHoveredColor(easzy.quadcopter.colors.transparent)
        upgradeButton:SetTextColor(easzy.quadcopter.colors.black)
        upgradeButton:SetSize(size, size)
        upgradeButton:SetText(upgrade.name)
        upgradeButton:NoClipping(true)
        upgradeButton.Paint = function(s, w, h)
            local backgroundColor = s:GetSelect() and s:GetSelectColor() or (s:IsHovered() and s:GetHoveredColor() or s:GetColor())

        	surface.SetDrawColor(backgroundColor)
	        surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(easzy.quadcopter.colors.black:Unpack())
            surface.DrawOutlinedRect(0, 0, w + 1, h, 1)

            surface.SetDrawColor(easzy.quadcopter.colors.white:Unpack())
            surface.SetMaterial(upgrade.icon)
            surface.DrawTexturedRect(0, 0, w, h)

            return true
        end
        upgradeButton.PaintOver = function(s, w, h)
            draw.SimpleText(s:GetText(), s:GetFont(), w/2, h + easzy.quadcopter.RespY(10), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText(upgradePrice and easzy.quadcopter.FormatCurrency(upgradePrice) or "Maximum", s:GetFont(), w/2, h + easzy.quadcopter.RespY(35), easzy.quadcopter.colors.black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        upgradeButton.DoClick = function()
            if easzy.quadcopter.buyFrame then return end

            local buyUpgrade = vgui.Create("EZQuadcopterBuyUpgrade", self)
            buyUpgrade:SetSize(easzy.quadcopter.RespX(400), easzy.quadcopter.RespY(200))
            buyUpgrade:SetPos((ScrW() - easzy.quadcopter.RespX(300))/2, ScrH() - easzy.quadcopter.RespY(300))
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
    model:Dock(FILL)
    model:SetModel(quadcopter:GetModel())
    model:SetAnimated(true)

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
    self:SetLayoutSize(easzy.quadcopter.RespY(100))

    -- Load modules
    self:LoadEquipments()
    self:LoadColors()
    self:LoadUpgrades()
end

function PANEL:OnRemove()
    easzy.quadcopter.interface = nil
    easzy.quadcopter.buyFrame = nil
end

function PANEL:Paint(w, h)
    if easzy.quadcopter.config.bluredBackground then
        Derma_DrawBackgroundBlur(self, SysTime() - 0.4)
    end

	surface.SetDrawColor(easzy.quadcopter.colors.transparentWhite)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("EZQuadcopterMenu", PANEL, "EZQuadcopterFrame")
