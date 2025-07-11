/*
    Addon id: 1b1f12d2-b4fd-4ab9-a065-d7515b84e743
    Version: v1.1.2 (stable)
*/

include("shared.lua")

function ENT:Initialize()
    self.LastRolls = 0
end

function ENT:Draw()
    self:DrawModel()
end

local l_ang = Angle(0, 0, 0)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:Think()
    self:SetNextClientThink(CurTime())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

    -- ClientModel
    if zlm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 2000) then

        if self.ClientProps then

            if self.LastRolls ~= self:GetGrassRolls() then

                self.LastRolls = self:GetGrassRolls()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec4bcedb5ad793eb64c20f10460e4544045df493b35c2a9ef9ba60298c766c2

                -- If the new roll count is greater then 0 then this means a roll got loaded and we create the effect then.
                if self.LastRolls > 0 then
                    self:EmitSound("zlm_grassroll_hit")
                    local attach = self:GetAttachment(self.LastRolls + 4)
                    ParticleEffect("zlm_grassroll_load", attach.Pos, l_ang, NULL)
                end

                self:RemoveClientModels()

                for i = 1, self.LastRolls do
                    self:SpawnClientModel_GrassRolls(i)
                end
            end
        else
            self.ClientProps = {}
        end
    else
        self:RemoveClientModels()
        self.LastRolls = -1
    end

    return true
end

function ENT:SpawnClientModel_GrassRolls(pos)
    local attach = self:GetAttachment(pos + 4)
    if attach == nil then return end
    local rPos = attach.Pos
    local ent = ents.CreateClientProp("models/zerochain/props_lawnmower/zlm_grassroll.mdl")
    ent:SetPos(rPos)
    ent:SetAngles(self:GetAngles())
    ent:Spawn()
    ent:Activate()
    ent:SetParent(self)
    self.ClientProps["GrassRoll" .. pos] = ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:RemoveClientModels()
    if (self.ClientProps and table.Count(self.ClientProps) > 0) then
        for k, v in pairs(self.ClientProps) do
            if IsValid(v) then
                v:Remove()
            end
        end
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 741ac39e105a3ee9540164afd8276847e647c3ff10d5fa176e07bbc90c0f2f4d

    self.ClientProps = {}
end

function ENT:OnRemove()
    self:RemoveClientModels()
end
