-- gscooters/lua/scooters/client/cl_gui.lua
-- Syntax hatası düzeltildi

local iScrW, iScrH = ScrW(), ScrH()

local mScooter = Material("gscooters/scooter.png", "noclamp smooth")
local iScooterW, iScooterH = mScooter:Width()/4, mScooter:Height()/4

local mLogo = Material("gscooters/logo_white.png", "noclamp smooth")
local iLogoW, iLogoH = mLogo:Width()/3, mLogo:Height()/3

local mWayPoint = Material("gscooters/waypoint.png", "noclamp smooth")

local mGradient = Material("gui/gradient_up")

local cMainColor = gScooters.Config.PrimaryColor
local cSecondaryColor = gScooters.Config.SecondaryColor
local cAccentColor = gScooters.Config.AccentColor
local cTextColor = gScooters.Config.TextColor

local cos, sin, rad = math.cos, math.sin, math.rad

local imgui = include("cl_imgui.lua")

-- Global değişkenler
local costTimer
local buttonUI
local bInScooter = false
local activeRentalFrame = nil

-- Jail kontrolü
local function IsPlayerJailed()
    local ply = LocalPlayer()
    
    -- DarkRP jail kontrolü
    if ply.DarkRPJailed or ply:getDarkRPVar("jailed") then
        return true
    end
    
    -- ULX jail kontrolü
    if ply:GetNWBool("ulx_jailed", false) then
        return true
    end
    
    -- SAM jail kontrolü  
    if ply:GetNWBool("sam_jailed", false) then
        return true
    end
    
    return false
end

-- Frame temizleme
local function CleanupRentalFrame()
    if IsValid(activeRentalFrame) then
        activeRentalFrame:Remove()
        activeRentalFrame = nil
        print("[gScooters CLIENT] Rental frame cleaned up")
    end
end

function gScooters:CostTimer()
    local iStartTime = CurTime()

    buttonUI = vgui.Create("DPanel")
    buttonUI:SetAlpha(0)
    buttonUI:SetSize(iScrW/3, 30*(#gScooters:GetPhrase("keybinds") + 1))
    buttonUI:Center()

    buttonUI.Alpha = 0

    buttonUI.Paint = function(self, w, h)
        self:SetAlpha(math.Round(self.Alpha))

        draw.RoundedBox(8, 0, 0, w, h, cSecondaryColor)
        draw.RoundedBox(8, 0, 0, w, 30, cMainColor)

        draw.SimpleText(gScooters:GetPhrase("keybind_text"), "gScooters.Font.MediumTextItalic", w/2, 5, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        for iIndex, tInfo in pairs(gScooters:GetPhrase("keybinds")) do
            draw.MultiColorText("gScooters.Font.Small", 10, (iIndex + 0.5)*30, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, cTextColor, gScooters:GetPhrase("button") .. "  ", cAccentColor, "(" .. tInfo[1] .. ")", cTextColor, "  " .. tInfo[2])

            draw.RoundedBox(8, 10, (iIndex+1)*30, w - 20, 2, cMainColor)
        end

        if input.IsKeyDown(gScooters.Config.RentalMenuKey) then
            self.Alpha = Lerp(0.3, self.Alpha, 255)
        else
            self.Alpha = Lerp(0.15, self.Alpha, 0)
        end
    end

    costTimer = vgui.Create("DPanel")
    costTimer:SetSize(iScrW/8, iScrH/10)
    costTimer:SetPos(iScrW/2 - costTimer:GetWide()/2, iScrH)
    costTimer:MoveTo(iScrW/2 - costTimer:GetWide()/2, iScrH - costTimer:GetTall() - 5, 1, 0, 0.2)

    local sFont = "gScooters.Font.Bold"
    local iMargin = 0
    local iBoxMarginH = 25

    costTimer.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h - iBoxMarginH, cMainColor, true, true, false, false)
        draw.RoundedBoxEx(6, 0, h - iBoxMarginH, w, iBoxMarginH, Color(cMainColor.r, cMainColor.g, cMainColor.b, 250), false, false, true, true)
        draw.RoundedBox(6, 0, h - iBoxMarginH, w, 4, cAccentColor)

        draw.SimpleText(gScooters:GetPhrase("renting_price"), "gScooters.Font.MediumTextItalic", w/2, 5, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        local sCurrentPrice = gScooters:FormatMoney(((CurTime() - iStartTime) / 60)*gScooters.Config.RentalRate, true)

        draw.SimpleText(sCurrentPrice, sFont, w/2, h/2, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText(string.format(gScooters:GetPhrase("dropdown_menu"), string.upper(input.GetKeyName(gScooters.Config.RentalMenuKey))), "gScooters.Font.SmallBoldItalic", w/2, h-5, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
end

net.Receive("gScooters.Net.OpenScooterUI", function()
    local eScooter = net.ReadEntity()

    -- Eğer zaten açık frame varsa kapat
    CleanupRentalFrame()

    -- Jail kontrolü
    if IsPlayerJailed() then
        print("[gScooters CLIENT] Player is jailed, not opening rental UI")
        gScooters:ChatMessage("Hapiste iken scooter kiralayamazsınız!")
        return
    end

    local frame = gScooters.Window(iScrW/4.5, iScrH/1.6, true)
    activeRentalFrame = frame
    
    frame:MakePopup()
    frame:SetPos(iScrW/2 - frame:GetWide()/2, iScrH)
    frame:MoveTo(iScrW/2 - frame:GetWide()/2, iScrH/2 - frame:GetTall()/2, 1, 0, 0.2)
    
    -- Frame kapatıldığında temizlik
    frame.OnRemove = function()
        activeRentalFrame = nil
    end
    
    local model = vgui.Create("DModelPanel", frame)
    model:Dock(TOP)
    model:DockMargin(5, 40, 5, 0)
    model:SetTall(frame:GetTall()/2)
    model:SetModel("models/dannio/gscooters.mdl")
    model:SetFOV(75)

    function model:LayoutEntity(Entity) return end

    local iDegree = 0
    local iRadius = 75

    model:SetLookAt(Vector(0,0,30))

    local modelCover = vgui.Create("DPanel", model)
    modelCover:Dock(FILL)

    modelCover.Paint = function()
        iDegree = rad(((-gui.MouseX() - iScrW/2)/400) + 25)
        model:SetCamPos(Vector(iRadius*cos(iDegree), iRadius*sin(iDegree), 60))
    end

    local info = vgui.Create("DPanel", frame)
    info:Dock(FILL)
    info:DockMargin(5, 10, 5, 0)

    info.Paint = function(self, w, h)
        draw.MultiColorText("gScooters.Font.MediumText", w/2, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, cTextColor, gScooters:GetPhrase("rental_rate_1") .. " ", cAccentColor, gScooters:FormatMoney(gScooters.Config.RentalRate), cTextColor, " " .. gScooters:GetPhrase("rental_rate_2"))

        draw.SimpleText(gScooters:GetPhrase("tap_below"), "gScooters.Font.Small", w/2, 20, gScooters.Config.ButtonColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local bCanAfford = gScooters:CanAfford(LocalPlayer(), gScooters.Config.RentalRate)

    local function GC_RentScooter()
        -- Jail kontrolü
        if IsPlayerJailed() then
            frame:Remove()
            gScooters:ChatMessage("Hapiste iken scooter kiralayamazsınız!")
            return
        end
        
        frame:MoveTo(iScrW/2 - frame:GetWide()/2, iScrH, 1)
        timer.Simple(2, function()
            net.Start("gScooters.Net.RentScooter")
            net.WriteEntity(eScooter)
            net.SendToServer()
            
            bInScooter = true

            if IsValid(frame) then
                frame:Remove()
            end

            if bCanAfford then
                timer.Simple(5, function() gScooters:CostTimer() end)
            else
                gScooters:ChatMessage(gScooters:GetPhrase("cannot_afford"))
            end
        end)
    end

    local rentButton = vgui.Create("DButton", frame)
    rentButton:SetText("")
    rentButton:Dock(BOTTOM)
    rentButton:DockMargin(5, 10, 5, 5)
    rentButton:SetTall(frame:GetTall()/4)

    local iRingSize = 0.5
    local iRadiusDifferent = 6.2

    rentButton.Lerp = 0
    local bCompleted = false

    rentButton.Paint = function(self, w, h)
        -- Jail kontrolü
        if IsPlayerJailed() then
            frame:Remove()
            return
        end
        
        draw.NoTexture()

        surface.SetDrawColor(gScooters.Config.PrimaryColor)
        draw.Circle(w/2, h/2, w/(iRadiusDifferent), 100)

        surface.SetDrawColor(gScooters.Config.AccentColor.r + 30, gScooters.Config.AccentColor.g + 30, gScooters.Config.AccentColor.b + 30)
        draw.Circle(w/2, h/2, w/(iRadiusDifferent), 100, self.Lerp)

        surface.SetDrawColor(gScooters.Config.SecondaryColor)
        draw.Circle(w/2, h/2, w/(iRadiusDifferent + iRingSize), 100)

        render.ClearStencil()
        render.SetStencilEnable(true)
      
        render.SetStencilWriteMask(1)
        render.SetStencilTestMask(1)
      
        render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
        render.SetStencilPassOperation(STENCILOPERATION_ZERO)
        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
        render.SetStencilReferenceValue(1)
      
        surface.SetDrawColor(color_white)

        if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
            draw.Circle(w/2, h/2, w/9, 100)

            if self.Lerp > 350 and bCompleted == false then
                self.Lerp = Lerp(0.2, self.Lerp, 365)
                bCompleted = true 
                timer.Simple(1.5, function() if IsValid(self) then GC_RentScooter() end end)
            else
                self.Lerp = Lerp(0.02, self.Lerp, 365)
            end
        else
            draw.Circle(w/2, h/2, w/8.5, 100)
            
            LocalPlayer():StopSound("gscooters/scooter_purchase.wav")

            self.Lerp = 0
        end
      
        render.SetStencilFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilReferenceValue(1)

        draw.RoundedBox(0, 0, 0, w, h, gScooters.Config.AccentColor)
        surface.SetDrawColor(gScooters.Config.AccentColor.r + 100, gScooters.Config.AccentColor.g + 100, gScooters.Config.AccentColor.b + 100)
        surface.SetMaterial(mGradient)
        surface.DrawTexturedRect(0, h/4, w, h)
        draw.SimpleText(gScooters:GetPhrase("go"), "gScooters.Font.Bold", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        render.SetStencilEnable(false)
        render.ClearStencil()
    end

    rentButton.OnDepressed = function()
        LocalPlayer():EmitSound("gscooters/scooter_purchase.wav")
    end

    rentButton.OnReleased = function(self)
        if not bCompleted then
            LocalPlayer():StopSound("gscooters/scooter_purchase.wav")
        end
    end

    rentButton.OnCursorEntered = function()
        surface.PlaySound("gscooters/rollover.wav")
    end
    
    -- Periyodik jail kontrolü
    frame.Think = function()
        if IsPlayerJailed() then
            frame:Remove()
            gScooters:ChatMessage("Hapiste iken scooter kiralayamazsınız!")
        end
    end
end)

-- Scooter entities
local tScooters = tScooters or {}
local tVans = tVans or {}

hook.Add("OnEntityCreated", "gScooters.Hook.ScooterCreated", function(eEnt)
    if IsValid(eEnt) and eEnt:IsVehicle() then
        if eEnt:GetVehicleClass() == gScooters.ScooterClass then
            table.insert(tScooters, eEnt)
        elseif eEnt:GetVehicleClass() == "merc_sprinter_swb_lw" then
            table.insert(tVans, eEnt)
        end
    end
end)

local iS = 256

local function GS_PushSpeedomoter(iSpeed)
    local mRT = GetRenderTarget("GS_Speedometer", iS, iS)
    local matScreen = Material("dannio/gscooters/blackm")
    matScreen:SetTexture("$basetexture", mRT)

    render.PushRenderTarget(mRT)
    cam.Start2D()
        surface.SetDrawColor(cMainColor)
        surface.DrawRect(0, 0, iS, iS)
        
        local mText = Matrix()
    
        mText:Translate(Vector(iS/2, iS/2))
        mText:Rotate(Angle(0, 0, 0))
        mText:Scale(Vector(1, 1, 1))
        mText:Translate(-Vector(iS/2, iS/2))
        
        cam.PushModelMatrix(mText)
            draw.RoundedBox(0, 0, 0, iS, iS, color_black)
            draw.SimpleText(tostring(iSpeed), "gScooters.Font.Speedo", iS/2, iS - 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        cam.PopModelMatrix()	
    cam.End2D()
    render.PopRenderTarget()
end

net.Receive("gScooters.Net.ResetScooterUI", function()
    print("[gScooters CLIENT] ResetScooterUI received!")
    
    -- Tüm UI elementlerini temizle
    if IsValid(costTimer) then 
        costTimer:Remove() 
        print("[gScooters CLIENT] CostTimer removed")
    end
    if IsValid(buttonUI) then 
        buttonUI:Remove() 
        print("[gScooters CLIENT] ButtonUI removed")
    end
    
    CleanupRentalFrame()
    
    costTimer = nil
    buttonUI = nil
    bInScooter = false
    
    GS_PushSpeedomoter(0)
    
    print("[gScooters CLIENT] UI reset completed")
end)

-- Job cooldown UI
local jobCooldownPanel
local cooldownStartTime = 0
local cooldownDuration = 0
local isOnCooldown = false

local function CleanupCooldownUI()
    if IsValid(jobCooldownPanel) then
        jobCooldownPanel:Remove()
        jobCooldownPanel = nil
        print("[gScooters CLIENT] Cooldown UI cleaned up")
    end
end

local function CreateJobCooldownUI()
    CleanupCooldownUI()
    
    if not isOnCooldown then
        return
    end

    jobCooldownPanel = vgui.Create("DPanel")
    jobCooldownPanel:SetSize(iScrW/6, iScrH/12)
    jobCooldownPanel:SetPos(iScrW - jobCooldownPanel:GetWide() - 20, iScrH/2 - jobCooldownPanel:GetTall()/2)
    jobCooldownPanel:SetAlpha(0)
    jobCooldownPanel:AlphaTo(255, 0.5)
    
    print("[gScooters CLIENT] New cooldown UI created")

    jobCooldownPanel.Paint = function(self, w, h)
        if not isOnCooldown then
            self:AlphaTo(0, 0.5)
            timer.Simple(0.5, function()
                if IsValid(self) then
                    self:Remove()
                end
            end)
            return
        end

        local currentTime = CurTime()
        local elapsed = currentTime - cooldownStartTime
        local remaining = math.max(0, cooldownDuration - elapsed)
        
        if remaining <= 0 then
            isOnCooldown = false
            self:AlphaTo(0, 0.5)
            timer.Simple(0.5, function()
                if IsValid(self) then
                    self:Remove()
                end
            end)
            return
        end

        draw.RoundedBox(8, 0, 0, w, h, cMainColor)
        draw.RoundedBox(8, 2, 2, w-4, h-4, cSecondaryColor)

        local progress = math.min(1, (cooldownDuration - remaining) / cooldownDuration)
        local barWidth = (w - 20) * progress
        
        draw.RoundedBox(4, 10, h - 15, w - 20, 8, Color(50, 50, 50))
        if barWidth > 0 then
            draw.RoundedBox(4, 10, h - 15, barWidth, 8, cAccentColor)
        end

        local title = "GÖREV HAZIRLANIYIR"
        if remaining <= 30 then
            title = "GÖREV NEREDEYSE HAZIR"
        elseif remaining <= 60 then
            title = "MERKEZ KONTROL YAPIYIR"
        end
        
        draw.SimpleText(title, "gScooters.Font.MediumText", w/2, 8, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        local minutes = math.floor(remaining / 60)
        local seconds = math.floor(remaining % 60)
        local timeText = string.format("%02d:%02d", minutes, seconds)
        
        draw.SimpleText(timeText, "gScooters.Font.Bold", w/2, h/2 - 5, cAccentColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local subText = "Merkez hazırlık yapıyor..."
        if remaining <= 10 then
            subText = "Çok yakında hazır!"
        elseif remaining <= 30 then
            subText = "Son kontroller yapılıyor..."
        end
        
        draw.SimpleText(subText, "gScooters.Font.Small", w/2, h - 25, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end

net.Receive("gScooters.Net.JobCooldownStart", function()
    cooldownDuration = net.ReadFloat()
    cooldownStartTime = CurTime()
    isOnCooldown = true
    
    print("[gScooters CLIENT] Cooldown started -", cooldownDuration, "seconds")
    
    timer.Simple(0.1, function()
        CreateJobCooldownUI()
    end)
    
    if cooldownDuration <= 60 then
        gScooters:ChatMessage("Merkez kontrol yapıyor, " .. math.Round(cooldownDuration) .. " saniye bekleyin...")
    else
        local minutes = math.floor(cooldownDuration / 60)
        gScooters:ChatMessage("Merkez size görev hazırlıyor, " .. minutes .. " dakika bekleyin...")
    end
end)

net.Receive("gScooters.Net.JobCooldownUpdate", function()
    local remaining = net.ReadFloat()
    
    print("[gScooters CLIENT] Cooldown update -", remaining, "seconds remaining")
    
    cooldownDuration = remaining
    cooldownStartTime = CurTime()
    
    if not IsValid(jobCooldownPanel) and isOnCooldown then
        CreateJobCooldownUI()
    end
end)

net.Receive("gScooters.Net.JobCooldownEnd", function()
    isOnCooldown = false
    
    print("[gScooters CLIENT] Cooldown ended")
    
    CleanupCooldownUI()
    
    surface.PlaySound("gscooters/notify.wav")
    gScooters:ChatMessage("🎯 GÖREV HAZIR! (J) tuşuna basarak kabul edin!")
    
    timer.Simple(1, function()
        local noticePanel = vgui.Create("DPanel")
        noticePanel:SetSize(iScrW/4, 60)
        noticePanel:SetPos(iScrW/2 - noticePanel:GetWide()/2, iScrH/4)
        noticePanel:SetAlpha(0)
        noticePanel:AlphaTo(255, 0.3)
        
        noticePanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 123, 253, 230))
            draw.RoundedBox(8, 2, 2, w-4, h-4, Color(36, 36, 36, 200))
            
            draw.SimpleText("GÖREV HAZIR!", "gScooters.Font.Bold", w/2, 15, Color(0, 255, 0), TEXT_ALIGN_CENTER)
            draw.SimpleText("(J) tuşuna basın", "gScooters.Font.MediumText", w/2, 35, color_white, TEXT_ALIGN_CENTER)
        end
        
        timer.Simple(3, function()
            if IsValid(noticePanel) then
                noticePanel:AlphaTo(0, 0.5)
                timer.Simple(0.5, function()
                    if IsValid(noticePanel) then
                        noticePanel:Remove()
                    end
                end)
            end
        end)
    end)
end)

-- Hook'lar
hook.Add("OnPlayerChangedTeam", "gScooters.Hook.ClientJailCleanup", function(ply, oldTeam, newTeam)
    if ply == LocalPlayer() then
        if newTeam == 1000 or newTeam == TEAM_JAIL then
            CleanupRentalFrame()
            
            if IsValid(costTimer) then
                costTimer:Remove()
                costTimer = nil
            end
            if IsValid(buttonUI) then
                buttonUI:Remove()
                buttonUI = nil
            end
        end
    end
end)

hook.Add("OnPlayerChangedTeam", "gScooters.Hook.CooldownCleanup", function(ply, oldTeam, newTeam)
    if ply == LocalPlayer() then
        isOnCooldown = false
        cooldownStartTime = 0
        cooldownDuration = 0
        
        CleanupCooldownUI()
    end
end)

hook.Add("PlayerLeaveVehicle", "gScooters.Hook.CooldownVehicleCleanup", function(ply, veh)
    if ply == LocalPlayer() and IsValid(veh) and veh:GetVehicleClass() == "merc_sprinter_swb_lw" then
        timer.Simple(1, function()
            local currentVeh = LocalPlayer():GetVehicle()
            if not IsValid(currentVeh) or currentVeh:GetVehicleClass() ~= "merc_sprinter_swb_lw" then
                isOnCooldown = false
                cooldownStartTime = 0
                cooldownDuration = 0
                
                CleanupCooldownUI()
            end
        end)
    end
end)

-- Pozisyon kontrolü
local lastPlayerPos = Vector(0, 0, 0)
hook.Add("Think", "gScooters.Hook.ClientJailTeleportCheck", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local currentPos = ply:GetPos()
    local distance = currentPos:Distance(lastPlayerPos)
    
    if distance > 2000 and IsValid(activeRentalFrame) then
        timer.Simple(0.5, function()
            if IsPlayerJailed() then
                CleanupRentalFrame()
                gScooters:ChatMessage("Hapiste iken scooter kiralayamazsınız!")
            end
        end)
    end
    
    lastPlayerPos = currentPos
end)

-- 3D2D UI
local iW = 620
local iH = 340
local sHeader = gScooters.Config.Van.Name

local sStatus = gScooters:GetPhrase("status_awaiting")
local cStatusColor = Color(71, 212, 130)

local tBackUI = {
	{x = 5, y = 44},
	{x = 21, y = 11},
	{x = 320, y = 4},
	{x = 619, y = 11},
    {x = 636, y = 35},
    {x = 663, y = 268},
    {x = 653, y = 304},
    {x = 469, y = 356},
    {x = 167, y = 356},
    {x = -8, y = 304},
    {x = -21, y = 268},
}

local cBackGround = Color(cMainColor.r, cMainColor.g, cMainColor.b, 250)
local iClick = 0

hook.Add("PostDrawTranslucentRenderables", "gScooters.Hook.DrawHoveringUI", function()
    for iIndex, eEnt in pairs(tScooters) do
        if not IsValid(eEnt) then
            tScooters[iIndex] = nil
            return
        end

        local vPos = eEnt:GetPos()

        if LocalPlayer():GetPos():DistToSqr(vPos) < 610000 then
            local aAng = eEnt:GetAngles()

            if not IsValid(eEnt:GetPassenger(0)) then
                cam.Start3D2D(vPos + aAng:Up()*85 + aAng:Forward()*-5, Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.1)
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(mScooter)
                    surface.DrawTexturedRect(0, 0, iScooterW, iScooterH)
                cam.End3D2D()

                if eEnt:GetNWInt("GC_ScooterAmount", 0) < gScooters.Config.ScooterPickupRequirement and LocalPlayer():Team() == TEAM_MARTI and imgui.Entity3D2D(eEnt, Vector(-5, 8, 8.75), Angle(0, 270, 90), 0.1) then
                    draw.RoundedBox(0, 0, 0, 200, 35, cBackGround)

                    if GC_JobRack and imgui.xTextButton(gScooters:GetPhrase("pickup_scooter"), "gScooters.Font.MediumText", 0, 0, 200, 35, 1, cTextColor, cAccentColor, cMainColor) and (CurTime() > iClick + 1) then
                        iClick = CurTime()

                        net.Start("gScooters.Net.PickupScooter")
                        net.SendToServer()
                    end

                    imgui.xCursor(0, 0, 200, 35)

                    imgui.End3D2D()
                end
            elseif eEnt:GetDriver() == LocalPlayer() then
                local velocity = eEnt:GetVelocity():Length()
                local speed = math.Round(velocity / 25, 0)
                
                GS_PushSpeedomoter(speed)
            end
        end
    end

    local eVan = LocalPlayer():GetVehicle()
    if IsValid(eVan) and eVan:GetVehicleClass() == "merc_sprinter_swb_lw" and LocalPlayer():Team() == TEAM_MARTI then
        local vPos = eVan:GetPos()
        local aAng = eVan:GetAngles()
        
        cam.Start3D2D(vPos + aAng:Up()*69.6 + aAng:Forward()*-14.75 + aAng:Right()*-80.1, eVan:GetAngles() + Angle(-1, -10, 90), 0.01, 200, 150)    
            draw.RoundedBox(0, 0, 0, iW, iH, cSecondaryColor)

            surface.SetDrawColor(cMainColor)
            surface.SetMaterial(mLogo)
            surface.DrawTexturedRect(iW/2 - iLogoW/2, iH/2 - iLogoH/2, iLogoW, iLogoH)

            draw.SimpleText(sHeader, "gScooters.Font.Main", iW/2, 5, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

            draw.SimpleText(os.date("%I:%M:%S"), "gScooters.Font.Main", iW/2, iH - 5, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        cam.End3D2D()

        cam.Start3D2D(vPos + aAng:Up()*61.8 + aAng:Forward()*-6.1 + aAng:Right()*-72.73, eVan:GetAngles() + Angle(0, 0, 80), 0.0191, 200, 150)    
            draw.RoundedBox(16, 0, 0, iW, iH, cSecondaryColor)

            draw.SimpleText(gScooters:GetPhrase("retrieval_unit"), "gScooters.Font.Main", iW/2, 5, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
            draw.MultiColorText("gScooters.Font.Main", iW/2, iH/2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, cTextColor, gScooters:GetPhrase("status"), cStatusColor, sStatus)

            draw.SimpleText(string.format(gScooters:GetPhrase("driver"), LocalPlayer():Nick()), "gScooters.Font.Main", iW/2, iH - 5, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        cam.End3D2D()
    end

    for iIndex, eVan in pairs(tVans) do
        if not IsValid(eVan) then
            tVans[iIndex] = nil
            return
        end

        local vPos = eVan:GetPos()

        if LocalPlayer():GetPos():DistToSqr(vPos) < 610000 then
            local aAng = eVan:GetAngles()

            cam.Start3D2D(vPos + aAng:Up()*89 + aAng:Forward()*-32 + aAng:Right()*111, eVan:GetAngles() + Angle(0, 0, 86), 0.1)
                surface.SetDrawColor(cBackGround)
                draw.NoTexture()
                surface.DrawPoly(tBackUI)

                draw.SimpleText(gScooters:GetPhrase("scooter_capacity"), "gScooters.Font.Logo", 321, 50, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(gScooters.Config.SecondaryColor)
                draw.Circle(321, 200, 100, 100)

                surface.SetDrawColor(gScooters.Config.AccentColor)
                draw.Circle(321, 200, 98, 100, 360*(eVan:GetNWInt("GC_ScooterAmount", 0)/gScooters.Config.ScooterPickupRequirement), 180)
                
                surface.SetDrawColor(gScooters.Config.PrimaryColor)
                draw.Circle(321, 200, 70, 100)

                for i = 0, 360, 360/gScooters.Config.ScooterPickupRequirement do
                    surface.DrawLine(321, 200, 321 + cos(rad(i - 90))*100, 200 + sin(rad(i - 90))*100)
                end

                draw.SimpleText(string.format("%i / %i", eVan:GetNWInt("GC_ScooterAmount", 0), gScooters.Config.ScooterPickupRequirement), "gScooters.Font.Logo", 321, 200, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end)

net.Receive("gScooters.Net.SendJob", function()
    surface.PlaySound("gscooters/pager.wav")

    gScooters:ChatMessage(string.format(gScooters:GetPhrase("job_notice"), string.upper(input.GetKeyName(gScooters.Config.JobAcceptKey))))

    local tData = {}
    
    local iNum = net.ReadUInt(22)
    for i = 1, iNum do
        table.insert(tData, net.ReadEntity())
    end

    hook.Add("PlayerButtonDown", "gScooters.Hook.JobAcceptKey", function(pPlayer, iKey)
        if IsFirstTimePredicted() and iKey == gScooters.Config.JobAcceptKey then
            sStatus = gScooters:GetPhrase("status_busy")
            cStatusColor = Color(219, 99, 99)

            GC_JobRack = tData

            surface.PlaySound("gscooters/beep.wav")

            hook.Remove("PlayerButtonDown", "gScooters.Hook.JobAcceptKey")
        end
    end)
end)

net.Receive("gScooters.Net.SendWaypoint", function()
    GC_JobRack = {net.ReadEntity()}
end)

local iLerp = 0

net.Receive("gScooters.Net.ResetJobs", function()
    sStatus = gScooters:GetPhrase("status_awaiting")
    cStatusColor = Color(71, 212, 130)

    GC_JobRack = nil

    iLerp = 0
end)

local iSize = 64

local sHeader = gScooters:GetPhrase("scooters")
local sFont = "gScooters.Font.Text"
surface.SetFont(sFont)
local iTextW, iTextH = surface.GetTextSize(sHeader)

hook.Add("HUDPaint", "gScooters.Hook.DrawCursor", function()
    local eVan = LocalPlayer():GetVehicle()
    if IsValid(eVan) and eVan:GetVehicleClass() == "merc_sprinter_swb_lw" and LocalPlayer():Team() == TEAM_MARTI and not eVan:GetThirdPersonMode() then
        draw.RoundedBox(0, iScrW/2 - 1, iScrH/2 - 1, 2, 2, color_white)
    end

    if GC_JobRack then
        for _, eEnt in pairs(GC_JobRack) do
            if IsValid(eEnt) and (eEnt:GetClass() == "prop_vehicle_jeep" and eEnt:GetVehicleClass() == gScooters.ScooterClass or eEnt:GetClass() == "gc_npc") then
                local vScooterPos = eEnt:GetPos() + Vector(0, 0, 90)

                local iDistance = math.Round(LocalPlayer():GetPos():Distance(vScooterPos)*0.01905)

                if iDistance > 5 then 
                    iLerp = Lerp(0.05, iLerp, 1)
                else
                    iLerp = Lerp(0.05, iLerp, 0)
                end

                local tPoint = vScooterPos:ToScreen()

                surface.SetAlphaMultiplier(iLerp)
                surface.SetDrawColor(cAccentColor)
                
                surface.SetMaterial(mWayPoint)
                surface.DrawTexturedRect(tPoint.x - (iSize/2), tPoint.y - 5 - (iSize/4), iSize, iSize)

                draw.SimpleText(iDistance .. "m", "gScooters.Font.MediumText", tPoint.x, tPoint.y + iTextH, cAccentColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                
                surface.SetAlphaMultiplier(1)
            end
        end
    end
end)

net.Receive("gScooters.Net.OpenRetrieverUI", function()
    local frame = gScooters.Window(iScrW/4.5, iScrH/2.5, true, gScooters:GetPhrase("retriever"))
    frame:MakePopup()
    frame:SetPos(iScrW/2 - frame:GetWide()/2, iScrH)
    frame:MoveTo(iScrW/2 - frame:GetWide()/2, iScrH/2 - frame:GetTall()/2, 1, 0, 0.2)

    local info = vgui.Create("DPanel", frame)
    info:Dock(TOP)
    info:DockMargin(0, 45, 0, 5)
    info:SetTall(frame:GetTall()/5)

    local sHeader = gScooters.Config.Van.Name
    local sHeaderFont = "gScooters.Font.Bold"
    local iTextW, iTextH = surface.GetTextSize(sHeader)
    local iHeaderW = iTextW + 40

    local sSubHeader = gScooters.Config.Van.Description

    info.Paint = function(self, w, h)
        draw.SimpleText(sHeader, sHeaderFont, w/2, h/3, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.RoundedBox(0, (w - iHeaderW)/2, (h/3) + iTextH/2 + 5, iHeaderW, 1, cTextColor)

        draw.SimpleText(sSubHeader, "gScooters.Font.Small", w/2, h*(2.4/3), cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local retrieveButton = gScooters.Button(frame, gScooters:GetPhrase("retrieve_vehicle"), 0, 0, 0, 0, cAccentColor)
    retrieveButton:Dock(BOTTOM)
    retrieveButton:DockMargin(0, 5, 0, 0)
    retrieveButton:SetTall(40)

    retrieveButton.DoClick = function(self, w, h)
        surface.PlaySound("gscooters/click.wav")

        frame:MoveTo(iScrW/2 - frame:GetWide()/2, iScrH, 1, 0, 0.2)
        timer.Simple(1, function()
            if IsValid(frame) then 
                frame:Remove() 

                net.Start("gScooters.Net.RetrieveEmployerCar")
                net.SendToServer()
            end 
        end)
    end

    local display = vgui.Create("DPanel", frame)
    display:Dock(FILL)

    local displayModel = vgui.Create("DModelPanel", display)
    displayModel:Dock(FILL)
    displayModel:DockMargin(2, 2, 2, 2)
    displayModel:SetModel(gScooters.Config.Van.Model)
    displayModel:SetColor(gScooters.Config.Van.Color)
    displayModel.Entity:SetSkin(gScooters.Config.Van.Skin)

    local mn, mx = displayModel.Entity:GetRenderBounds()

    local iDegree = 0
    local iRadius = 400

    display.Paint = function(self, w, h)
        iDegree = rad(((-gui.MouseX() - iScrW/2)/400) + 25)
        displayModel:SetCamPos(Vector(iRadius*cos(iDegree), iRadius*sin(iDegree), 60))
    end

    displayModel:SetFOV(50)
    displayModel:SetLookAt(Vector(0, 0, 50))
    displayModel:SetDirectionalLight(BOX_TOP, Color(200, 200, 200))
    displayModel:SetDirectionalLight(BOX_FRONT, Color(40, 40, 40))

    function displayModel:LayoutEntity(Entity) return end
end)

-- Debug komutları
if CLIENT then
    concommand.Add("gc_debug_client", function()
        print("[gScooters CLIENT] Debug Info:")
        print("- isOnCooldown:", isOnCooldown)
        print("- cooldownDuration:", cooldownDuration)
        print("- cooldownStartTime:", cooldownStartTime)
        print("- Current time:", CurTime())
        if cooldownStartTime > 0 then
            local remaining = cooldownDuration - (CurTime() - cooldownStartTime)
            print("- Calculated remaining:", remaining)
        end
        print("- jobCooldownPanel valid:", IsValid(jobCooldownPanel))
        print("- activeRentalFrame valid:", IsValid(activeRentalFrame))
        print("- IsPlayerJailed:", IsPlayerJailed())
    end)
    
    concommand.Add("gc_clear_cooldown_ui", function()
        print("[gScooters CLIENT] Clearing cooldown UI manually...")
        CleanupCooldownUI()
        CleanupRentalFrame()
        isOnCooldown = false
        cooldownStartTime = 0
        cooldownDuration = 0
        print("[gScooters CLIENT] UI cleared!")
    end)
    
    concommand.Add("gc_test_jail", function()
        print("[gScooters CLIENT] Jail status:", IsPlayerJailed())
        local ply = LocalPlayer()
        print("- DarkRP jailed:", ply.DarkRPJailed or ply:getDarkRPVar("jailed"))
        print("- ULX jailed:", ply:GetNWBool("ulx_jailed", false))
        print("- SAM jailed:", ply:GetNWBool("sam_jailed", false))
    end)
end