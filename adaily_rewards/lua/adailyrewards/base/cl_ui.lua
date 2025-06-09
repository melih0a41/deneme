 local math_Round, math_cos, math_sin, math_pi = math.Round, math.cos, math.sin, math.pi

local sound_hover = "adailyrewards/button1.ogg"
local sound_click = "adailyrewards/button2.ogg"
local sound_miss = "adailyrewards/button3.ogg"

local mat_blur = Material("pp/blurscreen")
local mat_options = Material( "adailyrewards/options.png", "mips smooth" )
local mat_back = Material( "adailyrewards/back.png", "mips smooth" )
local mat_lock = Material( "adailyrewards/lock.png", "mips smooth" )
local mat_lock_outline = Material( "adailyrewards/lock_outline.png", "mips smooth" )
local mat_none = Material( "adailyrewards/none.png", "mips smooth" )
local mat_check = Material( "adailyrewards/check.png", "mips smooth" )
local mat_player = Material( "adailyrewards/player.png", "mips smooth" )
local mat_premium = Material( "adailyrewards/premium.png", "mips smooth" )
local mat_hint = Material( "adailyrewards/hint.png", "mips smooth" )


local c_255 = Color( 255, 255, 255, 255 )
local c_220 = Color( 220, 220, 220, 255 )
local c_200 = Color( 200, 200, 200, 255 )
local c_180 = Color( 180, 180, 180, 255 )
local c_150 = Color( 150, 150, 150, 255 )

local c_ablack = Color(0, 0, 0, 200)
local c_hint = Color(90, 90, 90, 140)

local c_transparent  = Color( 255, 255, 255, 10 )
local c_transparent2 = Color( 255, 255, 255, 20 )
local c_transparent3 = Color( 255, 255, 255, 50 )
local c_transparent4 = Color( 255, 255, 255, 100)

local c_vbar = Color( 255, 255, 255, 3 )

/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
------------------------------------adrDraw----------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/
local mat_white = Material("vgui/white")
--local mat_grUp = Material("vgui/gradient_up")
local mat_grUp = Material("vgui/gradient-d")

local function adrdraw_Stencil(draw1, draw2, sec)
	render.ClearStencil()
	render.SetStencilEnable( true )

	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )

	if sec then
		render.SetStencilReferenceValue( 0 )
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_NEVER )
		render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

		draw1()

		render.SetStencilCompareFunction( STENCIL_EQUAL )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	else
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE )
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilCompareFunction(STENCIL_NEVER)
		render.SetStencilReferenceValue(1)
	  
		draw1()
	  
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilReferenceValue(0)
	end

	draw2()

	render.SetStencilEnable( false )
	render.ClearStencil()
end

local circleCache = {}
local function adrdraw_Circle(x, y, r, seg, color, mat)
	local cacheKey = x.."."..y.."."..r.."."..seg
	local cir = circleCache[cacheKey]
	if not cir then
		cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * r, y = y + math.cos( a ) * r, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is needed for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * r, y = y + math.cos( a ) * r, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		circleCache[cacheKey] = cir
	end

	surface.SetMaterial(mat or mat_white)
	surface.SetDrawColor(color or color_white)
	surface.DrawPoly( cir )
end

local dcircleCache = {}
local function adrdraw_dCircle(x, y, r, seg, proc, color, mat)
	local cproc = math.Round(seg*proc*2)
	local cacheKey = x.."."..y.."."..r.."."..seg.."."..cproc
	local cir = dcircleCache[cacheKey]
	if not cir then
		cir = {}
		if cproc == 0 then return end
		local needi = seg - cproc
		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = needi, seg do
			local a = math.rad( ( i / seg ) * -360 )*0.5
			table.insert( cir, { x = x + math.sin( a ) * r, y = y + math.cos( a ) * r, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) 
		table.insert( cir, { x = x + math.sin( a ) * r, y = y + math.cos( a ) * r, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		circleCache[cacheKey] = cir
	end

	surface.SetMaterial(mat or mat_white)
	surface.SetDrawColor(color or color_white)
	surface.DrawPoly( cir )
end
/*---------------------------------------------------------------------------
Thanks: I don't know who the creator is because I've seen this code in many public places, but presumably it's Vaxod.
If you are the creator or know him for sure, let me know so I can credit him.
Link: https://steamcommunity.com/sharedfiles/filedetails/?id=2913918620  (?)
---------------------------------------------------------------------------*/
local roundedCache = {}

function ADRewards.draw_RoundedTextureBox(r, xOffset, yOffset, w, h, color, mat)
	xOffset = math.floor(xOffset)
	yOffset = math.floor(yOffset)
	w = math.floor(w)
	h = math.floor(h)

	local cacheKey = r.."."..xOffset.."."..yOffset.."."..w.."."..h

	local poly = roundedCache[cacheKey]
	if not poly then
		poly = {}
		local r2 = r * r

		for x = 0, r do
			local y = r - math.sqrt(r2 - (x - r) ^ 2)
			table.insert(poly, {
				x = x + xOffset,
				y = y + yOffset,
				u = x / w,
				v = y / h
			})
		end


		for x = w - r - 1, w do
			local ex = x - (w - r)
			local y = r - math.sqrt(r2 - ex * ex)
			table.insert(poly, {
				x = x + xOffset,
				y = y + yOffset,
				u = x / w,
				v = y / h
			})
		end


		for x = w, w - r - 1, -1 do
			local ex = x - (w - r)
			local y = h - (r - math.sqrt(r2 - ex ^ 2))
			table.insert(poly, {
				x = x + xOffset,
				y = y + yOffset,
				u = x / w,
				v = y / h
			})
		end


		for x = r, 0, -1 do
			local y = h - (r - math.sqrt(r2 - (x - r) ^ 2))
			table.insert(poly, {
				x = x + xOffset,
				y = y + yOffset,
				u = x / w,
				v = y / h
			})
		end
		roundedCache[cacheKey] = poly
	end

	surface.SetMaterial(mat or mat_white)
	surface.SetDrawColor(color or color_white)
	surface.DrawPoly(poly)
end

local function adrdraw_RoundedBoxGradient(r, x, y, w, h, color1, color2, gradientTop)
	ADRewards.draw_RoundedTextureBox(r, x, y, w, h, color1, mat_white)
	ADRewards.draw_RoundedTextureBox(r, x, y, w, h, color2, mat_grUp)
end
/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/
local function rewardDrawPanel(panel, name, key)
	if !IsValid(ADRewards.RewardsMenu) then return end
	local rPanel = panel
	if rPanel.RewardPnl then
		rPanel.RewardPnl:Remove()
	end
	local mW, mH = rPanel:GetWide(), rPanel:GetTall()
	local rewardtbl = ADRewards.Rewards[name]
	if !rewardtbl then
		return
	end

	local rchoosePanel
	if rewardtbl.DrawType == 1 then
		local rmat = rewardtbl.DrawFunc(key)
		if !rmat then return end
		rchoosePanel = vgui.Create( "DPanel", rPanel)
		rchoosePanel:SetPos( 0, 0 )
		rchoosePanel:SetSize( mW, mH )
		rchoosePanel.Paint = function(self, w, h)
			surface.SetDrawColor( 255, 255, 255 )
			surface.SetMaterial( rmat )
			surface.DrawTexturedRect( w*0.10+1, h*0.10, w*0.80, h*0.80 )
		end
	elseif rewardtbl.DrawType == 2 then
		local rmodel = rewardtbl.DrawFunc(key)
		if !rmodel then return end
		rchoosePanel = vgui.Create( "ModelImage", rPanel)
		rchoosePanel:SetPos( mW*0.20+1, mH*0.20 )
		rchoosePanel:SetSize( mW*0.60, mH*0.60 )
		rchoosePanel:SetModel(rmodel)
	elseif rewardtbl.DrawType == 3 then
		local rmodel, rpos, rang, rangat, rfov, rskin, rcolor = rewardtbl.DrawFunc(key)
		if !rmodel then return end
		rchoosePanel = vgui.Create( "DModelPanel", rPanel)
		rchoosePanel:SetPos( mW*0.20+1, mH*0.20 )
		rchoosePanel:SetSize( mW*0.60, mH*0.60 )
		rchoosePanel:SetModel(rmodel)
		rchoosePanel.LayoutEntity = function(ent)
			return
		end
		if rpos then rchoosePanel:SetCamPos( rpos ) end
		if rang then rchoosePanel:SetLookAng( rang ) end
		if rangat then rchoosePanel:SetLookAt( rangat ) end
		if rfov then rchoosePanel:SetFOV( rfov ) end
		if rskin then rchoosePanel.Entity:SetSkin(rskin) end
		if rcolor then rchoosePanel.Entity:SetColor(rcolor) end
	elseif rewardtbl.DrawType == 4 then
		rchoosePanel = rewardtbl.DrawFunc(key, rPanel)
	end
	if !rchoosePanel then return end

	rchoosePanel.OnMousePressed = function(self, keyCode)
		rPanel:OnMousePressed(keyCode)
	end
	rPanel.RewardPnl = rchoosePanel
	

	rchoosePanel:SetCursor( "hand" )
	return rchoosePanel
end

net.Receive("adrewards_RewardRequest", function(nlen, ply)
	local rewardModule = net.ReadString()
	local rewardTbl = ADRewards.Rewards[rewardModule]
	if !rewardTbl then return end
	local rewardVal = net.ReadString()
	local key = rewardTbl.NetRead(rewardVal)
	if !key then return end
	if !IsValid(ADRewards.RewardsMenu) then return end

	if IsValid(ADRewards.RewardsMenu.rchoosePanel)then
		ADRewards.RewardsMenu.rchoosePanel.SetKey(key)
		rewardDrawPanel(ADRewards.RewardsMenu.rchoosePanel.iconPnl, rewardModule, key)
		return
	end

	local finded 
	for k, v in ipairs(ADRewards.RewardsMenu.WaitRequest["Default"]) do
		if v.Module != rewardModule or v.Key != key then continue end
		local rewardIcon = rewardDrawPanel(v.Panel, v.Module, v.Key)
		rewardIcon:SetPaintedManually( true )
		v.Panel.HandPaint = rewardIcon

		table.remove( ADRewards.RewardsMenu.WaitRequest["Default"], k )
		finded = true
		break
	end
	if !finded then
		for k, v in ipairs(ADRewards.RewardsMenu.WaitRequest["Premium"]) do
			if v.Module != rewardModule or v.Key != key then continue end
			local rewardIcon = rewardDrawPanel(v.Panel, v.Module, v.Key)
			rewardIcon:SetPaintedManually( true )
			v.Panel.HandPaint = rewardIcon

			table.remove( ADRewards.RewardsMenu.WaitRequest["Premium"], k )
			break
		end
	end
end)
/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------MAIN MENU---------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/
function ADRewards.OpenRewardsMenu()
	if IsValid(ADRewards.RewardsMenu) then ADRewards.RewardsMenu:Remove() end
	if !ADRewards.SeasonNow then return end
	if !ADRewards.Themes[ADRewards.SeasonNow.STheme] then
		ADRewards.SeasonNow.STheme = "Default"
	end
	local seasonInfo = ADRewards.SeasonNow
	local sW, sH = ScrW(), ScrH()
	local ply = LocalPlayer()
	
	local havePrem = ADRewards.HavePremium(ply)
	local page = 1

	ADRewards.RewardsMenu = vgui.Create( "DFrame" )
	ADRewards.RewardsMenu:SetPos( sW*0.25, sH*0.25 )
	ADRewards.RewardsMenu:SetSize( sW*0.50, sH*0.50 )
	ADRewards.RewardsMenu:SetTitle( "" )
	ADRewards.RewardsMenu:SetVisible( true )
	ADRewards.RewardsMenu:SetDraggable( false )
	ADRewards.RewardsMenu:ShowCloseButton( false )
	ADRewards.RewardsMenu:MakePopup()
	local dayNow = #ply.SeasonADR.Rewards
	local dayMax = seasonInfo.MaxReward
	local dayProc = dayNow/dayMax
	local circleSeg = 200
	local completedtasks = 0
	for k, v in pairs(ply.TasksADR) do
		if v.ValNow < v.ValNeed then continue end
		completedtasks = completedtasks + 1
	end
	ADRewards.RewardsMenu.Paint = function(self, w, h)
		local theme = seasonInfo.STheme
		local maincolor = ADRewards.Themes[theme].MainColor
		local maincolor2 = ADRewards.Themes[theme].MainColor2

		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( ADRewards.Themes[theme].BgImage )
		surface.DrawTexturedRect( 0, 0, w, h )
		/*------------*/
		/*--Left Box--*/
		/*------------*/
		if maincolor2 then
			adrdraw_RoundedBoxGradient(7, w*0.06, h*0.08, w*0.17, h*0.84, maincolor, maincolor2, true)
		else
			ADRewards.draw_RoundedTextureBox(7, w*0.06, h*0.08, w*0.17, h*0.84, maincolor)
		end
		draw.SimpleText( "Daily Rewards", "ADRewards_8",  w*0.145, h*0.102, c_255, TEXT_ALIGN_CENTER )

		adrdraw_Stencil(function()
			adrdraw_Circle(w*0.145, h*0.27, h*0.08, circleSeg, c_transparent3)
		end,
		function()
			adrdraw_Circle(w*0.145, h*0.27, h*0.09, circleSeg, c_transparent3)
		end)

		adrdraw_Stencil(function()
			adrdraw_Circle(w*0.145, h*0.27, h*0.08, circleSeg, c_transparent3)
		end,
		function()
			adrdraw_dCircle(w*0.145, h*0.27, h*0.09, circleSeg, dayProc, c_transparent4)
		end)


		draw.SimpleText( dayNow, "ADRewards_8",  w*0.145, h*0.225, c_255, TEXT_ALIGN_CENTER )
		draw.SimpleText( ADRewards.GetPhrase("DAY"), "ADRewards_L_6",  w*0.145, h*0.275, c_255, TEXT_ALIGN_CENTER )

		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( ADRewards.Themes[seasonInfo.STheme].BoxImage )
		surface.DrawTexturedRect( w*0.01, h*0.38, w*0.245, h*0.44 )

		draw.RoundedBox( 7, w*0.072, h*0.83, w*0.145, h*0.07, c_transparent3 )
		draw.SimpleText( seasonInfo.SName, "ADRewards_L_6",  w*0.145, h*0.85, c_255, TEXT_ALIGN_CENTER )
		/*-------------*/
		/*----Tasks----*/
		/*-------------*/
		draw.SimpleText( ADRewards.GetPhrase("CURRENT_TASKS"), "ADRewards_Bk_6",  w*0.28, h*0.08, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		
		draw.SimpleText( ADRewards.GetPhrase("Completed"), "ADRewards_Bk_6",  w*0.928, h*0.08, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( completedtasks, "ADRewards_Bk_6",  w*0.943, h*0.08, completedtasks == 3 and c_255 or c_transparent4, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "/3", "ADRewards_Bk_6",  w*0.96, h*0.08, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		/*---------------------*/
		/*----Middle Panels----*/
		/*---------------------*/
		local leftStartPos = w*0.29
		surface.SetFont( "ADRewards_7" )
		local phraseText = ADRewards.GetPhrase("TIME")
		local p_w, p_h = surface.GetTextSize( phraseText )

		draw.SimpleText( phraseText, "ADRewards_7",  w*0.28, h*0.53, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.RoundedBox(0, leftStartPos+p_w, h*0.50, 2, h*0.06, c_transparent)
		local timenow = os.time()
		local leftTime = seasonInfo.SEnd-timenow
		if (leftTime/3600) > 24 then
			draw.SimpleText( ADRewards.GetPhrase("EXPIRATION_DATE"), "ADRewards_5",  leftStartPos+p_w+w*0.01, h*0.50, c_transparent3, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( os.date( "%d/%m/%Y", seasonInfo.SEnd ), "ADRewards_6",  leftStartPos+p_w+w*0.01, h*0.56, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		else
			draw.SimpleText( ADRewards.GetPhrase("UNTIL_THE_END"), "ADRewards_5",  leftStartPos+p_w+w*0.01, h*0.50, c_transparent3, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( os.date( "!%H:%M:%S", leftTime ), "ADRewards_6",  leftStartPos+p_w+w*0.01, h*0.56, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		end


		draw.SimpleText( page.."/"..seasonInfo.Pages, "ADRewards_6",  w*0.87, h*0.53, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		/*---------------*/
		/*----Rewards----*/
		/*---------------*/
		local iconSize = w*0.045
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( mat_player )
		surface.DrawTexturedRect( w*0.28, h*0.70-iconSize*0.5, iconSize, iconSize )

		local premColor = havePrem and c_255 or c_transparent4
		surface.SetDrawColor( premColor )
		surface.SetMaterial( mat_premium )
		surface.DrawTexturedRect( w*0.28, h*0.85-iconSize*0.5, iconSize, iconSize )
	end
	ADRewards.RewardsMenu.Think = function(self)
		if input.IsKeyDown(KEY_ESCAPE) then
			ADRewards.RewardsMenu:Remove() 
			gui.HideGameUI()
		end
	end
	ADRewards.RewardsMenu.WaitRequest = {
		Default = {},
		Premium = {}
	}

	local rMenu = ADRewards.RewardsMenu
	local mW, mH = rMenu:GetWide(), rMenu:GetTall()

	local setSoundCD = CurTime() + 0.2
	local settingsBtn = vgui.Create( "DButton", rMenu)
	settingsBtn:SetPos( mW*0.92, 0 )
	settingsBtn:SetSize( mW*0.04, mH*0.06 )
	settingsBtn:SetText( "" )
	settingsBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		surface.SetDrawColor( hovered and c_255 or c_200 )
		surface.SetMaterial( mat_options )
		surface.DrawTexturedRect( w*0.30, h*0.30, w*0.4, h*0.5 )
		--
	end
	settingsBtn.OnCursorEntered = function()
		if setSoundCD > CurTime() then return end
		surface.PlaySound( sound_hover )
	end
	settingsBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		ADRewards.OpenSettings(seasonInfo)
	end

	local closeBtn = vgui.Create( "DButton", rMenu)
	closeBtn:SetPos( mW*0.96, 0 )
	closeBtn:SetSize( mW*0.04, mH*0.06 )
	closeBtn:SetText( "" )
	closeBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		draw.SimpleText( "❌", "ADRewards_6",  w*0.5, h*0.5, hovered and c_255 or c_200, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	closeBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	closeBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		ADRewards.RewardsMenu:Remove()
	end
	/*---------------------------------------------------------------------------
	Tasks
	---------------------------------------------------------------------------*/
	local taskPnl_w, taskPnl_h, taskPnl_pH = mW*0.22, mH*0.325, mH*0.14
	local taskPanelsPos = {
		[1] = mW*0.28,
		[2] = mW*0.51,
		[3] = mW*0.74,
	}
	ADRewards.BuildTask = function(num, moduleName)
		local taskInfo = ADRewards.Tasks[moduleName]
		local taskDone = ply.TasksADR[moduleName].ValNow >= ply.TasksADR[moduleName].ValNeed
		local taskPnl = vgui.Create( "DPanel", rMenu)
		taskPnl:SetPos( taskPanelsPos[num], taskPnl_pH )
		taskPnl:SetSize( taskPnl_w, taskPnl_h )
		taskPnl.Paint = function(self, w, h)
			ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_transparent)

			draw.SimpleText( ADRewards.GetPhrase(moduleName), "ADRewards_Bk_6",  w*0.10, h*0.09, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			--draw.DrawText( taskInfo.Description, "ADRewards_L_6",  w*0.10, h*0.23, c_255, TEXT_ALIGN_LEFT )
			--draw.SimpleText( ply.TasksADR[moduleName].ValNow.."/"..ply.TasksADR[moduleName].ValNeed, "ADRewards_Bk_6",  w*0.92, h*0.95, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

			surface.SetFont( "ADRewards_Bk_6" )
			local valneed = "/"..ply.TasksADR[moduleName].ValNeed
			local t_w, t_h = surface.GetTextSize( valneed )
			local valnow = ply.TasksADR[moduleName].ValNow
			draw.SimpleText( valnow, "ADRewards_Bk_6",  w*0.92-t_w, h*0.95, valnow == ply.TasksADR[moduleName].ValNeed and c_255 or c_transparent4, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( valneed, "ADRewards_Bk_6",  w*0.92, h*0.95, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		end

		local taskScroll = vgui.Create( "DScrollPanel", taskPnl )
		taskScroll:SetPos( taskPnl:GetWide()*0.10, taskPnl:GetTall()*0.22 )
		taskScroll:SetSize( taskPnl:GetWide()*0.80, taskPnl:GetTall()*0.60 )
		taskScroll.Paint = function(self, w, h)
			--draw.RoundedBox( 0, 0, 0, w, h , Color(0, 0, 0,245) )
		end
		local butcol = c_transparent4
		taskScroll.VBar.Paint = function(self, w, h)
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, c_vbar )
		end
		taskScroll.VBar.btnUp.Paint = function(self, w, h)
			if taskScroll.VBar.Scroll != 0 then return end
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
		end
		taskScroll.VBar.btnDown.Paint = function(self, w, h)
			if taskScroll.VBar.Scroll != taskScroll.VBar.CanvasSize then return end
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
		end
		taskScroll.VBar.btnGrip.Paint = function(self, w, h)
			--if taskScroll.VBar.Scroll == 0 or taskScroll.VBar.Scroll == taskScroll.VBar.CanvasSize then return end
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
		end

		local taskDescription = taskScroll:Add( "DLabel" )
		taskDescription:SetPos( 0, 0 )
		taskDescription:SetSize( taskScroll:GetWide()*0.95, 0 )
		taskDescription:SetFont( "ADRewards_6" )
		taskDescription:SetTextColor(c_220) 
		taskDescription:SetText( ADRewards.GetPhrase(taskInfo.Description) )
		taskDescription:SetWrap( true )
		taskDescription:SetAutoStretchVertical( true )

		if taskDone then
			local donePnl = vgui.Create( "DPanel", taskPnl)
			donePnl:Dock(FILL)
			donePnl.Paint = function(self, w, h)
				ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)
				surface.SetDrawColor( 255, 255, 255 )
				surface.SetMaterial( mat_check )
				local size = w*0.20
				surface.DrawTexturedRect( w*0.50-(size*0.50), h*0.50-(size*0.50), size, size )
			end
		elseif !ADRewards.Config.TasksForClaim and !ADRewards.SeasonNow.STRewards then
			local closedPnl = vgui.Create( "DPanel", taskPnl)
			closedPnl:Dock(FILL)
			closedPnl.Paint = function(self, w, h)
				--ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)

				adrdraw_Stencil(function()
					ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)
				end,
				function()
					local x, y = self:LocalToScreen(0, 0)
					surface.SetMaterial( mat_blur )
				    surface.SetDrawColor( 255, 255, 255 )
				    for i = 1, 6 do
						mat_blur:SetFloat( "$blur", (i*0.45) * 0.7 )
						mat_blur:Recompute()
						render.UpdateScreenEffectTexture()
						surface.DrawTexturedRect( -x, -y, sW, sH )
					end
					draw.NoTexture()
				end, true)

				surface.SetDrawColor( 255, 255, 255 )
				surface.SetMaterial( mat_lock )
				local size = w*0.17
				surface.DrawTexturedRect( w*0.50-(size*0.50), h*0.50-(size*0.50), size, size )
			end
		end

	end

	local tnum = 1
	for k, v in SortedPairs(ply.TasksADR) do
		ADRewards.BuildTask(tnum, k)
		tnum = tnum + 1
	end
	/*---------------------------------------------------------------------------
	Middle Panels
	---------------------------------------------------------------------------*/

	local premBtn = vgui.Create( "DButton", rMenu)
	premBtn:SetPos( mW*0.65, mH*0.50 )
	premBtn:SetSize( mW*0.10, mH*0.06 )
	premBtn:SetText( "" )
	premBtn.Paint = function(self, w, h)
		local theme = seasonInfo.STheme
		local hovered = self:IsHovered()
		local maincolor = ADRewards.Themes[theme].MainColor
		draw.RoundedBox(30, 0, 0, w, h, hovered and Color(maincolor.r+25, maincolor.g+25, maincolor.b+25, maincolor.a) or ADRewards.Themes[theme].MainColor)

		draw.SimpleText( ADRewards.GetPhrase("PREMIUM"), "ADRewards_5",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	premBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	premBtn.DoClick = function()
		surface.PlaySound( sound_click )

		gui.OpenURL( ADRewards.Config.PremiumURL )
	end
	

	local leftBtn = vgui.Create( "DButton", rMenu)
	leftBtn:SetPos( mW*0.78, mH*0.50 )
	leftBtn:SetSize( mW*0.055, mH*0.06 )
	leftBtn:SetText( "" )
	leftBtn.Paint = function(self, w, h)
		local theme = seasonInfo.STheme
		local hovered = self:IsHovered()
		local maincolor = ADRewards.Themes[theme].MainColor
		draw.RoundedBox(30, 0, 0, w, h, hovered and Color(maincolor.r+25, maincolor.g+25, maincolor.b+25, maincolor.a) or ADRewards.Themes[theme].MainColor)

		draw.SimpleText( "←", "ADRewards_9",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	leftBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		page = math.Clamp( page - 1, 1, 15 )
		ADRewards.RewardsMenu.rewardsPanel.BuildList(page)
	end

	local rightBtn = vgui.Create( "DButton", rMenu)
	rightBtn:SetPos( mW*0.906, mH*0.50 )
	rightBtn:SetSize( mW*0.055, mH*0.06 )
	rightBtn:SetText( "" )
	rightBtn.Paint = function(self, w, h)
		local theme = seasonInfo.STheme
		local hovered = self:IsHovered()
		local maincolor = ADRewards.Themes[theme].MainColor
		draw.RoundedBox(30, 0, 0, w, h, hovered and Color(maincolor.r+25, maincolor.g+25, maincolor.b+25, maincolor.a) or ADRewards.Themes[theme].MainColor)

		draw.SimpleText( "→", "ADRewards_9",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	rightBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		page = math.Clamp( page + 1, 1, seasonInfo.Pages )
		ADRewards.RewardsMenu.rewardsPanel.BuildList(page)
	end

	/*---------------------------------------------------------------------------
	Rewards
	---------------------------------------------------------------------------*/
	ADRewards.RewardsMenu.rewardsPanel = vgui.Create( "DPanel", rMenu)
	local rewardsPanel = ADRewards.RewardsMenu.rewardsPanel
	rewardsPanel:SetPos( mW*0.28, mH*0.59 )
	rewardsPanel:SetSize( mW*0.68, mH*0.33 )
	rewardsPanel.Paint = function(self, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(0,0,255,222))

		draw.RoundedBox( 0, w*0.08, h*0.17, 2, h*0.34, c_transparent )

		draw.RoundedBox( 0, w*0.08, h*0.625, 2, h*0.34, c_transparent )
	end

	local rW, rH = rewardsPanel:GetSize()
	local r_w, r_h = rW*0.115, rH*0.42
	local startpos = rW*0.107
	local widestep = rW*0.13
	
	rewardsPanel.BuildList = function(page)
		rewardsPanel:Clear()

		local startc = ( (page-1) * 7 ) + 1
		local endc = startc+7

		for i = startc, endc do
			local numpos = 8-(endc-i)
			local groupPanel = vgui.Create( "DPanel", rewardsPanel)
			groupPanel:SetPos( startpos + ( widestep * ( numpos-1 ) ), 0 )
			groupPanel:SetSize( r_w, rH )
			groupPanel.Paint = function(self, w, h)
				draw.SimpleText( i, "ADRewards_L_6",  w*0.5, 0, c_255, TEXT_ALIGN_CENTER )
			end
			/*----------------*/
			/*-----Default----*/
			/*----------------*/
			local rewardInfo = ADRewards.SeasonNow.SRewards["Default"][i]
			if rewardInfo and !ADRewards.Rewards[rewardInfo.Module] then
				rewardInfo = false
			end
			local rewardBtn = vgui.Create( "DButton", groupPanel)
			rewardBtn:SetPos( 0, rH*0.13 )
			rewardBtn:SetSize( r_w, r_h )
			rewardBtn:SetText("")
			rewardBtn.Paint = function(self, w, h)
				--draw.RoundedBox(7, 0, 0, w, h, c_transparent)
				ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_transparent)

				if rewardInfo then
					if self.HandPaint then
						self.HandPaint:PaintManual()
					end

					if ADRewards.Rewards[rewardInfo.Module].MaxAmount > 1 then
						draw.SimpleTextOutlined( string.Comma(rewardInfo.Amount, ","), "ADRewards_5", w*0.90, h*0.75, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, c_ablack )
					end

					if ply.SeasonADR.Rewards[i] then
						if ply.SeasonADR.Rewards[i].Default then
							--draw.RoundedBox(7, 0, 0, w, h, c_ablack)
							ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)
							surface.SetDrawColor( 255, 255, 255 )
							surface.SetMaterial( mat_check )
							surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )
						else
							adrdraw_Stencil(function()
								ADRewards.draw_RoundedTextureBox(7, 1, 1, w-2, h-2, c_180)
							end,
							function()
								ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_180)
							end)
						end
					end
					
				else
					surface.SetDrawColor( 255, 255, 255 )
					surface.SetMaterial( mat_none )
					surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )

					if ply.SeasonADR.Rewards[i] and ply.SeasonADR.Rewards[i].Default then
						ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)
						surface.SetDrawColor( 255, 255, 255 )
						surface.SetMaterial( mat_check )
						surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )
					end
				end
			end
			rewardBtn.OnMousePressed = function(self, keyCode)
				if keyCode != 107 then return end
				if !rewardInfo or !ply.SeasonADR.Rewards[i] or ply.SeasonADR.Rewards[i].Default then return end

				surface.PlaySound( sound_click )

				ply.SeasonADR.Rewards[i].Default = true

				net.Start("adrewards_RewardClaim")
					net.WriteUInt(i, 7)
					net.WriteBool(true) -- isDefault?
				net.SendToServer()
			end
			if rewardInfo then
				local rewardIcon = rewardDrawPanel(rewardBtn, rewardInfo.Module, rewardInfo.Key)
				if rewardIcon then
					rewardIcon:SetPaintedManually( true )
					rewardBtn.HandPaint = rewardIcon
				elseif !rewardIcon and ADRewards.Rewards[rewardInfo.Module].NetRead then
					local iconTbl = {
						Module = rewardInfo.Module,
						Key = rewardInfo.Key,
						Panel = rewardBtn,
					}
					table.insert(ADRewards.RewardsMenu.WaitRequest["Default"], iconTbl)
					net.Start("adrewards_RewardRequest")
						net.WriteString(rewardInfo.Module)
						net.WriteString(rewardInfo.Key)
					net.SendToServer()
				end
			end
			/*----------------*/
			/*-----Premium----*/
			/*----------------*/
			local rewardInfo = ADRewards.SeasonNow.SRewards["Premium"][i]
			if rewardInfo and !ADRewards.Rewards[rewardInfo.Module] then
				rewardInfo = false
			end
			local rewardPremBtn = vgui.Create( "DButton", groupPanel)
			rewardPremBtn:SetPos( 0, rH*0.585 )
			rewardPremBtn:SetSize( r_w, r_h )
			rewardPremBtn:SetText("")
			rewardPremBtn.Paint = function(self, w, h)
				ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_transparent)

				if rewardInfo then
					if self.HandPaint then
						self.HandPaint:PaintManual()
					end

					if ADRewards.Rewards[rewardInfo.Module].MaxAmount > 1 then
						draw.SimpleTextOutlined( string.Comma(rewardInfo.Amount, ","), "ADRewards_5", w*0.90, h*0.75, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, c_ablack )
					end

					if ply.SeasonADR.Rewards[i] and havePrem then
						if ply.SeasonADR.Rewards[i].Premium then
							ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)
							surface.SetDrawColor( 255, 255, 255 )
							surface.SetMaterial( mat_check )
							surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )
						else
							adrdraw_Stencil(function()
								ADRewards.draw_RoundedTextureBox(7, 1, 1, w-2, h-2, c_180)
							end,
							function()
								ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_180)
							end)
						end
					end
					
				else
					surface.SetDrawColor( 255, 255, 255 )
					surface.SetMaterial( mat_none )
					surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )
				end

				if !havePrem then
					ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)
					if ply.SeasonADR.Rewards[i] and ply.SeasonADR.Rewards[i].Premium then
						surface.SetDrawColor( 255, 255, 255 )
						surface.SetMaterial( mat_check )
						surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )
					end
					surface.SetDrawColor( 255, 255, 255 )
					surface.SetMaterial( mat_lock_outline )
					surface.DrawTexturedRect( w*0.75, h*0.07, w*0.22, h*0.22 )
				end
			end
			rewardPremBtn.OnMousePressed = function(self, keyCode)
				if keyCode != 107 then return end
				if !havePrem then return end
				if !rewardInfo or !ply.SeasonADR.Rewards[i] or ply.SeasonADR.Rewards[i].Premium then return end

				surface.PlaySound( sound_click )

				ply.SeasonADR.Rewards[i].Premium = true

				net.Start("adrewards_RewardClaim")
					net.WriteUInt(i, 7)
					net.WriteBool(false) -- isDefault?
				net.SendToServer()
			end
			if rewardInfo then
				local rewardIcon = rewardDrawPanel(rewardPremBtn, rewardInfo.Module, rewardInfo.Key)
				if rewardIcon then
					rewardIcon:SetPaintedManually( true )
					rewardPremBtn.HandPaint = rewardIcon
				elseif !rewardIcon and ADRewards.Rewards[rewardInfo.Module].NetRead then
					local iconTbl = {
						Module = rewardInfo.Module,
						Key = rewardInfo.Key,
						Panel = rewardPremBtn,
					}
					table.insert(ADRewards.RewardsMenu.WaitRequest["Premium"], iconTbl)
					net.Start("adrewards_RewardRequest")
						net.WriteString(rewardInfo.Module)
						net.WriteString(rewardInfo.Key)
					net.SendToServer()
				end
			end
		end
		if ADRewards.SeasonNow.SRewards.Default[startc] == nil then
			net.Start("adrewards_RewardsRequest")
				net.WriteUInt(startc, 7)
			net.SendToServer()
			return
		end
	end
	rewardsPanel.BuildList(page)
end


/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------SETTINGS----------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/
net.Receive("adrewards_ActionMenu", function(nlen, ply)
	local isList = net.ReadBool()
	if isList then
		local len = (nlen-1)/8
		local compressedJSON = net.ReadData( len )
		local decompressedJSON = util.Decompress( compressedJSON )
		local filestbl =  util.JSONToTable(decompressedJSON)
		if !IsValid(ADRewards.RewardsMenu) then return end
		ADRewards.RewardsMenu.FileList = {}
		for i = 1, #filestbl do
			local filename = string.TrimRight( filestbl[i], ".txt" )
			ADRewards.RewardsMenu.FileList[filename] = true
		end
	else
		local len = (nlen-1)/8
		local compressedJSON = net.ReadData( len )
		local decompressedJSON = util.Decompress( compressedJSON )
		local filestbl =  util.JSONToTable(decompressedJSON)

		local stheme = ADRewards.Themes[filestbl.STheme] and filestbl.STheme or "Default"
		ADRewards.RewardsMenu.SetInfo(stheme, filestbl.SName, filestbl.SFile, filestbl.STime, filestbl.STRewards, filestbl.SRewards)
	end
end)

local function drawHint(parentPnl, hintX, hintY, hintW, hintT, header, desc)
	local sW, sH = ScrW(), ScrH()
	local hintPnl = vgui.Create( "DPanel", parentPnl)
	hintPnl:SetPos( hintX, hintY )
	hintPnl:SetSize( hintW, hintT )
	hintPnl.Paint = function(self, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0))
		local hovered = self:IsHovered()
		surface.SetDrawColor( hovered and c_255 or c_transparent3 )
		surface.SetMaterial( mat_hint )
		surface.DrawTexturedRect( -w*0.07, -h*0.07, w*1.14, h*1.14 )
	end
	hintPnl.OnCursorEntered = function(self)
		if IsValid(ADRewards.HintPanel) then return end
		self.HintDraw = CurTime()+0.3
	end
	hintPnl.OnCursorExited = function(self)
		if IsValid(ADRewards.HintPanel) then ADRewards.HintPanel:Remove() end
		self.HintDraw = nil
	end
	hintPnl.Think = function(self)
		if self.HintDraw and self.HintDraw < CurTime() then
			self.ShowHint()
			self.HintDraw = nil
		end
	end

	local headerText = ADRewards.GetPhrase(header)
	local descText = ADRewards.GetPhrase(desc)
	hintPnl.ShowHint = function()
		if IsValid(ADRewards.HintPanel) then ADRewards.HintPanel:Remove() end
		ADRewards.HintPanel = vgui.Create( "DPanel")
		local hX, hY = hintPnl:LocalToScreen(hintPnl:GetWide()*0.5, hintPnl:GetTall())
		local hW, hT = sW*0.14, sH*0.05
		ADRewards.HintPanel:SetPos( hX-(hW*0.5), hY+sH*0.01 )
		ADRewards.HintPanel:SetSize( hW, hT )
		ADRewards.HintPanel.Paint = function(self, w, h)
			adrdraw_Stencil(function()
				ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_ablack)
			end,
			function()
				local x, y = self:LocalToScreen(0, 0)
				surface.SetMaterial( mat_blur )
			    surface.SetDrawColor( 255, 255, 255 )
			    for i = 1, 8 do
					mat_blur:SetFloat( "$blur", (i*0.45) * 0.7 )
					mat_blur:Recompute()
					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRect( -x, -y, sW, sH )
				end
				draw.NoTexture()
			end, true)

			ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_hint)

			adrdraw_Stencil(function()
				ADRewards.draw_RoundedTextureBox(7, 1, 1, w-2, h-2, c_180)
			end,
			function()
				ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_transparent3)
			end)

			draw.SimpleText( headerText, "ADRewards_Bk_6",  w*0.5, sH*0.01, c_220, TEXT_ALIGN_CENTER )
		end
		ADRewards.HintPanel:MakePopup()

		local hintText = vgui.Create( "DLabel", ADRewards.HintPanel)
		hintText:SetPos( ADRewards.HintPanel:GetWide()*0.07, sH*0.035 )
		hintText:SetSize( ADRewards.HintPanel:GetWide()*0.86, ADRewards.HintPanel:GetTall()*0.25 )
		--hintText:SetText("FGfg fg fgd fgcv b cvfrdg ty gbxfg dfg fdg fdg df gdfg dfg dfg dfg dfd gdf bcvbcvx cxz xzc zxdsf gbvcbgdfh gfy t ghj f dfng dfjgjdfg kjdf gjkdfksgknfdsjg dfkmgkmdf gjkdfk gidf gkjdflmg dskjfgkfd kgdfgsdjkdslf e rkj sdkfkfdgk dfkg fdkg fdjgn jj")
		hintText:SetText(descText)
		hintText:SetFont( "ADRewards_6" )
		hintText:SetTextColor(c_220) 
		hintText:SetWrap( true )
		hintText:SetAutoStretchVertical( true )
		--ADRewards.HintPanel:InvalidateLayout(true)
		--ADRewards.HintPanel:SizeToChildren(false, true)
		hintText.OnSizeChanged = function( self, new_w, new_h ) -- fix stretch
			surface.SetFont("ADRewards_6")
			local _, text_h = surface.GetTextSize("|")
			local rT = ADRewards.HintPanel:GetTall()
			local total_h = new_h + hT
			ADRewards.HintPanel:SetTall(total_h)
		end
	end

	return hintPnl
end


local function rewardsChooseList(istask, num, isprem)
	if !IsValid(ADRewards.RewardsMenu) then return end
	local rMenu = ADRewards.RewardsMenu
	local mW, mH = rMenu:GetWide(), rMenu:GetTall()
	local rewardInfo

	local rModule
	local rAmount = 1
	local rKey

	local rchoosePanel = vgui.Create( "DPanel", rMenu)
	rchoosePanel:SetPos( 0, 0 )
	rchoosePanel:SetSize( mW, mH )
	rchoosePanel.Paint = function(self, w, h)
		local bgimage = ADRewards.Themes[ADRewards.RewardsMenu.SeasonInfo.CurTheme].BgImage
		surface.SetDrawColor( 100, 100, 100, 250 )
		surface.SetMaterial( bgimage )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	rchoosePanel.SetKey = function(key)
		rKey = key
	end
	ADRewards.RewardsMenu.rchoosePanel = rchoosePanel
	/*-------------------*/
	/*----Trans Panel----*/
	/*-------------------*/
	local transPanel = vgui.Create( "DPanel", rchoosePanel)
	transPanel:SetPos( rchoosePanel:GetWide()*0.28, rchoosePanel:GetTall()*0.15 )
	transPanel:SetSize( rchoosePanel:GetWide()*0.44, rchoosePanel:GetTall()*0.70 )
	transPanel.Paint = function(self, w, h)
		draw.RoundedBox(7, 0, 0, w, h, c_transparent)

		draw.SimpleText( ADRewards.GetPhrase("Reward"), "ADRewards_7",  w*0.5, h*0.03, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )


		draw.SimpleText( ADRewards.GetPhrase("Module"), "ADRewards_6",  w*0.26, h*0.16, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.RoundedBox(7, w*0.05, h*0.14, w*0.42, h*0.65, c_transparent)


		draw.RoundedBox(7, w*0.53, h*0.39, w*0.42, h*0.16, c_transparent)
		--draw.SimpleText( "Amount", "ADRewards_6",  w*0.72, h*0.515, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		local isblocked = self.nameEntry:GetDisabled()
		draw.RoundedBox(7, w*0.53, h*0.57, w*0.42, h*0.22, c_transparent)
		draw.SimpleText( rModule and ADRewards.Rewards[rModule].DrawKey or ADRewards.GetPhrase("Name"), "ADRewards_6",  w*0.74, h*0.60, isblocked and c_150 or c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	/*----------------*/
	/*----Scroll 1----*/
	/*----------------*/
	local rewardsScroll = vgui.Create( "DScrollPanel", transPanel )
	rewardsScroll:SetPos( transPanel:GetWide()*0.07, transPanel:GetTall()*0.23 )
	rewardsScroll:SetSize( transPanel:GetWide()*0.38, transPanel:GetTall()*0.54 )
	rewardsScroll.Paint = function(self, w, h)
		--draw.RoundedBox(7, 0, 0, w, h, Color(255,0,0))
	end
	local butcol = c_transparent4
	rewardsScroll.VBar.Paint = function(self, w, h)
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, c_vbar )
	end
	rewardsScroll.VBar.btnUp.Paint = function(self, w, h)
		if rewardsScroll.VBar.Scroll != 0 then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end
	rewardsScroll.VBar.btnDown.Paint = function(self, w, h)
		if rewardsScroll.VBar.Scroll != rewardsScroll.VBar.CanvasSize then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end
	rewardsScroll.VBar.btnGrip.Paint = function(self, w, h)
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end

	for k, v in SortedPairs(ADRewards.Rewards) do
		if istask and !v.CanTaskReward then continue end
		local rewardBtn = rewardsScroll:Add( "DButton" )
		rewardBtn:SetText( "" )
		rewardBtn:Dock( TOP )
		rewardBtn:SetTall(rewardsScroll:GetTall()*0.14)
		rewardBtn:DockMargin( 0, 0, 0, 0 )
		rewardBtn.Paint = function(self, w, h)
			--draw.RoundedBox(7, 0, 0, w, h, Color(255,0,0))
		end
		rewardBtn.DoClick = function(self)
			if IsValid(rchoosePanel.iconPnl.RewardPnl) then rchoosePanel.iconPnl.RewardPnl:Remove() end
			if IsValid(transPanel.hintPnl) then transPanel.hintPnl:Remove() end

			surface.PlaySound( sound_click )

			transPanel.nameEntry:SetValue( "" )
			rModule = k
			transPanel.aDNumber:SetMax(ADRewards.Rewards[rModule].MaxAmount or 1)
			transPanel.aDNumber:SetValue(1)

			if ADRewards.Rewards[rModule].MaxAmount > 1 then
				transPanel.aDNumber:BlockPanel(false)
			else
				transPanel.aDNumber:BlockPanel(true)
			end

			if ADRewards.Rewards[rModule].GetKey then
				transPanel.nameEntry:BlockPanel(false)
				if ADRewards.Rewards[rModule].LangPhrase then
					transPanel.hintPnl = drawHint(transPanel, transPanel:GetWide()*0.90, transPanel:GetTall()*0.59, transPanel:GetWide()*0.04, transPanel:GetWide()*0.04, rModule, ADRewards.Rewards[rModule].LangPhrase)
				end
			else
				transPanel.nameEntry:BlockPanel(true)
				rewardDrawPanel(rchoosePanel.iconPnl, rModule, rKey)
			end
		end

		local moduleName = k
		local moduleLabel = vgui.Create( "DLabel", rewardBtn )
		moduleLabel:SetPos( rewardsScroll:GetWide()*0.05, rewardBtn:GetTall()*0.18 )
		moduleLabel:SetSize( rewardsScroll:GetWide()*0.85, rewardBtn:GetTall() )
		moduleLabel:SetFont( "ADRewards_6" )
		moduleLabel:SetTextColor(c_220) 
		moduleLabel:SetText( moduleName )
		moduleLabel:SetWrap( true )
		moduleLabel:SetAutoStretchVertical( true )
		moduleLabel.OnSizeChanged = function( self, new_w, new_h ) -- fix stretch
			surface.SetFont("ADRewards_6")
			local _, text_h = surface.GetTextSize("|")
			local rT = rewardBtn:GetTall()
			local total_h = new_h + (text_h*0.45)
			rewardBtn:SetTall(total_h)
		end
	end
	/*------------------*/
	/*----Name Entry----*/
	/*------------------*/
	transPanel.nameEntry = vgui.Create( "DTextEntry", transPanel )
	local nameEntry = transPanel.nameEntry
	nameEntry:SetPos( transPanel:GetWide()*0.56, transPanel:GetTall()*0.67 )
	nameEntry:SetSize( transPanel:GetWide()*0.36, transPanel:GetTall()*0.10 )
	nameEntry:SetPlaceholderText( "  "..ADRewards.GetPhrase("Reward_name") )
	nameEntry:SetPlaceholderColor( c_180 )
	nameEntry:SetCursorColor( c_180 )
	nameEntry:SetUpdateOnType( false )
	nameEntry.OnLoseFocus = function( self )
		self:OnValueChange( self:GetText() )
	end
	nameEntry.OnValueChange = function( self, text )
		if text == "" then rKey = nil return end
		if !rModule then return end
		local key = ADRewards.Rewards[rModule].GetKey(text)
		if !key and key == nil then
			net.Start("adrewards_RewardRequest")
				net.WriteString(rModule)
				net.WriteString(text)
			net.SendToServer()
			return
		end

		rKey = key

		rewardDrawPanel(rchoosePanel.iconPnl, rModule, rKey)
	end
	nameEntry.Paint = function(self, w, h)
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
		draw.RoundedBox(5, 0, 0, w, h, c_transparent2)
		local isblocked = self:GetDisabled()
		if isblocked then
			surface.SetDrawColor( 220, 220, 220 )
			surface.SetMaterial( mat_lock )
			surface.DrawTexturedRect( w*0.83, h*0.25, h*0.50, h*0.50 )
		end
	end
	nameEntry.BlockPanel = function( self, block )
		if block then
			self:SetDisabled( true )
			self:SetPlaceholderColor( c_150 )
		else
			self:SetDisabled( false )
			self:SetPlaceholderColor( c_180 )
		end
	end
	nameEntry:BlockPanel(true)
	nameEntry:SetFont( "ADRewards_L_6" )
	nameEntry:SetTextColor( color_white )
	nameEntry:SetPaintBackground( false )
	/*----------------*/
	/*-----Amount-----*/
	/*----------------*/
	transPanel.aDNumber = vgui.Create( "DNumberWang", transPanel )
	local amountNumber = transPanel.aDNumber
	amountNumber:SetPos( transPanel:GetWide()*0.56, transPanel:GetTall()*0.42 )
	amountNumber:SetSize( transPanel:GetWide()*0.36, transPanel:GetTall()*0.10 )
	amountNumber:SetMin(1)
	amountNumber:SetMax(1)
	amountNumber:SetValue( 1 )
	amountNumber:SetDecimals(0)
	amountNumber:SetUpdateOnType( true )
	amountNumber:SetCursorColor( c_180 )
	amountNumber:SetPlaceholderColor( c_180 )
	amountNumber.OnValueChanged = function( self, val )
		local max = ADRewards.Rewards[rModule].MaxAmount
		if val > max then
			val = max
		end
		rAmount = val
	end
	amountNumber.Paint = function(self, w, h)
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
		draw.RoundedBox(5, 0, 0, w, h, c_transparent2)

		--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0))
	end
	amountNumber.BlockPanel = function( self, block )
		if block then
			self:SetDisabled( true )
			self:SetTextColor( c_150 )
		else
			self:SetDisabled( false )
			self:SetTextColor( color_white )
		end
	end
	amountNumber:SetFont( "ADRewards_L_6" )
	amountNumber:SetTextColor( color_white )
	amountNumber:SetPaintBackground( false )
	amountNumber:SetDrawLanguageID( false )
	amountNumber:BlockPanel(true)
	amountNumber.Up.Paint = function( self, w, h )
		draw.SimpleText( "▲", "ADRewards_3",  w*0.4, h*0.5, self:IsHovered() and c_255 or c_150, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	amountNumber.Down.Paint = function( self, w, h )
		draw.SimpleText( "▼", "ADRewards_3",  w*0.4, h*0.5, self:IsHovered() and c_255 or c_150, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	local OldDoClick = amountNumber.Up.DoClick
	amountNumber.Up.DoClick = function( self, w, h )
		OldDoClick()
		surface.PlaySound( sound_click )
	end
	local OldDoClick = amountNumber.Down.DoClick
	amountNumber.Down.DoClick = function( self, w, h )
		OldDoClick()
		surface.PlaySound( sound_click )
	end
	/*--------------*/
	/*-----Icon-----*/
	/*--------------*/
	local iconPanel = vgui.Create( "DPanel", transPanel)
	iconPanel:SetPos( transPanel:GetWide()*0.645, transPanel:GetTall()*0.14 )
	iconPanel:SetSize( transPanel:GetWide()*0.19, transPanel:GetWide()*0.19 )
	iconPanel.Paint = function(self, w, h)
		--draw.RoundedBox(7, 0, 0, w, h, c_transparent)
		ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_transparent)

		if IsValid(self.RewardPnl) then return end
		draw.SimpleText( "?", "ADRewards_9",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		--draw.RoundedBox(7, w*0.05, h*0.19, w*0.38, h*0.54, c_transparent)
		--draw.RoundedBox(7, w*0.75, h*0.19, w*0.20, h*0.33, c_transparent)
	end
	rchoosePanel.iconPnl = iconPanel
	/*-----------------*/
	/*-----CONFIRM-----*/
	/*-----------------*/
	local confirmBtn = vgui.Create( "DButton", transPanel)
	confirmBtn:SetPos( transPanel:GetWide()*0.05, transPanel:GetTall()*0.84 )
	confirmBtn:SetSize( transPanel:GetWide()*0.42, transPanel:GetTall()*0.12 )
	confirmBtn:SetText("")
	confirmBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
		draw.SimpleText( ADRewards.GetPhrase("Confirm"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	confirmBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	
	confirmBtn.DoClick = function()
		if !rModule then return end
		if ADRewards.Rewards[rModule].GetKey and !rKey then return end

		if istask then
			ADRewards.RewardsMenu.SeasonInfo.TReward = {
				Module = rModule,
				Amount = rAmount,
				Key = rKey
			}

			ADRewards.RewardsMenu.updateFile = true

			local taskrewardIcon = rewardDrawPanel(ADRewards.RewardsMenu.taskIconContainer, rModule, rKey)
			taskrewardIcon:SetPaintedManually( true )
			ADRewards.RewardsMenu.taskIconContainer.HandPaint = taskrewardIcon
		else
			local rtype = isprem and "Premium" or "Default"

			ADRewards.RewardsMenu.SeasonInfo.Rewards[rtype][num] = {
				Module = rModule,
				Amount = rAmount,
				Key = rKey
			}

			ADRewards.RewardsMenu.updateFile = true

			local checknum = num-1
			while checknum > 0 and !ADRewards.RewardsMenu.SeasonInfo.Rewards[rtype][checknum] do -- check if the cells were empty before
				ADRewards.RewardsMenu.SeasonInfo.Rewards[rtype][checknum] = false
				checknum = checknum - 1
			end
			if ADRewards.RewardsMenu.DNumber:GetValue() < num then
				ADRewards.RewardsMenu.DNumber:SetValue(num)
			end

			ADRewards.RewardsMenu.rewardsPanel.BuildList( math.ceil(num/7) )
		end

		surface.PlaySound( sound_click )

		rchoosePanel:Remove()
	end

	local cancelBtn = vgui.Create( "DButton", transPanel)
	cancelBtn:SetPos( transPanel:GetWide()*0.53, transPanel:GetTall()*0.84 )
	cancelBtn:SetSize( transPanel:GetWide()*0.42, transPanel:GetTall()*0.12 )
	cancelBtn:SetText("")
	cancelBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
		draw.SimpleText( ADRewards.GetPhrase("Cancel"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	cancelBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	cancelBtn.DoClick = function()
		surface.PlaySound( sound_click )

		rchoosePanel:Remove()
	end
end

function ADRewards.OpenSettings(started)
	local ply = LocalPlayer()
	if !ADRewards.Config.Admins[ply:GetUserGroup()] then return end
	if IsValid(ADRewards.RewardsMenu) then ADRewards.RewardsMenu:Remove() end
	local sW, sH = ScrW(), ScrH()

	local page = 1

	ADRewards.RewardsMenu = vgui.Create( "DFrame" )
	ADRewards.RewardsMenu:SetPos( sW*0.25, sH*0.25 )
	ADRewards.RewardsMenu:SetSize( sW*0.50, sH*0.50 )
	ADRewards.RewardsMenu:SetTitle( "" )
	ADRewards.RewardsMenu:SetVisible( true )
	ADRewards.RewardsMenu:SetDraggable( false )
	ADRewards.RewardsMenu:ShowCloseButton( false )
	ADRewards.RewardsMenu:MakePopup()
	ADRewards.RewardsMenu.IsSettings = true
	ADRewards.RewardsMenu.updateFile = true
	ADRewards.RewardsMenu.SeasonInfo = {
		CurTheme = "Default",
		SName = "SEASON NAME",
		SFile = "unique_name",
		SDays = 1,
		TReward = false,
		Rewards = {
			Default = {},
			Premium = {},
		},
	}
	if ADRewards.SeasonNow then
		ADRewards.RewardsMenu.SeasonInfo.CurTheme = ADRewards.SeasonNow.STheme
	end
	ADRewards.RewardsMenu.WaitRequest = {
		Default = {},
		Premium = {}
	}
	local timeEnd = os.time()+((ADRewards.RewardsMenu.SeasonInfo.SDays-1)*86400)
	local ddata = os.date( "*t" , timeEnd )
	local allsecs = (ddata.hour*3600)+(ddata.min*60)+ddata.sec
	timeEnd = timeEnd + (86400 - allsecs)
	ADRewards.RewardsMenu.SetInfo = function(stheme, sname, sfile, sdays, treward, rewards)
		local sInfo = ADRewards.RewardsMenu.SeasonInfo
		sInfo.CurTheme = stheme or "Default"

		ADRewards.RewardsMenu.snameEntry:SetValue( sname or "" )
		sInfo.SName = sname or "SEASON NAME"

		ADRewards.RewardsMenu.sfileEntry:SetValue( sfile or "" )
		sInfo.SFile = sfile or "unique_name"

		ADRewards.RewardsMenu.DNumber:SetValue( sdays or 1 )

		ADRewards.RewardsMenu.SeasonInfo.TReward = treward
		if ADRewards.RewardsMenu.SeasonInfo.TReward then
			local trModule = ADRewards.RewardsMenu.SeasonInfo.TReward.Module
			local trKey = ADRewards.RewardsMenu.SeasonInfo.TReward.Module
			rewardDrawPanel(ADRewards.RewardsMenu.taskIconContainer, trModule, trKey)
		else
			ADRewards.RewardsMenu.taskIconContainer:Clear()
		end

		page = 1
		local clearRewards = {
			Default = {},
			Premium = {},
		}
		ADRewards.RewardsMenu.SeasonInfo.Rewards = rewards or clearRewards
		ADRewards.RewardsMenu.rewardsPanel.BuildList( page )

		ADRewards.RewardsMenu.updateFile = false
	end
	ADRewards.RewardsMenu.Paint = function(self, w, h)
		local theme = ADRewards.RewardsMenu.SeasonInfo.CurTheme
		local maincolor = ADRewards.Themes[theme].MainColor
		local maincolor2 = ADRewards.Themes[theme].MainColor2

		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( ADRewards.Themes[theme].BgImage )
		surface.DrawTexturedRect( 0, 0, w, h )
		/*------------*/
		/*--Left Box--*/
		/*------------*/
		--draw.RoundedBox(7, w*0.06, h*0.08, w*0.17, h*0.84, maincolor)
		if maincolor2 then
			adrdraw_RoundedBoxGradient(7, w*0.06, h*0.08, w*0.17, h*0.84, maincolor, maincolor2, true)
		else
			ADRewards.draw_RoundedTextureBox(7, w*0.06, h*0.08, w*0.17, h*0.84, maincolor)
		end
		
		draw.SimpleText( "Daily Rewards", "ADRewards_8",  w*0.145, h*0.102, c_255, TEXT_ALIGN_CENTER )

		local circleSeg = 200
		adrdraw_Stencil(function()
			adrdraw_Circle(w*0.145, h*0.27, h*0.08, circleSeg, c_transparent3)
		end,
		function()
			adrdraw_Circle(w*0.145, h*0.27, h*0.09, circleSeg, c_transparent3)
		end)


		draw.SimpleText( "0", "ADRewards_8",  w*0.145, h*0.225, c_255, TEXT_ALIGN_CENTER )
		draw.SimpleText( ADRewards.GetPhrase("DAY"), "ADRewards_L_6",  w*0.145, h*0.275, c_255, TEXT_ALIGN_CENTER )

		--draw.RoundedBox(7, w*0.01, h*0.38, w*0.245, h*0.44, Color(255,0,0,100))
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( ADRewards.Themes[theme].BoxImage )
		surface.DrawTexturedRect( w*0.01, h*0.38, w*0.245, h*0.44 )

		draw.RoundedBox( 7, w*0.072, h*0.83, w*0.145, h*0.07, c_transparent3 )
		draw.SimpleText( ADRewards.RewardsMenu.SeasonInfo.SName, "ADRewards_L_6",  w*0.145, h*0.85, c_255, TEXT_ALIGN_CENTER )
		/*-------------*/
		/*----Settings----*/
		/*-------------*/
		draw.SimpleText( ADRewards.GetPhrase("SETTINGS"), "ADRewards_Bk_6",  w*0.28, h*0.08, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		local drawStatus = ADRewards.GetPhrase("New_File")
		if ADRewards.RewardsMenu.FileList then
			local filename = ADRewards.RewardsMenu.SeasonInfo.SFile
			if ADRewards.RewardsMenu.FileList[filename] and !ADRewards.RewardsMenu.updateFile then drawStatus = ADRewards.GetPhrase("FileStatus")..""..filename end
		end
		draw.SimpleText( drawStatus, "ADRewards_Bk_6",  w*0.96, h*0.08, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		/*---------------------*/
		/*----Middle Panels----*/
		/*---------------------*/
		local leftStartPos = w*0.29
		surface.SetFont( "ADRewards_7" )
		local phraseText = ADRewards.GetPhrase("TIME")
		local p_w, p_h = surface.GetTextSize( phraseText )

		draw.SimpleText( phraseText, "ADRewards_7",  w*0.28, h*0.53, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.RoundedBox(0, leftStartPos+p_w, h*0.50, 2, h*0.06, c_transparent)
		local timenow = os.time()
		local leftTime = timeEnd-timenow
		if (leftTime/3600) > 24 then
			draw.SimpleText( ADRewards.GetPhrase("EXPIRATION_DATE"), "ADRewards_5",  leftStartPos+p_w+w*0.01, h*0.50, c_transparent3, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( os.date( "%d/%m/%Y", timeEnd ), "ADRewards_6",  leftStartPos+p_w+w*0.01, h*0.56, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		else
			draw.SimpleText( ADRewards.GetPhrase("UNTIL_THE_END"), "ADRewards_5",  leftStartPos+p_w+w*0.01, h*0.50, c_transparent3, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( os.date( "!%H:%M:%S", leftTime ), "ADRewards_6",  leftStartPos+p_w+w*0.01, h*0.56, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		end

		draw.SimpleText( page.."/15", "ADRewards_6",  w*0.87, h*0.53, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		/*---------------*/
		/*----Rewards----*/
		/*---------------*/
		local iconSize = w*0.045
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( mat_player )
		surface.DrawTexturedRect( w*0.28, h*0.70-iconSize*0.5, iconSize, iconSize )

		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( mat_premium )
		surface.DrawTexturedRect( w*0.28, h*0.85-iconSize*0.5, iconSize, iconSize )
	end
	ADRewards.RewardsMenu.Think = function(self)
		if input.IsKeyDown(KEY_ESCAPE) then
			ADRewards.RewardsMenu:Remove() 
			gui.HideGameUI()
		end
	end
	ADRewards.RewardsMenu.OnRemove = function(self)
		if IsValid(ADRewards.HintPanel) then ADRewards.HintPanel:Remove() end
	end
	
	net.Start("adrewards_ActionMenu")
		net.WriteUInt(1, 3) -- action type
	net.SendToServer()


	local rMenu = ADRewards.RewardsMenu
	local mW, mH = rMenu:GetWide(), rMenu:GetTall()

	if started then
		local backSoundCD = CurTime() + 0.2
		local backBtn = vgui.Create( "DButton", rMenu)
		backBtn:SetPos( mW*0.92, 0 )
		backBtn:SetSize( mW*0.04, mH*0.06 )
		backBtn:SetText( "" )
		backBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			surface.SetDrawColor( hovered and c_255 or c_200 )
			surface.SetMaterial( mat_back )
			surface.DrawTexturedRect( w*0.25, h*0.25, w*0.5, h*0.6 )
			--
		end
		backBtn.OnCursorEntered = function()
			if backSoundCD > CurTime() then return end
			surface.PlaySound( sound_hover )
		end
		backBtn.DoClick = function(self)
			surface.PlaySound( sound_click )

			ADRewards.OpenRewardsMenu()
		end
	end

	local closeBtn = vgui.Create( "DButton", rMenu)
	closeBtn:SetPos( mW*0.96, 0 )
	closeBtn:SetSize( mW*0.04, mH*0.06 )
	closeBtn:SetText( "" )
	closeBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		draw.SimpleText( "❌", "ADRewards_6",  w*0.5, h*0.5, hovered and c_255 or c_200, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	closeBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	closeBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		ADRewards.RewardsMenu:Remove()
	end
	/*---------------------------------------------------------------------------
	Settings
	---------------------------------------------------------------------------*/
	/*----------*/
	/*--Themes--*/
	/*----------*/
	local themesPnl = vgui.Create( "DPanel", rMenu)
	themesPnl:SetPos( mW*0.28, mH*0.14 )
	themesPnl:SetSize( mW*0.18, mH*0.325 )
	themesPnl.Paint = function(self, w, h)
		draw.RoundedBox(7, 0, 0, w, h, c_transparent)

		draw.SimpleText( ADRewards.GetPhrase("Themes"), "ADRewards_Bk_6",  w*0.5, h*0.05, c_255, TEXT_ALIGN_CENTER )
	end

	drawHint(themesPnl, themesPnl:GetWide()*0.85, themesPnl:GetTall()*0.04, themesPnl:GetWide()*0.11, themesPnl:GetWide()*0.11, "Themes", "ThemesHint")


	local themesScroll = vgui.Create( "DScrollPanel", themesPnl )
	themesScroll:SetPos( themesPnl:GetWide()*0.07, themesPnl:GetTall()*0.20 )
	themesScroll:SetSize( themesPnl:GetWide()*0.86, themesPnl:GetTall()*0.75 )
	themesScroll.Paint = function(self, w, h)
		--draw.RoundedBox( 0, 0, 0, w, h , Color(0, 0, 0,245) )
	end
	local butcol = c_transparent4
	themesScroll.VBar.Paint = function(self, w, h)
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, c_vbar )
	end
	--themesScroll.VBar:SetWide(themesScroll.VBar:GetWide()*0.5)
	themesScroll.VBar.btnUp.Paint = function(self, w, h)
		if themesScroll.VBar.Scroll != 0 then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end
	themesScroll.VBar.btnDown.Paint = function(self, w, h)
		if themesScroll.VBar.Scroll != themesScroll.VBar.CanvasSize then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end
	themesScroll.VBar.btnGrip.Paint = function(self, w, h)
		--if themesScroll.VBar.Scroll == 0 or themesScroll.VBar.Scroll == themesScroll.VBar.CanvasSize then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end

	for k, v in SortedPairs(ADRewards.Themes) do
		local themeBtn = themesScroll:Add( "DButton" )
		themeBtn:SetText( "" )
		themeBtn:Dock( TOP )
		themeBtn:SetTall(themesScroll:GetTall()*0.17)
		themeBtn:DockMargin( 0, 0, 0, 5 )
		themeBtn.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, h, h, v.MainColor)
			local hovered = self:IsHovered()
			draw.SimpleText( k, "ADRewards_6",  h+w*0.06, h*0.5, c_255, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		themeBtn.DoClick = function(self)
			surface.PlaySound( sound_click )

			ADRewards.RewardsMenu.SeasonInfo.CurTheme = k
			ADRewards.RewardsMenu.updateFile = true
		end
	end

	/*--------*/
	/*--Name--*/
	/*--------*/

	local seasonnamePnl = vgui.Create( "DPanel", rMenu)
	seasonnamePnl:SetPos( mW*0.48, mH*0.14 )
	seasonnamePnl:SetSize( mW*0.18, mH*0.1525 )
	seasonnamePnl.Paint = function(self, w, h)
		draw.RoundedBox(7, 0, 0, w, h, c_transparent)

		draw.SimpleText( ADRewards.GetPhrase("Season_Name"), "ADRewards_Bk_6",  w*0.5, h*0.098, c_255, TEXT_ALIGN_CENTER )
	end

	drawHint(seasonnamePnl, seasonnamePnl:GetWide()*0.87, seasonnamePnl:GetTall()*0.09, seasonnamePnl:GetWide()*0.11, seasonnamePnl:GetWide()*0.11, "Season_Name", "SNameHint")

	local seasonnameEntry = vgui.Create( "DTextEntry", seasonnamePnl )
	seasonnameEntry:SetPos( seasonnamePnl:GetWide()*0.07, seasonnamePnl:GetTall()*0.48 )
	seasonnameEntry:SetSize( seasonnamePnl:GetWide()*0.86, seasonnamePnl:GetTall()*0.40 )
	seasonnameEntry:SetPlaceholderText( "  "..ADRewards.GetPhrase("Season_Name") )
	seasonnameEntry:SetPlaceholderColor( c_180 )
	seasonnameEntry:SetCursorColor( c_180 )
	seasonnameEntry:SetUpdateOnType( true )
	--seasonnameEntry:SetValue( ADRewards.RewardsMenu.SeasonInfo.SName )
	seasonnameEntry.OnValueChange = function( self, text )
		ADRewards.RewardsMenu.SeasonInfo.SName = text
		ADRewards.RewardsMenu.updateFile = true
	end
	
	seasonnameEntry.Paint = function(self, w, h)
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
		draw.RoundedBox(5, 0, 0, w, h, c_transparent2)

		--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0))
	end
	seasonnameEntry:SetFont( "ADRewards_L_6" )
	seasonnameEntry:SetTextColor( color_white )
	seasonnameEntry:SetPaintBackground( false )
	rMenu.snameEntry = seasonnameEntry

	/*--------*/
	/*--File--*/
	/*--------*/

	local filenamePnl = vgui.Create( "DPanel", rMenu)
	filenamePnl:SetPos( mW*0.48, mH*0.3125 )
	filenamePnl:SetSize( mW*0.18, mH*0.1525 )
	filenamePnl.Paint = function(self, w, h)
		draw.RoundedBox(7, 0, 0, w, h, c_transparent)

		draw.SimpleText( ADRewards.GetPhrase("File_Name"), "ADRewards_Bk_6",  w*0.5, h*0.098, c_255, TEXT_ALIGN_CENTER )
	end

	drawHint(filenamePnl, filenamePnl:GetWide()*0.87, filenamePnl:GetTall()*0.09, filenamePnl:GetWide()*0.11, filenamePnl:GetWide()*0.11, "File_Name", "SFileHint")

	local filenameEntry = vgui.Create( "DTextEntry", filenamePnl )
	filenameEntry:SetPos( filenamePnl:GetWide()*0.07, filenamePnl:GetTall()*0.48 )
	filenameEntry:SetSize( filenamePnl:GetWide()*0.86, filenamePnl:GetTall()*0.40 )
	filenameEntry:SetPlaceholderText( "  "..ADRewards.GetPhrase("File_Name") )
	filenameEntry:SetPlaceholderColor( c_180 )
	filenameEntry:SetCursorColor( c_180 )
	filenameEntry:SetUpdateOnType( true )
	--filenameEntry:SetValue( ADRewards.RewardsMenu.SeasonInfo.SFile )
	filenameEntry.OnValueChange = function( self, text )
		ADRewards.RewardsMenu.SeasonInfo.SFile = text
		ADRewards.RewardsMenu.updateFile = true
	end
	
	filenameEntry.Paint = function(self, w, h)
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
		draw.RoundedBox(5, 0, 0, w, h, c_transparent2)

		--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0))
	end
	filenameEntry:SetFont( "ADRewards_L_6" )
	filenameEntry:SetTextColor( color_white )
	filenameEntry:SetPaintBackground( false )
	rMenu.sfileEntry = filenameEntry

	/*--------*/
	/*--Time--*/
	/*--------*/

	local timePnl = vgui.Create( "DPanel", rMenu)
	timePnl:SetPos( mW*0.68, mH*0.14 )
	timePnl:SetSize( mW*0.12, mH*0.1525 )
	timePnl.Paint = function(self, w, h)
		draw.RoundedBox(7, 0, 0, w, h, c_transparent)

		draw.SimpleText( ADRewards.GetPhrase("Time"), "ADRewards_Bk_6",  w*0.5, h*0.098, c_255, TEXT_ALIGN_CENTER )
	end

	drawHint(timePnl, timePnl:GetWide()*0.80, timePnl:GetTall()*0.09, timePnl:GetWide()*0.16, timePnl:GetWide()*0.16, "Time", "TimeHint")

	local dayNumber = vgui.Create( "DNumberWang", timePnl )
	dayNumber:SetPos( timePnl:GetWide()*0.15, timePnl:GetTall()*0.48 )
	dayNumber:SetSize( timePnl:GetWide()*0.70, timePnl:GetTall()*0.40 )
	dayNumber:SetMin(1)
	dayNumber:SetMax(105)
	dayNumber:SetValue( 1 )
	dayNumber:SetDecimals(0)
	dayNumber:SetUpdateOnType( true )
	dayNumber:SetCursorColor( c_180 )
	dayNumber.OnValueChanged = function( self, val )
		local max = self:GetMax()
		if val > max then val = max end
		ADRewards.RewardsMenu.SeasonInfo.SDays = val
		local tempEnd = os.time()+((ADRewards.RewardsMenu.SeasonInfo.SDays-1)*86400)
		local ddata = os.date( "*t" , tempEnd )
		local allsecs = (ddata.hour*3600)+(ddata.min*60)+ddata.sec
		timeEnd = tempEnd + (86400 - allsecs)
		ADRewards.RewardsMenu.updateFile = true
	end
	dayNumber.Paint = function(self, w, h)
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
		draw.RoundedBox(5, 0, 0, w, h, c_transparent2)

		--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0))
	end
	dayNumber:SetFont( "ADRewards_L_6" )
	dayNumber:SetTextColor( color_white )
	dayNumber:SetPaintBackground( false )
	dayNumber:SetDrawLanguageID( false )
	dayNumber.Up.Paint = function( self, w, h )
		draw.SimpleText( "▲", "ADRewards_3",  w*0.4, h*0.5, self:IsHovered() and c_255 or c_150, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	dayNumber.Down.Paint = function( self, w, h )
		draw.SimpleText( "▼", "ADRewards_3",  w*0.4, h*0.5, self:IsHovered() and c_255 or c_150, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	local OldDoClick = dayNumber.Up.DoClick
	dayNumber.Up.DoClick = function( self, w, h )
		OldDoClick()
		surface.PlaySound( sound_click )
	end
	local OldDoClick = dayNumber.Down.DoClick
	dayNumber.Down.DoClick = function( self, w, h )
		OldDoClick()
		surface.PlaySound( sound_click )
	end
	ADRewards.RewardsMenu.DNumber = dayNumber

	/*---------------*/
	/*--Task Reward--*/
	/*---------------*/

	local taskrPnl = vgui.Create( "DPanel", rMenu)
	taskrPnl:SetPos( mW*0.68, mH*0.3125 )
	taskrPnl:SetSize( mW*0.12, mH*0.1525 )
	taskrPnl.Paint = function(self, w, h)
		draw.RoundedBox(7, 0, 0, w, h, c_transparent)

		draw.SimpleText( ADRewards.GetPhrase("Task"), "ADRewards_Bk_6",  w*0.5, h*0.098, c_255, TEXT_ALIGN_CENTER )
	end

	drawHint(taskrPnl, taskrPnl:GetWide()*0.80, taskrPnl:GetTall()*0.09, taskrPnl:GetWide()*0.16, taskrPnl:GetWide()*0.16, "Task", "TaskHint")

	local taskriconPnl = vgui.Create( "DPanel", taskrPnl)
	ADRewards.RewardsMenu.taskIconContainer = taskriconPnl
	taskriconPnl:SetPos( taskrPnl:GetWide()*0.5-(taskrPnl:GetTall()*0.25), taskrPnl:GetTall()*0.38 )
	taskriconPnl:SetSize( taskrPnl:GetTall()*0.5, taskrPnl:GetTall()*0.5 )
	taskriconPnl.Paint = function(self, w, h)
		--draw.RoundedBox(8, 0, 0, w, h, c_180)
		local hovered = self:IsHovered()
		local drawColor = hovered and c_220 or c_180

		adrdraw_Stencil(function()
			ADRewards.draw_RoundedTextureBox(8, 1, 1, w-2, h-2, drawColor)
		end,
		function()
			ADRewards.draw_RoundedTextureBox(8, 0, 0, w, h, drawColor)
		end)

		if ADRewards.RewardsMenu.SeasonInfo.TReward then
			if self.HandPaint then
				self.HandPaint:PaintManual()
			end
			draw.SimpleTextOutlined( string.Comma(ADRewards.RewardsMenu.SeasonInfo.TReward.Amount, ","), "ADRewards_4", w*0.5, h*0.65, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, c_ablack )
		else
			draw.SimpleText( "➕", "ADRewards_6",  w*0.5, h*0.45, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	taskriconPnl:SetCursor( "hand" )
	taskriconPnl.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	taskriconPnl.OnMousePressed = function(self, keyCode)
		if keyCode == MOUSE_LEFT then
			surface.PlaySound( sound_click )

			rewardsChooseList(true, false, false)
		elseif keyCode == MOUSE_RIGHT then
			for _, v in ipairs( taskriconPnl:GetChildren() ) do
				v:Remove()
			end

			surface.PlaySound( sound_click )

			ADRewards.RewardsMenu.SeasonInfo.TReward = false
			ADRewards.RewardsMenu.updateFile = true
		end
	end
	/*---------------*/
	/*----Actions----*/
	/*---------------*/

	local actionsPnl = vgui.Create( "DPanel", rMenu)
	actionsPnl:SetPos( mW*0.821, mH*0.14 )
	actionsPnl:SetSize( mW*0.14, mH*0.325 )
	actionsPnl.Paint = function(self, w, h)
		draw.RoundedBox(7, 0, 0, w, h, c_transparent)

		draw.SimpleText( ADRewards.GetPhrase("Actions"), "ADRewards_Bk_6",  w*0.5, h*0.05, c_255, TEXT_ALIGN_CENTER )
	end

	drawHint(actionsPnl, actionsPnl:GetWide()*0.83, actionsPnl:GetTall()*0.04, actionsPnl:GetWide()*0.14, actionsPnl:GetWide()*0.14, "Actions", "ActionsHint")

	local actionsScroll = vgui.Create( "DScrollPanel", actionsPnl )
	--actionsScroll:SetPos( actionsPnl:GetWide()*0.07, actionsPnl:GetTall()*0.05 )
	--actionsScroll:SetSize( actionsPnl:GetWide()*0.86, actionsPnl:GetTall()*0.90 )
	actionsScroll:SetPos( actionsPnl:GetWide()*0.07, actionsPnl:GetTall()*0.20 )
	actionsScroll:SetSize( actionsPnl:GetWide()*0.86, actionsPnl:GetTall()*0.75 )
	actionsScroll.Paint = function(self, w, h)
		--draw.RoundedBox( 0, 0, 0, w, h , Color(0, 0, 0,245) )
	end
	local butcol = c_transparent4
	actionsScroll.VBar.Paint = function(self, w, h)
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, c_vbar )
	end
	--actionsScroll.VBar:SetWide(actionsScroll.VBar:GetWide()*0.5)
	actionsScroll.VBar.btnUp.Paint = function(self, w, h)
		if actionsScroll.VBar.Scroll != 0 then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end
	actionsScroll.VBar.btnDown.Paint = function(self, w, h)
		if actionsScroll.VBar.Scroll != actionsScroll.VBar.CanvasSize then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end
	actionsScroll.VBar.btnGrip.Paint = function(self, w, h)
		--if actionsScroll.VBar.Scroll == 0 or actionsScroll.VBar.Scroll == actionsScroll.VBar.CanvasSize then return end
		draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
	end

	/*-----------*/
	/*----New----*/
	/*-----------*/
	local actionNewBtn = actionsScroll:Add( "DButton" )
	actionNewBtn:SetText( "" )
	actionNewBtn:Dock( TOP )
	actionNewBtn:SetTall(actionsScroll:GetTall()*0.17)
	actionNewBtn:DockMargin( 0, 0, 0, 5 )
	actionNewBtn.Paint = function(self, w, h)
		local textcenter = actionsScroll.VBar.Enabled and ( w*0.5 + ( actionsScroll.VBar:GetWide()*0.5 ) ) or w*0.5
		draw.SimpleText( ADRewards.GetPhrase("New"), "ADRewards_6", textcenter, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	actionNewBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		local confirmPanel = vgui.Create( "DPanel", rMenu)
		confirmPanel:SetPos( 0, 0 )
		confirmPanel:SetSize( mW, mH )
		confirmPanel.Paint = function(self, w, h)
			local bgimage = ADRewards.Themes[ADRewards.RewardsMenu.SeasonInfo.CurTheme].BgImage

			surface.SetDrawColor( Color( 100, 100, 100, 250 ) )
			surface.SetMaterial( bgimage )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		local transPanel = vgui.Create( "DPanel", confirmPanel)
		transPanel:SetPos( confirmPanel:GetWide()*0.25, confirmPanel:GetTall()*0.325 )
		transPanel:SetSize( confirmPanel:GetWide()*0.50, confirmPanel:GetTall()*0.35 )
		transPanel.Paint = function(self, w, h)
			draw.RoundedBox(7, 0, 0, w, h, c_transparent)

			draw.SimpleText( ADRewards.GetPhrase("CreateNew"), "ADRewards_7",  w*0.5, h*0.15, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			draw.DrawText( ADRewards.GetPhrase("ActionNew"), "ADRewards_6", w*0.10, h*0.28, c_255, TEXT_ALIGN_LEFT )
		end
		local confirmBtn = vgui.Create( "DButton", transPanel)
		confirmBtn:SetPos( transPanel:GetWide()*0.10, transPanel:GetTall()*0.7 )
		confirmBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.2 )
		confirmBtn:SetText("")
		confirmBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Confirm"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		confirmBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		confirmBtn.DoClick = function()
			surface.PlaySound( sound_click )

			ADRewards.RewardsMenu.SetInfo(false, false, false, false, false, false)
			confirmPanel:Remove()
		end

		local cancelBtn = vgui.Create( "DButton", transPanel)
		cancelBtn:SetPos( transPanel:GetWide()*0.60, transPanel:GetTall()*0.7 )
		cancelBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.2 )
		cancelBtn:SetText("")
		cancelBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Cancel"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		cancelBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		cancelBtn.DoClick = function()
			surface.PlaySound( sound_click )

			confirmPanel:Remove()
		end
	end
	/*------------*/
	/*----Load----*/
	/*------------*/
	local actionLoadBtn = actionsScroll:Add( "DButton" )
	actionLoadBtn:SetText( "" )
	actionLoadBtn:Dock( TOP )
	actionLoadBtn:SetTall(actionsScroll:GetTall()*0.17)
	actionLoadBtn:DockMargin( 0, 0, 0, 5 )
	actionLoadBtn.Paint = function(self, w, h)
		local textcenter = actionsScroll.VBar.Enabled and ( w*0.5 + ( actionsScroll.VBar:GetWide()*0.5 ) ) or w*0.5
		draw.SimpleText( ADRewards.GetPhrase("Load"), "ADRewards_6", textcenter, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	actionLoadBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		local confirmPanel = vgui.Create( "DPanel", rMenu)
		confirmPanel:SetPos( 0, 0 )
		confirmPanel:SetSize( mW, mH )
		confirmPanel.Paint = function(self, w, h)
			local bgimage = ADRewards.Themes[ADRewards.RewardsMenu.SeasonInfo.CurTheme].BgImage

			surface.SetDrawColor( Color( 100, 100, 100, 250 ) )
			surface.SetMaterial( bgimage )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		local transPanel = vgui.Create( "DPanel", confirmPanel)
		transPanel:SetPos( confirmPanel:GetWide()*0.38, confirmPanel:GetTall()*0.22 )
		transPanel:SetSize( confirmPanel:GetWide()*0.24, confirmPanel:GetTall()*0.56 )
		transPanel.Paint = function(self, w, h)
			draw.RoundedBox(7, 0, 0, w, h, c_transparent)

			draw.SimpleText( ADRewards.GetPhrase("Load"), "ADRewards_7",  w*0.5, h*0.09, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			draw.RoundedBox(7, w*0.10, h*0.19, w*0.80, h*0.54, c_transparent)
		end

		local filesScroll = vgui.Create( "DScrollPanel", transPanel )
		filesScroll:SetPos( transPanel:GetWide()*0.15, transPanel:GetTall()*0.22 )
		filesScroll:SetSize( transPanel:GetWide()*0.70, transPanel:GetTall()*0.48 )
		filesScroll.Paint = function(self, w, h)
			--draw.RoundedBox(7, 0, 0, w, h, Color(255,0,0))
		end
		local butcol = c_transparent4
		filesScroll.VBar.Paint = function(self, w, h)
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, c_vbar )
		end
		filesScroll.VBar.btnUp.Paint = function(self, w, h)
			if filesScroll.VBar.Scroll != 0 then return end
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
		end
		filesScroll.VBar.btnDown.Paint = function(self, w, h)
			if filesScroll.VBar.Scroll != filesScroll.VBar.CanvasSize then return end
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
		end
		filesScroll.VBar.btnGrip.Paint = function(self, w, h)
			draw.RoundedBox( 0, w*0.7, 0, w*0.15, h, butcol )
		end

		for k, v in pairs(ADRewards.RewardsMenu.FileList) do
			local fileBtn = filesScroll:Add( "DButton" )
			fileBtn:SetText( "" )
			fileBtn:Dock( TOP )
			fileBtn:SetTall(filesScroll:GetTall()*0.17)
			fileBtn:DockMargin( 0, 0, 0, 5 )
			fileBtn.Paint = function(self, w, h)
				draw.SimpleText( k, "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			fileBtn.DoClick = function(self)
				surface.PlaySound( sound_click )

				net.Start("adrewards_ActionMenu")
					net.WriteUInt(2, 3) -- action type
					net.WriteString(k)
				net.SendToServer()
				confirmPanel:Remove()
			end
		end

		local cancelBtn = vgui.Create( "DButton", transPanel)
		cancelBtn:SetPos( transPanel:GetWide()*0.10, transPanel:GetTall()*0.78 )
		cancelBtn:SetSize( transPanel:GetWide()*0.80, transPanel:GetTall()*0.16 )
		cancelBtn:SetText("")
		cancelBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Cancel"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		cancelBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		cancelBtn.DoClick = function()
			surface.PlaySound( sound_click )

			confirmPanel:Remove()
		end
	end
	/*------------*/
	/*----Save----*/
	/*------------*/
	local actionSaveBtn = actionsScroll:Add( "DButton" )
	actionSaveBtn:SetText( "" )
	actionSaveBtn:Dock( TOP )
	actionSaveBtn:SetTall(actionsScroll:GetTall()*0.17)
	actionSaveBtn:DockMargin( 0, 0, 0, 5 )
	actionSaveBtn.Paint = function(self, w, h)
		local textcenter = actionsScroll.VBar.Enabled and ( w*0.5 + ( actionsScroll.VBar:GetWide()*0.5 ) ) or w*0.5
		draw.SimpleText( ADRewards.GetPhrase("Save"), "ADRewards_6", textcenter, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	actionSaveBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		local confirmPanel = vgui.Create( "DPanel", rMenu)
		confirmPanel:SetPos( 0, 0 )
		confirmPanel:SetSize( mW, mH )
		confirmPanel.Paint = function(self, w, h)
			local bgimage = ADRewards.Themes[ADRewards.RewardsMenu.SeasonInfo.CurTheme].BgImage

			surface.SetDrawColor( Color( 100, 100, 100, 250 ) )
			surface.SetMaterial( bgimage )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		local transPanel = vgui.Create( "DPanel", confirmPanel)
		transPanel:SetPos( confirmPanel:GetWide()*0.25, confirmPanel:GetTall()*0.325 )
		transPanel:SetSize( confirmPanel:GetWide()*0.50, confirmPanel:GetTall()*0.32 )
		transPanel.Paint = function(self, w, h)
			draw.RoundedBox(7, 0, 0, w, h, c_transparent)

			draw.SimpleText( ADRewards.GetPhrase("Save"), "ADRewards_7",  w*0.5, h*0.15, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			draw.DrawText( ADRewards.GetPhrase("ActionSave"), "ADRewards_6", w*0.10, h*0.28, c_255, TEXT_ALIGN_LEFT )
		end
		local confirmBtn = vgui.Create( "DButton", transPanel)
		confirmBtn:SetPos( transPanel:GetWide()*0.10, transPanel:GetTall()*0.68 )
		confirmBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.22 )
		confirmBtn:SetText("")
		confirmBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Confirm"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		confirmBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		confirmBtn.DoClick = function()
			local defnum = #ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"]
			local premnum = #ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"]

			local checknum = defnum
			while checknum > 0 and ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][checknum] == nil do
				ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][checknum] = false
				checknum = checknum - 1
			end
			local checknum = premnum
			while checknum > 0 and ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][checknum] == nil do
				ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][checknum] = false
				checknum = checknum - 1
			end

			local filename = ADRewards.RewardsMenu.SeasonInfo.SFile
			net.Start("adrewards_ActionMenu")
				net.WriteUInt(3, 3) -- action type
				net.WriteString(filename) -- file name
				net.WriteString(ADRewards.RewardsMenu.SeasonInfo.SName) -- season name
				net.WriteString(ADRewards.RewardsMenu.SeasonInfo.CurTheme) -- theme name
				net.WriteUInt(ADRewards.RewardsMenu.SeasonInfo.SDays, 7) -- days
				/*for i = 1, 105 do
					ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][i] = {
						Module = "Test dfd fd f d",
						Amount = 11111,
						Key = "dffd df df df df df df"
					}
					ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][i] = {
						Module = "Test dfd fd f d",
						Amount = 11111,
						Key = "dffd df df df df df df"
					}
				end*/
				local trwrd = ADRewards.RewardsMenu.SeasonInfo.TReward
				net.WriteBool(trwrd)
				if trwrd then
					net.WriteString(trwrd.Module)
					net.WriteUInt(trwrd.Amount, 20)
					local tkey = trwrd.Key and trwrd.Key or ""
					net.WriteString(tkey)
				end

				local json = util.TableToJSON( ADRewards.RewardsMenu.SeasonInfo.Rewards )
				local compressed = util.Compress( json )
				local len = #compressed
				net.WriteUInt( len, 10 )
				net.WriteData( compressed, len )
			net.SendToServer()

			surface.PlaySound( sound_click )

			confirmPanel:Remove()

			ADRewards.RewardsMenu.FileList[filename] = true
		end
		local cancelBtn = vgui.Create( "DButton", transPanel)
		cancelBtn:SetPos( transPanel:GetWide()*0.60, transPanel:GetTall()*0.68 )
		cancelBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.22 )
		cancelBtn:SetText("")
		cancelBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Cancel"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		cancelBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		cancelBtn.DoClick = function()
			surface.PlaySound( sound_click )

			confirmPanel:Remove()
		end
	end
	/*--------------*/
	/*----Remove----*/
	/*--------------*/
	local actionRemoveBtn = actionsScroll:Add( "DButton" )
	actionRemoveBtn:SetText( "" )
	actionRemoveBtn:Dock( TOP )
	actionRemoveBtn:SetTall(actionsScroll:GetTall()*0.17)
	actionRemoveBtn:DockMargin( 0, 0, 0, 5 )
	actionRemoveBtn.Paint = function(self, w, h)
		local textcenter = actionsScroll.VBar.Enabled and ( w*0.5 + ( actionsScroll.VBar:GetWide()*0.5 ) ) or w*0.5
		draw.SimpleText( ADRewards.GetPhrase("Remove"), "ADRewards_6", textcenter, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	actionRemoveBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		local confirmPanel = vgui.Create( "DPanel", rMenu)
		confirmPanel:SetPos( 0, 0 )
		confirmPanel:SetSize( mW, mH )
		confirmPanel.Paint = function(self, w, h)
			local bgimage = ADRewards.Themes[ADRewards.RewardsMenu.SeasonInfo.CurTheme].BgImage

			surface.SetDrawColor( Color( 100, 100, 100, 250 ) )
			surface.SetMaterial( bgimage )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		local transPanel = vgui.Create( "DPanel", confirmPanel)
		transPanel:SetPos( confirmPanel:GetWide()*0.25, confirmPanel:GetTall()*0.33 )
		transPanel:SetSize( confirmPanel:GetWide()*0.50, confirmPanel:GetTall()*0.35 )
		transPanel.Paint = function(self, w, h)
			draw.RoundedBox(7, 0, 0, w, h, c_transparent)

			draw.SimpleText( ADRewards.GetPhrase("Remove"), "ADRewards_7",  w*0.5, h*0.15, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			draw.DrawText( ADRewards.GetPhrase("ActionRemove"), "ADRewards_6", w*0.10, h*0.26, c_255, TEXT_ALIGN_LEFT )
		end
		local confirmBtn = vgui.Create( "DButton", transPanel)
		confirmBtn:SetPos( transPanel:GetWide()*0.10, transPanel:GetTall()*0.69 )
		confirmBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.21 )
		confirmBtn:SetText("")
		confirmBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Confirm"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		confirmBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		confirmBtn.DoClick = function()
			local fname = ADRewards.RewardsMenu.SeasonInfo.SFile
			surface.PlaySound( sound_click )

			net.Start("adrewards_ActionMenu")
				net.WriteUInt(4, 3)  -- action type
				net.WriteString(fname) -- file name
			net.SendToServer()
			
			ADRewards.RewardsMenu.FileList[fname] = nil
			ADRewards.RewardsMenu.SetInfo(false, false, false, false, false, false)
			confirmPanel:Remove()
		end
		local cancelBtn = vgui.Create( "DButton", transPanel)
		cancelBtn:SetPos( transPanel:GetWide()*0.60, transPanel:GetTall()*0.69 )
		cancelBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.21 )
		cancelBtn:SetText("")
		cancelBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Cancel"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		cancelBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		cancelBtn.DoClick = function()
			surface.PlaySound( sound_click )

			confirmPanel:Remove()
		end
	end
	/*--------------*/
	/*-----Start----*/
	/*--------------*/
	local actionStartBtn = actionsScroll:Add( "DButton" )
	actionStartBtn:SetText( "" )
	actionStartBtn:Dock( TOP )
	actionStartBtn:SetTall(actionsScroll:GetTall()*0.17)
	actionStartBtn:DockMargin( 0, 0, 0, 5 )
	actionStartBtn.Paint = function(self, w, h)
		local textcenter = actionsScroll.VBar.Enabled and ( w*0.5 + ( actionsScroll.VBar:GetWide()*0.5 ) ) or w*0.5
		draw.SimpleText( ADRewards.GetPhrase("Start"), "ADRewards_6", textcenter, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	actionStartBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		local confirmPanel = vgui.Create( "DPanel", rMenu)
		confirmPanel:SetPos( 0, 0 )
		confirmPanel:SetSize( mW, mH )
		confirmPanel.Paint = function(self, w, h)
			local bgimage = ADRewards.Themes[ADRewards.RewardsMenu.SeasonInfo.CurTheme].BgImage

			surface.SetDrawColor( Color( 100, 100, 100, 250 ) )
			surface.SetMaterial( bgimage )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		local transPanel = vgui.Create( "DPanel", confirmPanel)
		transPanel:SetPos( confirmPanel:GetWide()*0.25, confirmPanel:GetTall()*0.325 )
		transPanel:SetSize( confirmPanel:GetWide()*0.50, confirmPanel:GetTall()*0.35 )
		transPanel.Paint = function(self, w, h)
			draw.RoundedBox(7, 0, 0, w, h, c_transparent)

			draw.SimpleText( ADRewards.GetPhrase("StartSeason"), "ADRewards_7",  w*0.5, h*0.15, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			draw.DrawText( ADRewards.GetPhrase("ActionStart"), "ADRewards_6", w*0.10, h*0.28, c_255, TEXT_ALIGN_LEFT )
		end
		local confirmBtn = vgui.Create( "DButton", transPanel)
		confirmBtn:SetPos( transPanel:GetWide()*0.10, transPanel:GetTall()*0.7 )
		confirmBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.2 )
		confirmBtn:SetText("")
		confirmBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Confirm"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		confirmBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		confirmBtn.DoClick = function()
			if ADRewards.RewardsMenu.SeasonInfo.SFile == "unique_name" then surface.PlaySound( sound_miss ) return end
			local filename = ADRewards.RewardsMenu.SeasonInfo.SFile
			if !ADRewards.RewardsMenu.FileList[filename] or ADRewards.RewardsMenu.updateFile then
				local defnum = #ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"]
				local premnum = #ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"]

				local checknum = defnum
				while checknum > 0 and ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][checknum] == nil do
					ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][checknum] = false
					checknum = checknum - 1
				end
				local checknum = premnum
				while checknum > 0 and ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][checknum] == nil do
					ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][checknum] = false
					checknum = checknum - 1
				end

				net.Start("adrewards_ActionMenu")
					net.WriteUInt(3, 3) -- action type
					net.WriteString(ADRewards.RewardsMenu.SeasonInfo.SFile) -- file name
					net.WriteString(ADRewards.RewardsMenu.SeasonInfo.SName) -- season name
					net.WriteString(ADRewards.RewardsMenu.SeasonInfo.CurTheme) -- theme name
					net.WriteUInt(ADRewards.RewardsMenu.SeasonInfo.SDays, 7) -- days

					local trwrd = ADRewards.RewardsMenu.SeasonInfo.TReward
					net.WriteBool(trwrd)
					if trwrd then
						net.WriteString(trwrd.Module)
						net.WriteUInt(trwrd.Amount, 20)
						local tkey = trwrd.Key and trwrd.Key or ""
						net.WriteString(tkey)
					end

					local json = util.TableToJSON( ADRewards.RewardsMenu.SeasonInfo.Rewards )
					local compressed = util.Compress( json )
					local len = #compressed
					net.WriteUInt( len, 10 )
					net.WriteData( compressed, len )
				net.SendToServer()
			end
			net.Start("adrewards_ActionMenu")
				net.WriteUInt(5, 3)  -- action type
				net.WriteString(ADRewards.RewardsMenu.SeasonInfo.SFile) -- file name
			net.SendToServer()

			surface.PlaySound( sound_click )

			ADRewards.RewardsMenu:Remove()
		end
		local cancelBtn = vgui.Create( "DButton", transPanel)
		cancelBtn:SetPos( transPanel:GetWide()*0.60, transPanel:GetTall()*0.7 )
		cancelBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.2 )
		cancelBtn:SetText("")
		cancelBtn.Paint = function(self, w, h)
			local hovered = self:IsHovered()
			draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
			draw.SimpleText( ADRewards.GetPhrase("Cancel"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		cancelBtn.OnCursorEntered = function()
			surface.PlaySound( sound_hover )
		end
		cancelBtn.DoClick = function()
			surface.PlaySound( sound_click )

			confirmPanel:Remove()
		end
	end
	
	/*--------*/
	/*--Stop--*/
	/*--------*/

	if ADRewards.SeasonNow then
		local actionStopBtn = actionsScroll:Add( "DButton" )
		actionStopBtn:SetText( "" )
		actionStopBtn:Dock( TOP )
		actionStopBtn:SetTall(actionsScroll:GetTall()*0.17)
		actionStopBtn:DockMargin( 0, 0, 0, 5 )
		actionStopBtn.Paint = function(self, w, h)
			local textcenter = actionsScroll.VBar.Enabled and ( w*0.5 + ( actionsScroll.VBar:GetWide()*0.5 ) ) or w*0.5
			draw.SimpleText( ADRewards.GetPhrase("Stop"), "ADRewards_6", textcenter, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		actionStopBtn.DoClick = function(self)
			surface.PlaySound( sound_click )

			local confirmPanel = vgui.Create( "DPanel", rMenu)
			confirmPanel:SetPos( 0, 0 )
			confirmPanel:SetSize( mW, mH )
			confirmPanel.Paint = function(self, w, h)
				local bgimage = ADRewards.Themes[ADRewards.RewardsMenu.SeasonInfo.CurTheme].BgImage

				surface.SetDrawColor( Color( 100, 100, 100, 250 ) )
				surface.SetMaterial( bgimage )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			local transPanel = vgui.Create( "DPanel", confirmPanel)
			transPanel:SetPos( confirmPanel:GetWide()*0.25, confirmPanel:GetTall()*0.325 )
			transPanel:SetSize( confirmPanel:GetWide()*0.50, confirmPanel:GetTall()*0.35 )
			transPanel.Paint = function(self, w, h)
				draw.RoundedBox(7, 0, 0, w, h, c_transparent)

				draw.SimpleText( ADRewards.GetPhrase("StopSeason"), "ADRewards_7",  w*0.5, h*0.15, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

				draw.DrawText( ADRewards.GetPhrase("ActionStop"), "ADRewards_6", w*0.10, h*0.28, c_255, TEXT_ALIGN_LEFT )
			end
			local confirmBtn = vgui.Create( "DButton", transPanel)
			confirmBtn:SetPos( transPanel:GetWide()*0.10, transPanel:GetTall()*0.7 )
			confirmBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.2 )
			confirmBtn:SetText("")
			confirmBtn.Paint = function(self, w, h)
				local hovered = self:IsHovered()
				draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
				draw.SimpleText( ADRewards.GetPhrase("Confirm"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			confirmBtn.OnCursorEntered = function()
				surface.PlaySound( sound_hover )
			end
			confirmBtn.DoClick = function()
				surface.PlaySound( sound_click )

				ADRewards.SeasonNow = nil
				net.Start("adrewards_ActionMenu")
					net.WriteUInt(6, 3)  -- action type
				net.SendToServer()
				ADRewards.RewardsMenu:Remove()
			end
			local cancelBtn = vgui.Create( "DButton", transPanel)
			cancelBtn:SetPos( transPanel:GetWide()*0.60, transPanel:GetTall()*0.7 )
			cancelBtn:SetSize( transPanel:GetWide()*0.30, transPanel:GetTall()*0.2 )
			cancelBtn:SetText("")
			cancelBtn.Paint = function(self, w, h)
				local hovered = self:IsHovered()
				draw.RoundedBox(7, 0, 0, w, h, hovered and c_transparent2 or c_transparent)
				draw.SimpleText( ADRewards.GetPhrase("Cancel"), "ADRewards_6",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			cancelBtn.OnCursorEntered = function()
				surface.PlaySound( sound_hover )
			end
			cancelBtn.DoClick = function()
				surface.PlaySound( sound_click )

				confirmPanel:Remove()
			end
		end
	end
	/*---------------------------------------------------------------------------
	Middle Panels
	---------------------------------------------------------------------------*/

	local premBtn = vgui.Create( "DButton", rMenu)
	premBtn:SetPos( mW*0.65, mH*0.50 )
	premBtn:SetSize( mW*0.10, mH*0.06 )
	premBtn:SetText( "" )
	premBtn.Paint = function(self, w, h)
		local theme = ADRewards.RewardsMenu.SeasonInfo.CurTheme
		local hovered = self:IsHovered()
		local maincolor = ADRewards.Themes[theme].MainColor
		draw.RoundedBox(30, 0, 0, w, h, hovered and Color(maincolor.r+25, maincolor.g+25, maincolor.b+25, maincolor.a) or ADRewards.Themes[theme].MainColor)
		--draw.RoundedBox(30, 3, 3, w-6, h-6, Color(0,0,0,150))

		draw.SimpleText( ADRewards.GetPhrase("PREMIUM"), "ADRewards_5",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	premBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	premBtn.DoClick = function()
		surface.PlaySound( sound_click )

		gui.OpenURL( ADRewards.Config.PremiumURL )
	end
	

	local leftBtn = vgui.Create( "DButton", rMenu)
	leftBtn:SetPos( mW*0.78, mH*0.50 )
	leftBtn:SetSize( mW*0.055, mH*0.06 )
	leftBtn:SetText( "" )
	leftBtn.Paint = function(self, w, h)
		local theme = ADRewards.RewardsMenu.SeasonInfo.CurTheme
		local hovered = self:IsHovered()
		local maincolor = ADRewards.Themes[theme].MainColor
		draw.RoundedBox(30, 0, 0, w, h, hovered and Color(maincolor.r+25, maincolor.g+25, maincolor.b+25, maincolor.a) or ADRewards.Themes[theme].MainColor)

		draw.SimpleText( "←", "ADRewards_9",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	leftBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		page = math.Clamp( page - 1, 1, 15 )
		ADRewards.RewardsMenu.rewardsPanel.BuildList(page)
	end

	local rightBtn = vgui.Create( "DButton", rMenu)
	rightBtn:SetPos( mW*0.906, mH*0.50 )
	rightBtn:SetSize( mW*0.055, mH*0.06 )
	rightBtn:SetText( "" )
	rightBtn.Paint = function(self, w, h)
		local theme = ADRewards.RewardsMenu.SeasonInfo.CurTheme
		local hovered = self:IsHovered()
		local maincolor = ADRewards.Themes[theme].MainColor
		draw.RoundedBox(30, 0, 0, w, h, hovered and Color(maincolor.r+25, maincolor.g+25, maincolor.b+25, maincolor.a) or ADRewards.Themes[theme].MainColor)

		draw.SimpleText( "→", "ADRewards_9",  w*0.5, h*0.5, c_255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightBtn.OnCursorEntered = function()
		surface.PlaySound( sound_hover )
	end
	rightBtn.DoClick = function(self)
		surface.PlaySound( sound_click )

		page = math.Clamp( page + 1, 1, 15 )
		ADRewards.RewardsMenu.rewardsPanel.BuildList(page)
	end

	/*---------------------------------------------------------------------------
	Rewards
	---------------------------------------------------------------------------*/
	ADRewards.RewardsMenu.rewardsPanel = vgui.Create( "DPanel", rMenu)
	local rewardsPanel = ADRewards.RewardsMenu.rewardsPanel
	rewardsPanel:SetPos( mW*0.28, mH*0.59 )
	rewardsPanel:SetSize( mW*0.68, mH*0.33 )
	rewardsPanel.Paint = function(self, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(0,0,255,222))

		draw.RoundedBox( 0, w*0.08, h*0.17, 2, h*0.34, c_transparent )

		draw.RoundedBox( 0, w*0.08, h*0.625, 2, h*0.34, c_transparent )
	end

	local rW, rH = rewardsPanel:GetSize()
	local r_w, r_h = rW*0.115, rH*0.42
	local startpos = rW*0.107
	local widestep = rW*0.13

	rewardsPanel.BuildList = function(page)
		rewardsPanel:Clear()

		local startc = ( (page-1) * 7 ) + 1
		local endc = startc+7

		for i = startc, endc do
			local numpos = 8-(endc-i)
			local groupPanel = vgui.Create( "DPanel", rewardsPanel)
			groupPanel:SetPos( startpos + ( widestep * ( numpos-1 ) ), 0 )
			groupPanel:SetSize( r_w, rH )
			groupPanel.Paint = function(self, w, h)
				--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0,255))
				--draw.RoundedBox(0, w-1, 0, 1, h, Color(0,225,255,255))
				draw.SimpleText( i, "ADRewards_L_6",  w*0.5, 0, c_255, TEXT_ALIGN_CENTER )
			end
			/*----------------*/
			/*-----Default----*/
			/*----------------*/
			local rewardInfo = ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][i]
			if rewardInfo and !ADRewards.Rewards[rewardInfo.Module] then
				rewardInfo = false
			end
			local rewardBtn = vgui.Create( "DButton", groupPanel)
			rewardBtn:SetPos( 0, rH*0.13 )
			rewardBtn:SetSize( r_w, r_h )
			rewardBtn:SetText("")
			rewardBtn.Paint = function(self, w, h)
				--draw.RoundedBox(7, 0, 0, w, h, c_transparent)
				ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_transparent)

				if rewardInfo then
					if ADRewards.Rewards[rewardInfo.Module].MaxAmount > 1 then
						draw.SimpleTextOutlined( string.Comma(rewardInfo.Amount, ","), "ADRewards_5", w*0.90, h*0.75, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, c_ablack )
					end
				else
					if ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][i] then
						surface.SetDrawColor( 255, 255, 255 )
						surface.SetMaterial( mat_none )
						surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )
					else
						draw.SimpleText( "➕", "ADRewards_6",  w*0.5, h*0.5, c_180, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
				end
			end
			rewardBtn.OnMousePressed = function(self, keyCode)
				if keyCode == MOUSE_LEFT then
					surface.PlaySound( sound_click )

					rewardsChooseList(false, i, false)
				elseif keyCode == MOUSE_RIGHT then
					if ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][i+1] == nil then
						ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][i] = nil
						local checknum = i-1
						while checknum > 0 and ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][checknum] == false do
							ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][checknum] = nil
							checknum = checknum - 1
						end
					else
						ADRewards.RewardsMenu.SeasonInfo.Rewards["Default"][i] = false
					end

					surface.PlaySound( sound_click )

					rewardsPanel.BuildList(page)
					ADRewards.RewardsMenu.updateFile = true
				end
			end
			if rewardInfo then
				local rewardIcon = rewardDrawPanel(rewardBtn, rewardInfo.Module, rewardInfo.Key)
				if !rewardIcon and ADRewards.Rewards[rewardInfo.Module].NetRead then
					local iconTbl = {
						Module = rewardInfo.Module,
						Key = rewardInfo.Key,
						Panel = rewardBtn,
					}
					table.insert(ADRewards.RewardsMenu.WaitRequest["Default"], iconTbl)
					net.Start("adrewards_RewardRequest")
						net.WriteString(rewardInfo.Module)
						net.WriteString(rewardInfo.Key)
					net.SendToServer()
				end
			end
			/*----------------*/
			/*-----Premium----*/
			/*----------------*/
			local rewardInfo = ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][i]
			if rewardInfo and !ADRewards.Rewards[rewardInfo.Module] then
				rewardInfo = false
			end
			local rewardPremBtn = vgui.Create( "DButton", groupPanel)
			rewardPremBtn:SetPos( 0, rH*0.585 )
			rewardPremBtn:SetSize( r_w, r_h )
			rewardPremBtn:SetText("")
			rewardPremBtn.Paint = function(self, w, h)
				--draw.RoundedBox(7, 0, 0, w, h, c_transparent)
				ADRewards.draw_RoundedTextureBox(7, 0, 0, w, h, c_transparent)

				if rewardInfo then
					if ADRewards.Rewards[rewardInfo.Module].MaxAmount > 1 then
						draw.SimpleTextOutlined( string.Comma(rewardInfo.Amount, ","), "ADRewards_5", w*0.90, h*0.75, c_255, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, c_ablack )
					end
				else
					if ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][i] then
						surface.SetDrawColor( 255, 255, 255 )
						surface.SetMaterial( mat_none )
						surface.DrawTexturedRect( w*0.25, h*0.25, w*0.50, h*0.50 )
					else
						draw.SimpleText( "➕", "ADRewards_6",  w*0.5, h*0.5, c_180, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
				end
			end
			rewardPremBtn.OnMousePressed = function(self, keyCode)
				if keyCode == MOUSE_LEFT then
					rewardsChooseList(false, i, true)
				elseif keyCode == MOUSE_RIGHT then
					if ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][i+1] == nil then
						ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][i] = nil
						local checknum = i-1
						while checknum > 0 and ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][checknum] == false do
							ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][checknum] = nil
							checknum = checknum - 1
						end
					else
						ADRewards.RewardsMenu.SeasonInfo.Rewards["Premium"][i] = false
					end
					ADRewards.RewardsMenu.updateFile = true
					rewardsPanel.BuildList(page)
				end
			end
			if rewardInfo then
				local rewardIcon = rewardDrawPanel(rewardPremBtn, rewardInfo.Module, rewardInfo.Key)
				if !rewardIcon and ADRewards.Rewards[rewardInfo.Module].NetRead then
					local iconTbl = {
						Module = rewardInfo.Module,
						Key = rewardInfo.Key,
						Panel = rewardPremBtn,
					}
					table.insert(ADRewards.RewardsMenu.WaitRequest["Default"], iconTbl)
					net.Start("adrewards_RewardRequest")
						net.WriteString(rewardInfo.Module)
						net.WriteString(rewardInfo.Key)
					net.SendToServer()
				end
			end
		end
	end
	rewardsPanel.BuildList(1)
end