-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()
local lastOpenedUser = nil

local flagTexID = surface.GetTextureID("z_anticrash/icons/flag")
local circleTexID = surface.GetTextureID("z_anticrash/vgui/circle")


function PANEL:Init(realInit)

	if !realInit then return end

	CL_ANTICRASH.SkinScrollPanel(self)
		
	local pWide, pTall = self:GetSize()
	local filterPanels = {}
	
	// Search bar
	local searchInputBg, searchInput = CL_ANTICRASH.CreateTextInput(10, 0, pWide-20, 30, "", "z_anticrash_user_info_search", color_white, self)
	searchInput:SetPlaceholderColor(SH_ANTICRASH.VARS.COLOR.LIGHTGREY)
	searchInput:SetPlaceholderText(SH_ANTICRASH.Translate("search"))
	
	CL_ANTICRASH.HookSearchInputFilter(searchInput,filterPanels)
	
	// Player panels
	local panelOffset = 10
	local plyPanelW = pWide-(panelOffset*2)
	local plyPanelH, plyPanelHE = 30, 194
	
	local startY = searchInputBg:GetBottomY()+panelOffset
	local prevY = startY
	local prevPlyPanel = nil
	
	-- Prevent overlapping scroll items
	local _, selfY = self:GetPos()
	local selfW, selfH = self:GetSize()
	self:SetPos(0,selfY+panelOffset)
	self:SetSize(selfW,(selfH-panelOffset*2))
		
	local function AddPlayerPanel(ply)
		
		local plyPanel = vgui.Create("DPanel", self)
		local nick = ply:Nick()
		
		plyPanel.isExpanded = false
		plyPanel.prevPnl = prevPlyPanel
		plyPanel.panelOffset = panelOffset
		
		plyPanel:SetPos(panelOffset,prevY)
		plyPanel:SetSize(plyPanelW,plyPanelH)
		plyPanel.Think = function(self)
			
			if self.prevPnl then
				self:SetPos(panelOffset,self.prevPnl:GetBottomY()+panelOffset)
			else
				self:SetPos(panelOffset,startY)
			end
			
		end
		
		prevY = prevY + plyPanelH + panelOffset
		prevPlyPanel = plyPanel
		table.insert(filterPanels,{
			filterStr = nick,
			filterPanel = plyPanel
		})

		local plyBtn = vgui.Create("DButton", plyPanel)
		plyBtn:SetSize(plyPanelW,plyPanelH)
		plyBtn:SetFont("z_anticrash_graph_btn")
		plyBtn:SetText(nick)
		plyBtn:SetTextColor(color_white)
		
		local flagCol = ColorAlpha(SH_ANTICRASH.VARS.COLOR.RED,150) 
		plyBtn.Paint = function(self, w, h)
		
			-- Bg
			draw.RoundedBox(4, 0, 0, w, h, SH_ANTICRASH.VARS.COLOR.LIGHTDARK)
			
			local flagCount = ply:z_anticrashGetFlaggedCount()
			
			if flagCount > 0 then
			
				-- Flag icon
				local flagOffset = 7
				local flagSize = h-(flagOffset*2)
				local flagX = w-flagSize-flagOffset
				surface.SetDrawColor( flagCol )
				surface.SetTexture( flagTexID )
				surface.DrawTexturedRect( flagX, flagOffset, flagSize, flagSize )
				
				-- Flag txt
				surface.SetFont( "z_anticrash_flag_count" )
				local flagTxtW, flagTxtH = surface.GetTextSize( flagCount )
				
				surface.SetTextColor( flagCol )
				surface.SetTextPos( flagX-flagTxtW, h/2-flagTxtH/2 ) 
				surface.DrawText( flagCount )
				
				
			end
			
		end
		plyBtn.DoClick = function(self)
			
			local newH = plyPanelHE
			
			if plyPanel.isExpanded then
				newH = plyPanelH
				
				-- Only reset last choice when no other active panel was opened
				if lastOpenedUser == ply then
					lastOpenedUser = nil
				end
				
			else
				lastOpenedUser = ply
			end
			
			plyPanel:SizeTo( -1, newH, 0.25 )
			plyPanel.isExpanded = !plyPanel.isExpanded
			CL_ANTICRASH.PlaySound("plyPress")
			
		end
		
		if lastOpenedUser == ply then
			plyBtn:DoClick()
		end
		
		-- Can spawn btn
		local circleSize = 20
		local canSpawnBtn = vgui.Create("DButton",plyBtn)
		canSpawnBtn:SetPos(7,5)
		canSpawnBtn:SetSize(plyPanelH,plyPanelH)
		canSpawnBtn:SetText("")
		canSpawnBtn.Paint = function(self, w, h)
		
			-- Circle bg
			surface.SetDrawColor( ColorAlpha(SH_ANTICRASH.VARS.COLOR.GREEN, 255-self.__bgAlpha) )
			surface.SetTexture( circleTexID )
			surface.DrawTexturedRect(0, 0, circleSize, circleSize)
			
			-- Circle FG
			surface.SetDrawColor( ColorAlpha(SH_ANTICRASH.VARS.COLOR.RED, self.__bgAlpha) )
			surface.SetTexture( circleTexID )
			surface.DrawTexturedRect(0, 0, circleSize, circleSize)
			
		end
		canSpawnBtn.__bgAlpha = (ply:z_anticrashGetCanSpawnGlobal() and 0) or 255
		canSpawnBtn.__nextCheckSelected = 0
		canSpawnBtn.Think = function(self, w, h)
			
			if self.__nextCheckSelected < CurTime() then
				self.isSelected = ply:z_anticrashGetCanSpawnGlobal()
			end
		
			-- alpha fade
			if self.isSelected then
				self.__bgAlpha = math.Approach(self.__bgAlpha, 0, 3)
			else
				self.__bgAlpha = math.Approach(self.__bgAlpha, 255, 3)
			end
		end
		canSpawnBtn.DoClick = function(self)
			
			CL_ANTICRASH.PlaySound("togglePress")
			
			self.__nextCheckSelected = CurTime() + 1
			self.isSelected = !self.isSelected
			
			net.Start("sv_anticrash_SetCanSpawnGlobal")
				net.WriteEntity(ply)
				net.WriteBool(self.isSelected)
			net.SendToServer()
			
		end
		
		-- Info panels
		local infoPnlOffset = 6
		local infoPnlW, infoPnlH = plyPanel:GetWide()/2 - (infoPnlOffset*1.5), 22
		
		local entInfoPanel = CL_ANTICRASH.CreateUserInfoPanel(infoPnlOffset, plyBtn:GetBottomY()+infoPnlOffset, infoPnlW, infoPnlH, SH_ANTICRASH.Translate("entities"), "ENTITIES", "GetEntityCount", ply, plyPanel)
		local spawnedEntInfoPanel = CL_ANTICRASH.CreateUserInfoPanel(entInfoPanel:GetRightX()+infoPnlOffset, plyBtn:GetBottomY()+infoPnlOffset, infoPnlW, infoPnlH, SH_ANTICRASH.Translate("spawned"), "SPAWNEDENTS", "GetSpawnedEntitiesCount", ply, plyPanel)
		
		local propInfoPanel = CL_ANTICRASH.CreateUserInfoPanel(infoPnlOffset, entInfoPanel:GetBottomY()+infoPnlOffset, infoPnlW, infoPnlH, SH_ANTICRASH.Translate("props"), "PROPS", "GetPropCount", ply, plyPanel)
		local constraintsInfoPanel = CL_ANTICRASH.CreateUserInfoPanel(propInfoPanel:GetRightX()+infoPnlOffset, entInfoPanel:GetBottomY()+infoPnlOffset, infoPnlW, infoPnlH, SH_ANTICRASH.Translate("constraints"), "CONSTRAINTS", "GetConstraintCount", ply, plyPanel)
		
		-- Entity vision button
		local buttonW, buttonH = plyPanel:GetWide() - (infoPnlOffset*2), 20
		local entVisionHasPlayer = CL_ANTICRASH.ENTVISION.HasPlayer(ply)
		
		local function entVisionBtnText()
			return entVisionHasPlayer and SH_ANTICRASH.Translate("hideEntities") or SH_ANTICRASH.Translate("showEntities")
		end
		
		local entityVisionBtn = CL_ANTICRASH.CreateColorSwitchButton(infoPnlOffset, constraintsInfoPanel:GetBottomY()+(infoPnlOffset*3), buttonW, buttonH, entVisionBtnText(), "z_anticrash_user_info_button", SH_ANTICRASH.VARS.COLOR.DARKPURPLE, SH_ANTICRASH.VARS.COLOR.CONTRASTFUCHSIA, entVisionHasPlayer, plyPanel, function(self)
			
			CL_ANTICRASH.PlaySound("togglePress")
			
			if !entVisionHasPlayer then
				CL_ANTICRASH.ENTVISION.AddPlayer(ply)
			else
				CL_ANTICRASH.ENTVISION.RemovePlayer(ply)
			end
			
			entVisionHasPlayer = !entVisionHasPlayer
			self.__isSelected = entVisionHasPlayer
			self:SetText(entVisionBtnText())
			
		end)
		
		-- Entity Control buttons
		local freezeEntsBtn = CL_ANTICRASH.CreateButtonColorFade(infoPnlOffset, entityVisionBtn:GetBottomY()+(infoPnlOffset*3), buttonW, buttonH, SH_ANTICRASH.Translate("freezeEntities"), "z_anticrash_user_info_button", SH_ANTICRASH.VARS.COLOR.SUPERDARKORGANGE, color_white, plyPanel, function()
			CL_ANTICRASH.PlaySound("gmodPress")
			net.Start("sv_anticrash_FreezeEntitiesFrom")
				net.WriteEntity(ply)
			net.SendToServer()
		end)
	
		local removeEntsBtn = CL_ANTICRASH.CreateButtonColorFade(infoPnlOffset, freezeEntsBtn:GetBottomY()+infoPnlOffset, buttonW, buttonH, SH_ANTICRASH.Translate("removeEntities"), "z_anticrash_user_info_button", SH_ANTICRASH.VARS.COLOR.DARKRED, color_white, plyPanel, function()
			CL_ANTICRASH.PlaySound("gmodPress")
			net.Start("sv_anticrash_RemoveEntitiesFrom")
				net.WriteEntity(ply)
			net.SendToServer()
		end)
		
		local userInfoDivider = constraintsInfoPanel:GetBottomY()+infoPnlOffset
		local entVisionDivider = entityVisionBtn:GetBottomY()+infoPnlOffset
		plyPanel.Paint = function(self, w, h)
		
			-- Bg
			draw.RoundedBox(4, 0, 0, w, h, SH_ANTICRASH.VARS.COLOR.DARKY)
			
			-- Divider lines
			-- local dividerW = w/2
			-- local dividerX = w/2-(dividerW/2)
			draw.RoundedBox(4, 0, userInfoDivider, w, 4, SH_ANTICRASH.VARS.COLOR.DARK)
			draw.RoundedBox(4, 0, entVisionDivider, w, 4, SH_ANTICRASH.VARS.COLOR.DARK)
			
		end
	
	end
	

	local plys = player.GetAll()
	
	-- Sort players alphabetically & by flags
	table.sort( plys, function(a, b) 
		
		local aFlags = a:z_anticrashGetFlaggedCount()
		local bFlags = b:z_anticrashGetFlaggedCount()
		
		if aFlags == bFlags then
			return a:Nick():lower() < b:Nick():lower()
		end
		
		return aFlags > bFlags
		
	end )
	
	for i=1, #plys do
		AddPlayerPanel(plys[i])
	end

end
vgui.Register('p_anticrash_users',PANEL,'DScrollPanel')