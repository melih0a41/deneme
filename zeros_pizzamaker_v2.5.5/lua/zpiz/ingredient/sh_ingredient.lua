/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

zpiz = zpiz or {}
zpiz.Ingredient = zpiz.Ingredient or {}

function zpiz.Ingredient.GetData(id)
	return zpiz.config.Ingredients[id]
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

function zpiz.Ingredient.GetName(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.name
	else
		return "Unkown"
	end
end

function zpiz.Ingredient.GetModel(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.model
	else
		return "Unkown"
	end
end

function zpiz.Ingredient.GetIcon(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.icon
	else
		return zpiz.materials["zpiz_circle"]
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1e328fabbaf565eb0db586ac588b71f8384bcaa811ba77de699b4af9f3938eed
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47

function zpiz.Ingredient.GetColor(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.color
	else
		return color_white
	end
end

function zpiz.Ingredient.GetPrice(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat then
		return dat.price
	else
		return 0
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 2ec7bf76aef81873a8e297c99878b6c3d58ea4d3947c3a5ff3089503b2848c47

function zpiz.Ingredient.GetLimit(id)
	local dat = zpiz.Ingredient.GetData(id)
	if dat && isnumber(dat.limit) then
		return dat.limit
	else
		return 5
	end
end
