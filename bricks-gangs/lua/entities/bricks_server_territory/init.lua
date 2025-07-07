AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
util.AddNetworkString("BricksGang_CaptureProgress")
util.AddNetworkString("BricksGang_CaptureComplete")
util.AddNetworkString("BricksGang_ShowStats")

-- Bayrak koruma sistemi için timer
local territoryProtection = {}

-- Gang savaş istatistikleri
local gangWarStats = {}
local statsFile = "bricks_gang_stats.txt"

-- İstatistikleri yükle
local function LoadGangStats()
    if file.Exists(statsFile, "DATA") then
        local data = file.Read(statsFile, "DATA")
        gangWarStats = util.JSONToTable(data) or {}
    end
end

-- İstatistikleri kaydet
local function SaveGangStats()
    file.Write(statsFile, util.TableToJSON(gangWarStats))
end

-- Sunucu başladığında istatistikleri yükle
hook.Add("Initialize", "BricksGang_LoadStats", LoadGangStats)

-- Gang için istatistik oluştur
local function InitGangStats(gangID)
    if not gangWarStats[gangID] then
        gangWarStats[gangID] = {
            captured = 0,
            lost = 0,
            defended = 0,
            totalCaptureTime = 0,
            lastCapture = 0,
            weeklyCaptures = {},
            members = {}
        }
    end
end

function ENT:Initialize()
	self:SetModel( "models/ogl/ogl_flag.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:GetPhysicsObject():EnableMotion( false )
	self:SetUseType( SIMPLE_USE )
end

function ENT:SetTerritoryKeyFunc( territoryKey )
	self:SetTerritoryKey( territoryKey )

	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable or not territoryTable.Claimed ) then
		self:DoMyAnimationThing( "flagdown", 1, 1 )
	end
end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate, cycle )
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		self:ResetSequence(sequenceID)
		self:SetPlaybackRate(25)
		self:ResetSequenceInfo()
		self:SetCycle( cycle or 0 )
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		return CurTime()
	end
end

function ENT:StartCapture( ply )
	if( IsValid( self:GetCaptor() ) ) then return end

	if( ply:GetPos():DistToSqr( self:GetPos() ) > BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] ) then return end

	self:SetCaptor( ply )
	self:SetCaptureEndTime( CurTime()+BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"] )
	
	ply:SetNWInt("GangID", ply:HasGang() or 0)

	self:SetPlaybackRate(-1)
	self:ResetSequence(0)

	local territoryKey = self:GetTerritoryKey()

	hook.Run( "BRS.Hooks.GangStartCapture", ply, ((BRICKS_SERVER.CONFIG.GANGS.Territories or {})[territoryKey] or {}).Name or "NIL" )
end

function ENT:StartUnCapture( ply )
	if( IsValid( self:GetCaptor() ) ) then return end

	if( ply:GetPos():DistToSqr( self:GetPos() ) > BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] ) then return end

	self:SetPlaybackRate(1)
	self:ResetSequence(0)
	
	ply:SetNWInt("GangID", ply:HasGang() or 0)

	self:SetCaptor( ply )
	self:SetUnCaptureEndTime( CurTime()+(BRICKS_SERVER.CONFIG.GANGS["Territory UnCapture Time"] or 60) )

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	local gangTable = BRICKS_SERVER_GANGS[territoryTable.GangID or 0]
	
	if( not gangTable ) then return end

	local onlineMembers = {}
	for k, v in pairs( gangTable.Members ) do
		local memberPly = player.GetBySteamID( k )
		if( IsValid( memberPly ) ) then
			table.insert( onlineMembers, memberPly )
		end
	end

	DarkRP.notify( onlineMembers, 1, 5, BRICKS_SERVER.Func.L( "gangTerritoryBeingCaptured", ((BRICKS_SERVER.CONFIG.GANGS.Territories or {})[territoryKey] or {}).Name or "NIL" ) )

	hook.Run( "BRS.Hooks.GangStartUnCapture", ply, ((BRICKS_SERVER.CONFIG.GANGS.Territories or {})[territoryKey] or {}).Name or "NIL" )
end

function ENT:Use( ply )
	local plyGangID = ply:HasGang()

	if( not plyGangID ) then return end

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	-- KORUMA KONTROLÜ
	if( territoryProtection[territoryKey] and territoryProtection[territoryKey] > CurTime() ) then
		local remainingTime = math.ceil(territoryProtection[territoryKey] - CurTime())
		DarkRP.notify( ply, 1, 5, "Bu bölge yeni ele geçirildi! " .. remainingTime .. " saniye daha bekleyin." )
		return
	end

	if( territoryTable.Claimed ) then
		if( territoryTable.GangID != plyGangID ) then
			self:StartUnCapture( ply )
		else
			DarkRP.notify( ply, 1, 5, BRICKS_SERVER.Func.L( "gangTerritoryAlready" ) )
		end
	else
		self:StartCapture( ply )
	end
end

function ENT:FinishCapture()
	if( not IsValid( self:GetCaptor() ) ) then return end

	local plyGangID = self:GetCaptor():HasGang()

	self:SetCaptor( nil )
	self:SetCaptureEndTime( 0 )

	if( not plyGangID ) then return end

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	-- İstatistikleri güncelle
	InitGangStats(plyGangID)
	gangWarStats[plyGangID].captured = (gangWarStats[plyGangID].captured or 0) + 1
	gangWarStats[plyGangID].lastCapture = os.time()

	-- Haftalık capture
	local week = os.date("%Y-%U")
	if not gangWarStats[plyGangID].weeklyCaptures[week] then
		gangWarStats[plyGangID].weeklyCaptures[week] = 0
	end
	gangWarStats[plyGangID].weeklyCaptures[week] = gangWarStats[plyGangID].weeklyCaptures[week] + 1

	-- Kaybeden gang istatistiği
	if territoryTable.GangID and territoryTable.GangID > 0 then
		InitGangStats(territoryTable.GangID)
		gangWarStats[territoryTable.GangID].lost = (gangWarStats[territoryTable.GangID].lost or 0) + 1
	end

	-- Capture eden oyuncu istatistiği
	if IsValid(self:GetCaptor()) then
		local captorSteamID = self:GetCaptor():SteamID()
		if not gangWarStats[plyGangID].members[captorSteamID] then
			gangWarStats[plyGangID].members[captorSteamID] = {
				captures = 0,
				defends = 0,
				name = self:GetCaptor():Nick()
			}
		end
		gangWarStats[plyGangID].members[captorSteamID].captures = gangWarStats[plyGangID].members[captorSteamID].captures + 1
	end

	SaveGangStats()

	BRICKS_SERVER.Func.GangCaptureTerritory( plyGangID, territoryKey )
	
	-- KORUMA SİSTEMİ: 300 saniye koruma ekle
	territoryProtection[territoryKey] = CurTime() + 300
	self:SetNWFloat("ProtectionTime", CurTime() + 300)
	
	-- Havai fişek efekti için network mesajı
    net.Start("BricksGang_CaptureComplete")
       net.WriteVector(self:GetPos())
       net.WriteInt(plyGangID, 32)
    net.Broadcast()
	
end

function ENT:FinishUnCapture()
	if( not IsValid( self:GetCaptor() ) ) then return end

	local ply = self:GetCaptor()
	local plyGangID = self:GetCaptor():HasGang()

	self:SetCaptor( nil )
	self:SetUnCaptureEndTime( 0 )

	if( not plyGangID ) then return end

	local territoryKey = self:GetTerritoryKey()
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists( territoryKey )
	if( not territoryTable ) then return end

	BRICKS_SERVER.Func.GangUnCaptureTerritory( plyGangID, territoryKey )

	self:StartCapture( ply )
end

function ENT:CancelCapture()
	if( IsValid( self:GetCaptor() ) ) then 
		DarkRP.notify( self:GetCaptor(), 1, 5, BRICKS_SERVER.Func.L( "gangCaptureFail" ) )
	end

	self:SetCaptor( nil )
	self:SetCaptureEndTime( 0 )
	self:SetUnCaptureEndTime( 0 )
	self:SetNWInt("LastProgress", 0)
end

function ENT:Think()
	if( IsValid( self:GetCaptor() ) ) then 
		-- Capture hızlandırma sistemi
		local captureRadius = math.sqrt(BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or 40000)
		local captorGangID = self:GetCaptor():GetNWInt("GangID", 0)
		local gangMembersInZone = 0
		
		-- Alandaki gang üyelerini say
		if captorGangID > 0 then
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:Alive() and ply:GetNWInt("GangID", 0) == captorGangID then
					if ply:GetPos():Distance(self:GetPos()) <= captureRadius then
						gangMembersInZone = gangMembersInZone + 1
					end
				end
			end
		end
		
		-- Hız çarpanını hesapla (1 kişi = 1x, 2 kişi = 1.5x, 3+ kişi = 2x)
		local speedMultiplier = 1
		if gangMembersInZone >= 3 then
			speedMultiplier = 2
		elseif gangMembersInZone == 2 then
			speedMultiplier = 1.5
		end
		
		-- Network değişkeni olarak gönder (HUD'da göstermek için)
		self:SetNWInt("CaptureSpeedBonus", gangMembersInZone)
		
		-- Hızlandırılmış capture kontrolü
		local timeBonus = (speedMultiplier - 1) * FrameTime()
		
		if( self:GetCaptureEndTime() > 0 ) then
			self:SetCaptureEndTime(self:GetCaptureEndTime() - timeBonus)
		elseif( self:GetUnCaptureEndTime() > 0 ) then
			self:SetUnCaptureEndTime(self:GetUnCaptureEndTime() - timeBonus)
		end
		
		-- İLERLEME BİLDİRİMİ SİSTEMİ
		local captureProgress = 0
		if self:GetCaptureEndTime() > 0 then
			captureProgress = math.floor(((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(self:GetCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]) * 100)
		elseif self:GetUnCaptureEndTime() > 0 then
			captureProgress = math.floor((1-((BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"]-(self:GetUnCaptureEndTime()-CurTime()))/BRICKS_SERVER.CONFIG.GANGS["Territory Capture Time"])) * 100)
		end
		
		-- %25, %50, %75 bildirimlerini kontrol et
		local lastProgress = self:GetNWInt("LastProgress", 0)
		
		if lastProgress < 25 and captureProgress >= 25 then
			self:SendProgressNotification(25)
			self:SetNWInt("LastProgress", 25)
		elseif lastProgress < 50 and captureProgress >= 50 then
			self:SendProgressNotification(50)
			self:SetNWInt("LastProgress", 50)
		elseif lastProgress < 75 and captureProgress >= 75 then
			self:SendProgressNotification(75)
			self:SetNWInt("LastProgress", 75)
		end
		
		-- Normal capture kontrolleri
		if( CurTime() >= (self:GetCaptureEndTime() or 0) and (self:GetUnCaptureEndTime() or 0) <= 0 ) then
			self:FinishCapture()
		elseif( CurTime() >= (self:GetUnCaptureEndTime() or 0) and (self:GetCaptureEndTime() or 0) <= 0 ) then
			self:FinishUnCapture()
		end
		
		if( not IsValid( self:GetCaptor() ) or self:GetCaptor():GetPos():DistToSqr( self:GetPos() ) > BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or not self:GetCaptor():Alive() ) then
			self:CancelCapture()
		end
	else
		self:SetNWInt("CaptureSpeedBonus", 0)
	end
	
	-- Koruma süresini güncelle
	for territoryKey, _ in pairs(territoryProtection) do
		local ent = self
		if ent:GetTerritoryKey() == territoryKey then
			if territoryProtection[territoryKey] and territoryProtection[territoryKey] > CurTime() then
				ent:SetNWFloat("ProtectionTime", territoryProtection[territoryKey])
			else
				ent:SetNWFloat("ProtectionTime", 0)
				territoryProtection[territoryKey] = nil
			end
		end
	end
end

-- İlerleme bildirimi gönder
function ENT:SendProgressNotification(percent)
	local territoryKey = self:GetTerritoryKey()
	local territoryConfig = BRICKS_SERVER.CONFIG.GANGS.Territories[territoryKey] or {}
	local territoryName = territoryConfig.Name or "Bilinmeyen Bölge"
	
	-- Capture eden gang üyelerine bildir
	local captorGangID = self:GetCaptor():GetNWInt("GangID", 0)
	if captorGangID > 0 then
		local gangTable = BRICKS_SERVER_GANGS[captorGangID]
		if gangTable then
			for k, v in pairs(gangTable.Members) do
				local memberPly = player.GetBySteamID(k)
				if IsValid(memberPly) then
					DarkRP.notify(memberPly, 0, 5, territoryName .. " %" .. percent .. " ele geçirildi!")
					
					-- Ses efekti gönder
					net.Start("BricksGang_CaptureProgress")
						net.WriteInt(percent, 8)
						net.WriteBool(true) -- Kendi gang
					net.Send(memberPly)
				end
			end
		end
	end
	
	-- Savunan gang üyelerine bildir
	local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists(territoryKey)
	if territoryTable and territoryTable.Claimed then
		local defenderGangID = territoryTable.GangID
		if defenderGangID and defenderGangID ~= captorGangID then
			local gangTable = BRICKS_SERVER_GANGS[defenderGangID]
			if gangTable then
				for k, v in pairs(gangTable.Members) do
					local memberPly = player.GetBySteamID(k)
					if IsValid(memberPly) then
						DarkRP.notify(memberPly, 1, 5, "DİKKAT! " .. territoryName .. " %" .. percent .. " ele geçiriliyor!")
						
						-- Alarm sesi gönder
						net.Start("BricksGang_CaptureProgress")
							net.WriteInt(percent, 8)
							net.WriteBool(false) -- Düşman gang
						net.Send(memberPly)
					end
				end
			end
		end
	end
end

-- Oyuncu bağlandığında gang ID'sini ayarla
hook.Add("PlayerInitialSpawn", "BricksGang_InitGangID", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) and ply:HasGang() then
            ply:SetNWInt("GangID", ply:HasGang())
        else
            ply:SetNWInt("GangID", 0)
        end
    end)
end)

-- Gang değişikliklerini takip et
hook.Add("BRS.Hooks.GangJoined", "BricksGang_UpdateGangID", function(ply, gangID)
    if IsValid(ply) then
        ply:SetNWInt("GangID", gangID or 0)
    end
end)

hook.Add("BRS.Hooks.GangLeft", "BricksGang_ClearGangID", function(ply)
    if IsValid(ply) then
        ply:SetNWInt("GangID", 0)
    end
end)

hook.Add("BRS.Hooks.GangKicked", "BricksGang_ClearGangIDKick", function(ply)
    if IsValid(ply) then
        ply:SetNWInt("GangID", 0)
    end
end)

-- Bayrak savunma bonusu sistemi
hook.Add("EntityTakeDamage", "BricksGang_TerritoryDefenseBonus", function(target, dmginfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    
    local targetGangID = target:GetNWInt("GangID", 0)
    if targetGangID == 0 then return end
    
    -- Oyuncunun yakınındaki bayrakları kontrol et
    for _, ent in ipairs(ents.FindByClass("bricks_server_territory")) do
        if not IsValid(ent) then continue end
        
        local territoryKey = ent:GetTerritoryKey()
        local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists(territoryKey)
        local captureRadius = math.sqrt(BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or 40000)
        
        -- Oyuncu bayrak alanında mı?
        if target:GetPos():Distance(ent:GetPos()) <= captureRadius then
            local giveBonus = false
            
            -- DURUM 1: Kendi bayrağının alanında
            if territoryTable and territoryTable.Claimed and territoryTable.GangID == targetGangID then
                giveBonus = true
            end
            
            -- DURUM 2: Bayrağı ele geçirmeye çalışıyor
            local captor = ent:GetCaptor()
            if IsValid(captor) then
                local captorGangID = captor:GetNWInt("GangID", 0)
                if captorGangID == targetGangID then
                    giveBonus = true
                end
            end
            
            if giveBonus then
                -- %10 hasar azaltması
                dmginfo:ScaleDamage(0.9)
                
                -- Efekt göster
                target:SetNWBool("TerritoryDefenseActive", true)
                timer.Simple(0.1, function()
                    if IsValid(target) then
                        target:SetNWBool("TerritoryDefenseActive", false)
                    end
                end)
                
                break
            end
        end
    end
end)

-- Silah reload hızı bonusu
hook.Add("WeaponEquip", "BricksGang_TerritoryReloadBonus", function(wep, ply)
    if not IsValid(wep) or not IsValid(ply) then return end
    
    timer.Simple(0.1, function()
        if not IsValid(wep) or not IsValid(ply) then return end
        
        local plyGangID = ply:GetNWInt("GangID", 0)
        if plyGangID == 0 then return end
        
        -- Oyuncunun yakınındaki bayrakları kontrol et
        for _, ent in ipairs(ents.FindByClass("bricks_server_territory")) do
            if not IsValid(ent) then continue end
            
            local territoryKey = ent:GetTerritoryKey()
            local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists(territoryKey)
            
            if territoryTable and territoryTable.Claimed and territoryTable.GangID == plyGangID then
                local captureRadius = math.sqrt(BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or 40000)
                
                -- Oyuncu kendi bayrağının alanında mı?
                if ply:GetPos():Distance(ent:GetPos()) <= captureRadius then
                    -- Reload hızını %20 artır
                    if wep.Primary and wep.Primary.DefaultReloadSpeed then
                        wep.Primary.ReloadSpeed = wep.Primary.DefaultReloadSpeed * 0.8
                    end
                    
                    ply:SetNWBool("TerritoryReloadBonus", true)
                    break
                end
            end
        end
    end)
end)

-- Oyuncu hareket ettiğinde bonusları kontrol et
hook.Add("Think", "BricksGang_CheckTerritoryBonuses", function()
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:Alive() then continue end
        
        local plyGangID = ply:GetNWInt("GangID", 0)
        if plyGangID == 0 then 
            ply:SetNWBool("InOwnTerritory", false)
            continue 
        end
        
        local inOwnTerritory = false
        
        for _, ent in ipairs(ents.FindByClass("bricks_server_territory")) do
            if not IsValid(ent) then continue end
            
            local territoryKey = ent:GetTerritoryKey()
            local territoryTable = BRICKS_SERVER.Func.GangTerritoryExists(territoryKey)
            local captureRadius = math.sqrt(BRICKS_SERVER.CONFIG.GANGS["Territory Capture Distance"] or 40000)
            
            -- DURUM 1: Kendi bayrağının alanında
            if territoryTable and territoryTable.Claimed and territoryTable.GangID == plyGangID then
                if ply:GetPos():Distance(ent:GetPos()) <= captureRadius then
                    inOwnTerritory = true
                    break
                end
            end
            
            -- DURUM 2: Bayrağı ele geçirmeye çalışıyor
            local captor = ent:GetCaptor()
            if IsValid(captor) then
                local captorGangID = captor:GetNWInt("GangID", 0)
                if captorGangID == plyGangID and ply:GetPos():Distance(ent:GetPos()) <= captureRadius then
                    inOwnTerritory = true
                    break
                end
            end
        end
        
        ply:SetNWBool("InOwnTerritory", inOwnTerritory)
    end
end)

-- Savunma başarısı kontrolü
hook.Add("BricksGang_TerritoryDefended", "RecordDefense", function(territoryKey, defenderGangID, attackerPly)
    InitGangStats(defenderGangID)
    gangWarStats[defenderGangID].defended = (gangWarStats[defenderGangID].defended or 0) + 1
    SaveGangStats()
end)

-- İstatistik komutu
concommand.Add("gang_stats", function(ply)
    if not IsValid(ply) then return end
    
    local plyGangID = ply:HasGang()
    if not plyGangID then
        ply:ChatPrint("Bir gang'e üye değilsiniz!")
        return
    end
    
    -- İstatistik paneli için network mesajı
    net.Start("BricksGang_ShowStats")
        net.WriteTable(gangWarStats)
        net.WriteInt(plyGangID, 32)
    net.Send(ply)
end)