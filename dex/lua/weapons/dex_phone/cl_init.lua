include('shared.lua')

local panel = nil
local currentItemIndex = 1
local totalItems = 0
local items = {}
local materialCache = {}
local PlayerJobEntities = {}

local itemOffset = 0
local animationOffset = 0

local SCREEN_WIDTH = 355
local SCREEN_HEIGHT = 735
local ITEM_CARD_HEIGHT = 500
local ANIMATION_SPEED = 8

local COLOR_WARNING_TEXT = Color(200, 200, 200)
local COLOR_BUTTON_NORMAL = Color(60, 60, 65)
local COLOR_BUTTON_HOVER = Color(80, 80, 85)
local COLOR_CLOSE_NORMAL = Color(180, 50, 50)
local COLOR_CLOSE_HOVER = Color(220, 70, 70)
local COLOR_BG = Color(20, 20, 25)
local COLOR_CARD_BG = Color(40, 40, 45, 240)
local COLOR_CARD_BORDER = Color(70, 70, 75)
local COLOR_WHITE = Color(255, 255, 255)
local COLOR_GREEN = Color(120, 255, 120)
local COLOR_RED = Color(255, 120, 120)
local COLOR_GRAY = Color(180, 180, 180)
local COLOR_ORANGE = Color(200, 60, 60)
local backgroundMaterial = Material("vgui/backgroundr.png", "noclamp smooth")

local ghostModel = nil
local ghostOffset = 0
local selectedItem = nil
local ghostItem = nil
local lastGhostUpdate = 0
local ghostPulseTime = 0

local function createFonts()
    surface.CreateFont("Dex_Title", {
        font = "Roboto",
        size = 24,
        weight = 700,
        antialias = true
    })
    
    surface.CreateFont("Dex_ItemName", {
        font = "Roboto",
        size = 30,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("Dex_Price", {
        font = "Roboto",
        size = 18,
        weight = 700,
        antialias = true
    })
    
    surface.CreateFont("Dex_Description", {
        font = "Roboto",
        size = 20,
        weight = 400,
        antialias = true
    })

    surface.CreateFont("Dex_Descriptions", {
        font = "Roboto",
        size = 22,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("Dex_Counter", {
        font = "Roboto",
        size = 16,
        weight = 500,
        antialias = true
    })
        surface.CreateFont("Dex_WarningTitle", {
        font = "Roboto",
        size = 28,
        weight = 700,
        antialias = true
    })
    
    surface.CreateFont("Dex_WarningText", {
        font = "Roboto",
        size = 20,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("Dex_CloseButton", {
        font = "Roboto",
        size = 24,
        weight = 700,
        antialias = true
    })
end

local function drawAutoResizeText(text, font, x, y, color, alignX, alignY, maxWidth, minFont, testOnly)
    if not text or text == "" then return end
    
    minFont = minFont or "DermaDefault"
    testOnly = testOnly or false
    
    local fontSizes = {
        {name = "Dex_Selected_Large", size = 20},
        {name = "Dex_Selected_Medium", size = 18}, 
        {name = "Dex_Selected_Small", size = 16},
        {name = "Dex_Selected_Mini", size = 14}
    }
    
    for _, fontData in ipairs(fontSizes) do
        if not _G["FONT_CREATED_" .. fontData.name] then
            surface.CreateFont(fontData.name, {
                font = "Roboto",
                size = fontData.size,
                weight = 600,
                antialias = true
            })
            _G["FONT_CREATED_" .. fontData.name] = true
        end
    end
    
    for i, fontData in ipairs(fontSizes) do
        surface.SetFont(fontData.name)
        local textW, textH = surface.GetTextSize(text)
        
        if textW <= maxWidth or i == #fontSizes then
            if not testOnly then
                draw.SimpleText(text, fontData.name, x, y, color, alignX, alignY)
            end
            return textW, textH, fontData.name
        end
    end
end

local function getMaterial(imagePath)
    if not imagePath then return nil end
    
    if materialCache[imagePath] then
        return materialCache[imagePath]
    end
        
    local material = Material(imagePath, "noclamp smooth")
        
    materialCache[imagePath] = material
    return material
end

local function drawItem(x, y, w, h, item, alpha)
    alpha = alpha or 255
    
    if x + w < 0 or x > SCREEN_WIDTH then
        return
    end
    
    local visibleX = math.max(0, x)
    local visibleW = math.min(w, SCREEN_WIDTH - visibleX)
    local clipX = math.max(0, -x)
    
    if visibleW <= 0 then return end
    
    local cardColor = Color(COLOR_CARD_BG.r, COLOR_CARD_BG.g, COLOR_CARD_BG.b, alpha * 0.9)
    draw.RoundedBox(0, visibleX, y, visibleW, h, cardColor)
    
    local borderColor = COLOR_CARD_BORDER
    if selectedItem and item and selectedItem.name == item.name then
        borderColor = COLOR_ORANGE
        local glowAlpha = math.sin(RealTime() * 3) * 50 + 100
        surface.SetDrawColor(COLOR_ORANGE.r, COLOR_ORANGE.g, COLOR_ORANGE.b, glowAlpha * alpha / 255)
        if visibleX >= 2 and visibleX + visibleW <= SCREEN_WIDTH - 2 then
            surface.DrawOutlinedRect(visibleX - 2, y - 2, visibleW + 4, h + 4, 4)
        end
    end
    
    surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, alpha)
    surface.DrawOutlinedRect(visibleX, y, visibleW, h, 2)
    
    if not item then return end
    
    local centerX = x + w/2
    if centerX >= 0 and centerX <= SCREEN_WIDTH then
        local nameColor = Color(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, alpha)
        draw.SimpleText(item.name or DEX_LANG.Get("unknown"), "Dex_ItemName", centerX, y + 40, nameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local priceText = DarkRP and DarkRP.formatMoney(item.price or 0) or "$" .. (item.price or 0)
        local priceColor = (item.price or 0) > 500 and 
            Color(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b, alpha) or 
            Color(COLOR_GREEN.r, COLOR_GREEN.g, COLOR_GREEN.b, alpha)
        draw.SimpleText(priceText, "Dex_Price", centerX, y + h - 40, priceColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
        if selectedItem and item and selectedItem.name == item.name then
            local selectedText = ""
            if item.isSWEP then
                selectedText = DEX_LANG.Get("selectedweapon")
            else
                selectedText = DEX_LANG.Get("selected")
            end
            
            local maxTextWidth = w + 11
            
            local textW, textH, usedFont = drawAutoResizeText(
                selectedText,
                "Dex_Description",
                centerX,
                y + 90,
                COLOR_ORANGE,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                maxTextWidth,
                "DermaDefault"
            )
        end        
        local previewY = y + 140
        local previewH = h - 220
        local previewX = math.max(x + 20, 20)
        local previewW = math.min(w - 40, SCREEN_WIDTH - previewX - 20)
        
        if previewW > 0 then
            draw.RoundedBox(10, previewX, previewY, previewW, previewH, Color(30, 30, 35, alpha * 0.8))
            
            local itemImage = item.image
            if itemImage then
                local material = getMaterial(itemImage)
                
                if material then
                    local imageSize = math.min(previewW - 20, previewH - 20)
                    local imageX = previewX + (previewW - imageSize) / 2
                    local imageY = previewY + (previewH - imageSize) / 2
                    
                    surface.SetDrawColor(255, 255, 255, alpha)
                    surface.SetMaterial(material)
                    surface.DrawTexturedRect(imageX, imageY, imageSize, imageSize)
                    
                    surface.SetDrawColor(60, 60, 65, alpha * 0.8)
                    surface.DrawOutlinedRect(imageX - 2, imageY - 2, imageSize + 4, imageSize + 4, 2)
                else                    
                end
            else
            end
        end
    end
end
local function drawPageIndicators(x, y, w)
    if totalItems <= 1 then return end
    
    local dotSize = 8
    local dotSpacing = 20
    local totalWidth = (totalItems - 1) * dotSpacing + dotSize
    local startX = x + w/2 - totalWidth/2
    
    for i = 1, totalItems do
        local dotX = startX + (i - 1) * dotSpacing
        local isActive = i == currentItemIndex
        local color = isActive and COLOR_WHITE or Color(COLOR_GRAY.r, COLOR_GRAY.g, COLOR_GRAY.b, 100)
        
        if isActive then
            draw.RoundedBox(dotSize/2, dotX - 2, y - 2, dotSize + 4, dotSize + 4, color)
        else
            draw.RoundedBox(dotSize/2, dotX, y, dotSize, dotSize, color)
        end
    end
end

function SwipeLeft()
    if currentItemIndex < totalItems then
        currentItemIndex = currentItemIndex + 1
        itemOffset = -150
        surface.PlaySound("ui/buttonrollover.wav")
                
        selectedItem = nil
        if IsValid(ghostModel) then
            ghostModel:Remove()
            ghostModel = nil
            ghostItem = nil
        end
        
        net.Start("Dex_BuySWEP_Clear")
        net.SendToServer()
    end
end

function SwipeRight()
    if currentItemIndex > 1 then
        currentItemIndex = currentItemIndex - 1
        itemOffset = 150
        surface.PlaySound("ui/buttonrollover.wav")
                
        selectedItem = nil
        if IsValid(ghostModel) then
            ghostModel:Remove()
            ghostModel = nil
            ghostItem = nil
        end
        
        net.Start("Dex_BuySWEP_Clear")
        net.SendToServer()
    end
end

local function DrawShadow(x, y, w, h, blur)
    surface.SetDrawColor(0, 0, 0, 100)
    for i = 1, blur do
        surface.DrawOutlinedRect(x - i, y - i, w + i*2, h + i*2)
    end
end

local function DrawBlur(panel, amount)
    surface.SetDrawColor(0, 0, 0, 20)
    surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
end

local function DrawBackground(x, y, w, h, alpha)
    surface.SetDrawColor(0, 0, 0, alpha)
    surface.DrawRect(x, y, w, h)
end

local function Scale(value)
    return value * (ScrH() / 1080)
end

function SelectCurrentItem()
    if totalItems > 0 and items[currentItemIndex] then
        surface.PlaySound("ui/buttonclick.wav")
        
        local item = items[currentItemIndex]
        
        selectedItem = table.Copy(item)
        selectedItem.index = currentItemIndex

        net.Start("Dex_SelectedBuyItem")
            net.WriteUInt(currentItemIndex, 8)
        net.SendToServer()

        if item.entidade == "dex_bed" then
            local warningFrame = vgui.Create("DFrame")
            warningFrame:SetSize(Scale(650), Scale(350))
            warningFrame:Center()
            warningFrame:SetTitle("")
            warningFrame:MakePopup()
            warningFrame:ShowCloseButton(false)
            warningFrame:SetDraggable(false)
            
            warningFrame.Paint = function(self, w, h)
                DrawShadow(0, 0, w, h, 10)
                DrawBlur(self, 1.5)
                
                DrawBackground(0, 0, w, h, 150)
                
                draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 40, 220))
                draw.RoundedBoxEx(8, 0, 0, w, Scale(70), Color(210, 50, 50, 230), true, true, false, false)
                
                surface.SetFont("Dex_WarningTitle")
                local textW, textH = surface.GetTextSize(DEX_LANG.Get("warning_title"))
                                    
                draw.SimpleText(DEX_LANG.Get("warning_title"), "Dex_WarningTitle", w/2, Scale(35), COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                local warningLine1 = DEX_LANG.Get("warning_line1")
                local maxWarningWidth = w + 9

                local _, _, warningFont = drawAutoResizeText(
                    warningLine1,
                    "Dex_WarningText",
                    w/2,
                    Scale(130),
                    COLOR_WARNING_TEXT,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER,
                    maxWarningWidth,
                    "DermaDefault"
                )
                draw.SimpleText(DEX_LANG.Get("warning_line2"), "Dex_WarningText", w/2, Scale(180), COLOR_WARNING_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            local warningCloseButton = vgui.Create("DButton", warningFrame)
            local warningCloseSize = Scale(36)
            warningCloseButton:SetSize(warningCloseSize, warningCloseSize)
            warningCloseButton:SetPos(warningFrame:GetWide() - Scale(50), Scale(17))
            warningCloseButton:SetText("×")
            warningCloseButton:SetFont("Dex_CloseButton")
            warningCloseButton:SetTextColor(COLOR_WHITE)
            warningCloseButton.Paint = function(self, w, h)
                local radius = math.min(w, h) / 2
                draw.RoundedBox(radius, 0, 0, w, h, self:IsHovered() and COLOR_CLOSE_HOVER or COLOR_CLOSE_NORMAL)
            end
            warningCloseButton.DoClick = function()
                warningFrame:Close()
                surface.PlaySound("ui/buttonclickrelease.wav")
            end
            
            local confirmButton = vgui.Create("DButton", warningFrame)
            confirmButton:SetSize(Scale(200), Scale(70))
            confirmButton:SetPos(warningFrame:GetWide()/2 - Scale(100), Scale(250))
            confirmButton:SetText(DEX_LANG.Get("understood_button"))
            confirmButton:SetFont("Dex_WarningText")
            confirmButton:SetTextColor(COLOR_WHITE)
            confirmButton.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, self:IsHovered() and COLOR_BUTTON_HOVER or COLOR_BUTTON_NORMAL)
                
                if self:IsHovered() then
                    surface.SetDrawColor(COLOR_WHITE)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                end
            end
            confirmButton.DoClick = function()
                warningFrame:Close()
                surface.PlaySound("ui/buttonclickrelease.wav")
            
                net.Start("Dex_SpawnGhost")
                    net.WriteString(item.model or "")
                    net.WriteInt(item.offset or 0, 8)
                net.SendToServer()
            end
        else
            if not item.isSWEP then
                net.Start("Dex_SpawnGhost")
                    net.WriteString(item.model or "")
                    net.WriteInt(item.offset or 0, 8)
                net.SendToServer()
            end
        end
    end
end

net.Receive("Dex_SwipeLeft", function()
    SwipeLeft()
end)

net.Receive("Dex_SwipeRight", function()
    SwipeRight()
end)

net.Receive("Dex_SelectItem", function()
    SelectCurrentItem()
end)

function createScreen()
    if not IsValid(panel) then
        panel = vgui.Create("DFrame")
        panel:SetTitle("")
        panel:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
        panel:SetPos(0, 0)
        panel:ShowCloseButton(false)
        panel:SetDraggable(false)
        panel:SetSizable(false)
        panel:SetVisible(false)
        panel:SetMouseInputEnabled(false)

        local swep = LocalPlayer():GetActiveWeapon()
        if IsValid(swep) and swep.ItemsToBuy then
            items = swep.ItemsToBuy
            totalItems = #items
            currentItemIndex = math.max(1, math.min(currentItemIndex, totalItems))
        end

        panel.Paint = function(self, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(backgroundMaterial)
            surface.DrawTexturedRect(0, 0, w, h)

            draw.RoundedBox(42, 0, 0, w, h, Color(COLOR_BG.r, COLOR_BG.g, COLOR_BG.b, 100))
            
            if totalItems == 0 then
                draw.SimpleText(DEX_LANG.Get("buy_menu_title"), "Dex_Title", w/2, h/2, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                return
            end
            
            draw.SimpleText(DEX_LANG.Get("buy_menu_title"), "Dex_Title", w/2, 30, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            local counterText = currentItemIndex .. " / " .. totalItems
            draw.SimpleText(counterText, "Dex_Counter", w/2, 60, COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            animationOffset = Lerp(FrameTime() * ANIMATION_SPEED, animationOffset, 0)
            itemOffset = Lerp(FrameTime() * ANIMATION_SPEED, itemOffset, 0)
            
            local totalOffset = animationOffset + itemOffset
            
            local cardY = 90
            local cardMargin = 20
            local cardWidth = w - (cardMargin * 2)
            local cardHeight = ITEM_CARD_HEIGHT
            
            local baseX = cardMargin
            
            local currentX = baseX + math.max(-cardWidth/2, math.min(cardWidth/2, totalOffset))
            if items[currentItemIndex] then
                local alpha = math.max(200, 255 - math.abs(totalOffset) * 0.5)
                drawItem(currentX, cardY, cardWidth, cardHeight, items[currentItemIndex], alpha)
            end
            
            if currentItemIndex > 1 and totalOffset > 20 then
                local prevX = currentX - cardWidth - 10
                if prevX + cardWidth > 0 then
                    local alpha = math.max(0, math.min(150, totalOffset * 2))
                    drawItem(prevX, cardY, cardWidth, cardHeight, items[currentItemIndex - 1], alpha)
                end
            end
            
            if currentItemIndex < totalItems and totalOffset < -20 then
                local nextX = currentX + cardWidth + 10
                if nextX < w then
                    local alpha = math.max(0, math.min(150, -totalOffset * 2))
                    drawItem(nextX, cardY, cardWidth, cardHeight, items[currentItemIndex + 1], alpha)
                end
            end
            
            drawPageIndicators(0, h - 100, w)
            
            local line1 = DEX_LANG.Get("instructions1")
            local line2 = selectedItem and DEX_LANG.Get("instructions2") or DEX_LANG.Get("instructions3")

            local maxInstructionWidth = w - 20 
            local longerText = string.len(line1) > string.len(line2) and line1 or line2
            local _, _, chosenFont = drawAutoResizeText(
                longerText,
                "Dex_Descriptions",
                0, 0,
                COLOR_GRAY,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                maxInstructionWidth,
                "DermaDefault",
                true
            )

            draw.SimpleText(line1, chosenFont, w / 2, h - 50, COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(line2, chosenFont, w / 2, h - 30, COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        createFonts()
    end
end

function destroyScreen()
    if IsValid(panel) then
        panel:Remove()
        panel = nil
    end
    
    if IsValid(ghostModel) then
        ghostModel:Remove()
        ghostModel = nil
        ghostItem = nil
    end
end

hook.Add("PlayerSwitchWeapon", "CleanupScreen", function(ply, oldWep, newWep)
    if ply == LocalPlayer() and IsValid(oldWep) and oldWep:GetClass() == "dex_phone" then
        destroyScreen()
    end
end)

hook.Add("ShutDown", "CleanupScreenOnShutdown", function()
    destroyScreen()
end)

function SWEP:PostDrawViewModel(vm)
    if self.Owner ~= LocalPlayer() then return end

    local ang = vm:GetAngles()
    local realAng = Angle(ang)

    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), -90)

    local pos = vm:GetPos() +
        realAng:Up() * 3.16 + realAng:Right() * 2.9 + realAng:Forward() * 18.8

    local size = 0.0107

    createScreen()
    panel:SetVisible(true)
    panel:SetPaintedManually(true)
    cam.Start3D2D(pos, ang, size)
        panel:PaintManual()
    cam.End3D2D()
end

net.Receive("Dex_SpawnGhost", function()
    if IsValid(ghostModel) then
        ghostModel:Remove()
    end
    
    local modelPath = net.ReadString()
    ghostOffset = net.ReadInt(8)

    ghostModel = ClientsideModel(modelPath, RENDERGROUP_TRANSLUCENT)
    if IsValid(ghostModel) then
        ghostModel:SetNoDraw(true)
        ghostModel:SetMaterial("models/debug/debugwhite")
        
        if items[currentItemIndex] then
            ghostItem = table.Copy(items[currentItemIndex])
        end
        
        ghostPulseTime = RealTime()
    end
end)

net.Receive("Dex_BuySWEP_ClearGhost", function()
    selectedItem = nil
    if IsValid(ghostModel) then
        ghostModel:Remove()
        ghostModel = nil
        ghostItem = nil
    end
end)

net.Receive("Dex_BuySWEP_Notify", function()
    local notifyType = net.ReadUInt(8)
    local message = net.ReadString()

    local function Notify(color, msg)
        if DarkRP and DarkRP.notify then
            local drpType = notifyType == 0 and 0 or (notifyType == 1 and 1 or 2)
            DarkRP.notify(LocalPlayer(), drpType, 5, msg)
        elseif notification and notification.AddLegacy then
            local legacyType = notifyType == 0 and NOTIFY_GENERIC or (notifyType == 1 and NOTIFY_ERROR or NOTIFY_UNDO)
            notification.AddLegacy(msg, legacyType, 5)
            surface.PlaySound("buttons/button15.wav")
        else
            chat.AddText(COLOR_RED, "[Dex] ", color, msg)
        end
        if notifyType == 1 then
            surface.PlaySound("buttons/button10.wav")
        end
    end
    if notifyType == 0 then
        Notify(COLOR_GREEN, message)
    elseif notifyType == 1 then
        Notify(COLOR_RED, message)
    elseif notifyType == 2 then
        Notify(COLOR_ORANGE, message)
    end
end)

hook.Add("PostDrawTranslucentRenderables", "Dex_DrawGhost", function()
    if not IsValid(ghostModel) or not ghostItem then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "dex_phone" then return end

    local tr = ply:GetEyeTrace()
    if not tr.Hit then return end

    local ang = Angle(0, ply:EyeAngles().y + 90, 0)
    local pos = tr.HitPos + ply:EyeAngles():Right() * ghostOffset

    if ghostItem.isSWEP then
        pos = pos + Vector(0, 0, 20)
    end

    ghostModel:SetPos(pos)
    ghostModel:SetAngles(ang)
    
    local pulseAlpha = math.sin((RealTime() - ghostPulseTime) * 2) * 30 + 120
    local pulseScale = math.sin((RealTime() - ghostPulseTime) * 1.5) * 0.05 + 1
    
    local ghostColor = ghostItem.isSWEP and 
        Color(120, 255, 120, pulseAlpha) or
        Color(120, 180, 255, pulseAlpha)
    
    ghostModel:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ghostModel:SetColor(ghostColor)
    
    local matrix = Matrix()
    matrix:Scale(Vector(pulseScale, pulseScale, pulseScale))
    ghostModel:EnableMatrix("RenderMultiply", matrix)
    
    ghostModel:DrawModel()
    
    ghostModel:DisableMatrix("RenderMultiply")
    
    local screenPos = pos:ToScreen()
    if screenPos.visible then
        local textY = screenPos.y - 40
        
        draw.SimpleTextOutlined(
            ghostItem.name or DEX_LANG.Get("unknown"),
            "DermaDefaultBold",
            screenPos.x, textY,
            ghostColor,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            1, Color(0, 0, 0, 200)
        )
        
        local priceText = DarkRP and DarkRP.formatMoney(ghostItem.price or 0) or "$" .. (ghostItem.price or 0)
        draw.SimpleTextOutlined(
            priceText,
            "DermaDefault",
            screenPos.x, textY + 20,
            COLOR_WHITE,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            1, Color(0, 0, 0, 200)
        )
        
        draw.SimpleTextOutlined(
            DEX_LANG.Get("placer_instructions"),
            "DermaDefault",
            screenPos.x, textY + 35,
            COLOR_ORANGE,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            1, Color(0, 0, 0, 200)
        )
    end
end)