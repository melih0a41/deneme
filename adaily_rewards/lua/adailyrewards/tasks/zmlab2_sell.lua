local Task = {}

Task.Name = "SellMeth"

Task.Description = "Desc_SellMeth"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {250,500,750}

Task.AddHook = function()
	hook.Add( "zmlab2_PostMethSell", "ADR_TaskSellMeth", function( ply, Earning, MethList )
		if !ADRewards.SeasonNow then return end
		if !ply.TasksADR[Task.Name] then return end

		local methAmount = 0
		for k, v in pairs(MethList) do
			methAmount = methAmount + v.a
		end

		ADRewards.GiveTaskVal(ply, Task.Name, methAmount)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Sell Meth"
ADRLang.uk[Task.Name] = "Продати Мет"
ADRLang.ru[Task.Name] = "Продать Мет"
ADRLang.fr[Task.Name] = "Vendre de la Méth"
ADRLang.de[Task.Name] = "Meth Verkaufen"
ADRLang.pl[Task.Name] = "Sprzedaż Mety"
ADRLang.tr[Task.Name] = "Meth Satmak"
ADRLang["es-ES"][Task.Name] = "Vender Metanfetamina"

ADRLang.en[Task.Description] = "Sell the required amount of meth"
ADRLang.uk[Task.Description] = "Продайте необхідну кількість мета"
ADRLang.ru[Task.Description] = "Продайте необходимое количество мета"
ADRLang.fr[Task.Description] = "Vendre la quantité nécessaire de méthamphétamine"
ADRLang.de[Task.Description] = "Verkaufen Sie die erforderliche Menge an Meth"
ADRLang.pl[Task.Description] = "Sprzedaż wymaganej ilości metamfetaminy"
ADRLang.tr[Task.Description] = "Gerekli miktarda meth satmak"
ADRLang["es-ES"][Task.Description] = "Vender la cantidad necesaria de metanfetamina"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if zmlab2 then return true end
	return false
end

ADRewards.CreateTask(Task)