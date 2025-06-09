local Task = {}

Task.Name = "ConsumMeth"

Task.Description = "Desc_ConsumMeth"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = 1

Task.AddHook = function()
	hook.Add( "zmlab2_OnMethConsum", "ADR_TaskConsumMeth", function( ply, MethType, MethQuality )
		if !ADRewards.SeasonNow then return end
		if !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Consume Meth"
ADRLang.uk[Task.Name] = "Вжити Мет"
ADRLang.ru[Task.Name] = "Употребите Мет"
ADRLang.fr[Task.Name] = "Consommer de la Méth"
ADRLang.de[Task.Name] = "Meth Konsumieren"
ADRLang.pl[Task.Name] = "Spożycie Mety"
ADRLang.tr[Task.Name] = "Meth Tüketin"
ADRLang["es-ES"][Task.Name] = "Consume Metanfetamina"

ADRLang.en[Task.Description] = "Consume the required amount of meth"
ADRLang.uk[Task.Description] = "Вжийте необхідну кількість мета"
ADRLang.ru[Task.Description] = "Употребите необходимое количество мета"
ADRLang.fr[Task.Description] = "Consommer la quantité nécessaire de méthamphétamine"
ADRLang.de[Task.Description] = "Konsumieren Sie die erforderliche Menge an Meth"
ADRLang.pl[Task.Description] = "Spożycie wymaganej ilości metamfetaminy"
ADRLang.tr[Task.Description] = "Gerekli miktarda meth tüketin"
ADRLang["es-ES"][Task.Description] = "Consumir la cantidad necesaria de metanfetamina"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if zmlab2 then return true end
	return false
end

ADRewards.CreateTask(Task)