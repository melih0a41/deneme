local APP = {}

APP.name = "Calls"
APP.icon = "akulla/aphone/app_calls.png"

local clr_blue = Color(93,207,202)
local redb = Color(255, 0, 0)

function APP:NotifyCount()
    return aphone.Clientside.GetSetting("callmissed", 0)
end

function APP:Open(main, main_x, main_y, screenmode)
    local clr_green = aphone:Color("Black2")
    local clr_black3 = aphone:Color("Black3")
    local clr_black1 = aphone:Color("Black1")
    local clr_white120 = aphone:Color("Text_White120")
    local font_bold = aphone:GetFont("Roboto45_700")
    local font_mediumheader = aphone:GetFont("MediumHeader")
    local sBox = aphone.GUI.ScaledSize(48)

    local tbl = {}

    function main:Paint(w, h)
        surface.SetDrawColor(clr_black3)
        surface.DrawRect(0,0,w,h)
    end

    local local_player = LocalPlayer()
    local already_ids = {}
    local already_num = {}

    local search_bg = vgui.Create("DPanel", main)
    search_bg:Dock(TOP)
    search_bg:DockMargin(main_x * 0.04, main_y * 0.05, main_x * 0.04, 0)
    search_bg:SetTall(main_y * 0.07)

    function search_bg:Paint(w, h)
        draw.RoundedBox(h / 2, 0, 0, w, h, clr_black1)
    end

    local search_icon = vgui.Create("DLabel", search_bg)
    search_icon:Dock(LEFT)
    search_icon:DockMargin(search_bg:GetTall() / 2, 0, 0, 0)
    search_icon:SetWide(search_bg:GetTall())
    search_icon:SetFont(aphone:GetFont("SVG_30"))
    search_icon:SetText("g")
    search_icon:SetTextColor(clr_white120)

    local search_entry = vgui.Create("DLabel", search_bg)
    search_entry:Dock(FILL)
    search_entry:DockMargin(0, 0, search_bg:GetTall() / 2, 0)
    search_entry:SetFont(font_mediumheader)
    search_entry:SetText(aphone.L("Search"))
    search_entry:SetMouseInputEnabled(true)
    search_entry:Phone_AlphaHover()

    function search_entry:DoClick()
        self:Phone_AskTextEntry(aphone.L("Search") != self:GetText() and self:GetText() or "", 32)
    end

    function search_entry:textChange(txt)
        txt = string.lower(txt or "")

        for k, v in pairs(tbl) do
            if !string.StartWith(k, txt) and !v.on_closeanim then
                // Reset it
                v:SetAnimationEnabled(false)
                v:SetAnimationEnabled(true)

                v:AlphaTo(0, 0.25, 0)
                v:SizeTo(-1, 0, 0.25, 0, 0.5)
                v.on_closeanim = true
            elseif string.StartWith(k, txt) then
                // Reset it
                if v.on_closeanim then
                    v:SetAnimationEnabled(false)
                    v:SetAnimationEnabled(true)
                end

                v:SizeTo(-1, sBox, 0.25, 0, 0.5)
                v:AlphaTo(255, 0.25, 0)
                v.on_closeanim = false
            end
        end
    end

    local sFont = draw.GetFontHeight(aphone:GetFont("SVG_40"))
    local dial = vgui.Create("DLabel", main)
    dial:Dock(BOTTOM)
    dial:DockMargin(0, 0, 0, main_y*0.05)
    dial:SetFont(aphone:GetFont("SVG_40"))
    dial:SetText("5")
    dial:SetContentAlignment(5)
    dial:SetTall(sFont)
    dial:SetMouseInputEnabled(true)
    dial:Phone_AlphaHover()

    local b = true
    local switch = vgui.Create("DLabel", dial)
    switch:Dock(RIGHT)
    switch:DockMargin(0, 0, sFont, 0)
    switch:SetFont(aphone:GetFont("SVG_40"))
    switch:SetText("4")
    switch:SetContentAlignment(5)
    switch:SetWide(sFont)
    switch:SetMouseInputEnabled(true)
    switch:Phone_AlphaHover()

    if aphone.Clientside.GetSetting("callmissed", 0) > 0 then
        function switch:Paint(w, h)
            DisableClipping(true)
                draw.RoundedBox(8, w - 12, -4, 16, 16, redb)
            DisableClipping(false)
        end
    end

    local player_list = vgui.Create("DScrollPanel", main)
    player_list:Dock(FILL)
    player_list:DockMargin(0, main_y * 0.02, 0, 0)
    player_list:aphone_PaintScroll()

    local function genCallable()
        local plyList = player.GetHumans()
        plyList = player.GetAll()

        for k, v in ipairs(plyList) do
            local id = v:aphone_GetID()

            if local_player == v or (aphone.disable_showingUnknownPlayers and !aphone.Contacts.GetName(id)) then continue end
            already_ids[id] = v

            // Get last message, for date + text display
            local player_main = vgui.Create("DButton", player_list)
            player_main:Dock(TOP)
            player_main:SetTall(sBox)
            player_main:DockMargin(main_x*0.1, main_y * 0.0125, main_x*0.1, 0)
            player_main:SetPaintBackground(false)
            player_main:TDLib()
            player_main:SetText("")
            player_main:FadeHover(clr_green, nil, 8)
    
            tbl[string.lower(aphone.GetName(v))] = player_main
    
            function player_main:DoClick()
                net.Start("aphone_Phone")
                    net.WriteUInt(1, 4)
                    net.WriteEntity(v)
                net.SendToServer()
            end
    
            local player_avatar = vgui.Create("aphone_CircleAvatar", player_main)
            player_avatar:SetPlayer(v, 184)
            player_avatar:Dock(LEFT)
            player_avatar:SetWide(sBox)
            player_avatar.roundedValue = 8
            player_avatar:DockMargin(0, 0, 0, 0)

            surface.SetFont(font_mediumheader)
            local player_textname = vgui.Create("DLabel", player_main)
            player_textname:Dock(FILL)
            player_textname:DockMargin(main_x * 0.05, 0, 5, 0)
            player_textname:SetFont(font_mediumheader)
            player_textname:SetTextColor(aphone:Color("Text_White"))
            player_textname:SetText(aphone.GetName(v))
            player_textname:SetMouseInputEnabled(false)
        end
    
        for k, v in ipairs(plyList) do
            if local_player == v or !v:aphone_GetNumber() then continue end
            already_num[v:aphone_GetNumber()] = v
        end
    end

    local function genHistory()
        already_ids = {}
        for k, v in ipairs(aphone.Clientside.GetSetting("callhistory", {})) do
            // Get last message, for date + text display
            local a = draw.GetFontHeight(aphone:GetFont("SVG_30"))/2

            local player_main = vgui.Create("DPanel", player_list)
            player_main:Dock(TOP)
            player_main:SetTall(sBox*1.66)
            player_main:DockMargin(main_x*0.1, main_y * 0.0125, main_x*0.1, 0)
            player_main:DockPadding(a, a, a, a)
            player_main:SetPaintBackground(false)
            player_main:TDLib()
            player_main:SetText("")
            //player_main:FadeHover(clr_green, nil, 8)

            function player_main:Paint(w, h)
                surface.SetDrawColor(100, 100, 100, 125)
                surface.DrawLine(0, h-1, w, h-1)
            end
    
            tbl[string.lower(aphone.GetName(v))] = player_main
    
            local player_avatar = vgui.Create("DLabel", player_main)
            player_avatar:Dock(LEFT)
            player_avatar:SetWide(sBox)
            player_avatar:SetFont(aphone:GetFont("SVG_30"))
            player_avatar:SetTextColor(aphone:Color("Text_White120"))
            player_avatar:DockMargin(0, 0, main_y * 0.005, 0)

            if v.p then
                player_avatar:SetText("4")

                if !v.is_caller then
                    player_avatar:SetTextColor(aphone:Color("mat_blackred"))
                end
            else
                player_avatar:SetText("o")
            end
    
            surface.SetFont(font_mediumheader)
            local player_textname = vgui.Create("DLabel", player_main)
            player_textname:Dock(TOP)
            player_textname:SetFont(aphone:GetFont("Small"))
            player_textname:SetTextColor(aphone:Color("Text_White"))
            player_textname:SetText(aphone.GetName(v))
            player_textname:SetMouseInputEnabled(false)
            player_textname:SetTall(player_main:GetTall()/2 - a)
            player_textname:SetContentAlignment(1)

            local player_time = vgui.Create("DLabel", player_main)
            player_time:Dock(TOP)
            player_time:SetFont(aphone:GetFont("Small"))
            player_time:SetTextColor(aphone:Color("Text_White"))
            player_time:SetText(aphone.FormatTimeStamp(os.time() - v.time))
            player_time:SetMouseInputEnabled(false)
            player_time:SetTall(player_main:GetTall()/2 - a)
            player_time:SetContentAlignment(7)
        end
    end

    function switch:DoClick()
        b = !b
        player_list:Clear()

        if !b then
            genCallable()
            switch:SetText("4")
            search_bg:SetTall(main_y * 0.07)
        else
            genHistory()
            switch:SetText("o")
            search_bg:SetTall(0)

            switch.Paint = function() end
            aphone.Clientside.SaveSetting("callmissed", 0)
        end

        main:aphone_RemoveCursor()
    end
    switch:DoClick()

    function dial:DoClick()
        local number = 0

        local dial_bigpanel = vgui.Create("DButton", main)
        dial_bigpanel:SetSize(main_x, main_y)
        dial_bigpanel:SetPaintBackground(false)
        dial_bigpanel:SetText("")
        dial_bigpanel.open = CurTime()

        local dial_keys = vgui.Create("DPanel", dial_bigpanel)
        dial_keys:SetPos(0, main_y)
        dial_keys:SetSize(main_x, main_y*0.55)
        dial_keys:MoveTo(0, main_y - dial_keys:GetTall(), 0.5, 0, 0.2)

        function dial_bigpanel:DoClick()
            dial_bigpanel.closing = CurTime()
            dial_keys:MoveTo(0, main_y, 0.5, 0, 0.2, function()
                dial_bigpanel:Remove()
            end)
        end

        function dial_bigpanel:Paint(w, h)
            local ratio = !dial_bigpanel.closing and (CurTime() - dial_bigpanel.open)*3 or 1 - (CurTime() - dial_bigpanel.closing)*3

            if ratio > 1 then
                ratio = 1
            elseif ratio < 0 then
                ratio = 0
            end

            surface.SetDrawColor(0, 0, 0, 230 * ratio)
            surface.DrawRect(0, 0, w, h)
        end

        function dial_keys:Paint(w, h)
            draw.RoundedBoxEx(32, 0, 0, w, h, clr_blue, true, true, false, false)
            draw.RoundedBoxEx(32, 0, 10, w, h, clr_black1, true, true, false, false)
        end

        surface.SetFont(font_bold)

        local dial_number = vgui.Create("DLabel", dial_keys)
        dial_number:Dock(TOP)
        dial_number:SetText(aphone.FormatNumber("0"))
        dial_number:SetFont(font_bold)
        dial_number:SetContentAlignment(5)
        dial_number:DockMargin(0, main_y*0.03, 0, 0)
        dial_number:SetTextColor(clr_blue)
        dial_number:SetTall(select(2, surface.GetTextSize(aphone.FormatNumber("0"))))

        local lang_unknown = aphone.L("PlayerNotFound")

        local dial_name = vgui.Create("DLabel", dial_keys)
        dial_name:Dock(TOP)
        dial_name:SetText(lang_unknown)
        dial_name:SetFont(aphone:GetFont("Little_NoWeight"))
        dial_name:SetContentAlignment(5)
        dial_name:SetTextColor(clr_white120)
        dial_name:DockMargin(0, 0, 0, main_y*0.02)

        surface.SetFont(dial_name:GetFont())
        dial_name:SetTall(select(2, surface.GetTextSize(dial_name:GetText())))

        local dial_DIconLayout = vgui.Create("DIconLayout", dial_keys)
        dial_DIconLayout:Dock(TOP)
        dial_DIconLayout:DockMargin(main_x*0.2, 0, main_x*0.2, 0)
        dial_DIconLayout:SetTall(main_y*0.25)

        local button_call = vgui.Create("DLabel", dial_keys)
        button_call:Dock(FILL)
        button_call:SetText("o")
        button_call:SetFont(dial:GetFont())
        button_call:SetContentAlignment(5)
        button_call:Phone_AlphaHover()
        button_call:SetVisible(false)
        button_call:SetMouseInputEnabled(true)

        function button_call:DoClick()
            if !IsValid(already_num[dial_number:GetText()]) then return end

            net.Start("aphone_Phone")
                net.WriteUInt(1, 4)
                net.WriteEntity(already_num[dial_number:GetText()])
            net.SendToServer()

            dial_bigpanel:DoClick()
        end

        local roboto40 = aphone:GetFont("Roboto40")
        local pnl_0

        for i=9, 0, -1 do
            local ratio = (i != 0 and 3 or 1)

            local num = vgui.Create("DButton", dial_DIconLayout)
            num:SetSize(main_x*0.6 / ratio, main_y*0.25 / 3)
            num:SetText(i)
            num:SetPaintBackground(false)
            num:SetFont(roboto40)
            num:Phone_AlphaHover()

            function num:DoClick()
                local tempnumber = tonumber(tostring(number) .. i)

                if string.len(tempnumber) > aphone.digitscount then return end
                number = tempnumber
                dial_number:SetText(aphone.FormatNumber(tempnumber))

                if already_num[dial_number:GetText()] then
                    dial_name:SetText(aphone.GetName(already_num[dial_number:GetText()]))
                    button_call:SetVisible(true)
                else
                    dial_name:SetText(lang_unknown)
                    button_call:SetVisible(false)
                end
            end

            if i == 0 then pnl_0 = num end
        end

        local remove = vgui.Create("DButton", pnl_0)
        remove:SetSize(main_x*0.2, main_y*0.25 / 3)
        remove:SetText("<")
        remove:SetPaintBackground(false)
        remove:SetFont(roboto40)
        remove:Phone_AlphaHover()
        remove:Dock(RIGHT)

        function remove:DoClick()
            if tonumber(number) == 0 then return end
            local formatted = string.sub(tostring(number), 1, -2)
            formatted = (formatted != "" and formatted or "0")

            number = tonumber(formatted)
            dial_number:SetText(aphone.FormatNumber(formatted))

            if already_num[dial_number:GetText()] then
                dial_name:SetText(aphone.GetName(already_num[dial_number:GetText()]))
                button_call:SetVisible(true)
            else
                dial_name:SetText(lang_unknown)
                button_call:SetVisible(false)
            end
        end

        dial_bigpanel:aphone_RemoveCursor()
    end

    main:aphone_RemoveCursor()
end

function APP:OnClose()
    aphone.InsertNewMessage = nil
end

aphone.RegisterApp(APP)