function Corporate_Takeover:FormatNumber(number)
	local str = tostring(number)
	if number >= 1000 then
	  str = string.format("%d.%03d", math.floor(number / 1000), number % 1000)
	end

	return str
end

function Corporate_Takeover:CanPlaceDeskHere(ply, prop, builder)
    if (!IsValid(ply) && !ply:Alive() && !IsValid(prop) && !IsValid(builder)) then
        return false
    end

    local pos = prop:GetPos()

    -- Check if any entities are blocking the placement
    local blocked = {
        ["prop_dynamic"] = true,
        ["prop_physics"] = true,
        ["player"] = true,
        ["deskbuilder_base"] = true,
    }
    for _, v in ipairs(ents.FindInSphere(pos, 50)) do
        if blocked[v:GetClass()] then
            return false
        end
    end

    -- Check if the builder is too far away
    if builder:GetPos():DistToSqr(pos) > 200 * 200 then
        return false
    end

    return true
end
