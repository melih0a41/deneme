local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale

// Marketplace

VoidCases.MarketplacePreviewPanel = nil

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)

    self:SetTitle(L("marketplace"):upper())

    local searchCard = self:Add("VoidUI.BackgroundPanel")
    searchCard:Dock(TOP)
    searchCard:SSetTall(50)
    searchCard:MarginTop(5)
    searchCard:MarginSides(45)
    searchCard:DockPadding(30,8,10,8)

    local searchInput = searchCard:Add("VoidUI.Search")
    searchInput:Dock(LEFT)
    searchInput:SSetWide(260)

    searchInput.OnSearch = function (s, str)
        self.refreshItems(str)
    end

    local sortContainer = searchCard:Add("Panel")
    sortContainer:Dock(LEFT)
    sortContainer:SSetWide(340)
    sortContainer:MarginLeft(30)
    
    local rarityFilter = sortContainer:Add("VoidUI.Dropdown")
    rarityFilter:Dock(RIGHT)
    rarityFilter:SSetWide(160)
    rarityFilter:SetText("Rarity Filter")
    rarityFilter.color = VoidUI.Colors.BackgroundTransparent
    rarityFilter:SetFont("VoidUI.R24")

    rarityFilter:AddChoice(L"none")
    for rarityName, id in SortedPairsByValue(VoidCases.Rarities) do
        rarityFilter:AddChoice(rarityName)
    end

    rarityFilter.OnSelect = function (s, i, val)
        self.refreshItems(searchInput:GetValue())
    end

    local itemFilter = sortContainer:Add("VoidUI.Dropdown")
    itemFilter:Dock(LEFT)
    itemFilter:SSetWide(160)
    itemFilter:SetText("Item Filter")
    itemFilter.color = VoidUI.Colors.BackgroundTransparent
    itemFilter:SetFont("VoidUI.R24")
    
    itemFilter:AddChoice(L"none")
    itemFilter:AddChoice(L"cases")
    itemFilter:AddChoice(L"keys")
    itemFilter:AddChoice(L"weapons")
    itemFilter:AddChoice(L"skins")
    itemFilter:AddChoice(L"money")
    itemFilter:AddChoice(L"other")

    itemFilter.OnSelect = function (s, i, val)
        self.refreshItems(searchInput:GetValue())
    end

    local sellItem = searchCard:Add("VoidUI.Button")
    sellItem:Dock(RIGHT)
    sellItem:MarginRight(30)
    sellItem:SSetWide(145)
    sellItem:SetMedium()
    sellItem:SetText("+  " .. L"sell_item")

    sellItem.DoClick = function ()
        local panel = vgui.Create("VoidCases.MarketCreate")
        panel:MakePopup()

        panel:SetSize(600, 600)

        panel:Center()
        
        panel:SetParent(self)
        panel:DoModal()
    end

    self.sellItem = sellItem

    local itemContainer = self:Add("VoidUI.BackgroundPanel")
    itemContainer:Dock(FILL)
    itemContainer:SDockMargin(45, 15, 45, 30)

    local itemWrapper = itemContainer:Add("VoidUI.Grid")
    itemWrapper:Dock(FILL)
    itemWrapper:DockMargin(0, 0, 0, 0)

    itemWrapper:SetColumns(5)
    itemWrapper:SetHorizontalMargin(ScrW() * 0.0078)
    itemWrapper:SetVerticalMargin(20)

    self.refreshItems = function (str)

        itemWrapper:Clear()

        self.modelsToHide = {}

        local function checkItemPass(item)
            local rarityName = nil
            for k, v in pairs(VoidCases.Rarities) do
                if (v == tonumber(item.info.rarity)) then
                    rarityName = k
                end
            end

            if (str and (!item.name:lower():find(str:lower(), 1, true) and !rarityName:lower():find(str:lower(), 1, false)) ) then return false end
            if ((rarityFilter:GetSelected() and rarityFilter:GetSelected() != "" and rarityFilter:GetSelected() != L"none") and rarityFilter:GetSelected() != rarityName) then return false end
            
            if (itemFilter:GetSelected() and itemFilter:GetSelected() != "" and itemFilter:GetSelected() != L"none") then
                local currFilter = itemFilter:GetSelected()

                if (currFilter == L"weapons" and item.info.actionType != "weapon") then return false end
                if (currFilter == L"cases" and item.type != VoidCases.ItemTypes.Case) then return false end
                if (currFilter == L"keys" and item.type != VoidCases.ItemTypes.Key) then return false end
                if (currFilter == L"skins" and item.info.actionType != "weapon_skin") then return false end
                if (currFilter == L"money" and item.info.actionType != "money") then return false end

                if (currFilter == L"other" and (!item.info.actionType or (!item.info.actionType:find("pointshop") and item.info.actionType != "concommand"))) then return false end
            end

            return true
        end


        

        for _, listingTbl in pairs(VoidCases.Marketplace) do
            if (tonumber(listingTbl.amount) < 1) then continue end

            local item = VoidCases.Config.Items[tonumber(listingTbl.item)]
            if (!VoidCases.IsItemValid(item)) then continue end

            if (!checkItemPass(item)) then continue end

            local rarityColor = VoidCases.RarityColors[tonumber(item.info.rarity)]

            local itemPanel = vgui.Create("VoidCases.Item")
            itemPanel:SSetTall(230)
            itemPanel:SSetWide(230)
            itemPanel.isList = true
            itemPanel.marketMoney = listingTbl.price

            itemPanel:SetItem(item)

            itemPanel.statusX = 0
            itemPanel.statusY = sc(150)
            
            itemWrapper:AddCell(itemPanel, nil, sc(230))

            itemPanel.avatar = itemPanel:Add("Panel")
            itemPanel.avatar:SetSize(20, 20)
            itemPanel.avatar:SetPos(5, ScrH() * 0.037)
            itemPanel.avatar:SetZPos(9999)

            itemPanel.avatar.avatar = itemPanel.avatar:Add("AvatarImage")
            itemPanel.avatar.avatar:Dock(FILL)
            itemPanel.avatar.avatar:SetPaintedManually(true)
            itemPanel.avatar.avatar:SetSteamID(listingTbl.sid, 32)
        
            function itemPanel.avatar:Paint(w, h)
                render.ClearStencil()
                render.SetStencilEnable(true)

                render.SetStencilWriteMask(1)
                render.SetStencilTestMask(1)

                render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
                render.SetStencilPassOperation(STENCILOPERATION_ZERO)
                render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
                render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
                render.SetStencilReferenceValue(1)

                surface.SetDrawColor(0,0,0,1)
                draw.drawCircle(w/2, h/2, w/2, 2)

                render.SetStencilFailOperation(STENCILOPERATION_ZERO)
                render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
                render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
                render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
                render.SetStencilReferenceValue(1)

                self.avatar:PaintManual()

                render.SetStencilEnable(false)
                render.ClearStencil()
            end

            local plyNick = listingTbl.sid
            steamworks.RequestPlayerInfo(plyNick, function (res)
                plyNick = res
            end)

            local itemPanelB = itemPanel:Add("DButton")
            itemPanelB:Dock(FILL)
            itemPanelB:SetText("")
            itemPanelB.Paint = function (self, w, h) 
                if (self:IsHovered()) then
                    surface.SetFont("VoidUI.R16")
                    local nameSize = surface.GetTextSize(plyNick) + 35

                    draw.RoundedBox(8, 5, ScrH() * 0.035, nameSize, 22, rarityColor)
                    draw.SimpleText(plyNick, "VoidUI.R16", 30, ScrH() * 0.035+11, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
            itemPanelB:SetZPos(30)
            itemPanel.b = itemPanelB

            itemPanelB.DoClick = function ()
                -- Purchase item
                if (IsValid(VoidCases.MarketplacePreviewPanel)) then return end

                local panel = vgui.Create("VoidCases.ItemPurchase")
                panel:SetSize(ScrW() * 0.5448, ScrH() * 0.648)
                panel:Center()

                panel:SetParent(self)
                panel:InitItem(tonumber(listingTbl.item), item, true, listingTbl.amount, listingTbl.sid, listingTbl.price, listingTbl.listingid)

                VoidCases.MarketplacePreviewPanel = panel
            end
            
        end

    end

    self.refreshItems()
end

vgui.Register("VoidCases.Market", PANEL, "VoidUI.PanelContent")
