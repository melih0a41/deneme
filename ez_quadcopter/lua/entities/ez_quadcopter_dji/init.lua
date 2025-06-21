AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:InitRadioController()
	local class = "ez_quadcopter_dji_radio_controller"
	local owner = self:CPPIGetOwner() or (self.SID and Player(self.SID)) or self:GetOwner()
	self:CPPISetOwner(owner)

	-- Delete the old quadcopter
	if owner:HasWeapon(class) then
		-- Because Give returns NULL if the player already has the weapon
		local radioController = owner:GetWeapon(class)
		if not IsValid(radioController) then return end

		if IsValid(radioController.quadcopter) then
			radioController.quadcopter:Remove()
		end
	end

	owner:Give(class)

	-- Because Give returns NULL if the player already has the weapon
	local radioController = owner:GetWeapon(class)
	if not IsValid(radioController) then return end

	owner:SelectWeapon(class)

	-- Update radio controller quadcopter
	self.radioController = radioController
    radioController.quadcopter = self
end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetMoveCollide(MOVECOLLIDE_FLY_CUSTOM)

	self:PhysWake()
	self:DropToFloor()

	-- Fizik optimizasyonu
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetDragCoefficient(0) -- Drag'ı kaldır
		phys:SetMass(50) -- Kütleyi azalt
		phys:EnableGravity(true) -- Yerçekimi açık kalsın
	end

	self.sound = CreateSound(self, "easzy/ez_quadcopter/quadcopter.wav")
	self.damage = 0
    self.lastBatteryRefresh = 0
    
    -- Akıllı yükseklik koruma sistemi
    self.targetHeight = nil
    self.lastHeightInput = 0
    self.isReceivingVerticalInput = false

	-- Collisions
	self:AddCallback("PhysicsCollide", function(ent, data)
		self:Collide(ent, data)
	end)
end

function ENT:Use(activator)
	if self.broken then
		easzy.quadcopter.RepairMenu(self, activator)
	else
		easzy.quadcopter.Menu(self, activator)
	end
end

function ENT:OnRemove()
	self.sound:Stop()
	self.on = false

	easzy.quadcopter.changeViewEntity(self, false)
end

function ENT:UpdateBattery()
    if self.battery <= 0 then
		self.sound:Stop()
		self.on = false
		return
	end

	local curTime = CurTime()
	local quadcopterClass = self:GetClass()

    -- Battery duration
    local batteryLevel = self.upgrades["Battery"]
    local battery = easzy.quadcopter.quadcoptersData[quadcopterClass].upgrades["Battery"].levels[batteryLevel]

	local velocity = self:GetVelocity():Length()

	-- Batarya tüketimini azalt (daha uzun uçuş süresi)
	self.battery = self.battery - ((curTime - self.lastBatteryRefresh) / (battery * 90)) * (20 + velocity/4)

	self.lastBatteryRefresh = curTime

	easzy.quadcopter.SyncQuadcopter(self)
end

function ENT:AutoStabilize()
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local velocity = phys:GetVelocity()
    local pos = self:GetPos()
    local angles = self:GetAngles()
    
    -- Skybox kontrolü (yukarı sınır)
    local skyboxCheck = util.TraceLine({
        start = pos,
        endpos = pos + Vector(0, 0, 100),
        filter = self
    })
    
    local isNearSkybox = skyboxCheck.Hit and skyboxCheck.Fraction < 0.5
    
    -- Skybox'a çok yakınsa aşağı kuvvet uygula
    if isNearSkybox then
        phys:AddVelocity(Vector(0, 0, -50))
    end
    
    -- Akıllı yükseklik koruma sistemi
    if self.targetHeight and self.lastHeightInput and 
       (CurTime() - self.lastHeightInput) > 1.0 and
       not self.isReceivingVerticalInput then
        
        local heightDiff = self.targetHeight - pos.z
        
        -- Sadece belirli bir tolerans dışındaysa düzelt
        if math.abs(heightDiff) > 15 then
            local correctionForce = math.Clamp(heightDiff * 0.8, -15, 15)
            phys:AddVelocity(Vector(0, 0, correctionForce))
        end
    end
    
    -- Sadece açı stabilizasyonu (çok minimal drag)
    local angleVelocity = phys:GetAngleVelocity()
    phys:SetAngleVelocity(angleVelocity * 0.98) -- Daha az dampening
    
    -- Sadece roll/pitch stabilizasyonu, yaw'ı koru (daha yumuşak)
    local targetAngles = Angle(0, angles.y, 0)
    phys:SetAngles(LerpAngle(0.05, angles, targetAngles)) -- Daha yumuşak
end

function ENT:Think()
	local owner = self:CPPIGetOwner() or (self.SID and Player(self.SID)) or self:GetOwner()
	if not self.radioController and IsValid(owner) and self.sound then
		self:InitRadioController()
	end

	if not self.on then
		easzy.quadcopter.Anim(self, "idle", 1)
	    easzy.quadcopter.toggleStamina(self, true)
		return true
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		local velocity = phys:GetVelocity()
		local velocityLenght = velocity:Length()

		self.sound:ChangePitch(100 + velocityLenght/3, .1)

		-- TAMAMEN MANUEL UÇUŞ - HİÇBİR OTOMATİK KUVVET YOK
		-- Sadece yerçekimini normale bırak, drone normal fizik kurallarına uysun
		
		local angles = phys:GetAngles()
		phys:SetAngles(Angle(angles.x, angles.y, 0))
		
		-- Sadece skybox kontrolü
		self:AutoStabilize()
	end

	easzy.quadcopter.Anim(self, "rotation", 1)
	easzy.quadcopter.StabilizeQuadcopter(self)

	self:NextThink(CurTime())
	self:UpdateBattery()
    easzy.quadcopter.toggleStamina(self, false)

	return true
end

-- Input tracking için yükseklik koruma sistemi
function ENT:OnInputReceived()
    -- Hiçbir şey yapma, sadece manuel uçuş
end

function ENT:SetVerticalInput(isReceiving, setHeight)
    self.isReceivingVerticalInput = isReceiving
    if setHeight then
        self.targetHeight = self:GetPos().z
        self.lastHeightInput = CurTime()
    end
end

-- Attach bomb to the quadcopter or recharge battery
function ENT:Touch(entity)
	local entityClass = entity:GetClass()
	if entityClass == "ez_quadcopter_bomb" then
		if not self.equipments["BombHook"] then return end

		local class = self:GetClass()
		local equipment = easzy.quadcopter.quadcoptersData[class].equipments["Bomb"]
		if not equipment then return end

		easzy.quadcopter.SetBodygroupByName(self, equipment.bodygroup, equipment.value)
		self.equipments["Bomb"] = true

		entity:Remove()

	elseif entityClass == "ez_quadcopter_battery" then
		self.battery = 100
		easzy.quadcopter.SyncQuadcopter(self)

		entity:Remove()
	end
end

function ENT:Break()
	-- In order to avoid an infinite loop
	if self.broken then return end

	self.broken = true
	self.on = false
	self.sound:Stop()

	local pos = self:GetPos()

	if self.equipments["Bomb"] or self.equipments["C4"] then
		local owner = self:CPPIGetOwner() or (self.SID and Player(self.SID))

		local explosion = EffectData()
		explosion:SetStart(pos)
		explosion:SetOrigin(pos)
		explosion:SetMagnitude(12)
		explosion:SetScale(1)
		util.Effect("Explosion", explosion, true, true)

		util.BlastDamage(self, owner or self, pos, 200, 300)
		self:Remove()
	else
		local sparks = EffectData()
		sparks:SetStart(pos)
		sparks:SetOrigin(pos)
		sparks:SetMagnitude(2)
		sparks:SetScale(1)
		util.Effect("ElectricSpark", sparks, true, true)

		easzy.quadcopter.SyncQuadcopter(self)
	end
end

function ENT:OnTakeDamage(dmginfo)
	self.damage = self.damage + dmginfo:GetDamage()
    -- Dayanıklılığı 4 kat artır (60'dan 240'a)
    if self.damage > 240 then
        self:Break()
    end
end

function ENT:Collide(_, data)
	local collisionSpeed = data["HitSpeed"]:Length()
	local speedDifference = (data["OurNewVelocity"] - data["OurOldVelocity"]):Length()
	local hitNormal = data["HitNormal"]

	local collisionIsVertical = (hitNormal - Vector(0, 0, -1)):Length() < 0.1

    local quadcopterClass = self:GetClass()

	-- Resistance - çarpışma toleransını artır
    local resistanceLevel = self.upgrades["Resistance"]
    local resistance = easzy.quadcopter.quadcoptersData[quadcopterClass].upgrades["Resistance"].levels[resistanceLevel]

	-- Çarpışma eşiklerini 3 kat artır
	if collisionSpeed > (300 * resistance) and speedDifference > (240 * resistance) and not collisionIsVertical then
		self:Break()
	end
end