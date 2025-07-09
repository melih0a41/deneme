/*
    Addon id: 28ddc61a-392d-42d6-8fb0-ed07a8920d3c
    Version: v1.6.3 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_trashman/ztm_buyermachine.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Buyermachine"
ENT.Category = "Zeros Trashman"
ENT.RenderGroup = RENDERGROUP_BOTH
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 4761d92e26a8368e807053fe2d90c81f752029244ebe30160fa138da2f850f4d

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsInserting")
    self:NetworkVar("Float", 0, "Money")
    self:NetworkVar("Int", 0, "BlockType")
    self:NetworkVar("Entity", 0, "MoneyEnt")
    self:NetworkVar("Int", 1, "PriceModify")
    if (SERVER) then
        self:SetIsInserting(false)
        self:SetMoney(0)
        self:SetBlockType(1)
        self:SetPriceModify(100)
    end
end


function ENT:OnPayoutButton(ply)
    local trace = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 690e7c05e9b721aeeb69c6e7b7a4675f509d3d60bb2720620b2eb2eadf3d954b

    local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 8c0610095498cad249907b4483d55516b938e13a8ae55fb7897080fa3a184381

    if lp.x > -13 and lp.x < 13 and lp.y < 10 and lp.y > 9 and lp.z > 79 and lp.z < 85.3 then
        return true
    else
        return false
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
