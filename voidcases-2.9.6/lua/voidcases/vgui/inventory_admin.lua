local L = VoidCases.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SetTitle(L("inventories"):upper())

    local selectionPanel = self:Add("Panel")
    selectionPanel:Dock(FILL)

    local inventoryPanel = self:Add("VoidCases.Inventory")
    inventoryPanel:Dock(FILL)
    inventoryPanel:SetVisible(false)

    self.inventoryPanel = inventoryPanel
    self.selectionPanel = selectionPanel

    local container = selectionPanel:Add("Panel")
    container:Dock(FILL)
    container:MarginSides(45)
    container:MarginTops(5)

    local searchContainer = container:Add("VoidUI.BackgroundPanel")
    searchContainer:Dock(TOP)
    searchContainer:SSetTall(55)
    searchContainer:SDockPadding(14,10,14,10)

    local searchPanel = searchContainer:Add("VoidUI.Search")
    searchPanel:Dock(FILL)

    local playerCard = container:Add("VoidUI.BackgroundPanel")
    playerCard:Dock(FILL)
    playerCard:MarginTop(15)
    playerCard:MarginBottom(25)

    local playerGrid = playerCard:Add("VoidUI.Grid")
    playerGrid:Dock(FILL)
    playerGrid:InvalidateParent(true)

    playerGrid:SetColumns(4)
    playerGrid:SetHorizontalMargin(sc(20))
    playerGrid:SetVerticalMargin(sc(10))

    local localPly = LocalPlayer()

    local function loadPlayers(searchStr)

        playerGrid:Clear()

        for k, v in pairs(player.GetHumans()) do

            if (searchStr and !v:Nick():lower():find(searchStr:lower())) then return end

            local itemPlayer = vgui.Create("DButton")
            itemPlayer:SSetTall(60)
            itemPlayer:SetText("")

            itemPlayer.Paint = function (self, w, h)
                local color = !self:IsHovered() and VoidUI.Colors.BackgroundTransparent or VoidUI.Colors.TextGray
                draw.RoundedBox(8, 0, 0, w, h, color)

                local teamColor = team.GetColor(v:Team())
                local teamName = team.GetName(v:Team())

                draw.SimpleText(v:Nick(), "VoidUI.R24", 65, h/2+4, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                draw.SimpleText(teamName, "VoidUI.R20", 65, h/2+2, teamColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            itemPlayer.Think = function ()
                if (!IsValid(v)) then
                    loadPlayers()
                end
            end

            itemPlayer.DoClick = function ()
                net.Start("VoidCases_RequestAdminInventory")
                    net.WriteString(v:SteamID64())
                net.SendToServer()
            end

            itemPlayer.avatar = itemPlayer:Add("Panel")
            itemPlayer.avatar:SetSize(45, 45)
            itemPlayer.avatar:SetPos(7, 7)
            itemPlayer.avatar:SetZPos(9999)

            itemPlayer.avatar.avatar = itemPlayer.avatar:Add("AvatarImage")
            itemPlayer.avatar.avatar:Dock(FILL)
            itemPlayer.avatar.avatar:SetPaintedManually(true)
            itemPlayer.avatar.avatar:SetPlayer(v)
        
            function itemPlayer.avatar:Paint(w, h)
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

            playerGrid:AddCell(itemPlayer)

        end

    end

    searchPanel.OnSearch = function (s, str)
        loadPlayers(str)
    end

    loadPlayers()
end

vgui.Register("VoidCases.InventoryAdmin", PANEL, "VoidUI.PanelContent")