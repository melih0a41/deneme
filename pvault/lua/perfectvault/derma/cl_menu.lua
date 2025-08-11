net.Receive("pvault_ui", function()
	local vault = net.ReadEntity()
	local unlockCount = 0

	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrH()*0.6, ScrH()*0.5)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
		draw.RoundedBox(0, 0, 0, w, 25, Color(0, 0, 0, 200))
	end

	local shell = vgui.Create("DPanel", frame)
	shell:SetSize(frame:GetWide()-10, frame:GetTall()-35)
	shell:SetPos(5, 30)
	shell.Paint = function() end

	local side = vgui.Create("DPanel", shell)
	side:SetPos(0, 0)
	side:SetSize(shell:GetWide()/5, shell:GetTall())
	side.Paint = function(self, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(0, 255, 0))
	end

	local guessBar = vgui.Create("DPanel", side)
	guessBar:SetSize(side:GetWide(), side:GetTall())
	guessBar:SetPos(0, 0)
	guessBar.barPos = 0
	guessBar.barSize = 0
	guessBar.whiteLoc = 0
	guessBar.Paint = function(self, w, h)
		if !self.whiteStopped then
			self.whiteLoc = ((h-15)/2*math.sin(CurTime()*perfectVault.Config.DermaBarSpeed))+(h-10)/2
		end
		draw.RoundedBox(0, 5, 0, w-10, h, Color(50, 50, 50))
		draw.RoundedBox(0, 5, self.barPos, w-10, self.barSize, Color(0, 155, 155))
		draw.RoundedBox(0, 0, self.whiteLoc, w, 10, Color(255, 255, 255))
	end
	function guessBar:NewBar()
		self.barSize = math.random(self:GetTall()*perfectVault.Config.DermaLevelMin, self:GetTall()*perfectVault.Config.DermaLevelMax)
		self.barPos = math.random(0, self:GetTall()-self.barSize)
		self.whiteStopped = false
	end
	guessBar:NewBar()

	local main = vgui.Create("DPanel", shell)
	main:SetPos(shell:GetWide()/5, 0)
	main:SetSize((shell:GetWide()/5)*4, shell:GetTall())
	main.Paint = function() end

	local locks = vgui.Create("DModelPanel", main)
	locks:SetModel("models/freeman/owain_pickable_lock.mdl")
	locks:SetPos(0, 0)
	locks:SetSize(main:GetWide() + (main:GetWide()/(main:GetWide()*2)), main:GetTall()/4*3)
	locks:SetFOV(15)
	locks:SetCamPos(Vector(41.296387, 75.021957, 12.896591))
	locks:SetLookAt(Angle(0.075521, -0.000010, 0.026477))
	locks:SetLookAng(Angle(8.564, -118.831, 0.000))
	function locks:LayoutEntity( ) self:RunAnimation() end
	locks:GetEntity():SetSequence("idle")
	locks:GetEntity():SetPlaybackRate(1)
	locks:SetAnimated(true)
	locks:SetAnimSpeed(1)
	function locks:GiveAnimation(seq)
		local ent = self:GetEntity()
		local seq = ent:LookupSequence(seq)
		ent:SetSequence(seq)
		ent:SetCycle(0)
	end

	local stopLocation = vgui.Create("DButton", main)
	stopLocation:SetSize(main:GetWide()-10, (main:GetTall()/4)/4*3-5)
	stopLocation:SetPos(5, (main:GetTall()/4*3))
	stopLocation:SetText("")
	stopLocation.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(55, 55, 55))
		draw.SimpleText(perfectVault.Translation.Vault.DermaUnlock, "_pvault_derma", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	--perfectVault.Translation.Vault.DermaUnlock
	stopLocation.DoClick = function()
		if guessBar.whiteStopped then return end
		guessBar.whiteStopped = true

		if guessBar.whiteLoc > guessBar.barPos and guessBar.whiteLoc + 10 < guessBar.barPos + guessBar.barSize then
			unlockCount = unlockCount + 1
			if unlockCount == 1 then
				locks:GiveAnimation("pin1_unlock")
				if perfectVault.Config.DermaSounds then
					local UnlockSound = CreateSound(LocalPlayer(), Sound(perfectVault.Config.DermaSoundsDir))
					UnlockSound:SetSoundLevel(52)
					UnlockSound:PlayEx(1, 100)
				end
			elseif unlockCount == 2 then
				locks:GiveAnimation("pin2_unlock")
				if perfectVault.Config.DermaSounds then
					local UnlockSound = CreateSound(LocalPlayer(), Sound(perfectVault.Config.DermaSoundsDir))
					UnlockSound:SetSoundLevel(52)
					UnlockSound:PlayEx(1, 100)
				end
			elseif unlockCount == 3 then
				locks:GiveAnimation("pin3_unlock")
				if perfectVault.Config.DermaSounds then
					local UnlockSound = CreateSound(LocalPlayer(), Sound(perfectVault.Config.DermaSoundsDir))
					UnlockSound:SetSoundLevel(52)
					UnlockSound:PlayEx(1, 100)
				end
				timer.Simple(1, function()
					if !IsValid(frame) then return end
					locks:GiveAnimation("tumbler_rotate")
					timer.Simple(2, function()
						if !IsValid(frame) then return end
						net.Start("pvault_lockpick_pass")
							net.WriteEntity(vault)
						net.SendToServer()
						frame:Close()
					end)
				end)
			end

			if unlockCount != 3 then
				timer.Simple(1, function()
					if !IsValid(frame) then return end
					locks:GiveAnimation("pin"..unlockCount.."_idleopen")
					guessBar:NewBar()
				end)
			end
		else
			net.Start("pvault_lockpick_fail")
				net.WriteEntity(vault)
			net.SendToServer()
			frame:Close()
		end
	end

	local closeButton = vgui.Create("DButton", main)
	closeButton:SetSize(main:GetWide()-10, (main:GetTall()/4)/4)
	closeButton:SetPos(5, (main:GetTall()/4*3)+(main:GetTall()/4)/4*3)
	closeButton:SetText("")
	closeButton.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(55, 55, 55))
		draw.SimpleText(perfectVault.Translation.Vault.DermaClose, "_pvault_derma_small", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeButton.DoClick = function()
		frame:Close()
	end
end)


net.Receive("pvault_ui_sell", function()
	local npc = net.ReadEntity()
	local unlockCount = 0

	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrH()*0.6, ScrH()*0.4)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
		draw.RoundedBox(0, 0, 0, w, 25, Color(0, 0, 0, 200))
	end

	local shell = vgui.Create("DPanel", frame)
	shell:SetSize(frame:GetWide()-10, frame:GetTall()-35)
	shell:SetPos(5, 30)
	shell.Paint = function() end

	local info = vgui.Create("DPanel", shell)
	info:SetSize(shell:GetWide(), shell:GetTall()/4*2)
	info:SetPos(0, 0)
	info.Paint = function(self, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
		draw.SimpleText(perfectVault.Translation.NPC.InfoHeader, "_pvault_derma_small", w/2, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(perfectVault.Translation.NPC.InfoHeader2, "_pvault_derma_small", w/2, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(perfectVault.Translation.NPC.CurrentlyHolding, "_pvault_derma_small", w/2, h/2-10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(DarkRP.formatMoney(npc:GetHolding()), "_pvault_derma", w/2, h/2+10, Color(155, 255, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local shares = vgui.Create("DPanel", shell)
	shares:SetSize(shell:GetWide(), shell:GetTall()/4)
	shares:SetPos(0, shell:GetTall()/4*2)
	shares.Paint = function(self, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(0, 255, 0))
		draw.SimpleText(perfectVault.Translation.NPC.BankerCut, "_pvault_derma_small", 5, 0, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(100-math.Round(100*self.Slider:GetSlideX()).."%", "_pvault_derma_small", 5, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(DarkRP.formatMoney(math.Round(npc:GetHolding()-(npc:GetHolding()*self.Slider:GetSlideX()))), "_pvault_derma_small", 5, h, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

		draw.SimpleText(perfectVault.Translation.NPC.YourCut, "_pvault_derma_small", w-5, 0, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		draw.SimpleText(math.Round(100*self.Slider:GetSlideX()).."%", "_pvault_derma_small", w-5, h/2, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText(DarkRP.formatMoney(math.Round(npc:GetHolding()*self.Slider:GetSlideX())), "_pvault_derma_small", w-5, h, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end

	shares.Slider = vgui.Create("DSlider", shares)
	shares.Slider:SetPos(shares:GetWide()*0.15, shares:GetTall()/5)
	shares.Slider:SetSize(shares:GetWide()*0.7, shares:GetTall()/2)
	shares.Slider.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, h/2+8, w, 2, Color(155, 155, 155))
	end

	local buttons = vgui.Create("DPanel", shell)
	buttons:SetSize(shell:GetWide(), shell:GetTall()/4)
	buttons:SetPos(0, shell:GetTall()/4*3)
	buttons.Paint = function() end

	local makeOffer = vgui.Create("DButton", buttons)
	makeOffer:SetPos(0, 0)
	makeOffer:SetSize(buttons:GetWide(), buttons:GetTall()/4*3-5)
	makeOffer:SetText("")
	makeOffer.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(55, 55, 55))
		draw.SimpleText(perfectVault.Translation.NPC.MakeOffer, "_pvault_derma_small", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	makeOffer.DoClick = function()
		net.Start("pvault_ui_makeoffer")
			net.WriteEntity(npc)
			net.WriteFloat(1-shares.Slider:GetSlideX())
		net.SendToServer()

		frame:Close()
	end

	local cancel = vgui.Create("DButton", buttons)
	cancel:SetPos(0, buttons:GetTall()/4*3)
	cancel:SetSize(buttons:GetWide(), buttons:GetTall()/4)
	cancel:SetText("")
	cancel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(55, 55, 55))
		draw.SimpleText(perfectVault.Translation.NPC.Cancel, "_pvault_derma_smaller", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	cancel.DoClick = function()
		frame:Close()
	end
end)