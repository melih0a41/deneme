/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PANEL = {}

function PANEL:Init()
    self.entry = vgui.Create("DTextEntry", self)
    self.entry:Dock(FILL)
    self.entry:DockMargin(RCD.ScrW*0.0035, 0, 0, 0)
    self.entry:SetText("")
    self.entry:SetDrawLanguageID(false)
    self.entry:SetFont("RCD:Font:13")
    
    self.entry.RCDPlaceHolder = ""
    self.entry.RCDBackgroundColor = RCD.Colors["white5"]
    self.entry.RCDRounded = 0

    self.entry.Paint = function(pnl,w,h)
        pnl:DrawTextEntryText(RCD.Colors["white100"], RCD.Colors["white100"], RCD.Colors["white100"])
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

    self.entry.OnGetFocus = function()
        if string.Trim(self.entry:GetValue()) == "" or tostring(self.entry:GetValue()) == tostring(self.entry.RCDPlaceHolder) then
            self.entry:SetValue("")
        end
    end
    
    self.entry.OnLoseFocus = function()
        if string.Trim(self.entry:GetValue()) == "" then
            self.entry:SetText(self.entry.RCDPlaceHolder)
        end
    end
end

function PANEL:BackGroundColor(color)
    self.entry.RCDBackgroundColor = color
end

function PANEL:SetPlaceHolder(text)
    self.entry.RCDPlaceHolder = text
    self.entry:SetText(self.entry.RCDPlaceHolder)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

function PANEL:SetNumeric()
    self.entry:SetNumeric(true)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0

function PANEL:SetRounded(number)
    self.entry.RCDRounded = (number or 0)
end

function PANEL:GetText()
    return self.entry:GetText()
end

function PANEL:SetText(text)
    return self.entry:SetText(text)
end

function PANEL:Paint(w,h) 
    draw.RoundedBox(self.entry.RCDRounded, 0, 0, w, h, self.entry.RCDBackgroundColor)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

derma.DefineControl("RCD:TextEntry", "RCD TextEntry", PANEL, "DPanel")
