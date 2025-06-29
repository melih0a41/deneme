/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Yeastbeast
//https://www.gmodstore.com/market/view/zero-s-yeastbeast-alcohol-script

zvm.AllowedItems.Add("zyb_fuel")
zvm.AllowedItems.Add("zyb_jarpack")
zvm.AllowedItems.Add("zyb_paperbag")
zvm.AllowedItems.Add("zyb_sugar")
zvm.AllowedItems.Add("zyb_water")
zvm.AllowedItems.Add("zyb_yeast")
zvm.AllowedItems.Add("zyb_yeastgrinder")
zvm.AllowedItems.Add("zyb_motor")
zvm.AllowedItems.Add("zyb_fermbarrel")
zvm.AllowedItems.Add("zyb_distillery")
zvm.AllowedItems.Add("zyb_constructionkit_cooler")
zvm.AllowedItems.Add("zyb_constructionkit_condenser")

zclib.RenderData.Add("zyb_yeastgrinder", {ang = Angle(0, 180, 0)})

local zyb_entTable = {
    ["zyb_distillery"] = true,
    ["zyb_constructionkit_cooler"] = true,
    ["zyb_constructionkit_condenser"] = true,
    ["zyb_fermbarrel"] = true,
    ["zyb_fuel"] = true,
    ["zyb_jarpack"] = true,
    ["zyb_jarcrate"] = true,
    ["zyb_yeastgrinder"] = true,
    ["zyb_motor"] = true,
    ["zyb_paperbag"] = true,
    ["zyb_sugar"] = true,
    ["zyb_water"] = true,
    ["zyb_yeast"] = true,
    ["zyb_distillery_cooler"] = true,
    ["zyb_distillery_condenser"] = true,
    ["zyb_palette"] = true
}
hook.Add("zvm_OnPackageItemSpawned", "zvm_OnPackageItemSpawned_ZerosYeastbeast", function(ply, ent, extradata)
    if zyb and zyb_entTable[ent:GetClass()] then
        zyb.f.SetOwner(ent, ply)
    end
end)

zvm.Definition.Add("zyb_jarcrate", {
	OnItemDataCatch = function(data, ent)
		data.jar_count = ent:GetJarCount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetJarCount(data.jar_count)
	end,
	OnItemDataName = function(data, ent)
		if data.jar_count > 0 then
			return ent.PrintName .. " x" .. data.jar_count
		else
			return ent.PrintName
		end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.jar_count == data.jar_count end,
	BlockItemCheck = function(other, Machine) end,
})

zvm.Definition.Add("zyb_palette", {
	OnItemDataCatch = function(data, ent)
		data.crate_count = ent:GetCrateCount()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetCrateCount(data.crate_count)
	end,
	OnItemDataName = function(data, ent)
		if data.crate_count > 0 then
			return ent.PrintName .. " x" .. data.crate_count
		else
			return ent.PrintName
		end
	end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.crate_count == data.crate_count end,
	BlockItemCheck = function(other, Machine) end,
})

zvm.Definition.Add("zyb_jar", {
	OnItemDataApply = function(data, ent)
		ent:SetMoonShine(zyb.config.Jar.MoonshineAmount)
		ent:UpdateVisuals()
	end,
	BlockItemCheck = function(other, Machine) return other:GetMoonShine() < zyb.config.Jar.MoonshineAmount end,
})

zvm.Definition.Add("zyb_constructionkit_cooler", {
	OnItemDataName = function(data, ent) return "Kit - Cooler" end,
})

zvm.Definition.Add("zyb_constructionkit_condenser", {
	OnItemDataName = function(data, ent) return "Kit - Condenser" end,
})

zvm.Definition.Add("zyb_jarpack", {
	BlockItemCheck = function(ent, Machine) return ent:GetJarCount() < 6 end,
})

zvm.Definition.Add("zyb_paperbag", {
	BlockItemCheck = function(ent, Machine) return ent:GetYeastAmount() > 0 end,
})

zvm.Definition.Add("zyb_yeast", {
	BlockItemCheck = function(ent, Machine) return ent:GetYeastAmount() < zyb.config.YeastBlock.Amount end,
})

zvm.Definition.Add("zyb_yeastgrinder", {
	BlockItemCheck = function(ent, Machine) return ent:GetGrinding() end,
})

zvm.Definition.Add("zyb_fermbarrel", {
	BlockItemCheck = function(ent, Machine) return ent:GetStage() ~= 0 end,
})
zclib.Snapshoter.SetPath("zyb_jarcrate", function(ItemData) return "zyb/crates/crate_" .. ItemData.extraData.jar_count end)
zclib.Snapshoter.SetPath("zyb_palette", function(ItemData) return "zyb/palette/palette_" .. ItemData.extraData.crate_count end)

hook.Add("zclib_RenderProductImage","zclib_RenderProductImage_ZerosYeastbeast",function(cEnt,ItemData)
    if zyb then
        // Lets add the food on the plates before rendering
        if ItemData.class == "zyb_palette" and ItemData.extraData and ItemData.extraData.crate_count and ItemData.extraData.crate_count > 0 then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

            // Create all the crates on the palette
            local crates = {}
            local Count_X = 0
            local Count_Y = 0
            local Count_Z = 0
            for i = 1, ItemData.extraData.crate_count do
                local client_mdl = zclib.ClientModel.Add("models/zerochain/props_yeastbeast/yb_jarcrate_full.mdl", RENDERGROUP_BOTH)
                if IsValid(client_mdl) then
                    local pos = cEnt:GetPos() - cEnt:GetRight() * 25 - cEnt:GetForward() * 50 + cEnt:GetUp() * 3
                    local ang = cEnt:GetAngles()

                    if Count_X >= 2 then
                        Count_X = 1
                        Count_Y = Count_Y + 1
                    else
                        Count_X = Count_X + 1
                    end

                    if Count_Y >= 3 then
                        Count_Y = 0
                        Count_Z = Count_Z + 1
                    end

                    pos = pos + cEnt:GetForward() * 33 * Count_X
                    pos = pos + cEnt:GetRight() * 25 * Count_Y
                    pos = pos + cEnt:GetUp() * 13.5 * Count_Z

                    client_mdl:SetAngles(ang)
                    client_mdl:SetPos(pos)

                    render.Model({
                        model = "models/zerochain/props_yeastbeast/yb_jarcrate_full.mdl",
                        pos = pos,
                        angle = ang
                    }, client_mdl)

                    table.insert(crates,client_mdl)
                end
            end

            cEnt:CallOnRemove("zyb_remove_render_crates_" .. cEnt:EntIndex(),function(ent)
                for k,v in pairs(crates) do
                    zclib.ClientModel.Remove(v)
                end
            end)
        elseif ItemData.class == "zyb_jarpack" then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 0a634a1c95b228804b929766b9af17cff8ffcc3dd0f61e75078108af6f36b161

            // Create all the crates on the palette
            local jars = {}
            for i = 1, 6 do
                local client_mdl = zclib.ClientModel.Add("models/zerochain/props_yeastbeast/yb_jar.mdl", RENDERGROUP_BOTH)
                if IsValid(client_mdl) then
                    local pos = cEnt:GetAttachment(i).Pos - cEnt:GetUp() * 3
                    client_mdl:SetPos(pos)

                    render.Model({
                        model = "models/zerochain/props_yeastbeast/yb_jar.mdl",
                        pos = pos,
                        angle = Angle(0,0,0)
                    }, client_mdl)

                    table.insert(jars,client_mdl)
                end
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

            cEnt:CallOnRemove("zyb_remove_render_jarpacks_" .. cEnt:EntIndex(),function(ent)
                for k,v in pairs(jars) do
                    zclib.ClientModel.Remove(v)
                end
            end)
        elseif ItemData.class == "zyb_jarcrate" and ItemData.extraData and ItemData.extraData.jar_count and ItemData.extraData.jar_count > 0 then

            // Create all the crates on the palette
            local jars = {}
            for i = 1, ItemData.extraData.jar_count do
                local client_mdl = zclib.ClientModel.Add("models/zerochain/props_yeastbeast/yb_jar.mdl", RENDERGROUP_BOTH)
                if IsValid(client_mdl) then
                    local pos = cEnt:GetAttachment(i).Pos + cEnt:GetUp() * 1
                    client_mdl:SetPos(pos)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

                    client_mdl:SetBodygroup(2, 5)
                    client_mdl:SetBodygroup(1,1)

                    render.Model({
                        model = "models/zerochain/props_yeastbeast/yb_jar.mdl",
                        pos = pos,
                        angle = Angle(0,0,0)
                    }, client_mdl)

                    table.insert(jars,client_mdl)
                end
            end

            cEnt:CallOnRemove("zyb_remove_render_jarpacks_" .. cEnt:EntIndex(),function(ent)
                for k,v in pairs(jars) do
                    zclib.ClientModel.Remove(v)
                end
            end)
        end
    end
end)
