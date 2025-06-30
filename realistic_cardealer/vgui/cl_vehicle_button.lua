/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.5 (stable)
*/

local PANEL = {}

function PANEL:Init()
    self:SetSize(RCD.ScrW*0.1949, RCD.ScrH*0.05)
    self:InclineButton(RCD.ScrW*0.055)
    self:SetText("")
    self:SetIconMaterial(nil)
    self.MinMaxLerp = {15, 5}
    self.VehicleName = RCD.GetSentence("invalidText")
    self.VehiclePrice = 0
    self.RCDSelected = nil
    self.RCDUniqueId = nil
    self.RCDCustomText = nil
    self.Fake = false
end

function PANEL:SetName(name)
    self.VehicleName = (name or RCD.GetSentence("undefined"))
end

function PANEL:SetPrice(price)
    self.VehiclePrice = (tonumber(price) or 0)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198381307883

function PANEL:SetCustomText(text)
    self.RCDCustomText = text
end

function PANEL:SetFake(bool)
    self.Fake = bool
end

function PANEL:SetUniqueId(uniqueId)
    self.RCDUniqueId = uniqueId
end

function PANEL:PaintOver(w,h)
    if self.Fake then return end
    
    local money = LocalPlayer():RCDGetMoney()
    local bought = RCD.ClientTable["vehiclesBought"][self.RCDUniqueId]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198381307883

    draw.SimpleText(self.VehicleName, "RCD:Font:06", w/2.3, h*0.78, RCD.Colors["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if bought then
        draw.SimpleText(RCD.GetSentence("owned"), "RCD:Font:08", w/2.3, h*0.9, RCD.Colors["green97"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        local textUnder
        if isstring(self.RCDCustomText) then
            textUnder = self.RCDCustomText
        else
            textUnder = self.VehiclePrice <= 0 and RCD.GetSentence("free") or RCD.formatMoney(self.VehiclePrice)
        end

        draw.SimpleText(textUnder, "RCD:Font:08", w/2.3, h*0.9, ((money < self.VehiclePrice) or isstring(self.RCDCustomText)) and RCD.Colors["red202"] or RCD.Colors["green97"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198381307883

    local bought = RCD.ClientTable["vehiclesBought"][self.RCDUniqueId]
    
    if bought then
        RCD.DrawCircle(w*0.91, h*0.1, h*0.06, 0, 360, RCD.Colors["purple"])

        surface.SetDrawColor(RCD.Colors["white"])
        surface.SetMaterial(RCD.Materials["icon_check"])
        surface.DrawTexturedRect(w*0.91-h*0.07/2, h*0.1-h*0.07/2, h*0.07, h*0.07)
    end

    if not LocalPlayer():RCDCanAccessVehicle(self.RCDUniqueId) then
        if not bought then
            RCD.DrawCircle(w*0.91, h*0.1, h*0.06, 0, 360, RCD.Colors["yellow"])
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e7642b6fee76974c5b4cb1588c352652566adad83a055acd6548883f965b363c

            surface.SetDrawColor(RCD.Colors["white"])
            surface.SetMaterial(RCD.Materials["icon_star"])
            surface.DrawTexturedRect(w*0.91-h*0.07/2, h*0.1-h*0.07/2, h*0.07, h*0.07)
        end

        surface.SetDrawColor(RCD.Colors["white100"])
        surface.SetMaterial(RCD.Materials["lock"])
        surface.DrawTexturedRect(w*0.845, h*0.07, h*0.07, h*0.07)
    end

    if not IsValid(self.vehicleModel) then return end

    local bool = self.vehicleModel:IsHovered()
    self.ColorLerp = Lerp(FrameTime()*3, self.ColorLerp, (bool or self.RCDSelected) and self.MinMaxLerp[1] or self.MinMaxLerp[2])
        
    local model = self.vehicleModel:GetModel()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6d21edde7c4a1b0ef357587fa9066c2a28ce32c65b157abc6efda0f8c0ec5415

    if isstring(model) then
        if IsValid(self.vehicleModel) && isstring(self.vehicleTextModel) && self.vehicleModel:GetModel():lower() != self.vehicleTextModel:lower() then
            self.vehicleModel:SetModel(self.vehicleTextModel)  
        end
    end
end

function PANEL:SetSelectedButton(bool)
    self.RCDSelected = bool
end

function PANEL:SetModel(mdl)
    self.vehicleTextModel = mdl

    self.vehicleModel = vgui.Create("RCD:DModel", self)
    self.vehicleModel:Dock(FILL)
    self.vehicleModel:DockMargin(RCD.ScrW*0.025,0,RCD.ScrW*0.03,RCD.ScrH*0.025)
    self.vehicleModel:SetFOV(55)
    self.vehicleModel:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self.vehicleModel:CanRotateCamera(false)
end

derma.DefineControl("RCD:VehicleButton", "RCD VehicleButton", PANEL, "RCD:SlideButton")
