-- cl_menu_main.lua - ShowReport fonksiyonunu komple değiştirin

local matBack = Material("shenesis/general/back.png")

function SH_REPORTS:ShowReport(report)
	if (IsValid(_SH_REPORTS_VIEW)) then
		_SH_REPORTS_VIEW:Remove()
	end

	local styl = self.Style
	local th, m = self:GetPadding(), self:GetMargin()
	local m2 = m * 0.5
	local ss = self:GetScreenScale()

	local frame = self:MakeWindow(SH_REPORTS:L("view_report"))
	frame:SetSize(500 * ss, 400 * ss)
	frame:Center()
	frame:MakePopup()
	_SH_REPORTS_VIEW = frame
	
	-- Rapor ID'sini frame'e kaydet (yenileme için kullanacağız)
	frame.ReportID = report.id

		-- GERİ BUTONU - SADECE SUPERADMİN KONTROLÜ
		if LocalPlayer():GetUserGroup() == "superadmin" then
			frame:AddHeaderButton(matBack, function()
				frame:Close()
				self:ShowReports()
			end)
		end

		local body = vgui.Create("DPanel", frame)
		body:SetDrawBackground(false)
		body:DockPadding(m, m, m, m)
		body:Dock(FILL)

			local players = vgui.Create("DPanel", body)
			players:SetDrawBackground(false)
			players:SetWide(frame:GetWide() - m * 2)
			players:Dock(TOP)

				local lbl1 = self:QuickLabel(SH_REPORTS:L("reporter"), "{prefix}Large", styl.text, players)
				lbl1:SetContentAlignment(7)
				lbl1:SetTextInset(m2, m2)
				lbl1:SetWide(frame:GetWide() * 0.5 - m2)
				lbl1:Dock(LEFT)
				lbl1:DockPadding(m2, lbl1:GetTall() + m * 1.5, m2, m2)
				lbl1.Paint = function(me, w, h)
					draw.RoundedBox(4, 0, 0, w, h, styl.inbg)
				end

					local avi = self:Avatar(report.reporter_id, 32, lbl1)
					avi:Dock(LEFT)
					avi:DockMargin(0, 0, m2, 0)

					local nic = self:QuickButton(report.reporter_name, function()
						SetClipboardText(report.reporter_name)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl1)
					nic:SetContentAlignment(4)
					nic:Dock(TOP)

					local s1 = util.SteamIDFrom64(report.reporter_id)
					local steamid = self:QuickButton(s1, function()
						SetClipboardText(s1)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl1)
					steamid:SetContentAlignment(4)
					steamid:Dock(TOP)

				local lbl = self:QuickLabel(SH_REPORTS:L("reported_player"), "{prefix}Large", styl.text, players)
				lbl:SetContentAlignment(9)
				lbl:SetTextInset(m2, m2)
				lbl:Dock(FILL)
				lbl:DockPadding(m2, lbl1:GetTall() + m * 1.5, m2, m2)
				lbl.Paint = lbl1.Paint

					local avi = self:Avatar(report.reported_id, 32, lbl)
					avi:Dock(RIGHT)
					avi:DockMargin(m2, 0, 0, 0)

					local nic = self:QuickButton(report.reported_name, function()
						SetClipboardText(report.reported_name)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl)
					nic:SetContentAlignment(6)
					nic:Dock(TOP)
					nic.Think = function(me)
						me:SetTextColor(IsValid(player.GetBySteamID64(report.reported_id)) and styl.text or styl.failure)
					end

					local s2 = util.SteamIDFrom64(report.reported_id)
					local steamid = self:QuickButton(s2, function()
						SetClipboardText(s2)
						surface.PlaySound("common/bugreporter_succeeded.wav")
					end, lbl)
					steamid:SetContentAlignment(6)
					steamid:Dock(TOP)

					if (report.reported_id == "0") then
						nic.Think = function() end
						nic:Dock(FILL)
						steamid:SetVisible(false)
						avi:SetVisible(false)
					end

				players:SetTall(lbl1:GetTall() + m * 2.5 + 32)

			local reason = self:QuickLabel(SH_REPORTS:L("reason") .. ":", "{prefix}Medium", styl.text, body)
			reason:Dock(TOP)
			reason:DockMargin(0, m, 0, 0)
			reason:DockPadding(reason:GetWide() + m2, 0, 0, 0)

				local reasonData = self.ReportReasons[report.reason_id]
				local reasonText = reasonData
				if type(reasonData) == "table" then
					reasonText = reasonData.reason
				end
				
				local r = self:QuickEntry(reasonText, reason)
				r:SetEnabled(false)
				r:SetContentAlignment(6)
				r:Dock(FILL)
				
				-- Yetkili şikayeti uyarısı
				if type(reasonData) == "table" and reasonData.disabled then
					local warning = self:QuickLabel("⚠️ Bu rapor Discord üzerinden işleme alınmalıdır!", "{prefix}Medium", styl.failure, body)
					warning:SetContentAlignment(5)
					warning:Dock(TOP)
					warning:DockMargin(0, m2, 0, 0)
				end

			local comment = self:QuickLabel(SH_REPORTS:L("comment") .. ":", "{prefix}Medium", styl.text, body)
			comment:SetContentAlignment(7)
			comment:Dock(FILL)
			comment:DockMargin(0, m, 0, m2)

				local tx = self:QuickEntry("", comment)
				tx:SetEnabled(false)
				tx:SetMultiline(true)
				tx:SetValue(report.comment)
				tx:Dock(FILL)
				tx:DockMargin(0, comment:GetTall() + m2, 0, 0)

			local actions = vgui.Create("DPanel", body)
			actions:SetDrawBackground(false)
			actions:Dock(BOTTOM)

				if (self:IsAdmin(LocalPlayer())) then
					-- İKİ AŞAMALI SİSTEM
					if (report.admin_id == "") then
						-- AŞAMA 1: SADECE ÜSTLEN BUTONU
						local claim = self:QuickButton(SH_REPORTS:L("claim_report"), function()
							-- Raporu üstlen
							easynet.SendToServer("SH_REPORTS.Claim", {id = report.id})
							
							-- BUTON DEVRE DIŞI BIRAK
							claim:SetEnabled(false)
							claim:SetText("Üstleniliyor...")
							
							-- Raporu manuel olarak güncelle (sunucu onayını beklemeden)
							report.admin_id = LocalPlayer():SteamID64()
							
							-- BİRAZ BEKLE VE YENİLE
							timer.Simple(1, function()
								if IsValid(frame) then
									frame:Close()
									-- Güncel raporu bul ve göster
									for _, rep in pairs(SH_REPORTS.ActiveReports) do
										if rep.id == report.id then
											SH_REPORTS:ShowReport(rep)
											break
										end
									end
								end
							end)
						end, actions, nil, styl.header)
						claim:Dock(FILL)
						claim:SetTall(35 * ss)
						claim:SetToolTip("Bu raporu üstlenin")
						
					elseif (report.admin_id == LocalPlayer():SteamID64()) then
						-- AŞAMA 2: RAPOR ÜSTLENİLDİ - GİT/ÇEK/SİT BUTONLARI
						
						-- GİT BUTONU
						local goto = self:QuickButton(SH_REPORTS:L("goto"), function()
							easynet.SendToServer("SH_REPORTS.TeleportToReport", {
								id = report.id, 
								action = "goto"
							})
							frame:Close()
						end, actions)
						goto:Dock(LEFT)
						goto:DockMargin(0, 0, m2, 0)
						goto:SetToolTip("Oyuncunun yanına git")
						
						-- ÇEK BUTONU
						local bring = self:QuickButton(SH_REPORTS:L("bring"), function()
							easynet.SendToServer("SH_REPORTS.TeleportToReport", {
								id = report.id,
								action = "bring"
							})
							frame:Close()
						end, actions)
						bring:Dock(LEFT)
						bring:DockMargin(0, 0, m2, 0)
						bring:SetToolTip("Oyuncuyu yanına çek")
						
						-- SİT BAŞLAT BUTONU
						local sit = self:QuickButton("Sit Başlat", function()
							easynet.SendToServer("SH_REPORTS.StartSitForReport", {
								id = report.id
							})
							frame:Close()
						end, actions, nil, styl.header)
						sit:Dock(LEFT)
						sit:DockMargin(0, 0, m2, 0)
						sit:SetToolTip("15 saniye sonra sit başlat")
						
						-- Base kontrolü için özel durum
						if (report.reason_id == 7) then
							bring:SetVisible(false)
							sit:SetVisible(false)
							goto:SetText("Base'e Git")
							goto:SetToolTip("Base kontrolü için oyuncunun yanına git")
						end
						
					else
						-- BAŞKA BİR YETKİLİ ÜSTLENMİŞ
						local lbl = self:QuickLabel(SH_REPORTS:L("claimed_by_x", ""), "{prefix}Medium", styl.text, actions)
						lbl:SetContentAlignment(5)
						lbl:Dock(FILL)

						self:GetName(report.admin_id, function(nick)
							if (IsValid(lbl)) then
								lbl:SetText(SH_REPORTS:L("claimed_by_x", nick))
								lbl:SizeToContents()
							end
						end)
					end
				end

				-- KAPAT BUTONU
				if (report.reporter_id == LocalPlayer():SteamID64()) or 
				   (report.admin_id == "" and self.CanDeleteWhenUnclaimed) or 
				   (report.admin_id == LocalPlayer():SteamID64()) then
					local close = self:QuickButton(SH_REPORTS:L("close_report"), function()
						easynet.SendToServer("SH_REPORTS.CloseReport", {id = report.id})
						frame:Close()
					end, actions, nil, self.Style.close_hover)
					close:Dock(RIGHT)
				end

	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.1)
end