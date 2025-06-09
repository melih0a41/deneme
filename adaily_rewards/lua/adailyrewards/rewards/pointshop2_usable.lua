local Reward = {}

Reward.Name = "PS2 Usable"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	if !key then return end
	local itemClass = Pointshop2.GetItemClassByPrintName( key )
    ply:PS2_EasyAddItem( itemClass.className )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 4 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

local c_bg = Color(51,51,51)
Reward.DrawFunc = function(key, parent)
	if !key then return end
	local itemClass = Pointshop2.GetItemClassByPrintName( key )
	local pW, pH = parent:GetSize()
	local imageMat = itemClass.material or itemClass.class.material
	imageMat = Material(imageMat, "mips smooth")

	local itemPanel = vgui.Create( "DPanel", parent )
	itemPanel:SetPos( pW*0.1+1, pH*0.1+1 )
	itemPanel:SetSize( pW*0.8, pH*0.8 )
	itemPanel.Paint = function(self, w, h)
		ADRewards.draw_RoundedTextureBox(8, 0, 0, w, h, c_bg)

		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial(imageMat)
		surface.DrawTexturedRect(w*0.15+1, h*0.15+1, w*0.70, h*0.70)
	end

	return itemPanel
end

Reward.DrawKey = "Item Name"

Reward.GetKey = function(name)
	local key = false
	local getItem = Pointshop2.GetItemClassByPrintName( name ) or false
	if getItem then
		if getItem.super == KInventory.Items.base_hat or getItem.super == KInventory.Items.base_trail or getItem.static:GetPointshopLowendIconControl() != "DPointshopMaterialIcon" then return false end
		key = name
	end
	return key
end

Reward.LangPhrase = "PS2_Usable_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the item. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву предмету. Назва повинна бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя предмета. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de l'article. Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Artikels. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy elementu. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Öğenin adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre del artículo. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if not Pointshop2 or (Pointshop2 and ashop) then return false end
	return true
end

ADRewards.CreateReward(Reward)