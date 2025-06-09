local Task = {}

Task.Name = "SpawnCar"

Task.Description = "Desc_SpawnCar"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = 1

Task.AddHook = function()
	hook.Add( "RCD:OnSpawnVehicleBought", "ADR_TaskSpawnCar", function( ply, vehc, vehcInfos )
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Spawn Car"
ADRLang.uk[Task.Name] = "Створіть Автомобіль"
ADRLang.ru[Task.Name] = "Создайте Автомобиль"
ADRLang.fr[Task.Name] = "Spawn un Vehicule"
ADRLang.de[Task.Name] = "Auto Spawnen"
ADRLang.pl[Task.Name] = "Zespawnij Pojazd"
ADRLang.tr[Task.Name] = "Araç Oluştur"
ADRLang["es-ES"][Task.Name] = "Crear Vehículo"

ADRLang.en[Task.Description] = "Spawn your own car or take a test drive"
ADRLang.uk[Task.Description] = "Створіть свій автомобіль або скористайтеся тест-драйвом"
ADRLang.ru[Task.Description] = "Создайте свой автомобиль или воспользуйтесь тест-драйвом"
ADRLang.fr[Task.Description] = "Construisez votre propre voiture ou faites un essai routier"
ADRLang.de[Task.Description] = "Bauen Sie Ihr eigenes Auto oder machen Sie eine Probefahrt"
ADRLang.pl[Task.Description] = "Zbuduj własny samochód lub wybierz się na jazdę próbną"
ADRLang.tr[Task.Description] = "Kendi aracınızı üretin veya test sürüşü yapın"
ADRLang["es-ES"][Task.Description] = "Construye tu propio coche o pruébalo"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if RCD then return true end
	return false
end

ADRewards.CreateTask(Task)