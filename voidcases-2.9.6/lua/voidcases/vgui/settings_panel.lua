local function L(phrase)
    return VoidCases.Lang.GetPhrase(phrase)
end

local sc = VoidUI.Scale

-- Main options panel

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1000, 556)
    self.ccPanels = {}
    local this = self

    local selectionPanel = self:Add("Panel")
    selectionPanel:Dock(LEFT)
    selectionPanel.Paint = function (self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)
    end
    selectionPanel:SDockPadding(8,8,8,8)

    local rowPanel = selectionPanel:Add("VoidUI.RowPanel")
    rowPanel:Dock(FILL)
    rowPanel:SDockMargin(0, 0, 0, 10)
    rowPanel:SetSpacing(8)

    function selectionPanel:AddCategory(category)

        local this = self

        local panel = rowPanel:Add("DButton")
        panel:SetText("")
        panel.Paint = function (self, w, h)
            if (self:IsHovered() or this.selectedCategory == category) then
                if (this.selectedCategory == category) then
                    draw.RoundedBox(8, 0, 0, w, h, VoidCases.AccentColor)
                else
                    draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.TextGray)
                end
            end

            draw.SimpleText(L(category), "VoidUI.R28", sc(10), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        panel.DoClick = function ()
            self:SelectCategory(category)
        end

        rowPanel:AddRow(panel, 33)
    end


    local settingsContainer = self:Add("Panel")
    settingsContainer:Dock(FILL)
    
    local settingTitle = settingsContainer:Add("Panel")

    settingTitle.category = "None"

    settingTitle:Dock(TOP)
    settingTitle.Paint = function (self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)

        draw.SimpleText(string.upper(self.category), "VoidUI.R34", w/2, h/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local settingsContent = settingsContainer:Add("Panel")
    settingsContent:Dock(FILL)
    settingsContent:SDockPadding(20, 15, 20, 15)
    settingsContent.Paint = function (self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)
    end

    local contentRow = settingsContent:Add("VoidUI.RowPanel")
    contentRow:Dock(FILL)
    contentRow:SetSpacing(20)

    function settingsContent:AddEntry(config, id)
        local panel = contentRow:Add("VoidCases.ConfigEntry")
        panel:SetText(L(config.name), L(config.description))
        panel:CreateInput(config, id)

        contentRow:AddRow(panel, 55)
    end


    function selectionPanel:SelectCategory(cat)
        self.selectedCategory = cat
        settingTitle.category = L(cat)

        contentRow:Clear()

        if (self.selectedPanel) then
            self.selectedPanel:Remove()
            self.selectedPanel = nil
        end

        local configPanel = VoidCases.IGConfigPanels[cat]
        if (configPanel) then
            local panel = settingsContent:Add(configPanel)
            panel:Dock(FILL)
            panel:SetVisible(true)

            self.selectedPanel = panel
            this.ccPanels[configPanel] = panel
        else
            for id, config in SortedPairsByMemberValue(VoidCases.IGConfig, "sortOrder") do
                if (config.category == cat) then
                    settingsContent:AddEntry(config, id)
                end
            end
        end
    end

    for category, value in SortedPairsByValue(VoidCases.IGConfigCategories) do
        selectionPanel:AddCategory(category)

        if (category == "general") then
            selectionPanel:SelectCategory(category)
        end
    end


    self.selectionPanel = selectionPanel
    self.settingsContainer = settingsContainer
    self.settingTitle = settingTitle
    self.settingsContent = settingsContent
end

function PANEL:PerformLayout(w, h)
    self:SDockPadding(35, 35, 35, 35, self)
    
    self.selectionPanel:SSetWide(200, self)
    self.settingsContainer:MarginLeft(12, self)
    self.settingTitle:SSetTall(35, self)
    self.settingsContent:MarginTop(10, self)
end


vgui.Register("VoidCases.Options", PANEL, "VoidUI.PanelContent")

-- Config entry

local PANEL = {}

function PANEL:Init()
    self.title = "Config title"
    self.desc = "Config description goes here"
end

function PANEL:SetText(title, desc)
    self.title = title
    self.desc = desc
end

function PANEL:CreateInput(config, id)

    local type = config.type

    if (type == "string" or type == "number") then
        self.input = self:Add("VoidUI.TextInput")
        self.input:SetNumeric(type == "number")
        self.input:SetLight()

        function self.input.entry:OnFocusChanged(gained)
            if (!gained) then
                VoidCases.UpdateConfig(id, self:GetValue())
            end
        end

        local val = VoidCases.Config[id]
        if (val) then
            self.input:SetValue(val)
        end
    end

    if (type == "timevalue") then
        self.input = self:Add("VoidUI.TextInput")
        self.input:SetNumeric(true)
        self.input:SetLight()

        local values = {}

        function self.input.entry:OnFocusChanged(gained)
            if (!gained) then
                values[1] = self:GetValue()
                VoidCases.UpdateConfig(id, values)
            end
        end

        self.input2 = self:Add("VoidUI.TextInput")
        self.input2:SetNumeric(true)
        self.input2:SetLight()

        function self.input2.entry:OnFocusChanged(gained)
            if (!gained) then
                values[2] = self:GetValue()
                VoidCases.UpdateConfig(id, values)
            end
        end

        local val = VoidCases.Config[id]
        if (val) then
            values = val
            self.input:SetValue(val[1])
            self.input2:SetValue(val[2])
        end
    end

    if (type == "keybind") then
        self.input = self:Add("VoidUI.KeybindButton")
        self.input:SetLight()

        function self.input:OnSelect(key)
            -- We will store the key as a string because storing enums as numbers is not a good idea
            local str = key and input.GetKeyName(key) or nil
            VoidCases.UpdateConfig(id, str)
        end

        local val = VoidCases.Config[id]
        if (val) then
            local keycode = input.GetKeyCode(val)
            self.input:Select(keycode)
        end
    end

    if (type == "dropdown_multi") then
        -- todo: fix
        local selected = VoidCases.Config[id]

        self.input = self:Add("VoidUI.SelectorButton")
		self.input.text = L"clickToAdd"

		self.input.DoClick = function ()
			local selector = vgui.Create("VoidUI.ItemSelect")
			selector:SetParent(self)
			selector:SetMultipleChoice(true)

			if (self.input.multiSelection) then
				selector.choices = self.input.multiSelection
			end

			local jobTbl = {}

			for id, t in pairs(config.ddOptions) do
				jobTbl[id] = t
			end

			selector:InitItems(jobTbl, function (tbl, selTbl)
				self.input:Select(tbl, selTbl)
                selected = selTbl
			end)
		end
    end

    if (type == "bool") then
        self.input = self:Add("VoidUI.Switch")
        self:SDockMargin(50, 0, 50, 0)
        local currentVal = VoidCases.Config[id]
        self.input:SetChecked(currentVal)

        function self.input:OnChange(val)
            VoidCases.UpdateConfig(id, val)
        end
    end

    if (type == "dropdown") then
        self.input = self:Add("VoidUI.Dropdown")
        self.input:SetLight()
        local val = VoidCases.Config[id]

        for k, option in ipairs(config.ddOptions) do
            self.input:AddChoice(option)
            if (val == option) then
                self.input:ChooseOptionID(k)
            end
        end
        
        function self.input:OnSelect(index, val)
            VoidCases.UpdateConfig(id, val)
        end
    end

    self.input:Dock(RIGHT)
    self.input:MarginTops(7)
    self.input:MarginRight(10)
    self.input:SSetWide(230)

    if (self.input2) then
        self.input:SSetWide(75)
        self.input2:Dock(RIGHT)
        self.input2:SSetWide(75)
        self.input2:MarginTops(7)
        self.input2:MarginRight(10)
    end

    if (type == "bool") then
        self.input:Dock(RIGHT)
        self.input:SSetWide(90)
        self.input:MarginRight(148)
    end

end

function PANEL:Paint(w, h)
    draw.SimpleText(self.title, "VoidUI.B28", 0, 0, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    local descFont = "VoidUI.R24"
    surface.SetFont(descFont)
    draw.SimpleText(self.desc, descFont, 0, h, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

vgui.Register("VoidCases.ConfigEntry", PANEL, "Panel")


