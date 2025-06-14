-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()

local menuW, menuH = 500,600
local menuAnimSpeed = 0.2

function PANEL:Init()
	
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSize(menuW,menuH)
	self:SetPos(10,10)
	self.Paint = function() end
	
	-- animate alpha
	self:SetAlpha(0)
	self:AlphaTo(240, menuAnimSpeed)
	
	self:MoveToFront()
	
	// Stats
	local statsP = vgui.Create("p_anticrash_stats", self)
	statsP:SetPos(0,0)
	statsP:SetSize(menuW,menuH)
	statsP:Init(true, true)
	
end
vgui.Register("p_anticrash_overlay", PANEL, "DFrame")