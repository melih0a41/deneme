ENT.Type = "anim"
ENT.SH_IsSZ = true

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetSolid(SOLID_BBOX)
	self:DrawShadow(false)

	if (SERVER) then
		self:SetTrigger(true)
	end

	self.m_Players = {}
	self.m_Entities = {}

	self:OnInitialize()
end

function ENT:OnRemove()
	for k, v in pairs (self.m_Entities) do
		if (IsValid(v)) then
			self:EndTouch(v)
		end
	end
end

function ENT:Think()
	if (SH_SZ.ZoneHitboxesDeveloper) then
		if (self.m_Shape == "cube") then
			local min, max = self:GetCollisionBounds()
			debugoverlay.Box(self:GetPos(), min, max, 0.12, Color(255, 255, 255, 125))
		elseif (self.m_Shape == "sphere") then
			debugoverlay.Sphere(self:GetPos(), self.m_fSize, 0.12, Color(255, 255, 255, 125))
		end
	end
	
	for k, v in pairs (self.m_Players) do
		if (!IsValid(v)) then
			self.m_Players[k] = nil
		end
	end
	
	for k, v in pairs (self.m_Entities) do
		if (!IsValid(v)) then
			self.m_Entities[k] = nil
		end
	end

	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:SetupCube(a, b, size)
	local center = Vector(a.x + b.x, a.y + b.y, a.z + b.z) / 2
	self:SetPos(center)

	local a, b = self:WorldToLocal(a), self:WorldToLocal(b)
	OrderVectors(a, b)
	self:SetCollisionBounds(a, b + Vector(0, 0, size))

	self.m_Shape = "cube"
end

function ENT:SetupSphere(center, size)
	local m = Vector(size, size, size)

	self:SetPos(center)
	self:SetCollisionBounds(-m, m)

	self.m_Shape = "sphere"
end

function ENT:Touch(ent)
	if (!IsValid(ent) or ent.IsZone) then
		return end

	if (!self:PassesZoneFilter(ent)) then
		if (self.m_Entities[tostring(ent)]) then
			self:EndTouch(ent)
		end

		return
	end

	if (self.m_Entities[tostring(ent)]) then
		return end

	if (ent:IsPlayer() and ent:Alive()) then
		self.m_Players[ent:SteamID()] = ent
	end

	self.m_Entities[tostring(ent)] = ent

	self:OnZoneEntered(ent)
end

function ENT:EndTouch(ent)
	local call = false
	if (ent:IsPlayer()) then
		call = self.m_Players[ent:SteamID()] ~= nil
		self.m_Players[ent:SteamID()] = nil
	end

	if (self.m_Entities[tostring(ent)]) then
		call = true
		self.m_Entities[tostring(ent)] = nil
	end

	if (call) then
		self:OnZoneExited(ent)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end

function ENT:OnInitialize()
end

function ENT:OnZoneEntered(ent)
	if (ent:IsPlayer()) then
		SH_SZ:EnterSafeZone(ent, self)
	end

	if (ent:IsNPC() and self.m_Options.nonpc) then
		SafeRemoveEntity(ent)
-- ... (önceki if veya elseif bloğu) ...

	elseif (ent:IsVehicle()) then
		local driver = ent:GetDriver()
		local shouldDeleteVehicle = true -- Varsayılan olarak aracı sil
		
		-- Araç Whitelist Başlangıcı
if ent:GetClass() == "zlm_tractor" or ent:GetClass() == "zlm_tractor_trailer" then
    shouldDeleteVehicle = false
end


		if IsValid(driver) and driver:IsPlayer() then
			-- 1. Admin/Yetkili Kullanıcı Grubu Kontrolü (Orijinal mantık gibi)
			if SH_SZ.Usergroups and SH_SZ.Usergroups[driver:GetUserGroup()] then
				shouldDeleteVehicle = false -- Eğer yetkili gruptaysa, aracı silme
			else
				-- 2. İzin Verilen Meslek Kontrolü
				-- DarkRP ve DarkRP.teams tablosunun yüklü olduğundan emin olalım
				if DarkRP and DarkRP.teams and driver:Team() and DarkRP.teams[driver:Team()] then
					local jobCommand = DarkRP.teams[driver:Team()].command
					-- Yapılandırmada tanımlı AllowedVehicleJobs tablosu ve içinde meslek komutu var mı?
					if SH_SZ.AllowedVehicleJobs and SH_SZ.AllowedVehicleJobs[jobCommand] then
						shouldDeleteVehicle = false -- Eğer izin verilen meslekteyse, aracı silme
					end
				end
			end
		else
			-- Geçerli bir oyuncu sürücü yoksa (araç boş veya NPC kullanıyor olabilir)
			-- Orijinal kod, geçerli sürücü yoksa siliyordu. Bu mantığı korumak için
			-- shouldDeleteVehicle = true olarak kalır.
			-- Eğer boş araçların da kalmasını istiyorsanız, buraya ek bir kontrol ekleyebilirsiniz.
			-- Örneğin: shouldDeleteVehicle = false -- Boş araçlar da silinmesin
		end

		if shouldDeleteVehicle then
			if IsValid(driver) then
				driver:ExitVehicle() -- Sürücüyü araçtan at (isteğe bağlı)
			end
			SafeRemoveEntity(ent) -- Aracı sil
		end
-- ... (sonraki elseif bloğu bu satırdan sonra gelmeli) ...
	elseif (ent.SH_SpawnedBy) then
		local owner = ent.SH_SpawnedBy
		if (self.m_Options.noprop and not (IsValid(owner) and SH_SZ.Usergroups[owner:GetUserGroup()])) then
			// 76561198173808733
			SafeRemoveEntity(ent)
		end
	end
end

function ENT:OnZoneExited(ent)
	if (ent:IsPlayer()) then
		SH_SZ:ExitSafeZone(ent, self)
	end
end

function ENT:PassesZoneFilter(ent)
	if (self.m_Shape == "sphere") then
		local pos = ent:GetPos():Distance(self:GetPos())
		return pos <= self.m_fSize
	end

	return true
end