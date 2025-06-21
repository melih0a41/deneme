-- Güvenli Bölge Durum Sabitleri (sh_safezones kodundan türetildi)
local SH_SZ_OUTSIDE = 0
local SH_SZ_ENTERING = 1
local SH_SZ_PROTECTED = 2

-- Seconds to pass until Pickpocketing is done
local PPConfig_Duration = 10

-- Seconds to wait until next Pickpocketing
local PPConfig_Wait = 180 

-- Distance able to be stolen from
local PPConfig_Distance = 150 

-- Should stealing emit a silent sound (true or false)
local PPConfig_Sound = false 

-- Hold down to keep Pickpocketing (true or false)
local PPConfig_Hold = false 

-- YENİ: Hareket toleransı (birim cinsinden)
local PPConfig_MovementTolerance = 35 -- Hedef 2-3 adım kadar uzaklaşabilir

if SERVER then
	AddCSLuaFile( "shared.lua" )
	util.AddNetworkString( "pickpocket_time_pro" ) 
else
	SWEP.PrintName = "PRO Kapkac" 
	SWEP.Slot = 0
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.Base = "weapon_base"
SWEP.Author = "Leon Roleplay"
SWEP.Instructions = "Para calmak icin hedefe sol klik tıkla (%20)" -- %10'dan %20'ye güncellendi
SWEP.IconLetter = ""
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model( "models/weapons/c_crowbar.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" )
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminOnly = true 
SWEP.Category = "lordtobi's Weapons"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize() self:SetWeaponHoldType( "normal" ) end

if CLIENT then
	net.Receive( "pickpocket_time_pro", function() 
		local wep = net.ReadEntity()
        if not IsValid(wep) then return end
		wep.IsPickpocketing = true
		wep.StartPick = CurTime()
		wep.EndPick = CurTime() + PPConfig_Duration 
	end )
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 ) 
	if self.IsPickpocketing then return end
	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity
	if not IsValid( e ) or not e:IsPlayer() or e == self.Owner then return end
	if trace.HitPos:Distance( self.Owner:GetShootPos() ) > PPConfig_Distance then 
		if CLIENT then self.Owner:PrintMessage( HUD_PRINTTALK, "Hedef çok uzakta." ) end
		return
	end

	if SERVER then
        local owner = self.Owner
		local attackerStatus = owner:GetNWInt("SH_SZ.Safe", SH_SZ_OUTSIDE)
		local targetStatus = e:GetNWInt("SH_SZ.Safe", SH_SZ_OUTSIDE)

        if attackerStatus == SH_SZ_ENTERING or attackerStatus == SH_SZ_PROTECTED then
            owner:ChatPrint("[Kapkaç] Güvenli bölgedeyken kapkaç yapamazsın!")
            return 
        end

		if targetStatus == SH_SZ_ENTERING or targetStatus == SH_SZ_PROTECTED then
			owner:ChatPrint("[Kapkaç] Hedef güvenli bölgede, kapkaç yapamazsın!")
			return 
		end

        if math.random(1, 100) <= 70 then 
            timer.Simple(0.1, function() 
                if IsValid(e) then e:ChatPrint("Ceplerin yoklanıyor, dikkat et!") end
            end)
        end
		self.IsPickpocketing = true
		self.StartPick = CurTime()
		self.EndPick = CurTime() + PPConfig_Duration 
		-- YENİ: Hedefi ve başlangıç pozisyonunu kaydet
		self.PickpocketTarget = e
		self.InitialTargetPos = e:GetPos()
		
		net.Start( "pickpocket_time_pro" ) 
		net.WriteEntity( self )
		net.Send(owner)
	end

	self:SetWeaponHoldType( "pistol" )
	if CLIENT then
		self.Dots = self.Dots or ""
		timer.Create( "PickpocketDotsPro", 0.5, 0, function() 
			if not self:IsValid() or not self.IsPickpocketing then
				timer.Destroy( "PickpocketDotsPro" ); self.Dots = ""
				return
			end
			local len = string.len( self.Dots ); local dots = { [0] = ".", [1] = "..", [2] = "...", [3] = "" }
			self.Dots = dots[len]
		end )
	end
end

function SWEP:Holster()
    if self.IsPickpocketing then self:Fail() end
	self.IsPickpocketing = false
	if CLIENT then timer.Destroy( "PickpocketDotsPro" ); self.Dots = "" end
	return true
end

function SWEP:OnRemove() self:Holster() end

function SWEP:Succeed()
    if not self.IsPickpocketing then return end
	self.IsPickpocketing = false
	self:SetWeaponHoldType( "normal" )

    -- >>> Cooldown burada başlıyor <<<
	self.Weapon:SetNextPrimaryFire( CurTime() + PPConfig_Wait ) 
	
    local trace = self.Owner:GetEyeTrace()
    local owner = self.Owner -- Sahibi değişkene alalım

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() then 
        -- Hedef geçerli değilse başarısız say, ama cooldown yine de başlasın
        self:Fail()
        return 
    end
	if CLIENT then timer.Destroy( "PickpocketDotsPro" ); self.Dots = "" end

	if SERVER then
        local function FormatMoney(number)
            local s = tostring(number)
            local formatted = ""
            local len = #s
            local mod = len % 3
            if mod == 0 then mod = 3 end
            for i = 1, len do
                formatted = formatted .. string.sub(s, i, i)
                if i == mod and i ~= len then
                    formatted = formatted .. "."
                    mod = mod + 3
                end
            end
            return formatted
        end

		local target = trace.Entity
		local targetMoney = target:getDarkRPVar( "money" ) or 0
		local moneyToSteal = math.floor( targetMoney * 0.20 ) -- GÜNCELLEME: %10'dan %20'ye çıkarıldı
		
		if targetMoney >= moneyToSteal and moneyToSteal > 0 then
			DarkRP.payPlayer( target, owner, moneyToSteal ) 
            local formattedMoney = FormatMoney(moneyToSteal) 

            if IsValid(owner) then
                 owner:ChatPrint("[PRO Kapkaç] Başarıyla " .. formattedMoney .. " TL çaldın! (%20)")
            end
            if IsValid(target) then
                 target:ChatPrint("[PRO Kapkaç] Dikkat! " .. formattedMoney .. " TL paran çalındı! (%20)")
            end
		-- else -- Para çalınamadıysa mesaj gönderilmiyor, ama cooldown yine aktif.
             -- if IsValid(owner) then
             --    owner:ChatPrint("[Kapkaç] Başarılı, fakat hedefin yeterli parası yoktu.")
             -- end
		end

        -- >>> YENİ: Başarılı Cooldown Mesajı (SERVER) <<<
        if IsValid(owner) then
             owner:ChatPrint("[PRO Kapkaç] Bekleme süresi: " .. PPConfig_Wait .. " saniye.")
        end
	end
end

function SWEP:Fail()
    if not self.IsPickpocketing then return end
	self.IsPickpocketing = false
	self:SetWeaponHoldType( "normal" )

    -- >>> YENİ: Başarısızlıkta da Cooldown Başlat <<<
	self.Weapon:SetNextPrimaryFire( CurTime() + PPConfig_Wait ) 

    local owner = self.Owner -- Sahibi değişkene alalım
	
    if CLIENT then timer.Destroy( "PickpocketDotsPro" ); self.Dots = "" end
	
    -- İstemciye başarısızlık mesajı gönder
    if CLIENT then
        if IsValid(owner) and owner == LocalPlayer() then 
		    owner:PrintMessage( HUD_PRINTTALK, "PRO Kapkac basarisiz." )
        end
	end

     -- >>> YENİ: Başarısız Cooldown Mesajı (SERVER) <<<
    if SERVER then
        if IsValid(owner) then
            owner:ChatPrint("[PRO Kapkaç] Bekleme süresi: " .. PPConfig_Wait .. " saniye.")
        end
    end
end

function SWEP:Think()
	if not self.IsPickpocketing or not self.EndPick then return end
    local owner = self.Owner
    if not IsValid(owner) then self:Fail(); return end
	local trace = owner:GetEyeTrace()
	
	-- YENİ: Daha sıkı hedef kontrolü
	local target = self.PickpocketTarget or trace.Entity
	
	if not IsValid(target) or not target:IsPlayer() then 
		self:Fail()
		return 
	end
	
	-- YENİ: Başlangıç pozisyonundan ne kadar uzaklaştığını kontrol et
	if self.InitialTargetPos then
		local distanceFromStart = target:GetPos():Distance(self.InitialTargetPos)
		-- Eğer hedef başlangıç pozisyonundan toleranstan fazla uzaklaştıysa iptal et
		if distanceFromStart > PPConfig_MovementTolerance then
			self:Fail()
			return
		end
	end
	
	-- Hedefin şu anki pozisyonu ile oyuncunun pozisyonu arasındaki mesafe
	local currentDistance = target:GetPos():Distance(owner:GetPos())
	
	-- Eğer hedef oyuncudan çok uzaklaştıysa iptal et
	if currentDistance > PPConfig_Distance then 
		self:Fail()
		return 
	end
	
	-- YENİ: Oyuncunun hedefi görüyor olması gerekiyor
	-- Bakış açısı kontrolü - hedefin hala görüş alanında olması gerekiyor
	local lookDir = owner:GetAimVector()
	local targetDir = (target:GetPos() + target:OBBCenter() - owner:GetShootPos()):GetNormalized()
	local dotProduct = lookDir:Dot(targetDir)
	
	-- Eğer hedef görüş açısının dışındaysa (0.5 = ~60 derece)
	if dotProduct < 0.5 then 
		self:Fail()
		return 
	end
	
	if PPConfig_Hold and not owner:KeyDown( IN_ATTACK ) then self:Fail(); return end
	if self.EndPick <= CurTime() then self:Succeed(); return end
end

function SWEP:DrawHUD()
	if self.IsPickpocketing and self.EndPick and IsValid(self.Owner) and self.Owner == LocalPlayer() then
		self.Dots = self.Dots or ""
		local w = ScrW(); local h = ScrH(); local x, y, width, height = w / 2 - w / 10, h / 2 - 60, w / 5, h / 15
		draw.RoundedBox( 8, x, y, width, height, Color( 10, 10, 10, 120 ) )
		local time = self.EndPick - self.StartPick; if time <= 0 then time = 0.01 end
		local curtime = CurTime() - self.StartPick; if curtime < 0 then curtime = 0 end
		local status = math.Clamp( curtime / time, 0, 1); local BarWidth = status * ( width - 16 )
        if BarWidth < 0 then BarWidth = 0 end; local cornerRadius = math.Min( 8, BarWidth / 3 * 2 - BarWidth / 3 * 2 % 2 )
        if cornerRadius < 0 then cornerRadius = 0 end
		draw.RoundedBox( cornerRadius, x + 8, y + 8, BarWidth, height - 16, Color( 255 - ( status * 255 ), 0 + ( status * 255 ), 0, 255 ) )
		draw.DrawNonParsedSimpleText( "PRO Caliniyor" .. self.Dots, "Trebuchet24", w / 2, y + height / 2, Color( 255, 255, 255, 255 ), 1, 1 )
	end
end

function SWEP:SecondaryAttack() end