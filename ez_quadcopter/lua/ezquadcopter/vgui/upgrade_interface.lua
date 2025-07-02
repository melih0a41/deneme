-- ez_quadcopter/lua/ezquadcopter/vgui/upgrade_interface.lua
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
    
    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self.lblTitle:Hide()

    self.startTime = SysTime()
    self.animationTime = 0.5
    self.selectedCategory = "equipments"
    self.hoveredItem = nil
end

function PANEL:Paint(w, h)
    -- Modern blur background
    if easzy.quadcopter.config.bluredBackground then
        Derma_DrawBackgroundBlur(self, self.startTime)
    end
    
    -- Dark overlay
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)
    
    -- Animated gradient background
    local time = CurTime() * 0.5
    local gradientY = math.sin(time) * 50
    
    -- Top gradient
    surface.SetDrawColor(30, 30, 35, 100)
    surface.DrawRect(0, 0, w, 200 + gradientY)
    
    -- Draw connecting line from 3D model to selected category
    if self.categoryButtons and self.modelPanel and self.itemsPanel then
        local selectedBtn = self.categoryButtons[self.selectedCategory]
        if selectedBtn and IsValid(selectedBtn) then
            -- Get model center position
            local modelX, modelY = self.modelPanel:GetPos()
            local modelW, modelH = self.modelPanel:GetSize()
            local startX = modelX + modelW - 50
            local startY = modelY + modelH/2
            
            -- Get selected button position
            local btnX, btnY = selectedBtn:GetPos()
            local btnW, btnH = selectedBtn:GetSize()
            local midX = btnX + btnW/2
            local midY = btnY + btnH
            
            -- Get items panel position
            local itemsX, itemsY = self.itemsPanel:GetPos()
            local itemsW, itemsH = self.itemsPanel:GetSize()
            local endX = itemsX + 20
            local endY = itemsY + itemsH/2
            
            -- Draw glow effect
            for i = 3, 1, -1 do
                surface.SetDrawColor(100, 200, 255, 10 * i)
                -- First segment: Model to Category button
                surface.DrawLine(startX - i, startY, midX, midY + i*2)
                surface.DrawLine(startX + i, startY, midX, midY + i*2)
                -- Second segment: Category button to Items panel
                surface.DrawLine(midX, midY + i*2, endX - i*2, endY)
                surface.DrawLine(midX, midY + i*2, endX + i*2, endY)
            end
            
            -- Main line
            surface.SetDrawColor(100, 200, 255, 100)
            -- First segment
            surface.DrawLine(startX, startY, midX, midY)
            -- Second segment  
            surface.DrawLine(midX, midY, endX, endY)
            
            -- Draw dots at connection points
            surface.SetDrawColor(100, 200, 255, 255)
            draw.NoTexture()
            
            -- Start dot
            local startDot = {}
            for i = 0, 16 do
                local angle = (i / 16) * math.pi * 2
                table.insert(startDot, {
                    x = startX + math.cos(angle) * 4,
                    y = startY + math.sin(angle) * 4
                })
            end
            surface.DrawPoly(startDot)
            
            -- Middle dot
            local midDot = {}
            for i = 0, 16 do
                local angle = (i / 16) * math.pi * 2
                table.insert(midDot, {
                    x = midX + math.cos(angle) * 3,
                    y = midY + math.sin(angle) * 3
                })
            end
            surface.DrawPoly(midDot)
            
            -- End dot
            local endDot = {}
            for i = 0, 16 do
                local angle = (i / 16) * math.pi * 2
                table.insert(endDot, {
                    x = endX + math.cos(angle) * 4,
                    y = endY + math.sin(angle) * 4
                })
            end
            surface.DrawPoly(endDot)
        end
    end
end

function PANEL:LoadInterface()
    local quadcopter = self:GetQuadcopter()
    local class = quadcopter:GetClass()
    
    -- Close button with modern style
    local closeBtn = vgui.Create("DButton", self)
    closeBtn:SetSize(50, 50)
    closeBtn:SetPos(ScrW() - 70, 20)
    closeBtn:SetText("")
    closeBtn.Paint = function(s, w, h)
        local hovered = s:IsHovered()
        
        -- Circle background
        surface.SetDrawColor(hovered and Color(255, 100, 100, 100) or Color(255, 255, 255, 20))
        draw.NoTexture()
        local segments = 32
        local radius = w/2
        local centerX, centerY = w/2, h/2
        
        local poly = {}
        for i = 0, segments do
            local angle = (i / segments) * math.pi * 2
            table.insert(poly, {
                x = centerX + math.cos(angle) * radius,
                y = centerY + math.sin(angle) * radius
            })
        end
        surface.DrawPoly(poly)
        
        -- X icon
        surface.SetDrawColor(255, 255, 255, hovered and 255 or 200)
        surface.DrawLine(w*0.3, h*0.3, w*0.7, h*0.7)
        surface.DrawLine(w*0.7, h*0.3, w*0.3, h*0.7)
        surface.DrawLine(w*0.3+1, h*0.3, w*0.7+1, h*0.7)
        surface.DrawLine(w*0.7+1, h*0.3, w*0.3+1, h*0.7)
    end
    closeBtn.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        self:AlphaTo(0, 0.2, 0, function()
            self:Remove()
        end)
    end
    
    -- 3D Model Panel with modern frame (LEFT SIDE)
    local modelPanel = vgui.Create("DPanel", self)
    modelPanel:SetSize(500, 500)
    modelPanel:SetPos(50, ScrH()/2 - 250) -- Sol tarafa yerleştir
    modelPanel.Paint = function(s, w, h)
        -- Hexagon frame
        local hex = {}
        local sides = 6
        local radius = math.min(w, h) / 2 - 20
        local centerX, centerY = w/2, h/2
        
        for i = 0, sides do
            local angle = (i / sides) * math.pi * 2 - math.pi/2
            table.insert(hex, {
                x = centerX + math.cos(angle) * radius,
                y = centerY + math.sin(angle) * radius
            })
        end
        
        -- Glow effect
        for i = 5, 1, -1 do
            surface.SetDrawColor(100, 200, 255, 10)
            draw.NoTexture()
            
            local glowHex = {}
            for j = 0, sides do
                local angle = (j / sides) * math.pi * 2 - math.pi/2
                table.insert(glowHex, {
                    x = centerX + math.cos(angle) * (radius + i*2),
                    y = centerY + math.sin(angle) * (radius + i*2)
                })
            end
            surface.DrawPoly(glowHex)
        end
        
        -- Main hexagon
        surface.SetDrawColor(100, 200, 255, 50)
        for i = 1, #hex-1 do
            surface.DrawLine(hex[i].x, hex[i].y, hex[i+1].x, hex[i+1].y)
        end
        
        -- Corner dots
        surface.SetDrawColor(100, 200, 255, 200)
        for i = 1, #hex-1 do
            draw.NoTexture()
            local dot = {}
            for j = 0, 16 do
                local angle = (j / 16) * math.pi * 2
                table.insert(dot, {
                    x = hex[i].x + math.cos(angle) * 3,
                    y = hex[i].y + math.sin(angle) * 3
                })
            end
            surface.DrawPoly(dot)
        end
    end
    
    -- 3D Model
    local model = vgui.Create("DModelPanel", modelPanel)
    model:Dock(FILL)
    model:DockMargin(40, 40, 40, 40)
    model:SetModel(quadcopter:GetModel())
    model:SetAnimated(true)
    
    local oldPaint = model.Paint
    model.Paint = function(s, w, h)
        oldPaint(s, w, h)
    end
    
    self:SetQuadcopterView(model:GetEntity())
    local quadcopterView = self:GetQuadcopterView()
    self:ResetBodygroups()
    
    -- Store model panel reference
    self.modelPanel = modelPanel
    
    function model:LayoutEntity(entity)
        local bone = entity:LookupBone(class == "ez_quadcopter_dji" and "dji_quadcopter" or "fpv_quadcopter")
        local bonePos = bone and entity:GetBonePosition(bone) or entity:GetPos()
        
        model:SetLookAt(bonePos)
        model:SetCamPos(bonePos + Vector(-50, 0, 25))
        
        entity:SetSequence("rotation")
        self:RunAnimation()
        
        -- Smooth rotation
        entity:SetAngles(Angle(0, -(RealTime() * 30 % 360), 0))
    end
    
    -- Title
    local title = vgui.Create("DLabel", self)
    title:SetText(string.upper(quadcopter.PrintName or "QUADCOPTER CONTROL PANEL"))
    title:SetFont("DermaLarge")
    title:SizeToContents()
    title:SetPos(ScrW()/2 - title:GetWide()/2, 50)
    title:SetTextColor(Color(255, 255, 255))
    
    -- Category buttons
    self:CreateCategoryButtons()
    
    -- Load default category
    self:LoadCategory("equipments")
    
    -- Stats panel
    self:CreateStatsPanel()
end

function PANEL:CreateCategoryButtons()
    local categories = {
        {id = "equipments", name = "EKIPMANLAR", icon = "icon16/wrench.png"},
        {id = "colors", name = "RENKLER", icon = "icon16/palette.png"},
        {id = "upgrades", name = "YUKSELTMELER", icon = "icon16/arrow_up.png"}
    }
    
    local buttonW = 200
    local buttonH = 60
    local spacing = 20
    local totalW = (#categories * buttonW) + ((#categories - 1) * spacing)
    local startX = (ScrW() - totalW) / 2
    
    self.categoryButtons = {}
    
    for i, cat in ipairs(categories) do
        local btn = vgui.Create("DButton", self)
        btn:SetSize(buttonW, buttonH)
        btn:SetPos(startX + (i-1) * (buttonW + spacing), 120)
        btn:SetText("")
        btn.category = cat.id
        
        -- Store button reference
        self.categoryButtons[cat.id] = btn
        
        btn.Paint = function(s, w, h)
            local hovered = s:IsHovered()
            local selected = self.selectedCategory == cat.id
            
            -- Background
            local bgColor = Color(30, 30, 35)
            if selected then
                bgColor = Color(100, 200, 255, 100)
            elseif hovered then
                bgColor = Color(60, 60, 70)
            end
            
            draw.RoundedBox(8, 0, 0, w, h, bgColor)
            
            -- Border
            surface.SetDrawColor(100, 200, 255, selected and 255 or (hovered and 150 or 50))
            surface.DrawOutlinedRect(0, 0, w, h)
            
            -- Icon and text
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Material(cat.icon))
            surface.DrawTexturedRect(10, h/2 - 8, 16, 16)
            
            draw.SimpleText(cat.name, "DermaDefault", 35, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = function()
            surface.PlaySound("UI/buttonclick.wav")
            self.selectedCategory = cat.id
            self:LoadCategory(cat.id)
        end
    end
end

function PANEL:LoadCategory(category)
    -- Remove old items
    if self.itemsPanel then
        self.itemsPanel:Remove()
    end
    
    -- Panel boyutunu kategori içeriğine göre dinamik ayarla
    local itemCount = 0
    local quadcopterData = easzy.quadcopter.quadcoptersData[self:GetQuadcopter():GetClass()]
    
    if category == "equipments" then
        itemCount = table.Count(quadcopterData.equipments)
    elseif category == "colors" then
        itemCount = table.Count(quadcopterData.colors)
    elseif category == "upgrades" then
        itemCount = table.Count(quadcopterData.upgrades)
    end
    
    local cols = 3
    local rows = math.ceil(itemCount / cols)
    local itemH = 280
    local spacing = 20
    local panelHeight = rows * (itemH + spacing) + spacing
    
    -- Items panel - boyutu içeriğe göre ayarlandı
    self.itemsPanel = vgui.Create("DPanel", self)
    self.itemsPanel:SetSize(800, math.min(panelHeight, ScrH() - 300))
    self.itemsPanel:SetPos(ScrW() - 950, 200) -- Daha yukarıda başlasın
    self.itemsPanel.Paint = function() end
    
    if category == "equipments" then
        self:LoadEquipments()
    elseif category == "colors" then
        self:LoadColors()
    elseif category == "upgrades" then
        self:LoadUpgrades()
    end
end

function PANEL:LoadEquipments()
    local quadcopter = self:GetQuadcopter()
    local quadcopterData = easzy.quadcopter.quadcoptersData[quadcopter:GetClass()]
    local equipments = quadcopterData.equipments
    
    -- Grid layout
    local itemCount = table.Count(equipments)
    local cols = 3
    local rows = math.ceil(itemCount / cols)
    local itemW, itemH = 240, 280
    local spacing = 20
    
    local i = 0
    for name, equipment in pairs(equipments) do
        local row = math.floor(i / cols)
        local col = i % cols
        
        local item = vgui.Create("DPanel", self.itemsPanel)
        item:SetPos(col * (itemW + spacing), row * (itemH + spacing))
        item:SetSize(itemW, itemH)
        item.equipment = equipment
        item.name = name
        
        item.Paint = function(s, w, h)
            local hovered = s:IsHovered()
            
            -- Card background
            draw.RoundedBox(12, 0, 0, w, h, Color(40, 40, 45, 240))
            
            if hovered then
                -- Glow effect
                for i = 3, 1, -1 do
                    surface.SetDrawColor(100, 200, 255, 10 * i)
                    draw.RoundedBox(12, -i, -i, w+i*2, h+i*2, Color(100, 200, 255, 10 * i))
                end
            end
            
            -- Status indicator
            local hasEquipment = quadcopter.equipments[name]
            if hasEquipment then
                surface.SetDrawColor(100, 255, 100, 100)
                draw.RoundedBox(12, 2, 2, w-4, h-4, Color(100, 255, 100, 20))
            end
            
            -- Icon background
            draw.RoundedBox(8, w/2 - 60, 20, 120, 120, Color(30, 30, 35))
            
            -- Icon
            surface.SetDrawColor(255, 255, 255)
            if equipment.icon then
                surface.SetMaterial(equipment.icon)
            else
                surface.SetMaterial(Material("icon16/wrench.png")) -- Varsayılan ikon
            end
            surface.DrawTexturedRect(w/2 - 50, 30, 100, 100)
            
            -- Name
            draw.SimpleText(equipment.name, "DermaDefaultBold", w/2, 150, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            
            -- Description (wrapped)
            local desc = equipment.description
            if #desc > 40 then
                desc = string.sub(desc, 1, 37) .. "..."
            end
            draw.SimpleText(desc, "DermaDefault", w/2, 175, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            
            -- Price
            local priceText = hasEquipment and "KURULU" or easzy.quadcopter.FormatCurrency(equipment.price)
            local priceColor = hasEquipment and Color(100, 255, 100) or Color(255, 200, 100)
            draw.SimpleText(priceText, "DermaDefaultBold", w/2, h - 70, priceColor, TEXT_ALIGN_CENTER)
            
            -- Action button
            local btnText = hasEquipment and "KALDIR" or "SATIN AL"
            local btnColor = hasEquipment and Color(255, 100, 100, hovered and 150 or 100) or Color(100, 200, 255, hovered and 150 or 100)
            
            -- Store button bounds for click detection
            s.btnX = 50
            s.btnY = h - 40
            s.btnW = w - 100
            s.btnH = 28
            
            -- Check if mouse is over button
            local mx, my = s:LocalCursorPos()
            local btnHovered = mx >= s.btnX and mx <= s.btnX + s.btnW and my >= s.btnY and my <= s.btnY + s.btnH
            
            if btnHovered then
                btnColor = hasEquipment and Color(255, 100, 100, 200) or Color(100, 200, 255, 200)
            end
            
            draw.RoundedBox(6, s.btnX, s.btnY, s.btnW, s.btnH, btnColor)
            draw.SimpleText(btnText, "DermaDefault", w/2, h - 26, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end
        
        item.OnMousePressed = function(s)
            -- Check if click is on button
            local mx, my = s:LocalCursorPos()
            if mx >= s.btnX and mx <= s.btnX + s.btnW and my >= s.btnY and my <= s.btnY + s.btnH then
                surface.PlaySound("UI/buttonclick.wav")
                
                if quadcopter.equipments[name] then
                    easzy.quadcopter.RemoveEquipment(quadcopter, name)
                else
                    easzy.quadcopter.BuyEquipment(quadcopter, name)
                end
                
                -- Refresh after short delay
                timer.Simple(0.5, function()
                    if IsValid(self) then
                        self:LoadCategory(self.selectedCategory)
                    end
                end)
            end
        end
        
        i = i + 1
    end
end

function PANEL:LoadColors()
    local quadcopter = self:GetQuadcopter()
    local quadcopterData = easzy.quadcopter.quadcoptersData[quadcopter:GetClass()]
    local colors = quadcopterData.colors
    
    -- Grid layout
    local itemCount = table.Count(colors)
    local cols = 3
    local rows = math.ceil(itemCount / cols)
    local itemW, itemH = 240, 280
    local spacing = 20
    
    local i = 0
    for name, part in pairs(colors) do
        local row = math.floor(i / cols)
        local col = i % cols
        
        local item = vgui.Create("DPanel", self.itemsPanel)
        item:SetPos(col * (itemW + spacing), row * (itemH + spacing))
        item:SetSize(itemW, itemH)
        item.part = part
        item.name = name
        
        item.Paint = function(s, w, h)
            local hovered = s:IsHovered()
            
            -- Card background
            draw.RoundedBox(12, 0, 0, w, h, Color(40, 40, 45, 240))
            
            if hovered then
                -- Glow effect
                for i = 3, 1, -1 do
                    surface.SetDrawColor(100, 200, 255, 10 * i)
                    draw.RoundedBox(12, -i, -i, w+i*2, h+i*2, Color(100, 200, 255, 10 * i))
                end
            end
            
            -- Icon background
            draw.RoundedBox(8, w/2 - 60, 20, 120, 120, Color(30, 30, 35))
            
            -- Icon
            surface.SetDrawColor(255, 255, 255)
            if part.icon then
                surface.SetMaterial(part.icon)
            else
                surface.SetMaterial(Material("icon16/color_wheel.png")) -- Varsayılan renk ikonu
            end
            surface.DrawTexturedRect(w/2 - 50, 30, 100, 100)
            
            -- Name
            draw.SimpleText(part.name, "DermaDefaultBold", w/2, 150, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            
            -- Current color preview
            local currentColor = quadcopter.colors[name] or Color(255, 255, 255)
            draw.RoundedBox(8, w/2 - 40, 175, 80, 30, Color(30, 30, 35))
            draw.RoundedBox(6, w/2 - 38, 177, 76, 26, currentColor)
            
            -- Price
            draw.SimpleText(easzy.quadcopter.FormatCurrency(part.price), "DermaDefaultBold", w/2, h - 70, Color(255, 200, 100), TEXT_ALIGN_CENTER)
            
            -- Action button
            s.btnX = 50
            s.btnY = h - 40
            s.btnW = w - 100
            s.btnH = 28
            
            local mx, my = s:LocalCursorPos()
            local btnHovered = mx >= s.btnX and mx <= s.btnX + s.btnW and my >= s.btnY and my <= s.btnY + s.btnH
            local btnColor = btnHovered and Color(100, 200, 255, 200) or Color(100, 200, 255, 100)
            
            draw.RoundedBox(6, s.btnX, s.btnY, s.btnW, s.btnH, btnColor)
            draw.SimpleText("RENK SEC", "DermaDefault", w/2, h - 26, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end
        
        item.OnMousePressed = function(s)
            local mx, my = s:LocalCursorPos()
            if mx >= s.btnX and mx <= s.btnX + s.btnW and my >= s.btnY and my <= s.btnY + s.btnH then
                surface.PlaySound("UI/buttonclick.wav")
                self:OpenColorPicker(part, name)
            end
        end
        
        i = i + 1
    end
end

function PANEL:LoadUpgrades()
    local quadcopter = self:GetQuadcopter()
    local quadcopterData = easzy.quadcopter.quadcoptersData[quadcopter:GetClass()]
    local upgrades = quadcopterData.upgrades
    
    -- Grid layout
    local itemCount = table.Count(upgrades)
    local cols = 3
    local rows = math.ceil(itemCount / cols)
    local itemW, itemH = 240, 280
    local spacing = 20
    
    local i = 0
    for name, upgrade in pairs(upgrades) do
        local row = math.floor(i / cols)
        local col = i % cols
        
        local item = vgui.Create("DPanel", self.itemsPanel)
        item:SetPos(col * (itemW + spacing), row * (itemH + spacing))
        item:SetSize(itemW, itemH)
        item.upgrade = upgrade
        item.name = name
        
        local currentLevel = quadcopter.upgrades[name] or 1
        local maxLevel = #upgrade.levels
        local isMaxed = currentLevel >= maxLevel
        
        item.Paint = function(s, w, h)
            local hovered = s:IsHovered()
            
            -- Card background
            draw.RoundedBox(12, 0, 0, w, h, Color(40, 40, 45, 240))
            
            if hovered and not isMaxed then
                -- Glow effect
                for i = 3, 1, -1 do
                    surface.SetDrawColor(100, 200, 255, 10 * i)
                    draw.RoundedBox(12, -i, -i, w+i*2, h+i*2, Color(100, 200, 255, 10 * i))
                end
            end
            
            -- Icon background
            draw.RoundedBox(8, w/2 - 60, 20, 120, 120, Color(30, 30, 35))
            
            -- Icon
            surface.SetDrawColor(255, 255, 255)
            if upgrade.icon then
                surface.SetMaterial(upgrade.icon)
            else
                surface.SetMaterial(Material("icon16/arrow_up.png")) -- Varsayılan yükseltme ikonu
            end
            surface.DrawTexturedRect(w/2 - 50, 30, 100, 100)
            
            -- Name
            draw.SimpleText(upgrade.name, "DermaDefaultBold", w/2, 150, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            
            -- Level indicator
            local levelY = 180
            local maxLevel = upgrade.levels and #upgrade.levels or 4 -- Varsayılan max level
            local currentLevel = quadcopter.upgrades[name] or 1
            local barWidth = (w - 60) / maxLevel - 2
            
            for i = 1, maxLevel do
                local filled = i <= currentLevel
                local barColor = filled and Color(100, 200, 255) or Color(60, 60, 70)
                draw.RoundedBox(2, 30 + (i-1) * (barWidth + 2), levelY, barWidth, 10, barColor)
            end
            
            -- Level text
            draw.SimpleText("Level " .. currentLevel .. "/" .. maxLevel, "DermaDefault", w/2, levelY + 20, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            
            -- Price or maxed text
            local isMaxed = currentLevel >= maxLevel
            if isMaxed then
                draw.SimpleText("MAKSIMUM", "DermaDefaultBold", w/2, h - 70, Color(100, 255, 100), TEXT_ALIGN_CENTER)
                draw.RoundedBox(6, 50, h - 40, w - 100, 28, Color(60, 60, 70))
                draw.SimpleText("FULL", "DermaDefault", w/2, h - 26, Color(150, 150, 150), TEXT_ALIGN_CENTER)
            else
                local nextPrice = upgrade.prices and upgrade.prices[currentLevel] or 100
                draw.SimpleText(easzy.quadcopter.FormatCurrency(nextPrice), "DermaDefaultBold", w/2, h - 70, Color(255, 200, 100), TEXT_ALIGN_CENTER)
                
                s.btnX = 50
                s.btnY = h - 40
                s.btnW = w - 100
                s.btnH = 28
                
                local mx, my = s:LocalCursorPos()
                local btnHovered = mx >= s.btnX and mx <= s.btnX + s.btnW and my >= s.btnY and my <= s.btnY + s.btnH
                local btnColor = btnHovered and Color(100, 200, 255, 200) or Color(100, 200, 255, 100)
                
                draw.RoundedBox(6, s.btnX, s.btnY, s.btnW, s.btnH, btnColor)
                draw.SimpleText("YUKSELT", "DermaDefault", w/2, h - 26, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end
        end
        
        item.OnMousePressed = function(s)
            if not isMaxed then
                local mx, my = s:LocalCursorPos()
                if mx >= s.btnX and mx <= s.btnX + s.btnW and my >= s.btnY and my <= s.btnY + s.btnH then
                    surface.PlaySound("UI/buttonclick.wav")
                    easzy.quadcopter.Upgrade(quadcopter, name)
                    
                    timer.Simple(0.5, function()
                        if IsValid(self) then
                            self:LoadCategory(self.selectedCategory)
                        end
                    end)
                end
            end
        end
        
        i = i + 1
    end
end

function PANEL:CreateStatsPanel()
    local quadcopter = self:GetQuadcopter()
    
    -- Stats paneli artık sol alt köşede, 3D modelin altında
    local statsPanel = vgui.Create("DPanel", self)
    statsPanel:SetSize(400, 120)
    statsPanel:SetPos(75, ScrH() - 170)
    
    statsPanel.Paint = function(s, w, h)
        -- Background
        draw.RoundedBox(12, 0, 0, w, h, Color(30, 30, 35, 240))
        
        -- Border glow
        surface.SetDrawColor(100, 200, 255, 50)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Title
        draw.SimpleText("DRONE DURUMU", "DermaLarge", w/2, 25, Color(100, 200, 255), TEXT_ALIGN_CENTER)
        
        -- Stats in two columns
        local leftX = 30
        local rightX = w/2 + 20
        local y = 60
        
        -- Left column
        draw.SimpleText("Batarya:", "DermaDefault", leftX, y, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        local batteryColor = quadcopter.battery > 50 and Color(100, 255, 100) or (quadcopter.battery > 20 and Color(255, 200, 100) or Color(255, 100, 100))
        draw.SimpleText(math.Round(quadcopter.battery) .. "%", "DermaDefaultBold", leftX + 100, y, batteryColor, TEXT_ALIGN_LEFT)
        
        draw.SimpleText("Durum:", "DermaDefault", leftX, y + 25, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        local statusColor = quadcopter.broken and Color(255, 100, 100) or Color(100, 255, 100)
        draw.SimpleText(quadcopter.broken and "HASARLI" or "AKTIF", "DermaDefaultBold", leftX + 100, y + 25, statusColor, TEXT_ALIGN_LEFT)
        
        -- Right column
        draw.SimpleText("Hiz:", "DermaDefault", rightX, y, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        draw.SimpleText(quadcopter.upgrades.Speed .. "/" .. #easzy.quadcopter.quadcoptersData[quadcopter:GetClass()].upgrades.Speed.levels, "DermaDefaultBold", rightX + 100, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        
        draw.SimpleText("Menzil:", "DermaDefault", rightX, y + 25, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        draw.SimpleText(quadcopter.upgrades.Distance .. "/" .. #easzy.quadcopter.quadcoptersData[quadcopter:GetClass()].upgrades.Distance.levels, "DermaDefaultBold", rightX + 100, y + 25, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        
        -- Battery bar
        local barY = h - 20
        draw.RoundedBox(4, 30, barY, w - 60, 10, Color(60, 60, 70))
        draw.RoundedBox(4, 30, barY, (w - 60) * (quadcopter.battery / 100), 10, batteryColor)
    end
    
    -- Update stats periodically
    local timerName = "QuadcopterStats_" .. tostring(self)
    self.statsTimerName = timerName
    timer.Create(timerName, 0.5, 0, function()
        if IsValid(self) and IsValid(statsPanel) then
            statsPanel:InvalidateLayout()
        else
            timer.Remove(timerName)
        end
    end)
end

function PANEL:OpenColorPicker(part, name)
    local quadcopter = self:GetQuadcopter()
    local quadcopterView = self:GetQuadcopterView()
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 400)
    frame:Center()
    frame:SetTitle(part.name .. " Renk Secimi")
    frame:MakePopup()
    
    local colorPicker = vgui.Create("DColorMixer", frame)
    colorPicker:Dock(FILL)
    colorPicker:SetPalette(true)
    colorPicker:SetAlphaBar(false)
    colorPicker:SetWangs(true)
    colorPicker:SetColor(quadcopter.colors[name] or Color(255, 255, 255))
    
    colorPicker.ValueChanged = function(s, color)
        -- Preview color on model
        for index, material in ipairs(quadcopterView:GetMaterials()) do
            if material == part.material then
                easzy.quadcopter.ChangeSubMaterialColor(quadcopterView, index, name, color)
                break
            end
        end
    end
    
    local applyBtn = vgui.Create("DButton", frame)
    applyBtn:Dock(BOTTOM)
    applyBtn:SetTall(30)
    applyBtn:SetText("Uygula")
    applyBtn.DoClick = function()
        local color = colorPicker:GetColor()
        
        -- Find material index
        for index, material in ipairs(quadcopterView:GetMaterials()) do
            if material == part.material then
                easzy.quadcopter.BuyColor(quadcopter, index, name, color)
                break
            end
        end
        
        frame:Close()
    end
    
    frame.OnClose = function()
        -- Reset preview
        self:ResetBodygroups()
    end
end

function PANEL:ResetBodygroups()
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

function PANEL:OnRemove()
    if self.statsTimerName then
        timer.Remove(self.statsTimerName)
    end
    easzy.quadcopter.interface = nil
    easzy.quadcopter.buyFrame = nil
end

vgui.Register("EZQuadcopterMenu", PANEL, "DFrame")