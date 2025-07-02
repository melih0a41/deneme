if SERVER then
    util.AddNetworkString("ezquadcopter_quadcopter_light")
    util.AddNetworkString("ezquadcopter_quadcopter_speaker")

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

        -- Speaker
        if quadcopter.equipments["Speaker"] and key == IN_USE then
            quadcopter.speakerOn = not quadcopter.speakerOn
        end
    end)

    -- Speaker
    hook.Add("PlayerCanHearPlayersVoice", "ezquadcopter_speaker_PlayerCanHearPlayersVoice", function(listener, talker)
        local quadcopter = easzy.quadcopter.GetQuadcopter(talker)
        if not IsValid(quadcopter) then return end

        if not quadcopter.equipments["Speaker"] or not quadcopter.speakerOn then return end

        if listener:GetPos():DistToSqr(quadcopter:GetPos()) < 250000 then
            return true
        end
    end)

    -- Speaker
    net.Receive("ezquadcopter_quadcopter_speaker", function(len, ply)
        local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
        if not IsValid(quadcopter) then return end

        if not quadcopter.equipments["Speaker"] or not quadcopter.speakerOn then return end

        quadcopter:EmitSound("easzy/ez_quadcopter/speaker.wav")
    end)
else
    -- Light
    net.Receive("ezquadcopter_quadcopter_light", function()
        local quadcopter = net.ReadEntity()
        if not IsValid(quadcopter) then return end

        -- Replace by networked var
        local lightOn = net.ReadBool()
        quadcopter.lightOn = lightOn
    end)

    -- Speaker
    hook.Add("PlayerStartVoice", "ezquadcopter_speaker_PlayerStartVoice", function(ply)
        net.Start("ezquadcopter_quadcopter_speaker")
        net.SendToServer()
    end)

    hook.Add("PlayerEndVoice", "ezquadcopter_speaker_PlayerEndVoice", function(ply)
        net.Start("ezquadcopter_quadcopter_speaker")
        net.SendToServer()
    end)
end
