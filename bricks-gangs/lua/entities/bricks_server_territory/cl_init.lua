include('shared.lua')

function ENT:Initialize()
	self.flagMaterial = CreateMaterial( "brs_flag_material_entid" .. self:EntIndex(), "UnlitGeneric", {} )
	self.flagRenderTarget = GetRenderTarget( "brs_flag_rendertarget_entid" .. self:EntIndex(), 1004, 704, false )

	self.flagMaterial:SetTexture( "$basetexture", self.flagRenderTarget )
end

local iconMat
local iconRequested = false
function ENT:Draw()
	self:DrawModel()

    local position = self:GetPos()
    local angles = self:GetAngles()

	angles:RotateAroundAxis( angles:Forward(), 90)

	angles.y = LocalPlayer():EyeAngles().y - 90

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	local w, h = 200, 50
	local x, y = 25, 0

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )

	if( not territoryTable ) then return end
	
	local territoryConfig = BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey] or {}
	local territoryGangTable = (BRICKS_SERVER_GANGS or {})[(territoryTable or {}).GangID or 0] or {}

	if( Distance < BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then
		surface.SetAlphaMultiplier( math.Clamp( 1-(Distance/BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"]), 0, 1 ) )
		cam.Start3D2D( self:GetPos()+self:GetUp()*55, angles, 0.1 )
			draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

			local capturePercent = (territoryTable.Claimed and 1) or 0

			if( IsValid( self:GetCaptor() ) ) then
				if( (self:GetCaptureEndTime() or 0) > 0 ) then
					capturePercent = math.Clamp( (BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(self:GetCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"], 0, 1 )
				else
					capturePercent = math.Clamp( 1-((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(self:GetUnCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]), 0, 1 )
				end
			end

			local border = 5
			draw.RoundedBox( 5, x+border, y+border, (w-2*border)*capturePercent, h-(2*border), territoryConfig.Color or BRICKS_SERVER.Func.GetTheme( 5 ) )
		cam.End3D2D()

		local bottomW, bottomH, iconSize = 240, 310, 64
		local bottomX, bottomY = -(bottomW/2), 0

		local function drawBottomInfo()
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
			surface.DrawRect( bottomX, bottomY, bottomW, bottomH )
			draw.SimpleText( territoryConfig.Name, "BRICKS_SERVER_Font40", bottomX+bottomW/2, 65, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( BRICKS_SERVER.Func.L( "gangTerritoryUpper" ), "BRICKS_SERVER_Font25", bottomX+bottomW/2, 65, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )

			if( territoryTable.Claimed ) then
				draw.SimpleText( BRICKS_SERVER.Func.L( "gangCaptured" ), "BRICKS_SERVER_Font20", bottomX+bottomW/2, bottomY+(bottomH/2)-(iconSize/2)+25-5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

				if( territoryTable.IconMat ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( territoryTable.IconMat )
					surface.DrawTexturedRect( bottomX+(bottomW/2)-(iconSize/2), bottomY+(bottomH/2)-(iconSize/2)+25, iconSize, iconSize )
				else
					BRICKS_SERVER.Func.RequestTerritoryIconMat( territoryKey )
				end

				draw.SimpleText( (territoryGangTable.Name or BRICKS_SERVER.Func.L( "nil" )), "BRICKS_SERVER_Font25", bottomX+bottomW/2, bottomY+(bottomH/2)+(iconSize/2)+25+5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
				
				-- KORUMA GÖSTERGESİ
				local protectionTime = self:GetNWFloat("ProtectionTime", 0)
				if protectionTime > CurTime() then
					local remaining = math.ceil(protectionTime - CurTime())
					draw.SimpleText( "KORUMA: " .. remaining .. " saniye", "BRICKS_SERVER_Font20", bottomX+bottomW/2, bottomY+bottomH-30, Color( 255, 255, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
		end

		local angles = self:GetAngles()
		angles:RotateAroundAxis( angles:Forward(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4+self:GetRight()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()

		angles:RotateAroundAxis( angles:Right(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4-self:GetForward()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()
		
		angles:RotateAroundAxis( angles:Right(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4-self:GetRight()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()

		angles:RotateAroundAxis( angles:Right(), 90)

		cam.Start3D2D( self:GetPos()+self:GetUp()*17.4+self:GetForward()*12.8, angles, 0.05 )
			drawBottomInfo()
		cam.End3D2D()
		surface.SetAlphaMultiplier( 1 )

		-- Draw flag color and logo
		local w, h, iconSize = 1004, 704, 400
		render.PushRenderTarget( self.flagRenderTarget )
			render.Clear( 0, 0, 0, 0, true, true ) 
			cam.Start2D()
				surface.SetDrawColor( territoryConfig.Color or BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.DrawRect( 0, 0, w, h )

				if( territoryTable.Claimed ) then
					if( territoryTable.IconMat ) then
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetMaterial( territoryTable.IconMat )
						surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
					else
						BRICKS_SERVER.Func.RequestTerritoryIconMat( territoryKey )
					end
				end
			cam.End2D()
		render.PopRenderTarget()
		
		self:SetSubMaterial( 2, "!brs_flag_material_entid" .. self:EntIndex() )
	end
end

-- CAPTURE ZONE ÇEMBER SİSTEMİ
hook.Add("PostDrawTranslucentRenderables", "BricksGang_DrawCaptureRadius", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local segments = 128
    
    -- Tüm territory bayraklarını kontrol et
    for _, ent in ipairs(ents.FindByClass("bricks_server_territory")) do
        if not IsValid(ent) then continue end
        
        -- Eğer bu bayrakta capture işlemi varsa
        local captor = ent:GetCaptor()
        if IsValid(captor) then
            local captureRadius = math.sqrt(BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or 40000)
            local flagPos = ent:GetPos()
            
            -- Sadece capture eden oyuncu veya gang üyeleri görsün
            local showCircle = false
            if captor == ply then
                showCircle = true
            else
                -- Gang üyesi mi kontrol et
                local captorGangID = captor:GetNWInt("GangID", 0)
                local plyGangID = ply:GetNWInt("GangID", 0)
                if captorGangID > 0 and captorGangID == plyGangID then
                    showCircle = true
                end
            end
            
            if showCircle then
                -- Animasyonlu efekt
                local pulse = math.sin(CurTime() * 2) * 0.1 + 0.9
                
                -- İlerleme yüzdesini hesapla
                local captureProgress = 0
                if ent:GetCaptureEndTime() > 0 then
                    captureProgress = math.Clamp((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(ent:GetCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"], 0, 1)
                elseif ent:GetUnCaptureEndTime() > 0 then
                    captureProgress = math.Clamp(1-((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(ent:GetUnCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]), 0, 1)
                end

                -- İlerlemeye göre renk değişimi
                local circleColor
                if captureProgress < 0.3 then
                    -- %0-30 arası kırmızı
                    circleColor = Color(255, 0, 0)
                elseif captureProgress < 0.7 then
                    -- %30-70 arası kırmızıdan sarıya geçiş
                    local t = (captureProgress - 0.3) / 0.4
                    circleColor = Color(255, 255 * t, 0)
                else
                    -- %70-100 arası sarıdan yeşile geçiş
                    local t = (captureProgress - 0.7) / 0.3
                    circleColor = Color(255 * (1 - t), 255, 0)
                end
                
                -- Zemine çember çiz
                render.SetColorMaterial()
                
                -- İç dolgulu yuvarlak alan (gradient efektli)
                cam.Start3D2D(flagPos + Vector(0, 0, 1), Angle(0, 0, 0), 1)
                    -- Dıştan içe doğru halkalar
                    for r = captureRadius, 10, -10 do
                        local circle = {}
                        for i = 0, segments do
                            local angle = (i / segments) * math.pi * 2
                            table.insert(circle, {
                                x = math.cos(angle) * r,
                                y = math.sin(angle) * r
                            })
                        end
                        local alpha = math.Clamp((1 - (r / captureRadius)) * 100, 0, 100)
                        surface.SetDrawColor(circleColor.r, circleColor.g, circleColor.b, alpha * pulse)
                        draw.NoTexture()
                        surface.DrawPoly(circle)
                    end
                cam.End3D2D()
                
                -- Çember çizgisi
                for i = 0, segments do
                    local angle = (i / segments) * math.pi * 2
                    local nextAngle = ((i + 1) / segments) * math.pi * 2
                    
                    local startPos = flagPos + Vector(math.cos(angle) * captureRadius, math.sin(angle) * captureRadius, 2)
                    local endPos = flagPos + Vector(math.cos(nextAngle) * captureRadius, math.sin(nextAngle) * captureRadius, 2)
                    
                    render.DrawLine(startPos, endPos, Color(circleColor.r, circleColor.g, circleColor.b, 255 * pulse), true)
                end
                
                -- Dikey duvar efekti (opsiyonel, daha güzel görünüm için)
                local wallHeight = 50
                for i = 0, 32 do
                    local angle = (i / 32) * math.pi * 2
                    local wallPos = flagPos + Vector(math.cos(angle) * captureRadius, math.sin(angle) * captureRadius, wallHeight/2)
                    
                    render.DrawLine(
                        wallPos - Vector(0, 0, wallHeight/2),
                        wallPos + Vector(0, 0, wallHeight/2),
                        Color(circleColor.r, circleColor.g, circleColor.b, 100 * pulse),
                        true
                    )
                end
                
                -- >>> YENİ EKLENEN KOD BAŞLANGICI <<<
                -- IŞIK SÜTUNU EFEKTİ
                if showCircle and captureProgress > 0 then
                    -- Işık sütunu parametreleri
                    local beamHeight = 500 + (captureProgress * 500) -- İlerlemeyle yükselen
                    local beamRadius = 50
                    local beamAlpha = 100 * pulse
                    
                    -- Işık sütunu render
                    render.SetMaterial(Material("sprites/light_glow02_add"))
                    
                    -- Ana ışık sütunu
                    for i = 0, beamHeight, 20 do
                        local size = beamRadius * (1 - (i / beamHeight) * 0.5)
                        render.DrawSprite(
                            flagPos + Vector(0, 0, i),
                            size * 2,
                            size * 2,
                            Color(circleColor.r, circleColor.g, circleColor.b, beamAlpha * (1 - i / beamHeight))
                        )
                    end
                    
                    -- Dönen spiral efekt
                    local spiralAngle = CurTime() * 2
                    for i = 0, beamHeight, 10 do
                        local spiralOffset = math.sin(spiralAngle + i * 0.01) * 20
                        local spiralPos = flagPos + Vector(
                            math.cos(spiralAngle + i * 0.02) * spiralOffset,
                            math.sin(spiralAngle + i * 0.02) * spiralOffset,
                            i
                        )
                        
                        render.DrawSprite(
                            spiralPos,
                            20,
                            20,
                            Color(255, 255, 255, 50 * (1 - i / beamHeight))
                        )
                    end
                    
                    -- Taban parıltısı
                    render.SetMaterial(Material("sprites/light_glow02_add"))
                    render.DrawSprite(
                        flagPos + Vector(0, 0, 5),
                        200 * pulse,
                        200 * pulse,
                        Color(circleColor.r, circleColor.g, circleColor.b, 150)
                    )
                end
                -- >>> YENİ EKLENEN KOD BİTİŞİ <<<

            end
        end
    end
end)

-- HUD'da mesafe göstergesi
hook.Add("HUDPaint", "BricksGang_CaptureDistanceHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Tüm territory bayraklarını kontrol et
    for _, ent in ipairs(ents.FindByClass("bricks_server_territory")) do
        if not IsValid(ent) then continue end
        
        local captor = ent:GetCaptor()
        if IsValid(captor) and captor == ply then
            local captureRadius = math.sqrt(BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or 40000)
            local distance = ply:GetPos():Distance(ent:GetPos())
            local inZone = distance <= captureRadius
            
            -- İlerleme yüzdesini hesapla
            local captureProgress = 0
            if ent:GetCaptureEndTime() > 0 then
                captureProgress = math.Clamp((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(ent:GetCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"], 0, 1)
            elseif ent:GetUnCaptureEndTime() > 0 then
                captureProgress = math.Clamp(1-((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(ent:GetUnCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]), 0, 1)
            end

            -- İlerlemeye göre renk değişimi
            local circleColor
            if captureProgress < 0.3 then
                circleColor = Color(255, 0, 0)
            elseif captureProgress < 0.7 then
                local t = (captureProgress - 0.3) / 0.4
                circleColor = Color(255, 255 * t, 0)
            else
                local t = (captureProgress - 0.7) / 0.3
                circleColor = Color(255 * (1 - t), 255, 0)
            end
            
            -- Ekran ortasında uyarı
            local centerX, centerY = ScrW() / 2, ScrH() * 0.75
            
            -- Arka plan
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(centerX - 150, centerY - 25, 300, 50)
            
            -- Çerçeve
            surface.SetDrawColor(circleColor.r, circleColor.g, circleColor.b, 255)
            surface.DrawOutlinedRect(centerX - 150, centerY - 25, 300, 50)
            
            -- Metin
            local text = inZone and "BAYRAK ALANINDA" or string.format("ALANDAN ÇIKTINIZ! Mesafe: %dm", math.Round(distance - captureRadius))
            draw.SimpleText(
                text,
                "DermaLarge",
                centerX,
                centerY,
                inZone and Color(0, 255, 0) or Color(255, 0, 0),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            
            -- İlerleme çubuğu
            if inZone then
                -- İlerleme arka planı
                surface.SetDrawColor(50, 50, 50, 200)
                surface.DrawRect(centerX - 100, centerY + 30, 200, 20)
                
                -- İlerleme çubuğu (ilerlemeye göre renk)
                surface.SetDrawColor(circleColor.r, circleColor.g, circleColor.b, 255)
                surface.DrawRect(centerX - 100, centerY + 30, 200 * captureProgress, 20)
                
                -- İlerleme çerçevesi
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawOutlinedRect(centerX - 100, centerY + 30, 200, 20)
                
                -- Yüzde
                draw.SimpleText(
                    string.format("%d%%", captureProgress * 100),
                    "DermaDefault",
                    centerX,
                    centerY + 40,
                    Color(255, 255, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                
                -- Gang üye sayısı ve hız bonusu göster
                local speedBonus = ent:GetNWInt("CaptureSpeedBonus", 0)
                if speedBonus > 1 then
                    local bonusText = speedBonus >= 3 and "HIZ: x2" or "HIZ: x1.5"
                    local bonusColor = speedBonus >= 3 and Color(0, 255, 0) or Color(255, 255, 0)
                    
                    draw.SimpleText(
                        bonusText .. " (" .. speedBonus .. " kişi)",
                        "DermaDefault",
                        centerX,
                        centerY + 60,
                        bonusColor,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER
                    )
                end
            end
        end
    end
end)

-- Düşman gang üyelerine glow efekti
hook.Add("PreDrawHalos", "BricksGang_EnemyTerritoryGlow", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local plyGangID = ply:GetNWInt("GangID", 0)
    if plyGangID == 0 then return end -- Oyuncu gang'de değilse çık
    
    local glowPlayers = {}
    
    -- Tüm territory bayraklarını kontrol et
    for _, ent in ipairs(ents.FindByClass("bricks_server_territory")) do
        if not IsValid(ent) then continue end
        
        local territoryKey = ent:GetTerritoryKey()
        local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists(territoryKey)
        
        -- Bu bayrakta aktif capture var mı?
        local captor = ent:GetCaptor()
        if IsValid(captor) then
            local captorGangID = captor:GetNWInt("GangID", 0)
            local ownerGangID = (territoryTable and territoryTable.Claimed and territoryTable.GangID) or 0
            
            local captureRadius = math.sqrt(BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or 40000)
            local glowRadius = captureRadius * 3 -- 3 katı mesafe
            
            -- Tüm oyuncuları kontrol et
            for _, target in ipairs(player.GetAll()) do
                if target == ply then continue end -- Kendini kontrol etme
                
                local targetGangID = target:GetNWInt("GangID", 0)
                if targetGangID == 0 or targetGangID == plyGangID then continue end -- Gang'de değil veya aynı gang
                
                -- Target glow mesafesinde mi?
                if target:GetPos():Distance(ent:GetPos()) <= glowRadius then
                    local shouldGlow = false
                    
                    -- DURUM 1: Biz capture ediyorsak, bayrak sahibi gang'i görürüz
                    if captorGangID == plyGangID and targetGangID == ownerGangID then
                        shouldGlow = true
                    end
                    
                    -- DURUM 2: Biz bayrak sahibiysek, capture eden gang'i görürüz
                    if ownerGangID == plyGangID and targetGangID == captorGangID then
                        shouldGlow = true
                    end
                    
                    -- DURUM 3: Başka biri capture ediyorsa, capture eden gang'i görürüz
                    if captorGangID ~= plyGangID and captorGangID > 0 and targetGangID == captorGangID then
                        shouldGlow = true
                    end
                    
                    -- DURUM 4: Capture eden gang, bayrak sahibini görür
                    if captorGangID == plyGangID and ownerGangID > 0 and targetGangID == ownerGangID then
                        shouldGlow = true
                    end
                    
                    if shouldGlow then
                        -- Line of Sight kontrolü (duvar arkasından görünmesin)
                        local tr = util.TraceLine({
                            start = ply:EyePos(),
                            endpos = target:GetPos() + Vector(0, 0, 50),
                            filter = {ply, target},
                            mask = MASK_SHOT
                        })
                        
                        if tr.Fraction == 1 or tr.Entity == target then -- Görüş açık
                            table.insert(glowPlayers, target)
                        end
                    end
                end
            end
        end
    end
    
    -- Glow efekti uygula
    if #glowPlayers > 0 then
        -- Kırmızı glow efekti (düşman olduğu için)
        halo.Add(glowPlayers, Color(255, 0, 0), 3, 3, 2, true, true)
    end
end)

-- Gang ID'lerini oyuncu spawn olduğunda güncelle
hook.Add("OnEntityCreated", "BricksGang_SetPlayerGangID", function(ent)
    if IsValid(ent) and ent:IsPlayer() then
        timer.Simple(1, function()
            if IsValid(ent) and ent:HasGang() then
                ent:SetNWInt("GangID", ent:HasGang())
            end
        end)
    end
end)

-- Savunma bonusu HUD göstergesi
hook.Add("HUDPaint", "BricksGang_DefenseBonusHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    if ply:GetNWBool("InOwnTerritory", false) then
        -- Sağ üst köşede bilgi göster
        local x, y = ScrW() - 220, 100
        
        -- Arka plan
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(x, y, 200, 80)
        
        -- Çerçeve
        surface.SetDrawColor(0, 255, 0, 255)
        surface.DrawOutlinedRect(x, y, 200, 80)
        
        -- Başlık
        draw.SimpleText(
            "BAYRAK BONUSU",
            "DermaDefault",
            x + 100,
            y + 10,
            Color(0, 255, 0),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP
        )
        
        -- Bonuslar
        draw.SimpleText(
            "• Hasar Koruması: %10",
            "DermaDefault",
            x + 10,
            y + 30,
            Color(255, 255, 255),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_TOP
        )
        
        draw.SimpleText(
            "• Hızlı Reload: %20",
            "DermaDefault",
            x + 10,
            y + 50,
            Color(255, 255, 255),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_TOP
        )
    end
    
    -- Hasar aldığında efekt
    if ply:GetNWBool("TerritoryDefenseActive", false) then
        -- Ekran kenarlarına yeşil parıltı
        surface.SetDrawColor(0, 255, 0, 50)
        surface.DrawRect(0, 0, ScrW(), 50)
        surface.DrawRect(0, ScrH() - 50, ScrW(), 50)
        surface.DrawRect(0, 0, 50, ScrH())
        surface.DrawRect(ScrW() - 50, 0, 50, ScrH())
    end
end)

-- Capture ilerleme sesleri
net.Receive("BricksGang_CaptureProgress", function()
    local percent = net.ReadInt(8)
    local isOwnGang = net.ReadBool()
    
    if isOwnGang then
        -- Kendi gang'imiz capture ediyor - pozitif ses
        surface.PlaySound("buttons/button3.wav")
        
        -- %75'te ekstra ses
        if percent >= 75 then
            surface.PlaySound("buttons/button10.wav")
        end
    else
        -- Bayrağımız ele geçiriliyor - alarm sesi
        surface.PlaySound("buttons/button8.wav")
        
        -- %75'te yoğun alarm
        if percent >= 75 then
            surface.PlaySound("ambient/alarms/warningbell1.wav")
            
            -- Ekran titreme efekti
            util.ScreenShake(LocalPlayer():GetPos(), 5, 5, 1, 200)
        end
    end
    
    -- Ekranda büyük bildirim göster
    if percent >= 75 then
        hook.Add("HUDPaint", "BricksGang_CriticalCapture", function()
            local alpha = math.sin(CurTime() * 10) * 50 + 200
            
            draw.SimpleText(
                isOwnGang and "BAYRAK ELE GEÇİRİLMEK ÜZERE!" or "BAYRAK TEHLİKEDE!",
                "DermaLarge",
                ScrW() / 2,
                100,
                Color(255, 0, 0, alpha),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end)
        
        -- 5 saniye sonra bildirimi kaldır
        timer.Simple(5, function()
            hook.Remove("HUDPaint", "BricksGang_CriticalCapture")
        end)
    end
end)


-- Capture tamamlandığında havai fişek efekti
local fireworks = {}

net.Receive("BricksGang_CaptureComplete", function()
    local pos = net.ReadVector()
    local gangID = net.ReadInt(32)
    
    -- 10 havai fişek oluştur
    for i = 1, 10 do
        timer.Simple(i * 0.3, function()
            local firework = {
                pos = pos + Vector(math.random(-100, 100), math.random(-100, 100), 0),
                vel = Vector(math.random(-50, 50), math.random(-50, 50), math.random(300, 500)),
                life = CurTime() + 2,
                exploded = false,
                particles = {}
            }
            
            table.insert(fireworks, firework)
            
            -- Fişek sesi
            sound.Play("weapons/flaregun/fire.wav", pos, 75, math.random(90, 110))
        end)
    end
end)

-- Havai fişek render
hook.Add("PostDrawTranslucentRenderables", "BricksGang_Fireworks", function()
    render.SetMaterial(Material("sprites/light_glow02_add"))
    
    for k, fw in pairs(fireworks) do
        if CurTime() > fw.life then
            table.remove(fireworks, k)
            continue
        end
        
        -- Fişek henüz patlamadıysa
        if not fw.exploded then
            fw.pos = fw.pos + fw.vel * FrameTime()
            fw.vel.z = fw.vel.z - 300 * FrameTime() -- Yerçekimi
            
            -- Fişek izi
            render.DrawSprite(fw.pos, 20, 20, Color(255, 200, 100, 255))
            
            -- Yeterince yükseldiyse patla
            if fw.vel.z < 0 then
                fw.exploded = true
                
                -- Patlama sesi
                sound.Play("ambient/explosions/explode_" .. math.random(1, 5) .. ".wav", fw.pos, 75, 150)
                
                -- Parçacıklar oluştur
                for i = 1, 30 do
                    local particle = {
                        pos = fw.pos,
                        vel = Vector(
                            math.random(-200, 200),
                            math.random(-200, 200),
                            math.random(-100, 200)
                        ),
                        color = HSVToColor(math.random(0, 360), 1, 1),
                        life = CurTime() + math.random(1, 2)
                    }
                    table.insert(fw.particles, particle)
                end
            end
        else
            -- Patlama parçacıkları
            for pk, particle in pairs(fw.particles) do
                if CurTime() > particle.life then
                    table.remove(fw.particles, pk)
                    continue
                end
                
                particle.pos = particle.pos + particle.vel * FrameTime()
                particle.vel.z = particle.vel.z - 200 * FrameTime()
                
                local alpha = math.Clamp((particle.life - CurTime()) * 255, 0, 255)
                render.DrawSprite(
                    particle.pos,
                    math.random(10, 20),
                    math.random(10, 20),
                    Color(particle.color.r, particle.color.g, particle.color.b, alpha)
                )
            end
        end
    end
end)

-- İstatistik paneli
net.Receive("BricksGang_ShowStats", function()
    local allStats = net.ReadTable()
    local myGangID = net.ReadInt(32)
    
    -- Panel oluştur
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("Gang Savaş İstatistikleri")
    frame:MakePopup()
    
    -- Tab paneli
    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    
    -- Gang sıralaması sekmesi
    local rankPanel = vgui.Create("DPanel", sheet)
    local rankList = vgui.Create("DListView", rankPanel)
    rankList:Dock(FILL)
    rankList:AddColumn("Sıra")
    rankList:AddColumn("Gang")
    rankList:AddColumn("Ele Geçirme")
    rankList:AddColumn("Kayıp")
    rankList:AddColumn("Savunma")
    rankList:AddColumn("Başarı Oranı")
    
    -- Gang'leri sırala
    local sortedGangs = {}
    for gangID, stats in pairs(allStats) do
        local gangInfo = BRICKS_SERVER_GANGS[gangID]
        if gangInfo then
            local successRate = stats.captured / math.max(1, stats.captured + stats.lost) * 100
            table.insert(sortedGangs, {
                id = gangID,
                name = gangInfo.Name or "Bilinmeyen",
                captured = stats.captured or 0,
                lost = stats.lost or 0,
                defended = stats.defended or 0,
                rate = successRate
            })
        end
    end
    
    table.sort(sortedGangs, function(a, b) return a.captured > b.captured end)
    
-- Listeye ekle
for k, gang in ipairs(sortedGangs) do
    local line = rankList:AddLine(
        k,
        gang.name,
        gang.captured,
        gang.lost,
        gang.defended,
        string.format("%%%.1f", gang.rate)
    )
    
    -- Kendi gang'imizi vurgula
    if gang.id == myGangID then
        line.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 100, 0, 50))
        end
    end
end
    
    sheet:AddSheet("Gang Sıralaması", rankPanel, "icon16/chart_bar.png")
    
    -- Kendi gang detayları
    if allStats[myGangID] then
        local myPanel = vgui.Create("DPanel", sheet)
        local myStats = allStats[myGangID]
        
        -- Üye listesi
        local memberList = vgui.Create("DListView", myPanel)
        memberList:Dock(FILL)
        memberList:AddColumn("Üye")
        memberList:AddColumn("Ele Geçirme")
        memberList:AddColumn("Savunma")
        
        for steamID, member in pairs(myStats.members or {}) do
            memberList:AddLine(
                member.name,
                member.captures or 0,
                member.defends or 0
            )
        end
        
        -- Genel bilgiler
        local infoPanel = vgui.Create("DPanel", myPanel)
        infoPanel:Dock(TOP)
        infoPanel:SetTall(100)
        infoPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
            
            draw.SimpleText("Toplam Ele Geçirme: " .. (myStats.captured or 0), "DermaLarge", 10, 10, Color(255, 255, 255))
            draw.SimpleText("Toplam Kayıp: " .. (myStats.lost or 0), "DermaLarge", 10, 35, Color(255, 255, 255))
            draw.SimpleText("Başarılı Savunma: " .. (myStats.defended or 0), "DermaLarge", 10, 60, Color(255, 255, 255))
            
            if myStats.lastCapture and myStats.lastCapture > 0 then
                local lastCap = os.date("%d/%m/%Y %H:%M", myStats.lastCapture)
                draw.SimpleText("Son Ele Geçirme: " .. lastCap, "DermaDefault", w - 10, 10, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
            end
        end
        
        sheet:AddSheet("Gang Detayları", myPanel, "icon16/group.png")
    end
    
    -- Haftalık istatistikler
    local weekPanel = vgui.Create("DPanel", sheet)
    local weekList = vgui.Create("DListView", weekPanel)
    weekList:Dock(FILL)
    weekList:AddColumn("Gang")
    weekList:AddColumn("Bu Hafta")
    weekList:AddColumn("Geçen Hafta")
    
    local currentWeek = os.date("%Y-%U")
    local lastWeek = os.date("%Y-%U", os.time() - 7 * 24 * 60 * 60)
    
    for gangID, stats in pairs(allStats) do
        local gangInfo = BRICKS_SERVER_GANGS[gangID]
        if gangInfo and stats.weeklyCaptures then
            weekList:AddLine(
                gangInfo.Name or "Bilinmeyen",
                stats.weeklyCaptures[currentWeek] or 0,
                stats.weeklyCaptures[lastWeek] or 0
            )
        end
    end
    
    sheet:AddSheet("Haftalık", weekPanel, "icon16/calendar.png")
end)