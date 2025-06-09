local Task = {}

Task.Name = "HitOrder"

Task.Description = "Desc_HitOrder"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 2, 3}

Task.AddHook = function()
	hook.Add( "onHitAccepted", "ADR_TaskHitOrder", function( hitman, target, customer )
		ADRewards.GiveTaskVal(customer, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Hit Order"
ADRLang.uk[Task.Name] = "Замовте Вбивство"
ADRLang.ru[Task.Name] = "Закажите Убийство"
ADRLang.fr[Task.Name] = "Commander L'assassinat"
ADRLang.de[Task.Name] = "Töten Bestellen"
ADRLang.pl[Task.Name] = "Zlecenie Zabójstwa"
ADRLang.tr[Task.Name] = "Öldürme Emri Verin"
ADRLang["es-ES"][Task.Name] = "Ordenar la Muerte"

ADRLang.en[Task.Description] = "Make an order to kill a player"
ADRLang.uk[Task.Description] = "Зробіть замовлення на вбивство гравця"
ADRLang.ru[Task.Description] = "Сделайте заказ на убийство игрока"
ADRLang.fr[Task.Description] = "Donner l'ordre de tuer un joueur"
ADRLang.de[Task.Description] = "Einen Befehl zum Töten eines Spielers erteilen"
ADRLang.pl[Task.Description] = "Wydanie rozkazu zabicia gracza"
ADRLang.tr[Task.Description] = "Bir oyuncuyu öldürmek için emir verin"
ADRLang["es-ES"][Task.Description] = "Dar la orden de matar a un jugador"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)