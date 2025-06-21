include("shared.lua")

function ENT:Initialize()
    self.cameraAngle = Angle(0, 0, 0)
    self.lastCameraRefresh = 0
    self.pov = false
    self.thermal = false
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    local curTime = CurTime()

    if self.lightOn then
        local dlight = DynamicLight(self:EntIndex())
        if (dlight) then
            dlight.pos = self:GetPos() + self:GetForward() * 100
            dlight.dir = self:GetForward()
            dlight.innerangle = 5
            dlight.outerangle = 0
            dlight.r = 255
            dlight.g = 255
            dlight.b = 255
            dlight.brightness = 3
            dlight.decay = 1000
            dlight.size = 256
            dlight.style = 12
            dlight.dietime = curTime + 1
        end
    end

    -- Camera movement
    if self.on and self.equipments["Camera"] then
        local degree = (curTime - self.lastCameraRefresh) * 45

        self.cameraAngle.x = self.cameraAngle.x % 360

        local newCameraAngle = self.cameraAngle

        if input.IsKeyDown(KEY_UP) then
            newCameraAngle = newCameraAngle + Angle(-degree, 0, 0)
        elseif input.IsKeyDown(KEY_DOWN) then
            newCameraAngle = newCameraAngle + Angle(degree, 0, 0)
        end

        if newCameraAngle.x < 0 then
            newCameraAngle.x = newCameraAngle.x + 360
        elseif newCameraAngle.x >= 360 then
            newCameraAngle.x = newCameraAngle.x - 360
        end

        if (newCameraAngle.x < 90 and newCameraAngle.x >= 0) or (newCameraAngle.x > 330 and newCameraAngle.x <= 360) then
            self.cameraAngle = newCameraAngle
        end

        self.lastCameraRefresh = curTime
    else
        self.cameraAngle.x = 0
    end

    local curTime = CurTime()
    if self.lastThermalSwitch and (curTime - self.lastThermalSwitch) < 0.2 then return end
    if input.IsKeyDown(KEY_N) then
        self.lastThermalSwitch = curTime
        self.thermal = not self.thermal
    end
end
