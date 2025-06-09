local Reward = {}

Reward.Name = "OnyxStore Item"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	local creditstore = onyx.creditstore
	local itemTable = creditstore.items[key]
	if !itemTable then return end
	local itemTypeData = creditstore.types[itemTable.type]
	if !itemTypeData then return end
	local data = itemTypeData.generateItemData and itemTypeData.generateItemData(itemTable) or {}

	creditstore:AddPlayerItem(ply, key, data)
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key, parent)
	local creditstore = onyx.creditstore
	local itemTable = creditstore.items[key]
	if !itemTable then return end

	local mW, mH = parent:GetWide(), parent:GetTall()
    local itemPanel = vgui.Create( "DPanel" , parent )
    itemPanel:SetPos( mW*0.15, mH*0.15+1 )
	itemPanel:SetSize( mW*0.70, mH*0.70 )
    itemPanel:SetMouseInputEnabled(false)
    itemPanel.Paint = function(self, w, h)
       	if self.icon then
	        self.icon:Draw(0, 0, w, h)
	    end
    end

    local model = itemTable.model
    if (model) then
        if (onyx.creditstore:GetOptionValue('cheap_icon_mode')) then
            itemPanel.modelContainer = itemPanel:Add('Panel')
            itemPanel.modelContainer:Dock(FILL)
            itemPanel.modelContainer:SetMouseInputEnabled(false)
            itemPanel.modelContainer.PerformLayout = function(panel, w, h)
                local size = math.min(w, h) * .75
                local radius = size * .5
                local child = panel:GetChild(0)

                if (IsValid(child)) then
                    child:SetSize(size, size)
                    child:Center()
                end

                panel.radius = radius
                panel.mask = onyx.CalculateArc(w * .5, h * .5, 0, 360, radius, 24)
            end
            itemPanel.modelContainer.Paint = function(panel, w, h)
                local child = panel:GetChild(0)
                local radius = panel.radius
                if (IsValid(child)) then
                    if (radius) then
                        onyx.DrawCircle(w * .5, h * .5, radius, colorPrimary)
                    end

                    onyx.DrawWithPolyMask(panel.mask, function()
                        child:PaintManual()
                    end)

                    if (radius) then
                        onyx.DrawOutlinedCircle(w * .5, h * .5, radius, 1, color_white)
                    end
                end
            end

            itemPanel.model2d = itemPanel.modelContainer:Add('SpawnIcon')
            itemPanel.model2d:SetModel(model)
            itemPanel.model2d:SetPaintedManually(true)
        else
            itemPanel.dmodel = itemPanel:Add('DModelPanel')
            itemPanel.dmodel:Dock(FILL)
            itemPanel.dmodel:SetMouseInputEnabled(false)
            itemPanel.dmodel:SetModel(model)

            if (itemTable.type:find('vehicle')) then
                itemPanel.dmodel:SetCamPos(Vector(0, 200, -15))
                itemPanel.dmodel.LayoutEntity = function(panel, ent)
                    ent:SetAngles(Angle(0, 25, -15))
                end
            else
                local ent = itemPanel.dmodel.Entity
                if (IsValid(ent)) then
                	local typeData = onyx.creditstore.types[itemTable.type]
                    if (typeData.setupModelPanel) then
                        typeData.setupModelPanel(itemPanel.dmodel, itemTable)
                    else
                        local min, max = ent:GetRenderBounds()
                        local center = (min + max) / 2
                        local distance = 0

                        for _, key in ipairs({'x', 'y', 'z'}) do
                            distance = math.max(distance, max[key])
                        end

                        itemPanel.dmodel:SetLookAt(center)
                        itemPanel.dmodel:SetFOV(distance + 15)
                        itemPanel.dmodel.LayoutEntity = function() end
                    end
                end
            end
        end
    elseif (itemTable.icon) then
        itemPanel.icon = onyx.wimg.Simple(itemTable.icon, '')
    end

	return itemPanel
end

Reward.DrawKey = "Unique Name"

Reward.GetKey = function(name)
	local key
	local creditstore = onyx.creditstore
	key = creditstore.items[name] and name or false
	return key
end

Reward.LangPhrase = "OnyxStore_Item_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use a unique name for the item. It can be differentiated from the display name."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте унікальне ім'я предмета. Воно може відрізнятись від імені для відображення."
ADRLang.ru[Reward.LangPhrase] = "Используйте уникальное имя предмета. Оно может отличать от имени для отображения."
ADRLang.fr[Reward.LangPhrase] = "Utilisez un nom unique pour l'élément. Il peut être différencié du nom d'affichage."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie einen eindeutigen Namen für den Artikel. Er kann vom Anzeigenamen unterschieden werden."
ADRLang.pl[Reward.LangPhrase] = "Użyj unikalnej nazwy dla elementu. Można ją odróżnić od nazwy wyświetlanej."
ADRLang.tr[Reward.LangPhrase] = "Öğe için benzersiz bir ad kullanın. Görünen addan ayırt edilebilir."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice un nombre único para el elemento. Puede diferenciarse del nombre para mostrar."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !onyx then return false end
	return true
end


ADRewards.CreateReward(Reward)