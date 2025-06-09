local Task = {}

Task.Name = "BuyDoor"

Task.Description = "Desc_BuyDoor"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {3, 6, 9}

Task.AddHook = function()
	hook.Add( "playerBoughtDoor", "ADR_TaskBuyDoor", function( ply, ent, cost )
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Buy Door"
ADRLang.uk[Task.Name] = "Придбати Двері"
ADRLang.ru[Task.Name] = "Купить Дверь"
ADRLang.fr[Task.Name] = "Acheter une Porte"
ADRLang.de[Task.Name] = "Tür Kaufen"
ADRLang.pl[Task.Name] = "Kup Drzwi"
ADRLang.tr[Task.Name] = "Kapı Satın Al"
ADRLang["es-ES"][Task.Name] = "Comprar Puerta"

ADRLang.en[Task.Description] = "Purchase a door in some place"
ADRLang.uk[Task.Description] = "Придбайте двері в якомусь приміщенні"
ADRLang.ru[Task.Description] = "Приобретите дверь в каком-то помещении"
ADRLang.fr[Task.Description] = "Achat d'une porte à un endroit donné"
ADRLang.de[Task.Description] = "Kauf einer Tür an einem bestimmten Ort"
ADRLang.pl[Task.Description] = "Zakup drzwi w jakimś miejscu"
ADRLang.tr[Task.Description] = "Bir yerden bir kapı satın alın"
ADRLang["es-ES"][Task.Description] = "Comprar una puerta en algún lugar"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)