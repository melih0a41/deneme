include("shared.lua")
local DexBedStates = DexBedStates or {}

local function Scale(size)
    return math.ceil(size * (ScrH() / 1080))
end

local dex_color_black_translucent = Color(0, 0, 0, 200)
local dex_color_white = Color(255, 255, 255, 255)
local dex_color_bloodred = Color(180, 0, 0, 255)
local dex_color_darktext = Color(30, 30, 30, 220)
local dex_color_highlight = Color(220, 50, 50, 255)

function ENT:Draw()
    self:DrawModel()
end

local viewingFromRagdoll = false
local ragdollEnt = nil
local progressBarActive = false
local progressBarValue = 0
local progressBarMax = 100

net.Receive("dex_EnterFirstPersonView", function()
    ragdollEnt = net.ReadEntity()
    viewingFromRagdoll = IsValid(ragdollEnt)
end)

net.Receive("dex_ExitFirstPersonView", function()
    viewingFromRagdoll = false
    ragdollEnt = nil
end)

net.Receive("dex_ShowProgressBar", function()
    progressBarActive = true
    progressBarValue = 0
end)

net.Receive("dex_HideProgressBar", function()
    progressBarActive = false
end)

local gaggedPlayers = {}

net.Receive("dex_UpdateGagged", function()
    local ply = net.ReadEntity()
    local isGagged = net.ReadBool()
    
    if IsValid(ply) then
        gaggedPlayers[ply] = isGagged
    end
end)

net.Receive("dex_UpdateProgressBar", function()
    progressBarValue = net.ReadUInt(8)
end)

local function DexCreateFontsBed()
    surface.CreateFont("dex_ProgressBarFont", {
        font = "Arial",
        size = Scale(23),
        weight = 500,
        antialias = true,
        shadow = true
    })

    surface.CreateFont("dex_AssassinHUD", {
        font = "Arial",
        size = Scale(30),
        weight = 700,
        antialias = true,
        shadow = true
    })
end

DexCreateFontsBed()

local lastScrH = ScrH()
local function CheckResolutionChange()
    if ScrH() ~= lastScrH then
        lastScrH = ScrH()
        DexCreateFontsBed()
    end
end

local function DrawProgressBar()
    if not progressBarActive then return end
    
    local w = ScrW() * 0.3
    local h = Scale(32)
    local x = (ScrW() - w) / 2
    local y = ScrH() * 0.7
    
    surface.SetDrawColor(dex_color_black_translucent)
    surface.DrawRect(x, y, w, h)
    
    local progressWidth = w * (progressBarValue / progressBarMax)
    surface.SetDrawColor(dex_color_white)
    surface.DrawRect(x, y, progressWidth, h)
    
    surface.SetDrawColor(dex_color_white)
    surface.DrawOutlinedRect(x, y, w, h)
    
    draw.SimpleText(DEX_LANG.Get("table_up"), "dex_ProgressBarFont", x + w/2, y + h/2, dex_color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function CalculateRagdollView(ply, pos, angles, fov)
    if not viewingFromRagdoll or not IsValid(ragdollEnt) then return end
    
    local boneID = ragdollEnt:LookupBone("ValveBiped.Bip01_Head1")
    local camPos = ragdollEnt:GetPos()
    local camAng = Angle(-90, 135, 0)

    if boneID then
        local bonePos = ragdollEnt:GetBonePosition(boneID)
        if bonePos then
            camPos = bonePos + Vector(0, 0, 4.5)
        end
    end

    return {
        origin = camPos,
        angles = camAng,
        fov = fov
    }
end

local lastGagTime = 0

hook.Add("Think", "dex_CheckGagAction", function()
    if not input.IsKeyDown(KEY_R) then return end
    if CurTime() - lastGagTime < 0.5 then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local tr = ply:GetEyeTrace()
    local ent = tr.Entity
    
    if IsValid(ent) and ent:GetClass() == "dex_bed" then
        local bedState = DexBedStates[ent:EntIndex()]
        if not bedState or not bedState.IsOnBed or not IsValid(bedState.BedPlayer) then 
            return 
        end

        net.Start("dex_GagRagdoll")
            net.WriteEntity(ent)
        net.SendToServer()
        
        lastGagTime = CurTime()
    end
end)
local RenderPos = {
    Gag = {
        Vector(1.0, 4.2, 2),
        Vector(1.0, 5.5, -0.1),
        Vector(1.0, 4.5, -2),
        Vector(0, 0, -3.4),
        Vector(-0.8, -3, 0),
        Vector(0, 0, 3.4)
    }
}

local gagMaterial = Material("models/dexter/tape")
local HeadBone = "ValveBiped.Bip01_Head1"

hook.Add("PostDrawOpaqueRenderables", "dex_DrawRagdollGag", function()
    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        local owner = ent:GetOwner()
        if not IsValid(owner) or not gaggedPlayers[owner] then continue end

        if owner:GetNWBool("IsInRagdoll", false) then return end

        local bone = ent:LookupBone(HeadBone)   
        if not bone then continue end

        local pos, ang = ent:GetBonePosition(bone)
        if not pos or not ang then continue end

        render.SetMaterial(gagMaterial)

        local firstPos = pos + ang:Forward() * RenderPos.Gag[1].x + ang:Right() * RenderPos.Gag[1].y + ang:Up() * RenderPos.Gag[1].z
        local lastPos = firstPos

        for i = 2, #RenderPos.Gag do
            local newPos = pos + ang:Forward() * RenderPos.Gag[i].x + ang:Right() * RenderPos.Gag[i].y + ang:Up() * RenderPos.Gag[i].z
            render.DrawBeam(newPos, lastPos, 2.4, 0, 1, dex_color_white)
            lastPos = newPos
        end

        render.DrawBeam(lastPos, firstPos, 2.4, 0, 1, dex_color_white)
    end
end)

local RopeMat = Material("cable/rope")
local OriginalBonePositions = {}

local BedRopePositions = {
    Head = {
        bone = "ValveBiped.Bip01_Head1",
        offsets = {
            Vector(5.0, 4.2, 2),
            Vector(5.0, 5.5, -0.1),
            Vector(5.0, 4.5, -2),
            Vector(5, -8, -18),
            Vector(5, -10, 0),
            Vector(5, -8, 18),
        }
    },
    UpperChest = {
        bone = "ValveBiped.Bip01_Spine4",
        offsets = {
            Vector(-20, 1, 0),
            Vector(-20, 0, -18),
            Vector(-20, -8, -12),
            Vector(-20, -13, 0),
            Vector(-20, -8, 12),
            Vector(-20, 0, 18),
        }
    },
    LowerChest = {
        bone = "ValveBiped.Bip01_Spine2",
        offsets = {
            Vector(3, 3, 18),
            Vector(3, 6, 0),
            Vector(3, 3, -18),
            Vector(0, -4, -10),
            Vector(-3, -10, 0),
            Vector(0, -4, 10),
        }
    },
    Leg = {
        bone = "ValveBiped.Bip01_L_Calf",
        offsets = {
            Vector(2.5, 2, 5),
            Vector(2.5, 4, -4),
            Vector(2.5, 2, -11.5),
            Vector(0, -6, -22),
            Vector(-2.5, -8, -4),
            Vector(0, -7, 14),
        }
    },
}

local function DrawCircularRope(pos, ang, offsets)
    local firstPos = pos + ang:Forward() * offsets[1].x + ang:Right() * offsets[1].y + ang:Up() * offsets[1].z
    local lastPos = firstPos

    render.SetMaterial(gagMaterial)

    for i = 2, #offsets do
        local newPos = pos + ang:Forward() * offsets[i].x + ang:Right() * offsets[i].y + ang:Up() * offsets[i].z
        render.DrawBeam(newPos, lastPos, 2.4, 0, 1, dex_color_white)
        lastPos = newPos
    end

    render.DrawBeam(lastPos, firstPos, 2.4, 0, 1, dex_color_white)
end

local DexRagdolls = {}

net.Receive("dex_add_ragdoll", function()
    local rag = net.ReadEntity()
    if IsValid(rag) then
        DexRagdolls[rag:EntIndex()] = true
    end
end)

hook.Add("PostDrawOpaqueRenderables", "dex_DrawDexRagdollRopes", function()
    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        if not DexRagdolls[ent:EntIndex()] then continue end

        local entID = ent:EntIndex()
        OriginalBonePositions[entID] = OriginalBonePositions[entID] or {}

        render.SetMaterial(RopeMat)

        for key, part in pairs(BedRopePositions) do
            local bone = ent:LookupBone(part.bone)
            if not bone then continue end

            local pos, ang = ent:GetBonePosition(bone)
            if not pos or not ang then continue end

            if not OriginalBonePositions[entID][key] then
                OriginalBonePositions[entID][key] = pos
            end

            local originalPos = OriginalBonePositions[entID][key]
            if originalPos:Distance(pos) > 4.8 then
                continue
            end

            DrawCircularRope(pos, ang, part.offsets)
        end
    end
end)


net.Receive("dex_bed_status", function()
    local bed = net.ReadEntity()
    local isOnBed = net.ReadBool()
    local bedPlayer = net.ReadEntity()

    if IsValid(bed) then
        DexBedStates[bed:EntIndex()] = {
            IsOnBed = isOnBed,
            BedPlayer = IsValid(bedPlayer) and bedPlayer or nil
        }
    end
end)

hook.Add("HUDPaint", "dex_ShowBedInstructions", function()
    CheckResolutionChange()
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    if not tr.Hit or not IsValid(tr.Entity) then return end

    local ent = tr.Entity
    if ent:GetClass() ~= "dex_bed" then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 16000 then return end
    local bedState = DexBedStates[ent:EntIndex()]
    if not bedState or not bedState.IsOnBed then return end

    draw.SimpleText(
        DEX_LANG.Get("table_free"), 
        "dex_AssassinHUD", 
        ScrW() / 2, 
        ScrH() * 0.9, 
        dex_color_bloodred, 
        TEXT_ALIGN_CENTER, 
        TEXT_ALIGN_CENTER
    )

    local isGagged = bedState.BedPlayer and gaggedPlayers[bedState.BedPlayer] or false
    local muteAction = isGagged and DEX_LANG.Get("table_gagged_off") or DEX_LANG.Get("table_gagged_on")

    draw.SimpleText(
        muteAction,
        "dex_AssassinHUD",
        ScrW() / 2,
        ScrH() * 0.9 + Scale(40),
        isGagged and dex_color_darktext or dex_color_highlight,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end)

-- Client tarafı ölüm temizlemesi - YENİ!
hook.Add("PlayerDeath", "dex_CleanupBedClientOnDeath", function(ply)
    if ply == LocalPlayer() then
        -- FirstPerson view'i kapat
        viewingFromRagdoll = false
        ragdollEnt = nil
        
        -- Progress bar'ı kapat
        progressBarActive = false
        progressBarValue = 0
        
        -- Gag durumunu temizle
        gaggedPlayers[ply] = nil
    end
end)

-- Oyuncu öldüğünde box camera lock'unu temizle - YENİ!
hook.Add("PlayerDeath", "dex_CleanupBoxLockOnDeath", function(ply)
    if ply == LocalPlayer() then
        -- Camera view'i temizle
        if isViewingBox then
            isViewingBox = false
            currentBox = nil
            currentGlassList = {}
            selectedIndex = 1
            glowObjects = {}
            cameraStartTime = 0
            cameraTransitionComplete = false
            
            -- Movement lock'unu kaldır
            DexBoxMovement.Unlock()
            
            -- InvestigationMod view'i temizle
            if InvestigationMod and InvestigationMod.ClearView then
                InvestigationMod.ClearView()
            end
            
            -- View model'i geri getir
            LocalPlayer():DrawViewModel(true)
            LocalPlayer().IsFocused = false
            
            print("[DEX] Box camera lock temizlendi (oyuncu öldü)")
        end
    end
end)

-- Spawn olduğunda da temizle - YENİ!
hook.Add("PlayerSpawn", "dex_CleanupBoxLockOnSpawn", function(ply)
    if ply == LocalPlayer() then
        -- Movement lock'unu kesinlikle kaldır
        if DexBoxMovement and DexBoxMovement.IsLocked then
            DexBoxMovement.Unlock()
            print("[DEX] Movement lock kaldırıldı (spawn)")
        end
        
        -- View'i temizle
        if InvestigationMod and InvestigationMod.MoveView then
            InvestigationMod.ClearView()
        end
        
        -- Normal view model
        LocalPlayer():DrawViewModel(true)
        LocalPlayer().IsFocused = false
    end
end)

-- Oyuncu öldüğünde/spawn olduğunda tüm client efektlerini temizle - YENİ!
hook.Add("PlayerDeath", "dex_CleanupAllClientEffects", function(ply)
    if ply == LocalPlayer() then
        -- Sanity efektlerini sıfırla
        ResetColorModify()
        sanity = 100
        bloodActive = false
        bloodPhaseEnd = 0
        redFadeAlpha = 0
        sanityPulse = 0
        sanityShake = 0
    end
end)

hook.Add("PlayerSpawn", "dex_ResetClientEffectsOnSpawn", function(ply)
    if ply == LocalPlayer() then
        -- Tüm efektleri temizle
        ResetColorModify()
        
        -- Movement lock kontrolü
        if DexBoxMovement and DexBoxMovement.IsLocked then
            DexBoxMovement.Unlock()
        end
        
        -- View model'i göster
        ply:DrawViewModel(true)
    end
end)


hook.Add("HUDPaint", "dex_DrawProgressBar", DrawProgressBar)
hook.Add("CalcView", "dex_RagdollView", CalculateRagdollView)