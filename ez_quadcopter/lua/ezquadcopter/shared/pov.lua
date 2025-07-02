if SERVER then
    util.AddNetworkString("ezquadcopter_quadcopter_pov")

    function easzy.quadcopter.changeViewEntity(quadcopter, pov)
        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if not IsValid(owner) then return end
        if pov then
            owner:SetViewEntity(quadcopter)
        else
            owner:SetViewEntity(owner)
        end
    end

    -- View entity
    net.Receive("ezquadcopter_quadcopter_pov", function(len, ply)
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
        if owner != ply then return end

        local pov = net.ReadBool()
        easzy.quadcopter.changeViewEntity(quadcopter, pov)
    end)
else
    function easzy.quadcopter.EnablePOV(quadcopter)
        quadcopter.pov = true

        net.Start("ezquadcopter_quadcopter_pov")
        net.WriteEntity(quadcopter)
        net.WriteBool(true)
        net.SendToServer()

        hook.Add("HUDPaint", "ezquadcopter_pov_HUDPaint", function()
            if not IsValid(quadcopter) then
                easzy.quadcopter.DisablePOV(quadcopter)
                return
            end

            easzy.quadcopter.QuadcopterHUD(quadcopter, nil, ScrW(), ScrH())

            -- Only render the quadcopter screen
            return false
        end)
    end

    function easzy.quadcopter.DisablePOV(quadcopter)
        hook.Remove("HUDPaint", "ezquadcopter_pov_HUDPaint")

        if not IsValid(quadcopter) then return end
        quadcopter.pov = false

        net.Start("ezquadcopter_quadcopter_pov")
        net.WriteEntity(quadcopter)
        net.WriteBool(false)
        net.SendToServer()
    end

    local visorWide = 80

    local plain = Material("easzy/ez_quadcopter/noise/plain.png")
    local noise = {
        texture = surface.GetTextureID("easzy/ez_quadcopter/noise/noise"),
        color = easzy.quadcopter.colors.white,
        x = 0,
        y = 0
    }
    local colorModify = {
        ["$pp_colour_addr"] = 0.06,
        ["$pp_colour_addg"] = 0.06,
        ["$pp_colour_brightness"] = 0.2,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 0.5
    }
    local thermalMat = Material("pp/texturize/plain.png")
    local colorModifyThermal = {
        ["$pp_colour_brightness"] = 0.05,
        ["$pp_colour_contrast"] = 0.5
    }

    local function IsHot(entity)
        if not entity then return false end
        if not IsValid(entity) then return false end
        if entity:IsWorld() then return false end
        if entity:IsOnFire() then return true end
        if entity:IsNPC() then return true end
        if entity:IsNextBot() then return true end
        if entity:IsPlayer() then return true end
        if entity:IsRagdoll() then return true end
        if entity:IsVehicle() then return true end
    end

    local allEntities = {}
    local allEntitiesCount = 0

    function easzy.quadcopter.QuadcopterHUD(quadcopter, renderTarget, w, h)
        if not w or not h then return end
        if not IsValid(quadcopter) then return end

        local class = quadcopter:GetClass()

        hook.Add("ShouldDrawLocalPlayer", "ezquadcopter_ShouldDrawLocalPlayer", function(ply) return true end)
        hook.Add("PreDrawEffects", "ezquadcopter_thermal_PreDrawEffects", function()
            if not quadcopter.equipments["Camera"] or not quadcopter.thermal then return end

            if ents.GetCount() != allEntitiesCount then
                allEntities = ents.GetAll()
            end
            for _, entity in ipairs(allEntities) do
                if IsHot(entity) then
                    local brightness = 1

                    if entity:IsVehicle() then
                        brightness = math.Clamp(entity:GetVelocity():Length() / 400, 0, 1)
                    end

                    if brightness > 0 then
                        render.SetBlend(0.5)
                        render.SuppressEngineLighting(true)

                        brightness = brightness * 250

                        render.SetColorModulation(brightness, brightness, brightness)

                        entity:DrawModel()
                    end
                end
            end

            render.SetBlend(1)
            render.SuppressEngineLighting(false)
            render.SetColorModulation(1, 1, 1)
        end)

        render.PushRenderTarget(renderTarget)
        render.Clear(255, 255, 255, 255, true)

        cam.Start2D()
            surface.SetDrawColor(easzy.quadcopter.colors.transparentWhite:Unpack())
            render.RenderView({
                origin = quadcopter:LocalToWorld(quadcopter:WorldToLocal(quadcopter:GetPos()) + Vector(3, 0, 3)),
                angles = quadcopter:GetAngles() + quadcopter.cameraAngle,
                drawviewmodel = false,
                fov = 90
            })

            if quadcopter.equipments["Camera"] and quadcopter.thermal then
                DrawColorModify(colorModifyThermal)
                DrawTexturize(1, thermalMat)
                DrawBloom(0, 1, 4, 4, 1, 1, 1, 1, 1)
            else
                DrawColorModify(colorModify)
            end

            -- Black and white
            if easzy.quadcopter.config.blackAndWhiteCam then
                DrawTexturize(0, plain)
            end

            -- Noise
            -- noise.w, noise.h = w, h
            -- draw.TexturedQuad(noise)

            surface.SetDrawColor(easzy.quadcopter.colors.transparentWhite:Unpack())
            surface.SetMaterial(easzy.quadcopter.materials.visor)
            surface.DrawTexturedRect((w - visorWide)/2, (h - visorWide)/2, visorWide, visorWide/2)

            local angleText = math.Round(quadcopter.cameraAngle.x > 90 and quadcopter.cameraAngle.x - 360 or quadcopter.cameraAngle.x)
            draw.SimpleText(easzy.quadcopter.languages.cameraAngle .. " : " .. angleText .. " °", "EZFont30", easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(50), easzy.quadcopter.colors.transparentWhite)

            local speedText = math.Round(quadcopter:GetVelocity():Length() / 10)
            draw.SimpleText(easzy.quadcopter.languages.speed .. " : " .. speedText .. " " .. easzy.quadcopter.config.speedUnit, "EZFont30", easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(100), easzy.quadcopter.colors.transparentWhite)

            local batteryText = math.Round(quadcopter.battery)
            draw.SimpleText(easzy.quadcopter.languages.battery .. " : " .. batteryText .. " %", "EZFont30", easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(150), easzy.quadcopter.colors.transparentWhite)

            if quadcopter.equipments["Speaker"] then
                local speakerText = easzy.quadcopter.languages.speaker ..  " : " .. (quadcopter.speakerOn and easzy.quadcopter.languages.on or easzy.quadcopter.languages.off)
                draw.SimpleText(speakerText, "EZFont30", easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(200), easzy.quadcopter.colors.transparentWhite)
            end

            local informationsY = easzy.quadcopter.RespY(150)
            local equipmentsData = easzy.quadcopter.quadcoptersData[class].equipments
            for name, equipmentData in pairs(equipmentsData) do
                if quadcopter.equipments[name] and equipmentData.information then
                    draw.SimpleText(equipmentData.information, "EZFont30", easzy.quadcopter.RespX(100), h - informationsY, easzy.quadcopter.colors.transparentWhite)
                    informationsY = informationsY + easzy.quadcopter.RespY(50)
                end
            end

        cam.End2D()
        render.PopRenderTarget()

        hook.Remove("PreDrawEffects", "ezquadcopter_thermal_PreDrawEffects")
        hook.Remove("ShouldDrawLocalPlayer", "ezquadcopter_ShouldDrawLocalPlayer")
    end

    function easzy.quadcopter.FPVRadioControllerHUD(quadcopter, renderTarget, w, h)
        if not w or not h then return end

        local class = quadcopter:GetClass()

        hook.Add("ShouldDrawLocalPlayer", "ezquadcopter_ShouldDrawLocalPlayer", function(ply) return true end)

        render.PushRenderTarget(renderTarget)
        render.Clear(149, 175, 149, 255, true)

        cam.Start2D()
            surface.SetDrawColor(easzy.quadcopter.colors.transparentWhite:Unpack())

            local angleText = math.Round(quadcopter.cameraAngle.x > 90 and quadcopter.cameraAngle.x - 360 or quadcopter.cameraAngle.x)
            draw.SimpleText(easzy.quadcopter.languages.cameraAngle .. " : " .. angleText .. " °", "EZFont30", easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(50), easzy.quadcopter.colors.transparentWhite)

            local speedText = math.Round(quadcopter:GetVelocity():Length() / 10)
            draw.SimpleText(easzy.quadcopter.languages.speed .. " : " .. speedText .. " " .. easzy.quadcopter.config.speedUnit, "EZFont30", easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(100), easzy.quadcopter.colors.transparentWhite)

            local batteryText = math.Round(quadcopter.battery)
            draw.SimpleText(easzy.quadcopter.languages.battery .. " : " .. batteryText .. " %", "EZFont30", easzy.quadcopter.RespX(100), easzy.quadcopter.RespY(150), easzy.quadcopter.colors.transparentWhite)

            local informationsY = easzy.quadcopter.RespY(150)
            local equipmentsData = easzy.quadcopter.quadcoptersData[class].equipments
            for name, equipmentData in pairs(equipmentsData) do
                if quadcopter.equipments[name] and equipmentData.information then
                    draw.SimpleText(equipmentData.information, "EZFont30", easzy.quadcopter.RespX(100), h - informationsY, easzy.quadcopter.colors.transparentWhite)
                    informationsY = informationsY + easzy.quadcopter.RespY(50)
                end
            end

        cam.End2D()
        render.PopRenderTarget()

        hook.Remove("ShouldDrawLocalPlayer", "ezquadcopter_ShouldDrawLocalPlayer")
    end
end
