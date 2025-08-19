local playerRagdolls = {}

local function Scale(size)
    return math.ceil(size * (ScrH() / 1080))
end

local drag_color_main = Color(180, 0, 0, 255)

local function CreateDragFonts()
    surface.CreateFont("dex_DragMain", {
        font = "Arial",
        size = Scale(32),
        weight = 700,
        antialias = true,
        shadow = true
    })
end

CreateDragFonts()

local lastScrH = ScrH()
local function CheckResolutionChange()
    if ScrH() ~= lastScrH then
        lastScrH = ScrH()
        CreateDragFonts()
    end
end

net.Receive("dex_RagdollDragSync", function()
    playerRagdolls = net.ReadTable()
end)

local function IsPlayerRagdoll(ent)
    if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then
        return false, nil
    end
    
    local ragdollInfo = playerRagdolls[ent:EntIndex()]
    if ragdollInfo then
        local owner = Entity(ragdollInfo.owner)
        return true, owner
    end
    
    return false, nil
end

hook.Add("HUDPaint", "dex_RagdollDragHUD", function()
    CheckResolutionChange()
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    local ent = tr.Entity

    if not tr.Hit or not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) > 150 * 150 then return end

    local isPlayerRagdoll, owner = IsPlayerRagdoll(ent)
    if not isPlayerRagdoll then return end

    local mainText = DEX_LANG.Get("drag_body")
    
    local centerX = ScrW() / 2
    local baseY = ScrH() * 0.85
                
    draw.SimpleText(
        mainText,
        "dex_DragMain",
        centerX,
        baseY,
        drag_color_main,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end)