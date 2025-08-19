-- Konum: kidnap_system/lua/weapons/weapon_kidnap_pro.lua

AddCSLuaFile()

SWEP.ClassName = "weapon_kidnap"
SWEP.PrintName = "Kaçırma Aleti PRO"
SWEP.Author = "Phantaso"
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

-- Server tarafında cooldown sistemi (sadece bir kez tanımla)
if SERVER and not _G.KidnapCooldownSystemLoaded then
    _G.KidnapCooldownSystemLoaded = true
    
    util.AddNetworkString("KidnapCooldownUpdate")
    util.AddNetworkString("KidnapCooldownNotify")
    
    -- Cooldown verileri - os.time() kullanacağız
    _G.KidnapCooldowns = _G.KidnapCooldowns or {}
    _G.KidnapActiveTargets = _G.KidnapActiveTargets or {}
    _G.KidnapLastTargets = _G.KidnapLastTargets or {}
    local COOLDOWN_TIME = 15 * 60 -- 15 dakika
    
    -- Dosya yolu (pro versiyon için ayrı dosya)
    local dataPath = "kidnap_pro_cooldowns.txt"
    
    -- Veriyi kaydet
    _G.SaveKidnapProCooldowns = function()
        local dataToSave = {
            cooldowns = _G.KidnapCooldowns,
            lastTargets = _G.KidnapLastTargets
        }
        file.Write(dataPath, util.TableToJSON(dataToSave))
    end
    
    -- Veriyi yükle
    local function LoadKidnapProCooldowns()
        if file.Exists(dataPath, "DATA") then
            local data = file.Read(dataPath, "DATA")
            if data then
                local loadedData = util.JSONToTable(data) or {}
                local currentTime = os.time()
                
                -- Cooldown'ları temizle ve yükle
                _G.KidnapCooldowns = {}
                if loadedData.cooldowns then
                    for steamID, cooldownTime in pairs(loadedData.cooldowns) do
                        -- Hala geçerli olan cooldown'ları sakla
                        if (currentTime - cooldownTime) < COOLDOWN_TIME then
                            _G.KidnapCooldowns[steamID] = cooldownTime
                        end
                    end
                end
                
                -- Son hedefleri yükle
                _G.KidnapLastTargets = loadedData.lastTargets or {}
                
                -- Temizlenmiş veriyi kaydet
                _G.SaveKidnapProCooldowns()
            end
        end
    end
    
    -- Sunucu başladığında veriyi yükle
    hook.Add("Initialize", "LoadKidnapProCooldowns", function()
        timer.Simple(1, LoadKidnapProCooldowns)
    end)
    
    -- Oyuncu ayrıldığında veriyi kaydet
    hook.Add("PlayerDisconnected", "SaveKidnapProCooldownOnLeave", function(ply)
        _G.SaveKidnapProCooldowns()
    end)
    
    -- Sunucu kapandığında veriyi kaydet
    hook.Add("ShutDown", "SaveKidnapProCooldownsOnShutdown", _G.SaveKidnapProCooldowns)
    
    -- Her 5 dakikada bir otomatik kaydet
    timer.Create("AutoSaveKidnapProCooldowns", 300, 0, _G.SaveKidnapProCooldowns)
    
    -- Kidnap yapamayan meslekler
    local NO_KIDNAP_TEAMS = {
        TEAM_SIVIL, TEAM_MARTI, TEAM_ZGW_GOLDWASHER, TEAM_COCUK, TEAM_ZPIZ_CHEF,
        TEAM_ZTM_TRASHMAN, TEAM_ZRUSH_FUELPRODUCER, TEAM_GITARCI, TEAM_PALYACO,
        TEAM_EVSIZ, TEAM_GANYAN, TEAM_BANKACI, TEAM_GUVENLIK, TEAM_CASINOSAHIBI,
        TEAM_SILAHSATICISI, TEAM_DJ, TEAM_OBEZ,
        TEAM_BASKAN, TEAM_POLIS, TEAM_BASKOMISER, TEAM_AMIR, TEAM_POH,
        TEAM_POHSIHHIYE, TEAM_POHKESKIN, TEAM_POHKOMUTANI, TEAM_DRONEPOLIS,
        TEAM_BASKANKORUMASI, TEAM_DOKTOR, TEAM_AVUKAT, TEAM_HAKIM,
        TEAM_ZMLAB2_COOK, TEAM_GRAFITICI, TEAM_ZGO2_AMATEUR, TEAM_KAPKACCI,
        TEAM_TETIKCI, TEAM_HIRSIZ, TEAM_SOYGUNCU,
        TEAM_GECEKULUBU, TEAM_GECEKULUBUCALISANI, TEAM_GROVE, TEAM_BALLAS, TEAM_VAGOS,
        TEAM_KARABORSACI, TEAM_PROFTETIKCI, TEAM_POHAGIRZIRH, TEAM_ZGO2_PRO,
        TEAM_ISADAMI, TEAM_BITCOIN, TEAM_HAYDUTIHA, TEAM_YETKILI
    }
    
    -- Cooldown kontrolü - os.time() kullanarak
    _G.CanPlayerKidnap = function(ply)
        local steamID = ply:SteamID()
        local currentTime = os.time()
        
        if _G.KidnapCooldowns[steamID] then
            local timeDiff = currentTime - _G.KidnapCooldowns[steamID]
            if timeDiff < COOLDOWN_TIME then
                return false, COOLDOWN_TIME - timeDiff
            else
                -- Cooldown bittiyse temizle
                _G.KidnapCooldowns[steamID] = nil
                _G.SaveKidnapProCooldowns()
            end
        end
        return true, 0
    end
    
    -- Meslek kontrolü
    _G.CanTeamKidnap = function(ply)
        local playerTeam = ply:Team()
        for _, teamID in pairs(NO_KIDNAP_TEAMS) do
            if playerTeam == teamID then
                return false
            end
        end
        return true
    end
    
    -- Cooldown ayarla - os.time() kullanarak
    _G.SetKidnapCooldown = function(ply)
        local steamID = ply:SteamID()
        _G.KidnapCooldowns[steamID] = os.time()
        
        net.Start("KidnapCooldownUpdate")
        net.WriteFloat(COOLDOWN_TIME)
        net.Send(ply)
        
        -- Veriyi hemen kaydet
        _G.SaveKidnapProCooldowns()
    end
    
    -- Oyuncu spawn olduğunda cooldown bilgisini gönder
    hook.Add("PlayerSpawn", "SendKidnapProCooldown", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                local steamID = ply:SteamID()
                if _G.KidnapCooldowns[steamID] then
                    local currentTime = os.time()
                    local timeDiff = currentTime - _G.KidnapCooldowns[steamID]
                    local remainingTime = COOLDOWN_TIME - timeDiff
                    
                    if remainingTime > 0 then
                        net.Start("KidnapCooldownUpdate")
                        net.WriteFloat(remainingTime)
                        net.Send(ply)
                    else
                        -- Cooldown bittiyse temizle
                        _G.KidnapCooldowns[steamID] = nil
                        _G.SaveKidnapProCooldowns()
                    end
                end
            end
        end)
    end)
    
    -- Oyuncu ilk bağlandığında cooldown kontrolü
    hook.Add("PlayerInitialSpawn", "CheckKidnapProCooldownOnJoin", function(ply)
        timer.Simple(2, function()
            if IsValid(ply) then
                local steamID = ply:SteamID()
                if _G.KidnapCooldowns[steamID] then
                    local currentTime = os.time()
                    local timeDiff = currentTime - _G.KidnapCooldowns[steamID]
                    local remainingTime = COOLDOWN_TIME - timeDiff
                    
                    if remainingTime > 0 then
                        net.Start("KidnapCooldownUpdate")
                        net.WriteFloat(remainingTime)
                        net.Send(ply)
                    else
                        -- Cooldown bittiyse temizle
                        _G.KidnapCooldowns[steamID] = nil
                        _G.SaveKidnapProCooldowns()
                    end
                end
            end
        end)
    end)
    
    -- Debug komutları
    concommand.Add("kidnap_pro_cooldown_list", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        print("=== Active Kidnap PRO Cooldowns ===")
        local currentTime = os.time()
        for steamID, cooldownTime in pairs(_G.KidnapCooldowns) do
            local remaining = COOLDOWN_TIME - (currentTime - cooldownTime)
            if remaining > 0 then
                print(string.format("%s: %d seconds remaining", steamID, remaining))
            end
        end
    end)
    
    concommand.Add("kidnap_pro_cooldown_clear", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        if args[1] then
            local targetSteamID = args[1]
            if _G.KidnapCooldowns[targetSteamID] then
                _G.KidnapCooldowns[targetSteamID] = nil
                _G.SaveKidnapProCooldowns()
                print("Cleared PRO cooldown for: " .. targetSteamID)
            else
                print("No PRO cooldown found for: " .. targetSteamID)
            end
        else
            _G.KidnapCooldowns = {}
            _G.KidnapLastTargets = {}
            _G.SaveKidnapProCooldowns()
            print("All kidnap PRO cooldowns cleared!")
        end
    end)
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    local ply = self.Owner

    -- Sadece aktif kurban varsa SWEP cooldown'unu kontrol et
    if self.Cooldown and IsValid(self.Victim) then
        ply:ChatPrint("Kaçırma Aleti bekleme süresinde!")
        return
    end

    if IsValid(self.Victim) then
        ply:ChatPrint("Zaten birini kaçırıyorsunuz! (SWEP Referansı)")
        return
    end

    -- Meslek kontrolü
    if not _G.CanTeamKidnap(ply) then
        net.Start("KidnapCooldownNotify")
        net.WriteString("Bu meslekteyken kidnap yapamazsın!")
        net.Send(ply)
        return
    end
    
    local target = ply:GetEyeTrace().Entity
    
    -- Hedef kontrolü
    if not (IsValid(target) and target:IsPlayer() and target:Alive() and ply:GetPos():DistToSqr(target:GetPos()) < 10000) then
        ply:ChatPrint("Menzilde geçerli veya canlı hedef yok.")
        return
    end
    
    -- Cooldown kontrolü - ama son kaçırdığı kişi değilse
    local steamID = ply:SteamID()
    local lastTarget = _G.KidnapLastTargets[steamID]
    local isRetryingSameTarget = (lastTarget == target:SteamID()) -- SteamID karşılaştır
    
    -- Eğer hiç kaçırmadı veya farklı birini kaçırmaya çalışıyorsa cooldown kontrol et
    if not isRetryingSameTarget then
        local canKidnap, remainingTime = _G.CanPlayerKidnap(ply)
        if not canKidnap then
            local minutes = math.floor(remainingTime / 60)
            local seconds = math.floor(remainingTime % 60)
            
            net.Start("KidnapCooldownNotify")
            net.WriteString(string.format("Kidnap yapmak için %02d:%02d daha beklemelisin!", minutes, seconds))
            net.Send(ply)
            return
        end
    end

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

    self.VictimRagdoll = ragdoll
    self.Victim = target
    ply:ChatPrint(target:Nick() .. " adlı oyuncuyu kaçırıp ragdoll yaptınız!")
    target:ChatPrint(ply:Nick() .. " tarafından kaçırıldınız!")

    _G.KidnapData[target] = {
        ragdoll = ragdoll,
        timer = CurTime() + 30, -- 30 saniye PRO versiyon
        kidnapper = ply,
        ragdoll_pos = ragdoll:GetPos(),
        swep_instance = self,
        weapons = saved_weapons
    }

    -- YENİ EKLENEN KOD BAŞLANGICI
    hook.Run("OnPlayerKidnapped", target)
    -- YENİ EKLENEN KOD SONU

    -- Timer'ı başlat (aktif kidnap var)
    if timer.Exists("KidnapperCheckPro") then
        timer.UnPause("KidnapperCheckPro")
    end

    -- Cooldown sistemini tetikle
    if not isRetryingSameTarget then
        _G.KidnapActiveTargets[steamID] = target
        _G.KidnapLastTargets[steamID] = target:SteamID() -- SteamID olarak kaydet
        
        -- Otomatik advert
        ply:ConCommand("say /advert Kidnap!")
        
        -- Cooldown başlat
        _G.SetKidnapCooldown(ply)
        
        net.Start("KidnapCooldownNotify")
        net.WriteString("Otomatik kidnap duyurusu yapıldı ve cooldown başlatıldı!")
        net.Send(ply)
        
        -- SWEP cooldown
        self.Cooldown = true
        timer.Simple(180, function()
            if IsValid(self) then
                self.Cooldown = false
                if IsValid(self.Owner) then
                    self.Owner:ChatPrint("Kaçırma Aleti tekrar kullanıma hazır.")
                end
            end
        end)
    else
        -- Aynı hedef için sadece kısa bir cooldown
        self.Cooldown = true
        timer.Simple(3, function()
            if IsValid(self) then
                self.Cooldown = false
            end
        end)
        
        ply:ChatPrint("Aynı kişiyi tekrar kaçırıyorsunuz.")
    end
    
    -- Veriyi kaydet
    _G.SaveKidnapProCooldowns()
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
    local saved_weapons = nil

    if IsValid(ragdoll) then
        ragdoll_pos = ragdoll:GetPos()
        ragdoll:Remove()
    end

    if _G.KidnapData[target] then
        saved_weapons = _G.KidnapData[target].weapons
        _G.KidnapData[target] = nil
    end

    -- Cooldown listesinden temizle
    if IsValid(owner) then
        local steamID = owner:SteamID()
        if _G.KidnapActiveTargets and _G.KidnapActiveTargets[steamID] == target then
            _G.KidnapActiveTargets[steamID] = nil
        end
    end

    if IsValid(target) then
        -- YENİ EKLENEN KOD BAŞLANGICI
        hook.Run("OnPlayerReleased", target)
        -- YENİ EKLENEN KOD SONU
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
    HOOKS - Sunucu Tarafı Kontroller (OPTİMİZE EDİLMİŞ)
-----------------------------------------------------------]]
if SERVER then
    -- OPTİMİZE EDİLMİŞ TIMER SİSTEMİ (PRO VERSİYON)
    timer.Create("KidnapperCheckPro", 0.5, 0, function()
        -- Aktif kidnap yoksa timer'ı durdur (CPU tasarrufu)
        if not _G.KidnapData or table.Count(_G.KidnapData) == 0 then
            timer.Pause("KidnapperCheckPro")
            return
        end
        
        local targets_to_check = {}
        for target, _ in pairs(_G.KidnapData) do
            if IsValid(target) then
                table.insert(targets_to_check, target)
            else
                _G.KidnapData[target] = nil
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
                local saved_weapons = data.weapons

                _G.KidnapData[target] = nil

                -- Cooldown listesinden temizle
                if IsValid(kidnapper) then
                    local steamID = kidnapper:SteamID()
                    if _G.KidnapActiveTargets and _G.KidnapActiveTargets[steamID] == target then
                        _G.KidnapActiveTargets[steamID] = nil
                    end
                end

                if IsValid(ragdoll) then
                    ragdoll:Remove()
                end

                if IsValid(swep_instance) then
                    swep_instance.Victim = nil
                    swep_instance.VictimRagdoll = nil
                end

                if IsValid(target) then
                    -- YENİ EKLENEN KOD BAŞLANGICI
                    hook.Run("OnPlayerReleased", target)
                    -- YENİ EKLENEN KOD SONU
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
                data.ragdoll_pos = data.ragdoll:GetPos()
            end
        end
        
        -- Hala aktif kidnap yoksa timer'ı durdur
        if table.Count(_G.KidnapData) == 0 then
            timer.Pause("KidnapperCheckPro")
        end
    end)

    -- Oyuncu oyundan çıktığında ragdoll'u sil ve veriyi temizle
    hook.Add("PlayerDisconnected", "KidnapCleanupOnDisconnectPro", function(ply, reason)
        if _G.KidnapData and _G.KidnapData[ply] then
            local data = _G.KidnapData[ply]

            if IsValid(data.ragdoll) then
                data.ragdoll:Remove()
            end

            _G.KidnapData[ply] = nil
        end
        
        -- Cooldown listesinden temizle
        local steamID = ply:SteamID()
        if _G.KidnapActiveTargets then
            _G.KidnapActiveTargets[steamID] = nil
        end
        
        -- Veriyi kaydet
        _G.SaveKidnapProCooldowns()
    end)

end

-- Client tarafında panel çizimi
if CLIENT then
    -- Local değişkenler
    local kidnapCooldownEndTime = 0
    local isShowingKidnapCooldown = false
    local totalCooldownTime = 15 * 60
    local cooldownStartTime = 0
    
    -- Network mesajlarını al
    if not _G.KidnapNetworkReceiversLoaded then
        _G.KidnapNetworkReceiversLoaded = true
        
        net.Receive("KidnapCooldownUpdate", function()
            local cooldownTime = net.ReadFloat()
            if cooldownTime > 0 then
                kidnapCooldownEndTime = CurTime() + cooldownTime
                cooldownStartTime = CurTime()
                totalCooldownTime = cooldownTime
                isShowingKidnapCooldown = true
            end
        end)
        
        net.Receive("KidnapCooldownNotify", function()
            local message = net.ReadString()
            chat.AddText(Color(255, 165, 0), "[Kidnap Sistemi] ", Color(255, 255, 255), message)
            surface.PlaySound("buttons/button10.wav")
        end)
    end
    
    -- Modern panel çizimi
    local function DrawKidnapCooldownPanel()
        if not isShowingKidnapCooldown then return end
        
        local currentTime = CurTime()
        local remainingTime = kidnapCooldownEndTime - currentTime
        
        if remainingTime <= 0 then
            isShowingKidnapCooldown = false
            chat.AddText(Color(100, 255, 100), "[Kidnap Sistemi] ", Color(255, 255, 255), "Artık tekrar kidnap yapabilirsin!")
            surface.PlaySound("buttons/button9.wav")
            return
        end
        
        local scrW, scrH = ScrW(), ScrH()
        
        -- Panel boyutları
        local panelW = 300
        local panelH = 60
        local panelX = (scrW - panelW) / 2
        local panelY = 120 -- Mug panelinin altında
        
        -- Panel animasyonu
        local alpha = 240
        if remainingTime < 5 then
            alpha = math.min(240, remainingTime * 48)
        elseif (currentTime - cooldownStartTime) < 1 then
            alpha = math.min(240, (currentTime - cooldownStartTime) * 240)
        end
        
        -- Ana panel arka planı
        draw.RoundedBox(8, panelX, panelY, panelW, panelH, Color(30, 30, 30, alpha))
        
        -- Üst çizgi (accent) - Son 30 saniyede renk değişimi
        local accentColor = Color(255, 165, 0, alpha)
        if remainingTime <= 30 then
            local pulse = math.sin(currentTime * 3) * 0.5 + 0.5
            accentColor = Color(255, 165 + (35 * pulse), 0, alpha)
        end
        draw.RoundedBox(8, panelX, panelY, panelW, 4, accentColor)
        
        -- Zaman hesaplama
        local minutes = math.floor(remainingTime / 60)
        local seconds = math.floor(remainingTime % 60)
        local timeText = string.format("%02d:%02d", minutes, seconds)
        
        -- Başlık - PRO etiketi ekle
        draw.SimpleText("KIDNAP COOLDOWN [PRO]", "DermaDefaultBold", panelX + panelW/2, panelY + 15, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Zaman gösterimi - Son 10 saniyede turuncu yanıp sönme
        local timeColor = Color(255, 165, 0, alpha)
        if remainingTime <= 10 then
            local pulse = math.sin(currentTime * 5) * 0.5 + 0.5
            timeColor = Color(255, 165 + (90 * pulse), 0, alpha)
        end
        draw.SimpleText(timeText, "DermaLarge", panelX + panelW/2, panelY + 35, timeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Progress bar
        local progressW = panelW - 20
        local progressH = 4
        local progressX = panelX + 10
        local progressY = panelY + panelH - 10
        
        -- Progress bar arka plan
        draw.RoundedBox(2, progressX, progressY, progressW, progressH, Color(60, 60, 60, alpha))
        
        -- Progress bar dolgu
        local progress = 1 - (remainingTime / totalCooldownTime)
        local fillW = progressW * progress
        
        fillW = math.max(0, math.min(progressW, fillW))
        
        draw.RoundedBox(2, progressX, progressY, fillW, progressH, accentColor)
        
        -- Yüzde gösterimi
        local percentage = math.floor(progress * 100)
        draw.SimpleText(percentage .. "%", "Default", panelX + panelW - 15, panelY + panelH - 15, Color(200, 200, 200, alpha * 0.7), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
    
    -- Panel çizimini hook'la
    if not _G.KidnapHUDHookLoaded then
        _G.KidnapHUDHookLoaded = true
        hook.Add("HUDPaint", "DrawKidnapCooldownPanelMain", DrawKidnapCooldownPanel)
    end
    
    -- Chat komutları için yardım
    if not _G.KidnapInitHookLoaded then
        _G.KidnapInitHookLoaded = true
        hook.Add("Initialize", "KidnapCooldownClientInitMain", function()
            timer.Simple(3, function()
                chat.AddText(Color(255, 165, 0), "[Kidnap Sistemi] ", Color(255, 255, 255), "Kidnap PRO cooldown sistemi aktif!")
            end)
        end)
    end
    
    -- Debug komutları (client)
    concommand.Add("kidnap_pro_status", function()
        if isShowingKidnapCooldown then
            local remaining = kidnapCooldownEndTime - CurTime()
            print("Kidnap PRO Cooldown Active - Remaining:", math.floor(remaining), "seconds")
        else
            print("No active kidnap PRO cooldown")
        end
    end)
end