local Task = {}

Task.Name = "PlayTime"

Task.Description = "Desc_PlayTime"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {10, 30, 60}

Task.AddHook = function()
	hook.Add( "ADR_TasksLoaded", "ADR_TaskPlayTime", function( ply )
		local taskTbl = ply.TasksADR[Task.Name]
		if !taskTbl then return end
		if taskTbl.ValNeed <= taskTbl.ValNow then return end

		local timername = "ADR_PlayTime_"..ply:SteamID64()
		timer.Create(timername, 60, 0, function()
			ADRewards.GiveTaskVal(ply, Task.Name, 1)
			if !ADRewards.SeasonNow or (taskTbl.ValNeed <= taskTbl.ValNow) then timer.Remove( timername ) end
		end)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Play Time"
ADRLang.uk[Task.Name] = "Тривалість Гри"
ADRLang.ru[Task.Name] = "Время Игры"
ADRLang.fr[Task.Name] = "Temps de Jeu"
ADRLang.de[Task.Name] = "Spielzeit"
ADRLang.pl[Task.Name] = "Czas Gry"
ADRLang.tr[Task.Name] = "Oyun Zamanı"
ADRLang["es-ES"][Task.Name] = "Tiempo de Juego"

ADRLang.en[Task.Description] = "Play a certain amount of time on the server"
ADRLang.uk[Task.Description] = "Награйте певний час на сервері"
ADRLang.ru[Task.Description] = "Наиграйте определенное время на сервере"
ADRLang.fr[Task.Description] = "Jouer un certain temps sur le serveur"
ADRLang.de[Task.Description] = "Eine bestimmte Zeit auf dem Server spielen"
ADRLang.pl[Task.Description] = "Graj określoną ilość czasu na serwerze"
ADRLang.tr[Task.Description] = "Sunucuda belirli bir süre oynayın"
ADRLang["es-ES"][Task.Description] = "Juega un tiempo determinado en el servidor"
/*-------------------------------------------------------------------------*/
end

ADRewards.CreateTask(Task)