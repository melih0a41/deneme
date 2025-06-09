local Task = {}

Task.Name = "Arrest"

Task.Description = "Desc_Arrest"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 3, 5}

Task.AddHook = function()
	hook.Add( "playerArrested", "ADR_TaskArrest", function( criminal, time, actor )
		ADRewards.GiveTaskVal(actor, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Arrest"
ADRLang.uk[Task.Name] = "Здійсніть Арешт"
ADRLang.ru[Task.Name] = "Совершите Арест"
ADRLang.fr[Task.Name] = "Faire une Arrestation"
ADRLang.de[Task.Name] = "Verhaftung Vornehmen"
ADRLang.pl[Task.Name] = "Aresztowanie"
ADRLang.tr[Task.Name] = "Bir Tutuklama Yapın"
ADRLang["es-ES"][Task.Name] = "Realizar una Detención"

ADRLang.en[Task.Description] = "Arrest the criminal for his offense"
ADRLang.uk[Task.Description] = "Заарештуйте злочинця за його правопорушення"
ADRLang.ru[Task.Description] = "Арестуйте преступника за его правонарушение"
ADRLang.fr[Task.Description] = "Arrêter l'auteur de l'infraction"
ADRLang.de[Task.Description] = "Verhaftung des Täters für seine Straftat"
ADRLang.pl[Task.Description] = "Aresztowanie sprawcy za popełnione przestępstwo"
ADRLang.tr[Task.Description] = "Faili işlediği suçtan dolayı tutuklayın"
ADRLang["es-ES"][Task.Description] = "Detener al autor del delito"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)