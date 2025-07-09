local custom_for_all_tabs = CreateConVar( "wire_tool_menu_custom_menu_for_all_tabs", 0, {FCVAR_ARCHIVE} ) -- Wiremod Support

local updateToolMenu = function()
    if !gProtect.config.HideToolsInSpawnMenu then return end
    
    local lp = LocalPlayer()

    if !IsValid(lp) or !gProtect or !gProtect.LoadedModules or !gProtect.LoadedModules["toolgunsettings"] then return end

    local perms = gProtect.LoadedModules["toolgunsettings"]
    local usergroup = lp:GetUserGroup()
    local groupToolsRestrictions = perms["groupToolRestrictions"][usergroup]
    
    local wiremodCustomTabs = custom_for_all_tabs:GetBool()
    
    local toolMenu = g_SpawnMenu:GetToolMenu()
    local toolsTab = toolMenu.ToolPanels[1]
    local tabCanvas = toolsTab.List:GetChildren()[1]
    local wireTabCanvas = wiremodCustomTabs and tabCanvas:GetChildren()[1]:GetChildren()[4]

    for _, tab in ipairs((wireTabCanvas or tabCanvas):GetChildren()) do
        local visibleTabs = 0
        local wireTab = wiremodCustomTabs and tab:GetChildren()[3]

        if wireTab then tab = wireTab end

        for _, tool in ipairs(tab:GetChildren()) do
            if !tool.Name then continue end

            local blockedByGroups = groupToolsRestrictions and groupToolsRestrictions and groupToolsRestrictions.list and (groupToolsRestrictions.list[tool.Name] == (groupToolsRestrictions.isBlacklist or false))
            local isBlocked = (perms["restrictTools"][tool.Name] and !perms["bypassGroups"][usergroup]) or blockedByGroups

            tool:SetVisible(!isBlocked)

            if !isBlocked then
                visibleTabs = visibleTabs + 1
            end
        end

        if !wireTab then
            tab:SetVisible(visibleTabs > 0)
        else
            wireTab:GetParent():SetVisible(visibleTabs > 0)
            wireTab:InvalidateLayout(true)
        end

        tab:InvalidateLayout(true)
    end

    tabCanvas:InvalidateLayout(true)
end

hook.Add("gP:ConfigUpdated", "gP:FilterTools", function(moduleName)
    if moduleName == "toolgunsettings" then
        updateToolMenu()
    end
end)

hook.Add("OnSpawnMenuOpen", "gP:FilterTools", function()
    timer.Simple(0, function() updateToolMenu() end)
end)