/*
    Addon id: 5c4c2c82-a77f-4f8a-88b9-60acbd238a40
    Version: v1.0.1 (stable)
*/

include("shared.lua")

function ENT:Draw_Info()
	if (IsValid(self)) then
		local attach = self:GetAttachment(1)

		if (attach) then
			local Pos = attach.Pos
			local Ang = attach.Ang
			local moneycount = tostring(math.Round(self:GetMoneyCount())) .. zcrga.config.Currency
			cam.Start3D2D(Pos, Ang, 0.1)
				draw.SimpleText(moneycount, "zcrga_coinpusher_moneycount", 0, 0, Color(100, 255, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()

			if table.Count(zcrga.config.OwnerJobs) > 0 and table.HasValue(zcrga.config.OwnerJobs, team.GetName(LocalPlayer():Team())) then
				cam.Start3D2D(self:LocalToWorld(Vector(20, -30, 74)), self:LocalToWorldAngles(Angle(0, 0, 90)), 0.1)
					if self:AddMoneyButton(LocalPlayer()) then

						draw.RoundedBox(5, -80 , -20, 160, 40,Color(125,200,125))
					else
						draw.RoundedBox(5, -80 , -20, 160, 40,Color(125,125,125))
					end
					draw.SimpleText("+ " .. zcrga.config.TransferAmount .. zcrga.config.Currency, "zcrga_coinpusher_button", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24d29d357f25d0e3dbcd1d408ccea85b467c8e0190b63644784fca3979a920a4


					if self:RemoveMoneyButton(LocalPlayer()) then
						draw.RoundedBox(5, -80 , 30, 160, 40,Color(200,125,125))
					else
						draw.RoundedBox(5, -80 , 30, 160, 40,Color(125,125,125))
					end
					draw.SimpleText("- " .. zcrga.config.TransferAmount .. zcrga.config.Currency, "zcrga_coinpusher_button", 0, 50, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


				cam.End3D2D()
			end
		end
	end
end

function ENT:Draw()
	self:DrawModel()

	if zcrga.f.InDistance(self:GetPos(), LocalPlayer():GetPos(), 300) then
		self:Draw_Info()
		self:MachineLight01()
		//self:MachineLight02()
	end
end

function ENT:MachineLight02()
	local dlight01 = DynamicLight(self:EntIndex())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24d29d357f25d0e3dbcd1d408ccea85b467c8e0190b63644784fca3979a920a4

	if (dlight01) then
		local pos = self:GetPos() + self:GetUp() * 65 + self:GetForward() * 10
		dlight01.pos = pos
		dlight01.r = 255
		dlight01.g = 100
		dlight01.b = 0
		dlight01.brightness = 1
		dlight01.Decay = 1000
		dlight01.Size = 256
		dlight01.DieTime = CurTime() + 1
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 049b4e254ea84b6bbd8714673e122cc1e8af2018030f6cc079898e33e35e9c0c

function ENT:MachineLight01()
	local dlight01 = DynamicLight(self:EntIndex())

	if (dlight01) then
		local pos = self:GetPos() + self:GetUp() * 60 + self:GetForward() * -15
		dlight01.pos = pos
		dlight01.r = 255
		dlight01.g = 175
		dlight01.b = 255
		dlight01.brightness = 1
		dlight01.Decay = 1000
		dlight01.Size = 256
		dlight01.DieTime = CurTime() + 1
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

function ENT:Initialize()
	if (zcrga.config.NoMusic == false) then
		self:PlayMachineMusic()
	end
end

function ENT:PlayMachineMusic()
	sound.PlayFile("sound/zap/coinpusher/arcade_game_8bit_style.mp3", "3d", function(station)
		if (IsValid(station)) then
			self.bonusSound = station
			self.bonusSound:SetPos(self:GetPos() + self:GetUp() * 5 + self:GetForward() * -15)
			self.bonusSound:Set3DFadeDistance(100, 500)
			self.bonusSound:SetVolume(0.2)
			self.bonusSound:EnableLooping(true)
			station:Play()
		end
	end)
end

function ENT:Think()
	self:SetNextClientThink(CurTime())

	if self.bonusSound ~= nil && IsValid(self.bonusSound) then
		self.bonusSound:SetPos(self:GetPos() + self:GetUp() * 10 + self:GetForward() * -45)
	end

	return true
end

function ENT:OnRemove()
	if self.bonusSound ~= nil && IsValid(self.bonusSound) then
		self.bonusSound:Stop()
	end
end
