local Task = {}

Task.Name = "GetSalary"

Task.Description = "Desc_GetSalary"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {3, 6, 9}

Task.AddHook = function()
	hook.Add( "playerGetSalary", "ADR_TaskGetSalary", function( ply, amount )
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Get Salary"
ADRLang.uk[Task.Name] = "Отримайте Зарплату"
ADRLang.ru[Task.Name] = "Получите Зарплату"
ADRLang.fr[Task.Name] = "Obtenir un Salaire"
ADRLang.de[Task.Name] = "Gehälter Erhalten"
ADRLang.pl[Task.Name] = "Otrzymuj Wynagrodzenie"
ADRLang.tr[Task.Name] = "Maaş Alın"
ADRLang["es-ES"][Task.Name] = "Obtener salario"

ADRLang.en[Task.Description] = "Get your paycheck on the job"
ADRLang.uk[Task.Description] = "Отримайте зарплату граючи за якусь професію"
ADRLang.ru[Task.Description] = "Получите зарплату играя за какую-то профессию"
ADRLang.fr[Task.Description] = "Obtenir son salaire sur le lieu de travail"
ADRLang.de[Task.Description] = "Erhalten Sie Ihren Gehaltsscheck bei der Arbeit"
ADRLang.pl[Task.Description] = "Otrzymuj wypłatę w miejscu pracy"
ADRLang.tr[Task.Description] = "Maaş çekinizi iş başında alın"
ADRLang["es-ES"][Task.Description] = "Cobrar en el trabajo"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)