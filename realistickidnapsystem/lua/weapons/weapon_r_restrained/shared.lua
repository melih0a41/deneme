if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Restrained"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.HoldType = "passive";
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "passive"
SWEP.Category = "ToBadForYou"
SWEP.UID = 76561197989708503

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "RestrainsHP")
	self:SetRestrainsHP(100)
end

function SWEP:Initialize() self:SetHoldType("passive") end

function SWEP:PrimaryAttack()
	if SERVER and RKS_GetConf("RESTRAINS_EnableEscape") then
		self:SetRestrainsHP(self:GetRestrainsHP() - 0.15)

		if self:GetRestrainsHP() < 1 then
			self.Owner:RKSRestrain(self.Owner)
		end
	end
end
function SWEP:SecondaryAttack() self:PrimaryAttack() end

function SWEP:Think()
	if SERVER then
		local CurT = CurTime()
		local HP = self:GetRestrainsHP()
		-- OPTIMIZATION: Only regenerate if needed and check less frequently
		if HP < 100 and (self.NextReg or 0) < CurT then
			self:SetRestrainsHP(math.min(HP + 0.325, 100)) -- Regen 5x faster but check 5x less
			self.NextReg = CurT + 0.25 -- Check every 0.25s instead of 0.05s
		end
	end
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:DrawWorldModel()
end

if CLIENT then
	-- OPTIMIZATION: Cache values
	local W, H = ScrW()/2, ScrH()/2
	local WHITE = Color(255,255,255,255)
	local BLACK = Color(0,0,0,255)
	local GRAY = Color(110,100,100,255)
	local GREEN = Color(50,200,5,200)
	
	hook.Add("OnScreenSizeChanged", "RKS_Restrained_UpdateCache", function()
		W, H = ScrW()/2, ScrH()/2
	end)
	
	function SWEP:DrawHUD()
		draw.SimpleTextOutlined(RKS_GetLang("RestrainedText"),"Trebuchet24",W,H/6,WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM,2,BLACK)

		if RKS_GetConf("RESTRAINS_EnableEscape") then
			local BoxW = 200
			local BoxSW = W-BoxW/2
			local BoxY = H/5.5
			
			surface.SetDrawColor(BLACK)
			surface.DrawOutlinedRect(BoxSW-1, BoxY-1, BoxW+2, 27)
			draw.RoundedBox(0, BoxSW, BoxY, BoxW, 25, GRAY)
			
			local HP = self:GetRestrainsHP()
			if HP > 0 then
				draw.RoundedBox(0, BoxSW, BoxY, BoxW*HP/100, 25, GREEN)
			end
		end
	end
end