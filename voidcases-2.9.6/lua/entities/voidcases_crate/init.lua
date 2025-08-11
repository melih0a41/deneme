AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("VoidCases_BroadcastLogoDL")

local casesUnlockSounds = VoidCases.UnlockSounds
local raritySounds = VoidCases.RaritySounds

function ENT:Initialize()
 
	self:SetModel( "models/voidcases/plastic_crate.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )         
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

    self:SetRenderMode(RENDERMODE_TRANSALPHA)    

end


function ENT:Think()
    
    self:NextThink(CurTime())
    return true
end


function ENT:SetCrateColor(color)
    self:SetNWVector("CrateColor", color:ToVector())
end

function ENT:SetCrateLogo(logo)
    self:SetNWString("CrateLogo", logo)
end


function ENT:SetAttachmentItem(modelName, isIcon, isSkin, skin_)

    if (!isIcon) then

        self:SetNWString("ModelName", modelName)
        self:SetNWBool("IsSkin", isSkin or false)
        self:SetNWString("SkinMat", skin_ or "")

    else
        local attachment = self:LookupAttachment("attachment")

        local pos = self:GetAttachment(attachment)

        local model = ents.Create("prop_physics")
        model:SetModel( (!isIcon and modelName) or "models/hunter/blocks/cube025x025x025.mdl" )
        model:SetMoveType(MOVETYPE_NONE)

        model:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
        
        model:SetPos(self:GetPos() + self:GetUp() * 12)
        model:SetRenderMode(RENDERMODE_TRANSALPHA)
        model:SetColor(Color(0,0,0,0))
        model:SetParent(self, attachment)

        model:Spawn()

        self.itemModel = model

        self:SetNWString("CrateUnboxLogo", modelName)
        self:SetNWEntity("UnboxingModel", model)


    end
    
end

function ENT:OpenBox()
    
end

function ENT:PerformAnimation(model, isIcon, isSkin, skin_, rarity)
    self:ResetSequenceInfo()

    timer.Simple(0.28, function ()
        self:EmitSound("voidcases/case_drop.wav")
    end)

    // Lock
    if (self:GetModel() != "models/voidcases/scifi_crate.mdl") then
        self:SetBodygroup(1, 1)
    end

    self:ResetSequence("drop")
    local seqDuration = self:SequenceDuration()
    timer.Simple(seqDuration + 0.1, function ()

        if (!IsValid(self)) then return end

        local unlockSound = casesUnlockSounds[self:GetModel()]
        if (self:GetModel() == "models/voidcases/scifi_crate.mdl") then
            timer.Simple(0.9, function ()
                self:EmitSound(unlockSound or "")
            end)
        else
            self:EmitSound(unlockSound or "")
        end

        self:SetAttachmentItem(model, isIcon, isSkin, skin_)

        // Key
        self:SetBodygroup(self:GetModel() == "models/voidcases/scifi_crate.mdl" and 1 or 2, 1)
        self:ResetSequence("open")
        
        if (self:GetModel() == "models/voidcases/scifi_crate.mdl") then
            // Green skin
            timer.Simple(1.1, function ()
                if (!IsValid(self)) then return end

                self:SetSkin(1)
            end)
        end

        seqDuration = self:SequenceDuration()
        timer.Simple(seqDuration, function ()

            if (!IsValid(self)) then return end

            self:SetBodygroup(2, 0)
            self:SetBodygroup(1, 0)

            self:ResetSequence("popout")
            self:SetPlaybackRate(0.5)

            local raritySound = raritySounds[rarity]
            self:EmitSound(raritySound or "")

            seqDuration = self:SequenceDuration()
            timer.Simple(seqDuration - 0.1, function ()
                if (!IsValid(self)) then return end

                if (IsValid(self.itemModel) and self.itemModel:GetModelScale() != 1) then
                    self.itemModel:SetModelScale(1, 0.4)
                end

                self:ResetSequence("hover")
                self:SetPlaybackRate(1)
            end)
            
        end)
    end)
end
