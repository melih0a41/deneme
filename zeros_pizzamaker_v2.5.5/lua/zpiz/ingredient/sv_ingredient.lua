/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if not SERVER then return end
zpiz = zpiz or {}
zpiz.Ingredient = zpiz.Ingredient or {}
zpiz.Ingredient.List = zpiz.Ingredient.List or {}

function zpiz.Ingredient.Add(Ingredient)
	Ingredient.SpawnTime = CurTime() + zpiz.config.Ingredient.Despawn
	table.insert(zpiz.Ingredient.List, Ingredient)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 424f95482a0f767a4150c7f5703bf669d63905694257a805988c97414ec2fe70
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

if zpiz.config.Ingredient.Despawn > 0 then
	zclib.Timer.Create("zpiz_ingredientcleanup_timer", zpiz.config.Ingredient.Despawn, 0, function()
		for k, v in pairs(zpiz.Ingredient.List) do
			if IsValid(v) and v.SpawnTime < CurTime() then
				SafeRemoveEntity(v)
			end
		end
	end)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838599
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
