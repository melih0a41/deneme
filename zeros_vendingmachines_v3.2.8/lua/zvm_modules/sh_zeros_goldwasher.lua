/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Goldwasher
// https://www.gmodstore.com/market/view/7405

zvm.AllowedItems.Add("zgw_goldwasher")
zvm.AllowedItems.Add("zgw_lantern")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

zvm.AllowedItems.Add("zgw_shovel")
zvm.AllowedItems.Add("zgw_sieve")

zclib.RenderData.Add("zgw_shovel", {ang = Angle(90, 0, 0)})
zclib.RenderData.Add("zgw_sieve", {ang = Angle(0, 0, 0)})
zclib.RenderData.Add("zgw_goldwasher", {ang = Angle(0, 0, 0),FOV = 5,pos = Vector(-35,0,0)})


zvm.Definition.Add("zgw_jar", {
	OnItemDataCatch = function(data, ent) data.gold = ent:GetGold() end,
	OnItemDataApply = function(data, ent) ent:SetGold(data.gold) end,
	OnItemDataName = function(data, ent) return ent.PrintName .. " " .. data.gold .. zgw.config.UoM end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.gold == data.gold end,
	BlockItemCheck = function(ent, Machine) if ent:GetGold() <= 0 then return true end end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

zvm.Definition.Add("zgw_bucket", {
	BlockItemCheck = function(ent, Machine) if ent:GetDirt() > 0 then return true end end,
})

zvm.Definition.Add("zgw_bucket_follow", {
	BlockItemCheck = function(ent, Machine) if ent:GetDirt() > 0 then return true end end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

zvm.Definition.Add("zgw_lantern", {
	BlockItemCheck = function(ent, Machine) if ent.GotStarted then return true end end,
})

zvm.Definition.Add("zgw_mat", {
	BlockItemCheck = function(ent, Machine) if ent:GetGold() > 0 then return true end end,
})

hook.Add("zclib_GetImagePath", "zclib_GetImagePath_GoldWasher", function(ItemData)
    if zgw and string.sub(ItemData.class, 1, 4) == "zgw_" then return "zgw/" .. ItemData.class end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

hook.Add("zclib_RenderProductImage","zclib_RenderProductImage_GoldWasher",function(cEnt,ItemData)
    if zgw then
        if ItemData.class == "zgw_lantern" then
            ItemData.model_bg[0] = 0
        elseif ItemData.class == "zgw_bucket_follow" then
            ItemData.model_bg[1] = 1
        end
    end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389
