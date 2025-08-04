AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Maymuncuk"
    SWEP.Slot = 5
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Author = "Brickwall (Düzenlendi)"
SWEP.Category = "DarkRP SWEP Replacements" -- Kategori adını isteğe göre değiştirebilirsiniz
SWEP.Instructions = "Sol/Sağ tık ile kapıyı açmaya başla!" -- Talimat güncellendi

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/sterling/c_enhanced_lockpicks.mdl" )
SWEP.WorldModel = ( "models/sterling/w_enhanced_lockpicks.mdl" )
SWEP.ViewModelFOV = 85
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Base = "weapon_base"

local jobLockpickTimes = {
    ["Hırsız"] = 5,
    ["Profesyonel Hırsız"] = 2.5,
}

local rankLockpickTimes = {
    ["vip"] = 5,
    ["admin+"] = 5,
    ["admin"] = 5,
    ["moderator+"] = 5,
    ["moderator"] = 5,
    ["basadmin"] = 5,
    ["viprehber"] = 5,
    ["superadmin"] = 5,
}
local defaultLockpickTime = 10

function SWEP:Initialize()
    self:SetWeaponHoldType( "pistol" )
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsLockpicking")
    self:NetworkVar("Float", 0, "LockpickStartTime")
    self:NetworkVar("Float", 1, "LockpickEndTime")
    self:NetworkVar("Float", 2, "NextSoundTime")
    self:NetworkVar("Float", 3, "LockpickDuration")
    self:NetworkVar("Entity", 0, "LockpickEnt")
end

function SWEP:PrimaryAttack()
    local function RunAnimation()
        if IsValid(self) and self.Owner and self.Owner:IsValid() then
            if type(self.Owner.GetViewModel) ~= "function" then
                return
            end

            local VModel = self.Owner:GetViewModel()
            if IsValid(VModel) then
                local EnumToSeq = VModel:SelectWeightedSequence( ACT_VM_PRIMARYATTACK )
                VModel:SendViewModelMatchingSequence( EnumToSeq )
            end
        end
    end

    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:SetNextSecondaryFire(CurTime() + 0.5)

    if self:GetIsLockpicking() then
        return
    end

    if not IsValid(self:GetOwner()) then return end

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)
    local ent = trace.Entity

    if not IsValid(ent) or ent.DarkRPCanLockpick == false then return end

    local currentGamemode = GAMEMODE
    if type(currentGamemode) ~= "table" then currentGamemode = nil end

    local canLockpick = hook.Call("canLockpick", currentGamemode, self:GetOwner(), ent, trace)

    if canLockpick == false then return end

    local gmConfig = GAMEMODE.Config or {}

    if canLockpick ~= true and (
            trace.HitPos:DistToSqr(self:GetOwner():GetShootPos()) > 4000 or
            (not gmConfig.canforcedooropen and ent:getKeysNonOwnable()) or
            (not ent:isDoor() and not ent:IsVehicle() and not string.find(string.lower(ent:GetClass() or ""), "vehicle") and (not gmConfig.lockpickfading or not ent.isFadingDoor))
        ) then
        return
    end

    local determinedTime = hook.Run( "lockpickTime", self.Owner, ent )
    local ply = self:GetOwner()

    if not determinedTime then
        local jobName = ply:getDarkRPVar("job")
        if jobName and jobLockpickTimes[jobName] then
            determinedTime = jobLockpickTimes[jobName]
        else
            local group = ply:GetUserGroup()
            determinedTime = rankLockpickTimes[group] or defaultLockpickTime
        end
    end
    self:SetLockpickDuration( determinedTime )

    self:SetHoldType("pistol")
    self:SetIsLockpicking(true)
    self:SetLockpickEnt(ent)
    self:SetLockpickStartTime(CurTime())
    self:SetLockpickEndTime(CurTime() + self:GetLockpickDuration())

    RunAnimation()

    if IsFirstTimePredicted() then
        hook.Call("lockpickStarted", currentGamemode, self:GetOwner(), ent, trace)
    end

    local onFail = function(targetPly)
        if not IsValid(self) or not IsValid(self:GetOwner()) then return end
        if targetPly == self:GetOwner() then
            hook.Call("onLockpickCompleted", currentGamemode, targetPly, false, self:GetLockpickEnt())
        end
    end

    hook.Add("PlayerDeath", self, function(victim)
        if IsValid(self) and self.Owner and victim == self.Owner then
            onFail(victim)
        end
    end)

    hook.Add("PlayerDisconnected", self, function(disconnectedPly)
        if IsValid(self) and self.Owner and disconnectedPly == self.Owner then
            onFail(disconnectedPly)
        end
    end)

    hook.Add("onLockpickCompleted", self, function(completedPly, success, completedEnt)
        if IsValid(self) and self.Owner and completedPly == self.Owner then
            hook.Remove("PlayerDeath", self)
            hook.Remove("PlayerDisconnected", self)
            hook.Remove("onLockpickCompleted", self)
        end
    end)
end

function SWEP:Holster()
    if self:GetIsLockpicking() then
        self:Fail()
    end
    self:SetIsLockpicking(false)
    self:SetLockpickEnt(nil)
    return true
end

function SWEP:Succeed()
    self:SetHoldType("normal")
    local ent = self:GetLockpickEnt()
    self:SetIsLockpicking(false)

    if not IsValid(ent) then
        self:SetLockpickEnt(nil)
        return
    end

    local override = hook.Call("onLockpickCompleted", GAMEMODE, self:GetOwner(), true, ent)
    self:SetLockpickEnt(nil)

    if override then return end

    if ent.isFadingDoor and ent.fadeActivate and not ent.fadeActive then
        ent:fadeActivate()
        if IsFirstTimePredicted() then timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end) end
    elseif ent.Fire then
        ent:keysUnLock()
        ent:Fire("open", "", .6)
        ent:Fire("setanimation", "open", .6)
    end

    if IsValid(self.Weapon) then
        self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
    end
end

function SWEP:Fail()
    self:SetHoldType("normal")
    local ent = self:GetLockpickEnt()
    self:SetIsLockpicking(false)
    hook.Call("onLockpickCompleted", GAMEMODE, self:GetOwner(), false, ent)
    self:SetLockpickEnt(nil)

    if IsValid(self.Weapon) then
        self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
    end
end

function SWEP:Think()
    if not self:GetIsLockpicking() or self:GetLockpickEndTime() == 0 or not IsValid(self:GetOwner()) then return end

    if CurTime() >= self:GetNextSoundTime() then
        self:SetNextSoundTime(CurTime() + 1)
        local sounds = {
            "weapons/357/357_reload1.wav",
            "weapons/357/357_reload3.wav",
            "weapons/357/357_reload4.wav"
        }
        self:EmitSound(sounds[math.random(1, #sounds)], 50, 100)
    end

    local trace = self:GetOwner():GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity ~= self:GetLockpickEnt() or trace.HitPos:DistToSqr(self:GetOwner():GetShootPos()) > 4000 then
        self:Fail()
    elseif self:GetLockpickEndTime() <= CurTime() then
        self:Succeed()
    end
end

if CLIENT then
    -- Bu değişkenler bir kez hesaplanır. Ekran çözünürlüğü değişirse güncellenmez.
    -- Daha dinamik bir yapı için önceki cevabımdaki UpdateHUDLayout ve hookları kullanabilirsiniz.
    local w = ScrW()
    local h = ScrH()
    local barHeight = h / 25
    local barWidth = w / 5
    local x = w / 2 - barWidth / 2
    local y = (h / 4) * 3 - barHeight / 2
    local padding = 4

    -- Metin için font ve renkler
    local hudFont = "DermaDefaultBold" -- İstediğiniz bir fontla değiştirebilirsiniz
    local textColor = Color(255, 255, 255, 255) -- Beyaz renk
    local textOutlineColor = Color(0, 0, 0, 220) -- Metin dış çizgisi için koyu renk

    function SWEP:DrawHUD()
        if not self:GetIsLockpicking() or self:GetLockpickEndTime() == 0 or self:GetLockpickStartTime() == 0 or not IsValid(self:GetOwner()) then return end

        local lockpickDuration = self:GetLockpickDuration()
        if lockpickDuration <= 0 then lockpickDuration = 0.01 end

        local timeElapsed = CurTime() - self:GetLockpickStartTime()
        local status = math.Clamp(timeElapsed / lockpickDuration, 0, 1)

        -- Dış çerçeve
        surface.SetDrawColor( Color(40, 40, 40, 200) )
        surface.DrawRect( x, y, barWidth, barHeight )

        -- İç arka plan
        surface.SetDrawColor( Color(70, 70, 70, 200) )
        surface.DrawRect( x + padding, y + padding, barWidth - padding * 2, barHeight - padding * 2 )

        -- İlerleme barı (Yeşilden kırmızıya doğru dolar)
        local currentBarWidth = status * (barWidth - padding * 2)
        surface.SetDrawColor( HSVToColor(120 * (1 - status), 1, 1) )
        surface.DrawRect( x + padding, y + padding, currentBarWidth, barHeight - padding * 2 )

        -- Kalan Süre Metni
        local remainingTime = math.max(0, self:GetLockpickEndTime() - CurTime())
        local timeText = string.format("%.1fs", remainingTime) -- Sadece saniye, örn: "7.3s"

        -- Metnin pozisyonunu barın ortasına ayarla
        local textPosX = x + barWidth / 2
        local textPosY = y + barHeight / 2

        -- Metni çiz
        surface.SetFont(hudFont)
        local tw, th = surface.GetTextSize(timeText) -- Metin boyutunu al

        -- Dış çizgi (daha iyi okunabilirlik için)
        surface.SetTextColor(textOutlineColor)
        -- Dış çizgi için metni 4 ana yöne 1 piksel kaydırarak çiz
        surface.SetTextPos(textPosX - (tw / 2) - 1, textPosY - (th / 2) - 1)
        surface.DrawText(timeText)
        surface.SetTextPos(textPosX - (tw / 2) + 1, textPosY - (th / 2) - 1)
        surface.DrawText(timeText)
        surface.SetTextPos(textPosX - (tw / 2) - 1, textPosY - (th / 2) + 1)
        surface.DrawText(timeText)
        surface.SetTextPos(textPosX - (tw / 2) + 1, textPosY - (th / 2) + 1)
        surface.DrawText(timeText)
        -- İsteğe bağlı olarak çapraz yönlere de eklenebilir (toplam 8 gölge)
        -- surface.SetTextPos(textPosX - (tw / 2) - 1, textPosY - (th / 2)) surface.DrawText(timeText)
        -- surface.SetTextPos(textPosX - (tw / 2) + 1, textPosY - (th / 2)) surface.DrawText(timeText)
        -- surface.SetTextPos(textPosX - (tw / 2), textPosY - (th / 2) - 1) surface.DrawText(timeText)
        -- surface.SetTextPos(textPosX - (tw / 2), textPosY - (th / 2) + 1) surface.DrawText(timeText)

        -- Ana metin (beyaz renkte)
        surface.SetTextColor(textColor)
        surface.SetTextPos(textPosX - (tw / 2), textPosY - (th / 2))
        surface.DrawText(timeText)
    end
end

function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end