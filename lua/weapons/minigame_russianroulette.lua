AddCSLuaFile()
--[[------------------------------------------------
            Minigame Russian Roulette
------------------------------------------------]]--

SWEP.PrintName = "Russian Roulette"
SWEP.Author = "vicentefelipechile"


SWEP.Category = "Minigames"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.DrawAmmo = false

SWEP.ViewModelFOV = 70

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

local WeaponSoundEmpty = "weapons/pistol/pistol_empty.wav"
local WeaponSoundFire = "weapons/357/357_fire2.wav"


--[[----------------------------------------
                SWEP Functions
----------------------------------------]]--

function SWEP:Shoot(DecideToShoot)
    local ply = self:GetOwner()

    local InGame, Owner = Minigames.PlayerInGame( ply )
    if not InGame then return end

    local GameScript = Minigames.GetOwnerGame(Owner)

    local CanSkip = GameScript:CanSkip( ply )
    local IsReady = true

    if ( DecideToShoot == false ) and ( CanSkip == false ) then
        Minigames.BroadcastMessage( Minigames.GetPhrase( "russianroulette.hud.cantskip", ply:Nick() ), ply )
        IsReady = false
    end

    if ( DecideToShoot == false ) and ( CanSkip == true ) then
        IsReady = true
    end

    if ( DecideToShoot == true ) and ( CanSkip == true ) then
        IsReady = true
    end

    if not IsReady then return end

    if DecideToShoot then
        self:EmitSound( GameScript:BulletOnNextPosition() and WeaponSoundFire or WeaponSoundEmpty )
    end

    ply:SetNWBool("RussianRoulette.Decision", DecideToShoot)
    ply:SetNWBool("RussianRoulette.Ready", IsReady)

end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    self:SetNextPrimaryFire(CurTime() + 0.5)

    if CLIENT then return end
    self:Shoot(true)
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    self:SetNextSecondaryFire(CurTime() + 0.5)

    if CLIENT then return end
    self:Shoot(false)
end

--[[----------------------------------------
            Draw Hud Function
----------------------------------------]]--

local BackGround = Color(0, 0, 0, 240)
local DarkColor = Color(200, 200, 200, 2)
local PrimaryAttackIcon = Material("minigames/icons/mouse_primaryattack.png")
local SecondaryAttackIcon = Material("minigames/icons/mouse_secondaryattack.png")

function SWEP:DrawHUD()
    local W, H = ScrW(), ScrH()
    local PAposX = W / 2 - 240
    local PAposY = H - 140

    local HeCantSkip = not LocalPlayer():GetNWBool("RussianRoulette.CanSkip", true)
    local SecondaryAttackColor = HeCantSkip and DarkColor or color_white

    -- Background
    draw.RoundedBox(8, PAposX, PAposY, 240 * 2, 100, BackGround)

    -- Primary Attack Icon
    surface.SetDrawColor(color_white)
    surface.SetMaterial(PrimaryAttackIcon)
    surface.DrawTexturedRect(PAposX + 10, PAposY + (100 * 0.3) - 10, 28, 28)

    -- Secondary Attack Icon
    surface.SetDrawColor(SecondaryAttackColor)
    surface.SetMaterial(SecondaryAttackIcon)
    surface.DrawTexturedRect(PAposX + 10, PAposY + (100 * 0.7) - 10, 28, 28)

    draw.SimpleText(Minigames.GetPhrase("russianroulette.hud.primaryattack"), "Minigames.Title", PAposX + 40, PAposY + (100 * 0.3), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(Minigames.GetPhrase("russianroulette.hud.secondaryattack"), "Minigames.Title", PAposX + 40, PAposY + (100 * 0.7), SecondaryAttackColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if HeCantSkip then
        draw.SimpleText(Minigames.GetPhrase("russianroulette.hud.cantskip"), "Minigames.Title", PAposX + 40, PAposY + (100 * 0.7), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end


--[[----------------------------------------
            Miscelaneous Functions
----------------------------------------]]--

cvars.AddChangeCallback("viewmodel_fov", function(_, _, new)
    if not IsValid(LocalPlayer()) then return end
    if not IsValid(LocalPlayer():GetActiveWeapon()) then return end
    if LocalPlayer():GetActiveWeapon():GetClass() ~= "minigame_russianroulette" then return end
    LocalPlayer():GetActiveWeapon().ViewModelFOV = tonumber(new)
end)