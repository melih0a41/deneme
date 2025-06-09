local Reward = {}

Reward.Name = "PS2 Trails"

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
Reward.DrawType = 1 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key, parent)
	if !key then return end
	local itemClass = Pointshop2.GetItemClassByPrintName( key )

	local mat = Material(itemClass.material, "mips smooth")

	return mat
end

Reward.DrawKey = "Trail Name"

Reward.GetKey = function(name)
	local key = false
	local getItem = Pointshop2.GetItemClassByPrintName( name ) or false
	if getItem then
		if getItem.super != KInventory.Items.base_trail then return false end
		key = name
	end
	return key
end

Reward.LangPhrase = "PS2_Trails_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the name of the trail. The name must be unique."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте назву хвоста. Назва має бути унікальною."
ADRLang.ru[Reward.LangPhrase] = "Используйте имя хвоста. Имя должно быть уникальным."
ADRLang.fr[Reward.LangPhrase] = "Utilisez le nom de la queue. Le nom doit être unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie den Namen des Schwanzes. Der Name muss eindeutig sein."
ADRLang.pl[Reward.LangPhrase] = "Użyj nazwy ogona. Nazwa musi być unikalna."
ADRLang.tr[Reward.LangPhrase] = "Kuyruğun adını kullanın. İsim benzersiz olmalıdır."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilice el nombre de la cola. El nombre debe ser único."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if not Pointshop2 or (Pointshop2 and ashop) then return false end
	return true
end

ADRewards.CreateReward(Reward)