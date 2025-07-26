local PANEL = {}

function PANEL:Init()
	self.topbarHeight = Corporate_Takeover.Scale(40)

	self.Title = "";
	self:SetTitle("")
	self:ShowCloseButton(false)
    self:MakePopup()
	self:DockPadding(Corporate_Takeover.Scale(10), self.topbarHeight + Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10), Corporate_Takeover.Scale(10))

    local close = vgui.Create("DButton", self)
    close:SetSize(Corporate_Takeover.Scale(80), self.topbarHeight)
    timer.Simple(0, function()
    	if(close) then
    		close:SetPos(self:GetWide() - Corporate_Takeover.Scale(80), 0)
    	end
    end)
    close:SetText("X")
	close:SetFont("cto_25")
	close:SetTextColor(Corporate_Takeover.Config.Colors.Background)
    close.DoClick = function(slf) 
    	if(IsValid(self)) then
    		if(self.OnClose) then
    			self.OnClose()
    		end

    		self:Remove()
    	end

		surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)
	end
	function close:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and Corporate_Takeover.Config.Colors.CloseButtonHover or Corporate_Takeover.Config.Colors.CloseButton)
	end

	self.close = close
end

function PANEL:MinimalPadding()
	self:DockPadding(0, self.topbarHeight, 0, 0)
end

local color_gray = Color(46, 46, 46)

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Corporate_Takeover.Config.Colors.Background)
	draw.RoundedBox(0, 0, 0, w, self.topbarHeight, color_gray)
	draw.SimpleText(self.Title, "cto_25", 10, self.topbarHeight/2, Corporate_Takeover.Config.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:SetWindowTitle(title)
	self.Title = title;
end

vgui.Register("cto_main", PANEL, "DFrame")