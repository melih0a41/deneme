-- ezquadcopter/shared/equipments.lua
-- Bu dosyanın tamamını değiştirin

if SERVER then
    util.AddNetworkString("ezquadcopter_quadcopter_light")
    util.AddNetworkString("ezquadcopter_quadcopter_speaker")
    util.AddNetworkString("ezquadcopter_quadcopter_speaker_talking")
    util.AddNetworkString("ezquadcopter_microphone_active")

    hook.Add("KeyPress", "ezquadcopter_equipments_KeyPress", function(ply, key)
        if not easzy.quadcopter.IsHoldingRadioController(ply) then return end

        local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
        if not quadcopter.on then return end

        local quadcopterPos = quadcopter:GetPos()
        local class = quadcopter:GetClass()

        -- C4
        if quadcopter.equipments["C4"] and key == IN_RELOAD then
            local explosion = EffectData()
            explosion:SetStart(quadcopterPos)
            explosion:SetOrigin(quadcopterPos)
            explosion:SetMagnitude(12)
            explosion:SetScale(2)
            util.Effect("Explosion", explosion, true, true)

            util.BlastDamage(quadcopter, ply, quadcopterPos, 200, 200)
            quadcopter:Remove()
            local radioController = easzy.quadcopter.GetRadioController(quadcopter)
            if IsValid(radioController) then radioController:Remove() end
        end

        -- Bomb
        if quadcopter.equipments["Bomb"] and key == IN_RELOAD then
            local equipment = easzy.quadcopter.quadcoptersData[class].equipments["Bomb"]
            if not equipment then return end

            easzy.quadcopter.SetBodygroupByName(quadcopter, equipment.bodygroup, "")

            local bomb = ents.Create("ez_quadcopter_bomb")
            bomb:SetPos(quadcopter:GetPos() + Vector(0, 0, -3))
            bomb:SetAngles(Angle(0, 0, 90))
            bomb:Spawn()
            bomb:GetPhysicsObject():SetVelocity(quadcopter:GetPhysicsObject():GetVelocity())

            -- Explode at contact
            bomb:AddCallback("PhysicsCollide", function(ent, data)
                bomb:Explode(ply)
            end)

            quadcopter.equipments["Bomb"] = false
            easzy.quadcopter.SyncQuadcopter(quadcopter)
        end

        -- Light
        if quadcopter.equipments["Light"] and key == IN_WALK then
            quadcopter.lightOn = not quadcopter.lightOn

            net.Start("ezquadcopter_quadcopter_light")
            net.WriteEntity(quadcopter)
            net.WriteBool(quadcopter.lightOn)
            net.Broadcast()
        end
    end)

    -- Speaker - Voice chat override
    hook.Add("PlayerCanHearPlayersVoice", "ezquadcopter_speaker_PlayerCanHearPlayersVoice", function(listener, talker)
        -- SPEAKER: Check if talker is using quadcopter
        local talkerQuadcopter = easzy.quadcopter.GetQuadcopter(talker)
        if IsValid(talkerQuadcopter) and talkerQuadcopter.equipments["Speaker"] and talkerQuadcopter.on and easzy.quadcopter.IsHoldingRadioController(talker) then
            -- Mute at player's position
            if listener:GetPos():DistToSqr(talker:GetPos()) < 10000 then
                return false, false
            end
            
            -- Enable at drone position
            if listener:GetPos():DistToSqr(talkerQuadcopter:GetPos()) < 250000 then
                return true, true
            end
            
            return false, false
        end
        
        -- MICROPHONE: Check if listener is using quadcopter
        local listenerQuadcopter = easzy.quadcopter.GetQuadcopter(listener)
        if IsValid(listenerQuadcopter) and listenerQuadcopter.on and listenerQuadcopter.equipments["Microphone"] then
            -- If talker is near the drone
            if talker:GetPos():DistToSqr(listenerQuadcopter:GetPos()) < 360000 then
                return true, false
            end
        end
    end)
    
    -- Voice position override for speaker
    hook.Add("PlayerVoiceLocation", "ezquadcopter_speaker_PlayerVoiceLocation", function(ply)
        local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
        if not IsValid(quadcopter) then return end
        
        if not quadcopter.equipments["Speaker"] or not quadcopter.on then return end
        
        if not easzy.quadcopter.IsHoldingRadioController(ply) then return end
        
        return quadcopter:GetPos()
    end)

    -- Notify clients when someone starts/stops talking through drone
    net.Receive("ezquadcopter_quadcopter_speaker_talking", function(len, ply)
        local talking = net.ReadBool()
        local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
        if not IsValid(quadcopter) then return end

        if not quadcopter.equipments["Speaker"] or not quadcopter.on then return end

        -- Broadcast to all players near the drone
        local nearbyPlayers = {}
        for _, p in ipairs(player.GetAll()) do
            if p:GetPos():DistToSqr(quadcopter:GetPos()) < 250000 then
                table.insert(nearbyPlayers, p)
            end
        end
        
        net.Start("ezquadcopter_quadcopter_speaker")
        net.WriteEntity(quadcopter)
        net.WriteBool(talking)
        net.Send(nearbyPlayers)
    end)
    
    -- Microphone system
    timer.Create("ezquadcopter_microphone_check", 0.5, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
            if IsValid(quadcopter) and quadcopter.on and quadcopter.equipments["Microphone"] then
                -- Check if anyone is talking near the drone
                local talking = false
                for _, other in ipairs(player.GetAll()) do
                    if other != ply and other:VoiceVolume() > 0 then
                        if other:GetPos():DistToSqr(quadcopter:GetPos()) < 360000 then
                            talking = true
                            break
                        end
                    end
                end
                
                net.Start("ezquadcopter_microphone_active")
                net.WriteEntity(quadcopter)
                net.WriteBool(talking)
                net.Send(ply)
            end
        end
    end)
else
    -- CLIENT
    
    -- Light
    net.Receive("ezquadcopter_quadcopter_light", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        local lightOn = net.ReadBool()
        quadcopter.lightOn = lightOn
    end)

    -- Speaker sound effect
    net.Receive("ezquadcopter_quadcopter_speaker", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end
        
        local talking = net.ReadBool()
        
        if talking then
            quadcopter:EmitSound("npc/combine_soldier/vo/on2.wav", 65, 120, 0.3)
        else
            quadcopter:EmitSound("npc/combine_soldier/vo/off2.wav", 65, 120, 0.3)
        end
    end)

    -- Override voice key when using drone
    hook.Add("PlayerBindPress", "ezquadcopter_speaker_PlayerBindPress", function(ply, bind, pressed)
        if string.find(bind, "+voicerecord") then
            local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
            if IsValid(quadcopter) and quadcopter.equipments["Speaker"] and quadcopter.on then
                if pressed then
                    net.Start("ezquadcopter_quadcopter_speaker_talking")
                    net.WriteBool(true)
                    net.SendToServer()
                end
            end
        elseif string.find(bind, "-voicerecord") then
            local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
            if IsValid(quadcopter) and quadcopter.equipments["Speaker"] and quadcopter.on then
                net.Start("ezquadcopter_quadcopter_speaker_talking")
                net.WriteBool(false)
                net.SendToServer()
            end
        end
    end)
    
    -- Microphone active indicator
    net.Receive("ezquadcopter_microphone_active", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end
        
        local active = net.ReadBool()
        quadcopter.microphoneActive = active
        
        -- Sound effect
        if active and not quadcopter.lastMicSound then
            quadcopter:EmitSound("npc/scanner/scanner_blip1.wav", 65, 100, 0.3)
            quadcopter.lastMicSound = true
        elseif not active then
            quadcopter.lastMicSound = false
        end
    end)
    
    -- Visual indicators
    hook.Add("HUDPaint", "ezquadcopter_equipment_indicators", function()
        local localPlayer = LocalPlayer()
        
        -- Speaker indicator for other drones
        for _, quadcopter in ipairs(ents.FindByClass("ez_quadcopter_*")) do
            if IsValid(quadcopter) and quadcopter.equipments and quadcopter.equipments["Speaker"] then
                local owner = quadcopter:CPPIGetOwner()
                if IsValid(owner) and owner != localPlayer then
                    if owner:VoiceVolume() > 0 then
                        local pos = quadcopter:GetPos():ToScreen()
                        if pos.visible then
                            surface.SetDrawColor(255, 255, 255, 200 + math.sin(CurTime() * 10) * 50)
                            surface.SetMaterial(Material("icon16/sound.png"))
                            surface.DrawTexturedRect(pos.x - 16, pos.y - 32, 32, 32)
                        end
                    end
                end
            end
        end
        
        -- Microphone indicator for own drone
        local quadcopter = easzy.quadcopter.GetQuadcopter(localPlayer)
        if IsValid(quadcopter) and quadcopter.on and quadcopter.equipments["Microphone"] then
            if quadcopter.microphoneActive then
                local x = ScrW() - 200
                local y = 100
                
                local alpha = 200 + math.sin(CurTime() * 5) * 55
                
                draw.RoundedBox(8, x - 5, y - 5, 160, 40, Color(0, 0, 0, 150))
                
                surface.SetDrawColor(255, 100, 100, alpha)
                surface.SetMaterial(Material("icon16/sound.png"))
                surface.DrawTexturedRect(x, y, 32, 32)
                
                draw.SimpleText("MIKROFON AKTIF", "DermaDefault", x + 40, y + 16, Color(255, 100, 100, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                -- Sound waves effect
                for i = 1, 3 do
                    local waveAlpha = math.max(0, alpha - i * 60)
                    local waveSize = 32 + i * 8
                    surface.SetDrawColor(255, 100, 100, waveAlpha)
                    draw.NoTexture()
                    
                    local segments = 16
                    local circle = {}
                    for j = 0, segments do
                        local angle = (j / segments) * math.pi * 2
                        table.insert(circle, {
                            x = x + 16 + math.cos(angle) * waveSize/2,
                            y = y + 16 + math.sin(angle) * waveSize/2
                        })
                    end
                    surface.DrawPoly(circle)
                end
            end
        end
    end)
end