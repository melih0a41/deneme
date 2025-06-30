/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local carouselId, selectedVehicle, sellVehicle

local function getAllVehiclesAround()
    local entities, vehiclesId = {}, {}
    
    for k, v in ipairs(ents.GetAll()) do
        if not IsValid(v) then continue end
        if v:GetPos():DistToSqr(RCD.LocalPlayer:GetPos()) > RCD.GetSetting("distanceToSell", "number") then continue end

        local vehicleId = tonumber(RCD.GetNWVariables("RCDVehicleId", v))
        if not isnumber(vehicleId) then continue end

        local vehicleTable = RCD.GetVehicleInfo(vehicleId)
        local options = vehicleTable["options"] or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

        if options["cantResellVehicle"] then continue end

        entities[#entities + 1] = v
        vehiclesId[vehicleId] = true
    end

    RCD.ClientTable = RCD.ClientTable or {}
    RCD.ClientTable["vehiclesTable"] = RCD.ClientTable["vehiclesTable"] or {}

    for k,v in pairs(RCD.AdvancedConfiguration["vehiclesList"]) do
        if not vehiclesId[v.id] then continue end
        
        RCD.ClientTable["vehiclesTable"][k] = v
    end

    return entities
end

local function reloadPrice(vehiclesTable, sellVehicle)
    if not IsValid(sellVehicle) then return end
    
    local vehicleId = RCD.GetNWVariables("RCDVehicleId", vehiclesTable[carouselId])
    local vehicleTable = RCD.GetVehicleInfo(vehicleId)
    local options = vehicleTable["options"] or {}

    local resellPourcentPrice = RCD.GetSetting("resellPourcentPrice", "number")

    if options["pourcentPriceSellVehicle"] && options["pourcentPriceSellVehicle"] != 0 then
        resellPourcentPrice = options["pourcentPriceSellVehicle"] 
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7c49b9edc019137a13776a80179ac380331027d8e659dfc9fb64ff6acb16fd41

    local price = tonumber((vehicleTable["price"] or 0))*resellPourcentPrice/100

    local maxResellPrice = RCD.GetSetting("maxResellPrice", "number")
    price = math.Clamp(price, 0, maxResellPrice)
    
    sellVehicle:SetText(RCD.GetSentence("resellerSell"):format(RCD.formatMoney(price)))
end

local function reloadVehicles(vehicleModel)
    local vehiclesTable = getAllVehiclesAround()

    vehicleModel.Vehicles = {}
    for k,v in pairs(vehiclesTable) do
        vehicleModel.Vehicles[k] = ClientsideModel(v:GetModel(), RENDER_GROUP_OPAQUE)
            
        if not IsValid(vehicleModel.Vehicles[k]) then continue end
        vehicleModel.Vehicles[k]:SetNoDraw(true)
        vehicleModel.Vehicles[k]:SetPos(Vector(0, 500*k-500, 0))
        vehicleModel.Vehicles[k]:AddEffects(EF_BONEMERGE)
        vehicleModel.Vehicles[k]:SetSkin(v:GetSkin())
        vehicleModel.Vehicles[k].model = v:GetModel()
        vehicleModel.Vehicles[k].RCDColor = v:GetColor()
        vehicleModel.Vehicles[k].RCDId = k
        for bodyKey, _ in pairs(v:GetBodyGroups()) do
            vehicleModel.Vehicles[k]:SetBodygroup(bodyKey, v:GetBodygroup(bodyKey))
        end

        vehicleModel.PaintOver = function()
            if not IsValid(v) then
                carouselId = 1
                reloadVehicles(vehicleModel)
                reloadPrice(vehiclesTable, sellVehicle)
            end
        end

        if k == 1 then
            vehicleModel:SetFocusEntity(vehicleModel.Vehicles[k])

            selectedVehicle = v
        end

        local vehicleId = RCD.GetNWVariables("RCDVehicleId", v)
        local vehicleTable = RCD.GetVehicleInfo(vehicleId)

        local options = vehicleTable["options"] or {}

        if isangle(options["angle"]) then
            vehicleModel.Vehicles[k]:SetAngles(options["angle"] + RCD.Constants["angleParams"])
        end
        
        if options["addon"] == "simfphys" then
            RCD.GenerateWheels(vehicleModel.Vehicles[k], options["class"])
        end
    end
end

function RCD.ResellerMenu()
    if IsValid(resellerMenu) then resellerMenu:Remove() end
    
    local vehiclesTable = getAllVehiclesAround()
    carouselId, selectedVehicle = 1, vehiclesTable[1]

    if not IsValid(selectedVehicle) then 
        RCD.Notification(5, RCD.GetSentence("noVehicleAround"))
        return 
    end

    resellerMenu = vgui.Create("DFrame")
    resellerMenu:SetSize(RCD.ScrW*0.503, RCD.ScrH*0.603)
    resellerMenu:MakePopup()
    resellerMenu:SetTitle("")
    resellerMenu:SetDraggable(false)
    resellerMenu:ShowCloseButton(false)
    resellerMenu:Center()
    
    local vehicleModel = vgui.Create("RCD:DModel", resellerMenu)
    vehicleModel:SetModel(selectedVehicle:GetModel())
    vehicleModel:Dock(FILL)
    vehicleModel:DockMargin(RCD.ScrH*0.01, RCD.ScrH*0.01, RCD.ScrH*0.01, RCD.ScrH*-0.06)
    vehicleModel:SetFOV(50)
    vehicleModel:CanRotateCamera(true)
    vehicleModel.forceRotate = true
    
    local leftArrow = vgui.Create("DButton", resellerMenu)
    leftArrow:SetSize(RCD.ScrW*0.021, RCD.ScrH*0.037)
    leftArrow:SetPos(RCD.ScrW*0.05, RCD.ScrH*0.3)
    leftArrow:SetText("")
    leftArrow.Paint = function(self,w,h)
        surface.SetDrawColor(RCD.Colors["white100"])
        surface.SetMaterial(RCD.Materials["left_vehicle"])
        surface.DrawTexturedRect(0, 0, w, h)
    end
    leftArrow.DoClick = function()
        local vehiclesTable = getAllVehiclesAround()

        carouselId = math.Clamp(carouselId - 1, 1, #vehiclesTable)
        selectedVehicle = vehiclesTable[carouselId]

        reloadPrice(vehiclesTable, sellVehicle)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

        vehicleModel:SetFocusEntity(vehicleModel.Vehicles[carouselId])
    end
    
    local rightArrow = vgui.Create("DButton", resellerMenu)
    rightArrow:SetSize(RCD.ScrW*0.021, RCD.ScrH*0.037)
    rightArrow:SetPos(RCD.ScrW*0.45, RCD.ScrH*0.3)
    rightArrow:SetText("")
    rightArrow.Paint = function(self,w,h)
        surface.SetDrawColor(RCD.Colors["white100"])
        surface.SetMaterial(RCD.Materials["right_vehicle"])
        surface.DrawTexturedRect(0, 0, w, h)  
    end
    rightArrow.DoClick = function()
        local vehiclesTable = getAllVehiclesAround()

        carouselId = math.Clamp(carouselId + 1, 1, #vehiclesTable)
        selectedVehicle = vehiclesTable[carouselId]

        reloadPrice(vehiclesTable, sellVehicle)

        vehicleModel:SetFocusEntity(vehicleModel.Vehicles[carouselId])
    end

    reloadVehicles(vehicleModel)

    resellerMenu.Paint = function(self,w,h)
        RCD.DrawBlur(self, 10) 
        
        draw.RoundedBox(0, 0, 0, w, h, RCD.Colors["blackpurple"])
        draw.RoundedBox(0, w/2-RCD.ScrW*0.49/2, h*0.02, RCD.ScrW*0.49, RCD.ScrH*0.062, RCD.Colors["white20"])
        
        draw.DrawText(RCD.GetSentence("resellerTitle"), "RCD:Font:10", w*0.025, h*0.02, RCD.Colors["white"], TEXT_ALIGN_LEFT)
        draw.DrawText(RCD.GetSentence("resellerDesc"), "RCD:Font:11", w*0.025, h*0.07, RCD.Colors["white100"], TEXT_ALIGN_LEFT)

        local vehiclesTable = getAllVehiclesAround()
        if #vehiclesTable <= 0 then
            resellerMenu:Remove()
        end
    end

    local lerpVehicle = 1
    function vehicleModel:DrawModel()
        local curparent = self
        local leftx, topy = self:LocalToScreen(0, 0)
        local rightx, bottomy = self:LocalToScreen(self:GetWide(), self:GetTall())
        while (curparent:GetParent() != nil) do
            curparent = curparent:GetParent()
    
            local x1, y1 = curparent:LocalToScreen(0, 0)
            local x2, y2 = curparent:LocalToScreen(curparent:GetWide(), curparent:GetTall())
    
            leftx = math.max(leftx, x1)
            topy = math.max(topy, y1)
            rightx = math.min(rightx, x2)
            bottomy = math.min(bottomy, y2)
            previous = curparent
        end
    
        render.SetScissorRect(leftx, topy, rightx, bottomy, true)
        
        for k,v in pairs(self.Vehicles or {}) do
            local color = v.RCDColor or color_white

            render.SetColorModulation(color.r/255, color.g/255, color.b/255)
            v:DrawModel()

            if istable(v.wheels) then
                for k, wheel in ipairs(v.wheels) do
                    wheel:DrawModel()  
                end
            end       
        end
        
        local mn, mx = self.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

        lerpVehicle = Lerp(FrameTime()*3, lerpVehicle, carouselId)
        
        vehicleModel:SetCamPos(Vector(200+size, 500*lerpVehicle-500, 110))
        vehicleModel:SetLookAt(Vector(0, 500*lerpVehicle-500, 0) + self.RCDLerpVector)

        render.SetScissorRect(0, 0, 0, 0, false)
    end
    
    sellVehicle = vgui.Create("RCD:SlideButton", resellerMenu)
    sellVehicle:SetSize(resellerMenu:GetWide()*0.972, RCD.ScrH*0.041)
    sellVehicle:SetPos(RCD.ScrW*0.008, RCD.ScrH*0.55)
    sellVehicle:SetText(RCD.GetSentence("resellerSell"):format(RCD.formatMoney(0)))
    sellVehicle:SetFont("RCD:Font:12")
    sellVehicle:SetTextColor(RCD.Colors["white"])
    sellVehicle:InclineButton(0)
    sellVehicle.MinMaxLerp = {50, 200}
    sellVehicle:SetIconMaterial(nil)
    sellVehicle:SetButtonColor(RCD.Colors["purple"])
    sellVehicle.DoClick = function()
        if not IsValid(selectedVehicle) then return end

        net.Start("RCD:Insurance")
            net.WriteUInt(1, 5)
            net.WriteEntity(selectedVehicle)
        net.SendToServer()
    end
    reloadPrice(vehiclesTable, sellVehicle)
    
    local closeLerp = 50
    local close = vgui.Create("DButton", resellerMenu)
    close:SetSize(RCD.ScrH*0.026, RCD.ScrH*0.026)
    close:SetPos(resellerMenu:GetWide()*0.945, RCD.ScrH*0.03)
    close:SetText("")
    close.Paint = function(self,w,h)
        closeLerp = Lerp(FrameTime()*5, closeLerp, (close:IsHovered() and 50 or 100))
        
        surface.SetDrawColor(ColorAlpha(RCD.Colors["white100"], closeLerp))
        surface.SetMaterial(RCD.Materials["icon_close"])
        surface.DrawTexturedRect(0, 0, w, h)
    end
    close.DoClick = function()
        resellerMenu:Remove()
    end
end

net.Receive("RCD:Insurance", function()
    local uInt = net.ReadUInt(4)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132

    if uInt == 1 then
        RCD.ResellerMenu()
    end
end)
