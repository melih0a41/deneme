AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')

util.AddNetworkString("dex_glass_update_names")
util.AddNetworkString("dex_no_blood")

function SWEP:Initialize()
    self:SetHoldType("pistol")
    if SERVER then
        self.StoredNames = {}
        self.SelectedIndex = 1
    end
end

function SWEP:UpdateNetwork()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    net.Start("dex_glass_update_names")
        net.WriteUInt(#self.StoredNames, 8)
        net.WriteUInt(self.SelectedIndex or 1, 8)
        net.WriteString(self.StoredNames[self.SelectedIndex] or DEX_LANG.Get("unknown"))
    net.Send(owner)
end

function SWEP:AddGlassName(name)
    self.StoredNames = self.StoredNames or {}
    table.insert(self.StoredNames, name)
    self.SelectedIndex = #self.StoredNames
    self:UpdateNetwork()
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if not self.StoredNames or #self.StoredNames == 0 then
        net.Start("dex_no_blood")
        net.Send(owner)
        return
    end

    self.SelectedIndex = math.Clamp(self.SelectedIndex or 1, 1, #self.StoredNames)
    local storedName = table.remove(self.StoredNames, self.SelectedIndex)

    local ent = ents.Create("dex_glass")
    if not IsValid(ent) then return end

    local pos = owner:GetShootPos() + owner:GetAimVector() * 40
    ent:SetPos(pos)
    ent:SetAngles(AngleRand())
    ent:Spawn()

    ent.GlassName = storedName

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(owner:GetAimVector() * 150)
    end

    if self.SelectedIndex > #self.StoredNames then
        self.SelectedIndex = #self.StoredNames
    end
    if self.SelectedIndex < 1 then
        self.SelectedIndex = 1
    end

    self:UpdateNetwork()

    if #self.StoredNames == 0 then
        owner:StripWeapon(self:GetClass())
    end

    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
    if not SERVER then return end
    if not self.StoredNames or #self.StoredNames == 0 then return end

    self.SelectedIndex = (self.SelectedIndex or 1) + 1
    if self.SelectedIndex > #self.StoredNames then
        self.SelectedIndex = 1
    end

    self:UpdateNetwork()

    self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    local vm = IsValid(owner) and owner:GetViewModel()
    if IsValid(vm) then
        vm:ResetSequence(0)
        vm:SetPlaybackRate(1)
    end

    if SERVER then
        timer.Simple(0, function()
            if IsValid(self) then
                self:UpdateNetwork()
            end
        end)
        timer.Simple(0.5, function()
            if IsValid(self) then
                self:UpdateNetwork()
            end
        end)
    end
end