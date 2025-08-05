-- lua/entities/savav_LCD/init.lua
-- OPTIMIZED VERSION

AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
    self:SetModel("models/props_lab/jar01b.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetName("savav_LCD")
    self:SetPos(self:GetPos() + Vector(0, 0, self:OBBMaxs().z))
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then 
        phys:Wake()
    end
    
    -- Entity oluşturulma zamanı (limit kontrolü için)
    self.CreationTime = CurTime()
end

function ENT:GetCreationTime()
    return self.CreationTime or 0
end

function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end
    
    -- Oyuncunun zaten drug etkisi altında olup olmadığını kontrol et
    local currentDrug = caller:GetNWFloat("drug")
    if currentDrug and currentDrug ~= "0" and currentDrug ~= "" then
        caller:ChatPrint("Zaten bir uyuşturucu etkisi altındasınız!")
        return
    end
    
    -- Drug efektini başlat
    caller:SetNWFloat("drug", "savav_LCD")
    
    -- Net mesaj gönder (usermessage yerine)
    net.Start("DrugEffect")
    net.WriteString("savav_LCD")
    net.Send(caller)
    
    -- Timer oluştur
    local timerName = caller:Name() .. "_DrugTimer"
    
    -- Eski timer'ı temizle (güvenlik için)
    timer.Remove(timerName)
    
    timer.Create(timerName, 110, 1, function()
        if IsValid(caller) then
            caller:SetNWFloat("drug", "0")
            
            -- Client'a temizleme mesajı
            net.Start("DrugCleanup")
            net.Send(caller)
        end
    end)
    
    -- Entity'yi kaldır
    self:Remove()
end

-- AcceptInput yerine Use kullanıyoruz (daha optimize)
function ENT:AcceptInput(Name, Activator, Caller)
    if Name == "Use" and IsValid(Caller) and Caller:IsPlayer() then
        self:Use(Activator, Caller)
    end
end

-- Cleanup
function ENT:OnRemove()
    -- Entity kaldırıldığında yapılacak temizlik işlemleri
end

-- Entity hasar aldığında
function ENT:OnTakeDamage(dmg)
    -- Hasar alınca kırılabilir yapabilirsiniz
    self:TakePhysicsDamage(dmg)
    
    -- Belirli bir hasar sonrası kırılsın
    if not self.Health then
        self.Health = 50
    end
    
    self.Health = self.Health - dmg:GetDamage()
    
    if self.Health <= 0 then
        -- Kırılma efekti
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("GlassImpact", effectdata)
        
        self:Remove()
    end
end

-- Optimize edilmiş Think (gerekirse)
function ENT:Think()
    -- Think kullanmıyoruz, performans için
    -- Gerekirse NextThink kullanın:
    -- self:NextThink(CurTime() + 1)
    -- return true
end