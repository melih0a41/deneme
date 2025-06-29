/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

zvm = zvm or {}
zvm.AllowedItems = zvm.AllowedItems or {}

function zvm.AllowedItems.Add(class)
	table.insert(zvm.config.Vendingmachine.AllowedItems,class)
end

zvm.Definition = zvm.Definition or {}
zvm.Definition.List = zvm.Definition.List or {}

/*
	This can be used to add new vendingmachines items much more efficiently
*/
function zvm.Definition.Add(class,data) zvm.Definition.List[class] = data end

function zvm.Definition.Get(class) return zvm.Definition.List[class] end

/*
zvm.Definition.Add("entity_class", {
	OnItemDataCatch 			= function(data, ent) data.VarName = ent.VarName end,
	OnItemDataApplyPreSpawn 	= function(data, ent) end,
	OnItemDataApply 			= function(data, ent) ent.VarName = data.VarName end,
	OnItemDataName 				= function(data, ent) return ent:GetName() end,
	OnItemDataPrice 			= function(product, data) end,
	ItemExists 					= function(compared_item, data) return true, compared_item.extraData.VarName == data.VarName end,
	ProductImageOverwrite 		= function(img_pnl, itemdata) end,
	IdleImageOverwrite 			= function(img_pnl, itemdata) end,
	ItemUnpackOverwrite 		= function(ply, Crate, itemdata) end,
	BlockItem 					= function(ply, Machine, itemdata, productid) end,
	ModifyProductDataOnPurchase = function(ply, itemData) end,
	BlockItemCheck 				= function(other, Machine) end,
	OnPackageItemSpawned 		= function(data, ent, ply) end,
})
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff



zvm.Module = zvm.Module or {}

/*
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

	We keep the hooks for now to prevent errors for any other server which might be using them

*/

/*
	Takes the item and returns the data it has
*/
function zvm.Module.OnItemDataCatch(class,ent)
	local CustomData = {}

	local definition = zvm.Definition.Get(class)
	if definition and definition.OnItemDataCatch then
		definition.OnItemDataCatch(CustomData, ent)
	else
		hook.Run("zvm_OnItemDataCatch", CustomData, ent, class)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	return CustomData
end

/*
	Tells us if this item allready exits in the machine and on which Key
*/
function zvm.Module.ItemExists(class,itemdata,extraData)
	local CustomCheck, Exists

	local definition = zvm.Definition.Get(class)
	if definition and definition.ItemExists then
		CustomCheck, Exists = definition.ItemExists(itemdata, extraData)
	else
		CustomCheck, Exists = hook.Run("zvm_ItemExists", class, itemdata, extraData)
	end
	return CustomCheck, Exists
end

/*
	Modifies the panel in some other way then usual
*/
function zvm.Module.ProductImageOverwrite(class, itemdata, img_pnl)
	local definition = zvm.Definition.Get(class)
	local CustomUpdate

	if definition and definition.ProductImageOverwrite then
		CustomUpdate = definition.ProductImageOverwrite(img_pnl, itemdata)
	else
		CustomUpdate = hook.Run("zvm_Overwrite_ProductImage", img_pnl, itemdata)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

	return CustomUpdate
end

/*
	Modifies the panel in some other way then usual
*/
function zvm.Module.IdleImageOverwrite(class, itemdata, img_pnl)
	local definition = zvm.Definition.Get(class)
	local CustomUpdate

	if definition and definition.IdleImageOverwrite then
		CustomUpdate = definition.IdleImageOverwrite(img_pnl, itemdata)
	else
		CustomUpdate = hook.Run("zvm_Overwrite_IdleImage", img_pnl, itemdata)
	end

	return CustomUpdate
end

/*
	Can be used to overwrite the unpack function for this item
*/
function zvm.Module.ItemUnpackOverwrite(class, itemdata, ply, Crate)
	local definition = zvm.Definition.Get(class)
	local UnpackOverwrite

	if definition and definition.ItemUnpackOverwrite then
		UnpackOverwrite = definition.ItemUnpackOverwrite(ply, Crate, itemdata)
	else
		UnpackOverwrite = hook.Run("zvm_Overwrite_ItemUnpack", ply, Crate, itemdata)
	end

	return UnpackOverwrite
end

/*
	Called to check for any reason why the entity cant be bought by the player
*/
function zvm.Module.BlockItem(class, itemdata, ply, Machine, productid)
	local definition = zvm.Definition.Get(class)
	local BlockItem

	if definition and definition.BlockItem then
		BlockItem = definition.BlockItem(ply, Machine, itemdata, productid)
	else
		BlockItem = hook.Run("zvm_AddItemBlock", ply, Machine, itemdata, productid)
	end

	return BlockItem
end

/*
	If some module wants to modify the product data before purchase
*/
function zvm.Module.ModifyProductDataOnPurchase(class, itemdata, ply)
	local ChangedData
	local definition = zvm.Definition.Get(class)

	if definition and definition.ModifyProductDataOnPurchase then
		ChangedData = definition.ModifyProductDataOnPurchase(ply, itemData)
	else
		ChangedData = hook.Run("zvm_ModifyProductDataOnPurchase", ply, itemData)
	end

	return ChangedData
end

/*
	Called to check for any reason why the entity cant be added
*/
function zvm.Module.BlockItemCheck(class, other, Machine)
	local BlockEntity
	local definition = zvm.Definition.Get(class)

	if definition and definition.BlockItemCheck then
		BlockEntity = definition.BlockItemCheck(other, Machine)
	else
		BlockEntity = hook.Run("zvm_BlockItemCheck", other, Machine)
	end

	return BlockEntity
end

/*
	Overrides the itemname if specified
*/
function zvm.Module.OnItemDataName(class, product, extraData)
	local definition = zvm.Definition.Get(class)
	local override_name

	if definition and definition.OnItemDataName then
		override_name = definition.OnItemDataName(extraData,product)
	else
		override_name = hook.Run("zvm_OnItemDataName", product, extraData)
	end

	return override_name
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

/*
	Overrides the item price if specified
*/
function zvm.Module.OnItemDataPrice(class, product, extraData)
	local definition = zvm.Definition.Get(class)
	local override_price

	if definition and definition.OnItemDataPrice then
		override_price = definition.OnItemDataPrice(product, extraData)
	else
		override_price = hook.Run("zvm_OnItemDataPrice", product, extraData)
	end

	return override_price
end

/*
	Apply any of the extra data before you spawn it
*/
function zvm.Module.OnItemDataApplyPreSpawn(class, ent, extraData)
	local definition = zvm.Definition.Get(class)
	if definition and definition.OnItemDataApplyPreSpawn then
		definition.OnItemDataApplyPreSpawn(extraData, ent)
	else
		hook.Run("zvm_OnItemDataApplyPreSpawn", class, ent, extraData)
	end
end

/*
	Apply any of the extra data after you spawned it
*/
function zvm.Module.OnItemDataApply(class, ent, extraData)
	local definition = zvm.Definition.Get(class)

	if definition and definition.OnItemDataApply then
		definition.OnItemDataApply(extraData, ent)
	else
		hook.Run("zvm_OnItemDataApply", class, ent, extraData)
	end
end

/*
	Call Special hook so we can call some custom code for each entity
*/
function zvm.Module.OnPackageItemSpawned(class, ent, extraData, ply)
	local definition = zvm.Definition.Get(class)

	if definition and definition.OnPackageItemSpawned then
		definition.OnPackageItemSpawned(extraData, ent, ply)
	else
		hook.Run("zvm_OnPackageItemSpawned", ply, ent, extraData)
	end
end
