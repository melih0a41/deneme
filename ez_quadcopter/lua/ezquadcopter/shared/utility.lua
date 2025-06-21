-- Get the distance between the given entities
function easzy.quadcopter.GetDistance(ent1, ent2)
	return ent1:GetPos():DistToSqr(ent2:GetPos())
end

-- Verify if the given entities are in the given distance
function easzy.quadcopter.GetInDistance(ent1, ent2, distance)
	return easzy.quadcopter.GetDistance(ent1, ent2) < distance^2
end

-- Format currency
function easzy.quadcopter.FormatCurrency(amount)
	local amountString
	if GAMEMODE.Config.currency == "€" then
		amountString = tostring(amount) .. " " .. GAMEMODE.Config.currency
	else
		amountString = GAMEMODE.Config.currency .. tostring(amount)
	end
	return amountString
end

-- Change SubMaterial color
function easzy.quadcopter.ChangeSubMaterialColor(entity, subMaterialIndex, partName, color)
	if not color then
		entity:SetSubMaterial(subMaterialIndex - 1, "")
		if entity.colors then
			entity.colors[partName] = nil
		end
		return
	end

	local entIndex = entity:EntIndex()

	-- Texture
	local newTextureName = "ez_quadcopter_color_texture" .. entIndex .. subMaterialIndex
	local newTexture = GetRenderTarget(newTextureName, 32, 32)
	render.PushRenderTarget(newTexture)
		local r, g, b = color:Unpack()
		render.Clear(r, g, b, 255, true)
	render.PopRenderTarget()

	-- Material
	local newMaterialName = "ez_quadcopter_color_material" .. entIndex .. subMaterialIndex
	local newMaterial = CreateMaterial(newMaterialName, "VertexLitGeneric")
	newMaterial:SetTexture("$basetexture", newTexture)

	entity:SetSubMaterial(subMaterialIndex - 1, "!" .. newMaterialName)

	if entity.colors then
		entity.colors[partName] = color
	end
end

-- Reset SubMaterial color
function easzy.quadcopter.ResetSubMaterialColor(quadcopter, quadcopterView, subMaterialIndex, partName)
	local oldColor = quadcopter.colors[partName]
	easzy.quadcopter.ChangeSubMaterialColor(quadcopterView, subMaterialIndex, partName, oldColor)
end

local function IsRadioController(weapon)
    if not IsValid(weapon) then return false end

    local class = weapon:GetClass()
    return class == "ez_quadcopter_fpv_radio_controller" or class == "ez_quadcopter_dji_radio_controller"
end

function easzy.quadcopter.IsHoldingRadioController(ply)
    local radioController = ply:GetActiveWeapon()
    if not radioController then return end

    return IsRadioController(radioController)
end

function easzy.quadcopter.GetRadioController(quadcopter)
    local owner = quadcopter:CPPIGetOwner() or Player(quadcopter.SID)
    if not IsValid(owner) then return end

    if not easzy.quadcopter.IsHoldingRadioController(owner) then return end
	return owner:GetActiveWeapon()
end

function easzy.quadcopter.GetQuadcopter(ply)
    if not easzy.quadcopter.IsHoldingRadioController(ply) then return end

    local radioController = ply:GetActiveWeapon()

	return radioController.quadcopter
end

if CLIENT then
	function easzy.quadcopter.RespX(px)
		local respX = math.ceil((px/1920) * ScrW(), 0)
		return respX
	end

	function easzy.quadcopter.RespY(px)
		local respY = math.ceil((px/1080) * ScrH(), 0)
		return respY
	end

	function easzy.quadcopter.GetTextSize(text, font)
		surface.SetFont(font)
		local w, h = surface.GetTextSize(text)
		w = w + easzy.quadcopter.RespX(20)
		h = h + easzy.quadcopter.RespY(10)

		return w, h
	end

	function easzy.quadcopter.Notify(_, text, length, type)
		notification.AddLegacy(text, type or 1, length)
	end

	net.Receive("ezquadcopter_quadcopter_notify", function(_, ply)
		local text = net.ReadString()
		local len = net.ReadUInt(8)
		local type = net.ReadUInt(8)
		easzy.quadcopter.Notify(nil, text, len, type)
	end)
end

if SERVER then
	function easzy.quadcopter.Pay(ply, amount)
		if not ply:canAfford(amount) then
			return false
		end

		ply:addMoney(-amount)

		return true
	end

	util.AddNetworkString("ezquadcopter_quadcopter_notify")

	function easzy.quadcopter.Notify(ply, text, length, type)
		net.Start("ezquadcopter_quadcopter_notify")
		net.WriteString(text)
		net.WriteUInt(length, 8)
		net.WriteUInt(type, 8)
		net.Send(ply)
	end
end
