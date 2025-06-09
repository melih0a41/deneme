local Task = {}

Task.Name = "PlayerDamage"

Task.Description = "Desc_PlayerDamage"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {100, 300, 500}

local math_floor = math.floor
Task.AddHook = function()
	hook.Add( "EntityTakeDamage", "ADR_TaskPlayerDamage", function( target, dmginfo )
		if !ADRewards.SeasonNow then return end
		local attacker = dmginfo:GetAttacker()
		if !target:IsPlayer() or !attacker or !attacker:IsPlayer() then return end
		if !attacker.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(attacker, Task.Name, math_floor( dmginfo:GetDamage() ))
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Player Damage"
ADRLang.uk[Task.Name] = "Ушкодження Гравцям"
ADRLang.ru[Task.Name] = "Урон Игрокам"
ADRLang.fr[Task.Name] = "Dommages aux Joueurs"
ADRLang.de[Task.Name] = "Spieler Schaden"
ADRLang.pl[Task.Name] = "Obrażenia Gracza"
ADRLang.tr[Task.Name] = "Oyuncu Hasarı"
ADRLang["es-ES"][Task.Name] = "Daños al Jugador"

ADRLang.en[Task.Description] = "Do a certain amount of damage to players"
ADRLang.uk[Task.Description] = "Завдайте певної кількості ушкоджень гравцям"
ADRLang.ru[Task.Description] = "Нанесите определенное количество урона игрокам"
ADRLang.fr[Task.Description] = "Faire un certain nombre de dégâts aux joueurs"
ADRLang.de[Task.Description] = "Verursache eine bestimmte Menge an Schaden bei Spielern"
ADRLang.pl[Task.Description] = "Zadaj określoną liczbę obrażeń graczom"
ADRLang.tr[Task.Description] = "Oyunculara belirli miktarda hasar verin"
ADRLang["es-ES"][Task.Description] = "Hacer una cierta cantidad de daño a los jugadores"
/*-------------------------------------------------------------------------*/
end


ADRewards.CreateTask(Task)