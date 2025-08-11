-- Bu kodu lua/autorun/client/hud_debug_all.lua olarak kaydedin
if CLIENT then
    local debugActive = false
    local allPanels = {}
    local mouseX, mouseY = 0, 0
    
    concommand.Add("debug_all", function()
        if not LocalPlayer():IsSuperAdmin() then 
            print("Bu komut sadece superadminler içindir!")
            return 
        end
        
        debugActive = not debugActive
        
        if debugActive then
            gui.EnableScreenClicker(true)
            print("=== KOMPLE DEBUG MODU AKTİF ===")
            print("Mouse'u hareket ettirerek tüm elementleri görün")
            print("Tekrar 'debug_all' yazarak kapatın")
            
            -- Mouse takibi
            hook.Add("Think", "DebugMouseTracker", function()
                mouseX, mouseY = gui.MousePos()
            end)
            
            -- Tüm panelleri sürekli tara
            hook.Add("DrawOverlay", "DebugAllElements", function()
                allPanels = {}
                
                -- Tüm panelleri recursive tara
                local function ScanPanel(panel, depth)
                    if not IsValid(panel) then return end
                    
                    local x, y = panel:LocalToScreen(0, 0)
                    local w, h = panel:GetSize()
                    
                    table.insert(allPanels, {
                        panel = panel,
                        x = x,
                        y = y,
                        w = w,
                        h = h,
                        depth = depth,
                        class = panel:GetClassName(),
                        name = panel:GetName(),
                        visible = panel:IsVisible(),
                        alpha = panel:GetAlpha(),
                        zpos = panel:GetZPos()
                    })
                    
                    for _, child in ipairs(panel:GetChildren()) do
                        ScanPanel(child, depth + 1)
                    end
                end
                
                ScanPanel(vgui.GetWorldPanel(), 0)
                
                -- Tüm panelleri çiz
                for _, data in ipairs(allPanels) do
                    if data.visible and data.w > 0 and data.h > 0 then
                        -- Panel sınırlarını çiz
                        local isHovered = mouseX >= data.x and mouseX <= data.x + data.w and 
                                        mouseY >= data.y and mouseY <= data.y + data.h
                        
                        if isHovered then
                            -- Hover edilenler kırmızı
                            surface.SetDrawColor(255, 0, 0, 150)
                            surface.DrawRect(data.x, data.y, data.w, data.h)
                            surface.SetDrawColor(255, 255, 0, 255)
                        else
                            -- Diğerleri yeşil çerçeve
                            surface.SetDrawColor(0, 255, 0, 50)
                        end
                        
                        surface.DrawOutlinedRect(data.x, data.y, data.w, data.h)
                        
                        -- Küçük bilgi etiketi
                        if data.w > 50 and data.h > 20 then
                            draw.SimpleText(
                                data.class,
                                "Default",
                                data.x + 2,
                                data.y + 2,
                                isHovered and Color(255, 255, 0) or Color(0, 255, 0),
                                TEXT_ALIGN_LEFT
                            )
                        end
                    end
                end
                
                -- Sol tarafta detaylı bilgi paneli
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawRect(10, 100, 600, ScrH() - 200)
                
                local yPos = 110
                draw.SimpleText("=== TÜM GÖRÜNÜR PANELLER ===", "DermaDefaultBold", 20, yPos, Color(255, 255, 0))
                yPos = yPos + 20
                
                draw.SimpleText(string.format("Mouse Pozisyonu: %d, %d", mouseX, mouseY), "DermaDefault", 20, yPos, Color(0, 255, 255))
                yPos = yPos + 20
                
                draw.SimpleText("Toplam Panel Sayısı: " .. #allPanels, "DermaDefault", 20, yPos, Color(255, 255, 255))
                yPos = yPos + 30
                
                -- Mouse altındaki panelleri listele
                local hoveredPanels = {}
                for _, data in ipairs(allPanels) do
                    if mouseX >= data.x and mouseX <= data.x + data.w and 
                       mouseY >= data.y and mouseY <= data.y + data.h and data.visible then
                        table.insert(hoveredPanels, data)
                    end
                end
                
                -- Z-Pos'a göre sırala (üsttekiler önce)
                table.sort(hoveredPanels, function(a, b) return a.zpos > b.zpos end)
                
                draw.SimpleText("=== MOUSE ALTINDAKİ PANELLER (Z-POS SIRASINA GÖRE) ===", "DermaDefaultBold", 20, yPos, Color(255, 0, 0))
                yPos = yPos + 20
                
                for i, data in ipairs(hoveredPanels) do
                    local text = string.format("%d. [%s] %s - Pos:(%d,%d) Size:(%dx%d) Z:%d Alpha:%d", 
                        i, 
                        data.class, 
                        data.name or "NoName",
                        data.x, data.y,
                        data.w, data.h,
                        data.zpos,
                        data.alpha
                    )
                    
                    draw.SimpleText(text, "DermaDefault", 30, yPos, Color(255, 200, 200))
                    yPos = yPos + 18
                    
                    if yPos > ScrH() - 100 then break end
                end
                
                -- Sağ üst köşedeki panelleri özel olarak listele
                yPos = yPos + 30
                if yPos < ScrH() - 200 then
                    draw.SimpleText("=== SAĞ ÜST KÖŞEDEKİ PANELLER ===", "DermaDefaultBold", 20, yPos, Color(255, 255, 0))
                    yPos = yPos + 20
                    
                    for _, data in ipairs(allPanels) do
                        if data.x > ScrW() * 0.6 and data.y < ScrH() * 0.4 and data.visible then
                            local text = string.format("[%s] %s - Pos:(%d,%d) Size:(%dx%d)", 
                                data.class, 
                                data.name or "NoName",
                                data.x, data.y,
                                data.w, data.h
                            )
                            
                            draw.SimpleText(text, "DermaDefault", 30, yPos, Color(200, 255, 200))
                            yPos = yPos + 18
                            
                            if yPos > ScrH() - 50 then break end
                        end
                    end
                end
                
                -- Kullanım talimatları
                draw.SimpleText("ESC tuşuna basarak mouse'u kullanın", "DermaDefaultBold", ScrW() - 300, 20, Color(255, 255, 0), TEXT_ALIGN_RIGHT)
                draw.SimpleText("Konsola 'debug_all' yazarak debug modunu kapatın", "DermaDefaultBold", ScrW() - 300, 40, Color(255, 255, 0), TEXT_ALIGN_RIGHT)
            end)
            
            -- Konsola detayları yazdır
            hook.Add("PlayerButtonDown", "DebugPrintDetails", function(ply, button)
                if button == MOUSE_LEFT and debugActive then
                    print("\n=== MOUSE TIKLAMASI - PANEL DETAYLARI ===")
                    print("Tıklama Pozisyonu:", mouseX, mouseY)
                    
                    for _, data in ipairs(allPanels) do
                        if mouseX >= data.x and mouseX <= data.x + data.w and 
                           mouseY >= data.y and mouseY <= data.y + data.h and data.visible then
                            print(string.format("\n[%s] %s", data.class, data.name or "NoName"))
                            print("  Pozisyon:", data.x, data.y)
                            print("  Boyut:", data.w, "x", data.h)
                            print("  Z-Pos:", data.zpos)
                            print("  Alpha:", data.alpha)
                            print("  Depth:", data.depth)
                            
                            if IsValid(data.panel) and data.panel.GetParent then
                                local parent = data.panel:GetParent()
                                if IsValid(parent) then
                                    print("  Parent:", parent:GetClassName())
                                end
                            end
                        end
                    end
                    print("=================================\n")
                end
            end)
            
        else
            -- Debug modunu kapat
            gui.EnableScreenClicker(false)
            hook.Remove("Think", "DebugMouseTracker")
            hook.Remove("DrawOverlay", "DebugAllElements")
            hook.Remove("PlayerButtonDown", "DebugPrintDetails")
            print("=== DEBUG MODU KAPALI ===")
        end
    end)
    
    -- Hızlı panel gizleme komutu
    concommand.Add("hide_panel", function(ply, cmd, args)
        if not LocalPlayer():IsSuperAdmin() then return end
        
        local className = args[1]
        if not className then
            print("Kullanım: hide_panel <panel_class_name>")
            return
        end
        
        local hidden = 0
        local function HideByClass(panel)
            if not IsValid(panel) then return end
            
            if panel:GetClassName() == className then
                panel:SetVisible(false)
                hidden = hidden + 1
            end
            
            for _, child in ipairs(panel:GetChildren()) do
                HideByClass(child)
            end
        end
        
        HideByClass(vgui.GetWorldPanel())
        print(hidden .. " adet " .. className .. " paneli gizlendi.")
    end)
end