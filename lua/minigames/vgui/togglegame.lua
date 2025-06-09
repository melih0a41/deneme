--[[--------------------------------------------
        Minigame Setup Menu - Toggle Button
--------------------------------------------]]--


local ButtonStyleBackground = Color(58, 58, 58, 150)
local ButtonStyleDisabled = Color(0, 0, 0, 100)
local BlackBackground = Color(0, 0, 0, 40)

local ShadingColor = {}
for i = 1, 16 do
    ShadingColor[i] = Color(0, 158, 185, (i * 160) / 16)
end

local ButtonStyle = function(SelfButton, w, h)
    draw.RoundedBox(4, 0, 0, w, h, SelfButton:IsEnabled() and ButtonStyleBackground or ButtonStyleDisabled)

    if not SelfButton:IsEnabled() then
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100))
    elseif SelfButton:IsHovered() then
        draw.RoundedBox(4, 0, 0, w, h, BlackBackground)

        for i = 1, 16 do
            draw.RoundedBox(0, 0, h + i - 16, w, 1, ShadingColor[i])
        end
    end
end

--[[----------------------------
       Toggle Game Button
----------------------------]]--

local PANEL = {}

function PANEL:Init()
    self.ToggleGameButon = self:Add("DButton")
    self.ToggleGameButon:SetText("Toggle Game")
    self.ToggleGameButon:SetFont("Minigames.Text")
    self.ToggleGameButon:SetTextColor(color_white)
    self.ToggleGameButon:Dock(FILL)
    self.ToggleGameButon.DoClick = function()
        net.Start("Minigames.SetupMenu")
        net.SendToServer()
    end

    self.ToggleGameButon:SetEnabled( Minigames.ActiveGames[ LocalPlayer() ] ~= nil )

    self.ToggleGameButon.Paint = ButtonStyle
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, ButtonStyleBackground)
end

vgui.Register("Minigames.ToggleGame", PANEL, "DPanel")