local function DrawHover(quadcopter)
    local text = quadcopter.broken and easzy.quadcopter.languages.pressToRepair or easzy.quadcopter.languages.pressToUpgrade

	local localPlayer = LocalPlayer()
	local font = "EZFont40"
    local textWidth, textHeight = easzy.quadcopter.GetTextSize(text, font)

	local pos = quadcopter:GetPos() + Vector(0, 0, 15)
	local ang = Angle(0, localPlayer:EyeAngles().y - 90, 90)

	cam.Start3D2D(pos, ang, 0.1)
		draw.SimpleText(text, font, 0, 0, easzy.quadcopter.colors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

hook.Add("PostDrawOpaqueRenderables", "ezquadcopter_hover_PostDrawOpaqueRenderables", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
    local localPlayer = LocalPlayer()
    local eyeTrace = localPlayer:GetEyeTrace()

    local entity = eyeTrace.Entity

    if not IsValid(entity) then return end
    local class = entity:GetClass()

    if not easzy.quadcopter.quadcoptersData[class] then return end

    if not easzy.quadcopter.GetInDistance(entity, localPlayer, 100) then return end
    local owner = entity:CPPIGetOwner() or entity:GetOwner()
    if owner != localPlayer then return end

    DrawHover(entity)
end)
