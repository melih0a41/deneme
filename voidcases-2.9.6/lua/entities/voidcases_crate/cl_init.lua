include('shared.lua')

function ENT:Initialize()
    self.startColor = Color(255,255,255,100)

    self.itemModel = NULL
end


function ENT:OnRemove()
    if (IsValid(self.itemModel)) then
        self.itemModel:Remove()
    end
end

function ENT:Draw()
    self:DrawModel()

    self.startColor = Color(255,255,255, math.min(self.startColor.a + 4, 255))
    self:SetColor(self.startColor)
    
    local unboxModel = self:GetNWEntity("UnboxingModel")
    local logo = self:GetNWString("CrateUnboxLogo")
    
    if (IsValid(unboxModel) and VoidCases.CachedMaterials[logo]) then

        local plyAngles = LocalPlayer():EyeAngles()

        local angles = unboxModel:GetAngles()
        angles:RotateAroundAxis(unboxModel:GetRight(), 270)
        angles:RotateAroundAxis(unboxModel:GetForward(), 90)
        
        angles = Angle(angles.x, plyAngles.y - 90, angles.z)
        

        cam.Start3D2D( unboxModel:GetPos(), angles, 0.2 )
            surface.SetDrawColor(VoidUI.Colors.White)
            surface.SetMaterial(VoidCases.CachedMaterials[logo])
            surface.DrawTexturedRect(-60,-60,120,120)
        cam.End3D2D()
    end

    local modelName = self:GetNWString("ModelName", nil)
    local isSkin = self:GetNWBool("IsSkin")
    local skinMat = self:GetNWString("SkinMat")


    if (modelName and modelName != "") then

        if (!IsValid(self.itemModel) or !IsValid(self)) then
            self.itemModel = ClientsideModel(modelName)

            local attachment = self:LookupAttachment("attachment")
            local pos = self:GetAttachment(attachment)

            if (!pos) then return end -- I have no idea..

            self.itemModel:SetPos(self:GetPos())
            self.itemModel:SetAngles(pos.Ang)

            self.itemModel:SetParent(self, attachment)

            local model = self.itemModel

            local modelCenter = model:OBBCenter()

            local mn, mx = model:GetModelBounds()

            local mnXY = Vector(mn.x, mn.y, 0)
            local mxXY = Vector(mx.x, mx.y, 0)

            local mdlSize = mxXY - mnXY

            

            local currXY = "y"
            if (mdlSize.x > mdlSize.y) then
                currXY = "x"
            end

            if (mdlSize[currXY] > 41) then
                model:SetModelScale(0.85)
            end

            if (mdlSize[currXY] > 50) then
                model:SetModelScale(0.8)
            end

            if (mdlSize[currXY] > 60) then
                model:SetModelScale(0.6)
            end

            if (mdlSize.x > mdlSize.y) then
                // Rotate by 90 degrees
                self.itemModel:SetAngles(pos.Ang + Angle(0,90,0))
                self.itemModel:SetPos(self.itemModel:GetPos() - self.itemModel:GetForward() * mdlSize.x/4)
            end
            


            if (isSkin) then
                SH_EASYSKINS.ApplySkinToModel(self.itemModel, skinMat)
            end
        end

        
    end


end


function ENT:Think()
    self:NextThink(CurTime())
    return true
end

local fallbackColor = Color(255,255,255)

matproxy.Add({
    name = "CrateColor",
    init = function (self, mat, values)
        self.ResultTo = values.resultvar
    end,
    bind = function (self, mat, ent)
        if (IsValid(ent) and ent:GetNWVector("CrateColor") and isvector(ent:GetNWVector("CrateColor"))) then
            mat:SetVector(self.ResultTo, ent:GetNWVector("CrateColor"))
        else
            mat:SetVector(self.ResultTo, fallbackColor:ToVector())
        end
    end
})

local fallbackMat = Material("models/voidcases/plastic_crate/logo")

matproxy.Add({
    name = "CrateLogo",
    init = function (self, mat, values)
        self.ResultTo = values.resultvar
    end,
    bind = function (self, mat, ent)
        if (IsValid(ent) and ent:GetNWString("CrateLogo") and VoidCases.CachedMaterials[ent:GetNWString("CrateLogo")]) then
            local texture = VoidCases.CachedMaterials[ent:GetNWString("CrateLogo")]:GetTexture("$basetexture")
            mat:SetTexture(self.ResultTo, texture)
        else
            mat:SetTexture(self.ResultTo, fallbackMat:GetTexture("$basetexture"))
        end
    end
})
