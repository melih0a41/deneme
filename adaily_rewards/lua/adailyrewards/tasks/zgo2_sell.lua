local Task = {}

Task.Name = "SellWeed"

Task.Description = "Desc_SellWeed"

if SERVER then
/*---------------------------------------------------------------------------
------------------------------------SERVER-----------------------------------
---------------------------------------------------------------------------*/
Task.Values = {250,500,750}

Task.AddHook = function()
	hook.Add( "zgo2.NPC.OnQuickSell", "ADR_TaskQuickSellWeed", function( ply, weed_id, weed_amount, weed_value )
		if !ADRewards.SeasonNow then return end
		if !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, weed_amount)
	end )

	hook.Add( "zgo2.Marketplace.OnCargoSold", "ADR_TaskCargoSellWeed", function( ply, MarketplaceID, cargo_name ,cargo_amount, cargo_value, cargo_data )
		if !ADRewards.SeasonNow then return end
		if !ply.TasksADR[Task.Name] then return end

		ADRewards.GiveTaskVal(ply, Task.Name, cargo_amount)
	end )
end
/*-------------------------------------------------------------------------*/
else-------------------------------------------------------------------------
------------------------------------CLIENT-----------------------------------
---------------------------------------------------------------------------*/
ADRLang.en[Task.Name] = "Sell Weed"
ADRLang.uk[Task.Name] = "Продати Травичку"
ADRLang.ru[Task.Name] = "Продать Травку"
ADRLang.fr[Task.Name] = "Vente de Weed"
ADRLang.de[Task.Name] = "Gras Verkaufen"
ADRLang.pl[Task.Name] = "Sprzedaż Marihuany"
ADRLang.tr[Task.Name] = "Kenevir Satışları"
ADRLang["es-ES"][Task.Name] = "Venta de Cannabis"

ADRLang.en[Task.Description] = "Sell the required amount of weed"
ADRLang.uk[Task.Description] = "Продайте необхідну кількість травички"
ADRLang.ru[Task.Description] = "Продайте необходимое количество травки"
ADRLang.fr[Task.Description] = "Vender la cantidad necesaria de marihuana"
ADRLang.de[Task.Description] = "Verkaufen Sie die erforderliche Menge an Gras"
ADRLang.pl[Task.Description] = "Sprzedać wymaganą ilość marihuany"
ADRLang.tr[Task.Description] = "Gerekli miktarda marihuana satmak"
ADRLang["es-ES"][Task.Description] = "Vender la cantidad requerida de marihuana"
/*-------------------------------------------------------------------------*/
end

Task.CheckLoad = function()
	if file.Exists("zgo2", "LUA") then  return true end
	return false
end

ADRewards.CreateTask(Task)