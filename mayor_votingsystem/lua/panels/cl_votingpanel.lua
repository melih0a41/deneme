/*---------------------------------------------------------
  Enhanced PlayerVotingPanel with Modern Effects
---------------------------------------------------------*/
local PlayerVotingPanel = {}

function PlayerVotingPanel:Init()
	self:SetDrawBackground(false)
	self:SetDrawBorder(false)
	self:SetSize(380, 90) -- Biraz daha büyük panel
	self.CurrentWidth = 380
	self.CurrentHeight = 90
	self.CurrentAlpha = 0
	self.HoverAlpha = 0
	self.PulseAlpha = 0
	self.PulseDirection = 1
	self.AnimationProgress = 0
	
	-- Renkler
	self.BackColor = VOTING.Theme.ControlColor
	self.TextColor = VOTING.Theme.PlayerNameColor
	self.HoverColor = VOTING.Theme.ControlHoverColor
	self.SelectedColor = VOTING.Theme.ControlSelectedColor
	self.VoteCountColor = VOTING.Theme.VoteCountColor
	self.GlowColor = VOTING.Theme.GlowColor
	
	self.Hovering = false
	self.IsSelected = false
	
	-- UI Elementleri
	self.HeaderLbl = vgui.Create("DLabel", self)
	self.HeaderLbl:SetFont("VotingPlayerNameFont")
	self.HeaderLbl:SetColor(self.TextColor)
	self.HeaderLbl:SetContentAlignment(5) -- Ortala
	
	self.VoteLbl = vgui.Create("DLabel", self)
	self.VoteLbl:SetFont("VotingCountFont")
	self.VoteLbl:SetColor(self.VoteCountColor)
	self.VoteLbl:SetContentAlignment(5) -- Ortala
	
	self.PlayerIcon = vgui.Create("VotingPlayerIcon", self)
	self.PlayerIcon:SetSize(75, 75) -- Daha büyük ikon
	
	-- Hover efekti için timer
	self.HoverTimer = 0
end

function PlayerVotingPanel:SetNoActionEnbaled(results)
	self.NoAction = true
	self.HoverColor = Color(50, 50, 50, 155)
	self.AlphaFade = 255
	self.StartAlphaFade = true
	self.HeaderLbl:SetColor(Color(120, 120, 120, 180))
	self.VoteLbl:SetColor(Color(120, 120, 120, 180))
	if results then
		self.PlayerIcon:SetVisible(false)
	end
end

function PlayerVotingPanel:SetPlayer(ply)
	if not IsValid(ply) then 
		self:SetNoActionEnbaled() 
		return 
	end
	
	-- İsim uzunluğunu kontrol et
	local name = ply:Nick()
	if string.len(name) > 18 then
		name = string.sub(name, 1, 15) .. "..."
	end
	
	self.HeaderLbl:SetText(name)
	self.HeaderLbl:SizeToContents()
	self.CurrentPlayer = ply
	self.CurrentVotes = 0
	self.VoteLbl:SetText("0")
	self.VoteLbl:SizeToContents()
	
	-- Player model ayarları
	self.PlayerIcon:InvalidateLayout(true)
	self.PlayerIcon:SetModel(ply:GetModel())
	self.PlayerIcon:SetToolTip(ply:Nick())
end

function PlayerVotingPanel:GetPlayer()
	if IsValid(self.CurrentPlayer) then 
		return self.CurrentPlayer
	else 
		self:SetNoActionEnbaled() 
		return nil 
	end
end

function PlayerVotingPanel:SetColor(color)
	if not IsColor(color) then return end
	self.BackColor = color
	self.GlowColor = Color(color.r, color.g, color.b, 100)
end

function PlayerVotingPanel:GetColor()
	return self.BackColor
end

function PlayerVotingPanel:IncreaseVote(num)
	self.CurrentVotes = (self.CurrentVotes + num)
	self.VoteLbl:SetText(tostring(self.CurrentVotes))
	self.VoteLbl:SizeToContents()
	
	-- Oy artışı efekti
	self.CurrentAlpha = 255
	self.PulseAlpha = 255
	
	-- Ses efekti
	if VOTING.Settings.MenuSounds then
		surface.PlaySound(VOTING.Settings.VoteCastSound or "buttons/button24.wav")
	end
end

function PlayerVotingPanel:SetText(text)
	self.HeaderLbl:SetText(text)
	self.HeaderLbl:SizeToContents()
end

function PlayerVotingPanel:PerformLayout()
	-- Player ikonu sol üstte
	self.PlayerIcon:SetPos(8, 8)

	-- İsim etiketini ortala (ikon ile oy sayısı arasında)
	local nameX = self.PlayerIcon:GetWide() + 20
	local nameWidth = self:GetWide() - nameX - 80
	self.HeaderLbl:SetPos(nameX, 15)
	self.HeaderLbl:SetWide(nameWidth)

	-- Oy sayısını sağa yasla
	self.VoteLbl:SetPos(self:GetWide() - 70, 10)
	self.VoteLbl:SetWide(60)
end

function PlayerVotingPanel:Paint(w, h)
	-- Animasyon değerlerini güncelle
	self.AnimationProgress = math.Approach(self.AnimationProgress, 1, FrameTime() * 3)
	
	-- Hover animasyonu
	if self.Hovering then
		self.HoverAlpha = math.Approach(self.HoverAlpha, 255, FrameTime() * 400)
	else
		self.HoverAlpha = math.Approach(self.HoverAlpha, 0, FrameTime() * 400)
	end
	
	-- Pulse efekti
	if VOTING.Settings.PulseEffect then
		self.PulseAlpha = self.PulseAlpha + (FrameTime() * 200 * self.PulseDirection)
		if self.PulseAlpha >= 100 then
			self.PulseDirection = -1
		elseif self.PulseAlpha <= 0 then
			self.PulseDirection = 1
		end
	end
	
	-- Ana panel arka planı
	local bgColor = self.BackColor
	if self.StartAlphaFade then
		self.AlphaFade = math.Approach(self.AlphaFade, 50, FrameTime() * 400)
		bgColor = Color(bgColor.r, bgColor.g, bgColor.b, self.AlphaFade)
	end
	
	-- Gradient arka plan
	self:DrawGradientRect(0, 0, w, h, bgColor, Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20, bgColor.a))
	
	-- Hover efekti
	if self.HoverAlpha > 0 and not self.NoAction then
		local hoverColor = Color(self.HoverColor.r, self.HoverColor.g, self.HoverColor.b, self.HoverAlpha * 0.7)
		surface.SetDrawColor(hoverColor)
		surface.DrawRect(0, 0, w, h)
	end
	
	-- Seçili efekti
	if self.IsSelected then
		surface.SetDrawColor(self.SelectedColor)
		surface.DrawRect(0, 0, w, h)
		
		-- Seçili çerçeve
		surface.SetDrawColor(Color(255, 255, 255, 200))
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	
	-- Glow efekti
	if VOTING.Settings.GlowEffect and self.CurrentVotes > 0 then
		local glowAlpha = math.sin(CurTime() * 3) * 50 + 100
		surface.SetDrawColor(Color(self.GlowColor.r, self.GlowColor.g, self.GlowColor.b, glowAlpha))
		surface.DrawOutlinedRect(-2, -2, w + 4, h + 4)
	end
	
	-- Oy sayısı arka planı
	local voteBoxX = w - 75
	local voteBoxW = 70
	surface.SetDrawColor(Color(0, 0, 0, 150))
	surface.DrawRect(voteBoxX, 0, voteBoxW, h)
	
	-- Oy artışı efekti
	self.CurrentAlpha = math.Approach(self.CurrentAlpha, 0, FrameTime() * 200)
	if self.CurrentAlpha > 0 then
		surface.SetDrawColor(Color(100, 255, 100, self.CurrentAlpha))
		surface.DrawRect(voteBoxX, 0, voteBoxW, h)
	end
	
	-- Alt çizgi (modern görünüm için)
	surface.SetDrawColor(VOTING.Theme.BorderColor)
	surface.DrawRect(0, h - 2, w, 2)
end

-- Gradient çizim fonksiyonu
function PlayerVotingPanel:DrawGradientRect(x, y, w, h, topColor, bottomColor)
	local gradientSteps = 10
	local stepHeight = h / gradientSteps
	
	for i = 0, gradientSteps - 1 do
		local alpha = i / (gradientSteps - 1)
		local r = Lerp(alpha, topColor.r, bottomColor.r)
		local g = Lerp(alpha, topColor.g, bottomColor.g)
		local b = Lerp(alpha, topColor.b, bottomColor.b)
		local a = Lerp(alpha, topColor.a, bottomColor.a)
		
		surface.SetDrawColor(r, g, b, a)
		surface.DrawRect(x, y + (i * stepHeight), w, stepHeight + 1)
	end
end

function PlayerVotingPanel:OnCursorEntered()
	self.Hovering = true
	if not self.NoAction and not self.IsSelected and not LocalPlayer().HasVoted then
		-- Hover ses efekti
		if VOTING.Settings.MenuSounds then
			surface.PlaySound(VOTING.Settings.HoverSound or "ui/buttonrollover.wav")
		end
	end
end

function PlayerVotingPanel:OnCursorExited()
	self.Hovering = false
end

function PlayerVotingPanel:ToggleSelect(select)
	self.IsSelected = select
	if select then
		-- Seçim animasyonu başlat
		self.CurrentAlpha = 255
	end
end

function PlayerVotingPanel:ColorWithCurrentAlpha(color)
	return Color(color.r, color.g, color.b, self.CurrentAlpha)
end

-- Panel'i kaydet
derma.DefineControl("PlayerVotingPanel", "Enhanced player voting panel for mayor elections", PlayerVotingPanel, "DImageButton")

/*---------------------------------------------------------
  End Enhanced PlayerVotingPanel
---------------------------------------------------------*/