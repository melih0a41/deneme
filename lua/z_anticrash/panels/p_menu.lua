-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()

local menuW, menuH = 500,700
local menuAnimSpeed = 0.2
local titleBarH = 35

local catBtnSize,catBtnOffset = 64,15
local catBtnAnimTimeShow, catBtnAnimTimeGrow = 0.3, 0.05
local circleTexID = surface.GetTextureID("z_anticrash/vgui/circle")
local closeBtnIcon = "z_anticrash/vgui/cross"

local categoryBtns = {
	{"stats","p_anticrash_stats","z_anticrash/icons/eye",60},
	{"users","p_anticrash_users","z_anticrash/icons/user",52},
	{"global","p_anticrash_global","z_anticrash/icons/group",48},
}

local catPosY = 0
local activeCategoryName = nil
local activeCategory = nil

local function CreateCategoryButton(i,parent,menuPanel,name,panel,icon,iconSize)

	if !SH_ANTICRASH.HasAccess(name) then return end
	
	if !activeCategoryName then
		activeCategoryName = name
	end
	
	local iconTexID = surface.GetTextureID(icon)
	local finishedAnimation, finishedLoadingAnimation = false, false
	
	-- Rounded Image Button
	local catBtn = vgui.Create( "DButton", parent )
	catBtn:SetPos(0,catPosY)
	catBtn.__x = 0
	catBtn.__y = catPosY
	
	catBtn:SetText("")
	catBtn:SetZPos(-1)
	catBtn:SetSize(catBtnSize+catBtnOffset,catBtnSize+catBtnOffset)
	catBtn.__realSize = catBtnSize
	
	catBtn.Paint = function(self, w, h)
	
		local wide = self:GetWide()
		local circleX, circleY = wide/2-catBtn.__realSize/2, wide/2-catBtn.__realSize/2
		local iconX, iconY = wide/2-iconSize/2, wide/2-iconSize/2
	
		-- Circle bg
		surface.SetDrawColor( SH_ANTICRASH.VARS.COLOR.DARKY )
		surface.SetTexture( circleTexID )
		surface.DrawTexturedRect(circleX, circleY, catBtn.__realSize, catBtn.__realSize )
		
		-- Circle FG
		surface.SetDrawColor( ColorAlpha(color_white, self.__bgAlpha) )
		surface.SetTexture( circleTexID )
		surface.DrawTexturedRect(circleX, circleY, catBtn.__realSize, catBtn.__realSize )
	
		-- Icon
		surface.SetDrawColor( color_white )
		surface.SetTexture( iconTexID )
		surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize )
		
	end
	
	catBtn.__bgAlpha = 0
	local nextThink, fadeSpeed = 0, 10
	catBtn.Think = function(self, w, h)
		
		if nextThink < CurTime() then
	
			-- alpha fade
			if self.__cursorIn or (name == activeCategoryName and finishedLoadingAnimation) then
			
				self.__bgAlpha = math.Approach(self.__bgAlpha, 255, fadeSpeed)
				
			else
				self.__bgAlpha = math.Approach(self.__bgAlpha, 0, fadeSpeed)
			end
			
			-- size
			if self.__cursorIn then
				self.__realSize = math.Approach(self.__realSize, catBtnSize*1.1, 2)
			else
				self.__realSize = math.Approach(self.__realSize, catBtnSize, 2)
			end
			
			-- Limit to 30FPS
			nextThink = CurTime() + 0.033
			
		end
	
	end
	
	catBtn.DoClick = function(self,force)
		
		-- No action if trying to reopen the same catetgory
		if activeCategoryName == name and !force then 
			return
		end
		
		-- Play sound
		if !force then
			CL_ANTICRASH.PlaySound("catPress")
		end
		
		-- Remove prev created cat
		if activeCategory ~= nil then
			activeCategory:Remove()
		end
		
		activeCategoryName = name
		
		local menuPanelW,menuPanelH = menuPanel:GetSize()
		
		activeCategory = vgui.Create(panel,menuPanel)
		
		if activeCategory ~= nil then
			activeCategory:SetPos(0,titleBarH)
			activeCategory:SetSize(menuPanelW,menuPanelH-titleBarH)
			activeCategory:Init(true)
		else
			error("Panel <"..panel.."> does not exist!")
		end
		
	end
	
	if name == activeCategoryName then
		catBtn:DoClick(true)
	end
	
	-- Grow btn
	catBtn.OnCursorEntered = function(self)
		self.__cursorIn = true
	end

	catBtn.OnCursorExited = function(self)
		self.__cursorIn = false
	end
	
	-- Button animation
	local animDelay = catBtnAnimTimeShow*(i-1)
	catBtn:SetPos(catBtnSize+catBtnOffset, catPosY)
	catBtn:SetAlpha(0)
	
	timer.Simple(menuAnimSpeed,function()
		
		if IsValid(catBtn) then
			catBtn:SetAlpha(255)
			catBtn:MoveTo( catBtn.__x, catBtn.__y, catBtnAnimTimeShow, animDelay, -1, function()
				finishedAnimation = true
				finishedLoadingAnimation = true
			end)
		end
		
	end)
	
	catPosY = catPosY + catBtnSize + 10
	
end

function PANEL:Init()
	
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSize(menuW+catBtnSize+catBtnOffset,menuH)
	self:Center()
	self.Paint = function() end
	
	-- animate alpha
	self:SetAlpha(0)
	self:AlphaTo(255, menuAnimSpeed)
	
	self:MoveToFront()
	self:MakePopup()
	
	local menuPanel = vgui.Create("DPanel",self)
	menuPanel:SetPos(catBtnSize+catBtnOffset)
	menuPanel:SetSize(menuW, menuH)
	
	-- Title
	local titleLbl = CL_ANTICRASH.CreateLbl(0, 5, "Anti-Crash", "z_anticrash_menu_title", ColorAlpha(SH_ANTICRASH.VARS.COLOR.RED,200), menuPanel)
	titleLbl:CenterHorizontal()
	
	-- Close btn
	local closeBtn = vgui.Create( "DImageButton", menuPanel )
	closeBtn:SetPos( menuW-28, 8 )
	closeBtn:SetSize( 20, 20 )
	closeBtn:SetColor(Color(255,255,255,200))
	closeBtn:SetImage( closeBtnIcon )	
	closeBtn.DoClick = function()
		CL_ANTICRASH.ToggleMenu(true)
	end
	
	-- Categories
	catPosY = 40
	
	for i=1, #categoryBtns do
		
		local cat = categoryBtns[i]
	
		CreateCategoryButton(i,self,menuPanel,cat[1],cat[2],cat[3],cat[4])
		
	end
	
	menuPanel.Paint = function(self, w, h)
	
		-- Menu bg
		surface.SetDrawColor(SH_ANTICRASH.VARS.COLOR.DARK)
		surface.DrawRect(0,titleBarH,w,h)
		
		-- Title bar bg
		surface.SetDrawColor(SH_ANTICRASH.VARS.COLOR.LIGHTDARK)
		surface.DrawRect(0,0,w,titleBarH)
		
	end
	
end
vgui.Register("p_anticrash_menu",PANEL,"DFrame")
