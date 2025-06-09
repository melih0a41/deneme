local Reward = {}

Reward.Name = "Helix Item"

Reward.MaxAmount = 1

Reward.CanTaskReward = true

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	if !ply:GetCharacter():GetInventory():Add(key, 1) then
		ix.item.Spawn( key, ply:GetPos()+ply:GetForward()*30+Vector(0,0,10) )
	end
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 2 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key)
	local itemTbl = ix.item.list[key]
	if !itemTbl then return end
	return itemTbl.model
end

Reward.DrawKey = "Unique ID"

Reward.GetKey = function(name)
	local key = ix.item.list[name] and name or false
	return key
end

Reward.LangPhrase = "HelixItem_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use a unique item identifier."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте унікальний ідентифікатор предмета."
ADRLang.ru[Reward.LangPhrase] = "Используйте уникальный идентификатор предмета."
ADRLang.fr[Reward.LangPhrase] = "Utiliser un identifiant unique."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie einen eindeutigen Artikelbezeichner."
ADRLang.pl[Reward.LangPhrase] = "Użyj unikalnego identyfikatora elementu."
ADRLang.tr[Reward.LangPhrase] = "Benzersiz bir öğe tanımlayıcısı kullanın."
ADRLang["es-ES"][Reward.LangPhrase] = "Utilizar un identificador único de artículo."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if ix then return true end
	return false
end


ADRewards.CreateReward(Reward)