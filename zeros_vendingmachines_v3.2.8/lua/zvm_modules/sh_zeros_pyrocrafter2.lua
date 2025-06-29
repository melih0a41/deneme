/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Pyrocrafter 2

zvm.Definition.Add("zpc2_firework", {
	OnItemDataCatch = function(data, ent)
		// Lets save the fireworkdata too
        local FireworkData = zpc2.Firework.GetCachedData(ent:GetSavefileID())
        if FireworkData then
            data.FireworkData = FireworkData
        end

        // Cache firework data
        zpc2.Firework.Cache(ent:GetSavefileID(),FireworkData)
	end,
	OnItemDataApply = function(data, ent)
		local SavefileID = data.FireworkData.UniqueID
        local FireworkData = zpc2.Firework.GetCachedData(SavefileID) or data.FireworkData
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

        zpc2.Firework.Cache(SavefileID,FireworkData)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194389

        local BoxData = zpc2.config.Pyrobox[FireworkData.PyroBoxID]
        if BoxData == nil then return end

        ent:SetSavefileID(SavefileID)

        // Cache firework data
        zpc2.Firework.Cache(SavefileID,FireworkData)

        ent:SetModel(BoxData.model)
        ent:PhysicsInit(SOLID_VPHYSICS)
        ent:SetSolid(SOLID_VPHYSICS)
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent:SetUseType(SIMPLE_USE)

        if zpc2.config.Firework.PlayerCollide == false then
            ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        end

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(true)
            phys:SetAngleDragCoefficient(1000)
        end
	end,
	OnItemDataName = function(data, ent)
		local savefile = ent:GetSavefileID()
        local FireworkData = zpc2.Firework.GetCachedData(savefile)
        if FireworkData == nil then return end
        local PyroBoxData = zpc2.config.Pyrobox[FireworkData.PyroBoxID]
        if PyroBoxData == nil then return end
        local name = FireworkData.Name

        if FireworkData.Version then
            name = name .. " v." .. FireworkData.Version
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

        return name
	end,
	ItemExists = function(compared_item, data)
		return true , compared_item.extraData.UniqueID == data.UniqueID
	end,
	BlockItemCheck = function(other, Machine)
		return other:GetIgnitionTime() > 0
	end
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
