local function workerMenu(desk)
	if(!desk) then return false end

    local w, h = ScrW() * 0.2, ScrH() * 0.18

    local main = vgui.Create("cto_main")
    main:SetSize(w, h)
    main:Center()
    main:SetWindowTitle(Corporate_Takeover:Lang(desk:GetDeskClass()))
    function main:Think()
    	if(!desk) then
    		main:Remove()
    		return false
    	end
	end

	local heading = vgui.Create("DLabel", main)
	heading:Dock(TOP)
    heading:SetFont("cto_20")
    heading:SetTextColor(Corporate_Takeover.Config.Colors.Text)
    heading:SetContentAlignment(5)
    heading:SetTall(Corporate_Takeover.Scale(25))

    local earnings = vgui.Create("DLabel", main)
    earnings:Dock(TOP)
    earnings:SetTall(Corporate_Takeover.Scale(25))
    earnings:SetFont("cto_20")
    earnings:SetTextColor(Corporate_Takeover.Config.Colors.Text)
    earnings:SetContentAlignment(5)
    earnings:SetText("")

    local statContainer = vgui.Create("DPanel", main)
    statContainer:Dock(TOP)
    statContainer:SetTall(Corporate_Takeover.Scale(25))
    function statContainer:Paint() end

    local loss = vgui.Create("DLabel", statContainer)
    loss:Dock(LEFT)
    loss:SetFont("cto_20")
    loss:SetTextColor(Corporate_Takeover.Config.Colors.Red)
    loss:SetContentAlignment(6)
    loss:SetText("")
    loss:SetWide(main:GetWide()/2 - Corporate_Takeover.Scale(15))
    loss:DockMargin(0, 0, Corporate_Takeover.Scale(5), 0)

    local profit = vgui.Create("DLabel", statContainer)
    profit:Dock(LEFT)
    profit:SetFont("cto_20")
    profit:SetTextColor(Corporate_Takeover.Config.Colors.Green)
    profit:SetContentAlignment(4)
    profit:SetText("")
    profit:SetWide(main:GetWide()/2 - Corporate_Takeover.Scale(15))
    profit:DockMargin(Corporate_Takeover.Scale(5), 0, 0, 0)
    
    local cooldown = CurTime()
    function main:Think()
        if(cooldown > CurTime()) then return end
        cooldown = CurTime() + 0.5

		local lost = math.Round(desk:GetLoss())
		local earning = math.Round(desk:GetProfit())
		local diff = earning - lost
		local text = " (+- "..DarkRP.formatMoney(0)..")"
		if(diff > 0) then
			text = " (+"..DarkRP.formatMoney(diff)..")"
		else
			text = " ("..DarkRP.formatMoney(diff)..")"
		end

        heading:SetText(Corporate_Takeover:Lang("earnings")..": "..DarkRP.formatMoney(math.Round(desk:GetFullProfit()))..text)
        earnings:SetText(Corporate_Takeover:Lang("profit")..": "..DarkRP.formatMoney(math.Round(desk:GetProfitDiff())))
        loss:SetText("-"..DarkRP.formatMoney(math.Round(desk:GetLoss())))
        profit:SetText("+"..DarkRP.formatMoney(math.Round(desk:GetProfit())))
    end

    local buttonContainer = vgui.Create("DPanel", main)
    buttonContainer:Dock(BOTTOM)
    buttonContainer:SetTall(Corporate_Takeover.Scale(40))
    function buttonContainer:Paint() end

    local fire = vgui.Create("cto_button", buttonContainer)
    fire:Dock(LEFT)
    fire:SetWide(main:GetWide() / 2 - Corporate_Takeover.Scale(15))
    fire:DangerTheme()
    fire:SetText(Corporate_Takeover:Lang("fire_worker"))
    function fire:DoClick()
        surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)

        net.Start("cto_WorkerManagement")
            net.WriteBit(0)
        net.SendToServer()
        main:Remove()
    end

    local dismantle = vgui.Create("cto_button", buttonContainer)
    dismantle:Dock(RIGHT)
    dismantle:SetWide(main:GetWide() / 2 - Corporate_Takeover.Scale(15))
    dismantle:DangerTheme()
    dismantle:SetText(Corporate_Takeover:Lang("dismantle"))
    function dismantle:DoClick()
        surface.PlaySound(Corporate_Takeover.Config.Sounds.General.click)

        net.Start("cto_dismantleDesk")
        net.SendToServer()
        main:Remove()
    end
end

net.Receive("cto_OpenWorkerMenu", function()
    workerMenu(net.ReadEntity())
end)