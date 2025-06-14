-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()

function PANEL:Init(realInit)

	if !realInit then return end

	CL_ANTICRASH.SkinScrollPanel(self)
	
	local pWide, pTall = self:GetSize()
	local offset = 10
	local buttonW = pWide-(offset*2)
	local buttonH = 28
	
	-- Prevent overlapping scroll items
	local _, selfY = self:GetPos()
	self:SetPos(0,selfY+offset)
	self:SetSize(pWide,(pTall-offset*2))
	
	-- Vision Button
	local hasGlobalVision = CL_ANTICRASH.ENTVISION.GetGlobalVision()
	
	local function entVisionBtnText()
		return hasGlobalVision and SH_ANTICRASH.Translate("hideEntities") or SH_ANTICRASH.Translate("showEntities")
	end
	
	local entityVisionBtn = CL_ANTICRASH.CreateColorSwitchButton(offset, 0, buttonW, buttonH, entVisionBtnText(), "z_anticrash_global_btn", SH_ANTICRASH.VARS.COLOR.DARKPURPLE, SH_ANTICRASH.VARS.COLOR.CONTRASTFUCHSIA, hasGlobalVision, self, function(self)
		
		CL_ANTICRASH.ENTVISION.SetGlobalVision(!hasGlobalVision)
		CL_ANTICRASH.PlaySound("togglePress")
		
		hasGlobalVision = !hasGlobalVision
		self.__isSelected = hasGlobalVision
		self:SetText(entVisionBtnText())
		
	end)
	
	-- Separation Line
	local dividerH = 4
	local dividerPnl = CL_ANTICRASH.CreateDividerLine(offset,entityVisionBtn:GetBottomY()+offset, buttonW, dividerH, SH_ANTICRASH.VARS.COLOR.LESSDARKY, self)
	
	-- Cleanup Buttons
	local nextY = dividerPnl:GetBottomY()+offset
	local cleanupTypes = SH_ANTICRASH.VARS.CLEANUP.TYPES
	
	for i=1, #cleanupTypes do
	
		if i==5 then
		
			local dividerPnl = CL_ANTICRASH.CreateDividerLine(offset,nextY, buttonW, dividerH, SH_ANTICRASH.VARS.COLOR.LESSDARKY, self)
			nextY = dividerPnl:GetBottomY()+offset
			
		end
		
		local cleanupType, cleanupStr, isDefault = cleanupTypes[i].type, cleanupTypes[i].name, cleanupTypes[i].isDefault
		local cleanupCol = SH_ANTICRASH.VARS.CLEANUP.COLORS[i]
		
		if !isDefault then
			cleanupStr = SH_ANTICRASH.Translate(cleanupStr)
		end

		local cleanupBtn = CL_ANTICRASH.CreateButtonColorFade(offset, nextY, buttonW, buttonH, cleanupStr, "z_anticrash_global_btn", cleanupCol, color_white, self, function()
			
			local delay = cleanupStr == "Reset Map" and 0.1 or 0
			
			timer.Simple(delay,function()
				CL_ANTICRASH.PlaySound("gmodPress")
			end)
			
			net.Start("sv_anticrash_GlobalCleanup")
				net.WriteString(cleanupType)
			net.SendToServer()
			
		end)
		
		nextY = cleanupBtn:GetBottomY()+offset
	
	end

end
vgui.Register('p_anticrash_global',PANEL,'DScrollPanel')