local Task = {}

Task.Name = "HitComplete"

Task.Description = "Desc_HitComplete"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "onHitCompleted", "ADR_TaskHitComplete", function( hitman, target, customer )
		ADRewards.GiveTaskVal(hitman, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Hit Complete"
ADRLang.uk[Task.Name] = "Замовне Вбивство"
ADRLang.ru[Task.Name] = "Заказное Убийство"
ADRLang.fr[Task.Name] = "Meurtre à Louer"
ADRLang.de[Task.Name] = "Auftragsmord"
ADRLang.pl[Task.Name] = "Morderstwo do Wynajęcia"
ADRLang.tr[Task.Name] = "Kiralık Katil"
ADRLang["es-ES"][Task.Name] = "Asesinato por Encargo"

ADRLang.en[Task.Description] = "Successfully complete the assassination order"
ADRLang.uk[Task.Description] = "Успішно виконайте замовне вбивство"
ADRLang.ru[Task.Description] = "Успешно завершите заказ на убийство"
ADRLang.fr[Task.Description] = "Réussir l'ordre d'assassinat"
ADRLang.de[Task.Description] = "Erfolgreicher Abschluss des Attentatsauftrags"
ADRLang.pl[Task.Description] = "Pomyślne wykonanie zlecenia zabójstwa"
ADRLang.tr[Task.Description] = "Suikast emrini başarıyla tamamlayın"
ADRLang["es-ES"][Task.Description] = "Completa con éxito la orden de asesinato"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)