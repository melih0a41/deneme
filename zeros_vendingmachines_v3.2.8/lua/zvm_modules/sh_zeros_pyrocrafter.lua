/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

/////////////////////////
//Zeros Pyrocrafter
//https://www.gmodstore.com/market/view/zero-s-pyrocrafter-firework-script

local function FireworkSetup(ent, ply)
    local filename = ent:GetPyroFileName()
    local _, directories = file.Find("zpc/*", "DATA", "datedesc")
    local pathToFile

    for _, dirs in pairs(directories) do
        local currentPath = "zpc/" .. dirs .. "/"
        local files, dirs01 = file.Find(currentPath .. "*", "DATA", "datedesc")
        local foundPath = false

        for s, w in pairs(files) do
            if w == filename then
                pathToFile = currentPath .. filename
                foundPath = true
                break
            end
        end

        if foundPath == false then
            for s, w in pairs(dirs01) do
                local currentPath01 = currentPath .. w .. "/"
                local files01, _ = file.Find(currentPath01 .. "*", "DATA", "datedesc")

                for _, afile in pairs(files01) do
                    if afile == filename then
                        pathToFile = currentPath01 .. filename
                        foundPath = true
                        break
                    end
                end
            end
        end

        if foundPath then break end
    end

    local pyrodata
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

    if pathToFile then
        if file.Exists(pathToFile, "DATA") then
            pyrodata = file.Read(pathToFile, "DATA")
            pyrodata = util.JSONToTable(pyrodata)
        else
            ent:FireWorkInvalid(ply)

            return
        end
    else
        ent:FireWorkInvalid(ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c752326f6d83fa5a15e6e0926dcb3ad403a307ad14d9b021db3f93fe96e130ff

        return
    end

    if zpc.f.CanSpawnPyro(ply, -1) == false then
        ent:FireWorkLimit(ply)

        return
    end

    if (pyrodata) then
        ent:SetPyroName(pyrodata.name)
        ent:SetModelID(pyrodata.modelID)
        ent:SetPyroCreatedBy(pyrodata.CreatedBy)
        local spyroBoxData = zpc.PyroBox[pyrodata.modelID]
        ent:SetModel(spyroBoxData.model)
        ent:PhysicsInit(SOLID_VPHYSICS)
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent:SetSolid(SOLID_VPHYSICS)
        ent:SetUseType(SIMPLE_USE)
        ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        local phys = ent:GetPhysicsObject()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

        if IsValid(ent) then
            phys:Wake()
            phys:EnableMotion(true)
        end

        if spyroBoxData.isrocket then
            local strings = string.Split(pyrodata.filename, "_")
            strings = string.Split(strings[2], ".")
            local id = strings[1]
            math.randomseed(id)
            ent:SetSkin(math.random(1, 3))
        end

        local seq = pyrodata.EffectSequence
        ent.EffectSequence = {}

        for k, v in pairs(seq) do
            local effectData = zpc.f.CatchEffectByNumID(v[1])

            table.insert(ent.EffectSequence, {
                EffectID = v[1],
                EffectName = effectData.effect,
                TriggerTime = v[2],
                AttachID = v[3],
                duration = effectData.duration,
                EffectType = effectData.effecttype,
                SFX = effectData.sfx,
                GotFired = false,
                ZForce = effectData.zforce
            })
        end
    end
end

zvm.Definition.Add("zpc_battery", {
	OnItemDataCatch = function(data, ent)
		data.pyro_file = ent:GetPyroFileName()
	end,
	OnItemDataApply = function(data, ent)
		ent:SetPyroFileName(data.pyro_file)
	end,
	OnItemDataName = function(data, ent) return ent:GetPyroName() or "" end,
	ItemExists = function(compared_item, data) return true, compared_item.extraData.pyro_file == data.pyro_file end,
	BlockItemCheck = function(other, Machine)
		if other:GetPyroIgnited() or other:GetPyroDone() then return true end
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		zpc.f.SetOwner(ent, ply)
		FireworkSetup(ent, ply)
	end,
})
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978

zvm.Definition.Add("zpc_pyrostage", {
	BlockItemCheck = function(other, Machine)
		if other:GetIsPlaying() then return true end
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		zpc.f.SetOwner(ent, ply)
		ent:SetAssignedPlayer(ply:SteamID())
		ent:SetMusicID(zpc.MusicList[ 1 ].id)
		ent:SetPyroShowDuration(zpc.MusicList[ 1 ].duration)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa

		if ply:HasWeapon("zpc_pyrolinker") then
			ply:GetWeapon("zpc_pyrolinker"):SetShowTable(ent)
		end
	end,
})

zvm.Definition.Add("zpc_pyroworkbench", {
	BlockItemCheck = function(other, Machine)
		if other:GetInUse() then return true end
	end,
	OnPackageItemSpawned = function(data, ent, ply)
		zpc.f.SetOwner(ent, ply)
	end,
})
