--[[

MCD DERMA
Credits as parts of the base was done by matlib and their developers. Check it out: https://github.com/LivacoNew/MatLib

]]--

local cMainColor = gScooters.Config.PrimaryColor
local cSecondaryColor = gScooters.Config.SecondaryColor
local cAccentColor = gScooters.Config.AccentColor
local cTextColor = gScooters.Config.TextColor

local iScrW, iScrH = ScrW(), ScrH()

local iHeaderHeight = 30

local mGradientDown = Material("gui/gradient_down")
local mGradientUp = Material("gui/gradient_up")

function gScooters.Frame(x, y, w, h, sTitle, bNotice) 
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame:MakePopup()

    frame.iHeaderHeight = iHeaderHeight
    local iStartTime = SysTime()

    if x == -1 and y == -1 then
        frame:Center()
    else
        frame:SetPos(x, y)
    end
    
    frame.Paint = function(self, w, h)
        if bNotice then
            Derma_DrawBackgroundBlur(frame, iStartTime)
        end
        draw.RoundedBox(8, 0, 1, w, h - 1, cMainColor)

        surface.SetDrawColor(color_black)
        surface.SetMaterial(mGradientDown)
        surface.DrawTexturedRect(0, self.iHeaderHeight * 0.9, w, self.iHeaderHeight * 0.25)

        draw.RoundedBox(8, 0, 0, w, self.iHeaderHeight, cSecondaryColor)
        draw.RoundedBox(0, 0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2, cSecondaryColor)

        if gScooters.Config.Light then
            surface.SetDrawColor(cSecondaryColor.r + 25, cSecondaryColor.g + 25, cSecondaryColor.b + 25)
            surface.SetMaterial(mGradientUp)
            surface.DrawTexturedRect(0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2)
        end

        draw.SimpleText(sTitle, "gScooters.Font.MediumText", 10, self.iHeaderHeight / 2, cTextColor, 0, 1)
    end

    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetPos(frame:GetWide() - frame.iHeaderHeight*2 + 10, 3)
    closeButton:SetSize(frame.iHeaderHeight*2, frame.iHeaderHeight + 6)
    closeButton:SetText("")

    closeButton.Paint = function(s, w, h)
        draw.NoTexture()

        surface.SetDrawColor(cTextColor)
        surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 135)
        surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 45)
    end

    closeButton.DoClick = function()
        surface.PlaySound("gscooters/click.wav")

        frame:Remove()
    end

    closeButton.OnCursorEntered = function()
        surface.PlaySound("gscooters/rollover.wav")
    end

    return frame
end

local mLogo = Material("gscooters/logo.png", "noclamp smooth")
local iLogoW, iLogoH = mLogo:Width()/9, mLogo:Height()/9

function gScooters.Window(w, h, bCloseButton, sHeaderOverride)
    local iHeaderHeight = iScrH/15

    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:CenterHorizontal()
    frame:SetTitle("")

    local cContrast = Color(gScooters.Config.PrimaryColor.r + 1, gScooters.Config.PrimaryColor.g + 1, gScooters.Config.PrimaryColor.b + 1)

    local sHeader = string.upper(gScooters:GetPhrase("scooters"))
    local sHeaderFont = "gScooters.Font.Logo"
    surface.SetFont(sHeaderFont)
    local sHeaderW = surface.GetTextSize(sHeader)
    local iDiff = (frame:GetWide() - (sHeaderW + iLogoW + 5))/2

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, gScooters.Config.SecondaryColor)

        draw.RoundedBox(0, 0, iHeaderHeight - 2, w, 2, cContrast)
        draw.RoundedBox(0, 0, iHeaderHeight, w, 5, gScooters.Config.PrimaryColor)
        draw.RoundedBox(0, 0, iHeaderHeight + 5, w, 2, cContrast)

        if sHeaderOverride then
            draw.SimpleText(sHeaderOverride, sHeaderFont, w/2, iHeaderHeight/2 - 1, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)    
        else
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mLogo)
            surface.DrawTexturedRect(iDiff, (iHeaderHeight - iLogoH) / 2, iLogoW, iLogoH)
    
            draw.SimpleText(sHeader, sHeaderFont, iLogoW + 5 + iDiff, iHeaderHeight/2 - 1, cTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)    
        end
    end
    
    if bCloseButton then
        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetText("")
        closeButton:SetSize(15, 15)
        closeButton:SetPos(frame:GetWide() - closeButton:GetWide() - 20, iHeaderHeight/2 - closeButton:GetTall() / 2)
        closeButton.Lerp = 0

        closeButton.Paint = function(self, w, h)
            draw.NoTexture()
            
            if self:IsHovered() then
                self.Lerp = Lerp(0.05, self.Lerp, 50)
            else
                self.Lerp = Lerp(0.1, self.Lerp, 0)
            end
            
            surface.SetDrawColor(cContrast.r + self.Lerp, cContrast.g, cContrast.b)

            draw.Circle(w/2, h/2, w/2, 20)
        end

        closeButton.DoClick = function()
            surface.PlaySound("gscooters/click.wav")

            frame:Close()
        end

        closeButton.OnCursorEntered = function()
            surface.PlaySound("gscooters/rollover.wav")
        end
    end
    return frame
end


function gScooters.Button(frame, text, x, y, w, h, cColor)
    local button = vgui.Create("DButton", frame)
    button:SetPos(x, y)
    button:SetSize(w, h)
    button:SetText("")
    button.Lerp = 0

    button.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, cColor or cSecondaryColor)
   
        if self:IsHovered() then
            self.Lerp = Lerp(0.2, self.Lerp, 100)
        else
            self.Lerp = Lerp(0.1, self.Lerp, 0)
        end
        
        draw.RoundedBox(8, 0, 0, w, h, Color(79, 79, 79, self.Lerp))
   
        draw.SimpleText(text, "gScooters.Font.Text", w / 2, h / 2, cTextColor, 1, 1)
    end

    button.OnCursorEntered = function()
        surface.PlaySound("gscooters/rollover.wav")
    end

    return button
end

function gScooters.CheckBox(frame, x, y, w, h, defaultValue)
    local box = vgui.Create("DCheckBox", frame)
    box:SetPos(x, y)
    box:SetSize(w, h)
    box:SetChecked(defaultValue)
    box.Lerp = 0

    box.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, cSecondaryColor)

        if self:GetChecked() then
            box.Lerp = Lerp(0.2, box.Lerp, 255)
        else
            box.Lerp = Lerp(0.2, box.Lerp, 0)
        end

        draw.SimpleText("✓", "gScooters.Font.MediumText", w / 2, h / 2, Color(255, 255, 255, box.Lerp), 1, 1)
    end
    return box
end

function gScooters.ComboBox(frame, x, y, w, h, defaultValue, fields)
    local box = vgui.Create("DComboBox", frame)

    box:SetPos(x, y)
    box:SetSize(w, h)
    box:SetTextColor(color_black)
    box:SetSortItems(false)
    box:SetFont("gScooters.Font.Text")

    for _, sName in ipairs(fields) do
        local option = box:AddChoice(sName)
    end

    box:SetValue(defaultValue)

    box.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(cTextColor.r, cTextColor.g, cTextColor.b, 250))
    end

    return box
end

function gScooters.TextEntry(frame, defaultValue, button)
    local cEntryColor = Color(cTextColor.r, cTextColor.g, cTextColor.b, 250)

    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:SetValue(defaultValue)
    textEntry:SetFont("gScooters.Font.Text")
    textEntry:SetCursorColor(color_black)
    textEntry:SetPaintBackground(false)
    textEntry.OldPaint = textEntry.Paint

    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, cEntryColor)
        self:OldPaint(w, h)
    end

    textEntry.OnKeyCode = function(self, iKey)
        if button and iKey == KEY_ENTER then
            button:DoClick()
        end
    end

    return textEntry
end

function gScooters.Scroll(frame, x, y, w, h)
    local scroll = vgui.Create("DScrollPanel", frame)
    
    scroll:SetPos(x, y)
    scroll:SetSize(w, h)

    scroll.Paint = function() end

    local sBar = scroll:GetVBar()
    local iSize = 8
    local cScrollColor = cMainColor

    function sBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_transparent)
    end

    function sBar.btnUp:Paint(w, h)
        draw.RoundedBox(8, (w - iSize)/2, 0, iSize, iSize, cScrollColor)
    end

    function sBar.btnDown:Paint(w, h)
        draw.RoundedBox(8, (w - iSize)/2, 0, iSize, iSize, cScrollColor)
    end

    function sBar.btnGrip:Paint(w, h)
        draw.RoundedBox(8, (w - iSize)/2, 0, iSize, h, cScrollColor)
    end

    return scroll
end

function gScooters.HeaderText(frame, x, y, text)
    local label = vgui.Create("DLabel", frame)
    label:SetPos(x, y)
    label:SetText(text)
    label:SetFont("gScooters.Font.Small")
    label:SetContentAlignment(7)
    label:SizeToContents()
    label:SetColor(cTextColor)
    return label
end

function gScooters.Notice(title, text)
    surface.PlaySound("gscooters/notify.wav")

    local frame = gScooters.Frame(-1, -1, ScrW() * 0.3, ScrH() * 0.075, title, true)
    frame:Center()
    frame:CenterVertical(0.4)

    gScooters.HeaderText(frame, 10, iHeaderHeight + 8, text)
end

function gScooters.Query(text, title, button1text, button1func, button2text, button2func)
    
    local frame = gScooters.Frame(-1, -1, ScrW() * 0.3, ScrH() * 0.125, title, true)
    frame:Center()
    frame:CenterVertical(0.4)

    gScooters.HeaderText(frame, 10, iHeaderHeight + 8, text)

    local iInBetween = (frame:GetWide() - ((iScrW/10) * 2))/3

    local buttonFrame = vgui.Create("DPanel", frame)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iHeaderHeight)
    buttonFrame.Paint = function() end


    local button1 = gScooters.Button(buttonFrame, button1text, 0, 0, 0, 0)
    button1:SetSize(iScrW/10, buttonFrame:GetTall())
    button1:SetPos(iInBetween, 0)
    button1.DoClick = function()
        frame:Remove()
        
        if not button1func then return end
        button1func()
    end

    local button2 = gScooters.Button(buttonFrame, button2text, 0, 0, 0, 0)
    button2:SetSize(iScrW/10, buttonFrame:GetTall())
    button2:SetPos(iScrW/10 + iInBetween*2, 0)
    button2.DoClick = function()
        frame:Remove()

        if not button2func then return end
        button2func()
    end
end

function gScooters.StringRequest(title, text, defaulttext, func)
    local frame = gScooters.Frame(-1, -1, ScrW() * 0.3, ScrH() * 0.175, title, true)
    frame:Center()
    frame:CenterVertical(0.4)

    local iRoundMargins = 5

    gScooters.HeaderText(frame, 10, iHeaderHeight + 8, text)

    local buttonFrame = vgui.Create("DPanel", frame)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iHeaderHeight)
    buttonFrame.Paint = function() end

    local textEntry

    local button1 = gScooters.Button(buttonFrame, "Submit", 0, 0, 0, 0)
    button1:SetSize(iScrW/10, buttonFrame:GetTall())
    button1:SetPos(frame:GetWide()/2 - button1:GetWide()/2, 0)
    button1.DoClick = function()
        frame:Remove()
        
        if not func then return end
        func(textEntry:GetValue())
    end

    textEntry = gScooters.TextEntry(frame, defaulttext, button1)
    textEntry:SetPos(iRoundMargins, iRoundMargins + iHeaderHeight + ScrH() * 0.04)
    textEntry:SetSize(frame:GetWide() - (iRoundMargins*2), 40 - (iRoundMargins*2))
end

function draw.Circle(x, y, radius, seg, degree, offset) -- CREDITS: https://wiki.facepunch.com/gmod/surface.DrawPoly
    local cir = {}

    table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
    
    for i = 0, seg do
        local a = math.rad(((i / seg) * (degree or 360) * -1) + (offset or 0))
        table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
    end

    --local a = math.rad(0)
    --table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
    
    surface.DrawPoly(cir)
end

-- https://github.com/Defaultik/DefaultUILibary/blob/main/LICENSE

function gScooters.Slider(frame, sHeader) -- https://github.com/Defaultik/DefaultUILibary/blob/main/dlib/lua/autorun/client/cl_dlib.lua
    local slider = vgui.Create("DNumSlider", frame)
    slider:SetDecimals(0)
    
    slider.TextArea.Paint = function(self, w, h)
        draw.SimpleText(math.Round(slider:GetValue()), "gScooters.Font.Small", w/2, h*(8.5/10) - 1, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    slider.Slider.Paint = function(self, w, h)
        draw.SimpleText(sHeader, "gScooters.Font.Small", w/2 + slider.TextArea:GetWide()/2, 0, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        draw.RoundedBox(8, 0, h*(7/10), w, h*(3/10), Color(255, 255, 255, 100))
        draw.RoundedBox(8, 0, h*(7/10), w * ((self:GetParent():GetValue() - self:GetParent():GetMin()) / self:GetParent():GetRange()), h*(3/10), cAccentColor)
    end

    slider.Label:SetWide(0)
    slider.PerformLayout = function() end
    slider.Slider.Knob.Paint = function()end

    return slider
end

--[[
MIT License
Copyright (c) 2020 EmperorSuper
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

function draw.MultiColorText(Font, x, y, xAlign, yAlign, ...) -- https://github.com/EmperorSuper/MultiColorText/blob/master/multicolortext.lua
	surface.SetFont(Font)
	local CurX = x
	local CurColor = nil
	local AllText = ""
	for k, v in pairs{...} do
		if not IsColor(v) then
			AllText = AllText .. tostring(v)
		end
	end
	local w, h = surface.GetTextSize(AllText)
	if xAlign == TEXT_ALIGN_CENTER then
		CurX = x - w/2
	elseif xAlign == TEXT_ALIGN_RIGHT then
		CurX = x - w
	end

	if yAlign == TEXT_ALIGN_CENTER then
		y = y - h/2
	elseif yAlign == TEXT_ALIGN_BOTTOM then
		y = y - h
	end

	for k, v in pairs{...} do
		if IsColor(v) then
			CurColor = v
			continue
		elseif CurColor == nil then
			CurColor = color_white
		end
		local Text = tostring(v)
		surface.SetTextColor(CurColor)
		surface.SetTextPos(CurX, y)
		surface.DrawText(Text)
		CurX = CurX + surface.GetTextSize(Text)
	end
end