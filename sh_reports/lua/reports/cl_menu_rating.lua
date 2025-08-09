-- cl_menu_rating.lua - GÜVEN SKORU SİSTEMİ İLE GÜNCELLENMİŞ HALİ

local matStar = Material("shenesis/reports/star.png", "noclamp smooth")

-- ESKİ FONKSİYON: Admin'i puanlama (oyuncu tarafından)
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

-- YENİ FONKSİYON: Rapor eden oyuncuyu puanlama (admin tarafından) - GÜVEN SKORU SİSTEMİ
function SH_REPORTS:ShowReportRating(report_id, reporter_name, reporter_id)
	if (IsValid(_SH_REPORTS_REPORT_RATE)) then
		_SH_REPORTS_REPORT_RATE:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5
	local ss = self:GetScreenScale()

	local cur_rate = 3
	local is = 64 * ss

	-- Puanlama açıklamaları
	local ratingDescriptions = {
		[5] = {text = "Tamamen Haklı", color = Color(46, 204, 113), trust = "+10 Güven"},
		[4] = {text = "Haklı", color = Color(52, 152, 219), trust = "+5 Güven"},
		[3] = {text = "Kısmen Haklı", color = Color(241, 196, 15), trust = "±0 Güven"},
		[2] = {text = "Gereksiz Rapor", color = Color(230, 126, 34), trust = "-5 Güven"},
		[1] = {text = "Troll/Spam", color = Color(231, 76, 60), trust = "-10 Güven"}
	}

	local frame = self:MakeWindow("Rapor Değerlendirmesi")
	frame:SetSize(500 * ss, 280 * ss)
	frame:MakePopup()
	frame:Center()
	_SH_REPORTS_REPORT_RATE = frame

		-- Başlık
		local header = self:QuickLabel("Rapor Eden: " .. reporter_name, "{prefix}Large", styl.text, frame)
		header:SetContentAlignment(5)
		header:Dock(TOP)
		header:DockMargin(m, m, m, 0)

		-- Açıklama
		local desc = self:QuickLabel("Bu rapor ne kadar haklıydı?", "{prefix}Medium", styl.text, frame)
		desc:SetContentAlignment(5)
		desc:Dock(TOP)
		desc:DockMargin(m, m2, m, m)

		-- Yıldızlar
		local stars = vgui.Create("DPanel", frame)
		stars:SetDrawBackground(false)
		stars:SetTall(64 * ss)
		stars:Dock(TOP)
		stars:DockMargin(m, 0, m, m)

			for i = 1, 5 do
				local st = vgui.Create("DButton", stars)
				st:SetToolTip(ratingDescriptions[i].text .. " (" .. ratingDescriptions[i].trust .. ")")
				st:SetText("")
				st:SetWide(64 * ss)
				st:Dock(LEFT)
				st:DockMargin(i == 1 and 0 or m2, 0, 0, 0)
				st.Paint = function(me, w, h)
					if (!me.m_CurColor) then
						me.m_CurColor = styl.inbg
					else
						local targetColor = cur_rate >= i and ratingDescriptions[cur_rate].color or styl.inbg
						me.m_CurColor = self:LerpColor(FrameTime() * 20, me.m_CurColor, targetColor)
					end

					surface.SetMaterial(matStar)
					surface.SetDrawColor(me.m_CurColor)
					surface.DrawTexturedRect(0, 0, w, h)
				end
				st.OnCursorEntered = function()
					cur_rate = i
				end
				st.DoClick = function()
					-- Puanı gönder
					easynet.SendToServer("SH_REPORTS.RateReport", {
						report_id = report_id,
						reporter_id = reporter_id,
						rating = i
					})
					frame:Close()
					
					-- Başarı mesajı
					self:Notify("Rapor değerlendirildi: " .. ratingDescriptions[i].text, nil, styl.success)
				end
			end

		-- Seçili puanın açıklaması
		local infoPanel = vgui.Create("DPanel", frame)
		infoPanel:SetTall(80 * ss)
		infoPanel:Dock(TOP)
		infoPanel:DockMargin(m, 0, m, m)
		infoPanel.Paint = function(me, w, h)
			draw.RoundedBox(4, 0, 0, w, h, styl.inbg)
			
			local rating = ratingDescriptions[cur_rate]
			if rating then
				-- Puan başlığı
				draw.SimpleText(rating.text, font_prefix .. "Large", w * 0.5, h * 0.3, rating.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				-- Güven skoru etkisi
				draw.SimpleText(rating.trust, font_prefix .. "Medium", w * 0.5, h * 0.6, styl.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				-- Açıklama metni
				local explainText = ""
				if cur_rate == 5 then
					explainText = "Rapor tamamen haklı, kural ihlali kesin"
				elseif cur_rate == 4 then
					explainText = "Rapor haklı, ancak küçük detaylar eksik"
				elseif cur_rate == 3 then
					explainText = "Rapor kısmen haklı, yanlış anlaşılma olabilir"
				elseif cur_rate == 2 then
					explainText = "Rapor gereksiz, kural ihlali yok"
				else
					explainText = "Rapor tamamen gereksiz, troll veya spam"
				end
				
				draw.SimpleText(explainText, font_prefix .. "Small", w * 0.5, h * 0.85, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		-- Butonlar
		local buttons = vgui.Create("DPanel", frame)
		buttons:SetDrawBackground(false)
		buttons:SetTall(35 * ss)
		buttons:Dock(BOTTOM)
		buttons:DockMargin(m, 0, m, m)

			-- İptal butonu
			local cancel = self:QuickButton("İptal", function()
				frame:Close()
			end, buttons)
			cancel:Dock(LEFT)
			cancel:SetWide(100 * ss)

			-- Değerlendir butonu
			local submit = self:QuickButton("Değerlendir", function()
				easynet.SendToServer("SH_REPORTS.RateReport", {
					report_id = report_id,
					reporter_id = reporter_id,
					rating = cur_rate
				})
				frame:Close()
				
				-- Başarı mesajı
				self:Notify("Rapor değerlendirildi: " .. ratingDescriptions[cur_rate].text, nil, styl.success)
			end, buttons, nil, styl.header)
			submit:Dock(RIGHT)
			submit:SetWide(120 * ss)

		-- Güven Skoru Bilgisi
		local trustInfo = self:QuickLabel("", "{prefix}Small", styl.text, frame)
		trustInfo:SetContentAlignment(5)
		trustInfo:Dock(BOTTOM)
		trustInfo:DockMargin(m, 0, m, 0)
		trustInfo.Think = function(me)
			me:SetText("Mevcut Güven Skoru: Yükleniyor...")
			
			-- Güven skorunu talep et (bir kerelik)
			if not me.requested then
				me.requested = true
				easynet.SendToServer("SH_REPORTS.RequestTrustScore", {steamid = reporter_id})
			end
		end

	-- Yıldızları ortala
	local totalWidth = (64 * ss * 5) + (m2 * 4)
	local padding = (frame:GetWide() - totalWidth - m * 2) * 0.5
	stars:DockPadding(padding, 0, padding, 0)

	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.1)
end

-- YENİ: Güven skoru callback'i
easynet.Callback("SH_REPORTS.SendTrustScore", function(data)
	if IsValid(_SH_REPORTS_REPORT_RATE) then
		local trustInfo = _SH_REPORTS_REPORT_RATE:GetChildren()[#_SH_REPORTS_REPORT_RATE:GetChildren()]
		if IsValid(trustInfo) and trustInfo.SetText then
			local score = data.score
			local color = Color(255, 255, 255)
			
			if score >= 80 then
				color = Color(46, 204, 113) -- Yeşil
			elseif score >= 50 then
				color = Color(241, 196, 15) -- Sarı
			elseif score >= 30 then
				color = Color(230, 126, 34) -- Turuncu
			else
				color = Color(231, 76, 60) -- Kırmızı
			end
			
			trustInfo:SetText("Mevcut Güven Skoru: " .. score .. "/100")
			trustInfo:SetTextColor(color)
		end
	end
end)

-- ESKİ: Admin rating callback'i
easynet.Callback("SH_REPORTS.PromptRating", function(data)
	SH_REPORTS:ShowRating(data.report_id, data.admin_name)
end)

-- YENİ: Report rating callback'i (admin tarafından tetiklenir)
easynet.Callback("SH_REPORTS.PromptReportRating", function(data)
	SH_REPORTS:ShowReportRating(data.report_id, data.reporter_name, data.reporter_id)
end)