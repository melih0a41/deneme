/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PANEL = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c49b9edc019137a13776a80179ac380331027d8e659dfc9fb64ff6acb16fd41

function PANEL:Init()
    self:SetText("")
    self:SetSize(RCD.ScrW*0.1949, RCD.ScrH*0.05)
    self:SetFont("RCD:Font:13")
    self:SetTextColor(RCD.Colors["white100"])
    self.RCDRounded = 0
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb

function PANEL:SetRounded(number)
    self.RCDRounded = (number or 0)
end

function PANEL:Paint(w,h)
    draw.RoundedBox(self.RCDRounded, 0, 0, w, h, RCD.Colors["white5"])
    self:DrawTextEntryText(RCD.Colors["white100"], RCD.Colors["white100"], RCD.Colors["white100"])
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c49b9edc019137a13776a80179ac380331027d8e659dfc9fb64ff6acb16fd41

derma.DefineControl("RCD:DComboBox", "RCD DComboBox", PANEL, "DComboBox")
