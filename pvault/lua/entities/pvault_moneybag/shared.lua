ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Moneybag"
ENT.Author = "Owain Owjo & The One Free-Man"
ENT.Category = "pVault"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Value")
end
