// Placing of cases here

VoidCases.CaseEntity = NULL
VoidCases.CaseItem = nil


local function L(phrase)
    return VoidCases.Lang.GetPhrase(phrase)
end

function VoidCases.StartCasePlace(id, case)
    local ply = LocalPlayer()

    local modelIcon = case.info.icon

    local entityModel = ClientsideModel(modelIcon, RENDERGROUP_TRANSLUCENT)
    entityModel:SetColor(Color(0,0,0,160))
    entityModel:SetRenderMode(RENDERMODE_TRANSALPHA)

    entityModel:SetPos(ply:GetForward() * 10)
    entityModel:SetNWString("CrateLogo", case.info.caseIcon)

    case.id = id

    VoidCases.CaseEntity = entityModel
    VoidCases.CaseItem = case

    local keysWep = ply:GetWeapon("keys")
    if (IsValid(keysWep)) then
        input.SelectWeapon(keysWep)
    else
        local gravGun = ply:GetWeapon("weapon_physcannon")
        if (!IsValid(gravGun)) then
            local crowbar = ply:GetWeapon("weapon_crowbar")
            if (IsValid(crowbar)) then
                input.SelectWeapon(crowbar)
            end
        else
            input.SelectWeapon(gravGun)
        end
    end

    
end




function VoidCases.PlaceCrate()
    net.Start("VoidCases.SpawnCase")
        net.WriteUInt(VoidCases.CaseItem.id, 32)
        net.WriteVector(VoidCases.CaseEntity:GetPos())
        net.WriteAngle(VoidCases.CaseEntity:GetAngles())
    net.SendToServer()
end

function VoidCases.DeleteCrateBP()
    VoidCases.CaseEntity:Remove()
    VoidCases.CaseItem = nil
end


hook.Add("HUDPaint", "VoidCases.CaseinfoHUD", function ()
    if (!VoidCases.Config.DisableInfobox3D2D) then return end
    if (!IsValid(VoidCases.CaseEntity)) then return end
    if (!VoidCases.CaseItem) then return end


    surface.SetFont("VoidUI.R28")

    local casesLeft = tonumber(VoidCases.Inventory[VoidCases.CaseItem.id]) or 1

    local caseString = VoidCases.CaseItem.name .. " (" .. casesLeft .. "x" .. ")"

    local minWidth = 120
    local textWidth = surface.GetTextSize(caseString) + 70

    local height = 150

    local w = math.max(minWidth, textWidth)

    local x, y = ScrW() / 2 - w / 2, ScrH() - height - 20

    draw.RoundedBox(2, x + 0, y + 0, w, height, VoidUI.Colors.Primary)
    draw.SimpleText(caseString, "VoidUI.R28", x + 15, y + 8, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    surface.SetDrawColor(VoidUI.Colors.White)
    surface.DrawRect(x + 15, y + 43, w - 30, 2)

    draw.RoundedBox(8, x+ 15, y + 55, 55, 35, VoidUI.Colors.TextGray)
    draw.SimpleText("LMB", "VoidUI.B24", x+ 15+55/2, y + 55+35/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText(L"case_place", "VoidUI.R26", x+ 15+55+10, y + 55+35/2-2, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    draw.RoundedBox(8, x+ 15, y + 100, 55, 35, VoidUI.Colors.TextGray)
    draw.SimpleText("RMB", "VoidUI.B24", x+ 15+55/2, y + 100+35/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText(string.lower(L("cancel")):gsub("^%l", string.upper), "VoidUI.R26", x+ 15+55+10, y + 100+35/2-2, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)


hook.Add("PostDrawTranslucentRenderables", "VoidCases.CaseInfo3D2D", function ()
    if (!IsValid(VoidCases.CaseEntity)) then return end
    if (!VoidCases.CaseItem) then return end
    if (VoidCases.Config.DisableInfobox3D2D) then return end

    local casesLeft = tonumber(VoidCases.Inventory[VoidCases.CaseItem.id]) or 1

    local caseString = VoidCases.CaseItem.name .. " (" .. casesLeft .. "x" .. ")"

    local casePos = VoidCases.CaseEntity:GetPos() + VoidCases.CaseEntity:GetUp() * 50 - VoidCases.CaseEntity:GetRight() * 90 - VoidCases.CaseEntity:GetForward() * 10

    local angle = EyeAngles()

	angle = Angle( 180, angle.y + 110, 270 )

    cam.Start3D2D(casePos, angle, 0.2)

        surface.SetFont("VoidUI.R28")

        local minWidth = 120
        local textWidth = surface.GetTextSize(caseString) + 70

        local height = 150

        local w = math.max(minWidth, textWidth)

        draw.RoundedBox(2, 0, 0, w, height, VoidUI.Colors.Primary)
        draw.SimpleText(caseString, "VoidUI.R28", 15, 8, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.SetDrawColor(VoidUI.Colors.White)
        surface.DrawRect(15, 43, w - 30, 2)

        draw.RoundedBox(8, 15, 55, 55, 35, VoidUI.Colors.TextGray)
        draw.SimpleText("LMB", "VoidUI.B24", 15+55/2, 55+35/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText(L"case_place", "VoidUI.R26", 15+55+10, 55+35/2-2, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.RoundedBox(8, 15, 100, 55, 35, VoidUI.Colors.TextGray)
        draw.SimpleText("RMB", "VoidUI.B24", 15+55/2, 100+35/2, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText(string.lower(L("cancel")):gsub("^%l", string.upper), "VoidUI.R26", 15+55+10, 100+35/2-2, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    cam.End3D2D()

end)


hook.Add("KeyRelease", "VoidCases.KeyListen", function (ply, key)
    if (!IsValid(VoidCases.CaseEntity)) then return end
    if (!VoidCases.CaseItem) then return end
    
    
    if (key == IN_ATTACK and VoidCases.CaseEntity.canPlace and !ply.vcases_cooldown) then
        // Place


        ply.vcases_cooldown = true
        timer.Simple(0.6, function ()
            ply.vcases_cooldown = false
        end)

        local prevCase = VoidCases.CaseItem
        local casesLeft = tonumber(VoidCases.Inventory[VoidCases.CaseItem.id]) or 1

        VoidCases.PlaceCrate()



        if (casesLeft < 2) then
            // Delete only if has no crates left
            VoidCases.DeleteCrateBP()
        end

        
    end
    if (key == IN_ATTACK2) then
        // Cancel
        VoidCases.DeleteCrateBP()
    end
end)

hook.Add("Think", "VoidCases.CasePlacingThink", function ()
    if (!IsValid(VoidCases.CaseEntity)) then return end
    if (!LocalPlayer():Alive()) then
        VoidCases.DeleteCrateBP()
        return
    end

    local trace = util.TraceLine({
        start = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 20,
        endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 200,
        filter = LocalPlayer()
    })
    if (trace) then
        local eAng = LocalPlayer():EyeAngles()

        VoidCases.CaseEntity:SetPos(trace.HitPos)
        VoidCases.CaseEntity:SetAngles(Angle(0, eAng.y, 0))        


        if (trace.Hit and trace.HitNormal.z > 0.9 and !LocalPlayer().vcases_cooldown) then
            // Can place
            VoidCases.CaseEntity.canPlace = true
            VoidCases.CaseEntity:SetColor(Color(0,255,0,160))
            VoidCases.CaseEntity:SetNWVector("CrateColor", Color(0,255,0):ToVector())

        else
            // Can't place
            VoidCases.CaseEntity.canPlace = false
            VoidCases.CaseEntity:SetColor(Color(255,0,0,160))
            VoidCases.CaseEntity:SetNWVector("CrateColor", Color(255,0,0):ToVector())
        end
        
    end
end)
