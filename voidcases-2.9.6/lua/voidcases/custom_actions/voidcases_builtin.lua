local sc = VoidUI.Scale
local L = VoidCases.Lang.GetPhrase

VoidCases.Print("Loaded VoidCases built-in actions!")

local function createWeaponCustomPanel(panel, parent, setValue, getItemObj, isSkin, fAdditionalRefresh)
    local wepSelector = panel:Add("VoidUI.SelectorButton")

    wepSelector.DoClick = function ()
        local selector = vgui.Create("VoidUI.ItemSelect")
        selector:SetParent(parent)

        local weps = weapons.GetList()
        local wepTbl = {}
        for id, wep in ipairs(weps) do
            if (engine.ActiveGamemode() != "terrortown" and !wep.Spawnable) then continue end
            local isEmpty = wep.PrintName == nil or wep.PrintName == ""
            wepTbl[wep.ClassName] = isEmpty and wep.ClassName or wep.PrintName
        end

        selector.SearchFunc = function (item, str, name)
            return name:lower():find(str:lower(), 1, true) or item:find(str:lower(), 1, true)
        end

        selector:InitItems(wepTbl, function (id, v)
            wepSelector:Select(id, v)
            setValue(id)

            if (fAdditionalRefresh) then
                fAdditionalRefresh(getItemObj)
            end

            local wep = weapons.Get(id)
            if (wep) then
                local model = wep.WorldModel or wep.WM
                local printName = wep.PrintName

                local concat = isSkin and " (Skin)" or ""
                parent.nameEntry.input.entry:SetValue(printName .. concat)

                if (model and parent.iconChooseEntry.input:GetSelectedID() == 2) then
                    parent.iconValueEntry.input.entry:SetValue(model)
                end
            end
        end)
    end

    return wepSelector
end

-- Actions below!

local tblInventories = {
    ["Xenin Inventory"] = {
        giveItem = function (ply, class, dropClass, model, amount)
            local inventory = ply:XeninInventory()
            inventory:Add(class, dropClass, model, amount)
        end,
        isInstalled = function () return XeninInventory end
    },
    ["ItemStore"] = {
        giveItem = function (ply, class, dropClass, model, amount)
            local tbl = { Model = model, Class = class, Amount = amount }
            local item = itemstore.Item(dropClass, tbl)
            ply.Inventory:AddItem(item)
        end,
        isInstalled = function () return itemstore end
    },
    ["IDInventory"] = {
        giveItem = function (ply, class, dropClass, model, amount)
            ply:GiveItem(class, model, amount)
        end,
        isInstalled = function () return IDInv end
    }
}

VoidCases.CreateAction("weapon", function (ply, value, itemObj, amount)
    if (itemObj.info.inventory and itemObj.info.inventory != "No" and itemObj.info.inventory != "no") then
        local inventory = itemObj.info.inventory
        local inv = tblInventories[inventory]
        local wep = weapons.Get(value)
        if (!wep) then
            VoidCases.PrintError("Could not give weapon " .. value .. " to " .. ply:Nick() .. ", invalid class name!")
            return
        end

        local wepModel = wep.WorldModel or wep.WM
        inv.giveItem(ply, value, "spawned_weapon", wepModel, amount)
    else
        ply:Give(value)
    end
end, {
    varType = "custom",
    title = "weapon",
    supportCount = true,
    setActive = function (panel, actionValue)
        local wep = weapons.Get(actionValue)
        if (wep) then
            panel:Select(actionValue, wep.PrintName)
        end
    end,
    customPanel = function (panel, parent, setValue, itemObj, fAdditionalRefresh)
        return createWeaponCustomPanel(panel, parent, setValue, itemObj, false)
    end,
    additionalPanel = function (panel, parent, itemObj, updateItemObj, itemP)
        local inventoryEntry = vgui.Create("Panel")
        inventoryEntry:SetWide(ScrW() * 0.124)
        inventoryEntry:SetTall(sc(75))
        
        inventoryEntry.Paint = function (self, w, h)
            draw.SimpleText(string.upper(L"put_to_inventory"), "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        inventoryEntry.input = inventoryEntry:Add("VoidUI.Dropdown")
        inventoryEntry.input:Dock(TOP)
        inventoryEntry.input:DockMargin(0, sc(30), 0, 0)
        inventoryEntry.input:SetTall(sc(45))

        inventoryEntry.input:AddChoice("No")
        inventoryEntry.input:ChooseOptionID(1)

        local i = 2
        for k, v in pairs(tblInventories) do
            if (!v.isInstalled()) then continue end
            inventoryEntry.input:AddChoice(k)

            if (k == itemObj().info.inventory) then
                inventoryEntry.input:ChooseOptionID(i)
            end

            i = i + 1
        end

        function inventoryEntry.input:OnSelect(index, val)
            updateItemObj(function (itemObj)
                itemObj.info.inventory = val
                return itemObj
            end)
        end

        panel:AddCell(inventoryEntry)
    end,
})


VoidCases.CreateAction("entity", function (ply, value, itemObj, amount)
    if (itemObj.info.inventory and itemObj.info.inventory != "No" and itemObj.info.inventory != "no") then
        local inventory = itemObj.info.inventory
        local inv = tblInventories[inventory]
        local dropClass = VoidLib.IsNilOrEmpty(itemObj.info.inventoryDropClass) and "base_entity" or itemObj.info.inventoryDropClass

        inv.giveItem(ply, value, dropClass, itemObj.info.icon, amount)
    else
        local ent = ents.Create(value)
        ent:SetPos(ply:GetPos() + ply:GetForward() * 35)
        ent:Spawn()
    end
end, {
    varType = "custom",
    title = "entity_class",
    supportCount = true,
    setActive = function (panel, actionValue)
        panel.entry:SetValue(actionValue)
    end,
    customPanel = function (panel, parent, setValue, itemObj)
        local entityPanel = panel:Add("VoidUI.TextInput")

        function entityPanel.entry:OnValueChange(val)
            setValue(val)

            // Easy entity adding (darkrp)
            local foundEntity = false
            if (DarkRP) then
                local ent = nil 
                for k, v in pairs(DarkRPEntities) do
                    if (v.ent == val) then
                        ent = v
                    end
                end

                if (ent) then
                    local printName = ent.name
                    local model = ent.model

                    if (printName and parent.nameEntry.input.entry:GetValue() == "") then
                        parent.nameEntry.input.entry:SetValue(printName)
                    end

                    if (model and parent.iconChooseEntry.input:GetSelectedID() == 2 and parent.iconValueEntry.input.entry:GetValue() == "") then
                        parent.iconValueEntry.input.entry:SetValue(model)
                    end
                    foundEntity = true
                end
            end

            // Alternative method from the spawn menu
            if (!foundEntity) then
                local spawnableEnts = list.Get("SpawnableEntities")
                if (spawnableEnts) then
                    for k, v in pairs(spawnableEnts) do
                        if (v.ClassName == val) then
                            -- Get the print name atleast
                            local printName = v.PrintName

                            if (printName and parent.nameEntry.input.entry:GetValue() == "") then
                                parent.nameEntry.input.entry:SetValue(printName)
                            end
                        end
                    end
                end
            end

        end

        return entityPanel
    end,
    additionalPanel = function (panel, parent, itemObj, updateItemObj, itemP)
        local inventoryEntry = vgui.Create("Panel")
        inventoryEntry:SetWide(ScrW() * 0.124)
        inventoryEntry:SetTall(sc(75))
        
        inventoryEntry.Paint = function (self, w, h)
            draw.SimpleText(string.upper(L"put_to_inventory"), "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        inventoryEntry.input = inventoryEntry:Add("VoidUI.Dropdown")
        inventoryEntry.input:Dock(TOP)
        inventoryEntry.input:DockMargin(0, sc(30), 0, 0)
        inventoryEntry.input:SetTall(sc(45))

        inventoryEntry.input:AddChoice("No")
        inventoryEntry.input:ChooseOptionID(1)

        local i = 2
        for k, v in pairs(tblInventories) do
            if (!v.isInstalled()) then continue end
            inventoryEntry.input:AddChoice(k)

            if (k == itemObj().info.inventory) then
                inventoryEntry.input:ChooseOptionID(i)
            end

            i = i + 1
        end

        function inventoryEntry.input:OnSelect(index, val)
            updateItemObj(function (itemObj)
                itemObj.info.inventory = val
                return itemObj
            end)
        end

        panel:AddCell(inventoryEntry)

        local dropClassEntry = vgui.Create("Panel")
        dropClassEntry:SetWide(ScrW() * 0.124)
        dropClassEntry:SetTall(sc(75))
        
        dropClassEntry.Paint = function (self, w, h)
            draw.SimpleText("DROP CLASS (ITEM TYPE)", "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        dropClassEntry.input = dropClassEntry:Add("VoidUI.TextInput")
        dropClassEntry.input:Dock(TOP)
        dropClassEntry.input:DockMargin(0, sc(30), 0, 0)
        dropClassEntry.input:SetTall(sc(45))

        function dropClassEntry.input:OnValueChange(val)
            updateItemObj(function(itemObj)
                itemObj.info.inventoryDropClass = val
                return itemObj
            end)
        end

        panel:AddCell(dropClassEntry)
    end,
})

if (DarkRP) then
    VoidCases.CreateAction("money", function (ply, value)
        ply:addMoney(value)
    end, {
        varType = "number",
        title = "money"
    })
end

if (PS) then
    VoidCases.CreateAction("Pointshop 1 Money", function (ply, value)
        ply:PS_GivePoints(tonumber(value))
    end, {
        varType = "number",
        title = "money"
    })

    VoidCases.CreateAction("pointshop_item", function (ply, value)
        ply:PS_GiveItem(value)
    end, {
        varType = "string",
        title = "pointshop_class"
    })
end

if (Pointshop2) then
    VoidCases.CreateAction("Pointshop 2 (Standard) Money", function (ply, value)
        ply:PS2_AddStandardPoints(tonumber(value))  -- idk why but it sometimes returns it as a string
    end, {
        varType = "number",
        title = "money"
    })

    VoidCases.CreateAction("Pointshop 2 (Premium) Money", function (ply, value)
        ply:PS2_AddPremiumPoints(tonumber(value))
    end, {
        varType = "number",
        title = "money"
    })

    VoidCases.CreateAction("pointshop2_item", function (ply, value)
        local itemClass = Pointshop2.GetItemClassByPrintName(value)
        if (!itemClass) then
            VoidLib.Notify(ply, L"error_occured", L"does_not_exist", Color(206, 83, 83), 4)
            return
        end
        return ply:PS2_EasyAddItem(itemClass.className)
    end, {
        varType = "string",
        title = "pointshop_name"
    })
end

if (SH_POINTSHOP) then
    VoidCases.CreateAction("pointshopsh_item", function (ply, value)
        ply:SH_AddItem(value)
    end, {
        varType = "string",
        title = "pointshop_class"
    })
end
                
if (BRICKSCREDITSTORE) then
    VoidCases.CreateAction("BricksCredits", function (ply, value)
        ply:AddBRCS_Credits(value)
    end, {
        varType = "number",
        title = "money"
    })
end

VoidCases.CreateAction("lua_code", function (ply, value)
    value = string.Replace(value, "%sid64", ply:SteamID64())
    value = string.Replace(value, "%sid", ply:SteamID())
    value = string.Replace(value, "%nick", ply:Nick())
    value = string.Replace(value, "%ply", "player.GetBySteamID64('" .. ply:SteamID64() .. "')")

    RunString(value)
end, {
    varType = "string",
    fontSize = "VoidUI.R18",
    title = "lua_code",
})

VoidCases.CreateAction("concommand", function (ply, value)
    value = string.Replace(value, "%sid64", ply:SteamID64())
    value = string.Replace(value, "%sid", ply:SteamID())
    value = string.Replace(value, "%nick", ply:Nick())

    game.ConsoleCommand(value .. "\n")
end, {
    varType = "string",
    fontSize = "VoidUI.R18",
    title = "concommand_type"
})

if (SH_EASYSKINS) then
    VoidCases.CreateAction("weapon_skin", function (ply, value, item)
        if (item.info.skinsForAll) then
            local skinInfo = SH_EASYSKINS.GetSkin(item.info.weaponSkin)
            value = skinInfo.weaponTbl
        else
            value = {value}
        end
        SV_EASYSKINS.GiveSkinToPlayer( ply:SteamID64(), item.info.weaponSkin, value )
    end, {
        varType = "custom",
        title = "weapon",
        setActive = function (panel, actionValue)
            local wep = weapons.Get(actionValue)
            if (wep) then
                panel:Select(actionValue, wep.PrintName)
            end
        end,
        additionalPanel = function (panel, parent, itemObj, updateItemObj, itemP)

            local skinChooseEntry = vgui.Create("Panel")
            local skinTypeChooseEntry = vgui.Create("Panel")

            skinChooseEntry:SetWide(ScrW() * 0.124)
            skinChooseEntry:SetTall(sc(75))
            
            skinChooseEntry.Paint = function (self, w, h)
                draw.SimpleText(string.upper(L"weapon_skin"), "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            skinChooseEntry.input = skinChooseEntry:Add("VoidUI.Dropdown")
            skinChooseEntry.input:Dock(TOP)
            skinChooseEntry.input:DockMargin(0, sc(30), 0, 0)
            skinChooseEntry.input:SetTall(sc(45))

            local skinValues = {}

            skinChooseEntry.refreshSkins = function (getItemObj)
                local itemObj = getItemObj()

                table.Empty(skinValues)
                skinChooseEntry.input:Clear()
                if (!SH_EASYSKINS) then return end

                if (itemObj.info.skinsForAll) then
                    for k, v in pairs(SH_EASYSKINS.GetSkins()) do
                        local index = skinChooseEntry.input:AddChoice(v.dispName)
                        skinValues[index] = v.id

                        if (v.id == tonumber(itemObj.info.weaponSkin)) then
                            skinChooseEntry.input:ChooseOptionID(index)
                        end
                    end
                else
                    for k, v in pairs(SH_EASYSKINS.GetSkins()) do
                        if (table.HasValue(v.weaponTbl, itemObj.info.actionValue)) then
                            local index = skinChooseEntry.input:AddChoice(v.dispName)
                            skinValues[index] = v.id

                            if (v.id == tonumber(itemObj.info.weaponSkin)) then
                                skinChooseEntry.input:ChooseOptionID(index)
                            end
                        end
                    end
                end
            end

            skinChooseEntry.refreshSkins(itemObj)

            function skinChooseEntry.input:OnSelect(index, val)

                local easySkin = SH_EASYSKINS.GetSkin(skinValues[index])
                if (!easySkin) then
                    VoidLib.Notify(L"error_occured", "Skin doesn't exist!", VoidUI.Colors.Red, 3)
                    return
                end
                
                SH_EASYSKINS.ApplySkinToModel(itemP.icon.Entity, easySkin.material.path)
                updateItemObj(function (itemObj)
                    itemObj.info.weaponSkin = skinValues[index]
                    return itemObj
                end)
            end

            panel:AddCell(skinChooseEntry)

            --skin_type

            skinTypeChooseEntry:SetWide(ScrW() * 0.124)
            skinTypeChooseEntry:SetTall(sc(75))
            
            skinTypeChooseEntry.Paint = function (self, w, h)
                draw.SimpleText(string.upper(L"skin_type"), "VoidUI.B24", 0, sc(15), VoidUI.Colors.GrayTransparent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            skinTypeChooseEntry.input = skinTypeChooseEntry:Add("VoidUI.Dropdown")
            skinTypeChooseEntry.input:Dock(TOP)
            skinTypeChooseEntry.input:DockMargin(0, sc(30), 0, 0)
            skinTypeChooseEntry.input:SetTall(sc(45))

            skinTypeChooseEntry.input:AddChoice("Yes")
            skinTypeChooseEntry.input:AddChoice("No")

            skinTypeChooseEntry.input:ChooseOptionID(2)

            function skinTypeChooseEntry.input:OnSelect(index, val)
                if (index == 2) then
                    parent.typeChooseValueEntry:SetVisible(true)
                    updateItemObj(function (itemObj)
                        itemObj.info.skinsForAll = false
                        return itemObj
                    end)
                else
                    parent.typeChooseValueEntry:SetVisible(false)
                    updateItemObj(function (itemObj)
                        itemObj.info.skinsForAll = true
                        return itemObj
                    end)
                end
                skinChooseEntry.refreshSkins(itemObj)
            end

            panel:AddCell(skinTypeChooseEntry)

            return skinChooseEntry.refreshSkins
        end,
        customPanel = function (panel, parent, setValue, itemObj, fRefresh)
            return createWeaponCustomPanel(panel, parent, setValue, itemObj, true, fRefresh)
        end
    })
end

if wOS and wOS.INV then
    VoidCases.CreateAction("wOS Item", function (ply, value)
        wOS:HandleItemPickup(ply, value)
    end, {
        varType = "string",
        title = "Item Name"
    })
end
