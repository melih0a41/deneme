function EFFECT:Init(data)
    self.Vector = data:GetNormal()
    self.StartPos = self:GetTracerShootPos(data:GetOrigin(), data:GetEntity(), data:GetAttachment())
    self.Emitter = ParticleEmitter(self.StartPos)

    for i = 1, 5 do
        local particle = self.Emitter:Add('sprites/orangecore1', self.StartPos)
        local dieTime = math.Rand(0.3, 0.4)
        local startSize = 0.5
        local velocity = self.Vector * 200
        local endSize = math.Rand(5, 15)
        local startAlpha = 255
        local endAlpha = 0
        local color = Color(50, 50, 50)
        local roll = math.Rand(-10, 10)
        local rollDelta = math.Rand(-10, 10)

        particle:SetDieTime(dieTime)
        particle:SetStartSize(startSize)
        particle:SetVelocity(velocity)
        particle:SetEndSize(endSize)
        particle:SetStartAlpha(startAlpha)
        particle:SetEndAlpha(endAlpha)
        particle:SetColor(color.r, color.g, color.b)
        particle:SetRoll(roll)
        particle:SetRollDelta(rollDelta)
        particle:SetCollide(true)
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
