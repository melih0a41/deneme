/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PANEL = {}

function PANEL:Init()
    self:SetSize(RCD.ScrW*0.023, RCD.ScrH*0.019)
    self:SetText("")
    self.RCDLerp = 0
    self.RCDActivate = true
    self.RCDLerpColor = RCD.Colors["purple"]
    self.RCDCanChange = true
end

function PANEL:ChangeStatut(bool)
    self.RCDActivate = bool
end

function PANEL:GetStatut()
    return self.RCDActivate
end

function PANEL:CanChange(bool)
    self.RCDCanChange = bool
end

function PANEL:Paint(w,h)
    self.RCDLerp = Lerp(FrameTime()*5, self.RCDLerp, (self.RCDActivate and w*0.44 or 0))
    self.RCDLerpColor = RCD.LerpColor(FrameTime()*5, self.RCDLerpColor, (self.RCDActivate && self.RCDCanChange and RCD.Colors["purple"] or RCD.Colors["grey"]))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

    RCD.DrawElipse(0, 0, w, h, self.RCDLerpColor, false, false)
    RCD.DrawCircle(w*0.28 + self.RCDLerp, h*0.5, h*0.4, 0, 360, RCD.Colors["white"])
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506

function PANEL:DoClick()
    if not self.RCDCanChange then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

    self.RCDActivate = !self.RCDActivate
    self:OnChange()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132

derma.DefineControl("RCD:Toggle", "RCD Toggle", PANEL, "DButton")
