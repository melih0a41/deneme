-- sh_rules_config.lua dosyasını dahil et
include("gelismis_kurallar/sh_rules_config.lua")

---------------------------------------------------------------------------
-- FONT TANIMLAMALARI
---------------------------------------------------------------------------
surface.CreateFont("Rules.Title", { font = "Tahoma", size = 22, weight = 600, antialias = true })
surface.CreateFont("Rules.Category", { font = "Tahoma", size = 15, weight = 500, antialias = true })
surface.CreateFont("Rules.Text", { font = "Tahoma", size = 15, weight = 400, antialias = true })
surface.CreateFont("Rules.Button", { font = "Tahoma", size = 14, weight = 600, antialias = true })
surface.CreateFont("Rules.DeleteButton", { font = "Tahoma", size = 11, weight = 700, antialias = true })
---------------------------------------------------------------------------

local mainFrame -- Paneli tekrar açmamak için referans

-- Network Mesajları
net.Receive("Rules_SendToClient", function()
    local rulesData = net.ReadTable()
    if IsValid(mainFrame) then
        mainFrame:UpdateRules(rulesData)
    end
end)

net.Receive("Rules_OpenMenu", function()
    if IsValid(mainFrame) then mainFrame:Close() end
    CreateRulesMenu()
end)


function CreateRulesMenu()
    -- Yetki Kontrolü
    local bIsAdmin = false
    if LocalPlayer and LocalPlayer() and LocalPlayer():IsValid() then
        local steamID = LocalPlayer():SteamID()
        local steamID64 = LocalPlayer():SteamID64()
        bIsAdmin = RULES_CONFIG.AdminSteamIDs[steamID] or RULES_CONFIG.AdminSteamIDs[steamID64]
    end

    -- Ana Pencere
    mainFrame = vgui.Create("DFrame")
    mainFrame:SetSize(800, 500)
    mainFrame:SetTitle("")
    mainFrame:Center()
    mainFrame:MakePopup()
    mainFrame:ShowCloseButton(true) -- Kapatma butonu aktif
    mainFrame:SetDraggable(true)
    mainFrame:SetSizable(false) -- Yeniden boyutlandırmayı ve ilgili butonları kapat

    mainFrame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(30, 35, 40, 250))
        surface.SetDrawColor(Color(20, 22, 25, 200))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    -- Başlık Etiketi
    local titleLabel = vgui.Create("DLabel", mainFrame)
    titleLabel:SetText(RULES_CONFIG.Title)
    titleLabel:SetFont("Rules.Title")
    titleLabel:SetTextColor(Color(240, 240, 240))
    titleLabel:Dock(TOP)
    titleLabel:SetTall(40)
    titleLabel:SetContentAlignment(5)

    -- Sol Panel (Kategoriler için)
    local leftPanel = vgui.Create("DPanel", mainFrame)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(200)
    leftPanel:DockMargin(15, 0, 10, 15)
    leftPanel.Paint = function(s,w,h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 28, 32, 220))
    end
    
    local categoryScroll = vgui.Create("DScrollPanel", leftPanel)
    categoryScroll:Dock(FILL)

    -- Sağ Panel (Kurallar için)
    local rulesPanel = vgui.Create("DScrollPanel", mainFrame)
    rulesPanel:Dock(FILL)
    rulesPanel:DockMargin(0, 0, 15, 15)
    
    local categoryButtons = {} -- Kategori butonlarını saklamak için

    -- Kategori seçildiğinde çalışacak fonksiyon
    local function SelectCategory(categoryName, clickedButton)
        rulesPanel:Clear()
        for _, btn in pairs(categoryButtons) do btn.selected = false end -- Tüm seçimleri kaldır
        clickedButton.selected = true -- Sadece tıklananı seç

        local rules = mainFrame.RulesData[categoryName]
        if not rules then return end

        for i, ruleText in ipairs(rules) do
            local ruleContainer = vgui.Create("DPanel", rulesPanel)
            ruleContainer:Dock(TOP)
            ruleContainer:DockMargin(10, 0, 0, 4)
            ruleContainer:SetPaintBackground(false)

            local label = vgui.Create("DLabel", ruleContainer)
            label:SetText(i .. ". " .. ruleText)
            label:SetFont("Rules.Text")
            label:SetColor(Color(220, 220, 220))
            label:SetWrap(true)
            label:Dock(FILL)
            
            if bIsAdmin then
                local deleteBtn = vgui.Create("DButton", ruleContainer)
                deleteBtn:SetText("SİL")
                deleteBtn:SetFont("Rules.DeleteButton")
                deleteBtn:SetSize(40, 18)
                deleteBtn:Dock(RIGHT)
                deleteBtn:DockMargin(5, 0, 0, 0)
                deleteBtn.DoClick = function()
                    Derma_Query("Bu kuralı silmek istediğinizden emin misiniz?", "Onay", "Evet", function()
                        net.Start("Rules_Admin_DeleteRule")
                        net.WriteString(categoryName)
                        net.WriteUInt(i, 32)
                        net.SendToServer()
                    end, "Hayır")
                end
            end
            ruleContainer:SizeToContents()
            -- HATA DÜZELTMESİ: 'Invalidate' metodu 'InvalidateLayout' olarak düzeltildi.
            ruleContainer:InvalidateLayout(true)
        end
    end

    -- Kuralları ve kategorileri güncelleyen fonksiyon
    function mainFrame:UpdateRules(rulesData)
        self.RulesData = rulesData
        categoryScroll:Clear()
        categoryButtons = {}
        
        local sortedCategories = {}
        for cat, _ in pairs(rulesData) do table.insert(sortedCategories, cat) end
        table.sort(sortedCategories)

        for _, categoryName in ipairs(sortedCategories) do
            local catButton = vgui.Create("DButton", categoryScroll)
            catButton:SetText(categoryName)
            catButton:SetFont("Rules.Category")
            catButton:SetTextColor(Color(180, 185, 190))
            catButton:Dock(TOP)
            catButton:DockMargin(5, 5, 5, 0)
            catButton:SetTall(30)
            catButton.selected = false

            catButton.Paint = function(s, w, h)
                local bgColor = s.selected and Color(60, 110, 200, 255) or (s:IsHovered() and Color(55, 60, 65, 255) or Color(44, 48, 52, 255))
                draw.RoundedBox(4, 0, 0, w, h, bgColor)
            end

            catButton.DoClick = function(s)
                SelectCategory(categoryName, s)
            end
            categoryButtons[categoryName] = catButton
        end
    end

    -- Admin Butonları
    if bIsAdmin then
        local bottomPanel = vgui.Create("DPanel", mainFrame)
        bottomPanel:Dock(BOTTOM)
        bottomPanel:SetHeight(45)
        bottomPanel.Paint = function(s,w,h) end

        local function CreateAdminButton(parent, text)
            local btn = vgui.Create("DButton", parent)
            btn:SetText(text)
            btn:SetFont("Rules.Button")
            return btn
        end

        local addCategoryBtn = CreateAdminButton(bottomPanel, "Yeni Kategori Ekle")
        local deleteCategoryBtn = CreateAdminButton(bottomPanel, "Seçili Kategoriyi Sil")
        local addRuleBtn = CreateAdminButton(bottomPanel, "Seçili Kategoriye Kural Ekle")

        bottomPanel.PerformLayout = function(s, w, h)
            local buttonTable = {addCategoryBtn, deleteCategoryBtn, addRuleBtn}
            local buttonCount = #buttonTable
            local spacing = 10
            local totalSpacing = spacing * (buttonCount - 1)
            local buttonWidth = (w - totalSpacing - 20) / buttonCount

            local x = 10
            for i, btn in ipairs(buttonTable) do
                btn:SetPos(x, (h - 25) / 2)
                btn:SetSize(buttonWidth, 25)
                x = x + buttonWidth + spacing
            end
        end

        addCategoryBtn.DoClick = function()
            Derma_StringRequest("Yeni Kategori", "Lütfen yeni kategori adını girin:", "", function(text)
                if text and text:Trim() ~= "" then
                    net.Start("Rules_Admin_AddCategory")
                    net.WriteString(text:Trim())
                    net.SendToServer()
                end
            end)
        end

        deleteCategoryBtn.DoClick = function()
            local selectedCategoryName
            for name, btn in pairs(categoryButtons) do if btn.selected then selectedCategoryName = name break end end
            
            if not selectedCategoryName then
                notification.AddLegacy("Lütfen önce silmek istediğiniz kategoriyi seçin!", NOTIFY_ERROR, 5)
                surface.PlaySound("buttons/button10.wav")
                return
            end

            Derma_Query("'" .. selectedCategoryName .. "' kategorisini ve içindeki TÜM kuralları kalıcı olarak silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz!", "Kategori Silme Onayı", "Evet, Kalıcı Olarak Sil", function()
                net.Start("Rules_Admin_DeleteCategory")
                net.WriteString(selectedCategoryName)
                net.SendToServer()
            end, "Hayır, İptal Et")
        end

        addRuleBtn.DoClick = function()
            local selectedCategoryName
            for name, btn in pairs(categoryButtons) do if btn.selected then selectedCategoryName = name break end end

            if not selectedCategoryName then
                notification.AddLegacy("Lütfen önce kural eklemek istediğiniz kategoriyi seçin!", NOTIFY_ERROR, 5)
                surface.PlaySound("buttons/button10.wav")
                return
            end
            
            Derma_StringRequest("'"..selectedCategoryName.."' için Kural Ekle", "Lütfen eklenecek kuralı yazın:", "", function(text)
                if text and text:Trim() ~= "" then
                    net.Start("Rules_Admin_AddRule")
                    net.WriteString(selectedCategoryName)
                    net.WriteString(text:Trim())
                    net.SendToServer()
                end
            end)
        end
    end

    -- Sunucudan kuralları iste
    net.Start("Rules_Request")
    net.SendToServer()
end