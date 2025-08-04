AddCSLuaFile()

if( CLIENT ) then
    SWEP.PrintName = "Koçbaşı"
    SWEP.Slot = 5
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "Brickwall"
SWEP.Instructions = "Left click to ram a door."
SWEP.Contact = ""
SWEP.Purpose = "Knock down doors!"

SWEP.ViewModel = Model( "models/sterling/c_enhanced_batteringram.mdl" )
SWEP.WorldModel = ( "models/sterling/w_enhanced_batteringram.mdl" )
SWEP.ViewModelFOV = 85
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP SWEP Replacements"

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

--[[-------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()
    self:SetHoldType("crossbow")
end

function SWEP:SetupDataTables()
    self:NetworkVar( "Int", 0, "BarPercent" )
end

--[[-------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------]]

-- Check whether an object of this player can be rammed
local function canRam(ply)
    return IsValid(ply) and (ply.warranted == true or ply:isWanted() or ply:isArrested())
end

-- <<< RÜTBEYE GÖRE HASAR ÇARPANLARI TABLOSU >>>
-- Buraya istediğiniz rütbeleri ve hasar çarpanlarını ekleyin.
-- 1.0 = Normal hasar, 1.5 = %50 daha fazla hasar, 2.0 = 2 kat hasar vb.
local rankDamageMultipliers = {
    ["vip"] = 2,
    ["admin+"] = 2,
	["admin"] = 2,
    ["moderator+"] = 2, -- Örnek: Moderator için 7 saniye
    ["moderator"] = 2, -- Örnek: Superadmin için 3 saniye
	["basadmin"] = 2,
	["viprehber"] = 2,
	["superadmin"] = 2,
}
local defaultDamageMultiplier = 1.0 -- Yukarıdaki tabloda olmayan rütbeler için varsayılan çarpan (normal hasar)
-- <<< RÜTBE TABLOSU SONU >>>


-- Ram action when ramming a door
local GoingUp = true
local Freeze = false
local function ramDoor(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 3000 or (not GAMEMODE.Config.canforcedooropen and ent:getKeysNonOwnable()) then return false end

    local allowed = false

    -- if we need a warrant to get in
    if GAMEMODE.Config.doorwarrants and ent:isKeysOwned() and not ent:isKeysOwnedBy(ply) then
        -- if anyone who owns this door has a warrant for their arrest
        -- allow the police to smash the door in
        for _, v in ipairs(player.GetAll()) do
            if ent:isKeysOwnedBy(v) and canRam(v) then
                allowed = true
                break
            end
        end
    else
        -- door warrants not needed, allow warrantless entry
        allowed = true
    end

    -- Be able to open the door if any member of the door group is warranted
    local keysDoorGroup = ent:getKeysDoorGroup()
    if GAMEMODE.Config.doorwarrants and keysDoorGroup then
        local teamDoors = RPExtraTeamDoors[keysDoorGroup]
        if teamDoors then
            allowed = false
            for _, v in ipairs(player.GetAll()) do
                if table.HasValue(teamDoors, v:Team()) and canRam(v) then
                    allowed = true
                    break
                end
            end
        end
    end

    if CLIENT then return allowed end

    -- Do we have a warrant for this player?
    if not allowed then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("warrant_required"))

        return false
    end

    Freeze = true

    timer.Simple( 0.4, function()
        if( not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then Freeze = false return end -- Oyuncu veya silah geçerli değilse işlemi durdur
        ply:EmitSound( wep.Sound )

        if( not BES.CONFIG.DoorRam.InstantOpen and (not ent:GetNWInt( "BES_DoorHP", false ) or ent:GetNWInt( "BES_DoorHP", 0 ) > 0) ) then
            if( not ent:GetNWInt( "BES_DoorHP", false ) ) then
                ent:SetNWInt( "BES_DoorHP", BES.CONFIG.DoorRam.DoorHealth )
            end

            local percent = 0
            if( wep:GetBarPercent() <= 50 ) then
                percent = wep:GetBarPercent()/50
            else
                percent = (50-(wep:GetBarPercent()-50))/50
            end

            -- <<< HASAR HESAPLAMASINA RÜTBE ÇARPANI EKLENDİ >>>
            local playerGroup = ply:GetUserGroup()
            local multiplier = rankDamageMultipliers[playerGroup] or defaultDamageMultiplier -- Rütbeye göre çarpanı al veya varsayılanı kullan
            local Damage = BES.CONFIG.DoorRam.DamagePerHit * percent * multiplier -- Çarpanı hasara uygula
            -- <<< HASAR HESAPLAMASI SONU >>>

            ent:SetNWInt( "BES_DoorHP", math.max( ent:GetNWInt( "BES_DoorHP", 0 )-Damage, 0 ) )
        end

        if( BES.CONFIG.DoorRam.InstantOpen or ent:GetNWInt( "BES_DoorHP", 0 ) <= 0 or (BES.CONFIG.DoorRam.InstantAdmin and (ply:IsAdmin() or ply:IsSuperAdmin())) ) then
            ent:keysUnLock()
            ent:Fire( "open", "", 0 )
            ent:Fire( "setanimation", "open", 0 )

            if( not BES.CONFIG.DoorRam.InstantOpen and IsValid(ent) ) then -- Regen Timer öncesi ent kontrolü eklendi
                 -- Aynı kapı için zaten çalışan bir timer varsa onu iptal et
                if timer.Exists("BES_DoorTimer_" .. ent:EntIndex()) then
                    timer.Remove("BES_DoorTimer_" .. ent:EntIndex())
                end
                timer.Create( "BES_DoorTimer_" .. ent:EntIndex(), BES.CONFIG.DoorRam.DoorRegenTime, 1, function()
                    if( IsValid( ent ) ) then
                        ent:SetNWInt( "BES_DoorHP", BES.CONFIG.DoorRam.DoorHealth )
                    end
                end )
            end
        end
         -- Freeze = false -- İşlem bittikten sonra Freeze'i kaldır
    end )

    return true
end

-- Ram action when ramming a vehicle
local function ramVehicle(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    if CLIENT then return false end -- Ideally this would return true after ent:GetDriver() check

    Freeze = true -- Araca vururken de dondur
    timer.Simple( 0.4, function()
        if( not IsValid( ent ) or not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then Freeze = false return end

        ent:keysLock()

        ply:EmitSound( wep.Sound )

        local driver = ent:GetDriver()
        if not IsValid(driver) or not driver.ExitVehicle then Freeze = false return end

        driver:ExitVehicle()
        -- Freeze = false -- İşlem bittikten sonra Freeze'i kaldır
    end )

    return true
end

-- Ram action when ramming a fading door
local function ramFadingDoor(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    local Owner = ent:CPPIGetOwner()

    if CLIENT then return canRam(Owner) end

    if not canRam(Owner) then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("warrant_required"))
        return false
    end

    Freeze = true -- Fading door'a vururken de dondur
    timer.Simple( 0.4, function()
        if( not IsValid( ent ) or not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then Freeze = false return end
        ply:EmitSound( wep.Sound )

        if not ent.fadeActive then
            ent:fadeActivate()
            timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end)
        end
        -- Freeze = false -- İşlem bittikten sonra Freeze'i kaldır
    end )

    return true
end

-- Ram action when ramming a frozen prop
local function ramProp(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end
    if ent:GetClass() ~= "prop_physics" then return false end

    local Owner = ent:CPPIGetOwner()

    if CLIENT then return canRam(Owner) end

    if not canRam(Owner) then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase(GAMEMODE.Config.copscanunweld and "warrant_required_unweld" or "warrant_required_unfreeze"))
        return false
    end

    Freeze = true -- Prop'a vururken de dondur
    timer.Simple( 0.4, function()
        if( not IsValid( ent ) or not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then Freeze = false return end
        ply:EmitSound( wep.Sound )

        if GAMEMODE.Config.copscanunweld then
            constraint.RemoveConstraints(ent, "Weld")
        end

        if GAMEMODE.Config.copscanunfreeze then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then -- Phys obj kontrolü eklendi
                phys:EnableMotion(true)
            end
        end
        -- Freeze = false -- İşlem bittikten sonra Freeze'i kaldır
    end )

    return true
end

-- Decides the behaviour of the ram function for the given entity
local function getRamFunction(ply, trace, wep)
    local ent = trace.Entity

    if not IsValid(ent) then return fp{fn.Id, false} end

    local override = hook.Call("canDoorRam", nil, ply, trace, ent)

    -- Fizik nesnesi kontrolü eklendi
    local phys = ent:GetPhysicsObject()
    local isPhysicsValid = IsValid(phys)

    return
        override ~= nil     and fp{fn.Id, override}                                 or
        ent:isDoor()        and fp{ramDoor, ply, trace, ent, wep}                        or
        ent:IsVehicle()     and fp{ramVehicle, ply, trace, ent, wep}                     or
        ent.fadeActivate    and fp{ramFadingDoor, ply, trace, ent, wep}                  or
        (isPhysicsValid and not phys:IsMoveable()) -- Fizik nesnesi geçerliyse ve hareket etmiyorsa
                                         and fp{ramProp, ply, trace, ent, wep}           or
        fp{fn.Id, false} -- no ramming was performed
end

function SWEP:PrimaryAttack()
    if Freeze then return end -- Eğer zaten bir işlem yapılıyorsa (Freeze true ise) tekrar başlatma

    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

    local ramFunc = getRamFunction(self:GetOwner(), trace, self)
    local hasRammed = ramFunc() -- Ram fonksiyonunu çağır ve sonucu al

    if SERVER then
        hook.Call("onDoorRamUsed", GAMEMODE, hasRammed, self:GetOwner(), trace)
    end

    if not hasRammed then return end -- Eğer ram işlemi başarısızsa veya yapılamadıysa devam etme

    -- Freeze = true -- Başarılı ram işlemi başlarsa dondur (Bu satır ram fonksiyonlarının içine taşındı)

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )

    -- Animasyon ve bekleme süresi için tek bir timer kullanılıyor.
    -- Freeze değişkeni, ram fonksiyonlarının içindeki timer.Simple içinde false yapılıyor.
    timer.Simple( 1, function()
        if( not IsValid( self ) or not IsValid( self.Owner ) or self.Owner:GetActiveWeapon() != self ) then Freeze = false return end
        self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
        Freeze = false -- Animasyon bitince ve işlem tamamlanınca Freeze'i kaldır
        self:SetBarPercent( 0 )
    end )
    self:SetNextPrimaryFire( CurTime() + 1.1 )
end


function SWEP:SecondaryAttack()

end

function SWEP:Think()
    if( BES.CONFIG.DoorRam.InstantOpen or not IsValid( self.Owner ) ) then return end
    if CLIENT then return end
    if Freeze then return end -- Eğer işlem yapılıyorsa barı güncelleme

    local TraceEnt = self.Owner:GetEyeTrace().Entity
    local eyepos = self.Owner:EyePos()
    -- Kapı ve mesafe kontrolü
    if( IsValid( TraceEnt ) and TraceEnt:isDoor() and eyepos:DistToSqr( self.Owner:GetEyeTrace().HitPos ) < 3000 and not TraceEnt:getKeysNonOwnable() and TraceEnt:isKeysOwned() ) then
        if( self:GetBarPercent() < 100 and GoingUp ) then
            self:SetBarPercent( math.min( self:GetBarPercent()+2, 100 ) ) -- %100'ü geçmemesini sağla
            if( self:GetBarPercent() >= 100 ) then
                GoingUp = false
            end
        elseif( not GoingUp ) then
            self:SetBarPercent( math.max( self:GetBarPercent()-2, 0 ) ) -- %0'ın altına düşmemesini sağla
            if( self:GetBarPercent() <= 0 ) then
                GoingUp = true
            end
        end
    elseif( self:GetBarPercent() > 0 ) then
        -- Eğer hedeften uzaklaşıldıysa barı sıfırla
        GoingUp = true
        self:SetBarPercent( 0 )
    end
end

function SWEP:Holster()
    Freeze = false -- Silah değiştirilirse Freeze'i kaldır
    return true
end

if( CLIENT ) then
    local w = ScrW()
    local h = ScrH()
    local x, y, width, height = w / 2 - w / 10, (h / 4)*3 - (h / 15 + 20)/2, w / 5, h / 15
    local hHeight = 20
    local sizet = 9
    function SWEP:DrawHUD()
        -- Anlık açma veya admin anlık açma aktifse HUD'ı çizme
        if( (BES.CONFIG.DoorRam.InstantAdmin and (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin())) or BES.CONFIG.DoorRam.InstantOpen ) then return end

        if( not IsValid( self.Owner ) ) then return end
        local TraceEnt = self.Owner:GetEyeTrace().Entity
        local eyepos = self.Owner:EyePos()
        -- Kapı, mesafe ve sahiplik kontrolleri
        if( not IsValid( TraceEnt ) or not TraceEnt:isDoor() or eyepos:DistToSqr( self.Owner:GetEyeTrace().HitPos ) > 4000 or TraceEnt:getKeysNonOwnable() or not TraceEnt:isKeysOwned() ) then return end
        local status = self:GetBarPercent()/100

        surface.SetDrawColor( BES.CONFIG.Themes.Secondary )
        surface.DrawRect( x, y, width, height+hHeight )

        local BarWidth = status * (width - sizet)

        surface.SetDrawColor( BES.CONFIG.Themes.Tertiary )
        surface.DrawRect( x + sizet/2, y + sizet/2, width-sizet, height - sizet )

        -- Güç barı gradyanı
        draw.GradientBox( x + sizet/2, y + sizet/2, (width - sizet)/2, height - sizet, 0, HSVToColor( 0, 1, 1 ), HSVToColor( 90, 1, 1 ) )
        draw.GradientBox( x + sizet/2 + (width - sizet)/2 -1, y + sizet/2, (width - sizet)/2, height - sizet, 0, HSVToColor( 90, 1, 1 ), HSVToColor( 0, 1, 1 ) )

        surface.SetDrawColor( 50, 50, 50, 100 )
        surface.DrawRect( x + sizet/2, y + sizet/2, (width - sizet), height - sizet )

        -- Güç göstergesi çizgisi
        surface.SetDrawColor( BES.CONFIG.Themes.Primary )
        surface.DrawRect( (x + sizet/2)+(BarWidth) - 1.5, y + sizet/2, 3, height - sizet ) -- Çizgiyi ortalamak için -1.5 eklendi

        -- Kapı can barı
        local doorHealth = TraceEnt:GetNWInt( "BES_DoorHP", BES.CONFIG.DoorRam.DoorHealth )
        local maxHealth = BES.CONFIG.DoorRam.DoorHealth
        if maxHealth <= 0 then maxHealth = 1 end -- Sıfıra bölme hatasını engelle
        local healthStatus = math.Clamp(doorHealth / maxHealth, 0, 1) -- Sağlık durumunu 0-1 arasına sıkıştır

        surface.SetDrawColor( BES.CONFIG.Themes.Tertiary )
        surface.DrawRect( x + sizet/2, y + height, width-sizet, hHeight - sizet/2 )
        surface.SetDrawColor( BES.CONFIG.Themes.Red )
        surface.DrawRect( x + sizet/2, y + height, (width-sizet)*healthStatus, hHeight - sizet/2 )
    end
end