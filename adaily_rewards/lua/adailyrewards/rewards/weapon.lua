local Reward = {}

Reward.Name = "Temporary Weapon"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	ply:Give(key)
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 2 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key)
	local model = key
	local weptbl = weapons.Get( key )
	if weptbl then
		model = weptbl.WorldModel
	end
	return model
end

Reward.DrawKey = "Weapon Class"

Reward.GetKey = function(name)
	local key = false
	local weptbl = weapons.Get( name )
	if weptbl then key = name end
	return key
end

Reward.LangPhrase = "TemporaryWeapon_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use the weapon class. You can get it from the Q Menu."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте клас зброї. Ви можете взяти його в Q Menu."
ADRLang.ru[Reward.LangPhrase] = "Используйте класс оружия. Вы можете взять его в Q Menu."
ADRLang.fr[Reward.LangPhrase] = "Utilisez la classe d'armes. Vous pouvez l'obtenir dans le menu Q."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie die Waffenklasse. Du kannst sie über das Q-Menü erhalten."
ADRLang.pl[Reward.LangPhrase] = "Użyj klasy broni. Można ją pobrać z menu Q."
ADRLang.tr[Reward.LangPhrase] = "Silah sınıfını kullanın. Q Menüsünden alabilirsiniz."
ADRLang["es-ES"][Reward.LangPhrase] = "Usa la clase de arma. Puedes obtenerla en el menú Q."
/*-------------------------------------------------------------------------*/
end



ADRewards.CreateReward(Reward)