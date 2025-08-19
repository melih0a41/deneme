include("shared.lua")

local bgMaterial = Material("vgui/background.png", "noclamp smooth")

local DexBoxMovement = {}
DexBoxMovement.IsLocked = false

function DexBoxMovement.Lock()
    DexBoxMovement.IsLocked = true
end

function DexBoxMovement.Unlock()
    DexBoxMovement.IsLocked = false
end

function DexBoxMovement.IsPlayerLocked()
    return DexBoxMovement.IsLocked
end

hook.Add("CreateMove", "DexBox_BlockMovement", function(cmd)
    if not DexBoxMovement.IsLocked then return end
    
    cmd:SetMouseX(0)
    cmd:SetMouseY(0)
    
    cmd:SetForwardMove(0)
    cmd:SetSideMove(0)
    cmd:SetUpMove(0)
end)

hook.Add("InputMouseApply", "DexBox_BlockMouse", function(cmd, x, y, angle)
    if not DexBoxMovement.IsLocked then return end
    
    cmd:SetMouseX(0)
    cmd:SetMouseY(0)
    
    return true
end)

hook.Add("PlayerBindPress", "DexBox_BlockBinds", function(ply, bind, pressed)
    if not DexBoxMovement.IsLocked then return end
    if ply ~= LocalPlayer() then return end
    
    local allowedBinds = {
        "+use",       
        "+reload",    
        "+moveleft",   
        "+moveright", 
    }
    
    for _, allowedBind in ipairs(allowedBinds) do
        if string.find(bind, allowedBind) then
            return false 
        end
    end
    
    return true
end)

local InvestigationMod = InvestigationMod or {}
InvestigationMod.MoveView = nil

function InvestigationMod.SetView(vPosition, aAngle, bPreventAnimation, bShouldUseLastView, eLinkedEntity, fTransitionTime)
    LocalPlayer():DrawViewModel(false)
    
    DexBoxMovement.Lock()
    
    LocalPlayer().IsFocused = true
    
    local oldView = InvestigationMod.MoveView or {
        position = LocalPlayer():EyePos(),
        angle = LocalPlayer():EyeAngles()
    }
    
    if InvestigationMod.PlayAmbiantSound then
        InvestigationMod.PlayAmbiantSound()
    end
    
    InvestigationMod.MoveView = {
        startTime = CurTime(),
        position = vPosition,
        angle = aAngle,
        shouldAnimate = not bPreventAnimation,
        shouldLastView = bShouldUseLastView and oldView,
        linkedEntity = eLinkedEntity,
        transitionTime = fTransitionTime or 2.0,
        startPosition = oldView.position,
        startAngle = oldView.angle
    }
    
    hook.Run("InvestigationMod:OnViewChanged")
end

function InvestigationMod.ClearView()
    InvestigationMod.MoveView = nil
    LocalPlayer():DrawViewModel(true)
    LocalPlayer().IsFocused = false
    
    DexBoxMovement.Unlock()
end

hook.Add("CalcView", "InvestigationMod_CameraView", function(ply, pos, angles, fov)
    if not InvestigationMod.MoveView then return end
    
    local view = InvestigationMod.MoveView
    local targetPos = view.position
    local targetAngle = view.angle
    
    if view.shouldAnimate then
        local animTime = math.min((CurTime() - view.startTime) / view.transitionTime, 1)
        local ease = math.sin(animTime * math.pi * 0.5)
        
        targetPos = LerpVector(ease, view.startPosition, view.position)
        targetAngle = LerpAngle(ease, view.startAngle, view.angle)
    end
    
    return {
        origin = targetPos,
        angles = targetAngle,
        fov = fov,
        drawviewer = true
    }
end)

local currentBox = nil
local currentGlassList = {}
local selectedIndex = 1
local isViewingBox = false
local cameraTransitionComplete = false
local cameraStartTime = 0

local glowObjects = {}

local color_main_bg = Color(20, 20, 25, 200)
local color_text_white = Color(255, 255, 255, 255)
local color_text_selected = Color(200, 60, 60, 255)
local color_shadow = Color(0, 0, 0, 150)
local color_glow = Color(255, 60, 60)
local COLOR_GREEN = Color(120, 255, 120)
local COLOR_RED = Color(255, 120, 120)
local COLOR_ORANGE = Color(200, 60, 60)
local color_glow_background = Color(200, 60, 60, 100)
local color_glow_outline = Color(255, 60, 60)
local color_glow_halo_secondary = Color(255, 255, 255, 200)

local function Scale(size)
    return math.ceil(size * (ScrH() / 1080))
end

local function CreateFonts()
    surface.CreateFont("dex_box_hud_title", {
        font = "Roboto",
        size = Scale(24),
        weight = 800,
        antialias = true,
        shadow = true
    })

    surface.CreateFont("dex_box_hud_item", {
        font = "Roboto",
        size = Scale(18),
        weight = 600,
        antialias = true,
        shadow = true
    })

    surface.CreateFont("dex_box_hud_controls", {
        font = "Roboto",
        size = Scale(16),
        weight = 500,
        antialias = true,
        shadow = true
    })
end

CreateFonts()

hook.Add("OnScreenSizeChanged", "dex_box_font_refresh", function()
    CreateFonts()
end)

local function DrawTextShadow(text, font, x, y, color, xAlign, yAlign, shadowOffset)
    shadowOffset = shadowOffset or 2
    
    draw.SimpleText(text, font, x + shadowOffset, y + shadowOffset, color_shadow, xAlign, yAlign)
    draw.SimpleText(text, font, x, y, color, xAlign, yAlign)
end

local function DrawGlassSelectionHUD()
    if not isViewingBox or not IsValid(currentBox) or not cameraTransitionComplete then return end
    if #currentGlassList == 0 then return end

    local scrW, scrH = ScrW(), ScrH()
    local panelW, panelH = Scale(400), Scale(300)
    local x, y = scrW - panelW - Scale(30), Scale(30)

    surface.SetDrawColor(color_text_white.r, color_text_white.g, color_text_white.b, color_text_white.a)
    surface.SetMaterial(bgMaterial)
    surface.DrawTexturedRect(x, y, panelW, panelH)
    
    surface.SetDrawColor(color_text_selected.r, color_text_selected.g, color_text_selected.b, color_text_selected.a)
    surface.DrawOutlinedRect(x, y, panelW, panelH, Scale(2))

    DrawTextShadow(DEX_LANG.Get("box_print_name"), "dex_box_hud_title", x + panelW/2, y + Scale(25), color_text_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local startY = y + Scale(60)
    local itemHeight = Scale(25)
    local maxVisibleItems = 7
    local startIndex = math.max(1, selectedIndex - math.floor(maxVisibleItems/2))
    local endIndex = math.min(#currentGlassList, startIndex + maxVisibleItems - 1)

    for i = startIndex, endIndex do
        local itemY = startY + (i - startIndex) * itemHeight
        local isSelected = (i == selectedIndex)
        
        if isSelected then
            local pulse = math.sin(CurTime() * 3) * 0.2 + 0.8
            local glowColor = Color(color_glow_background.r, color_glow_background.g, color_glow_background.b, color_glow_background.a * pulse)
            draw.RoundedBox(Scale(4), x + Scale(10), itemY - Scale(2), panelW - Scale(20), itemHeight, glowColor)
            
            surface.SetDrawColor(color_glow.r, color_glow.g, color_glow.b, 150 * pulse)
            surface.DrawOutlinedRect(x + Scale(10), itemY - Scale(2), panelW - Scale(20), itemHeight, Scale(1))
        end

        local textColor = isSelected and color_text_selected or color_text_white
        DrawTextShadow(string.format("%d. %s", i, currentGlassList[i]), "dex_box_hud_item", x + Scale(20), itemY + itemHeight/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local controlsY = y + panelH - Scale(80)
    DrawTextShadow(DEX_LANG.Get("box_controls"), "dex_box_hud_controls", x + Scale(20), controlsY, color_text_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    DrawTextShadow(DEX_LANG.Get("box_navigate"), "dex_box_hud_controls", x + Scale(20), controlsY + Scale(20), color_text_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    DrawTextShadow(DEX_LANG.Get("box_drop"), "dex_box_hud_controls", x + Scale(20), controlsY + Scale(35), color_text_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    DrawTextShadow(DEX_LANG.Get("box_exit"), "dex_box_hud_controls", x + Scale(20), controlsY + Scale(50), color_text_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    if #currentGlassList > 0 then
        local counterText = string.format("%d/%d", selectedIndex, #currentGlassList)
        DrawTextShadow(counterText, "dex_box_hud_item", x + panelW - Scale(20), y + Scale(25), color_text_selected, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

local function CheckCameraTransition()
    if not isViewingBox or not InvestigationMod.MoveView then return end
    
    local view = InvestigationMod.MoveView
    if not view.shouldAnimate then 
        cameraTransitionComplete = true
        return 
    end
    
    local animTime = (CurTime() - view.startTime) / view.transitionTime
    if animTime >= 1.0 and not cameraTransitionComplete then
        cameraTransitionComplete = true
        
        net.Start("dex_box_camera_transition_complete")
            net.WriteEntity(currentBox)
        net.SendToServer()
        
        surface.PlaySound("ui/buttonclick.wav")
    end
end

hook.Add("PreDrawHalos", "dex_box_glass_glow", function()
    if not isViewingBox or not IsValid(currentBox) or not cameraTransitionComplete then 
        glowObjects = {}
        return 
    end
    
    glowObjects = {}
    
    local nearbyEnts = ents.FindInSphere(currentBox:GetPos(), 50)
    local glassVisuals = {}
    
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "prop_dynamic" and 
           ent:GetModel() == "models/blood/glass.mdl" and 
           ent:GetParent() == currentBox then
            table.insert(glassVisuals, ent)
        end
    end
    
    table.sort(glassVisuals, function(a, b)
        local posA = currentBox:WorldToLocal(a:GetPos())
        local posB = currentBox:WorldToLocal(b:GetPos())
        return posA.x < posB.x
    end)
    
    if glassVisuals[selectedIndex] and IsValid(glassVisuals[selectedIndex]) then
        table.insert(glowObjects, glassVisuals[selectedIndex])
    end
        
    if #glowObjects == 0 then return end
    
    local pulse = (math.sin(CurTime() * 1.5) + 1) * 0.5
    pulse = math.pow(pulse, 0.5)
    local r = color_glow.r * (0.3 + pulse * 0.7)
    local g = color_glow.g * (0.3 + pulse * 0.7) 
    local b = color_glow.b * (0.3 + pulse * 0.7)
    
    halo.Add(glowObjects, Color(r, g, b, 255), 3, 3, 15, true, true)
    halo.Add(glowObjects, Color(r * 0.7, g * 0.7, b * 0.7, 200), 5, 5, 8, true, true)
end)

hook.Add("RenderScreenspaceEffects", "dex_box_glow_effect", function()
    if not isViewingBox or not glowObjects or #glowObjects == 0 or not cameraTransitionComplete then return end
    
    DrawBloom(
        0.8,
        1.2,
        2, 2,
        2,
        1,
        1, 0.3, 0.3
    )
end)

hook.Add("HUDPaint", "dex_box_camera_hud", function()
    DrawGlassSelectionHUD()
end)

hook.Add("Think", "dex_box_camera_transition", function()
    CheckCameraTransition()
end)

hook.Add("KeyPress", "dex_box_camera_controls", function(ply, key)
    if not isViewingBox or not IsValid(currentBox) or not cameraTransitionComplete then return end
    if ply ~= LocalPlayer() then return end

    if key == IN_MOVELEFT then
        net.Start("dex_box_select_glass")
            net.WriteEntity(currentBox)
            net.WriteInt(-1, 8)
        net.SendToServer()
        surface.PlaySound("ui/buttonrollover.wav")
        
    elseif key == IN_MOVERIGHT then
        net.Start("dex_box_select_glass")
            net.WriteEntity(currentBox)
            net.WriteInt(1, 8)
        net.SendToServer()
        surface.PlaySound("ui/buttonrollover.wav")
        
    elseif key == IN_RELOAD then
        net.Start("dex_box_close")
            net.WriteEntity(currentBox)
        net.SendToServer()
        surface.PlaySound("ui/buttonclick.wav")
    end
end)

hook.Add("KeyRelease", "dex_box_camera_use", function(ply, key)
    if not isViewingBox or not IsValid(currentBox) or not cameraTransitionComplete then return end
    if ply ~= LocalPlayer() then return end
    if key ~= IN_USE then return end
    
    net.Start("dex_box_drop")
        net.WriteEntity(currentBox)
    net.SendToServer()
    surface.PlaySound("ui/buttonclickrelease.wav")
end)

net.Receive("dex_box_camera_start", function()
    local box = net.ReadEntity()
    local glassCount = net.ReadUInt(8)
    local glasses = {}
    
    for i = 1, glassCount do
        table.insert(glasses, net.ReadString())
    end
    
    selectedIndex = net.ReadUInt(8)
    
    if not IsValid(box) then return end
    
    currentBox = box
    currentGlassList = glasses
    isViewingBox = true
    cameraTransitionComplete = false
    cameraStartTime = CurTime()
    
    local cameraPos = box:LocalToWorld(Vector(10, 10, 10))
    local cameraAngle = box:LocalToWorldAngles(Angle(20, 225, 0))
    
    InvestigationMod.SetView(cameraPos, cameraAngle, false, true, box, 2.5)
    
    surface.PlaySound("ui/buttonclick.wav")
end)

net.Receive("dex_box_camera_end", function()
    local box = net.ReadEntity()
    
    isViewingBox = false
    currentBox = nil
    currentGlassList = {}
    selectedIndex = 1
    glowObjects = {}
    cameraStartTime = 0
    cameraTransitionComplete = false
    
    InvestigationMod.ClearView()
    
    surface.PlaySound("ui/buttonclickrelease.wav")
end)

net.Receive("dex_box_select_glass", function()
    local box = net.ReadEntity()
    selectedIndex = net.ReadUInt(8)
    local glassName = net.ReadString()
    
    if not cameraTransitionComplete then return end
        
    surface.PlaySound("ui/buttonrollover.wav")
end)

net.Receive("dex_box_notify", function()
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
    end
    if notifyType == 0 then
        Notify(COLOR_GREEN, message)
    elseif notifyType == 1 then
        Notify(COLOR_RED, message)
    elseif notifyType == 2 then
        Notify(COLOR_ORANGE, message)
    end
end)

function ENT:Draw()
    self:DrawModel()
end

hook.Add("Think", "dex_box_visual_update", function()
    if not isViewingBox or not IsValid(currentBox) then return end
    
    for i, visual in ipairs(currentBox.VisualGlass or {}) do
        if IsValid(visual) then
            if not visual.BaseOffset then
                visual.BaseOffset = Vector(-4.6 + (i-1) * 0.2, 0.5, 0.5)
            end
            if not visual.LiftHeight then
                visual.LiftHeight = 2
            end
            if not visual.GlassIndex then
                visual.GlassIndex = i
            end
        end
    end
end)