include("shared.lua")

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local hand = owner:LookupBone("ValveBiped.Bip01_R_Finger2")
    if hand then
        self:FollowBone(owner, hand)
    end

	easzy.quadcopter.SyncRadioController(self)
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
    local quadcopter = self.quadcopter
    if not quadcopter.equipments["Camera"] then return end

    local curTime = CurTime()
    if quadcopter.lastPOVSwitch and (curTime - quadcopter.lastPOVSwitch) < 0.2 then return end

    quadcopter.lastPOVSwitch = curTime

    if self.pov then
        self.pov = false
        easzy.quadcopter.DisablePOV(quadcopter)
    else
        self.pov = true
        easzy.quadcopter.EnablePOV(quadcopter)
    end
end

function SWEP:PostDrawViewModel(viewModel, weapon, ply)
    self:Draw3D2DGui(viewModel)
end

local w, h = 512, 512
local function GetScreenMaterial(quadcopter)
    if not IsValid(quadcopter) then return end

    local owner = quadcopter:CPPIGetOwner()
    local uniqueID = quadcopter:GetCreationID() .. "_" .. owner:SteamID64()

    -- Old VMT with unlit
    local oldMaterialName = "ezquadcopter_old_screen_material_" .. uniqueID
    local oldMaterial = CreateMaterial(oldMaterialName, "UnlitGeneric", {
        ["$basetexture"] = nil,
        ["$basetexturetransform"] = "center .5 .5 scale 1.03 1.03 rotate 0 translate 0 0",
        ["$model"] = 1,
        ["$ignorez"] = true
    })
    oldMaterial:SetTexture("$basetexture", "easzy/ez_quadcopter/dji_radio_controller/dji_radio_controller_screen")

    -- New VTF
    local newTextureName = "ezquadcopter_new_screen_texture_" .. uniqueID
    local newTexture = GetRenderTarget(newTextureName, w, h)
    local w, h = newTexture:Width(), newTexture:Height()

    easzy.quadcopter.FPVRadioControllerHUD(quadcopter, newTexture, 512, 512)

    -- New VMT
    local newMaterialName = "ezquadcopter_new_screen_material_" .. uniqueID
    local newMaterial = CreateMaterial(newMaterialName, "VertexlitGeneric", {
        ["$basetexture"] = nil
    })
    newMaterial:SetTexture("$basetexture", newTexture:GetName())

    return newMaterial
end

function SWEP:Draw3D2DGui(viewModel)
    if not IsValid(self.quadcopter) then return end

    local bone = viewModel:LookupBone("radio_controller")
    if not bone then return end

    -- 3D2D
    local bonePos, boneAng = viewModel:GetBonePosition(bone)
    if bonePos == viewModel:GetPos() then
        bonePos = viewModel:GetBoneMatrix(bone):GetTranslation()
    end
    boneAng:RotateAroundAxis(boneAng:Forward(), 90)
    bonePos = bonePos - boneAng:Up()*0.4

    -- Replace material
    local subMaterialKey = table.KeyFromValue(viewModel:GetMaterials(), "easzy/ez_quadcopter/fpv_radio_controller/fpv_radio_controller_screen")
    if not subMaterialKey then return end

    local newMaterialName = GetScreenMaterial(self.quadcopter)
    if not newMaterialName then
        viewModel:SetSubMaterial(subMaterialKey - 1, "")
    else
        viewModel:SetSubMaterial(subMaterialKey - 1, "!" .. newMaterialName:GetName())
    end
end

-- Specify a good position
local offsetVector = Vector(6, -4, -2)
local offsetAngle = Angle(303, 210, 157)

function SWEP:DrawWorldModel(flags)
    local owner = self:GetOwner()
    if not IsValid(owner) then
	    self:DrawModel(flags)
        return
    end

	if not IsValid(self.worldModel) then
		self.worldModel = ClientsideModel(self.WorldModel)
		self.worldModel:SetSkin(1)
		self.worldModel:SetNoDraw(true)
		self.worldModel:DrawShadow(false)
	else
        local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
        if not boneid then return end

        local matrix = owner:GetBoneMatrix(boneid)
        if not matrix then return end

        local newPos, newAng = LocalToWorld(offsetVector, offsetAngle, matrix:GetTranslation(), matrix:GetAngles())

        self.worldModel:SetPos(newPos)
        self.worldModel:SetAngles(newAng)
        self.worldModel:SetupBones()
    end
    self.worldModel:DrawModel()
end

function SWEP:Think()
    local quadcopter = self.quadcopter
    if not IsValid(quadcopter) then
    	easzy.quadcopter.SyncRadioController(self)
    end
end
