local Task = {}

Task.Name = "FallDamage"

Task.Description = "Desc_FallDamage"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {100, 200, 300}

local math_floor = math.floor
Task.AddHook = function()
	hook.Add( "EntityTakeDamage", "ADR_TaskFallDamage", function( target, dmginfo )
		if !ADRewards.SeasonNow then return end
		if !target:IsPlayer() or !dmginfo:IsFallDamage() then return end
		if !target.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(target, Task.Name, math_floor( dmginfo:GetDamage() ))
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Fall Damage"
ADRLang.uk[Task.Name] = "Травми від падіння"
ADRLang.ru[Task.Name] = "Урон от падения"
ADRLang.fr[Task.Name] = "Dommages dus à la chute"
ADRLang.de[Task.Name] = "Sturzschäden"
ADRLang.pl[Task.Name] = "Uraz Nóg"
ADRLang.tr[Task.Name] = "Düşme Hasarı"
ADRLang["es-ES"][Task.Name] = "Daños por Caída"

ADRLang.en[Task.Description] = "Take damage from the fall"
ADRLang.uk[Task.Description] = "Отримайте пошкодження від падіння"
ADRLang.ru[Task.Description] = "Получите урон от падения"
ADRLang.fr[Task.Description] = "Prendre les dégâts de la chute"
ADRLang.de[Task.Description] = "Schaden durch den Sturz nehmen"
ADRLang.pl[Task.Description] = "Obrażenia od upadku"
ADRLang.tr[Task.Description] = "Düşüşten hasar almak"
ADRLang["es-ES"][Task.Description] = "Recibe daños por la caída"
/*-------------------------------------------------------------------------*/
end


ADRewards.CreateTask(Task)