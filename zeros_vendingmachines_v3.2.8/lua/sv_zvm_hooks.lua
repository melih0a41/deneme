/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if (not SERVER) then return end

// Here are some Hooks you can use for Custom Code

// Called when a player buys items
hook.Add("zvm_OnItemBought", "zvm_OnItemBought_Test", function(ply, Vendingmachine, package, money)
    /*
    print("zvm_OnItemBought")
    print("Player who bought the Item/Items: " .. tostring(ply))
    print("Vendingmachine: " .. tostring(Vendingmachine))
    print("Money: " .. money)
    print("Package: " .. tostring(package))
    print("----------------")
    */
end)

// Called when a player opens a package
hook.Add("zvm_OnPackageOpend", "zvm_OnPackageOpend_Test", function(ply, package)
    /*
    print("zvm_OnPackageOpend")
    print("Player who opend the package:  " .. tostring(ply))
    print("Package: " .. tostring(package))
    print("----------------")
    */
end)

// Called when a Item gets spawned from the Package
hook.Add("zvm_OnPackageItemSpawned", "zvm_OnPackageItemSpawned_Test", function(ply, ent,extradata)

    /*
    print("zvm_OnPackageItemSpawned")
    print("Player who opend the package:  " .. tostring(ply))
    print("Item: " .. tostring(ent))
    print("----------------")
    */
end)

// Called when we get the data from a entity before adding it to the Vendingmachine.
// Here you can return some extra data
hook.Add("zvm_OnItemDataCatch", "zvm_OnItemDataCatch_Test", function( data,ent,itemclass)
    /*
        if itemclass == "SpecialClass" then
            data.SomeExtraDataVar = ent.ExtraData
        end
    */
end)

// Called when we apply the extra Data after we spawned the entity
hook.Add("zvm_OnItemDataApply", "zvm_OnItemDataApply_Test", function( itemclass, ent, extraData)
    /*
        if itemclass == "SpecialClass" then
            ent.ExtraData = extraData.SomeExtraDataVar
        end
    */
end)

// Called to override the Itemname when adding it to the Vendingmachine
hook.Add("zvm_OnItemDataName", "zvm_OnItemDataName_Test", function(ent,extraData)
    /*
        if itemclass == "SpecialClass" then
            return "Special Item"
        end
    */
end)

// Called to override the ItemPrice when adding it to the Vendingmachine
hook.Add("zvm_OnItemDataPrice", "zvm_OnItemDataPrice_Test", function(ent,extraData)
    /*
        if itemclass == "SpecialClass" then
            return 10000
        end
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff



// Called to check for any reason why the entity cant be added to the vendingmachine
hook.Add("zvm_BlockItemCheck", "zvm_BlockItemCheck_Test", function(ent,vendingmachine)

    // Custom check to make sure only full shipments can be added to the vendingmachine
    if ent:GetClass() == "spawned_shipment" then
        local contents = CustomShipments[ent:Getcontents()]
        if contents == nil or ent.dt == nil or ent.dt.count == nil or ent.dt.count ~= contents.amount then
            local ply = zclib.Player.GetOwner(vendingmachine)
            if IsValid(ply) then
                zclib.Notify(ply, "Shipment needs to be full!", 1)
            end
            return true
        end
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

// Checks if the specified Item allready exists in the Vendingmachine
// This only gets called when the itemclass we are trying to add has the same class as one thats allready in the Vendingmachine.
// Since both Items have the same class we try to compare the CustomData like foodtype, ammotype, etc..
hook.Add("zvm_ItemExists", "zvm_ItemExists_Test", function(compared_item,extraData)
    /*
        if itemclass == "SpecialClass" then
            // The first value tells us that a special check for this Class exists
            // The second value tells us if the 2 items are the same
            return true , compared_item.extraData.ItemID == extraData.ItemID
        end
    */
end)

// Return true to block the player from interacting with the vendingmachine
// Return nothing otherwhise
hook.Add("zvm_BlockInteraction", "zvm_BlockInteraction_Test", function(ply,vendingmachine)
    /*
    if vendingmachine.MachineName == "PronToys" and ply.Age < 18 then
        zclib.Notify(ply, "This Vendingmachine is for +18 only!", 1)
        return true
    end
    */
end)

// Provides the Product data from a vendingmachine, Return the image path on where it should be saved
// This is relative to "data/zclib/img/"
// If none is provided then the image path will be the model path
/*
// Function for adding a image path
zclib.Snapshoter.SetPath("sent_ball",function(ItemData)
    return "balls/" .. ItemData.class
end)

// Hook for adding a image path
hook.Add("zclib_GetImagePath","zclib_GetImagePath_Test",function(ItemData)
    if ItemData.class == "sent_ball" then
        return "balls/" .. ItemData.class
    end
end)
*/
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

// Gets called when the product image is beinig rendered
// Can be used to modify the rendered scene
hook.Add("zclib_RenderProductImage","zclib_RenderProductImage_Test",function(cEnt,ItemData)
end)

// Same as zclib_RenderProductImage but gets called after the product got rendered
hook.Add("zclib_PostRenderProductImage","zclib_PostRenderProductImage_Test",function(cEnt,ItemData)
end)

// Can be used to modify the small ProductImage panel
// Return true for it to take affect
hook.Add("zvm_Overwrite_ProductImage","zvm_Overwrite_ProductImage_Test",function(pnl,ItemData)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

// Can be used to modify the big IdleImage panel
// Return true for it to take affect
hook.Add("zvm_Overwrite_IdleImage","zvm_Overwrite_IdleImage_Test",function(pnl,ItemData)
end)

// Can be used to overwrite what should happen when a specific item gets unpacked
// Return true for it to take affect
hook.Add("zvm_Overwrite_ItemUnpack","zvm_Overwrite_ItemUnpack_Test",function(ply,crate,ItemData)
end)

// Can be used to prevent the user from adding a item to his buylist
// Return true to prevent the player
hook.Add("zvm_AddItemBlock","zvm_AddItemBlock_Test",function(ply,Machine,ItemData,ItemID)
end)

// Called when the player got data from a machine send
hook.Add("zvm_OnMachineDataUpdated","zvm_OnMachineDataUpdated_Test",function(Machine)
end)

// Return true to prevent the player using the PriceEditor
hook.Add("zvm_BlockPriceEditor","zvm_BlockPriceEditor_Test",function(Machine)
end)

// Return true to prevent the player using the AppearanceEditor
hook.Add("zvm_BlockAppearanceEditor","zvm_BlockAppearanceEditor_Test",function(Machine)
end)

// Return true to prevent the player using the RestrictionsEditor
hook.Add("zvm_BlockRestrictionsEditor","zvm_BlockRestrictionsEditor_Test",function(Machine)
end)

// Gets called when a buy request is made, here we can modify the product data which gets added in to the package
hook.Add("zvm_ModifyProductDataOnPurchase","zvm_ModifyProductDataOnPurchase_Test",function(ply,ProductData)
end)
