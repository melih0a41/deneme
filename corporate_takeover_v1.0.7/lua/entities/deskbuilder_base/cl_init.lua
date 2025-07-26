include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

function ENT:Initialize()
    self.name = ""
end

function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 200 * 200 then
        if(self.name == "" && self:GetDeskClass() != "none") then
            local desk = Corporate_Takeover.Desks[self:GetDeskClass()]
            if(desk) then
                self.name = desk.name
            end
        end

        local pos = self:GetPos()
        local ang = self:GetAngles()

        ang:RotateAroundAxis(ang:Forward(), 0)
        ang:RotateAroundAxis(ang:Up(), 90)


        pos = pos + ang:Right() * -2.25 + ang:Up() * 14.2

        cam.Start3D2D(pos, ang, 0.1)
            draw.DrawText(self.name, "cto_40", 0, 0, color_white, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

local function deskbuilderMenu(deskClass)
    local desk = Corporate_Takeover.Desks[deskClass]
    if(!desk) then return false end

    local w, h = ScrW() * 0.15, ScrH() * 0.14

    local main = vgui.Create("cto_main")
    main:SetSize(w, h)
    main:Center()
    main:SetWindowTitle(Corporate_Takeover:Lang(deskClass))
    function main:OnRemove()
        if(self.build) then return false end
        net.Start("cto_deskPlacement")
            net.WriteBit(0)
        net.SendToServer()
    end

    local build = vgui.Create("cto_button", main)
    build:DockMargin(0, 0, 0, Corporate_Takeover.Scale(10))
    build:Dock(TOP)
    build:SetText(Corporate_Takeover:Lang(deskClass == "vault" and "build_vault" or "build_desk"))
    function build:DoClick()
        main.build = true

        net.Start("cto_OpenDeskBuilderMenu")
        net.SendToServer()

        main:Remove()
        surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
    end

    local sell = vgui.Create("cto_button", main)
    sell:DangerTheme()
    sell:Dock(BOTTOM)
    sell:SetText(Corporate_Takeover:Lang(deskClass == "vault" and "sell_vault" or "sell_desk"))
    function sell:DoClick()
        net.Start("cto_sellDesk")
        net.SendToServer()
        
        main:Remove()
        surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
    end
end
net.Receive("cto_OpenDeskBuilderMenu", function()
    deskbuilderMenu(net.ReadString())
end)