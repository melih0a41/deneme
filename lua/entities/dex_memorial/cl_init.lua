include("shared.lua")

local MODEL_SCALE = 0.17
local MODEL_OFFSET = Vector(1.3, 0, 3)
local MODEL_ANGLE_OFFSET = 15
local POSE_LIST = {"walk_suitcase"}

function ENT:Initialize()
    self.ModelEntity = nil
    self.LastVictimModel = ""
    
    self:NetworkVarNotify("VictimModel", self.OnVictimModelChanged)
end

function ENT:OnVictimModelChanged(name, old, new)
    if new and new ~= "" and new ~= self.LastVictimModel then
        self:SetupModel(new)
        self.LastVictimModel = new
    end
end

function ENT:SetupModel(victimModel)
    if not victimModel or victimModel == "" then return end
    if not IsValid(self) then return end
    
    if IsValid(self.ModelEntity) then
        self.ModelEntity:Remove()
    end
    
    self.ModelEntity = ClientsideModel(victimModel, RENDERGROUP_OPAQUE)
    if not IsValid(self.ModelEntity) then return end

    self.ModelEntity:SetNoDraw(true)
    self.ModelEntity:SetModelScale(MODEL_SCALE, 0)

    local sequence = self.ModelEntity:LookupSequence(table.Random(POSE_LIST))
    if sequence >= 0 then
        self.ModelEntity:SetSequence(sequence)
        self.ModelEntity:SetCycle(0)
        self.ModelEntity:SetPlaybackRate(0)
    end

    for i = 0, self.ModelEntity:GetNumPoseParameters() - 1 do
        local paramName = self.ModelEntity:GetPoseParameterName(i)
        self.ModelEntity:SetPoseParameter(paramName, 0)
    end
end

function ENT:DrawModelEntity()
    if not IsValid(self.ModelEntity) then return end

    local rotatedOffset = self:GetAngles():Forward() * MODEL_OFFSET.x +
                        self:GetAngles():Right() * MODEL_OFFSET.y +
                        self:GetAngles():Up() * MODEL_OFFSET.z
    self.ModelEntity:SetPos(self:GetPos() + rotatedOffset)

    local modelAngle = self:GetAngles()
    modelAngle:RotateAroundAxis(modelAngle:Right(), MODEL_ANGLE_OFFSET)
    self.ModelEntity:SetAngles(modelAngle)

    local matrix = Matrix()
    matrix:Scale(Vector(0.1, 1, 1))
    self.ModelEntity:EnableMatrix("RenderMultiply", matrix)

    self.ModelEntity:DrawModel()
end

function ENT:Draw()
    self:DrawModel()

    local victimModel = self:GetVictimModel()
    if not IsValid(self.ModelEntity) and victimModel ~= "" then
        self:SetupModel(victimModel)
    end

    self:DrawModelEntity()
end

function ENT:OnRemove()
    if IsValid(self.ModelEntity) then
        self.ModelEntity:Remove()
    end
end