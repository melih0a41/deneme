/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PANEL = {}

function PANEL:Init()
    self:SetSize(RCD.ScrW*0.1949, RCD.ScrH*0.5)
    self:SetMinMax(0, 1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

    function self.Slider.Knob:Paint(w, h)
	    draw.NoTexture()
        RCD.DrawCircle(w/2, h/2, h/3.5, 0, 360, RCD.Colors["white"])
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb

    function self.Slider:Paint() end
    
    function self:Paint(w,h)
        local coef = math.Remap(self:GetValue(), self:GetMin(), self:GetMax(), 0, 1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506

        draw.RoundedBox(0, 0, h*0.5-RCD.ScrH*0.005/2, w*0.99, RCD.ScrH*0.005, RCD.Colors["grey"])
        draw.RoundedBox(0, 0, h*0.5-RCD.ScrH*0.005/2, w*coef*0.99, RCD.ScrH*0.005, RCD.Colors["purple"])
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

    self.TextArea:SetVisible(false)
    self.Label:SetVisible(false)
end

derma.DefineControl("RCD:Slider", "RCD Slider", PANEL, "DNumSlider")
