local Task = {}

Task.Name = "UseGesture"

Task.Description = "Desc_UseGesture"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "EC_PlayerUseEmoji", "ADR_TaskUseGesture", function( ply, ename )
		if EmojiCircle.Items[ename].Type != 2 then return end
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Use Gesture"
ADRLang.uk[Task.Name] = "Використайте Жест"
ADRLang.ru[Task.Name] = "Используйте Жест"
ADRLang.fr[Task.Name] = "Utiliser le Geste"
ADRLang.de[Task.Name] = "Geste Verwenden"
ADRLang.pl[Task.Name] = "Użyj Gestu"
ADRLang.tr[Task.Name] = "Hareket Kullanın"
ADRLang["es-ES"][Task.Name] = "Utilizar el Gesto"

ADRLang.en[Task.Description] = "Use any gesture from your kit"
ADRLang.uk[Task.Description] = "Використовуйте будь-який жест з вашого набору"
ADRLang.ru[Task.Description] = "Используйте любой жест из вашего набора"
ADRLang.fr[Task.Description] = "Utilisez n'importe quel geste de votre kit"
ADRLang.de[Task.Description] = "Verwenden Sie eine beliebige Geste aus Ihrem Kit"
ADRLang.pl[Task.Description] = "Użyj dowolnego gestu z zestawu"
ADRLang.tr[Task.Description] = "Kitinizdeki herhangi bir hareketi kullanın"
ADRLang["es-ES"][Task.Description] = "Utiliza cualquier gesto de tu kit"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if EmojiCircle then return true end
	return false
end

ADRewards.CreateTask(Task)