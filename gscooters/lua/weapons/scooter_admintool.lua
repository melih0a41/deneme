AddCSLuaFile()

SWEP.Category 		= "gScooters"
SWEP.PrintName		= "Setup Tool"
SWEP.Author			= "painless"
SWEP.Instructions   = "Left click to use the tool."
SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.Weight			        = 5
SWEP.AutoSwitchTo		    = false
SWEP.AutoSwitchFrom		    = false

SWEP.Slot			        = 2
SWEP.SlotPos			    = 1
SWEP.DrawAmmo			    = false
SWEP.DrawCrosshair		    = true

SWEP.ViewModel		= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel		= "models/weapons/w_toolgun.mdl"
SWEP.UseHands = true

local iTextSize = 256
local iLogoSize = 135
local cMainColor = gScooters.Config.PrimaryColor
local cSecondaryColor = gScooters.Config.SecondaryColor
local cAccentColor = gScooters.Config.AccentColor
local cTextColor = gScooters.Config.TextColor


if CLIENT then
    local iScrW, iScrH = ScrW(), ScrH()

    local frame
    local base
    local tScooterModels = {}

    local iScooterSize = 50

    local function GC_RequestRacks()
        net.Start("gScooters.Net.AdminRequestData")
        net.SendToServer()
    end


    concommand.Add("gc_bypass", function( ply, cmd, args )
        print("Running this command while not admin will still open the menu, but you can't do anything with it.")

        GC_RequestRacks()
    end)

    local function GC_Menu(tScootersData)
        local tScootersData = tScootersData or {}
        tScootersData[GC_RACK] = tScootersData[GC_RACK] or {}
        tScootersData[GC_NPC] = tScootersData[GC_NPC] or {}

        if not IsValid(frame) then

            local eSwep = LocalPlayer():GetActiveWeapon()

            frame = gScooters.Window(iScrW/5, iScrH/2, true)
            frame:SetPos(iScrW, iScrH/2 - frame:GetTall()/2)
            frame:MoveTo(iScrW - frame:GetWide() - 5, iScrH/2 - frame:GetTall()/2, 1, 0, 0.2)
    
            frame.AnimRemove = function()
                frame:MoveTo(iScrW, iScrH/2 - frame:GetTall()/2, 1, 0, 0.2)
                timer.Simple(1, function() if IsValid(frame) then frame:Remove() end end)
            end

            frame.Think = function()
                if not IsValid(eSwep) then frame:AnimRemove() base:Remove() end
            end
    
            gScooters:ChatMessage(gScooters:GetPhrase("focus_notification"))

            local function GC_Racks()
                local scroll = gScooters.Scroll(frame, 0, 0, 0, 0)
                scroll:Dock(FILL)
                scroll:DockMargin(0, iScrH/18 - 5, 0, 0)
                
                for sName, tScooterData in pairs(tScootersData[GC_RACK]) do
                    local rack = gScooters.Button(scroll, sName, 0, 0, 0, 0, cAccentColor)
                    rack:Dock(TOP)
                    rack:DockMargin(0, 0, 0, 5)
                    rack:SetTall(40)

                    rack.DoClick = function(self)
                        surface.PlaySound("gscooters/click.wav")

                        local menu = DermaMenu() 

                        local delete = menu:AddOption(gScooters:GetPhrase("remove"), function() 
                            self:Remove()

                            net.Start("gScooters.Net.AdminDeleteEntity")
                            net.WriteString(sName)
                            net.WriteUInt(GC_RACK, 2)
                            net.SendToServer()
                        end)
                        
                        delete:SetIcon("icon16/delete.png")
        
                        menu:Open()
                    end
                end

                local modeToggle = gScooters.Button(frame, string.format("- %s -", gScooters:GetPhrase("rack")), 0, 0, 0, 0, cAccentColor)
                modeToggle:Dock(BOTTOM)
                modeToggle:DockMargin(0, 5, 0, 0)
                modeToggle:SetTall(40)

                local line = vgui.Create("DPanel", frame)
                line:Dock(BOTTOM)
                line:SetTall(2)

                line.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, cMainColor) end

                local createButton = gScooters.Button(frame, gScooters:GetPhrase("create_rack"), 0, 0, 0, 0, cAccentColor)
                createButton:Dock(BOTTOM)
                createButton:DockMargin(0, 0, 0, 5)
                createButton:SetTall(40)
    
                createButton.DoClick = function()
                    surface.PlaySound("gscooters/click.wav")

                    createButton:Remove()
                    scroll:Remove()
                    line:Remove()
                    modeToggle:Remove()

                    local confirmButton = gScooters.Button(frame, gScooters:GetPhrase("confirm_rack"), 0, 0, 0, 0, cAccentColor)
                    confirmButton:Dock(BOTTOM)
                    confirmButton:DockMargin(5, 5, 5, 5)
                    confirmButton:SetTall(40)
    
                    local amount = gScooters.Slider(frame, gScooters:GetPhrase("amount_of_scooters"))
                    amount:SetMinMax(0, 10)
                    amount:SetValue(1)
                    amount:Dock(TOP)
                    amount:DockMargin(5, iScrH/18 - 4, -7, 5)
                    amount:SetTall(30)

                    local width = gScooters.Slider(frame, gScooters:GetPhrase("width_of_rack"))
                    width:SetMinMax(1, 1000)
                    width:SetValue(100)
                    width:Dock(TOP)
                    width:DockMargin(5, 15, -7, 5)
                    width:SetTall(30)

                    local rotation = gScooters.Slider(frame, gScooters:GetPhrase("rotation_of_scooters"))
                    rotation:SetMinMax(0, 360)
                    rotation:SetValue(180)
                    rotation:Dock(TOP)
                    rotation:DockMargin(5, 15, -7, 5)
                    rotation:SetTall(30)

                    base = ClientsideModel("models/squad/sf_plates/sf_plate7x7.mdl", RENDERGROUP_OPAQUE)
                    base:SetMaterial("models/shiny")
                    base:SetColor(cAccentColor)
                    base.Scale = 1
                    
                    
                    local function GC_ClampWidth()
                        return math.Clamp(width:GetValue(), iScooterSize*math.Round(amount:GetValue()), 1000)
                    end

                    local function GC_SetBasePos(iInitialAngle)
                        -- Minimum Sizes
                        width:SetValue(GC_ClampWidth())

                        -- Actual Base

                        local iInitialAngle = iInitialAngle or 0 

                        local tTrace = LocalPlayer():GetEyeTrace()
                        local vHitPos = tTrace.HitPos
                        local aNormal = tTrace.HitNormal:Angle()
                        local vBaseBoundsMin, vBaseBoundsMax = base:GetRenderBounds()
                        vBaseBoundsMax.y = vBaseBoundsMax.y * base.Scale

                        vBaseBoundsMin = base:LocalToWorld(vBaseBoundsMin)
                        vBaseBoundsMax = base:LocalToWorld(vBaseBoundsMax)
                        
                        base:SetPos(Vector(vHitPos.x - ((vBaseBoundsMax.x - vBaseBoundsMin.x)/2), vHitPos.y - ((vBaseBoundsMax.y - vBaseBoundsMin.y)/2), vHitPos.z))
                        base:SetAngles(Angle(0, (rotation:GetValue()*-1) + iInitialAngle, 0))
                    end

                    GC_SetBasePos()

                    local iInitialAngle = math.Round(LocalPlayer():EyeAngles().y/90)*90

                    confirmButton.Think = function()
                        if not IsValid(base) then return end
                        GC_SetBasePos(iInitialAngle)
                    end


                    local function GC_CalcSpacing(iNum, iMax, iWidth) -- I hate math
                        local iSpaceBetween = (iWidth - (iScooterSize*iMax))/(iMax + 1)
                        local iY = ((iNum*iSpaceBetween) + ((iNum - 1)*iScooterSize)) + (iScooterSize/2)
                          
                        return iY
                    end

                    local function GC_UpdateScooter(iVal)
                        local iVal = math.Round(iVal)
                        
                        for _, tScooter in ipairs(tScooterModels) do
                            tScooter.ClientSideModel:Remove()

                            tScooterModels = {}
                        end

                        for i = 1, tonumber(iVal) do
                            local tScooter = {}
                            local tClientSideModel = ClientsideModel("models/dannio/gscooters.mdl", RENDERGROUP_OPAQUE)
                            tClientSideModel:SetParent(base)

                            local vBaseBoundsMin, vBaseBoundsMax = base:GetRenderBounds()
                            vBaseBoundsMax.y = vBaseBoundsMax.y * base.Scale

                            local vScooterPlacement = Vector(vBaseBoundsMax.x - ((vBaseBoundsMax.x-vBaseBoundsMin.x)/2), vBaseBoundsMax.y - GC_CalcSpacing(i, iVal, vBaseBoundsMax.y - vBaseBoundsMin.y), 5)
                            tClientSideModel:SetPos(base:LocalToWorld(vScooterPlacement))
                            tClientSideModel:SetAngles(Angle(0, base:GetAngles().y - 90, 0))

                            tScooter.ClientSideModel = tClientSideModel

                            table.insert(tScooterModels, tScooter)
                        end
                    end

                    GC_UpdateScooter(1)

                    amount.OnValueChanged = function(self, iVal)
                        GC_UpdateScooter(iVal)
                    end
                    
                    width.OnValueChanged = function(self, iVal)
                        if iVal >= GC_ClampWidth() then
                            local mMatrix = Matrix()
                            local iScale = iVal/100
                            mMatrix:Scale(Vector(1, iScale, 1))
                            base.Scale = iScale
                            base:EnableMatrix("RenderMultiply", mMatrix)

                            GC_UpdateScooter(amount:GetValue())
                        end
                    end

                    confirmButton.DoClick = function()
                        surface.PlaySound("gscooters/click.wav")
                        
                        gScooters.StringRequest("gScooters", "  " .. gScooters:GetPhrase("rack_name"), gScooters:GetPhrase("rack") .. " #" .. (table.Count(tScootersData[GC_RACK]) + 1), function(sName)
                            frame:Remove()

                            if IsValid(base) then base:Remove() end

                            local tScooters = {}
                            tScooters.Scooters = {}

                            for iIndex, tScooter in pairs(tScooterModels) do
                                if IsValid(tScooter.ClientSideModel) then 
                                    table.insert(tScooters.Scooters, tScooter.ClientSideModel:GetPos())
                                    tScooters.Angle = tScooter.ClientSideModel:GetAngles()

                                    tScooter.ClientSideModel:Remove() 
                                end 
                            end
                        
                            tScooters.Center = (tScooters.Scooters[1] + tScooters.Scooters[#tScooters.Scooters])/2

                            local tTableToSend = util.Compress(util.TableToJSON(tScooters))

                            net.Start("gScooters.Net.AdminCreateEntity")
                            net.WriteUInt(#tTableToSend, 22)
                            net.WriteData(tTableToSend, #tTableToSend)
                            net.WriteUInt(GC_RACK, 2)
                            net.WriteString(sName)
                            net.SendToServer()

                            GC_RequestRacks()
                        end)
                    end
                end

                modeToggle.DoClick = function()
                    surface.PlaySound("gscooters/click.wav")

                    createButton:Remove()
                    scroll:Remove()
                    modeToggle:Remove()
                    line:Remove()

                    frame.NPCMenu()
                end
            end
            
            local function GC_NPCs()
                local scroll = gScooters.Scroll(frame, 0, 0, 0, 0)
                scroll:Dock(FILL)
                scroll:DockMargin(0, iScrH/18 - 5, 0, 0)
                
                for sName, tScooterData in pairs(tScootersData[GC_NPC]) do
                    local npc = gScooters.Button(scroll, sName, 0, 0, 0, 0, cAccentColor)
                    npc:Dock(TOP)
                    npc:DockMargin(0, 0, 0, 5)
                    npc:SetTall(40)

                    npc.DoClick = function(self)
                        surface.PlaySound("gscooters/click.wav")

                        local menu = DermaMenu() 

                        local delete = menu:AddOption(gScooters:GetPhrase("remove"), function() 
                            self:Remove()

                            net.Start("gScooters.Net.AdminDeleteEntity")
                            net.WriteString(sName)
                            net.WriteUInt(GC_NPC, 2)
                            net.SendToServer()
                        end)
                        
                        delete:SetIcon("icon16/delete.png")
        
                        menu:Open()
                    end
                end

                local modeToggle = gScooters.Button(frame, string.format("- %s -", gScooters:GetPhrase("retriever")), 0, 0, 0, 0, cAccentColor)
                modeToggle:Dock(BOTTOM)
                modeToggle:DockMargin(0, 5, 0, 0)
                modeToggle:SetTall(40)

                local line = vgui.Create("DPanel", frame)
                line:Dock(BOTTOM)
                line:SetTall(2)

                line.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, cMainColor) end

                local createNPC = gScooters.Button(frame, gScooters:GetPhrase("create_npc"), 0, 0, 0, 0, cAccentColor)
                createNPC:Dock(BOTTOM)
                createNPC:DockMargin(0, 0, 0, 5)
                createNPC:SetTall(40)

                createNPC.DoClick = function(self)
                    surface.PlaySound("gscooters/click.wav")

                    gScooters:ChatMessage(string.format(gScooters:GetPhrase("click_npc"), gScooters:GetPhrase("retriever")))

                    frame:AnimRemove()

                    local header = vgui.Create("DPanel")
                    header.Paint = function() end

                    local npc = ClientsideModel(gScooters.Config.RetrieverModel, RENDERGROUP_OPAQUE)
             
                    local function GC_SpawnPoint()
                        gScooters:ChatMessage(string.format(gScooters:GetPhrase("click_npc"), gScooters:GetPhrase("spawn_position")))

                        local bClickDelay = false
                        timer.Simple(1, function() bClickDelay = true end)
                        local baseFrame = vgui.Create("DPanel")
                        baseFrame.Paint = function() end

                        local base = ClientsideModel("models/squad/sf_plates/sf_plate4x7.mdl", RENDERGROUP_OPAQUE)
                        base:SetMaterial("models/shiny")
                        base:SetColor(cAccentColor)
                        
                        local mMatrix = Matrix()
                        mMatrix:Scale(Vector(3, 3, 1))
                        base:EnableMatrix("RenderMultiply", mMatrix)

                        baseFrame.Think = function()    
                            local tTrace = LocalPlayer():GetEyeTrace()
                            local vHitPos = tTrace.HitPos
                            local aNormal = tTrace.HitNormal:Angle()
                            local vBaseBoundsMin, vBaseBoundsMax = base:GetRenderBounds()
                            vBaseBoundsMax.y = vBaseBoundsMax.y * 3
                            vBaseBoundsMax.x = vBaseBoundsMax.x * 3

                            vBaseBoundsMin = base:LocalToWorld(vBaseBoundsMin)
                            vBaseBoundsMax = base:LocalToWorld(vBaseBoundsMax)

                            base:SetPos(Vector(vHitPos.x - ((vBaseBoundsMax.x - vBaseBoundsMin.x)/2), vHitPos.y - ((vBaseBoundsMax.y - vBaseBoundsMin.y)/2), vHitPos.z))
                            base:SetAngles(Angle(0, LocalPlayer():EyeAngles().y + 180, 0))

                            if input.IsMouseDown(MOUSE_LEFT) and bClickDelay then
                                surface.PlaySound("gscooters/click.wav")

                                baseFrame:Remove()

                                gScooters.Query(gScooters:GetPhrase("finalize_npc"), "gScooters", gScooters:GetPhrase("yes"), function()
                                    local tNPC = {}
                                    tNPC.Position = npc:GetPos()
                                    tNPC.Angle = npc:GetAngles()
                                    tNPC.VehiclePosition = vHitPos
                                    tNPC.VehicleAngle = Angle(0, LocalPlayer():EyeAngles().y + 180, 0)
                                    tNPC.VehicleMins = vBaseBoundsMin
                                    tNPC.VehicleMaxs = vBaseBoundsMax

                                    local tTableToSend = util.Compress(util.TableToJSON(tNPC))

                                    net.Start("gScooters.Net.AdminCreateEntity")
                                    net.WriteUInt(#tTableToSend, 22)
                                    net.WriteData(tTableToSend, #tTableToSend)
                                    net.WriteUInt(GC_NPC, 2)
                                    net.SendToServer()

                                    npc:Remove()
                                    base:Remove()

                                    GC_RequestRacks()
                                end,
                                gScooters:GetPhrase("no"), function()
                                    npc:Remove()
                                    base:Remove()

                                    GC_RequestRacks()
                                end)
                            end
                        end
                    end

                    
                    header.Think = function()
                        npc:SetPos(LocalPlayer():GetEyeTrace().HitPos)
                        npc:SetAngles(Angle(0, LocalPlayer():EyeAngles().y + 180, 0))

                        if input.IsMouseDown(MOUSE_LEFT) then
                            surface.PlaySound("gscooters/click.wav")

                            header:Remove()
                            GC_SpawnPoint()
                        end
                    end
                end

                modeToggle.DoClick = function()
                    surface.PlaySound("gscooters/click.wav")

                    createNPC:Remove()
                    scroll:Remove()
                    modeToggle:Remove()
                    line:Remove()

                    frame.RackMenu()
                end
            end

            frame.RackMenu = GC_Racks
            frame.NPCMenu = GC_NPCs

            GC_Racks()
        end
    end

    net.Receive("gScooters.Net.AdminSendData", function()
        local iNum = net.ReadUInt(22)
        local tJsonTableToRecieve = util.Decompress(net.ReadData(iNum))

        local tScooters 
        if not (tJsonTableToRecieve == "") then
            tScooters = util.JSONToTable(tJsonTableToRecieve)
        else
            tScooters = {}
        end

        GC_Menu(tScooters)
    end)

    function SWEP:Holster()
        if IsValid(frame) then frame:AnimRemove() end
        if IsValid(base) then base:Remove() end
        for _, tScooter in pairs(tScooterModels) do if IsValid(tScooter.ClientSideModel) then tScooter.ClientSideModel:Remove() end end
    end

    function SWEP:Deploy()
        GC_RequestRacks()
    end
    
    net.Receive("gScooters.Net.OpenAdminUI", GC_RequestRacks)
end

function SWEP:Initialize()
    self:SetHoldType("revolver")
    self.iCoolDown = false

    if CLIENT then
        local mRT = GetRenderTarget("GModToolgunScreen", iTextSize, iTextSize)
        local matScreen = Material("models/weapons/v_toolgun/screen")
        matScreen:SetTexture("$basetexture", mRT)
    
        local mLogo = Material("gScooters/logo.png", "$ignorez")
    
        function self:RenderScreen()
            render.PushRenderTarget(mRT)
            cam.Start2D()
                surface.SetDrawColor(cMainColor)
                surface.DrawRect(0, 0, iTextSize, iTextSize)
    
                surface.SetDrawColor(color_white)
                surface.SetMaterial(mLogo)
                surface.DrawTexturedRect((iTextSize-iLogoSize)/2 - 10, (iTextSize-iLogoSize)/2, iLogoSize, iLogoSize)
            cam.End2D()
            render.PopRenderTarget()
        end
    end
end

function SWEP:PrimaryAttack()
    if not self.iCoolDown then
        self.iCoolDown = true
        
        if CLIENT then
            LocalPlayer().GC_Editing = true 
        end

        timer.Simple(1, function() if IsValid(self) then self.iCoolDown = false end end)
    end
end

function SWEP:Reload()
    if not self.iCoolDown then
        self.iCoolDown = true
       
        timer.Simple(1, function() if IsValid(self) then self.iCoolDown = false end end)
    end
end