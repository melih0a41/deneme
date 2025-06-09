local Reward = {}

Reward.Name = "Emoji Circle"

Reward.MaxAmount = 1

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Reward.GiveReward = function(ply, amount, key)
	EmojiCircle.GiveEmoji(ply, key)
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
Reward.DrawType = 1 -- Types: 1 - image; 2 - spawnicon; 3 - model; 4 - custom;

Reward.DrawFunc = function(key)
	local mat = EmojiCircle.GetMaterial(key)
	return mat
end

Reward.DrawKey = "Unique Name"

Reward.GetKey = function(name)
	local key = EmojiCircle.Items[name] and name or false
	return key
end

Reward.LangPhrase = "EmojiCircle_KeyInfo"
ADRLang.en[Reward.LangPhrase] = "Use a unique emoji identifier from the config. For example: «tw_Gestures_HandHeart»."
ADRLang.uk[Reward.LangPhrase] = "Використовуйте унікальний ідентифікатор емодзі з конфіга. Наприклад: «tw_Gestures_HandHeart»"
ADRLang.ru[Reward.LangPhrase] = "Используйте уникальный идентификатор эмодзи из конфига. Например: «tw_Gestures_HandHeart»"
ADRLang.fr[Reward.LangPhrase] = "Utilisez un identifiant emoji unique provenant de la configuration. Par exemple : «tw_Gestures_HandHeart»."
ADRLang.de[Reward.LangPhrase] = "Verwenden Sie einen eindeutigen Emoji-Bezeichner aus der Konfiguration. Zum Beispiel: «tw_Gestures_HandHeart»."
ADRLang.pl[Reward.LangPhrase] = "Użyj unikalnego identyfikatora emoji z konfiguracji. Na przykład: «tw_Gestures_HandHeart»."
ADRLang.tr[Reward.LangPhrase] = "Yapılandırmadan benzersiz bir emoji tanımlayıcısı kullanın. Örneğin: «tw_Gestures_HandHeart»."
ADRLang["es-ES"][Reward.LangPhrase] = "Utiliza un identificador emoji único de la configuración. Por ejemplo: «tw_Gestures_HandHeart»."
/*-------------------------------------------------------------------------*/
end

Reward.CheckLoad = function()
	if !EmojiCircle then return false end
	return true
end


ADRewards.CreateReward(Reward)