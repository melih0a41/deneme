local Task = {}

Task.Name = "GetArrested"

Task.Description = "Desc_GetArrested"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 3, 5}

Task.AddHook = function()
	hook.Add( "playerArrested", "ADR_TaskGetArrested", function( criminal, time, actor )
		ADRewards.GiveTaskVal(criminal, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Get Arrested"
ADRLang.uk[Task.Name] = "Потрапити під Арешт"
ADRLang.ru[Task.Name] = "Попасть под Арест"
ADRLang.fr[Task.Name] = "Se faire Arrêter"
ADRLang.de[Task.Name] = "Verhaftet Werden"
ADRLang.pl[Task.Name] = "Aresztowanie"
ADRLang.tr[Task.Name] = "Tutuklan"
ADRLang["es-ES"][Task.Name] = "Ser Detenido"

ADRLang.en[Task.Description] = "Be arrested for the crime you committed"
ADRLang.uk[Task.Description] = "Потрапте до в'язниці за своє правопорушення"
ADRLang.ru[Task.Description] = "Попадите в тюрьму за свое правонарушение"
ADRLang.fr[Task.Description] = "Être arrêté pour le délit que vous avez commis"
ADRLang.de[Task.Description] = "Für das von Ihnen begangene Verbrechen verhaftet werden"
ADRLang.pl[Task.Description] = "Być aresztowanym za popełnione przestępstwo"
ADRLang.tr[Task.Description] = "İşlediğiniz suçtan dolayı tutuklanmak"
ADRLang["es-ES"][Task.Description] = "Ser detenido por el delito cometido"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)