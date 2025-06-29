/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.ItemData = zvm.ItemData or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

// Takes the item and returns the data it has
function zvm.ItemData.Catch(item)
    // Check if there is any other custom data we want append
    return zvm.Module.OnItemDataCatch(item:GetClass(),item)
end

// Tells us if this item allready exits in the machine and on which Key
// This will tell if the item should be stacked later
function zvm.ItemData.DoesExist(Machine, item, extraData, entData)
	zclib.Debug("ItemData_DoesExist")
	local itemclass = item:GetClass()
	local DoesExist = false
	local ProductKey

	for k, v in pairs(Machine.Products) do
		// If the items dont have the same class to begin with then they cant be the same
		if v.class ~= itemclass then continue end

		local CustomCheck, Exists = zvm.Module.ItemExists(itemclass,v,extraData)

		if CustomCheck then
			if Exists then
				ProductKey = k
				DoesExist = true
				break
			end
		else
			ProductKey = k
			DoesExist = true
		end
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

	if DoesExist then
		zclib.Debug("Item allready exists in machine!")
	end

	return DoesExist, ProductKey
end

// Tells us the name of the Item
function zvm.ItemData.Name(item,extraData)
    local ent = duplicator.CopyEntTable(item)
    local itemclass = item:GetClass()

    // Does the itemclass have a predefined name?
    if zvm.config.PredefinedNames[itemclass] then
        return zvm.config.PredefinedNames[itemclass]
    end

    // Does the Ent Data have a name?
    if ent.Name and string.len(ent.Name) >= 1 then
        return ent.Name
    end

    // Does the Ent Data have a PrintName?
    if ent.PrintName and string.len(ent.PrintName) >= 1 then
        return ent.PrintName
    end

    if item:IsWeapon() then
        local wep_list = list.Get( "Weapon" )
        if wep_list[itemclass] and wep_list[itemclass].PrintName then
            return wep_list[itemclass].PrintName
        end
    end

    // Name could not be found return class as name
    return itemclass
end

// Returns the correct model , skin, bgs, material, color
function zvm.ItemData.GetModelData(item,entdata)
    local model
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

    // If there is a predefined model then we use that instead
    if zvm.config.PredefinedModels[item:GetClass()] then
        model = zvm.config.PredefinedModels[item:GetClass()]
    else
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

        // Model fix for TFA Weapons
        if entdata.WElements then
            for k, v in pairs(entdata.WElements) do

                if v and v.model then
                    model = v.model
                    break
                end
            end
        end

        // Normal model Data
        if model == nil then
            if entdata.Model then
                model = entdata.Model
            else
                model = "models/error.mdl"
            end
        end
    end

    local bgs = {}
    for k,v in pairs(item:GetBodyGroups()) do
        bgs[v.id] = item:GetBodygroup(v.id)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

    local mData = {
        model = model,
        model_skin = item:GetSkin(),
        model_material = item:GetMaterial(),
        model_bg = bgs,
        model_color = item:GetColor(),
    }

    return mData
end
