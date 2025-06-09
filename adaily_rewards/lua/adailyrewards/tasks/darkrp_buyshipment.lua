local Task = {}

Task.Name = "BuyShipment"

Task.Description = "Desc_BuyShipment"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {1, 3, 5}

Task.AddHook = function()
	hook.Add( "playerBoughtShipment", "ADR_TaskBuyShipment", function( ply, shipmentTable, ent, price )
		ADRewards.GiveTaskVal(ply, Task.Name, 1)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Buy Shipment"
ADRLang.uk[Task.Name] = "Придбати Ящик"
ADRLang.ru[Task.Name] = "Купить Ящик"
ADRLang.fr[Task.Name] = "Acheter Shipment"
ADRLang.de[Task.Name] = "Kaufen Shipment"
ADRLang.pl[Task.Name] = "Kupować Shipment"
ADRLang.tr[Task.Name] = "Satın al Shipment"
ADRLang["es-ES"][Task.Name] = "Comprar Shipment"

ADRLang.en[Task.Description] = "Purchase any shipment at the store"
ADRLang.uk[Task.Description] = "Придбайте будь-який ящик у магазині"
ADRLang.ru[Task.Description] = "Приобретите любой ящик в магазине"
ADRLang.fr[Task.Description] = "Acheter n'importe quel shipment dans le magasin"
ADRLang.de[Task.Description] = "Kauf einer beliebigen shipment im Geschäft"
ADRLang.pl[Task.Description] = "Zakup dowolnej shipment w sklepie"
ADRLang.tr[Task.Description] = "Mağazadan herhangi bir shipment satın alın"
ADRLang["es-ES"][Task.Description] = "Comprar cualquier shipment en la tienda"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if !DarkRP then return false end
	return true
end

ADRewards.CreateTask(Task)