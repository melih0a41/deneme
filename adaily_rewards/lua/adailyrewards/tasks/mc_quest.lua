local Task = {}

Task.Name = "MacQuest"

Task.Description = "Desc_MacQuest"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1,2,3}

Task.AddHook = function()
	hook.Add( "MQS.OnTaskSuccess", "ADR_TaskMacQuest", function( ply, name_q, tbl_q )
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Complete quest"
ADRLang.uk[Task.Name] = "Завершіть завдання"
ADRLang.ru[Task.Name] = "Выполните задание"
ADRLang.fr[Task.Name] = "Terminer la quête"
ADRLang.de[Task.Name] = "Suche abschließen"
ADRLang.pl[Task.Name] = "Ukończ zadanie"
ADRLang.tr[Task.Name] = "Görevi tamamla"
ADRLang["es-ES"][Task.Name] = "Completa la misión"

ADRLang.en[Task.Description] = "Complete a new or active quest"
ADRLang.uk[Task.Description] = "Завершіть новий або активний квест"
ADRLang.ru[Task.Description] = "Выполните новый или активный квест"
ADRLang.fr[Task.Description] = "Terminer une nouvelle quête ou une quête active"
ADRLang.de[Task.Description] = "Schließe eine neue oder aktive Quest ab"
ADRLang.pl[Task.Description] = "Ukończenie nowego lub aktywnego zadania"
ADRLang.tr[Task.Description] = "Yeni veya aktif bir görevi tamamlayın"
ADRLang["es-ES"][Task.Description] = "Completa una misión nueva o activa"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if MQS then return true end
	return false
end

ADRewards.CreateTask(Task)