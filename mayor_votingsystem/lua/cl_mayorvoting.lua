--Mayor Voting Main Client - Enhanced Edition
if VOTING then VOTING = VOTING
else VOTING = {} end

VOTING.CurrentHeight = 50
VOTING.AnimationTime = 0
VOTING.BackgroundAlpha = 0
VOTING.TitleAlpha = 0
VOTING.ParticleTime = 0

include('cl_votingfonts.lua')
include('sh_votingconfig.lua')
include('panels/cl_votingpanel.lua')
include('panels/cl_playericon.lua')

function VOTING.OpenVoteScreen(settings)
	if not LocalPlayer() then return end
	VOTING.MainWindowOpen = true
	
	if !VotingMainWindow then
		VotingMainWindow = vgui.Create("DFrame")
		VotingMainWindow:SetSize(ScrW(), 350) -- Daha büyük pencere
		VotingMainWindow:SetDraggable(false)
		VotingMainWindow:ShowCloseButton(false) -- X butonunu kapat
		VotingMainWindow:SetSizable(false) -- Boyutlandırmayı kapat
		VotingMainWindow:SetDeleteOnClose(false) -- Kapanışta silmeyi kapat
		VotingMainWindow:SetTitle("") -- Başlığı kaldır
		VotingMainWindow:SetBackgroundBlur(true)
		VotingMainWindow:SetZPos(9999)
		VotingMainWindow:SetDrawOnTop(true)
		VotingMainWindow.VoteTime = settings.time
		VOTING.CanCloseTime = CurTime() + settings.time
		VotingMainWindow.Paint = VOTING.PaintMainWindow
		VOTING.VoteManager = {}
		
		-- Başlık çubuğunu tamamen gizle ve DarkRP çakışmasını önle
		VotingMainWindow.PerformLayout = function(self)
			-- DarkRP vote panel kontrolü
			if GAMEMODE and GAMEMODE.IsVoteActive and GAMEMODE:IsVoteActive() then
				self:SetVisible(false)
				return
			else
				self:SetVisible(true)
			end
			
			-- Başlık çubuğunu 0 yüksekliğe ayarla
			if self.lblTitle then
				self.lblTitle:SetVisible(false)
				self.lblTitle:SetSize(0, 0)
			end
			
			-- Tüm butonları gizle
			if self.btnClose then self.btnClose:SetVisible(false) end
			if self.btnMaxim then self.btnMaxim:SetVisible(false) end  
			if self.btnMinim then self.btnMinim:SetVisible(false) end
			
			-- Panel boyutunu ayarla (başlık çubuğu olmadan)
			if self.m_pnlContents then
				self.m_pnlContents:SetPos(0, 0)
				self.m_pnlContents:SetSize(self:GetWide(), self:GetTall())
			end
		end
		
		-- Animasyon başlangıç değerleri
		VOTING.AnimationTime = 0
		VOTING.BackgroundAlpha = 0
		VOTING.TitleAlpha = 0
		
		-- Voting panels list
		local VotingPanelsList = vgui.Create("DPanelList", VotingMainWindow)
		VotingPanelsList:SetPadding(0)
		VotingPanelsList:SetSpacing(8) -- Daha fazla boşluk
		VotingPanelsList:SetAutoSize(true)
		VotingPanelsList:SetNoSizing(false)
		VotingPanelsList:EnableHorizontal(true)
		VotingPanelsList:EnableVerticalScrollbar(false)
		VotingPanelsList.Paint = function() end
		VotingPanelsList:SetWide(ScrW() - (ScrW() / 8))
		VotingPanelsList:SetPos((ScrW() / 8) / 2, 90) -- Biraz daha aşağı
		
		-- Create voting panels with staggered animation
		for k, v in pairs(settings.Candidates) do
			local VotingPanel = vgui.Create("PlayerVotingPanel")
			
			if IsValid(v.player) then
				VotingPanel:SetPlayer(v.player)
				VotingPanel:SetColor(VOTING.NewVotingPanelColor())
				VotingPanel.DoClick = function()
					if LocalPlayer().HasVoted then return end
					local player = VotingPanel:GetPlayer()
					if player then
						LocalPlayer():ConCommand("mayor_vote " .. k)
						VotingPanel:ToggleSelect(true)
						LocalPlayer().HasVoted = true
						
						-- Seçim efekti
						if VOTING.Settings.MenuSounds then
							surface.PlaySound("buttons/button9.wav")
						end
						
						if VOTING.Settings.ForceMouseCursor then 
							gui.EnableScreenClicker(false) 
						end
					end
				end
			else
				VotingPanel:SetColor(Color(100, 100, 100))
				VotingPanel:SetNoActionEnbaled(true)
				VotingPanel:SetText("Bağlantı Kesildi")
			end
			
			-- Panel animasyonu için delay ekle
			VotingPanel.AnimationDelay = k * 0.1
			VotingPanel.AnimationStartTime = CurTime() + VotingPanel.AnimationDelay
			
			table.insert(VOTING.VoteManager, VotingPanel)
			VotingPanelsList:AddItem(VotingPanel)
		end
		
		-- Panel boyutlandırması
		local maxwidth = VotingPanelsList:GetWide()
		local curwidth = 0
		local items = 0
		
		for k, v in pairs(VotingPanelsList:GetItems()) do
			curwidth = curwidth + (v.CurrentWidth) + 8
			if curwidth > maxwidth then 
				break
			else 
				items = items + 1 
			end
		end
		
		VotingPanelsList:SetWide(390 * items) -- Daha geniş paneller
		VotingPanelsList:SetPos((ScrW() - VotingPanelsList:GetWide()) / 2, 90)
		
		local rows = math.ceil(#VOTING.VoteManager / items)
		VOTING.MaxHeight = 160 + (100 * rows) -- Daha yüksek
		VotingMainWindow:SetSize(ScrW(), VOTING.MaxHeight)
		
		if VOTING.Settings.ForceMouseCursor then 
			gui.EnableScreenClicker(true) 
		end
		
		-- Açılış ses efekti
		if VOTING.Settings.MenuSounds then
			surface.PlaySound(VOTING.Settings.NewVoteSound)
		end
	else
		VOTING.CloseVoteScreen()
	end
end

function VOTING.PaintMainWindow()
	local w, h = ScrW(), VOTING.CurrentHeight
	
	-- Animasyon güncellemeleri
	VOTING.AnimationTime = math.Approach(VOTING.AnimationTime, 1, FrameTime() * 2)
	VOTING.BackgroundAlpha = math.Approach(VOTING.BackgroundAlpha, 245, FrameTime() * 300)
	VOTING.TitleAlpha = math.Approach(VOTING.TitleAlpha, 255, FrameTime() * 200)
	VOTING.ParticleTime = VOTING.ParticleTime + FrameTime()
	
	-- Ana pencere animasyonu
	VOTING.CurrentHeight = math.Approach(VOTING.CurrentHeight, VOTING.MaxHeight, FrameTime() * VOTING.Settings.AnimationSpeed)
	
	-- Gradient arka plan
	VOTING.DrawGradientBackground(0, 0, w, VOTING.CurrentHeight)
	
	-- Üst çerçeve
	surface.SetDrawColor(VOTING.Theme.BorderColor)
	surface.DrawRect(0, 0, w, 4)
	surface.DrawRect(0, VOTING.CurrentHeight - 4, w, 4)
	
	-- Parçacık efekti (opsiyonel)
	if VOTING.Settings.GlowEffect then
		VOTING.DrawParticleEffect()
	end
	
	-- Zaman hesaplaması - güvenli kontrol
	local time = 0
	if VOTING.CanCloseTime and VotingMainWindow and VotingMainWindow.VoteTime then
		time = math.Clamp(VOTING.CanCloseTime - CurTime(), 0, VotingMainWindow.VoteTime)
	end
	local timetext = string.FormattedTime(time, "%02i:%02i")
	
	-- Ana başlık
	local text = VOTING.Settings.VotingTitle
	if VOTING.ResultsScreen then 
		text = VOTING.Settings.ResultsTitle 
	else
		text = text .. " | " .. timetext
	end
	
	-- Başlık gölgesi
	draw.DrawText(text, "VotingTitleFont", (w / 2) + 2, 17, Color(0, 0, 0, VOTING.TitleAlpha * 0.8), TEXT_ALIGN_CENTER)
	-- Ana başlık
	draw.DrawText(text, "VotingTitleFont", (w / 2), 15, Color(VOTING.Theme.TitleTextColor.r, VOTING.Theme.TitleTextColor.g, VOTING.Theme.TitleTextColor.b, VOTING.TitleAlpha), TEXT_ALIGN_CENTER)
	
	-- Geri sayım uyarısı - güvenli kontrol
	if time > 0 and time <= 10 and not VOTING.ResultsScreen then
		local warningAlpha = math.sin(CurTime() * 8) * 100 + 155
		draw.DrawText("SON " .. math.ceil(time) .. " SANIYE!", "VotingTimerFont", (w / 2), 55, Color(255, 100, 100, warningAlpha), TEXT_ALIGN_CENTER)
		
		-- Geri sayım sesi
		if math.ceil(time) ~= (VOTING.LastCountdownSecond or 0) and VOTING.Settings.MenuSounds then
			VOTING.LastCountdownSecond = math.ceil(time)
			surface.PlaySound(VOTING.Settings.CountdownSound or "buttons/button17.wav")
		end
	end
-- Vote ticker
	if VOTING.VoteTickerAlpha > -1 then
		VOTING.VoteTickerAlpha = math.Clamp(VOTING.VoteTickerAlpha + FrameTime() * VOTING.NotificationDirFT * 300, 0, 200)
		
		local c = VOTING.VoteTickerColor
		local tickerY = (VOTING.MaxHeight or 200) - 35
		
		-- Ticker arka planı
		surface.SetDrawColor(0, 0, 0, VOTING.VoteTickerAlpha * 0.8)
		surface.DrawRect(0, tickerY - 5, w, 30)
		
		-- Ticker metni
		if VOTING.VoteTickerMessage then
			draw.DrawText(VOTING.VoteTickerMessage, "VotingNoticeFont", w / 2, tickerY, Color(c.r, c.g, c.b, VOTING.VoteTickerAlpha), TEXT_ALIGN_CENTER)
		end
	end
end

-- Gradient arka plan çizim fonksiyonu
function VOTING.DrawGradientBackground(x, y, w, h)
	local steps = 20
	local stepHeight = h / steps
	
	-- Güvenli tema renkleri
	local topColor = VOTING.Theme.WindowGradientTop or Color(25, 35, 50, 250)
	local bottomColor = VOTING.Theme.WindowGradientBottom or Color(10, 15, 25, 250)
	local bgAlpha = VOTING.BackgroundAlpha or 245
	
	for i = 0, steps - 1 do
		local alpha = i / (steps - 1)
		
		local r = Lerp(alpha, topColor.r, bottomColor.r)
		local g = Lerp(alpha, topColor.g, bottomColor.g)
		local b = Lerp(alpha, topColor.b, bottomColor.b)
		local a = Lerp(alpha, topColor.a, bottomColor.a)
		
		surface.SetDrawColor(r, g, b, math.min(a, bgAlpha))
		surface.DrawRect(x, y + (i * stepHeight), w, stepHeight + 1)
	end
end

-- Parçacık efekti
function VOTING.DrawParticleEffect()
	if not VOTING.Settings or not VOTING.Settings.GlowEffect then return end
	
	local particleCount = 15
	local w, h = ScrW(), VOTING.CurrentHeight or 200
	local particleTime = VOTING.ParticleTime or 0
	local glowColor = VOTING.Theme.GlowColor or Color(100, 150, 255)
	
	for i = 1, particleCount do
		local x = (w / particleCount) * i + math.sin(particleTime * 2 + i) * 50
		local y = 20 + math.cos(particleTime * 1.5 + i) * 10
		local alpha = math.sin(particleTime * 3 + i) * 50 + 100
		
		surface.SetDrawColor(glowColor.r, glowColor.g, glowColor.b, alpha)
		surface.DrawRect(x - 1, y - 1, 2, 2)
	end
end

function VOTING.CloseVoteScreen()
	-- DarkRP timer'ı temizle
	if timer.Exists("VotingDarkRPCheck") then
		timer.Remove("VotingDarkRPCheck")
	end
	
	if VotingMainWindow then
		-- Güvenli kapanış animasyonu
		local closeAnim = VotingMainWindow
		if closeAnim.AlphaTo then
			closeAnim:AlphaTo(0, 0.5, 0, function()
				if IsValid(closeAnim) then
					closeAnim:Remove()
				end
			end)
		else
			-- Fallback - direkt kapat
			closeAnim:Remove()
		end
		
		VotingMainWindow = nil
	end
	
	-- Tüm değişkenleri güvenli şekilde sıfırla
	VOTING.CanCloseTime = nil
	VOTING.LastPanelNumber = nil
	VOTING.VoteTickerAlpha = -1
	VOTING.VoteTickerMessage = "Seçimde bir oy kullanıldı."
	VOTING.ResultsScreen = nil
	VOTING.LastCountdownSecond = nil
	VOTING.MainWindowOpen = false
	
	-- LocalPlayer kontrolü
	if IsValid(LocalPlayer()) then
		LocalPlayer().HasVoted = nil
	end
end

-- DarkRP uyumluluğu için kontrol fonksiyonu
local function CheckDarkRPVoteConflict()
	if VOTING.MainWindowOpen and VotingMainWindow and IsValid(VotingMainWindow) then
		-- DarkRP vote aktifse mayor voting'i gizle
		if GAMEMODE and GAMEMODE.IsVoteActive and GAMEMODE:IsVoteActive() then
			VotingMainWindow:SetVisible(false)
			print("[VOTING] Hiding mayor vote due to DarkRP vote conflict")
		else
			VotingMainWindow:SetVisible(true)
		end
	end
end

-- DarkRP vote kontrolü için timer
timer.Create("VotingDarkRPCheck", 1, 0, CheckDarkRPVoteConflict)

-- Network Messages
net.Receive("Voting_NewVote", function(l, c)
	-- DarkRP vote kontrolü
	if GAMEMODE and GAMEMODE.IsVoteActive and GAMEMODE:IsVoteActive() then
		print("[VOTING] DarkRP vote active, delaying mayor election for 5 seconds...")
		timer.Simple(5, function()
			local votedata = net.ReadTable()
			local votetime = VOTING.VoteTime
			local settings = {}
			settings.Candidates = votedata
			settings.time = votetime
			VOTING.OpenVoteScreen(settings)
		end)
		return
	end
	
	local votedata = net.ReadTable()
	local votetime = VOTING.VoteTime
	local settings = {}
	settings.Candidates = votedata
	settings.time = votetime
	VOTING.OpenVoteScreen(settings)
end)

net.Receive("Voting_EndVote", function(l, c)
	if not VOTING.MainWindowOpen then return end
	local winningplayer = net.ReadEntity()

	if winningplayer and not (winningplayer == NULL) and VOTING.VoteManager then
		VOTING.ResultsScreen = true
		
		for k, v in pairs(VOTING.VoteManager) do
			if not (v:GetPlayer() == winningplayer) then
				v:SetNoActionEnbaled(true)
			else
				VOTING.VoteTickerAlpha = 0
				VOTING.VoteTickerMessage = string.format("Tebrikler %s! Yeni baskan!", winningplayer:Nick())
				VOTING.VoteTickerColor = v:GetColor()
				
				-- Kazanan efekti
				v:SetColor(Color(255, 215, 0)) -- Altın rengi
			end
		end
		
		-- Kazanma ses efekti
		if VOTING.Settings.MenuSounds then
			surface.PlaySound(VOTING.Settings.VoteResultsSound)
		end
	end
	
	timer.Simple(VOTING.Settings.CloseTimeAfterVoteEnds, VOTING.CloseVoteScreen)
end)

net.Receive("Voting_VoteCast", function(l, c)
	if not VOTING.MainWindowOpen then return end
	local candidate = net.ReadEntity()
	local player = net.ReadEntity()

	for k, v in pairs(VOTING.VoteManager) do
		if v:GetPlayer() == candidate then
			v:IncreaseVote(1)
			
			-- Vote ticker update
			if VOTING.Settings.ShowVoteTickerUpdates and IsValid(player) and IsValid(candidate) then
				VOTING.VoteTickerAlpha = 0
				VOTING.VoteTickerMessage = string.format("%s -> %s oyunu kullandi", player:Nick(), candidate:Nick())
				VOTING.VoteTickerColor = v:GetColor()
			end
			break
		end
	end
end)

-- Initialization
VOTING.VoteTickerAlpha = -1
VOTING.VoteTickerMessage = "Seçimde bir oy kullanıldı."
VOTING.VoteTickerColor = Color(26, 83, 255)
VOTING.NotificationDirFT = 1

-- Enhanced color system
VOTING.VotingStaticColors = {
	Color(26, 83, 255),    -- Mavi
	Color(255, 77, 77),    -- Kırmızı
	Color(230, 184, 0),    -- Sarı
	Color(0, 179, 54),     -- Yeşil
	Color(255, 165, 0),    -- Turuncu
	Color(128, 0, 128),    -- Mor
	Color(255, 20, 147),   -- Pembe
	Color(0, 255, 255)     -- Cyan
}

function VOTING.NewVotingPanelColor()
	if not VOTING.LastPanelNumber then 
		VOTING.LastPanelNumber = 1 
	else 
		VOTING.LastPanelNumber = (VOTING.LastPanelNumber + 1) 
	end
	
	if VOTING.VotingStaticColors[VOTING.LastPanelNumber] then
		return VOTING.VotingStaticColors[VOTING.LastPanelNumber]
	else
		-- Rastgele parlak renkler
		local hue = math.random(0, 360)
		return HSVToColor(hue, 0.8, 1)
	end
end

-- Confirmation dialog
local ConfirmMenuVisible = false
function VOTING.ConfirmCandidacy()
	if ConfirmMenuVisible then return end
	ConfirmMenuVisible = true
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 300)
	frame:Center()
	frame:SetTitle("")
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	frame.Paint = function(self, w, h)
		-- Ana arka plan (opak)
		surface.SetDrawColor(20, 25, 35, 255)
		surface.DrawRect(0, 0, w, h)
		
		-- Üst gradient
		local gradientHeight = 60
		for i = 0, gradientHeight do
			local alpha = (i / gradientHeight) * 100
			surface.SetDrawColor(50, 100, 200, alpha)
			surface.DrawRect(0, i, w, 1)
		end
		
		-- Çerçeve
		surface.SetDrawColor(100, 150, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 3)
		
		-- İç çerçeve
		surface.SetDrawColor(255, 255, 255, 50)
		surface.DrawOutlinedRect(10, 10, w - 20, h - 20, 1)
		
		-- Başlık arka planı
		surface.SetDrawColor(30, 40, 60, 200)
		surface.DrawRect(0, 0, w, 50)
		
		-- Başlık metni
		draw.DrawText("BASKANLIK SECIMI", "DermaLarge", w / 2, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	end
	
	-- Ana soru metni
	local questionLabel = vgui.Create("DLabel", frame)
	questionLabel:SetPos(30, 70)
	questionLabel:SetSize(440, 30)
	questionLabel:SetText("Bir sonraki secime katilmak istiyor musunuz?")
	questionLabel:SetFont("DermaLarge")
	questionLabel:SetTextColor(Color(255, 255, 255))
	questionLabel:SetContentAlignment(5)
	
	-- Alt açıklama
	local infoLabel = vgui.Create("DLabel", frame)
	infoLabel:SetPos(30, 110)
	infoLabel:SetSize(440, 25)
	infoLabel:SetText("Secim sistemi otomatik olarak baslatilacaktir")
	infoLabel:SetFont("DermaDefaultBold")
	infoLabel:SetTextColor(Color(200, 200, 255))
	infoLabel:SetContentAlignment(5)
	
	-- Maliyet gösterimi
	local costPanel = vgui.Create("DPanel", frame)
	costPanel:SetPos(50, 150)
	costPanel:SetSize(400, 50)
	costPanel.Paint = function(self, w, h)
		-- Maliyet paneli arka planı
		surface.SetDrawColor(40, 50, 70, 200)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 215, 0, 150)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		
		-- Para ikonu (basit)
		surface.SetDrawColor(255, 215, 0)
		surface.DrawRect(15, 15, 20, 20)
		surface.SetDrawColor(40, 50, 70)
		surface.DrawRect(20, 20, 10, 10)
	end
	
	local costLabel = vgui.Create("DLabel", costPanel)
	costLabel:SetPos(50, 0)
	costLabel:SetSize(350, 50)
	costLabel:SetText("Maliyet: " .. (DarkRP and DarkRP.formatMoney(VOTING.CandidateCost) or VOTING.CandidateCost .. " TL"))
	costLabel:SetFont("DermaLarge")
	costLabel:SetTextColor(Color(255, 215, 0))
	costLabel:SetContentAlignment(5)
	
	-- EVET butonu
	local yesBtn = vgui.Create("DButton", frame)
	yesBtn:SetPos(80, 230)
	yesBtn:SetSize(140, 50)
	yesBtn:SetText("EVET")
	yesBtn:SetFont("DermaLarge")
	yesBtn.DoClick = function()
		LocalPlayer():ConCommand("mayor_vote_enter")
		frame:Close()
		ConfirmMenuVisible = false
	end
	
	-- HAYIR butonu
	local noBtn = vgui.Create("DButton", frame)
	noBtn:SetPos(280, 230)
	noBtn:SetSize(140, 50)
	noBtn:SetText("HAYIR")
	noBtn:SetFont("DermaLarge")
	noBtn.DoClick = function()
		frame:Close()
		ConfirmMenuVisible = false
	end
	
	-- Button styling
	local function StyleButton(btn, baseColor, hoverColor)
		btn.Paint = function(self, w, h)
			local color = baseColor
			if self:IsHovered() then
				color = hoverColor
			end
			
			-- Ana buton arka planı
			surface.SetDrawColor(color.r, color.g, color.b, 255)
			surface.DrawRect(0, 0, w, h)
			
			-- Gradient efekti
			for i = 0, h / 2 do
				local alpha = (i / (h / 2)) * 50
				surface.SetDrawColor(255, 255, 255, alpha)
				surface.DrawRect(0, i, w, 1)
			end
			
			-- Çerçeve
			surface.SetDrawColor(255, 255, 255, 100)
			surface.DrawOutlinedRect(0, 0, w, h, 2)
			
			-- İç gölge
			if self:IsDown() then
				surface.SetDrawColor(0, 0, 0, 50)
				surface.DrawRect(2, 2, w - 4, h - 4)
			end
		end
		btn:SetTextColor(Color(255, 255, 255))
	end
	
	StyleButton(yesBtn, Color(50, 150, 50), Color(70, 200, 70))
	StyleButton(noBtn, Color(150, 50, 50), Color(200, 70, 70))
	
	-- Kapanış animasyonu
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.3, 0)
end

usermessage.Hook("VOTING_Confirm", VOTING.ConfirmCandidacy)

function VOTING.SetupClientTeam()
	timer.Simple(2, function()
		local TEAM
		for k, v in pairs(RPExtraTeams) do
			if string.lower(v.name) == string.lower(VOTING.MayorTeamName) then
				TEAM = v
			end
		end
		if not TEAM then return end
		TEAM.vote = false
	end)
end
hook.Add("InitPostEntity", "VOTING_SetupClientTeam", VOTING.SetupClientTeam)

-- Chat notice function
local function MayorVotingChatNotice(msg)
	local text = msg:ReadString() or "No message."
	chat.AddText(VOTING.Theme.NoticePrefixColor, VOTING.Settings.NoticePrefix .. " ", VOTING.Theme.NoticeTextColor, text)
end
usermessage.Hook("Voting_ChatNotice", MayorVotingChatNotice)