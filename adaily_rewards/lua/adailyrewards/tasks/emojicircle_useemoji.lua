local Task = {}

Task.Name = "UseEmoji"

Task.Description = "Desc_UseEmoji"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "EC_PlayerUseEmoji", "ADR_TaskUseEmoji", function( ply, ename )
		if EmojiCircle.Items[ename].Type != 1 then return end
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Use Emoji"
ADRLang.uk[Task.Name] = "Використайте Емодзі"
ADRLang.ru[Task.Name] = "Используйте Эмодзи"
ADRLang.fr[Task.Name] = "Utiliser les Emoji"
ADRLang.de[Task.Name] = "Emoji Verwenden"
ADRLang.pl[Task.Name] = "Używanie Emotikonów"
ADRLang.tr[Task.Name] = "Emoji Kullanın"
ADRLang["es-ES"][Task.Name] = "Utilizar Emoji"

ADRLang.en[Task.Description] = "Use any emoji from your kit"
ADRLang.uk[Task.Description] = "Використовуйте будь-який емодзі з вашого набору"
ADRLang.ru[Task.Description] = "Используйте любой эмодзи из вашего набора"
ADRLang.fr[Task.Description] = "Utilisez n'importe quel emoji de votre choix"
ADRLang.de[Task.Description] = "Verwenden Sie ein beliebiges Emoji aus Ihrem Set"
ADRLang.pl[Task.Description] = "Użyj dowolnego emoji ze swojego zestawu"
ADRLang.tr[Task.Description] = "Setinizdeki herhangi bir emojiyi kullanın"
ADRLang["es-ES"][Task.Description] = "Utiliza cualquier emoji de tu set"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if EmojiCircle then return true end
	return false
end

ADRewards.CreateTask(Task)