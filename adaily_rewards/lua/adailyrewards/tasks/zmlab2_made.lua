local Task = {}

Task.Name = "MadeMeth"

Task.Description = "Desc_MadeMeth"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {250,500,750}

Task.AddHook = function()
	hook.Add( "zmlab2_OnMethMade", "ADR_TaskMadeMeth", function( pl, frezzingTray, methEnt )
		if !ADRewards.SeasonNow then return end
		local ply = pl
		if !IsValid(ply) then
			if !IsValid(methEnt) then return end
			local owner = methEnt:CPPIGetOwner()
			if !IsValid(owner) or !owner:IsPlayer() then return end
			ply = owner
		end
		if !ply.TasksADR[Task.Name] then return end

		local methAmount = methEnt:GetMethAmount()

		ADRewards.GiveTaskVal(ply, Task.Name, methAmount)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Make Meth"
ADRLang.uk[Task.Name] = "Виготовте Мет"
ADRLang.ru[Task.Name] = "Изготовьте Мет"
ADRLang.fr[Task.Name] = "Fabriquer de la Méth"
ADRLang.de[Task.Name] = "Meth Herstellen"
ADRLang.pl[Task.Name] = "Produkcja Mety"
ADRLang.tr[Task.Name] = "Meth Yap"
ADRLang["es-ES"][Task.Name] = "Hacer Metanfetamina"

ADRLang.en[Task.Description] = "Make the required amount of meth"
ADRLang.uk[Task.Description] = "Виготовте необхідну кількість мета"
ADRLang.ru[Task.Description] = "Изготовьте необходимое количества мета"
ADRLang.fr[Task.Description] = "Préparer la quantité nécessaire de méthamphétamine"
ADRLang.de[Task.Description] = "Stellen Sie die erforderliche Menge an Meth her"
ADRLang.pl[Task.Description] = "Przygotuj wymaganą ilość metamfetaminy"
ADRLang.tr[Task.Description] = "Gerekli miktarda meth yapın"
ADRLang["es-ES"][Task.Description] = "Prepare la cantidad necesaria de metanfetamina"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if zmlab2 then return true end
	return false
end

ADRewards.CreateTask(Task)