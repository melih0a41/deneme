local matStar = Material("shenesis/reports/star.png", "noclamp smooth")

-- ESKİ: Oyuncu admin'i puanlıyor
function SH_REPORTS:ShowRating(report_id, admin_name)
	if (IsValid(_SH_REPORTS_RATE)) then
		_SH_REPORTS_RATE:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5
	local ss = self:GetScreenScale()

	local cur_rate = 3
	local is = 64 * ss

	local frame = self:MakeWindow(SH_REPORTS:L("rating"))
	frame:SetSize(1, 144 * ss + m * 2)
	frame:MakePopup()
	_SH_REPORTS_RATE = frame

		local stars = vgui.Create("DPanel", frame)
		stars:SetDrawBackground(false)
		stars:Dock(FILL)
		stars:DockMargin(m, m, m, m)

			for i = 1, 5 do
				local st = vgui.Create("DButton", stars)
				st:SetToolTip(i .. "/" .. 5)
				st:SetText("")
				st:SetWide(64 * ss)
				st:Dock(LEFT)
				st:DockMargin(0, 0, m2, 0)
				st.Paint = function(me, w, h)
					if (!me.m_CurColor) then
						me.m_CurColor = styl.inbg
					else
						me.m_CurColor = self:LerpColor(FrameTime() * 20, me.m_CurColor, cur_rate >= i and styl.rating or styl.inbg)
					end

					surface.SetMaterial(matStar)
					surface.SetDrawColor(me.m_CurColor)
					surface.DrawTexturedRect(0, 0, w, h)
				end
				st.OnCursorEntered = function()
					cur_rate = i
				end
				st.DoClick = function()
					easynet.SendToServer("SH_REPORTS.RateAdmin", {report_id = report_id, rating = i})
					frame:Close()
				end
			end

		local lbl = self:QuickLabel(SH_REPORTS:L("rate_question", admin_name), "{prefix}Large", styl.text, frame)
		lbl:SetContentAlignment(5)
		lbl:Dock(BOTTOM)
		lbl:DockMargin(0, 0, 0, m)
		
	frame:SetWide(math.max(400 * ss, lbl:GetWide() + m * 2))
	frame:Center()
	
	local sp = math.ceil((frame:GetWide() - (64 * ss) * 5 - m * 4) * 0.5)
	stars:DockPadding(sp, 0, sp, 0)
end

-- YENİ: Admin oyuncuyu puanlıyor (Güven skoru için)
function SH_REPORTS:ShowReportRating(report_id, reporter_name, reporter_id)
	if (IsValid(_SH_REPORTS_ADMIN_RATE)) then
		_SH_REPORTS_ADMIN_RATE:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5
	local ss = self:GetScreenScale()

	local frame = self:MakeWindow("Rapor Değerlendirmesi")
	frame:SetSize(550 * ss, 650 * ss) -- 650 piksel yükseklik (kesinlikle yeterli)
	frame:Center()
	frame:MakePopup()
	_SH_REPORTS_ADMIN_RATE = frame

		local body = vgui.Create("DPanel", frame)
		body:SetDrawBackground(false)
		body:DockPadding(m, m, m, m)
		body:Dock(FILL)

			-- Başlık
			local title = self:QuickLabel("Raporu değerlendirin:", "{prefix}Larger", styl.text, body)
			title:SetContentAlignment(5)
			title:Dock(TOP)
			title:SetTall(30 * ss)
			
			-- Oyuncu bilgisi
			local info = self:QuickLabel("Rapor eden: " .. reporter_name, "{prefix}Large", styl.text, body)
			info:SetContentAlignment(5)
			info:Dock(TOP)
			info:SetTall(25 * ss)
			info:DockMargin(0, m2, 0, m)

			-- İptal butonlarını önce oluştur (alt kısımda sabit olması için)
			local bottomPanel = vgui.Create("DPanel", body)
			bottomPanel:SetDrawBackground(false)
			bottomPanel:Dock(BOTTOM)
			bottomPanel:SetTall(35 * ss)
			bottomPanel:DockMargin(0, m, 0, 0)
			
				local cancel = self:QuickButton("İptal", function()
					frame:Close()
					surface.PlaySound("buttons/button10.wav")
				end, bottomPanel, nil, styl.failure)
				cancel:Dock(RIGHT)
				cancel:SetWide(100 * ss)
				
				local skipRating = self:QuickButton("Değerlendirmeden Kapat", function()
					-- Değerlendirme yapmadan kapat (eski sistem gibi)
					easynet.SendToServer("SH_REPORTS.CloseReport", {
						id = report_id
					})
					frame:Close()
					
					if IsValid(_SH_REPORTS_VIEW) then
						_SH_REPORTS_VIEW:Close()
					end
					
					surface.PlaySound("buttons/button15.wav")
				end, bottomPanel)
				skipRating:Dock(LEFT)
				skipRating:SetWide(180 * ss)

			-- Değerlendirme seçenekleri için container
			local optionsContainer = vgui.Create("DPanel", body)
			optionsContainer:SetDrawBackground(false)
			optionsContainer:Dock(FILL)
			optionsContainer:DockMargin(0, 0, 0, 0)

			-- Değerlendirme seçenekleri
			local options = {
				{
					rating = 5, 
					text = "Tamamen haklı", 
					desc = "Rapor %100 doğru",
					score = "+10 güven puanı",
					color = Color(46, 204, 113)
				},
				{
					rating = 4, 
					text = "Haklı", 
					desc = "Rapor doğru",
					score = "+5 güven puanı",
					color = Color(52, 152, 219)
				},
				{
					rating = 3, 
					text = "Kısmen haklı", 
					desc = "Rapor kısmen doğru",
					score = "güven puanı değişmez",
					color = Color(241, 196, 15)
				},
				{
					rating = 2, 
					text = "Gereksiz", 
					desc = "Gereksiz rapor",
					score = "-5 güven puanı",
					color = Color(230, 126, 34)
				},
				{
					rating = 1, 
					text = "Spam/Troll", 
					desc = "Kötü niyetli rapor",
					score = "-10 güven puanı",
					color = Color(231, 76, 60)
				}
			}

			for i, opt in ipairs(options) do
				-- Her seçenek için panel
				local optPanel = vgui.Create("DButton", optionsContainer)
				optPanel:SetText("")
				optPanel:Dock(TOP)
				optPanel:SetTall(64 * ss) -- Yükseklik 64 piksel (kesin çözüm)
				optPanel:DockMargin(0, 3, 0, 3) -- Küçük margin
				
				optPanel.Paint = function(me, w, h)
					-- Arka plan
					draw.RoundedBox(4, 0, 0, w, h, styl.inbg)
					
					-- Hover efekti
					if me.Hovered then
						surface.SetAlphaMultiplier(0.2)
						draw.RoundedBox(4, 0, 0, w, h, opt.color)
						surface.SetAlphaMultiplier(1)
					end
					
					-- Sol renk şeridi
					surface.SetDrawColor(opt.color)
					surface.DrawRect(0, 0, 4, h)
					
					-- Metinler
					local textX = 14 * ss
					
					-- Başlık (üstten 13 piksel)
					surface.SetFont("SH_REPORTS.Large")
					surface.SetTextColor(opt.color)
					surface.SetTextPos(textX, 13 * ss)
					surface.DrawText(opt.text)
					
					-- Açıklama ve puan (üstten 37 piksel)
					surface.SetFont("SH_REPORTS.Medium")
					surface.SetTextColor(styl.text)
					surface.SetTextPos(textX, 37 * ss)
					surface.DrawText(opt.desc .. " (" .. opt.score .. ")")
				end
				
				optPanel.DoClick = function()
					-- Raporu değerlendirmeyle kapat
					easynet.SendToServer("SH_REPORTS.CloseReportWithRating", {
						report_id = report_id,
						admin_rating = opt.rating
					})
					frame:Close()
					
					-- View penceresi açıksa kapat
					if IsValid(_SH_REPORTS_VIEW) then
						_SH_REPORTS_VIEW:Close()
					end
					
					-- Bildirim
					surface.PlaySound("buttons/button14.wav")
				end
			end

	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.1)
end

-- Network callbacks
easynet.Callback("SH_REPORTS.PromptRating", function(data)
	SH_REPORTS:ShowRating(data.report_id, data.admin_name)
end)

-- YENİ: Admin rating penceresi açma callback'i
easynet.Callback("SH_REPORTS.ShowReportRating", function(data)
	SH_REPORTS:ShowReportRating(data.report_id, data.reporter_name, data.reporter_id)
end)