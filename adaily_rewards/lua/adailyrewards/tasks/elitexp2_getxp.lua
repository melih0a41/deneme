local Task = {}

Task.Name = "EliteGetXP"

Task.Description = "Desc_EliteGetXP"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {300, 600, 900}

Task.AddHook = function()
	hook.Add( "EliteOnCheckXP", "ADR_TaskEliteGetXP", function( ply, xp )
		ADRewards.GiveTaskVal(ply, Task.Name, xp)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Get XP"
ADRLang.uk[Task.Name] = "Отримати XP"
ADRLang.ru[Task.Name] = "Получить XP"
ADRLang.fr[Task.Name] = "Obtenir XP"
ADRLang.de[Task.Name] = "XP erhalten"
ADRLang.pl[Task.Name] = "Zdobądź XP"
ADRLang.tr[Task.Name] = "XP alın"
ADRLang["es-ES"][Task.Name] = "Obtener XP"

ADRLang.en[Task.Description] = "Get the amount of XP you need"
ADRLang.uk[Task.Description] = "Отримайте необхідну кількість XP за гру на сервері"
ADRLang.ru[Task.Description] = "Получите необходимое количество XP за игру на сервере"
ADRLang.fr[Task.Description] = "Obtenez la quantité de XP dont vous avez besoin"
ADRLang.de[Task.Description] = "Erhalten Sie die benötigte Anzahl von XP"
ADRLang.pl[Task.Description] = "Zdobądź wymaganą liczbę XP"
ADRLang.tr[Task.Description] = "İhtiyacınız olan XP miktarını alın"
ADRLang["es-ES"][Task.Description] = "Consigue la cantidad de XP que necesitas"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if EliteXP then return true end
	return false
end

ADRewards.CreateTask(Task)