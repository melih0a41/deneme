-- PropHP AR2 Prop Kırma Silahı
-- Dosya Yolu: addons/partysystem/lua/prophp_weapons/weapon_prophp_ar2.lua
-- NOT: Bu dosya otomatik yüklenecek

SWEP.PrintName = "Prop Kırma AR2"
SWEP.Author = "PropHP System"
SWEP.Instructions = "Sol tık: Prop'lara hasar ver (Sadece raid'de)"
SWEP.Category = "PropHP Raid"

SWEP.Spawnable = true
SWEP.AdminOnly = false

-- Silah modeli
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.UseHands = true
SWEP.HoldType = "ar2"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

-- Özel değişkenler
SWEP.PropDamage = 50
SWEP.MaxRange = 500
SWEP.BeamColor = Color(100, 150, 255, 255)

-- Client değişkenleri
if CLIENT then
    SWEP.BeamMaterial = Material("cable/blue_elec")
    SWEP.BeamPositions = {}
    SWEP.NextBeamTime = 0
    SWEP.LastSoundTime = 0
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.NextEffectTime = 0
    self.NextWarnTime = 0
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
    
    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) and owner:IsPlayer() then
            -- Raid kontrolü yap
            local inRaid = false
            if PropHP and PropHP.IsPlayerInAnyRaid then
                inRaid = PropHP.IsPlayerInAnyRaid(owner)
            end
            
            if not inRaid then
                owner:ChatPrint("[!] Bu silah sadece raid sırasında çalışır!")
            else
                owner:ChatPrint("[✓] Prop Kırma AR2 aktif - Prop'lara nişan alın!")
            end
        end
    end
    
    return true
end

function SWEP:CanDamageProp(trace)
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return false, "" end
    
    -- Hedef prop mu?
    if not IsValid(trace.Entity) or trace.Entity:GetClass() != "prop_physics" then
        return false, "Hedef prop değil"
    end
    
    -- Mesafe kontrolü
    if trace.HitPos:Distance(owner:GetShootPos()) > self.MaxRange then
        return false, "Çok uzak"
    end
    
    -- Prop'un partisi kontrolü
    local targetParty = trace.Entity:GetNWString("PropOwnerParty", "")
    if targetParty == "" then
        return false, "Partisiz prop"
    end
    
    -- Oyuncunun partisi
    local ownerParty = owner:GetParty and owner:GetParty() or nil
    if not ownerParty then
        return false, "Partiniz yok"
    end
    
    -- Kendi partisi kontrolü
    if targetParty == ownerParty then
        return false, "Kendi partiniz"
    end
    
    -- RAID KONTROLÜ
    if SERVER then
        if PropHP and PropHP.IsPlayerInAnyRaid then
            local inRaid, raidID = PropHP.IsPlayerInAnyRaid(owner)
            
            if not inRaid then
                return false, "Raid'de değilsiniz"
            end
            
            -- Hazırlık kontrolü
            if PropHP.ActiveRaids and PropHP.ActiveRaids[raidID] then
                if PropHP.ActiveRaids[raidID].preparation then
                    return false, "Hazırlık aşaması"
                end
            end
            
            -- NLR kontrolü
            if PropHP.IsPlayerNLR and PropHP.IsPlayerNLR(owner) then
                return false, "NLR kuralı"
            end
        else
            return false, "Raid sistemi yok"
        end
    end
    
    return true, "OK"
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local trace = owner:GetEyeTrace()
    local canDamage, reason = self:CanDamageProp(trace)
    
    if not canDamage then
        -- Hata bildirimi
        if CLIENT then
            if CurTime() > (self.LastSoundTime or 0) + 0.5 then
                surface.PlaySound("buttons/button10.wav")
                self.LastSoundTime = CurTime()
            end
        end
        
        self:SetNextPrimaryFire(CurTime() + 0.5)
        return
    end
    
    -- SERVER: Hasar ver
    if SERVER then
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(self.PropDamage)
        dmginfo:SetAttacker(owner)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageType(DMG_SHOCK)
        
        trace.Entity:TakeDamageInfo(dmginfo)
        
        -- Spark efekti
        local effectdata = EffectData()
        effectdata:SetOrigin(trace.HitPos)
        effectdata:SetNormal(trace.HitNormal)
        effectdata:SetMagnitude(2)
        effectdata:SetScale(1)
        effectdata:SetRadius(2)
        util.Effect("Sparks", effectdata)
    end
    
    -- CLIENT: Efektler
    if CLIENT then
        self:DoClientEffects(trace)
    end
    
    -- Animasyon
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    
    -- Geri tepme
    if owner:IsPlayer() then
        local angles = owner:EyeAngles()
        angles.p = angles.p - 0.3
        angles.y = angles.y + math.Rand(-0.1, 0.1)
        owner:SetEyeAngles(angles)
    end
    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    -- Sağ tık yok
end

function SWEP:Reload()
    -- Reload yok
end

-- CLIENT TARAFI
if CLIENT then
    function SWEP:DoClientEffects(trace)
        -- Elektrik sesi
        if CurTime() > (self.LastSoundTime or 0) + 0.1 then
            local sounds = {
                "ambient/energy/spark1.wav",
                "ambient/energy/spark2.wav",
                "ambient/energy/spark3.wav",
                "ambient/energy/spark4.wav",
                "ambient/energy/spark5.wav",
                "ambient/energy/spark6.wav",
                "ambient/energy/zap1.wav",
                "ambient/energy/zap2.wav",
                "ambient/energy/zap3.wav"
            }
            surface.PlaySound(sounds[math.random(#sounds)])
            self.LastSoundTime = CurTime()
        end
        
        -- Işın efekti için veri sakla
        if not self.BeamPositions then self.BeamPositions = {} end
        
        local attachment = self:GetAttachment(1)
        local startPos = attachment and attachment.Pos or self:GetOwner():GetShootPos()
        
        table.insert(self.BeamPositions, {
            startPos = startPos,
            endPos = trace.HitPos,
            dieTime = CurTime() + 0.1,
            alpha = 255
        })
        
        -- Eski ışınları temizle
        for i = #self.BeamPositions, 1, -1 do
            if self.BeamPositions[i].dieTime < CurTime() then
                table.remove(self.BeamPositions, i)
            end
        end
    end
    
    function SWEP:ViewModelDrawn()
        if not self.BeamPositions then return end
        
        -- Işınları çiz
        render.SetMaterial(self.BeamMaterial)
        
        for _, beam in ipairs(self.BeamPositions) do
            local alpha = beam.alpha * ((beam.dieTime - CurTime()) / 0.1)
            
            if alpha > 0 then
                -- Ana ışın
                render.DrawBeam(
                    beam.startPos,
                    beam.endPos,
                    math.random(3, 6),
                    0,
                    1,
                    Color(100, 150, 255, alpha)
                )
                
                -- İnce beyaz ışın
                render.DrawBeam(
                    beam.startPos,
                    beam.endPos,
                    math.random(1, 2),
                    0,
                    1,
                    Color(255, 255, 255, alpha * 0.5)
                )
            end
        end
    end
    
    function SWEP:DrawHUD()
        local trace = LocalPlayer():GetEyeTrace()
        local x, y = ScrW() / 2, ScrH() / 2
        
        -- Crosshair
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawLine(x - 10, y, x - 5, y)
        surface.DrawLine(x + 5, y, x + 10, y)
        surface.DrawLine(x, y - 10, x, y - 5)
        surface.DrawLine(x, y + 5, x, y + 10)
        
        -- Prop hedef bilgisi
        if IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_physics" then
            local canDamage, reason = self:CanDamageProp(trace)
            
            y = y + 50
            
            if canDamage then
                -- Yeşil hedef
                surface.SetDrawColor(0, 255, 0, 150)
                surface.DrawOutlinedRect(x - 25, y - 25, 50, 50)
                
                draw.SimpleText("HEDEF KİLİTLİ", "DermaDefault", x, y + 35, Color(0, 255, 0), TEXT_ALIGN_CENTER)
                
                -- HP bilgisi
                local hp = trace.Entity:GetNWInt("PropHP", 0)
                local maxHP = trace.Entity:GetNWInt("PropMaxHP", 0)
                if maxHP > 0 then
                    local percent = math.Round(hp / maxHP * 100)
                    draw.SimpleText("HP: " .. hp .. "/" .. maxHP .. " (" .. percent .. "%)", 
                        "DermaDefault", x, y + 50, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                end
            else
                -- Kırmızı hedef
                surface.SetDrawColor(255, 0, 0, 150)
                surface.DrawOutlinedRect(x - 25, y - 25, 50, 50)
                
                if reason != "" then
                    draw.SimpleText(reason, "DermaDefault", x, y + 35, Color(255, 100, 100), TEXT_ALIGN_CENTER)
                end
            end
        end
    end
end

function SWEP:Think()
    -- Periyodik kontroller
    if SERVER then
        if CurTime() > (self.NextWarnTime or 0) then
            local owner = self:GetOwner()
            if IsValid(owner) and owner:IsPlayer() then
                local inRaid = false
                if PropHP and PropHP.IsPlayerInAnyRaid then
                    inRaid = PropHP.IsPlayerInAnyRaid(owner)
                end
                
                if not inRaid then
                    -- Raid dışında uyarı
                    self.NextWarnTime = CurTime() + 10
                end
            end
        end
    end
end

function SWEP:Holster()
    if CLIENT then
        self.BeamPositions = {}
    end
    return true
end

function SWEP:OnRemove()
    if CLIENT then
        self.BeamPositions = {}
    end
end