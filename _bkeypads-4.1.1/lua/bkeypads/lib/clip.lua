AddCSLuaFile()
if SERVER then return end

local render = render
local Vector = Vector
local STENCIL_ALWAYS = STENCIL_ALWAYS
local STENCIL_KEEP = STENCIL_KEEP
local STENCIL_REPLACE = STENCIL_REPLACE
local STENCIL_EQUAL = STENCIL_EQUAL
local MATERIAL_CULLMODE_CW = MATERIAL_CULLMODE_CW
local MATERIAL_CULLMODE_CCW = MATERIAL_CULLMODE_CCW

local transparent = Color(0, 0, 0, 0)
local clipping = false

local clip = {}
setmetatable(clip, {
	__call = function()
		if clipping then
			clipping = false
			render.SetStencilEnable(false)
			return true
		end
		return false
	end
})
setfenv(1, clip)

local stencil do
local stenciling = false
function stencil()
	if stenciling then
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		stenciling = false
		return
	end

	render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()

	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)

	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)

	stenciling = true
end end

do
	local vert1, vert2, vert3, vert4 = Vector(), Vector(), Vector(), Vector()
	function clip:Scissor2D(w, h, x, y, z)
		if clip() then return end

			vert1:SetUnpacked(
				x or 0,
				y or 0,
				z or 0
			)

			vert2:SetUnpacked(
				x or 0,
				h + (y or 0),
				z or 0
			)

			vert3:SetUnpacked(
				w + (x or 0),
				h + (y or 0),
				z or 0
			)

			vert4:SetUnpacked(
				w + (x or 0),
				y or 0,
				z or 0
			)

		stencil()

			render.CullMode(MATERIAL_CULLMODE_CW)
				render.SetColorMaterial()
				render.DrawQuad(vert1, vert2, vert3, vert4, transparent)
			render.CullMode(MATERIAL_CULLMODE_CCW)

		stencil()

		clipping = true
	end
end

do
	function clip:Scissor3D(pos, ang, mins, maxs)
		if clip() then return end

		stencil()

			render.SetColorMaterial()
			render.DrawBox(pos, ang, mins, maxs, transparent, true)

		stencil()

		clipping = true
	end
end

return clip