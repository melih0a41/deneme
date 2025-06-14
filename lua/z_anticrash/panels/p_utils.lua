-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

function CL_ANTICRASH.CreateLbl(x, y, txt, font, col, parent)
	
	local lbl = vgui.Create( "DLabel", parent )
	lbl:SetFont(font)
	lbl:SetContentAlignment( 5 )
	lbl:SetTextColor(col)
	lbl:SetText(txt)
	lbl.UpdateSize = function(self)
		self:SetSize(self:GetContentSize()+10)
		self:SizeToContentsY()
		self:SetPos(x,y)
	end
	lbl:UpdateSize()
	
	return lbl
	
end

function CL_ANTICRASH.CreateButton(x, y, w, h, txt, font, col, parent, doClick)
	
	
	local btn = vgui.Create("DButton", parent)
	btn:SetPos(x,y)
	btn:SetSize(w,h)
	btn:SetText(txt)
	btn:SetFont(font)
	btn:SetTextColor(color_white)
	btn.DoClick = doClick
	btn.Paint = function(self, w, h)
		
		-- Bg
		draw.RoundedBox( 4, 0, 0, w, h, col )
		
	end
	
	return btn

end

function CL_ANTICRASH.CreateButtonColorFade(x, y, w, h, txt, font, col, col2, parent, doClick)

	local btn = CL_ANTICRASH.CreateButton(x, y, w, h, txt, font, col, parent, doClick)
	btn.isSelected = false
	btn.__bgAlpha = 0
	
	local nextThink, fadeSpeed, fadeLimit = 0, 40, 150
	btn.Think = function(self, w, h)
		
		if nextThink < CurTime() then
	
			-- Alpha fade
			if self.isSelected then
				
				self.__bgAlpha = math.Approach(self.__bgAlpha, fadeLimit, fadeSpeed)
				
				if self.__bgAlpha == fadeLimit then
					self.isSelected = false
				end
				
			else
				self.__bgAlpha = math.Approach(self.__bgAlpha, 0, fadeSpeed)
			end
			
			-- Limit to 30FPS
			nextThink = CurTime() + 0.033
		
		end
		
	end
	btn.Paint = function(self, w, h)
		
		-- Bg
		draw.RoundedBox( 4, 0, 0, w, h, ColorAlpha(col,255-self.__bgAlpha) )
		
		-- Fg
		draw.RoundedBox( 4, 0, 0, w, h, ColorAlpha(col2,self.__bgAlpha) )
		
	end
	btn.DoClick = function(self)
	
		self.isSelected = true
	
		doClick(self)
		
	end
	
	return btn
	
end

function CL_ANTICRASH.CreateColorSwitchButton(x, y, w, h, txt, font, col1, col2, isSelected, parent, doClick)
	
	local entityVisionBtn = vgui.Create("DButton", parent)
	entityVisionBtn:SetPos(x,y)
	entityVisionBtn:SetSize(w,h)
	entityVisionBtn:SetText(txt)
	entityVisionBtn:SetFont(font)
	entityVisionBtn:SetTextColor(color_white)
	entityVisionBtn.DoClick = doClick
	entityVisionBtn.__isSelected = isSelected
	entityVisionBtn.Paint = function(self, w, h)
		
		local bgCol = self.__isSelected and col2 or col1
		
		-- Bg
		draw.RoundedBox( 4, 0, 0, w, h, bgCol )
		
	end
	
	return entityVisionBtn

end

function CL_ANTICRASH.CreateTextInput(x, y, w, h, defaultVal, font, col, parent)
	
	local bgPanel = vgui.Create("DPanel", parent)
	bgPanel:SetPos( x, y )
	bgPanel:SetSize( w, h )
	bgPanel.Paint = function(self, w, h)
		
		-- Bg
		draw.RoundedBox( 4, 0, 0, w, h, SH_ANTICRASH.VARS.COLOR.DARKY )
		
	end

	local offsetW, offsetH = 4, 4
	local textInput = vgui.Create( "DTextEntry", bgPanel )
	textInput:SetPos( offsetW, offsetH )
	textInput:SetSize(w-(offsetW*2), h-(offsetH*2))
	textInput:SetFont( font )
	textInput:SetTextColor(col)
	textInput:SetText( defaultVal )
	textInput:SetDrawBackground(false)
	textInput.m_colCursor = col
	textInput.m_colPlaceholder = col
	
	local oldPaint = textInput.Paint
	textInput.Paint = function(self, w, h)
		
		-- Small BG
		draw.RoundedBox( 4, 0, 0, w, h, SH_ANTICRASH.VARS.COLOR.LESSDARKY )
		
		-- Input box
		oldPaint(self,w,h)
		
	end 
	
	return bgPanel, textInput
	
end

function CL_ANTICRASH.CreateDividerLine(x, y, w, h, col, parent)
	
	local dividerPnl = vgui.Create("DPanel",parent)
	dividerPnl:SetPos(x,y)
	dividerPnl:SetSize(w,h)
	dividerPnl.Paint = function(self, w, h)
	
		-- Bg
		draw.RoundedBox( 4, 0, 0, w, h, col )
		
	end
	
	return dividerPnl

end

function CL_ANTICRASH.DrawCircle(x, y, radius, col)

	local smoothness = 5
	local seg = 32
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		
	for i = 0, seg do
	
		local a = math.rad( ( i / seg ) * -360 )
		
		cir[i] = {
			x = x + math.sin( a ) * radius,
			y = y + math.cos( a ) * radius,
			u = math.sin( a ) / 2 + 0.5,
			v = math.cos( a ) / 2 + 0.5
		} 
		
	end

	local a = math.rad( 0 )
	
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.SetDrawColor(col) 
	draw.NoTexture()
	surface.DrawPoly( cir )

end

function CL_ANTICRASH.CreateInfoLabel(x, y, h, txt, col, font, parent)

	local infoLbl = vgui.Create( "DLabel", parent )
	infoLbl:SetPos(x, y)
	infoLbl:SetFont(font)
	infoLbl:SetContentAlignment( 5 )
	infoLbl:SetTextColor(col)
	infoLbl:SetText(txt)
	infoLbl.UpdateSize = function(self)
		self:SetSize(0,h)
		self:SizeToContentsX()
	end
	infoLbl:UpdateSize()
	
	return infoLbl
	
end

function CL_ANTICRASH.CreateGraphInfoLabel(x, y, w, h, txt, infoKey, showFraction, parent, drawBorders)

	local infoCol = CL_ANTICRASH.GRAPH.COL[infoKey]
	local edgeOffset = 2
	local infoLblOffset = 8

	local bgPanel = vgui.Create("DPanel",parent)
	bgPanel:SetPos(x,y)
	bgPanel:SetSize(w,h)
	bgPanel.Paint = function(self, w, h)
		
		if drawBorders then
		
			-- Left edge
			draw.RoundedBox( 4, 0, 0, w/2, h, infoCol )
			
			-- Right edge
			draw.RoundedBox( 4, w/2, 0, w/2, h, infoCol )
			
		end
		
		-- Bg
		draw.RoundedBox( 4, edgeOffset, 0, w-(edgeOffset*2), h, SH_ANTICRASH.VARS.COLOR.DARKY )
		
	end
	
	-- Info name
	CL_ANTICRASH.CreateInfoLabel(x+infoLblOffset,y,h,txt,infoCol, "z_anticrash_graph_label", parent)

	-- Info value
	local valLbl = CL_ANTICRASH.CreateInfoLabel(0,y,h,"",infoCol, "z_anticrash_graph_label", parent)
	
	-- Keep value up to date
	valLbl.Think = function()
	
		local graphInfo = CL_ANTICRASH.GRAPH.INFO[infoKey]
		local valTxt = graphInfo.cur
		
		if !showFraction then
			local num = math.Clamp(math.Round(100*(graphInfo.cur/graphInfo.max)),0,100)
			-- valTxt = num.."%"
			valTxt = num
		end
		
		valLbl:SetText(valTxt)
		valLbl:UpdateSize()
		valLbl:SetPos(bgPanel:GetRightX()-infoLblOffset-valLbl:GetWide(),y)
	
	end
	
	return bgPanel
	
end

function CL_ANTICRASH.CreateGraph(x, y, w, h, parent)

	local graphPanel = vgui.Create("DPanel",parent)
	graphPanel:SetPos(x,y)
	graphPanel:SetSize(w,h)
	
	local graphLineCol = SH_ANTICRASH.VARS.COLOR.DARK
	local graphLineOffset = h/6
	local graphLineCount = SH_ANTICRASH.SETTINGS.GRAPH.TIMEWINDOW
	
	graphPanel.Paint = function(self, w, h)
	
		-- Bg
		draw.RoundedBox( 4, 0, 0, w, h, SH_ANTICRASH.VARS.COLOR.LIGHTDARK )
		
		-- Bg Lines
		for i=1, 6 do
			
			local lineY = graphLineOffset*i
		
			surface.SetDrawColor( graphLineCol )
			surface.DrawLine( 0, lineY, w, lineY)
			
		end
	
		-- Graph Lines
		for k,points in SortedPairs(CL_ANTICRASH.GRAPH.POINTS) do

			local prevGraphPoint = nil
			local lineCol = CL_ANTICRASH.GRAPH.COL[k]
			
			for i=1, #points do
				
				local pointInfo = points[i]
				
				if !prevGraphPoint then
					prevGraphPoint = pointInfo
					continue
				end
				
				local startX, startY = (w/graphLineCount) * (graphLineCount-i+2), h - (h * prevGraphPoint.cur/prevGraphPoint.max)
				local endX, endY = (w/graphLineCount) * (graphLineCount-i+1), h - (h * pointInfo.cur/pointInfo.max)
				
				startY = math.Clamp(startY,1,h-2)
				endY = math.Clamp(endY,1,h-2)
				
				surface.SetDrawColor( lineCol )
				surface.DrawLine( startX, startY+1, endX, endY+1 )
				surface.DrawLine( startX, startY-1, endX, endY-1 )
				surface.DrawLine( startX, startY, endX, endY )
				
				prevGraphPoint = pointInfo
			
			end	
		
		end

	
	end
	
	
	
	return graphPanel

end

function CL_ANTICRASH.CreateUserInfoPanel(x, y, w, h, txt, colKey, funcKey, target, parent)
	
	local infoCol = CL_ANTICRASH.USERDATA.COL[colKey]
	local infoColFade = ColorAlpha(infoCol,50)
	local infoLblOffset = 5
	local edgeOffset = 2
	
	-- Info panel
	local infoPanel = vgui.Create("DPanel",parent)
	infoPanel:SetPos(x,y)
	infoPanel:SetSize(w,h)
	infoPanel.Paint = function(self, w, h)
		
		-- Bg
		draw.RoundedBox( 4, 0, 0, w, h, infoCol )
		
	end
	
	-- Info button
	/*
	local infoButton = vgui.Create("DButton",infoPanel)
	infoButton:SetSize(w,h)
	infoButton:SetText("")
	infoButton.Paint = function() end
	*/
	
	-- Info name
	CL_ANTICRASH.CreateInfoLabel(infoLblOffset,0,h,txt,SH_ANTICRASH.VARS.COLOR.DARKGREY, "z_anticrash_user_info_label", infoPanel)

	-- Info value
	local valLbl = CL_ANTICRASH.CreateInfoLabel(0,0,h,"",SH_ANTICRASH.VARS.COLOR.DARKGREY, "z_anticrash_user_info_label", infoPanel)
	
	-- Keep value up to date
	local nextThink = 0
	valLbl.Think = function()
	
		if !parent.isExpanded then return end
		
		if nextThink < CurTime() then
	
			local valTxt = CL_ANTICRASH.USERDATA[funcKey](target)
			
			valLbl:SetText(valTxt)
			valLbl:UpdateSize()
			valLbl:SetPos(infoPanel:GetWide()-infoLblOffset-valLbl:GetWide(),0)
			
			nextThink = CurTime() + 0.5
	
		end
	
	end
	
	return infoPanel
	
end

function CL_ANTICRASH.HookSearchInputFilter(searchInput, filterPanels)

	searchInput.OnChange = function(self)
		
		local filter = string.Trim( self:GetText():lower() ) 
		
		local prevFilterPnl = nil
		
		for i=1, #filterPanels do
		
			local filterStr, filterPanel = filterPanels[i].filterStr, filterPanels[i].filterPanel
			
			-- show panel if there is no filter or the filter matches
			if #filter == 0 or string.find( filterStr:lower(), filter, 1, true ) ~= nil then
			
				-- set filtered panel to auto adjust position
				if prevFilterPnl ~= nil then
					filterPanel.prevPnl = prevFilterPnl
				else
					-- make sure the first filtered result is on the start position
					filterPanel.prevPnl = nil
					filterPanel:SetPos(5,searchInput:GetBottomY()+filterPanel.panelOffset)
				end
			
				filterPanel:SetVisible(true)
				
				prevFilterPnl = filterPanel
				
				continue
			end
			
			filterPanel:Hide()
		
		end
		
	end

end

function CL_ANTICRASH.SkinScrollPanel(scrollP)
	
	local sbar = scrollP:GetVBar()
	
	sbar:SetWide(3)
	sbar:SetHideButtons( true )
	
	function sbar:Paint( w, h )
	end
	
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, color_white )
	end

end