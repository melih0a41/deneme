include('shared.lua')

local DEX_PRIMARY_COLOR = Color(255, 70, 70, 255)
local DEX_SECONDARY_COLOR = Color(255, 120, 120, 200)
local DEX_BACKGROUND_COLOR = Color(20, 20, 20, 180)
local DEX_ACCENT_COLOR = Color(255, 255, 255, 220)
local DEX_SHADOW_COLOR = Color(0, 0, 0, 100)
local DEX_BORDER_COLOR = Color(255, 70, 70, 100)

local bgMaterial = Material("vgui/background.png", "noclamp smooth")

local hudAlpha = 0
local bloodCountAnim = 0
local selectorAnim = 0
local pulseAnim = 0
local lastSelected = 1
local lastStored = 0
-- ADICIONADO: Flag para controlar quando resetar a animação
local forceUpdateCount = false

local function Scale(size)
    return math.ceil(size * (ScrH() / 1080))
end

local function CreateDexFonts()
    surface.CreateFont("DexMainFont", {
        font = "Roboto",
        size = Scale(28),
        weight = 600,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("DexCounterFont", {
        font = "Roboto",
        size = Scale(24),
        weight = 500,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("DexSelectorFont", {
        font = "Roboto",
        size = Scale(20),
        weight = 400,
        antialias = true,
        extended = true
    })
    
    surface.CreateFont("DexIconFont", {
        font = "Marlett",
        size = Scale(32),
        weight = 400,
        antialias = true
    })
end

CreateDexFonts()

hook.Add("OnScreenSizeChanged", "DEX_RecreateFonts", CreateDexFonts)

local function DrawRoundedBox(x, y, w, h, radius, color)
    draw.RoundedBox(radius, x, y, w, h, color)
end

local function DrawMaterial(material, x, y, w, h, color)
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(x, y, w, h)
end

net.Receive("dex_no_blood", function()
    notification.AddLegacy(DEX_LANG.Get("no_blood"), NOTIFY_ERROR, 5)
    surface.PlaySound("buttons/button10.wav")
end)

net.Receive("dex_glass_update_names", function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not IsValid(wep) or wep:GetClass() ~= "dex_w_glass" then return end

    local newStored = net.ReadUInt(8)
    local newSelected = net.ReadUInt(8)
    local newName = net.ReadString()
    
    if GetConVar("developer"):GetInt() > 0 then
        print("DEX DEBUG: Received - Stored:", newStored, "Selected:", newSelected, "Name:", newName)
    end
    
    -- CORREÇÃO: Força atualização da animação quando os dados mudam
    if lastStored ~= newStored then
        forceUpdateCount = true
        if GetConVar("developer"):GetInt() > 0 then
            print("DEX DEBUG: Blood count changed from", lastStored, "to", newStored)
        end
    end
    
    wep.GlassData = {
        stored = newStored,
        selected = newSelected,
        currentName = newName,
    }
    
    lastSelected = newSelected
    lastStored = newStored
end)

function SWEP:DrawHUD()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "dex_w_glass" then return end

    local data = wep.GlassData or {}
    local name = data.currentName or DEX_LANG.Get("nobody")
    local count = data.stored or 0
    local selectedIndex = data.selected or 1
    
    -- CORREÇÃO: Verifica mudanças e força atualização quando necessário
    if count ~= lastStored or selectedIndex ~= lastSelected or forceUpdateCount then
        if GetConVar("developer"):GetInt() > 0 then
            print("DEX DEBUG: HUD Update - Count:", count, "Selected:", selectedIndex, "Force Update:", forceUpdateCount)
        end
        
        -- Se houve mudança forçada, reseta a animação para o valor correto
        if forceUpdateCount then
            bloodCountAnim = count
            forceUpdateCount = false
        end
        
        lastStored = count
        lastSelected = selectedIndex
    end
    
    local frameTime = FrameTime()
    local targetAlpha = (count > 0) and 255 or 100
    hudAlpha = Lerp(frameTime * 5, hudAlpha, targetAlpha)
    
    -- CORREÇÃO: Lerp mais rápido e com verificação de proximidade
    local lerpSpeed = 12 -- Aumentado de 8 para 12
    bloodCountAnim = Lerp(frameTime * lerpSpeed, bloodCountAnim, count)
    
    -- Se a diferença for muito pequena, força o valor exato
    if math.abs(bloodCountAnim - count) < 0.1 then
        bloodCountAnim = count
    end
    
    selectorAnim = Lerp(frameTime * 6, selectorAnim, selectedIndex)
    pulseAnim = math.sin(CurTime() * 3) * 0.3 + 0.7

    local baseX = Scale(60)
    local baseY = ScrH() * 0.4
    local panelWidth = Scale(280)
    local panelHeight = Scale(140)
    
    local bgAlpha = hudAlpha * 1
    local bgColor = Color(255, 255, 255, bgAlpha)
    DrawMaterial(bgMaterial, baseX - Scale(15), baseY - Scale(20), panelWidth, panelHeight, bgColor)
    
    local bgColor1 = Color(DEX_BACKGROUND_COLOR.r, DEX_BACKGROUND_COLOR.g, DEX_BACKGROUND_COLOR.b, hudAlpha * 0.4)
    local bgColor2 = Color(DEX_BACKGROUND_COLOR.r + 10, DEX_BACKGROUND_COLOR.g + 10, DEX_BACKGROUND_COLOR.b + 10, hudAlpha * 0.3)
    
    local borderColor = Color(DEX_BORDER_COLOR.r, DEX_BORDER_COLOR.g, DEX_BORDER_COLOR.b, hudAlpha * pulseAnim)
    
    DrawRoundedBox(baseX - Scale(15), baseY - Scale(20), panelWidth, panelHeight, Scale(6), bgColor1)
    
    local headerHeight = Scale(35)
    local headerColor = Color(DEX_PRIMARY_COLOR.r, DEX_PRIMARY_COLOR.g, DEX_PRIMARY_COLOR.b, hudAlpha * 0.3)
    DrawRoundedBox(baseX - Scale(15), baseY - Scale(20), panelWidth, headerHeight, Scale(1), headerColor)
        
    local nameColor = Color(DEX_ACCENT_COLOR.r, DEX_ACCENT_COLOR.g, DEX_ACCENT_COLOR.b, hudAlpha)
    local glowColor = Color(DEX_PRIMARY_COLOR.r, DEX_PRIMARY_COLOR.g, DEX_PRIMARY_COLOR.b, hudAlpha * 0.5)
    
    for i = 1, 3 do
        draw.SimpleText(
            name,
            "DexMainFont",
            baseX + Scale(20) + i, baseY - Scale(5) + i,
            glowColor,
            TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        )
        draw.SimpleText(
            name,
            "DexMainFont",
            baseX + Scale(20) - i, baseY - Scale(5) - i,
            glowColor,
            TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        )
    end
    
    draw.SimpleText(
        name,
        "DexMainFont",
        baseX + Scale(20), baseY - Scale(5),
        nameColor,
        TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
    )
    
    -- CORREÇÃO: Usa math.ceil para garantir que números decimais sejam arredondados para cima
    -- e mostra o valor real quando muito próximo
    local displayCount = (math.abs(bloodCountAnim - count) < 0.1) and count or math.ceil(bloodCountAnim)
    local bloodText = DEX_LANG.Get("blood") .. displayCount
    local bloodY = baseY + Scale(45)
    
    local counterBg = Color(DEX_SECONDARY_COLOR.r, DEX_SECONDARY_COLOR.g, DEX_SECONDARY_COLOR.b, hudAlpha * 0.2)
    DrawRoundedBox(baseX + Scale(15), bloodY - Scale(12), Scale(180), Scale(24), Scale(4), counterBg)
        
    local counterColor = Color(DEX_PRIMARY_COLOR.r, DEX_PRIMARY_COLOR.g, DEX_PRIMARY_COLOR.b, hudAlpha)
    draw.SimpleText(
        bloodText,
        "DexCounterFont",
        baseX + Scale(30), bloodY,
        counterColor,
        TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
    )
    
    if count > 1 then
        local selectorY = bloodY + Scale(35)
        local selectorText = string.format("[%d/%d]", selectedIndex, count)
        
        local selectorBg = Color(DEX_ACCENT_COLOR.r, DEX_ACCENT_COLOR.g, DEX_ACCENT_COLOR.b, hudAlpha * 0.1)
        DrawRoundedBox(baseX + Scale(15), selectorY - Scale(10), Scale(80), Scale(20), Scale(4), selectorBg)
        
        local dotSpacing = Scale(15)
        for i = 1, count do
            local dotX = baseX + Scale(110) + (i - 1) * dotSpacing
            local dotColor = (i == selectedIndex) and 
                Color(DEX_PRIMARY_COLOR.r, DEX_PRIMARY_COLOR.g, DEX_PRIMARY_COLOR.b, hudAlpha) or
                Color(100, 100, 100, hudAlpha * 0.5)
            
            surface.SetDrawColor(dotColor.r, dotColor.g, dotColor.b, dotColor.a)
            surface.DrawRect(dotX, selectorY - Scale(2), Scale(8), Scale(4))
        end
        
        local selectorColor = Color(DEX_ACCENT_COLOR.r, DEX_ACCENT_COLOR.g, DEX_ACCENT_COLOR.b, hudAlpha)
        draw.SimpleText(
            selectorText,
            "DexSelectorFont",
            baseX + Scale(30), selectorY,
            selectorColor,
            TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        )
    end
    
    if count > 1 then
        local instructText = DEX_LANG.Get("instructglass")
        local instructColor = Color(150, 150, 150, hudAlpha * 0.6)
        draw.SimpleText(
            instructText,
            "DexSelectorFont",
            baseX + Scale(20), baseY + Scale(105),
            instructColor,
            TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        )
    end
end