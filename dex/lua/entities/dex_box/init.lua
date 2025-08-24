AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.OpenAnim = "Open"
ENT.CloseAnim = "Close"

local MAX_GLASSES = 47
util.AddNetworkString("dex_box_notify")
util.AddNetworkString("dex_box_select_glass")
util.AddNetworkString("dex_box_open")
util.AddNetworkString("dex_box_close")
util.AddNetworkString("dex_box_drop")
util.AddNetworkString("dex_box_camera_start")
util.AddNetworkString("dex_box_camera_end")
util.AddNetworkString("dex_box_camera_transition_complete")

function ENT:Initialize()
    self:SetModel("models/blood/box.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetTrigger(true)
    self:SetUseType(SIMPLE_USE)
    self.BoxIsOpen = false
    self.ViewingPlayer = nil
    self.CameraTransitionComplete = false

    self.StoredGlass = {}
    self.VisualGlass = {}
    self.SelectedGlassIndex = 1

    self.CameraPositions = {
        initial = Vector(50, 0, 30),
        close = Vector(25, 0, 15)
    }
    
    self.CameraAngles = {
        initial = Angle(10, 180, 0),
        close = Angle(15, 180, 0)
    }

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

function ENT:StartTouch(ent)
    if not IsValid(ent) or ent:GetClass() ~= "dex_glass" then return end
    if #self.StoredGlass >= MAX_GLASSES then return end
    if ent:GetPos():Distance(self:GetPos()) > 10 then return end

    self:AddGlassEntity(ent)
    self:AddVisualGlass()
end

function ENT:AddGlassEntity(ent)
    local name = ent.GlassName or DEX_LANG.Get("unknown")

    table.insert(self.StoredGlass, {
        Name = name,
        Model = ent:GetModel()
    })

    ent:Remove()
end

function ENT:AddVisualGlass()
    local visual = ents.Create("prop_dynamic")
    if not IsValid(visual) then return end

    visual:SetModel("models/blood/glass.mdl")

    local offset = Vector(-4.6 + #self.VisualGlass * 0.2, 0.5, 0.5)
    visual:SetPos(self:LocalToWorld(offset))
    visual:SetAngles(self:GetAngles())
    visual:SetParent(self)
    visual:Spawn()

    visual.BaseOffset = offset
    visual.IsSelected = false
    visual.LiftHeight = 2
    visual.GlassIndex = #self.VisualGlass + 1

    table.insert(self.VisualGlass, visual)
end

function ENT:RemoveVisualGlass(index)
    index = index or #self.VisualGlass
    
    if index < 1 or index > #self.VisualGlass then return end
    
    local visual = self.VisualGlass[index]
    if IsValid(visual) then
        visual:Remove()
    end
    
    table.remove(self.VisualGlass, index)
    
    for i, visual in ipairs(self.VisualGlass) do
        if IsValid(visual) then
            visual.GlassIndex = i
        end
    end
    
    if #self.VisualGlass > 0 and self.CameraTransitionComplete then
        self:UpdateVisualSelection()
    end
end

function ENT:UpdateVisualSelection()
    if not self.CameraTransitionComplete then return end
    
    for i, visual in ipairs(self.VisualGlass) do
        if IsValid(visual) then
            visual.IsSelected = (i == self.SelectedGlassIndex)
            
            if visual.IsSelected then
                local currentPos = visual:GetLocalPos()
                visual:SetLocalPos(Vector(currentPos.x, currentPos.y, visual.BaseOffset.z + visual.LiftHeight))
                
                visual:SetRenderMode(RENDERMODE_TRANSALPHA)
                visual:SetRenderFX(kRenderFxGlowShell)
            else
                local currentPos = visual:GetLocalPos()
                visual:SetLocalPos(Vector(currentPos.x, currentPos.y, visual.BaseOffset.z))
                
                visual:SetRenderMode(RENDERMODE_NORMAL)
                visual:SetRenderFX(kRenderFxNone)
            end
        end
    end
end

function ENT:Use(activator, caller)
    if not IsValid(caller) or not caller:IsPlayer() then return end
    if self.ViewingPlayer and IsValid(self.ViewingPlayer) then return end
    if #self.StoredGlass == 0 then 
        net.Start("dex_box_notify")
            net.WriteUInt(1, 8)
            net.WriteString(DEX_LANG and DEX_LANG.Get("box_empty"))
        net.Send(caller)
        return 
    end

    if DEX_CONFIG and DEX_CONFIG.BoxSwep then
        caller:SelectWeapon(DEX_CONFIG.BoxSwep)
    end

    self:ResetSequence(self.OpenAnim)
    self:SetCycle(0)
    self:SetPlaybackRate(0)

    self._OpenStartTime = CurTime()
    self._OpenDuration = 2

    self:StartAnimationAdvance()
    
    self.BoxIsOpen = true
    self.ViewingPlayer = caller
    self.SelectedGlassIndex = 1
    self.CameraTransitionComplete = false

    net.Start("dex_box_camera_start")
        net.WriteEntity(self)
        net.WriteUInt(#self.StoredGlass, 8)
        for _, data in ipairs(self.StoredGlass) do
            net.WriteString(data.Name)
        end
        net.WriteUInt(self.SelectedGlassIndex, 8)
    net.Send(caller)
end

function ENT:OnCameraTransitionComplete()
    self.CameraTransitionComplete = true
    
    self:UpdateVisualSelection()
    
    self:UpdateSelectedGlass()
end

function ENT:EndCameraView()
    if not IsValid(self.ViewingPlayer) then return end

    net.Start("dex_box_camera_end")
        net.WriteEntity(self)
    net.Send(self.ViewingPlayer)

    self:ResetSequence(self.CloseAnim)
    self:SetCycle(0)
    self:SetPlaybackRate(0)

    self._OpenStartTime = CurTime()
    self._OpenDuration = 1

    self:StartAnimationAdvance()
    
    timer.Simple(1, function()
        if IsValid(self) then
            self:ResetSequence(self.OpenAnim)
            self:SetPlaybackRate(0.5)
        end
    end)

    self.BoxIsOpen = false
    self.ViewingPlayer = nil
    self.CameraTransitionComplete = false
    
    self:ReorganizeVisualGlass()
end

function ENT:GetWorldCameraPosition(localVector)
    return self:LocalToWorld(localVector)
end

function ENT:GetWorldCameraAngle(localAngle)
    return self:LocalToWorldAngles(localAngle)
end

function ENT:SelectNextGlass()
    if #self.StoredGlass == 0 or not self.CameraTransitionComplete then return end
    
    self.SelectedGlassIndex = self.SelectedGlassIndex + 1
    if self.SelectedGlassIndex > #self.StoredGlass then
        self.SelectedGlassIndex = 1
    end
    
    self:UpdateSelectedGlass()
    self:UpdateVisualSelection()
end

function ENT:SelectPreviousGlass()
    if #self.StoredGlass == 0 or not self.CameraTransitionComplete then return end
    
    self.SelectedGlassIndex = self.SelectedGlassIndex - 1
    if self.SelectedGlassIndex < 1 then
        self.SelectedGlassIndex = #self.StoredGlass
    end
    
    self:UpdateSelectedGlass()
    self:UpdateVisualSelection()
end

function ENT:UpdateSelectedGlass()
    if not IsValid(self.ViewingPlayer) or not self.CameraTransitionComplete then return end

    net.Start("dex_box_select_glass")
        net.WriteEntity(self)
        net.WriteUInt(self.SelectedGlassIndex, 8)
        net.WriteString(self.StoredGlass[self.SelectedGlassIndex].Name)
    net.Send(self.ViewingPlayer)
end

function ENT:DropSelectedGlass()
    if #self.StoredGlass == 0 or not self.CameraTransitionComplete then return end
    if not IsValid(self.ViewingPlayer) then return end

    local data = self.StoredGlass[self.SelectedGlassIndex]
    if not data then return end

    table.remove(self.StoredGlass, self.SelectedGlassIndex)
    
    self:RemoveVisualGlass(self.SelectedGlassIndex)

    local glass = ents.Create("dex_glass")
    if not IsValid(glass) then return end

    glass:SetPos(self:GetPos() + self:GetForward() * 30 + Vector(0, 0, 20))
    glass:SetAngles(Angle(0, 0, 0))
    glass:Spawn()
    glass.GlassName = data.Name
    glass:SetModel(data.Model or "models/blood/glass.mdl")

    net.Start("dex_box_notify")
        net.WriteUInt(0, 8)
        net.WriteString(DEX_LANG and DEX_LANG.Get("drop_blood"))
    net.Send(self.ViewingPlayer)

    if self.SelectedGlassIndex > #self.StoredGlass and #self.StoredGlass > 0 then
        self.SelectedGlassIndex = #self.StoredGlass
    elseif #self.StoredGlass == 0 then
        self.SelectedGlassIndex = 1
    end

    if #self.StoredGlass == 0 then
        self:EndCameraView()
    else
        self:UpdateSelectedGlass()
    end
end

function ENT:ReorganizeVisualGlass()
    for i, visual in ipairs(self.VisualGlass) do
        if IsValid(visual) then
            local newOffset = Vector(-4.6 + (i-1) * 0.2, 0.5, 0.5)
            visual.BaseOffset = newOffset
            visual.GlassIndex = i
            
            visual:SetLocalPos(newOffset)
            visual.IsSelected = false
            
            visual:SetRenderMode(RENDERMODE_NORMAL)
            visual:SetRenderFX(kRenderFxNone)
            visual:SetColor(Color(255, 255, 255, 255))
        end
    end
end

net.Receive("dex_box_close", function(_, ply)
    local box = net.ReadEntity()
    if not IsValid(box) or box:GetClass() ~= "dex_box" then return end
    if box.ViewingPlayer ~= ply then return end

    box:EndCameraView()
end)

net.Receive("dex_box_drop", function(_, ply)
    local box = net.ReadEntity()
    if not IsValid(box) or box:GetClass() ~= "dex_box" then return end
    if box.ViewingPlayer ~= ply then return end

    box:DropSelectedGlass()
end)

net.Receive("dex_box_select_glass", function(_, ply)
    local box = net.ReadEntity()
    local direction = net.ReadInt(8)
    
    if not IsValid(box) or box:GetClass() ~= "dex_box" then return end
    if box.ViewingPlayer ~= ply then return end
    if not box.CameraTransitionComplete then return end

    if direction > 0 then
        box:SelectNextGlass()
    else
        box:SelectPreviousGlass()
    end
end)

net.Receive("dex_box_camera_transition_complete", function(_, ply)
    local box = net.ReadEntity()
    if not IsValid(box) or box:GetClass() ~= "dex_box" then return end
    if box.ViewingPlayer ~= ply then return end

    box:OnCameraTransitionComplete()
end)

function ENT:OnRemove()
    for _, visual in ipairs(self.VisualGlass) do
        if IsValid(visual) then
            visual:Remove()
        end
    end

    if IsValid(self.ViewingPlayer) then
        net.Start("dex_box_camera_end")
            net.WriteEntity(self)
        net.Send(self.ViewingPlayer)
    end
end

function ENT:StartAnimationAdvance()
    local id = "dex_box_anim_" .. self:EntIndex()
    hook.Add("Think", id, function()
        if not IsValid(self) then
            hook.Remove("Think", id)
            return
        end

        local elapsed = CurTime() - (self._OpenStartTime or 0)
        local progress = math.Clamp(elapsed / (self._OpenDuration or 1), 0, 1)

        self:SetCycle(progress)

        if progress >= 1 then
            hook.Remove("Think", id)
        end
    end)
end