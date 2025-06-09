local Task = {}

Task.Name = "KillNPC"

Task.Description = "Desc_KillNPC"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {3, 5, 10}

Task.AddHook = function()
	hook.Add( "OnNPCKilled", "ADR_TaskKillNPC", function( npc, attacker, inflictor )
		if !ADRewards.SeasonNow then return end
		if !attacker:IsPlayer() then return end
		if !attacker.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(attacker, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Kill NPC"
ADRLang.uk[Task.Name] = "Вбийте NPC"
ADRLang.ru[Task.Name] = "Убейте NPC"
ADRLang.fr[Task.Name] = "Tuer des NPC"
ADRLang.de[Task.Name] = "Töte die NPC"
ADRLang.pl[Task.Name] = "Zabij NPC"
ADRLang.tr[Task.Name] = "NPC'leri öldürün"
ADRLang["es-ES"][Task.Name] = "Mata a los NPC"

ADRLang.en[Task.Description] = "Kill a few NPCs"
ADRLang.uk[Task.Description] = "Вбийте декілька NPC"
ADRLang.ru[Task.Description] = "Убейте несколько NPC"
ADRLang.fr[Task.Description] = "Tuer quelques PNJ"
ADRLang.de[Task.Description] = "Töte ein paar NPCs"
ADRLang.pl[Task.Description] = "Zabij kilka NPC"
ADRLang.tr[Task.Description] = "Birkaç NPC öldürün"
ADRLang["es-ES"][Task.Description] = "Mata a unos cuantos NPC"
/*-------------------------------------------------------------------------*/
end


ADRewards.CreateTask(Task)