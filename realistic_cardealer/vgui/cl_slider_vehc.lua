/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PANEL = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

function PANEL:Init()
    self:SetSize(RCD.ScrH*0.3, RCD.ScrH*0.027)
    self.RCDText = RCD.GetSentence("invalidText")
    self.RCDMax = 170
    self.RCDValue = 165
    self.RCDLerp = 0
end

function PANEL:SetMaxValue(value)
    self.RCDMax = value
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

function PANEL:SetActualValue(value)
    self.RCDValue = value
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

function PANEL:Paint(w,h)
    draw.DrawText(self.RCDText, "RCD:Font:06", 0, 0, RCD.Colors["white"], TEXT_ALIGN_LEFT)
    draw.SimpleText(self.RCDValue, "RCD:Font:07", w-(h/2), h/2, RCD.Colors["white80"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local pourcent = math.Clamp(self.RCDValue*100/self.RCDMax/100, 0, 1)
    
    self.RCDLerp = Lerp(FrameTime()*5, self.RCDLerp, (pourcent*(w-h*1.2)))

    draw.RoundedBox(0, 0, h-RCD.ScrH*0.0055, w-h*1.2, RCD.ScrH*0.0055, RCD.Colors["white30"])
    draw.RoundedBox(0, 0, h-RCD.ScrH*0.0055, self.RCDLerp, RCD.ScrH*0.0055, RCD.Colors["purple"])
    draw.RoundedBox(0, w-h, 0, h, h, RCD.Colors["white30"])
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

function PANEL:SetText(text)
    self.RCDText = text
end

derma.DefineControl("RCD:SlideVehicle", "RCD SlideVehicle", PANEL, "DPanel")
