local Task = {}

Task.Name = "DestoryMeth"

Task.Description = "Desc_DestoryMeth"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {250,500,750}

Task.AddHook = function()
	hook.Add( "zmlab2_OnMethObjectDestroyed", "ADR_TaskDestoryMeth", function( methObject, damageinfo)
		if !ADRewards.SeasonNow then return end
		local ply = damageinfo:GetAttacker()
		if !IsValid(ply) or !ply:IsPlayer() then return end
		if !ply.TasksADR[Task.Name] then return end
		local methAmount = 0
		if methObject:GetClass() == "zmlab2_item_palette" then
            for k,v in pairs(methObject.MethList) do
                methAmount = v.a
            end
        else
            methAmount = methObject:GetMethAmount()
        end

		ADRewards.GiveTaskVal(ply, Task.Name, methAmount)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Destroy Met"
ADRLang.uk[Task.Name] = "Знищити Мет"
ADRLang.ru[Task.Name] = "Уничтожить Мет"
ADRLang.fr[Task.Name] = "Détruire Met"
ADRLang.de[Task.Name] = "Met Zerstören"
ADRLang.pl[Task.Name] = "Zniszcz Met"
ADRLang.tr[Task.Name] = "Yok Et Met"
ADRLang["es-ES"][Task.Name] = "Destruir Met"

ADRLang.en[Task.Description] = "Destroy the required amount of meth"
ADRLang.uk[Task.Description] = "Знищте необхідну кількість мета"
ADRLang.ru[Task.Description] = "Уничтожьте необходимое количество мета"
ADRLang.fr[Task.Description] = "Détruire la quantité nécessaire de méthamphétamine"
ADRLang.de[Task.Description] = "Vernichten Sie die erforderliche Menge an Meth"
ADRLang.pl[Task.Description] = "Zniszcz wymaganą ilość metamfetaminy"
ADRLang.tr[Task.Description] = "Gerekli miktarda metamfetamini imha edin"
ADRLang["es-ES"][Task.Description] = "Destruir la cantidad necesaria de metanfetamina"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if zmlab2 then return true end
	return false
end

ADRewards.CreateTask(Task)