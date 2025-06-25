/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "CoinPusher"
ENT.Author = "ClemensProduction aka Zerochain"
ENT.Information = "info"
ENT.Category = "Zeros ArcadePack"
ENT.Model = "models/zerochain/props_arcade/zap_coinpusher.mdl"
ENT.AutomaticFrameAdvance = true
ENT.DisableDuplicator = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24d29d357f25d0e3dbcd1d408ccea85b467c8e0190b63644784fca3979a920a4

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "MoneyCount")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c88d96e23ef1c52b933ccc1d3ce15226554b8e572b9dbf763835533b4e11507c

	if (SERVER) then
		self:SetMoneyCount(0)
	end
end

function ENT:AddMoneyButton(ply)
	local trace = ply:GetEyeTrace()
	local lp = self:WorldToLocal(trace.HitPos)

	if lp.x > 12 and lp.x < 28 and lp.y < -28 and lp.y > -30 and lp.z > 71.78 and lp.z < 76 then
		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

function ENT:RemoveMoneyButton(ply)
	local trace = ply:GetEyeTrace()
	local lp = self:WorldToLocal(trace.HitPos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 049b4e254ea84b6bbd8714673e122cc1e8af2018030f6cc079898e33e35e9c0c

	if lp.x > 12 and lp.x < 28 and lp.y < -28 and lp.y > -30 and lp.z > 66.78 and lp.z < 71 then
		return true
	else
		return false
	end
end
