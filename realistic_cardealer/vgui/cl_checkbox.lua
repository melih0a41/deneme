/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PANEL = {}

function PANEL:Init()
    self:SetText("")
    self:SetSize(RCD.ScrW*0.1949, RCD.ScrH*0.05)
    self.RCDLerp = 0
    self.RCDActivate = false
    self.RCDLerpColor = RCD.Colors["white0"]
end

function PANEL:Paint(w,h)
    self.RCDLerp = Lerp(FrameTime()*12, self.RCDLerp, self.RCDActivate and h/2 or 0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132

    RCD.DrawCircle(w/2, h/2, h/2, 0, 360, RCD.Colors["grey84"])
    RCD.DrawCircle(w/2, h/2, self.RCDLerp, 0, 360, RCD.Colors["purple"])

    local scale = math.floor(self.RCDLerp)*1.2
    local divisedScale = math.floor(scale/2)

    self.RCDLerpColor = RCD.LerpColor(FrameTime()*12, self.RCDLerpColor, (self.RCDActivate and RCD.Colors["white200"] or RCD.Colors["white0"]))

    surface.SetDrawColor(self.RCDLerpColor)
	surface.SetMaterial(RCD.Materials["icon_check"])
	surface.DrawTexturedRect(w/2-h*0.3, h/2-h*0.3, h*0.6, h*0.6)
end

function PANEL:DoClick()
    self.RCDActivate = !self.RCDActivate
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

    self:OnChange(self.RCDActivate)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb

function PANEL:GetActive()
    return self.RCDActivate
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

function PANEL:SetActive(bool)
    self.RCDActivate = bool
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb

derma.DefineControl("RCD:CheckBox", "RCD CheckBox", PANEL, "DButton")
