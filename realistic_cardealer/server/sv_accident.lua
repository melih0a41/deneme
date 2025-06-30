/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

local PLAYER = FindMetaTable("Player")

--[[ Apply force on the physic ]]
function RCD.PhysicsUpdate(phys, vehc)
    if not IsValid(phys) or not IsValid(vehc) then return end

    local vehcAngle = vehc:GetAngles()

	local force = (vehcAngle:Right() - vehcAngle:Up()*0.5)*-30000 
	local dt = engine.TickInterval()
    phys:ApplyForceCenter(force*dt)
end

--[[ Take/Remove security belt of the player ]]
function PLAYER:RCDSecurityBelt()
    local canChange = hook.Run("RCD:CanChangeBelt", self)
    if canChange == false then return end
    
    local vehc = self:GetVehicle()
    if not IsValid(vehc) or not RCD.IsVehicle(vehc) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb
    
    if RCD.GetVehicleParams(vehc.RCDUniqueId, "disableBeltVehicle") then return end

    local securityBelt = !RCD.GetNWVariables("RCDSecurityBelt", self)

    RCD.SetNWVariable("RCDSecurityBelt", securityBelt, self, true, self)
    self:EmitSound(securityBelt and "rcd_sounds/securitybelt01.wav" or "rcd_sounds/securitybelt02.wav")

    if securityBelt then self:StopSound("rcd_sounds/beltsound.mp3") end

    if not securityBelt then
        self.RCD["beltSound"] = false
    end

    hook.Run("RCD:SecurityBelt", self, securityBelt)

    return true, securityBelt
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499

--[[ Change the vehicle engine statut ]]
function RCD.ChangeVehicleStatut(vehc, start)
    if not IsValid(vehc) then return end
    if RCD.GetVehicleParams(vehc.RCDUniqueId, "disableEngineVehicle") then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d776bffa5f4877e1932ea2ae85d2defcb43da64563501d27971f841c3cccd8a0
    
    local canStart = (RCD.CompatibilitiesOptions["saveHealth"]["get"](vehc) > 0)
    
    --[[ This two function work on basic vehicle ]]
    if vehc.EnableEngine && canStart then
        vehc:EnableEngine(start)
    end

    if vehc.StartEngine && canStart then
        vehc:StartEngine(start)
    end

    --[[ This function is used for simfphys vehicle ]]
    if vehc.SetActive && canStart then
        vehc:SetActive(start)
    end
    
    if not start then
        --[[ This function is used for simfphys vehicle ]]
        if vehc.StopEngine then
            vehc:StopEngine()
        end
        
        if timer.Exists("rcd_start_engine:"..vehc:EntIndex()) then
            timer.Remove("rcd_start_engine:"..vehc:EntIndex()) 
        end
    end
end

--[[ Start/Stop engine of the vehicle ]]
function PLAYER:RCDVehicleEngine()
    local vehc = RCD.GetVehicle(self:GetVehicle())
    if not IsValid(vehc) or not RCD.IsVehicle(vehc) then return end

    if vehc:GetDriver() != self then return end

    if RCD.GetVehicleParams(vehc.RCDUniqueId, "disableEngineVehicle") then return end

    local canChange = hook.Run("RCD:CanChangeEngine", vehc)
    if canChange == false then self:RCDNotification(5, RCD.GetSentence("startEngineProblem")) return end

    local engineStatut = !RCD.GetNWVariables("RCDEngine", vehc)
    RCD.SetNWVariable("RCDEngine", engineStatut, vehc, true, self)

    vehc:EmitSound(engineStatut and "rcd_sounds/startengine.wav" or "rcd_sounds/carstop.wav")
    vehc:StopSound("rcd_sounds/nitro.wav")

    if engineStatut then
        local engineTime = RCD.GetSetting("engineTime", "number")

        timer.Create("rcd_start_engine:"..vehc:EntIndex(), engineTime, 1, function()
            if not IsValid(vehc) then return end

            RCD.ChangeVehicleStatut(vehc, engineStatut)
        end)
    else
        RCD.ChangeVehicleStatut(vehc, engineStatut)
    end

    hook.Run("RCD:Engine", self, engineStatut)

    return true, engineStatut
end

--[[ Set the engine statut of the vehicle ]]
function RCD.SetVehicleEngine(vehc, engineStatus, notReleaseHandBrake)
    if not IsValid(vehc) or not RCD.IsVehicle(vehc) then return end

    if RCD.GetVehicleParams(vehc.RCDUniqueId, "disableEngineVehicle") then return end
    
    --[[ Need to do this to solve some bug ]]
    timer.Create("rcd_vehicle_status:"..vehc:EntIndex(), 0, 3, function()
        if not IsValid(vehc) then return end
		if timer.RepsLeft("rcd_vehicle_status:"..vehc:EntIndex()) > 0 then return end
        
        RCD.ChangeVehicleStatut(vehc, engineStatus)
        if isfunction(vehc.ReleaseHandbrake) && not notReleaseHandBrake then
		    vehc:ReleaseHandbrake()
        end        
	end)
end

--[[ Create a ragdoll on the player ]]
function PLAYER:RCDCreateRagdoll(vehc)
    if timer.Exists("rcd_eject_people:"..self:SteamID64()) then return end
    if IsValid(self.RCD["rcd_ragdoll"]) then self.RCD["rcd_ragdoll"]:Remove() end

    local ragdoll = ents.Create("prop_physics")
    ragdoll:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    ragdoll:SetPos(self:GetPos())
    ragdoll:SetMaterial("Models/effects/vol_light001")
    ragdoll:Spawn()
    ragdoll:Activate()
    ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    local phys = ragdoll:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    
    --[[ Set the velocity of the ragdoll ]]
    timer.Create("rcd_eject_people:"..self:SteamID64(), 0.01, 1, function()
        if not IsValid(phys) or not RCD.IsVehicle(vehc) then return end
        RCD.PhysicsUpdate(phys, vehc)
    end)

    --[[ Set back the collision group of the ragdoll ]]
    timer.Simple(0.1, function()
        if not IsValid(ragdoll) then return end
        
        local phys = ragdoll:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetMass(80)
        end

        ragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0b6f3181b3d3f773c094bbb1989d20a409ffe7687773629cb85a888f51538c9

        net.Start("RCD:Main:Client")
            net.WriteUInt(14, 4)
            net.WriteEntity(ragdoll)
            net.WriteEntity(self)
        net.Broadcast()
    end)

    self.RCD["rcd_ragdoll"] = ragdoll
end

--[[ Save weapons and ammos of the player ]]
function PLAYER:RCDSaveWeapons(strip)
    local weps = {}

    self.RCD["saveInfo"] = self.RCD["saveInfo"] or {}

    for k,v in ipairs(self:GetWeapons()) do 
        weps[v:GetClass()] = {
            ["Clip1"] = v:Clip1(),
            ["Clip2"] = v:Clip2(),
        }
    end

    self.RCD["saveInfo"] = {
        ["weapon"] = weps,
        ["health"] = self:Health(),
        ["armor"] = self:Armor(),
        ["model"] = self:GetModel(),
    }

    if strip then
        self:StripWeapons()
    end
end

--[[ Restore weapons and ammos of the player ]]
function PLAYER:RCDGiveWeapons()
    self.RCD["saveInfo"] = self.RCD["saveInfo"] or {}

    local weps = self.RCD["saveInfo"]["weapon"] or {}

    for k, v in pairs(weps) do 
        local wep = self:Give(k, true)
        if not IsValid(wep) then continue end

        wep:SetClip1((v.Clip1 or 0))
        wep:SetClip2((v.Clip2 or 0))
    end 

    self:SetHealth(self.RCD["saveInfo"]["health"] or 100)
    self:SetArmor(self.RCD["saveInfo"]["armor"] or 0)

    if isstring(self.RCD["saveInfo"]["model"]) then
        self:SetModel(self.RCD["saveInfo"]["model"])
    end

    self.RCD["saveInfo"] = {}
end

--[[ Eject a player frome the vehicle ]]
function PLAYER:RCDEjectPeople()
    if not self:Alive() then return end

    local vehc = self:GetVehicle()
    if not IsValid(vehc) then return end

    timer.Simple(0, function()
        if not IsValid(self) or not IsValid(vehc) then return end
        if not self:Alive() then return end
        
        self:RCDCreateRagdoll(vehc)
        self:ExitVehicle()
        
        self:Spectate(OBS_MODE_CHASE)
        self:SpectateEntity(self.RCD["rcd_ragdoll"])
        self:RCDSaveWeapons(true)
        
        self.RCD["rcd_oldpos_eject"] = self:GetPos()

        timer.Simple(5, function()
            if not IsValid(self) then return end
            
            self:UnSpectate()
            self:Spawn()
    
            if IsValid(self.RCD["rcd_ragdoll"]) then
                local pos = self.RCD["rcd_ragdoll"]:GetPos()
    
                self:SetPos(pos)
                self.RCD["rcd_ragdoll"]:Remove()
            else
                if isvector(self.RCD["rcd_oldpos_eject"]) then
                    self:SetPos(self.RCD["rcd_oldpos_eject"])
                end
            end
    
            self:RCDGiveWeapons()
            self.RCD["rcd_oldpos_eject"] = nil
        end)
    
    end)
end

-- [[ Return the player gender ]] --
function PLAYER:RCDGetGender()
    local currentModel = self:GetModel()
    return isstring(RCD.AccidentModule["modelSound"][currentModel]) and RCD.AccidentModule["modelSound"][currentModel] or currentModel:find("female") and "female" or "male"
end

--[[ Freeze the vehicle and playsound on the player ]]
function PLAYER:RCDAccident(vehc)
    if not IsValid(vehc) or not RCD.IsVehicle(vehc) then return end

    self:EmitSound("vo/npc/"..self:RCDGetGender().."01/moan0"..math.random(1, 5)..".wav")

    vehc.RCDAccident = true
    RCD.ChangeVehicleStatut(vehc, false)

    timer.Simple(3, function()
        if not IsValid(vehc) then return end
        
        vehc.RCDAccident = false
        RCD.ChangeVehicleStatut(vehc, true)
    end)
end

--[[ Compatibility with all vehicle addons ]]
hook.Add("RCD:CanChangeEngine", "RCD:CanChangeEngine:Compatibilities", function(vehc)
    if not IsValid(vehc) then return end

    if vehc:WaterLevel() >= 2 then 
        local vehicleId = vehc.RCDUniqueId
        local vehicleTable = RCD.GetVehicleInfo(vehicleId) or {}

        local options = vehicleTable["options"] or {}
        if options["isBoat"] then return end

        return false
    end
    
    local health, fuel = 100, 100
    if not vehc.IsSimfphyscar then
        if SVMOD && SVMOD:GetAddonState() && isfunction(vehc.SV_GetHealth) && isfunction(vehc.SV_GetFuel) then
            health = vehc:SV_GetHealth()
            fuel = vehc:SV_GetFuel()
        elseif VC && isfunction(vehc.VC_getHealth) && isfunction(vehc.VC_fuelGet) then
            health = vehc:VC_getHealth(true)        
            fuel = vehc:VC_fuelGet(true)
        end
    elseif vehc.IsSimfphyscar && isfunction(vehc.GetCurHealth) && isfunction(vehc.GetFuel) then
        health = vehc:GetCurHealth()
        fuel = vehc:GetFuel()
    end
    
    if fuel <= 0 then return false end
    if health <= 0 then return false end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132
