ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = DEX_LANG.Get("memorial")
ENT.Category = "Dex's Addons"
ENT.Author = "Odinzz"
ENT.Spawnable = false
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "VictimName")
    self:NetworkVar("String", 1, "VictimModel")
end