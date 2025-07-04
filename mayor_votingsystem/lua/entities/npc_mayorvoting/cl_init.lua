include("shared.lua")

function ENT:Initialize()	
	self.AutomaticFrameAdvance = true
	-- Initialize all variables safely
	self.GlowTime = 0
	self.FloatOffset = 0
	self.ParticleTime = 0
	self.LastThink = CurTime()
end

-- Safety check function
function ENT:InitializeVars()
	if not self.GlowTime then self.GlowTime = 0 end
	if not self.FloatOffset then self.FloatOffset = 0 end
	if not self.ParticleTime then self.ParticleTime = 0 end
	if not self.LastThink then self.LastThink = CurTime() end
end

function ENT:Draw()
	-- Safety check for variables
	self:InitializeVars()
	
	self:DrawModel()

	local pos = self:GetPos()
	local ang = self:GetAngles()
	
	-- Floating animation - safe calculation
	local currentTime = CurTime()
	self.FloatOffset = math.sin(currentTime * 2) * 3
	pos.z = pos.z + 15 + self.FloatOffset
	
	-- Glow effect animation - daha az yoğun
	self.GlowTime = self.GlowTime + (currentTime - self.LastThink)
	self.LastThink = currentTime
	local glowAlpha = math.sin(self.GlowTime * 2) * 30 + 80 -- Daha az parlak (100+155 yerine 30+80)
	
	-- Particle effect timer - safe increment
	self.ParticleTime = self.ParticleTime + FrameTime()
	
	-- Font check and text setup
	local title = "Baskan Sekreteri"
	if VOTING and VOTING.Settings and VOTING.Settings.NPCTitleText then
		title = VOTING.Settings.NPCTitleText
	end
	
	-- Safe font usage
	local fontName = "DermaLarge"
	if surface.GetTextSize then
		surface.SetFont(fontName)
		local tw, th = surface.GetTextSize(title)

		-- Text positioning
		ang:RotateAroundAxis(ang:Forward(), 90)
		local textang = ang
		textang:RotateAroundAxis(textang:Right(), currentTime * -90)

		-- 3D2D Text rendering with error protection
		pcall(function()
			cam.Start3D2D(pos + ang:Right() * -40, textang, 0.3)
				-- Background
				surface.SetDrawColor(0, 0, 0, 220)
				surface.DrawRect(-tw * 0.6, -200, tw * 1.2, th + 60)
				
				-- Daha az parlak border
				local glowColor = Color(100, 150, 255)
				if VOTING and VOTING.Theme and VOTING.Theme.GlowColor then
					glowColor = VOTING.Theme.GlowColor
				end
				surface.SetDrawColor(glowColor.r, glowColor.g, glowColor.b, math.min(glowAlpha, 120)) -- Max 120 alpha
				surface.DrawOutlinedRect(-tw * 0.6 - 1, -201, tw * 1.2 + 2, th + 62) -- Daha ince çerçeve
				
				-- Main title text
				draw.DrawText(title, fontName, 0, -190, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
				
				-- Subtitle
				local subtitle = "Secime Katil"
				draw.DrawText(subtitle, "DermaDefaultBold", 0, -190 + th + 10, Color(200, 200, 255, 255), TEXT_ALIGN_CENTER)
				
				-- Status indicator
				local statusText = "Aday Kabul Ediliyor"
				local statusColor = Color(100, 255, 100)
				
				if VOTING then
					if VOTING.InProgress then
						statusText = "Secim Devam Ediyor"
						statusColor = Color(255, 100, 100)
					elseif VOTING.AboutToBegin then
						statusText = "Secim Baslayacak"
						statusColor = Color(255, 255, 100)
					end
				end
				
				draw.DrawText(statusText, "DermaDefault", 0, -190 + th + 35, statusColor, TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end)
	end
	
	-- Particle effects with safety check
	if VOTING and VOTING.Settings and VOTING.Settings.GlowEffect then
		self:DrawParticleEffects(pos)
	end
end

function ENT:DrawParticleEffects(pos)
	-- Safety check for variables
	if not self.ParticleTime then self.ParticleTime = 0 end
	
	-- Daha az ve kontrollü parçacık efekti
	local particleCount = 3 -- 8'den 3'e düşürdük
	local radius = 15 -- 30'dan 15'e düşürdük
	
	for i = 1, particleCount do
		local angle = (360 / particleCount) * i + (self.ParticleTime * 30) -- Daha yavaş hareket
		local x = pos.x + math.cos(math.rad(angle)) * radius
		local y = pos.y + math.sin(math.rad(angle)) * radius
		local z = pos.z + math.sin(self.ParticleTime * 1.5 + i) * 5 -- Daha az dikey hareket
		
		local particlePos = Vector(x, y, z)
		
		-- Çok daha az sıklıkta efekt
		if util and util.Effect then
			pcall(function()
				if math.random(1, 100) == 1 then -- 20'den 100'e çıkardık (çok daha az)
					local effectData = EffectData()
					effectData:SetOrigin(particlePos)
					effectData:SetMagnitude(0.2) -- Daha küçük efekt
					effectData:SetScale(0.5) -- Daha küçük scale
					effectData:SetRadius(1) -- Daha küçük radius
					
					util.Effect("sparks", effectData)
				end
			end)
		end
	end
end

-- Add interaction hint with better error handling
hook.Add("HUDPaint", "VOTING_NPCHint", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local trace = ply:GetEyeTrace()
	if not trace or not IsValid(trace.Entity) then return end
	
	if trace.Entity:GetClass() == "npc_mayorvoting" then
		local distance = ply:GetPos():Distance(trace.Entity:GetPos())
		
		if distance <= 150 then -- Interaction range
			local scrW, scrH = ScrW(), ScrH()
			local centerX, centerY = scrW / 2, scrH / 2
			
			-- Interaction text background
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(centerX - 150, centerY + 50, 300, 80)
			
			-- Border with safe color access
			local borderColor = Color(100, 150, 255)
			if VOTING and VOTING.Theme and VOTING.Theme.BorderColor then
				borderColor = VOTING.Theme.BorderColor
			end
			surface.SetDrawColor(borderColor)
			surface.DrawOutlinedRect(centerX - 150, centerY + 50, 300, 80)
			
			-- Main interaction text
			draw.DrawText("E tuşuna basarak seçime katıl", "DermaDefault", centerX, centerY + 65, color_white, TEXT_ALIGN_CENTER)
			
			-- Cost information with safety check
			local candidateCost = 0
			if VOTING and VOTING.CandidateCost then
				candidateCost = VOTING.CandidateCost
			end
			
			if candidateCost > 0 then
				local costText = "Maliyet: " .. candidateCost .. "₺"
				if DarkRP and DarkRP.formatMoney then
					costText = "Maliyet: " .. DarkRP.formatMoney(candidateCost)
				end
				draw.DrawText(costText, "DermaDefault", centerX, centerY + 85, Color(255, 255, 100), TEXT_ALIGN_CENTER)
			end
		end
	end
end)