/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PANEL = {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

function PANEL:Init()
    local sbar = self:GetVBar()
    sbar:SetWide(RCD.ScrW*0.003)

    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, RCD.Colors["grey30"])
    end
    function sbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, RCD.Colors["grey30"])
    end
    function sbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, RCD.Colors["grey30"])
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, RCD.Colors["grey30"])
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506

derma.DefineControl("RCD:DScroll", "RCD DScroll", PANEL, "DScrollPanel")
