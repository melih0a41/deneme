function Corporate_Takeover:GetDesk(class)
	local exists = self:DeskExists(class)
	if(exists) then
		return Corporate_Takeover.Desks[class]
	end

	return false
end

function Corporate_Takeover:DeskExists(class)
	local desk = Corporate_Takeover.Desks[class]
	if(desk) then
		return true
	end

	return false
end

function Corporate_Takeover:GetDeskCount(bpclass, class, ply)
	local amount = 0
	for k, v in ipairs(ents.FindByClass(bpclass)) do
		local ent_class = v:GetDeskClass()
		if(ent_class == class && v:Getowning_ent() == ply) then
			amount = amount + 1
		end
	end
	return amount
end

function Corporate_Takeover:GetDeskBuilderCount(ply)
	local amount = 0
	for k, v in ipairs(ents.FindByClass("deskbuilder_base")) do
		local owner = v:Getowning_ent()
		if(owner == ply) then
			amount = amount + 1
		end
	end
	return amount
end

function Corporate_Takeover:addResearchOption(name, data)
	if(name == "demo") then return false end
	Corporate_Takeover.Researches[name] = {
		class = name,
		name = Corporate_Takeover:Lang(name),
		description = Corporate_Takeover:Lang(name.."_desc")
	}

	for k, v in pairs(data) do
		Corporate_Takeover.Researches[name][k] = v
	end

	if(!Corporate_Takeover.Researches[name].buyable) then
		Corporate_Takeover.Researches[name].buyable = false
	end
end

function Corporate_Takeover:addDesk(name, data)
	if(name == "demo") then return false end
	if(Corporate_Takeover.Desks[name]) then
		print("CTO ERROR: Desk with name '"..name.."' already exists! Skipping...")
		return false
	end

	Corporate_Takeover.Desks[name] = {
		deskclass = name
	}

	for k, v in pairs(data) do
		Corporate_Takeover.Desks[name][k] = v
	end

	if(!Corporate_Takeover.Desks[name].buyable) then
		Corporate_Takeover.Desks[name].buyable = false
	end
end