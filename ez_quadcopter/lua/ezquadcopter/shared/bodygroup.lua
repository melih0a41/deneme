-- Returns a string of all the bodygroups of an entity
function easzy.quadcopter.GetBodygroupsString(entity)
    local bodygroupsString = ""

    for i = 0, entity:GetNumBodyGroups() - 1 do
        local bodygroup = entity:GetBodygroup(i)
        bodygroupsString = bodygroupsString .. bodygroup
    end

    return bodygroupsString
end

-- Returns the integer value of a bodygroup by its name
function easzy.quadcopter.FindBodygroupValueByValueName(entity, bodygroup, valueName)
    -- Because blank is not written int the bodygroup table
    local bodygroupTable = entity:GetBodyGroups()[bodygroup + 1]

    for value = 0, entity:GetBodygroupCount(bodygroup) - 1 do
        local name = bodygroupTable.submodels[value]
        name = (name == "" and "blank" or name)

        if name == valueName then return value end
    end

    return -1
end

-- Set a bodygroup of an entity by its name
function easzy.quadcopter.SetBodygroupByName(entity, bodygroupName, valueName)
    local bodygroup = entity:FindBodygroupByName(bodygroupName)
    if bodygroup == -1 then return end

    if valueName == "" then
        entity:SetBodygroup(bodygroup, 0)
        return
    end

    local value = easzy.quadcopter.FindBodygroupValueByValueName(entity, bodygroup, valueName)
    if value == -1 then return end

    entity:SetBodygroup(bodygroup, value)
end

-- Set many bodygroups of an entity by their names
function easzy.quadcopter.SetBodygroupsByNames(entity, bodygroupsList)
    if not IsValid(entity) then return end

    for bodygroupName, valueName in pairs(bodygroupsList) do
        easzy.quadcopter.SetBodygroupByName(entity, bodygroupName, valueName)
    end
end
