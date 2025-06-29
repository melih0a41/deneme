/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Factory
//https://www.gmodstore.com/market/view/zero-s-factory-crafting-space

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff


local function SpawnItem(ent,ItemID,ItemAmount)

    local itemData = zpf.config.Items[ItemID]
    ent.Model = itemData.model

    ent:SetModel(ent.Model)
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS )
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetUseType(SIMPLE_USE)
    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local bound_min, bound_max = ent:GetModelBounds()
    local size = bound_max - bound_min
    size = size:Length()
    local scale = 24 / size
    ent:SetModelScale(scale,0)
    ent:Activate()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
        phys:SetMaterial( "default_silent" )
    end

    ent:SetItemID(ItemID)
    ent:SetItemAmount(ItemAmount)

    if itemData.color then
        ent:SetColor(itemData.color)
    end
    if itemData.material then
        ent:SetMaterial(itemData.material)
    end
    if itemData.skin then
        ent:SetSkin(itemData.skin)
    end
end
zvm.Definition.Add("zpf_item", {
	OnItemDataCatch = function(data, ent)
		data.ItemID = ent:GetItemID()
		data.ItemAmount = ent:GetItemAmount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetItemID(data.ItemID)
		ent:SetItemAmount(data.ItemAmount)
		SpawnItem(ent, data.ItemID, data.ItemAmount)
	end,
	OnItemDataName = function(data, ent) return zpf.config.Items[ data.ItemID ].name .. " x" .. data.ItemAmount end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.ItemID == data.ItemID and compared_item.extraData.ItemAmount == data.ItemAmount end,
})

zvm.Definition.Add("zpf_upgradekit", {
	OnItemDataCatch = function(data, ent)
		data.ItemID = ent:GetItemID()
		data.ItemAmount = ent:GetItemAmount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetItemID(data.ItemID)
		ent:SetItemAmount(data.ItemAmount)
	end,
	OnItemDataName = function(data, ent) return zpf.config.Items[ data.ItemID ].name .. " x" .. data.ItemAmount end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.ItemID == data.ItemID and compared_item.extraData.ItemAmount == data.ItemAmount end,
})

zvm.Definition.Add("zpf_beltkit_slow", {
	OnItemDataCatch = function(data, ent)
		data.BeltCount = ent:GetBeltCount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetBeltCount(data.BeltCount)
	end,
	OnItemDataName = function(data, ent) return zvm.config.PredefinedNames[ "zpf_beltkit_slow" ] .. " x" .. data.BeltCount end,
})

zvm.Definition.Add("zpf_beltkit_fast", {
	OnItemDataCatch = function(data, ent)
		data.BeltCount = ent:GetBeltCount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetBeltCount(data.BeltCount)
	end,
	OnItemDataName = function(data, ent) return zvm.config.PredefinedNames[ "zpf_beltkit_fast" ] .. " x" .. data.BeltCount end,
})

zvm.Definition.Add("zpf_beltkit_extrem", {
	OnItemDataCatch = function(data, ent)
		data.BeltCount = ent:GetBeltCount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetBeltCount(data.BeltCount)
	end,
	OnItemDataName = function(data, ent) return zvm.config.PredefinedNames[ "zpf_beltkit_extrem" ] .. " x" .. data.BeltCount end,
})

zvm.Definition.Add("zpf_hive", {
	OnItemDataApply = function(data, ent)
		-- Resets the inventory so no bots will be there
		zpf.Inventory.Initialize(ent, 8)
	end,
})

zvm.AllowedItems.Add("zpf_scafold")
zvm.AllowedItems.Add("zpf_assembler")
zvm.AllowedItems.Add("zpf_cannon")
zvm.AllowedItems.Add("zpf_drill")
zvm.AllowedItems.Add("zpf_lab")
zvm.AllowedItems.Add("zpf_melter")
zvm.AllowedItems.Add("zpf_refiner")
zvm.AllowedItems.Add("zpf_recycler")
zvm.AllowedItems.Add("zpf_silo")
zvm.AllowedItems.Add("zpf_workbench")
zvm.AllowedItems.Add("zpf_chest_storage")
zvm.AllowedItems.Add("zpf_chest_provide")
zvm.AllowedItems.Add("zpf_chest_request")
zvm.AllowedItems.Add("zpf_chest_magneto")
zvm.AllowedItems.Add("zpf_constructor")

zclib.RenderData.Add("zpf_assembler", {
	ang = Angle(0, 180, 0)
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

zclib.RenderData.Add("zpf_drill", {
	ang = Angle(0, 180, 0)
})

zclib.RenderData.Add("zpf_hive", {
	ang = Angle(0, 180, 0)
})

zclib.RenderData.Add("zpf_cannon", {
	ang = Angle(0, 180, 0)
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zclib.RenderData.Add("zpf_melter", {
	ang = Angle(0, 180, 0)
})

zclib.RenderData.Add("zpf_recycler", {
	ang = Angle(0, 0, 0)
})

zclib.RenderData.Add("zpf_refiner", {
	ang = Angle(0, 180, 0)
})

zclib.RenderData.Add("zpf_silo", {
	ang = Angle(0, 90, 0)
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

zclib.RenderData.Add("zpf_lab", {
	ang = Angle(0, 180, 0)
})

zclib.RenderData.Add("zpf_workbench", {
	ang = Angle(0, 180, 0)
})

zvm.config.PredefinedNames[ "zpf_hive" ] = "Hive"
zvm.config.PredefinedNames[ "zpf_scafold" ] = "Foundation"
zvm.config.PredefinedNames[ "zpf_assembler" ] = "Assembler"
zvm.config.PredefinedNames[ "zpf_cannon" ] = "Item Cannon"
zvm.config.PredefinedNames[ "zpf_drill" ] = "Drill"
zvm.config.PredefinedNames[ "zpf_lab" ] = "Laboratory"
zvm.config.PredefinedNames[ "zpf_melter" ] = "Melter"
zvm.config.PredefinedNames[ "zpf_refiner" ] = "Refiner"
zvm.config.PredefinedNames[ "zpf_recycler" ] = "Recycler"
zvm.config.PredefinedNames[ "zpf_silo" ] = "Rocket Silo"
zvm.config.PredefinedNames[ "zpf_workbench" ] = "Workbench"
zvm.config.PredefinedNames[ "zpf_beltkit_extrem" ] = "Beltkit - Extrem"
zvm.config.PredefinedNames[ "zpf_beltkit_fast" ] = "Beltkit - Fast"
zvm.config.PredefinedNames[ "zpf_beltkit_slow" ] = "Beltkit - Slow"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zclib.Snapshoter.SetPath("zpf_item", function(ItemData) return "zpf/item_" .. ItemData.extraData.ItemID end)
zclib.Snapshoter.SetPath("zpf_upgradekit", function(ItemData) return "zpf/upgradekit_" .. ItemData.extraData.ItemID end)
zclib.Snapshoter.SetPath("zpf_chest_storage", function(ItemData) return "zpf/zpf_chest_storage" end)
zclib.Snapshoter.SetPath("zpf_chest_provide", function(ItemData) return "zpf/zpf_chest_provide" end)
zclib.Snapshoter.SetPath("zpf_chest_request", function(ItemData) return "zpf/zpf_chest_request" end)
zclib.Snapshoter.SetPath("zpf_chest_magneto", function(ItemData) return "zpf/zpf_chest_magneto" end)
zclib.Snapshoter.SetPath("zpf_beltkit_slow", function(ItemData) return "zpf/zpf_beltkit_slow" end)
zclib.Snapshoter.SetPath("zpf_beltkit_fast", function(ItemData) return "zpf/zpf_beltkit_fast" end)
zclib.Snapshoter.SetPath("zpf_beltkit_extrem", function(ItemData) return "zpf/zpf_beltkit_extrem" end)
