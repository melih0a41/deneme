include("shared.lua")

function ENT:Initialize()
    self.cameraAngle = Angle(0, 0, 0)
    self.lastCameraRefresh = 0
    self.pov = false
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    local curTime = CurTime()

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
end
