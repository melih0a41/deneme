
resource.AddWorkshop("804809965")

util.AddNetworkString("rks_blindfold")
util.AddNetworkString("rks_gag")
util.AddNetworkString("rks_unrestrain")
util.AddNetworkString("rks_knockout")
util.AddNetworkString("rks_drag")
util.AddNetworkString("rks_inspect")
util.AddNetworkString("rks_send_inspect_information")
util.AddNetworkString("rks_stealcash")
util.AddNetworkString("rks_stealweapon")
util.AddNetworkString("rks_update_ragdollcolor")
util.AddNetworkString("rks_bonemanipulate")
util.AddNetworkString("tbfy_surr")

local PLAYER = FindMetaTable("Player")

hook.Add("bLogs_FullyLoaded","RKS_bLogsInit",function()
	if ((not GAS or not GAS.Logging) and bLogs) then
		local MODULE = bLogs:Module()

		MODULE.Category = "ToBadForYou"
		MODULE.Name     = "Realistic Kidnap"
		MODULE.Colour   = Color(255,0,0)

		MODULE:Hook("RKS_Knockout","rks_succ_ko",function(vic,knocker)
			MODULE:Log(bLogs:FormatPlayer(knocker) .. " knocked out " .. bLogs:FormatPlayer(vic))
		end)

		MODULE:Hook("RKS_Restrain","rks_toggle_restrain",function(vic,restrainer)
			local LogText = "restrained"
			if !vic.RKRestrained then
				LogText = "unrestrained"
			end
			MODULE:Log(bLogs:FormatPlayer(restrainer) .. " " .. LogText .. " " .. bLogs:FormatPlayer(vic))
		end)

		MODULE:Hook("RKS_Blindfold","rks_toggle_blindfold",function(vic,blindfolder)
			local LogText = "blindfolded"
			if !vic.Blindfolded then
				LogText = "unblindfolded"
			end
			MODULE:Log(bLogs:FormatPlayer(blindfolder) .. " " .. LogText .. " " .. bLogs:FormatPlayer(vic))
		end)

		MODULE:Hook("RKS_Gag","rks_toggle_gag",function(vic,gagger)
			local LogText = "gagged"
			if !vic.Gagged then
				LogText = "ungagged"
			end
			MODULE:Log(bLogs:FormatPlayer(gagger) .. " " .. LogText .. " " .. bLogs:FormatPlayer(vic))
		end)

		bLogs:AddModule(MODULE)
	end
end)

function PLAYER:RKS_ToggleRagdoll(AlreadyRestrained)
	if !IsValid(self) then return end

	local Ragdoll = self.RKSRagdoll
	if IsValid(Ragdoll) then
		self:SetParent()
		self:SetPos(Ragdoll:GetPos())
		self:SetNoDraw(false)
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		self:SetNotSolid(false)
		self:DrawWorldModel(true)
		self:UnLock()
		if Ragdoll.RKSRestrained then
			self:RKSRestrain(Ragdoll.LastRKSRestrained)
		elseif Ragdoll.RHCCuffed then
			self:RHCRestrain(Ragdoll.LastRHCCuffed)
		end
		Ragdoll:Remove()
	else
		local Ragdoll = ents.Create("prop_ragdoll")
		Ragdoll:SetModel(self:GetModel())
		Ragdoll:SetPos( self:GetPos() )
		Ragdoll:SetAngles( self:GetAngles() )
		Ragdoll:SetSkin( self:GetSkin() )
		Ragdoll:SetColor(self:GetColor())
		Ragdoll:Spawn()
		Ragdoll:Activate()

		if AlreadyRestrained == 1 then
			Ragdoll.LastRKSRestrained = self.RestrainedBy
			Ragdoll.RKSRestrained = true
		elseif AlreadyRestrained == 2 then
			Ragdoll.LastRHCCuffed = self.CuffedBy
			Ragdoll.RHCCuffed = true
		else
			Ragdoll:SetNWBool("CanRKSRestrain", true)
		end

		local num = Ragdoll:GetPhysicsObjectCount() - 1
		for i = 0, num do
			local bone = Ragdoll:GetPhysicsObjectNum(i)
			if IsValid(bone) then
				local bp, ba = self:GetBonePosition(Ragdoll:TranslatePhysBoneToBone(i))
				if bp and ba then
					bone:SetPos(bp)
					bone:SetAngles(ba)
				end
				bone:SetMaterial("armorflesh")
			end
		end
		self.RKSRagdoll = Ragdoll
		Ragdoll.RKSPickup = true
		Ragdoll.Player = self
		Ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)

		self:SetParent(Ragdoll)
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetNotSolid(true)
		self:DrawWorldModel(false)
		self:Lock()

		timer.Simple(.1, function()
			net.Start("rks_update_ragdollcolor")
				net.WriteEntity(self)
				net.WriteEntity(Ragdoll)
			net.Broadcast()
		end)
	end
end

hook.Add("GravGunPickupAllowed", "RKS_AllowRagdollPickup", function(Player, Entity)
	if RKidnapConfig.AllowGravGunRagdolls and Entity.RKSPickup then
		return true
	end
end)

function PLAYER:RKSKnockout(KnockedoutBy)
	self.RKSKnockedOut = true

	if self.TBFY_Surrendered then
		self:TBFY_ToggleSurrender()
	end

	if self.Restrained then
		self:CleanUpRHC(false, true)
		self:RKS_ToggleRagdoll(2)
	elseif self.RKRestrained then
		self:CleanUpRKS(false, false,true)
		self:RKS_ToggleRagdoll(1)
	else
		self.RKS_KOStripped = true
		self.RKRestrained = true
		self:SetupRKSWeapons()
		self:RKS_ToggleRagdoll()
	end

	net.Start("rks_knockout")
		net.WriteBool(true)
	net.Send(self)

	timer.Simple(RKidnapConfig.KnockoutTime, function()
		self.RKSKnockedOut = false
		if self.RKS_KOStripped then
			self.RKRestrained = false
			self:SetupRKSWeapons()
		end
		self:RKS_ToggleRagdoll()

		net.Start("rks_knockout")
			net.WriteBool(false)
		net.Send(self)
	end)

	hook.Call("RKS_Knockout", GAMEMODE, self, KnockedoutBy)
end

function PLAYER:CleanUpRKS(GWeapons, BGRemove, NoReset)
  self.RKRestrained = false
	if RKS_GetConf("RESTRAINS_StarWarsRestrains") then
		self:SetupRKSBones("Restrained_StarWars", true)
	else
		self:SetupRKSBones("Restrained", true)
	end
  if !NoReset then
      local CBy = self.RestrainedBy
      if IsValid(CBy) then
          CBy.RestrainedPlayer = nil
      end
      self.RestrainedBy = nil
  end
  self:SetupRestrains()
  self:RKSCancelDrag()

	if self.RKS_Attatched then
		self:RKS_RemoveAttatch()
	end

  if GWeapons then
      self:SetupRKSWeapons()
  end

	if BGRemove then
		self.Gagged = false
		self:SetupRKSGag()

		self.Blindfolded = false
		self:SetupBlindfold()
	end

	if timer.Exists("RKS_unrestrain_" .. TBFY_SH:SID(self)) then
		timer.Destroy("RKS_unrestrain_" .. TBFY_SH:SID(self))
	end
end

local RKS_BoneManipulations = {
	["Restrained"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(-28,18,-21),
		["ValveBiped.Bip01_L_Hand"] = Angle(0,0,119),
		["ValveBiped.Bip01_L_Forearm"] = Angle(15,20,40),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(15, 26, 0),
		["ValveBiped.Bip01_R_Forearm"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Hand"] = Angle(45,34,-15),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(10,2,0),
		["ValveBiped.Bip01_R_Finger1"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,-40,0),
		["ValveBiped.Bip01_R_Finger12"] = Angle(0,-30,0)
	},
	["Restrained_StarWars"] = {
		["ValveBiped.Bip01_L_Hand"] = Angle(0,0,119),
		["ValveBiped.Bip01_L_Forearm"] = Angle(0,25,40),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(30, 26, 0),
		["ValveBiped.Bip01_R_UpperArm"] = Angle(-40,20, 0),
		["ValveBiped.Bip01_R_Forearm"] = Angle(5,50,0),
		["ValveBiped.Bip01_R_Hand"] = Angle(45,34,-15),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(10,2,0),
		["ValveBiped.Bip01_R_Finger1"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,-40,0),
		["ValveBiped.Bip01_R_Finger12"] = Angle(0,-30,0)
	},
	["HandsUp"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(73,35,128),
		["ValveBiped.Bip01_L_Hand"] = Angle(-12,12,90),
		["ValveBiped.Bip01_L_Forearm"] = Angle(-28,-29,44),
		["ValveBiped.Bip01_R_Forearm"] = Angle(-22,1,15),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(-77,-46,4),
		["ValveBiped.Bip01_R_Hand"] = Angle(33,39,-21),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,30,0),
		["ValveBiped.Bip01_L_Finger1"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger11"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger2"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger3"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger31"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,30,0),
		["ValveBiped.Bip01_R_Finger2"] = Angle(20,25,0),
		["ValveBiped.Bip01_R_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger3"] = Angle(20,35,0),
		["ValveBiped.Bip01_R_Finger31"] = Angle(0,45,0)
	}
}

function PLAYER:SetupRKSBones(Type, Reset)
    if RKidnapConfig.BoneManipulateClientside then
		net.Start("rks_bonemanipulate")
			net.WriteEntity(self)
			net.WriteString(Type)
			net.WriteBool(Reset)
		net.Broadcast()
	else
		for k,v in pairs(RKS_BoneManipulations[Type]) do
			local Bone = self:LookupBone(k)
			if Bone then
				if Reset then
					self:ManipulateBoneAngles(Bone, Angle(0,0,0))
				else
					self:ManipulateBoneAngles(Bone, v)
				end
			end
		end
		if !Reset and Type == "Restrained" and table.HasValue(RKidnapConfig.FEMALE_MODELS, self:GetModel()) then
			local LEFT_UP_ARM, RIGHT_UP_ARM, RIGHT_FORE_ARM = self:LookupBone("ValveBiped.Bip01_L_UpperArm"), self:LookupBone("ValveBiped.Bip01_R_UpperArm"), self:LookupBone("ValveBiped.Bip01_R_Forearm")
			if LEFT_UP_ARM then
				self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_UpperArm"), Angle(15, 23, 0))
			end
			if RIGHT_UP_ARM then
				self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_UpperArm"), Angle(-28, 5, -21))
			end
			if RIGHT_FORE_ARM then
				self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(0, 60, 10))
			end
		end
	end
	if RKidnapConfig.DisablePlayerShadow then
		self:DrawShadow(false)
	end
end

function PLAYER:TBFY_ToggleSurrender()
	if self.TBFY_Surrendered then
		self:SetupRKSBones("HandsUp", true)
		self.TBFY_Surrendered = false
		self:StripWeapon("tbfy_surrendered")
	else
		self:Give("tbfy_surrendered")
		//FA Support
		local Swep = self:GetActiveWeapon()
		if IsValid(Swep) and Swep.dt then
			Swep.dt.Status = 6
		end
		self:SelectWeapon("tbfy_surrendered")
		self:SetupRKSBones("HandsUp")
		self.TBFY_Surrendered = true
	end
end

local RKS_Surrendering = {}
hook.Add("Think", "TBFY_Surrender", function()
	for k,v in pairs(RKS_Surrendering) do
		local P, T = v.P, v.ST
		if v.ST < CurTime() then
			RKS_Surrendering[P:SteamID()] = nil
			net.Start("tbfy_surr")
				net.WriteFloat(0)
			net.Send(v.P)
			P:TBFY_ToggleSurrender()
		end
	end
end)

hook.Add("PlayerDisconnected", "TBFY_Surrender", function(Player)
	if RKS_Surrendering[Player:SteamID()] then
		RKS_Surrendering[Player:SteamID()] = nil
	end
end)

hook.Add("PlayerButtonDown","TBFY_Surrender",function(Player, Key)
	if RKidnapConfig.SurrenderEnabled and Key == RKidnapConfig.SurrenderKey and Player:TBFY_CanSurrender() then
		local SurrTime = CurTime() + 2.5
		RKS_Surrendering[Player:SteamID()] = {P = Player, ST = SurrTime}
		net.Start("tbfy_surr")
			net.WriteFloat(SurrTime)
		net.Send(Player)
	end
end)

hook.Add("PlayerButtonUp","TBFY_Surrender",function(Player, Key)
	if Key == RKidnapConfig.SurrenderKey and RKS_Surrendering[Player:SteamID()] then
		RKS_Surrendering[Player:SteamID()] = nil
		net.Start("tbfy_surr")
			net.WriteFloat(0)
		net.Send(Player)
	end
end)

hook.Add("demoteTeam", "TBFY_pre_demote", function(Player)
	Player.being_demoted = true
end)

hook.Add("playerCanChangeTeam", "TBFY_NoChangeJobSurrender", function(Player, Team)
  if Player.TBFY_Surrendered and !Player.being_demoted then
		return false, ""
	end
	Player.being_demoted = false
end)

hook.Add("OnPlayerChangedTeam", "TBFY_NoChangeJobSurrender", function(Player, Team)
  if Player.TBFY_Surrendered then
		Player:TBFY_ToggleSurrender()
	end
end)

hook.Add("PlayerSwitchWeapon", "TBFY_NoSwitchWeaponSurrender", function(Player)
	if Player.TBFY_Surrendered then return true end
end)

hook.Add("PlayerCanPickupWeapon", "TBFY_DisablePickupWeapon", function(Player, Wep)
	if Player.TBFY_Surrendered and Wep:GetClass() != "tbfy_surrendered" then return true end
end)

hook.Add("canDropWeapon", "TBFY_DisableDropWeapon", function(Player)
	if Player.TBFY_Surrendered then return false end
end)

hook.Add("CanPlayerEnterVehicle", "TBFY_CanPlayerEnterVehicle", function(Player, Vehicle)
	if Player.TBFY_Surrendered then return false end
end)

hook.Add("PlayerDeath", "TBFY_OnDeathSurrender", function( Player, Inflictor, Attacker )
    if Player.TBFY_Surrendered then
        Player:TBFY_ToggleSurrender()
    end
end)

hook.Add("PlayerUse", "TBFY_DisableUseSurrender", function(Player, Entity)
	if Player.TBFY_Surrendered then return false end
end)

function PLAYER:SetupRestrains()
		if RKS_GetConf("RESTRAINS_StarWarsRestrains") then
			TBFY_SH:TogglePEquip(self, "restrains_starwars", self.RKRestrained)
		else
			TBFY_SH:TogglePEquip(self, "restrains", self.RKRestrained)
		end
	  self:SetNWBool("rks_restrained", self.RKRestrained)
end

function PLAYER:SetupRKSWeapons()
  if self.RKRestrained then
    self.RKSStoreWTBL = {}
    for k,v in pairs(self:GetWeapons()) do
			local WData = {Class = v:GetClass()}
			WData.IsFromArmory = v.IsFromArmory
			WData.PrometheusGiven = v.PrometheusGiven
			WData.isPermanent = v.isPermanent
			self.RKSStoreWTBL[k] = WData
    end
    self:StripWeapons()
		self:Give("weapon_r_restrained")
    elseif !self.RKRestrained then
		self:StripWeapon("weapon_r_restrained")
    for k,v in pairs(self.RKSStoreWTBL) do
      local SWEP = self:Give(v.Class)
			SWEP.IsFromArmory = v.IsFromArmory
			SWEP.PrometheusGiven = v.PrometheusGiven
			SWEP.isPermanent = v.isPermanent
			local SWEPTable = weapons.GetStored(v.Class)
			if SWEPTable then
				local DefClip = SWEPTable.Primary.DefaultClip
				local AmmoType = SWEPTable.Primary.Ammo
				local ClipSize = SWEPTable.Primary.ClipSize
				if (DefClip and DefClip > 0) and AmmoType and ClipSize then
					local AmmoToRemove = DefClip - ClipSize
					self:RemoveAmmo(AmmoToRemove, AmmoType)
				end
			end
        end
        self.RKSStoreWTBL = {}
				self:SelectWeapon(RKS_GetConf("RESTRAINS_UnrestrainForcedWeaponSelection"))
    end
end

function PLAYER:RKSRestrain(RestrainedBy)
	local RNick = "UNKNOWN"
	local RPValid = false
	if IsValid(RestrainedBy) then
		RNick = RestrainedBy:Nick()
		RPValid = true
	end

  if !self.RKRestrained then
		if self.TBFY_Surrendered then
			self:TBFY_ToggleSurrender()
		end
    self.RKRestrained = true
    self.RestrainedBy = RestrainedBy
    RestrainedBy.RestrainedPlayer = self
		if RKS_GetConf("RESTRAINS_StarWarsRestrains") then
			self:SetupRKSBones("Restrained_StarWars")
		else
			self:SetupRKSBones("Restrained")
		end
    self:SetupRestrains()
    self:SetupRKSWeapons()
    TBFY_Notify(self, 1, 4, string.format(RKS_GetLang("RestrainedBy"), RNick))
		if RPValid then
			TBFY_Notify(RestrainedBy, 1, 4, string.format(RKS_GetLang("Restrainer"), self:Nick()))
		end
		local UnrestrainTime = RKS_GetConf("RESTRAINS_AutoUnrestrainTime")*60
		if UnrestrainTime != 0 then
			timer.Create("RKS_unrestrain_" .. TBFY_SH:SID(self), UnrestrainTime, 1, function()
				if IsValid(self) then
					self:CleanUpRKS(true, true)
					TBFY_Notify(self, 1, 4, RKS_GetLang("AutoUnrestrain"))
				end
			end)
		end
  elseif self.RKRestrained then
    self:CleanUpRKS(true, true)

    TBFY_Notify(self, 1, 4, string.format(RKS_GetLang("ReleasedBy"), RNick))
		if RPValid then
			TBFY_Notify(RestrainedBy, 1, 4, string.format(RKS_GetLang("Releaser"), self:Nick()))
		end
  end

	hook.Call("RKS_Restrain", GAMEMODE, self, RestrainedBy)
end

net.Receive("rks_unrestrain", function(len, Player)
	local TPlayer = net.ReadEntity()
	local Distance = Player:EyePos():Distance(TPlayer:GetPos());
	if Distance > 100 or !TPlayer:IsPlayer() or Player.RKRestrained then return false; end

	if TPlayer.RKRestrained then
		TPlayer:RKSRestrain(Player)
	end
end)

function PLAYER:SetupBlindfold()
	TBFY_SH:TogglePEquip(self, "blindfold", self.Blindfolded)
	net.Start("rks_blindfold")
		net.WriteBool(self.Blindfolded)
	net.Send(self)
end

function PLAYER:RKSBlindfold(BlindfoldedBy)
	if !self.RKRestrained then return end
	local Distance = BlindfoldedBy:EyePos():Distance(self:GetPos());
	if Distance > 100 then return false; end

	self.Blindfolded = !self.Blindfolded
	self:SetupBlindfold()

	if self.Blindfolded then
    TBFY_Notify(self, 1, 4, string.format(RKS_GetLang("BlindfoldedBy"), BlindfoldedBy:Nick()))
    TBFY_Notify(BlindfoldedBy, 1, 4, string.format(RKS_GetLang("Blindfolder"), self:Nick()))
	elseif !self.Blindfolded then
    TBFY_Notify(self, 1, 4, string.format(RKS_GetLang("UnBlindfoldedBy"), BlindfoldedBy:Nick()))
    TBFY_Notify(BlindfoldedBy, 1, 4, string.format(RKS_GetLang("UnBlindfolder"), self:Nick()))
	end

	hook.Call("RKS_Blindfold", GAMEMODE, self, BlindfoldedBy)
end
net.Receive("rks_blindfold", function(len, Player)
	if !Player:RKS_CanBlind() then return end
	if !IsValid(Player:GetActiveWeapon()) or Player:GetActiveWeapon():GetClass() != "weapon_r_restrains" then return false end

	local PToBlindfold = net.ReadEntity()
	if IsValid(PToBlindfold) then
		PToBlindfold:RKSBlindfold(Player)
	end
end)

function PLAYER:SetupRKSGag()
	TBFY_SH:TogglePEquip(self, "gag", self.Gagged)
end

function PLAYER:RKSGag(GaggedBy)
	if !self.RKRestrained then return end
	local Distance = GaggedBy:EyePos():Distance(self:GetPos());
	if Distance > 100 then return false; end

	if !self.Gagged then
		self.Gagged = true
		self:SetupRKSGag()
    TBFY_Notify(self, 1, 4, string.format(RKS_GetLang("GaggedBy"), GaggedBy:Nick()))
    TBFY_Notify(GaggedBy, 1, 4, string.format(RKS_GetLang("Gagger"), self:Nick()))
	elseif self.Gagged then
		self.Gagged = false
		self:SetupRKSGag()
    TBFY_Notify(self, 1, 4, string.format(RKS_GetLang("UnGaggedBy"), GaggedBy:Nick()))
    TBFY_Notify(GaggedBy, 1, 4, string.format(RKS_GetLang("UnGagger"), self:Nick()))
	end

	hook.Call("RKS_Gag", GAMEMODE, self, GaggedBy)
end
net.Receive("rks_gag", function(len, Player)
	if !Player:RKS_CanGag() then return end
	if !IsValid(Player:GetActiveWeapon()) or Player:GetActiveWeapon():GetClass() != "weapon_r_restrains" then return false end

	local PToGag = net.ReadEntity()
	PToGag:RKSGag(Player)
end)

net.Receive("rks_inspect", function(len, Player)
	if !Player:RKS_CanSteal() then return end
	if !IsValid(Player:GetActiveWeapon()) or Player:GetActiveWeapon():GetClass() != "weapon_r_restrains" then return false end

	local ToInspect = net.ReadEntity()
	if !ToInspect.RKRestrained then return end
	local Distance = Player:EyePos():Distance(ToInspect:GetPos());
	if Distance > 100 then return false; end

	local TotalWeps = #ToInspect.RKSStoreWTBL
	net.Start("rks_send_inspect_information")
		net.WriteEntity(ToInspect)
		net.WriteFloat(TotalWeps)
		for k,v in pairs(ToInspect.RKSStoreWTBL) do
			net.WriteFloat(k)
			net.WriteString(v.Class)
		end
	net.Send(Player)
end)

net.Receive("rks_stealcash", function(len, Player)
	if !DarkRP or !Player:RKS_CanSteal() then return end
	if !IsValid(Player:GetActiveWeapon()) or Player:GetActiveWeapon():GetClass() != "weapon_r_restrains" then return false end

	local StealFrom, Amount = net.ReadEntity(), net.ReadFloat()
	if !StealFrom.RKRestrained then return end
	local Distance = Player:EyePos():Distance(StealFrom:GetPos());
	if Distance > 100 then return false; end
	if StealFrom.RKSNextMoneySteal and StealFrom.RKSNextMoneySteal > CurTime() then
		local TimeLeft = math.Round(StealFrom.RKSNextMoneySteal - CurTime())
		TBFY_Notify(Player, 1, 4, string.format(RKS_GetLang("RobbCD"), StealFrom:Nick(),TimeLeft))
		return false
	end

	if RKS_GetConf("INSPECT_MoneyStealRandomAmount") then
		Amount = math.random(1,RKS_GetConf("INSPECT_MaxStolenMoney"))
	else
		Amount = math.Clamp(Amount, 0, RKS_GetConf("INSPECT_MaxStolenMoney"))
	end
	if Amount < 1 then return end
	if !StealFrom:canAfford(Amount) then
		TBFY_Notify(Player, 1, 4, string.format(RKS_GetLang("CantAfford"), StealFrom:Nick()))
		return
	end

	Player:addMoney(Amount)
	StealFrom:addMoney(-Amount)

	StealFrom.RKSNextMoneySteal = CurTime() + RKS_GetConf("INSPECT_MoneyStolenCooldown")
	TBFY_Notify(Player, 1, 4, string.format(RKS_GetLang("RobberSuccess"), Amount, StealFrom:Nick()))
	TBFY_Notify(StealFrom, 1, 4, string.format(RKS_GetLang("RobbedSuccess"), Player:Nick(), Amount))
end)

local function IsJobRanksLoadout(Player, Wep)
	local Rank = Player:GetJobRank()
	local Job = Player:Team()
	local WMatched = false

	if JobRanks and JobRanks[Job] then
		local JobTbl = JobRanks[Job]
		if JobTbl.ExtraLoadoutSingleRank and JobTbl.ExtraLoadoutSingleRank[Rank] then
			local SLoadout = JobTbl.ExtraLoadoutSingleRank[Rank]
			for k,v in pairs(SLoadout) do
				if v == Wep then
					WMatched = true
					break
				end
			end
		end
		if !WMatched and JobTbl.ExtraLoadout then
			local RLoadout = JobTbl.ExtraLoadout
			for k,v in pairs(RLoadout) do
				if v <= Rank and k == Wep then
					WMatched = true
					break
				end
			end
		end
	end
	return WMatched
end

net.Receive("rks_stealweapon", function(len, Player)
	if !Player:RKSAccess() or !RKidnapConfig.AllowStealingWeapons then return end
	if !IsValid(Player:GetActiveWeapon()) or Player:GetActiveWeapon():GetClass() != "weapon_r_restrains" then return false end

	local StealFrom, WepTblID = net.ReadEntity(), net.ReadFloat()
	if !StealFrom.RKRestrained then return end
	local Distance = Player:EyePos():Distance(StealFrom:GetPos());
	if Distance > 100 then return false; end
	if !StealFrom.RKSStoreWTBL[WepTblID] then return false end
	local WeaponClass = StealFrom.RKSStoreWTBL[WepTblID].Class

	if WeaponClass then
		if RKidnapConfig.BlackListedWeapons[WeaponClass] then return end

		local jobTable = {}
		if DarkRP then
			jobTable = StealFrom:getJobTable()
		end

		if RKidnapConfig.AllowStealingJobWeapons or (jobTable.weapons and !table.HasValue(jobTable.weapons, WeaponClass) and (!JobRanksConfig or !IsJobRanksLoadout(StealFrom, WeaponClass))) then
			Player:Give(WeaponClass)
			if CH_Armory_Locker and StealFrom.CH_ARMORY_NoDropWeapons[Wep] then
				StealFrom.CH_ARMORY_NoDropWeapons[Wep] = nil
			end
			StealFrom.RKSStoreWTBL[WepTblID] = nil
		end
	end
end)

concommand.Add("rks_togglerestrains", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	if !Args or !Args[1] then return end

	local Nick = string.lower(Args[1]);
	local PFound = false

	for k, v in pairs(player.GetAll()) do
		if (string.find(string.lower(v:Nick()), Nick)) then
			PFound = v;
			break;
		end
	end

	if PFound then
		PFound:RKSRestrain(Player)
	end
end)

hook.Add("canDropWeapon", "RKS_DisableDropWeapon", function(Player)
	if Player.RKS_BeingRestrained or Player.RKRestrained then return false end
end)

hook.Add("onDarkRPWeaponDropped", "RKS_NoDrop", function(Player, Wep, EqpWep)
	if EqpWep:GetClass() == "weapon_r_restrains" then
		Wep:SetModel("models/tobadforyou/flexcuffs_deployed.mdl")
	end
	if Player.RKS_BeingRestrained or Player.RKRestrained then
		timer.Simple(0.1, function() if IsValid(Wep) then Wep:Remove() end end)
	end
end)

local RKS_DCPlayers = RKS_DCPlayers or {}
hook.Add("PlayerInitialSpawn", "RKS_InitSpawn", function(Player)
    //Allow to intialize fully first
    timer.Simple(8, function()
		if IsValid(Player) then
			for k,v in pairs(ents.FindByClass("rrestrainsent")) do
				net.Start("rks_sendrestrains")
					net.WriteEntity(v.RestrainedPlayer)
					net.WriteEntity(v)
				net.Send(Player)
			end
			for k,v in pairs(ents.FindByClass("rblindfoldent")) do
				net.Start("rks_sendblindfold")
					net.WriteEntity(v.BlindfoldedPlayer)
					net.WriteEntity(v)
					net.WriteBool(v.Female)
				net.Send(Player)
			end
			for k,v in pairs(ents.FindByClass("rgagent")) do
				net.Start("rks_sendgag")
					net.WriteEntity(v.GaggedPlayer)
					net.WriteEntity(v)
					net.WriteBool(v.Female)
				net.Send(Player)
			end

			if RKS_GetConf("RESTRAINS_TeleportBackDisconnectPlayers") then
				local SID = Player:SteamID()
				local DCTable = RKS_DCPlayers[SID]
				if DCTable then
					local Restrainer = DCTable.Restrainer
					if IsValid(Restrainer) then
						Player:RKSRestrain(Restrainer)
						local Pos = TBFY_findEmptyPos(Restrainer:GetPos(), {Player}, 600, 30, Vector(16, 16, 64))
						Player:SetPos(Pos)
						TBFY_Notify(Player, 1, 4, RKS_GetLang("DisconnectRestrained"))
					end
					RKS_DCPlayers[SID] = nil
				end
			end
		end
    end)
end)

hook.Add("PlayerCanHearPlayersVoice", "RKS_BlockVoiceChatWhenGagged", function(Listener, Talker)
	if Talker.Gagged then
		return false
	end
end)

hook.Add("PlayerSay", "RKS_BlockChatWhenGagged", function( Player, text, public )
	if Player.Gagged then
		return ""
	end
end)

hook.Add("PlayerDeath", "RKS_ResetOnDeath", function( Player, Inflictor, Attacker )
    if Player.RKRestrained or Player.Gagged or Player.Blindfolded then
        Player:CleanUpRKS(false, true)
    end
end)

function PLAYER:CanRKSDrag(CPlayer)
    if self.RKRestrained or !CPlayer.RKRestrained or (CPlayer.RKSDraggedBy or self.RKSDragging) and (self.RKSDragging != CPlayer or CPlayer.RKSDraggedBy != self) then return end
	return true
end

local RKSPGettingDragged = {}
function PLAYER:RKSDragPlayer(TPlayer)
    if self == TPlayer.RKSDraggedBy then
        TPlayer:RKSCancelDrag()
    elseif !self.RKSDragging then
		TPlayer.RKSDraggedBy = self
        TPlayer:Freeze(true)
        self.RKSDragging = TPlayer
        if !table.HasValue(RKSPGettingDragged, TPlayer) then
            table.insert(RKSPGettingDragged, TPlayer)
        end
    end
end

function PLAYER:RKSCancelDrag()
  if table.HasValue(RKSPGettingDragged, self) then
      table.RemoveByValue(RKSPGettingDragged, self)
  end
	if IsValid(self) then
		self:Freeze(false)
		local DraggedByP = self.RKSDraggedBy
		if IsValid(DraggedByP) then
			DraggedByP.RKSDragging = nil
		end
		self.RKSDraggedBy = nil
	end
end

function PLAYER:RKS_RemoveAttatch(UnAttatchPlayer)
	local AttatchEnt = self.RKS_AEnt
	if IsValid(AttatchEnt) then
		AttatchEnt:Remove()
	end
	local AEnt = self.RKS_AttachtedTo
	if IsValid(AEnt) then
		self.RKS_AttachtedTo.AttatchedPlayer = nil
	end

	if IsValid(UnAttatchPlayer) then
		TBFY_Notify(UnAttatchPlayer, 1, 4, string.format(RKS_GetLang("UnAttatchedPlayer"), self:Nick()))
	end

	self.RKS_AEnt = nil
	self.RKS_Attatched = false
	self:SetNWEntity("RKS_AttatchEnt", nil)
	self:SetNWBool("RKS_Attatched", false)
end

function PLAYER:RKS_AttatchPlayer(APlayer, Pos, AEnt)
	if IsValid(AEnt) then
		if !RKS_GetConf("RESTRAINS_EnableAttachEntity") then
			TBFY_Notify(self, 1, 4, "Players may not be attached to entities.")
			return
		end
		if AEnt:IsVehicle() or AEnt:IsPlayer() or !IsValid(AEnt:GetPhysicsObject()) or RKidnapConfig.AttatchmentBlacklistEntities[AEnt:GetClass()] then return end
		if AEnt:GetPhysicsObject():IsMotionEnabled() then
			TBFY_Notify(self, 1, 4, RKS_GetLang("MustBeFrozen"))
			return
		end
	end

	APlayer:RKSCancelDrag()

	local AttatchEnt = APlayer.RKS_AEnt
	if !IsValid(AttatchEnt) then
		AttatchEnt = ents.Create("rks_attatch")
		AttatchEnt:Spawn()
	end

	AttatchEnt:SetPos(APlayer:GetPos())
	AttatchEnt:SetOwningPlayer(APlayer)
	AttatchEnt:SetAttatchedEntity(AEnt)
	AttatchEnt:SetAttatchPosition(Pos)
	AttatchEnt:SetParent(APlayer)

	APlayer.RKS_AEnt = AttatchEnt
	APlayer.RKS_AttachtedTo = AEnt
	AEnt.AttatchedPlayer = APlayer
	APlayer.RKS_Attatched = true

	APlayer:SetNWEntity("RKS_AttatchEnt", AttatchEnt)
	APlayer:SetNWBool("RKS_Attatched", true)

	TBFY_Notify(self, 1, 4, string.format(RKS_GetLang("AttatchedPlayer"), APlayer:Nick()))
end

hook.Add("PlayerDisconnected", "RKS_PDisconnect", function(Player)
	local Dragger = Player.RKSDraggedBy
	if IsValid(Dragger) then
		if table.HasValue(RKSPGettingDragged, Player) then
			table.RemoveByValue(RKSPGettingDragged, Player)
		end
		Dragger.RKSDragging = false
	end
	if IsValid(Player.Gag) then
		Player.Gag:Remove()
	end
	if IsValid(Player.Blindfold) then
		Player.Blindfold:Remove()
	end
	if IsValid(Player.Restrains) then
		Player.Restrains:Remove()
	end
	if IsValid(Player.RKSRagdoll) then
		Player.RKSRagdoll:Remove()
	end

	if Player.RKRestrained and RKS_GetConf("RESTRAINS_TeleportBackDisconnectPlayers") then
		local Restrainer = Player.RestrainedBy
		if IsValid(Restrainer) then
			RKS_DCPlayers[Player:SteamID()] = {Restrainer = Restrainer}
		end
	end
end)

hook.Add("PhysgunPickup", "RKS_PhysgunPickup", function(Player, Entity)
	if IsValid(Entity.AttatchedPlayer) then
		return false
	end
end)

hook.Add("CanPlayerUnfreeze", "RKS_CanUnFreezeEnt", function(Player, Entity)
	if IsValid(Entity.AttatchedPlayer) then
		return false
	end
end)

hook.Add("EntityRemoved", "RKS_EntityRemoved", function(Entity)
	if IsValid(Entity.AttatchedPlayer) then
		Entity.AttatchedPlayer:RKS_RemoveAttatch()
	end
end)


hook.Add("KeyPress", "RKS_keypress", function(Player, Key)
	if Key == IN_USE and !Player:InVehicle() then
		local Trace = {}
		Trace.start = Player:GetShootPos();
		Trace.endpos = Trace.start + Player:GetAimVector() * 100;
		Trace.filter = Player;

		local Tr = util.TraceLine(Trace);
		local TEnt = Tr.Entity

		local ValidEnt = IsValid(TEnt)
		local DraggedP = Player.RKSDragging
		if ValidEnt and TEnt:IsPlayer() then
			if TEnt:GetNWBool("RKS_Attatched", false) then
				TEnt:RKS_RemoveAttatch(Player)
			end
		elseif IsValid(DraggedP) and RKS_GetConf("RESTRAINS_EnableAttach") then
			local Pos = Tr.HitPos
			if ValidEnt then
				Pos = TEnt:GetPos()
			end
			if Pos:Distance(DraggedP:GetPos()) < 100 then
				Player:RKS_AttatchPlayer(DraggedP, Pos, TEnt)
			else
				TBFY_Notify(Player, 1, 4, RKS_GetLang("TooFarAway"))
			end
		end
  end
end)

net.Receive("rks_drag", function(len, Player)
	local TPlayer = net.ReadEntity()
	local Distance = Player:EyePos():Distance(TPlayer:GetPos());
	if Distance > 100 or !TPlayer:IsPlayer() then return false; end
	if Player:CanRKSDrag(TPlayer) then
		Player:RKSDragPlayer(TPlayer)
	end
end)

hook.Add("Think", "RKS_HandlePlayerDraggingRange", function()
	local DragRange = RKS_GetConf("DRAG_MaxRange")
		for k,v in pairs(RKSPGettingDragged) do
        if !IsValid(v) then table.RemoveByValue(RKSPGettingDragged, v) end
        local DPlayer = v.RKSDraggedBy
        if IsValid(DPlayer) then
            local Distance = v:GetPos():Distance(DPlayer:GetPos());
            if Distance > DragRange then
                v:RKSCancelDrag()
            end
        else
            v:RKSCancelDrag()
        end
    end
end)

hook.Add("CanPlayerEnterVehicle", "RKS_RestrictEnterVehicle", function(Player, Vehicle)
    if Player.RKRestrained and !Player.RKSDraggedBy then
        TBFY_Notify(Player, 1, 4, RKS_GetLang("CantEnterVehicle"))
        return false
	elseif Player.RKSDragging then
		return false
    end
end)

hook.Add("PlayerEnteredVehicle", "RKS_RestrainsVFix", function(Player,Vehicle)
    if Player.RKRestrained then
        Player:CleanUpRKS(false, false,true)
        Player.RKRestrained = true
    end
end)

hook.Add("PlayerLeaveVehicle", "RKS_LeaveVehicle", function(Player, Vehicle)
    if Player.RKRestrained then
		Player:SetupRestrains()
		if RKS_GetConf("RESTRAINS_StarWarsRestrains") then
			Player:SetupRKSBones("Restrained_StarWars")
		else
			Player:SetupRKSBones("Restrained")
		end
    end
end)

hook.Add("CanExitVehicle", "RKS_RestrictExitVehicle", function(Vehicle, Player)
    if Player.RKRestrained then
        TBFY_Notify(Player, 1, 4, RKS_GetLang("CantLeaveVehicle"))
        return false
    end
end)

hook.Add("PlayerSpawnProp", "RKS_DisablePropSpawning", function(Player)
    if Player.RKRestrained then
        TBFY_Notify(Player, 1, 4, RKS_GetLang("CantSpawnProps"))
        return false
    end
end)

hook.Add("PlayerCanPickupWeapon", "RKS_DisableWeaponPickup", function(Player, Wep)
	if Player.RKRestrained and Wep:GetClass() != "weapon_r_restrained" then return false end
end)

hook.Add("playerCanChangeTeam", "RKS_RestrictTeamChange", function(Player, Team)
    if Player.RKRestrained then return false, RKS_GetLang("CantChangeTeam") end
end)

hook.Add("CanPlayerSuicide", "RKS_DisableSuicide", function(Player)
	if Player.RKRestrained or Player.RKSKnockedOut then return false end
end)

hook.Add("NOVA_CanChangeSeat", "RKS_NovacarsDisableSeatChange", function(Player)
	if Player.RKRestrained then
		return false, RKS_GetLang("CantSwitchSeat")
	end
end)

hook.Add("VC_CanEnterPassengerSeat", "RKS_VCMOD_EnterSeat", function(Player, Seat, Vehicle)
    local DraggedPlayer = Player.RKSDragging
    if IsValid(DraggedPlayer) then
        DraggedPlayer:EnterVehicle(Seat)
        return false
    end
end)

hook.Add("VC_CanSwitchSeat", "RKS_VCMOD_SwitchSeat", function(Player, SeatFrom, SeatTo)
	if Player.RKRestrained then
		return false
	end
end)

hook.Add("PlayerHasBeenTazed", "RKS_FixRestrainsTaze", function(Player)
    if Player.RKRestrained then
        Player:CleanUpRKS(false, false,true)
        Player.RKRestrained = true
    end
end)

hook.Add("PlayerUnTazed", "RKS_FixRestrainsUnTaze", function(Player)
    if Player.RKRestrained then
        Player:SetupRestrains()
				if RKS_GetConf("RESTRAINS_StarWarsRestrains") then
					Player:SetupRKSBones("Restrained_StarWars")
				else
					Player:SetupRKSBones("Restrained")
				end
    end
end)

hook.Add("onDarkRPWeaponDropped", "RKS_RemoveRestrainsSurrOnDeath", function(Player, Ent, Wep)
	if Wep:GetClass() == "weapon_r_restrained" or Wep:GetClass() == "tbfy_surrendered" then
		Ent:Remove()
	end
end)


