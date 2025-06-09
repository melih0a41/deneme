--[[--------------------------------------------
        Minigame Setup Menu - Game Config
--------------------------------------------]]--

local Gray = Color(170, 170, 170)
local Grayest = Color(170, 170, 170, 40)
local Background = Color(30, 30, 30, 180)
local ConfigBackground = Color(60, 60, 60, 150)

local function GetPhraseText(Str, GameID)
    if string.sub( Str, 1, 1 ) == "#" then
        Str = Minigames.GetPhrase( GameID .. ".header." .. string.sub( Str, 2 ) )
    elseif string.sub( Str, 1, 1 ) == "!" then
        Str = Minigames.GetPhrase( "minigames." .. string.sub( Str, 2 ) )
    end

    return Minigames.GetPhrase( Str )
end


--[[----------------------------
           Config Menu
----------------------------]]--

local CONFIG = {}

function CONFIG:Init()
    self.Title = self:Add("DLabel")
    self.Title:SetText("Template")
    self.Title:SetFont("Minigames.Text")
    self.Title:SetTextColor(color_white)
    self.Title:Dock(TOP)
    self.Title:DockMargin(5, 5, 5, 5)
    self.Title:SetTall(20)
    self.Title:SetContentAlignment(4)

    self.Setting = self:Add("Panel")
    self.Setting:Dock(TOP)
    self.Setting:DockMargin(10, 0, 10, 0)

    local HorizontalLine = self:Add("Panel")
    HorizontalLine:Dock(TOP)
    HorizontalLine:DockMargin(4, 4, 4, 4)
    HorizontalLine:SetTall(1)
    HorizontalLine.Paint = function(_, w, h)
        surface.SetDrawColor(Grayest)
        surface.DrawRect(0, 0, w, h)
    end

    self.Description = self:Add("DLabel")
    self.Description:SetText("Template")
    self.Description:SetFont("Minigames.Text")
    self.Description:SetTextColor(color_white)
    self.Description:Dock(TOP)
    self.Description:DockMargin(5, 0, 10, 5)
    self.Description:SetWrap(true)
    self.Description:SetAutoStretchVertical(true)
end

function CONFIG:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, ConfigBackground)
end

function CONFIG:SetConfig(ConfigData, GameID)
    self.Title:SetText( Minigames.GetPhrase(GameID .. "." .. ConfigData["Name"]) )
    self.Description:SetText( Minigames.GetPhrase(GameID .. "." .. ConfigData["Name"] .. ".desc") )
    local Convar = GetConVar( "minigames_" .. GameID .. "_" .. ConfigData["Name"] )

    if ConfigData["Config"]["type"] == "boolean" then
        local Checkbox = self.Setting:Add("DCheckBoxLabel")
        Checkbox:SetText("")
        Checkbox:SetValue(Convar:GetBool())
        Checkbox:Dock(LEFT)
        Checkbox:DockMargin(5, 0, 5, 0)

        Checkbox.OnChange = function(_, Value)
            Convar:SetString(Value and 1 or 0)
        end
    elseif ConfigData["Config"]["type"] == "table" then
        local Dropdown = self.Setting:Add("DComboBox")
        Dropdown:Dock(FILL)
        Dropdown:DockMargin(5, 0, 5, 0)

        for Key, Value in ipairs(ConfigData["Config"]["def"]) do
            Dropdown:AddChoice( GetPhraseText(Value, GameID), Key )
        end

        Dropdown:ChooseOptionID( Convar:GetInt() )

        Dropdown.OnSelect = function(_, Value)
            Convar:SetInt(Value)
        end
    else

        local ValueBackground = self.Setting:Add("Panel")
        ValueBackground:Dock(RIGHT)
        ValueBackground:SetWide(30)

        ValueBackground.Paint = function(_, w, h)
            surface.SetDrawColor(60, 60, 60, 150)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(Gray)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        local ValueEditor = vgui.Create("DTextEntry", ValueBackground)
        ValueEditor:SetTextColor(color_white)
        ValueEditor:SetContentAlignment(6)
        ValueEditor:Dock(FILL)
        ValueEditor:SetPaintBackground(false)
        ValueEditor:SetNumeric(true)
        ValueEditor:SetValue( math.Round(Convar:GetFloat(), ConfigData["Config"]["dec"]) )
        ValueEditor:SetUpdateOnType(true)
        ValueEditor:SetTooltip("Press Enter to apply")

        local CustomSlider = self.Setting:Add("DSlider")
        CustomSlider:Dock(FILL)
        CustomSlider:DockMargin(5, 0, 10, 0)
        CustomSlider:SetLockY(0.5)
        CustomSlider:SetSlideX( math.Round(Convar:GetFloat(), ConfigData["Config"]["dec"]) )
        CustomSlider:SetTrapInside(true)

        local Scratch = self.Setting:Add("DNumberScratch")
        Scratch:Dock(LEFT)
        Scratch:SetWide(16)
        Scratch:SetDecimals(ConfigData["Config"]["dec"])
        Scratch:SetValue( math.Round(Convar:GetFloat(), ConfigData["Config"]["min"]) )
        Scratch:SetMin(ConfigData["Config"]["min"])
        Scratch:SetMax(ConfigData["Config"]["max"])
        Scratch:SetConVar(Convar:GetName())

        Scratch:SetFraction( Convar:GetFloat() )

        CustomSlider.Paint = function(SubSelf, w, h)
            surface.SetDrawColor(Gray)
            surface.DrawRect(7, h / 2 - 1, w - 14, 1)

            surface.SetDrawColor(Gray)
            surface.DrawRect(7, h / 2 + 4, 1, 4)
            for i = 1, 8 do
                surface.DrawRect(8 + i * (w - 16) / 8, h / 2 + 4, 1, 4)
            end
        end

        local NoLoop = false
        ValueEditor.OnEnter = function(SubSelf)
            if NoLoop then NoLoop = false return end

            NewValue = math.Clamp(tonumber(SubSelf:GetValue()), ConfigData["Config"]["min"], ConfigData["Config"]["max"])

            CustomSlider:SetSlideX(NewValue)
            Scratch:SetValue(NewValue)
            ValueEditor:SetValue(NewValue)
            NoLoop = true
        end

        if ConfigData["Config"]["dec"] == 0 then
            Scratch.OnValueChanged = function(_, Value)
                CustomSlider:SetSlideX( (Value - ConfigData["Config"]["min"]) / (ConfigData["Config"]["max"] - ConfigData["Config"]["min"]) )
                ValueEditor:SetValue( math.floor(Value) )
            end
        else
            Scratch.OnValueChanged = function(_, Value)
                CustomSlider:SetSlideX( (Value - ConfigData["Config"]["min"]) / (ConfigData["Config"]["max"] - ConfigData["Config"]["min"]) )
                ValueEditor:SetValue( math.Round(Value, ConfigData["Config"]["dec"]) )
            end
        end

        CustomSlider.TranslateValues = function(SubSelf, x, y)
            ValueEditor:SetValue( math.Round( Lerp(x, ConfigData["Config"]["min"], ConfigData["Config"]["max"]), ConfigData["Config"]["dec"] ) )
            Scratch:SetValue( ValueEditor:GetValue() )
            return x, y
        end

        --[[
        NSlider.OnValueChanged = function(_, Value)
            RunConsoleCommand("minigame_" .. GameID .. "_" .. string.lower(ConfigData["Name"]), Value)
        end
        --]]
    end
end

function CONFIG:OnSizeChanged(w, h)
    self:SizeToChildren(false, true)
end

vgui.Register("Minigames.Config", CONFIG, "DPanel")



--[[----------------------------
            Main Menu
----------------------------]]--

local PANEL = {}

function PANEL:Init()
    self.Container = vgui.Create("Panel", self)

    self.GameTargetConvar = GetConVar("minigames_game")

    self.GameList = self:Add("DComboBox")
    self.GameList:Dock(TOP)
    self.GameList:DockMargin(5, 5, 5, 5)
    self.GameList:SetValue( Minigames.GetPhrase("minigames.selectone") )
    self.GameList:SetSortItems(false)

    local TargetGame = self.GameTargetConvar:GetString()
    local ChoiceValue, ChoiceIndex
    for GameID, GameData in pairs(Minigames.Games) do
        local index = self.GameList:AddChoice( Minigames.GetPhrase(GameID .. ".name"), GameID )

        if GameID == TargetGame then
            ChoiceValue = Minigames.GetPhrase(GameID .. ".name")
            ChoiceIndex = index
        end
    end

    self.Header = vgui.Create("DLabel", self.Container)
    self.Header:SetText( Minigames.GetPhrase("minigames.selectone") )
    self.Header:SetFont("Minigames.Title")

    self.Description = vgui.Create("DLabel", self.Container)
    self.Description:SetText("")
    self.Description:SetFont("Minigames.Text")
    self.Description:SetWrap(true)
    self.Description:SetAutoStretchVertical(true)

    self.GameConfig = vgui.Create("DScrollPanel", self.Container)
    self.GameConfig:Dock(FILL)
    self.GameConfig:DockMargin(5, 5, 5, 5)
    self.GameConfig:DockPadding(5, 5, 5, 5)
    self.GameConfig.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Background)
    end

    self.GameConfig:GetVBar().Paint = nil

    if ChoiceValue then
        self.GameList:ChooseOptionID(ChoiceIndex)
        self:SetGameID(TargetGame)
        self.GameTargetConvar:SetString(TargetGame)
    end

    self.GameList.OnSelect = function(_, _, _, Value)
        self:SetGameID(Value, true)
        self.GameTargetConvar:SetString(Value)
    end

    self.GameList:SetEnabled( Minigames.GetOwnerGame( LocalPlayer() ) == nil )
    if not self.GameList:IsEnabled() then
        self.GameList:SetTooltip(Minigames.GetPhrase("minigames.removeyourgame"))
    end
end

function PANEL:Update()
    self.GameConfig:Clear()
    if not self.GameData then return end

    local GameID = self.GameData:GetGameID()
    self.Header:SetText( Minigames.GetPhrase(GameID .. ".name") )
    self.Description:SetText( Minigames.GetPhrase(GameID .. ".desc") )

    local Configs = self.GameData:GetAllConfig()
    for _, ConfigData in ipairs(Configs) do

        if ConfigData["Header"] then
            local Header = self.GameConfig:Add("DLabel")
            Header:SetText(GetPhraseText(ConfigData["Name"], GameID))
            Header:SetFont("Minigames.Title")
            Header:Dock(TOP)
            Header:SetTall(32)
            Header:DockMargin(10, 15, 5, 5)
            Header:SetTextColor(color_white)

        else
            local Config = vgui.Create("Minigames.Config")
            Config:SetConfig(ConfigData, GameID)
            Config:Dock(TOP)
            Config:DockMargin(10, 0, 10, 5)
            Config:DockPadding(5, 5, 5, 5)
            self.GameConfig:AddItem(Config)
        end

    end

    local EmptySpace = self.GameConfig:Add("Panel")
    EmptySpace:Dock(TOP)
    EmptySpace:DockMargin(5, 5, 5, 5)
    EmptySpace:SetTall(12)

    timer.Simple(.07, function()
        for _, Setting in ipairs(self.GameConfig:GetCanvas():GetChildren()) do
            if Setting:GetName() ~= "Minigames.Config" then continue end
            Setting:SizeToChildren(false, true)
        end
        timer.Simple(.07, function()
            self.GameConfig:GetVBar():SetScroll( GetGlobalInt("minigames_scrollpos", 0) )
            for _, Setting in ipairs(self.GameConfig:GetCanvas():GetChildren()) do
                if Setting:GetName() ~= "Minigames.Config" then continue end
                Setting:SizeToChildren(false, true)
            end
        end)
    end)
end

function PANEL:SetGameID(ID, ClearScroll)
    local GameData = Minigames.Games[ID]

    if ClearScroll then
        SetGlobalInt("minigames_scrollpos", 0)
    end

    self.GameData = GameData
    self:Update()
end

function PANEL:SaveScroll()
    SetGlobalInt("minigames_scrollpos", self.GameConfig:GetVBar():GetScroll()) -- for some reason, the game remove the old variable
end

function PANEL:PostInit()
    self.Header:Dock(TOP)
    self.Header:DockMargin(5, 5, 5, 5)
    self.Header:SetWrap(true)
    self.Header:SetContentAlignment(5)
    self.Header:SetTextColor(color_white)

    self.Description:Dock(TOP)
    self.Description:SetTall(32)
    self.Description:DockMargin(5, 0, 5, 5)
    self.Description:SetTextColor(color_white)
end

vgui.Register("Minigames.GameConfig", PANEL, "Panel")