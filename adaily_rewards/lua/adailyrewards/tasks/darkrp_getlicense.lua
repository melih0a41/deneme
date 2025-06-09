local Task = {}

Task.Name = "GetLicense"

Task.Description = "Desc_GetLicense"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = 1

Task.AddHook = function()
	hook.Add( "playerGotLicense", "ADR_TaskGetLicense", function( target, actor )
		ADRewards.GiveTaskVal(target, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Get License"
ADRLang.uk[Task.Name] = "Отримайте Ліцензію"
ADRLang.ru[Task.Name] = "Получите Лицензию"
ADRLang.fr[Task.Name] = "Obtenir une Licence"
ADRLang.de[Task.Name] = "Führerschein Erwerben"
ADRLang.pl[Task.Name] = "Uzyskaj Licencję"
ADRLang.tr[Task.Name] = "Ruhsat Alın"
ADRLang["es-ES"][Task.Name] = "Obtener una Licencia"

ADRLang.en[Task.Description] = "Get a gun license from an authorized person"
ADRLang.uk[Task.Description] = "Отримайте ліцензію на зброю від уповноваженої особи"
ADRLang.ru[Task.Description] = "Получите лицензию оружие от уполномоченного лица"
ADRLang.fr[Task.Description] = "Obtenir une licence d'armes à feu auprès d'une personne autorisée"
ADRLang.de[Task.Description] = "Erlangung eines Waffenscheins von einer befugten Person"
ADRLang.pl[Task.Description] = "Uzyskanie pozwolenia na broń palną od upoważnionej osoby"
ADRLang.tr[Task.Description] = "Yetkili bir kişiden ateşli silah ruhsatı almak"
ADRLang["es-ES"][Task.Description] = "Obtener una licencia de armas de fuego de una persona autorizada"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)