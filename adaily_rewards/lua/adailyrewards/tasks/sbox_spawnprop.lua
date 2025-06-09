local Task = {}

Task.Name = "SpawnProp"

Task.Description = "Desc_SpawnProp"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {15, 30, 50}

Task.AddHook = function()
	hook.Add( "PlayerSpawnProp", "ADR_TaskPropSpawn", function( ply, mdl )
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Spawn Prop"
ADRLang.uk[Task.Name] = "Створити Реквізит"
ADRLang.ru[Task.Name] = "Создать Реквизит"
ADRLang.fr[Task.Name] = "Créer un Accessoire"
ADRLang.de[Task.Name] = "Stütze Erstellen"
ADRLang.pl[Task.Name] = "Utwórz Rekwizyt"
ADRLang.tr[Task.Name] = "Destek Oluşturun"
ADRLang["es-ES"][Task.Name] = "Crear Accesorio"

ADRLang.en[Task.Description] = "Create the required number of props"
ADRLang.uk[Task.Description] = "Створіть необхідну кількість реквізиту"
ADRLang.ru[Task.Description] = "Создайте необходимое количество реквизита"
ADRLang.fr[Task.Description] = "Créer le nombre nécessaire d'accessoires"
ADRLang.de[Task.Description] = "Erstellen Sie die erforderliche Anzahl von Requisiten"
ADRLang.pl[Task.Description] = "Utwórz wymaganą liczbę rekwizytów"
ADRLang.tr[Task.Description] = "Gerekli sayıda sahne oluşturun"
ADRLang["es-ES"][Task.Description] = "Crear el número necesario de puntales"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !g_SBoxObjects then return false end
	return true
end

ADRewards.CreateTask(Task)