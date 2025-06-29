--[[------------------------------------------------
                    Minigame NPC
------------------------------------------------]]--

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



--[[----------------------------
           Sub Modules
----------------------------]]--

function ENT:AddModule(func)
    Minigames.Checker(func, "function", 1)

    table.insert(self.MG_MODULES, func)
end

include("mg_weapon.lua")
include("mg_player.lua")
include("mg_speak.lua")

function ENT:Initialize()
    -- check if the model exists
    if not util.IsValidModel(self.Model) then
        self.Model = "models/humans/group01/male_06.mdl"
    end

    self:SetModel(self.Model)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)

    self:StartActivity(ACT_IDLE)

    self:SetNickname("Minigame NPC")

    -- Active modules
    for _, func in ipairs(self.MG_MODULES) do
        func(self)
    end
end

function ENT:OnTakeDamage()
    return 0
end



--[[----------------------------
             Custom
----------------------------]]--


function ENT:OnContact( ent )
    if not ent:IsPlayer() then return end

    self.LastTarget = ent
end

function ENT:RunBehaviour()
    while true do
        if self.LookUncannyToPlayers and IsValid(self.LastTarget) then
            local dir = (self.LastTarget:GetPos() - self:GetPos()):GetNormalized()
            local targetAngle = Angle(0, math.atan2(dir.y, dir.x) * 180 / math.pi, 0)
            local currentAngle = Angle(0, self:GetAngles().y, 0)

            local diff = math.abs(math.AngleDifference(targetAngle.y, currentAngle.y))
            if diff < 4 then
                currentAngle = targetAngle
            end

            local newAngle = LerpAngle(0.5, targetAngle, currentAngle)
            self:SetAngles(newAngle)

            coroutine.yield()
        else
            coroutine.wait(0.1)
        end
    end
end