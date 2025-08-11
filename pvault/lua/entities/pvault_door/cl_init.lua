include("shared.lua")

function ENT:Initialize()
	self.room = ClientsideModel("models/freeman/vault/vault_interior.mdl", RENDERGROUP_OPAQUE)
	self.room:SetPos(self:GetPos()+(self.room:GetUp()*-42.5))
	self.room:SetAngles(self:GetAngles())
	
	self.room:SetNoDraw(true)
	for i=0, self:GetMoneybags() do
		self.room:SetBodygroup(i, 1)
	end

	perfectVault.Walls[self:EntIndex()] = self
end
function ENT:PostData()
end

function ENT:Think()
	if not IsValid(self.room) then return end
	self.room:SetPos(self:GetPos()+(self.room:GetUp()*-42.5))
	self.room:SetAngles(self:GetAngles())
end

function ENT:OnRemove()
	if IsValid(self.room) then self.room:Remove() end
	perfectVault.Walls[self:EntIndex()] = nil
end

-- huge credit to CodeBlue for helping me out with this, he's a true good guy
local stencilcolor = Color(255,255,255,1)
function ENT:Draw()
	self:DrawModel()
	if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 250000 then return end

	-- We can piggyback off the distance check to only request the entitys data when it's needed :D
	if (not self.data) and (not perfectVault.Cooldown.Check(self:EntIndex(), 5)) then
		perfectVault.Core.RequestConfigData(self)
		return
	end

	if not self.data then return end

	-- Basic setups
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	Ang:RotateAroundAxis(Ang:Up(), 90+30)
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	local centerx, centery = -300, -300

	cam.Start3D2D(Pos + Ang:Up()*-11 + Ang:Forward()*-40, Ang, 0.07)
		draw.RoundedBox(0, centerx-300, centery, 600, 405, Color(0, 0, 0, 200))
		draw.RoundedBox(0, centerx-300, centery, 600, 20, Color(0, 0, 0, 200))
		draw.SimpleText(string.upper(perfectVault.Translation.Vault.Title), "_pvault120", centerx, centery+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		-- Money Bag Icon
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(perfectVault.Icons[1].mat)
		surface.DrawTexturedRect(centerx-290, centery+130, 55, 55)
		-- Bag Count
		draw.SimpleText(string.format(perfectVault.Translation.Vault.Bags..": %s/%s", self:GetMoneybags(), self.data.general.bagCount), "_pvault70", centerx-220, centery+120, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		-- Police Icon
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(perfectVault.Icons[3].mat)
		surface.DrawTexturedRect(centerx-290, centery+200, 55, 55)
		-- Police
		local cops = 0
		for k, v in pairs(player.GetAll()) do
			if v:isCP() then cops = cops + 1 continue end
			if perfectVault.Config.Government[v:Team()] then cops = cops + 1 continue end
		end
		if player.GetCount()*self.data.general.neededCops <= cops then
			draw.SimpleText(perfectVault.Translation.Vault.Government..": "..perfectVault.Translation.Vault.GovernmentEnough, "_pvault70", centerx-220, centery+190, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(perfectVault.Translation.Vault.Government..": "..perfectVault.Translation.Vault.GovernmentNotEnough, "_pvault70", centerx-220, centery+190, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		-- Locked Icon
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(perfectVault.Icons[2].mat)
		surface.DrawTexturedRect(centerx-290, centery+270, 55, 55)
		-- Locked
		if self:GetLocked() then
			draw.SimpleText(string.format(perfectVault.Translation.Vault.Locked..": %s", perfectVault.Translation.Vault.LockedYes), "_pvault70", centerx-220, centery+260, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(string.format(perfectVault.Translation.Vault.Locked..": %s", perfectVault.Translation.Vault.LockedNo), "_pvault70", centerx-220, centery+260, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		-- Police Icon
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(perfectVault.Icons[4].mat)
		surface.DrawTexturedRect(centerx-290, centery+340, 55, 55)
		-- Police
		if self:GetAlarm() then
			draw.SimpleText(string.format(perfectVault.Translation.Vault.Alarm..": %s", perfectVault.Translation.Vault.AlarmOn), "_pvault70", centerx-220, centery+330, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(string.format(perfectVault.Translation.Vault.Alarm..": %s", perfectVault.Translation.Vault.AlarmOff), "_pvault70", centerx-220, centery+330, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	cam.End3D2D()

	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), -90)
	Ang:RotateAroundAxis(Ang:Forward(), 13)

	local centerx, centery = 0, -765

	cam.Start3D2D(Pos, Ang, 0.07)
		if self:GetCooldownEnd() > CurTime() then
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 100, Color(0, 0, 0, 200))
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 20, Color(0, 0, 0))
			draw.SimpleText(string.format(perfectVault.Translation.Vault.CooldownEnds, math.Round(self:GetCooldownEnd()- CurTime())), "_pvault70", centerx+25, centery+110, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif self:GetOpenTimeLeft() > CurTime() then
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 100, Color(0, 0, 0, 200))
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 20, Color(0, 0, 0))
			draw.SimpleText(string.format(perfectVault.Translation.Vault.VaultCloseTimer, math.Round(self:GetOpenTimeLeft()- CurTime())), "_pvault70", centerx+25, centery+110, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif self:GetAlarm() then
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 100, Color(0, 0, 0, 200))
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 20, Color(0, 0, 0))
			draw.SimpleText(perfectVault.Translation.Vault.VaultAlarmActive, "_pvault70", centerx+25, centery+110, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		elseif player.GetCount() < tonumber(self.data.general.plyNeeded) then
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 100, Color(0, 0, 0, 200))
			draw.RoundedBox(0, centerx-470, centery+50, 1000, 20, Color(0, 0, 0))
			draw.SimpleText(perfectVault.Translation.Vault.NoPlayers, "_pvault70", centerx+25, centery+110, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end