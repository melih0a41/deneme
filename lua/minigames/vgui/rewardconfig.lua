--[[--------------------------------------------
        Minigame Setup Menu - Rewards Config
--------------------------------------------]]--

-- local MAX_REWARDS = 8
local Background = Color(30, 30, 30, 180)

local ButtonStyleBackground = Color(82, 82, 82, 150)
local BlackBackground = Color(0, 0, 0, 40)

local ShadingColor = {}
for i = 1, 16 do
    ShadingColor[i] = Color(0, 158, 185, (i * 160) / 16)
end

local ButtonStyle = function(SelfButton, w, h)
    if not SelfButton:IsEnabled() then
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100))
    else
        draw.RoundedBox(4, 0, 0, w, h, ButtonStyleBackground)

        if SelfButton:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, BlackBackground)

            for i = 1, 16 do
                draw.RoundedBox(0, 0, h + i - 16, w, 1, ShadingColor[i])
            end
        end
    end
end



--[[----------------------------
         Reward Settings
----------------------------]]--

local REWARDSETTINGS = {}

function REWARDSETTINGS:Init()
    self.RewardID = nil

    self.Title = self:Add("DLabel")
    self.Title:SetText( Minigames.GetPhrase("reward.select") )
    self.Title:SetFont("Minigames.Text")
    self.Title:SetTextColor(color_white)
    self.Title:SetContentAlignment(5)
    self.Title:Dock(TOP)
    self.Title:DockMargin(5, 5, 5, 5)
    self.Title:SetWrap(true)
    self.Title:SetAutoStretchVertical(true)

    self.Input = self:Add("DPanel")
    self.Input:Dock(FILL)
    self.Input:DockMargin(5, 5, 5, 5)
    self.Input.Reward = {}
    self.Input.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, ButtonStyleBackground)
    end

    self.Submit = self:Add("DButton")
    self.Submit:SetText( Minigames.GetPhrase("reward.add") )
    self.Submit:SetTextColor(color_white)
    self.Submit:Dock(BOTTOM)
    self.Submit:DockMargin(5, 5, 5, 5)
    self.Submit:SetDisabled(true)
    self.Submit.Paint = ButtonStyle

    self.Submit.DoClick = function()
        local Reward = Minigames.GetReward(self.RewardID)

        for _, Argument in ipairs(self.Input.Reward) do
            if Argument.InputType == "text" then
                if Argument:GetNumeric() then
                    Reward:AddValue( Argument:GetInt() )
                else
                    Reward:AddValue( Argument:GetText() )
                end
            elseif Argument.InputType == "slider" then
                Reward:AddValue( math.floor( Argument:GetValue() ) )
            elseif Argument.InputType == "list" then
                local _, data = Argument:GetSelected()
                Reward:AddValue( data )
            end
        end

        Reward:AddReward()
    end
end

function REWARDSETTINGS:SetReward(RewardID)
    if not Minigames.GetReward(RewardID) then return end

    self.RewardID = RewardID
    self.Submit:SetDisabled(false)

    -- Remove old input
    self.Input:Clear()
    self.Input.Reward = {}

    local RewardData = Minigames.GetReward(RewardID)

    self.Title:SetText( RewardData["Name"] )

    for _, ArgumentTbl in ipairs(RewardData["Arguments"]) do
        local ArgumentPanel = self.Input:Add("DPanel")
        ArgumentPanel:Dock(TOP)
        ArgumentPanel:DockMargin(5, 5, 5, 5)
        ArgumentPanel:DockPadding(10, 0, 10, 0)
        ArgumentPanel:SetTall(52)
        ArgumentPanel.Paint = function(_, w, h)
            draw.RoundedBox(4, 0, 0, w, h, ButtonStyleBackground)
        end

        local ArgumentLabel = ArgumentPanel:Add("DLabel")
        ArgumentLabel:SetText( ArgumentTbl["Name"] )
        ArgumentLabel:SetFont("Minigames.Text")
        ArgumentLabel:SetTextColor(color_white)
        ArgumentLabel:Dock(TOP)
        ArgumentLabel:DockMargin(5, 3, 5, 3)
        ArgumentLabel:SetWide(100)
        ArgumentLabel:SetContentAlignment(5)

        if ArgumentTbl["Type"] == "text" then
            local ArgumentText = ArgumentPanel:Add("DTextEntry")
            ArgumentText:SetText( ArgumentTbl["Default"] )
            ArgumentText:SetPlaceholderText( ArgumentTbl["Placeholder"] )
            ArgumentText:Dock(FILL)
            ArgumentText:SetNumeric( ArgumentTbl["Numeric"] or false )
            ArgumentText.InputType = "text"

            table.insert(self.Input.Reward, ArgumentText)

        elseif ArgumentTbl["Type"] == "slider" then
            ArgumentLabel:Remove()

            local ArgumentSlider = ArgumentPanel:Add("DNumSlider")
            ArgumentSlider:SetText( ArgumentTbl["Name"] )
            ArgumentSlider:SetMin( ArgumentTbl["Min"] )
            ArgumentSlider:SetMax( ArgumentTbl["Max"] )
            ArgumentSlider:SetValue( ArgumentTbl["Default"] )
            ArgumentSlider:SetDecimals(0)
            ArgumentSlider:Dock(FILL)
            ArgumentSlider.InputType = "slider"

            table.insert(self.Input.Reward, ArgumentSlider)

        elseif ArgumentTbl["Type"] == "list" then
            local ArgumentList = ArgumentPanel:Add("DComboBox")
            ArgumentList:Dock(FILL)
            ArgumentList:SetValue( ArgumentTbl["Default"] )
            ArgumentList.InputType = "list"

            if ArgumentTbl["IsDictionary"] then
                for Value, Option in pairs(ArgumentTbl["Options"]) do
                    ArgumentList:AddChoice(Option, Value, Value == ArgumentTbl["Default"])
                end
            else
                for _, Option in ipairs(ArgumentTbl["Options"]) do
                    ArgumentList:AddChoice(Option, Option, Option == ArgumentTbl["Default"])
                end
            end

            ArgumentList.OnSelect = function(_, _, value)
                ArgumentList:SetValue(value)
            end

            table.insert(self.Input.Reward, ArgumentList)

        elseif ArgumentTbl["Type"] == "none" then
            ArgumentLabel:Dock(FILL)
            ArgumentLabel:SetText( ArgumentTbl["Name"] )
        end
    end
end

function REWARDSETTINGS:Paint()
    -- Nothing
end

vgui.Register("Minigames.RewardSettings", REWARDSETTINGS, "DPanel")



--[[----------------------------
           Reward Menu
----------------------------]]--

local PANEL = {}

function PANEL:AddReward(Reward)
    local RewardPanel = self.Container:Add("DButton")
    RewardPanel:SetText(Reward:GetNameAmount() or Minigames.GetPhrase("reward.nothing"))
    RewardPanel:SetTextColor(color_white)

    if Reward:GetIcon() then
        RewardPanel:SetImage( Reward:GetIcon() )
    end

    RewardPanel:Dock(TOP)
    RewardPanel:DockMargin(3, 3, 3, 3)
    RewardPanel:SetTall(24)
    RewardPanel.Paint = ButtonStyle

    RewardPanel.DoClick = function(SubSelf)
        Reward:RemoveReward()
    end

    return RewardPanel
end

function PANEL:GetRewards()
    if not Minigames.ActiveGames[ LocalPlayer() ] then return {} end

    return Minigames.ActiveGames[ LocalPlayer() ]:GetRewards()
end

function PANEL:QueryReward()
    self.RewardSelected = {}

    self.PopUp = vgui.Create("DFrame")
    self.PopUp:SetSize( math.max(ScrW() * .36, 400), math.max(ScrH() * .71, 240))
    self.PopUp:Center()
    self.PopUp:SetTitle(Minigames.GetPhrase("reward.title"))
    self.PopUp:MakePopup()
    self.PopUp.Paint = Minigames.Paint

    self.List = self.PopUp:Add("DScrollPanel")
    self.List:Dock(LEFT)
    self.List:SetWide(200)
    self.List:DockMargin(5, 5, 5, 5)
    self.List.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Background)
    end
    self.List.VBar.Paint = nil

    self.PopUp.Buttons = self.PopUp:Add("Minigames.RewardSettings")
    self.PopUp.Buttons:Dock(FILL)
    self.PopUp.Buttons:DockMargin(5, 5, 5, 5)

    local EmptySpace = self.List:Add("Panel")
    EmptySpace:Dock(TOP)
    EmptySpace:SetTall(2)
    EmptySpace.Paint = nil

    for RewardID, RewardData in pairs(Minigames.GetRewards()) do
        local RewardPanel = self.List:Add("DButton")
        RewardPanel:SetText( RewardData["Name"] )
        RewardPanel:SetTextColor(color_white)
        RewardPanel:SetIcon( RewardData["Icon"] )
        RewardPanel:Dock(TOP)
        RewardPanel:DockMargin(5, 2, 5, 2)
        RewardPanel:SetTall(24)
        RewardPanel.Paint = ButtonStyle

        RewardPanel.DoClick = function()
            self.PopUp.Buttons:SetReward(RewardID)
        end
    end
end

function PANEL:ClosePopUp()
    if IsValid(self.PopUp) then
        self.PopUp:Remove()
    end
end

function PANEL:AddAllRewards()
    self.Container:Clear()

    local Rewards = self:GetRewards()
    for _, Reward in ipairs(Rewards) do
        self:AddReward( Reward )
    end
end

function PANEL:Init()
    self.Title = self:Add("DLabel")
    self.Title:SetText( Minigames.GetPhrase("reward.title") )
    self.Title:SetFont("Minigames.Title")
    self.Title:SetTextColor(color_white)
    self.Title:Dock(TOP)
    self.Title:DockMargin(5, 5, 5, 5)

    self.Container = self:Add("DScrollPanel")
    self.Container:Dock(FILL)
    self.Container:DockMargin(5, 5, 5, 5)
    self.Container.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Background)
    end

    self:AddAllRewards()

    self.Buttons = self:Add("Panel")
    self.Buttons:Dock(RIGHT)
    self.Buttons:DockMargin(5, 5, 5, 5)
    self.Buttons:SetWide(50)

    self.AddButton = self.Buttons:Add("DButton")
    self.AddButton:SetText("+")
    self.AddButton:Dock(TOP)
    self.AddButton:DockMargin(0, 0, 0, 5)
    self.AddButton:SetTextColor(color_white)
    self.AddButton.Paint = ButtonStyle
    self.AddButton.DoClick = function()
        -- self:AddReward()
        self:QueryReward()
    end

    self.AddButton:SetEnabled( Minigames.GetOwnerGame( LocalPlayer() ) ~= nil )
    if not self.AddButton:IsEnabled() then
        self.AddButton:SetTooltip( Minigames.GetPhrase("reward.disabled") )
    end
end

function PANEL:Paint()
    -- Nothing
end

vgui.Register("Minigames.RewardConfig", PANEL, "DPanel")