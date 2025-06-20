AddCSLuaFile()

SWEP.ClassName = "weapon_kidnap"
SWEP.PrintName = "Kaçırma Aleti PRO"
SWEP.Author = "Phantaso" -- Yazar güncellendi
SWEP.Instructions = "Bir oyuncuyu ragdoll yapmak için sol tıklayın. Ragdoll'u sürüklemek ve hafifçe önünüze kaldırmak için sağ tıklamayı basılı tutun."
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Phantaso Kidnap"

SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"
SWEP.ViewModel = "models/weapons/v_stunbaton.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.VictimRagdoll = nil
SWEP.Victim = nil
SWEP.Cooldown = false
SWEP.IsDragging = false
SWEP.RagdollFinalPosition = nil

_G.KidnapData = _G.KidnapData or {}

function SWEP:PrimaryAttack()
    if CLIENT then return end
    local ply = self.Owner

    if self.Cooldown then
        ply:ChatPrint("Kaçırma Aleti bekleme süresinde!")
        return
    end

    if IsValid(self.Victim) then
        ply:ChatPrint("Zaten birini kaçırıyorsunuz! (SWEP Referansı)")
        return
    end

    local target = ply:GetEyeTrace().Entity

    if IsValid(target) and target:IsPlayer() and target:Alive() and ply:GetPos():DistToSqr(target:GetPos()) < 10000 then

        -- Kurbanın silahlarını kaydet
        local saved_weapons = {}
        for _, wep in pairs(target:GetWeapons()) do
            table.insert(saved_weapons, wep:GetClass())
        end

        -- Kurbanın silahlarını al
        target:StripWeapons()

        local ragdoll = ents.Create("prop_ragdoll")
        ragdoll:SetPos(target:GetPos() + Vector(0, 0, 10))
        ragdoll:SetModel(target:GetModel())
        ragdoll:SetAngles(target:GetAngles())
        ragdoll:Spawn()
        ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
            local phys = ragdoll:GetPhysicsObjectNum(i)
            if IsValid(phys) then
                phys:Wake()
                phys:SetMass(1)
                phys:EnableGravity(true)
                phys:SetBuoyancyRatio(0.3)
            end
        end

        -- Oyuncu modelini gizle ve kontrolleri devre dışı bırak
        target:Spectate(OBS_MODE_CHASE)
        target:SpectateEntity(ragdoll)
        -- target:StripWeapons() -- Bu satır artık yukarıda ve gerekli

        self.VictimRagdoll = ragdoll
        self.Victim = target
        ply:ChatPrint(target:Nick() .. " adlı oyuncuyu kaçırıp ragdoll yaptınız!")
        target:ChatPrint(ply:Nick() .. " tarafından kaçırıldınız!")

        _G.KidnapData[target] = {
            ragdoll = ragdoll,
            timer = CurTime() + 30, -- Serbest bırakma zamanlayıcısı (saniye) - 30 olarak ayarlandı
            kidnapper = ply,
            ragdoll_pos = ragdoll:GetPos(),
            swep_instance = self,
            weapons = saved_weapons -- Kaydedilen silahları ekle
        }

        self.Cooldown = true
        timer.Simple(180, function() -- SWEP'in tekrar kullanılabilme bekleme süresi (saniye)
            if IsValid(self) then
                self.Cooldown = false
                if IsValid(self.Owner) then
                    self.Owner:ChatPrint("Kaçırma Aleti tekrar kullanıma hazır.")
                end
            end
        end)

    else
        ply:ChatPrint("Menzilde geçerli veya canlı hedef yok.")
    end
end

function SWEP:Think()
    if CLIENT then return end

    -- Eğer kurban bağlantısı koparsa veya ölürse otomatik serbest bırakma
    if IsValid(self.Victim) and (not self.Victim:Alive() or not self.Victim:IsConnected()) then
        if IsValid(self.Owner) then
            self.Owner:ChatPrint(self.Victim:Nick() .. " öldüğü/bağlantısı koptuğu için otomatik olarak serbest bırakıldı.")
        end
        self:ForceReleaseVictim("Bağlantı Koptu/Öldü")
        return
    end

    -- Sadece bu SWEP'e ait bir kurban varsa ve ragdoll geçerliyse sürükle
    if not IsValid(self.Owner) or not IsValid(self.VictimRagdoll) or not IsValid(self.Victim) then
        if self.IsDragging then self.IsDragging = false end
        return
    end

    local ply = self.Owner
    local ragdoll = self.VictimRagdoll
    local phys = ragdoll:GetPhysicsObject()

    if not IsValid(phys) then return end

    -- Sağ tık basılı tutularak sürükleme
    if ply:KeyDown(IN_ATTACK2) then
        if not self.IsDragging then
            self.IsDragging = true
        end

        local targetPos = ply:GetPos() + ply:GetForward() * 60 + Vector(0, 0, 40)
        local ragdollPos = ragdoll:GetPos()
        local horizontalDirection = Vector(targetPos.x - ragdollPos.x, targetPos.y - ragdollPos.y, 0):GetNormalized()
        local horizontalDistance = Vector(targetPos.x - ragdollPos.x, targetPos.y - ragdollPos.y, 0):Length()
        local horizontalForceMagnitude = math.Clamp(horizontalDistance * 30, 0, 1500)
        phys:ApplyForceCenter(horizontalDirection * horizontalForceMagnitude)

        local verticalOffset = targetPos.z - ragdollPos.z
        local verticalForce = math.Clamp(verticalOffset * 40, -1200, 1200)
        phys:ApplyForceCenter(Vector(0, 0, verticalForce))

        phys:SetAngleVelocity(Vector(0,0,0))
    else
        if self.IsDragging then
            self.IsDragging = false
        end
    end
end

function SWEP:ForceReleaseVictim(reason)
    reason = reason or "Bilinmeyen Neden"
    if not IsValid(self.Victim) then
        self.VictimRagdoll = nil
        self.Victim = nil
        return
    end

    local target = self.Victim
    local ragdoll = self.VictimRagdoll
    local owner = self.Owner
    local ragdoll_pos = target:GetPos()
    local saved_weapons = nil -- Silahları tutmak için değişken

    if IsValid(ragdoll) then
        ragdoll_pos = ragdoll:GetPos()
        ragdoll:Remove()
    end

    if _G.KidnapData[target] then
        saved_weapons = _G.KidnapData[target].weapons -- Silahları al
        _G.KidnapData[target] = nil
    end

    if IsValid(target) then
        target:UnSpectate()
        if IsValid(target) then
            target:Spawn()
            if IsValid(target) then
                target:SetHealth(100)
                target:SetPos(ragdoll_pos + Vector(0, 0, 10))
                target:Freeze(false)
                target:SetRenderMode(RENDERMODE_NORMAL)
                target:SetColor(Color(255, 255, 255, 255))
                target:SetModel(target:GetModel())

                -- Silahları geri ver
                if saved_weapons then
                    for _, wepClass in pairs(saved_weapons) do
                        target:Give(wepClass)
                    end
                end

                if IsValid(owner) then
                    owner:ChatPrint(target:Nick() .. " (" .. string.lower(reason) .. ") serbest bırakıldı.")
                end
                target:ChatPrint("Kaçırılmaktan (" .. string.lower(reason) .. ") serbest bırakıldınız.")
            end
        end
    end

    self.VictimRagdoll = nil
    self.Victim = nil
end

function SWEP:OnRemove()
    if IsValid(self.Victim) then
        self:ForceReleaseVictim("SWEP Kaldırıldı")
    end
end

function SWEP:OwnerChanged()
    if IsValid(self.Victim) then
        self:ForceReleaseVictim("Sahip Değişti")
    end
end

--[[---------------------------------------------------------
    HOOKS - Sunucu Tarafı Kontroller
-----------------------------------------------------------]]
if SERVER then

    -- Kurbanın serbest bırakılmasını sürekli kontrol et ve yönet (Zamanlayıcı, Ragdoll durumu)
    hook.Add("Think", "KidnapperThink", function()
        local nextCheck = _G.KidnapperNextCheck or 0
        if CurTime() < nextCheck then return end
        _G.KidnapperNextCheck = CurTime() + 0.5

        local targets_to_check = {}
        if _G.KidnapData then
            for target, _ in pairs(_G.KidnapData) do
                if IsValid(target) then
                    table.insert(targets_to_check, target)
                else
                    _G.KidnapData[target] = nil
                end
            end
        end

        for _, target in ipairs(targets_to_check) do
            if not _G.KidnapData or not _G.KidnapData[target] then continue end

            local data = _G.KidnapData[target]

            if not data or not IsValid(target) then
                if data then _G.KidnapData[target] = nil end
                continue
            end

            local release_reason = nil
            local should_release = false

            if data.timer and CurTime() >= data.timer then
                release_reason = "Zamanlayıcı Bitti"
                should_release = true
            elseif not IsValid(data.ragdoll) then
                release_reason = "Ragdoll Hatası/Kayboldu"
                should_release = true
            end

            if should_release then
                local kidnapper = data.kidnapper
                local ragdoll = data.ragdoll
                local ragdoll_pos = target:GetPos()
                if IsValid(ragdoll) then ragdoll_pos = ragdoll:GetPos() end
                local swep_instance = data.swep_instance
                local saved_weapons = data.weapons -- Silahları al

                _G.KidnapData[target] = nil

                if IsValid(ragdoll) then
                    ragdoll:Remove()
                end

                if IsValid(swep_instance) then
                    swep_instance.Victim = nil
                    swep_instance.VictimRagdoll = nil
                end

                if IsValid(target) then
                    target:UnSpectate()
                    if IsValid(target) then
                        target:Spawn()
                        if IsValid(target) then
                            target:SetPos(ragdoll_pos + Vector(0, 0, 10))
                            target:SetHealth(100)
                            target:SetRenderMode(RENDERMODE_NORMAL)
                            target:SetColor(Color(255, 255, 255, 255))
                            target:SetModel(target:GetModel())
                            target:Freeze(false)

                            -- Silahları geri ver
                            if saved_weapons then
                                for _, wepClass in pairs(saved_weapons) do
                                    target:Give(wepClass)
                                end
                            end

                            if IsValid(kidnapper) then kidnapper:ChatPrint(target:Nick() .. " (" .. string.lower(release_reason) .. ") serbest bırakıldı.") end
                            target:ChatPrint("Kaçırılmaktan (".. string.lower(release_reason) ..") serbest bırakıldınız.")
                        end
                    end
                end
            elseif IsValid(data.ragdoll) then
                data.ragdoll_pos = data.ragdoll:GetPos() -- Pozisyonu güncellemeye devam et
            end
        end
    end)

    -- Oyuncu oyundan çıktığında ragdoll'u sil ve veriyi temizle
    hook.Add("PlayerDisconnected", "KidnapCleanupOnDisconnect", function(ply, reason)
        if _G.KidnapData and _G.KidnapData[ply] then -- Oyuncu kaçırılmış mı kontrol et
            local data = _G.KidnapData[ply]

            -- Ragdoll'u kaldır (geçerliyse)
            if IsValid(data.ragdoll) then
                data.ragdoll:Remove()
            end

            -- Veriyi tablodan sil
            _G.KidnapData[ply] = nil
        end
    end)

end