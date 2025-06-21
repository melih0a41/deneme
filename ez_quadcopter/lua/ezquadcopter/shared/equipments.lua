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
            -- Hoparlör durumu değiştiğinde quadcopter'ı senkronize etmeliyiz ki istemciler güncel durumu bilsin.
            easzy.quadcopter.SyncQuadcopter(quadcopter)
        end
    end)

    -- Speaker
    hook.Add("PlayerCanHearPlayersVoice", "ezquadcopter_speaker_PlayerCanHearPlayersVoice", function(listener, talker)
        local quadcopter = easzy.quadcopter.GetQuadcopter(talker)
        if not IsValid(quadcopter) then return end

        if not quadcopter.equipments["Speaker"] or not quadcopter.speakerOn then return end

        if listener:GetPos():DistToSqr(quadcopter:GetPos()) < 250000 then -- 500 birim kare
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

        -- Networked var ile değiştirildi
        local lightOn = net.ReadBool()
        quadcopter.lightOn = lightOn
    end)

    -- Speaker
    hook.Add("PlayerStartVoice", "ezquadcopter_speaker_PlayerStartVoice", function(ply)
        -- Sadece ses olayını başlatan oyuncu LocalPlayer ise devam et
        if ply == LocalPlayer() then
            local radioController = ply:GetActiveWeapon()
            -- Oyuncu bir quadcopter kontrolcüsü tutuyor mu ve quadcopter'ı var mı?
            if IsValid(radioController) and (radioController:GetClass() == "ez_quadcopter_fpv_radio_controller" or radioController:GetClass() == "ez_quadcopter_dji_radio_controller") then
                local quadcopter = radioController.quadcopter
                -- Quadcopter geçerli mi, Speaker ekipmanı var mı ve hoparlör açık mı?
                -- Bu bilgiler istemcide quadcopter.equipments ve quadcopter.speakerOn aracılığıyla senkronize edilmiş olmalıdır.
                if IsValid(quadcopter) and quadcopter.equipments and quadcopter.equipments["Speaker"] and quadcopter.speakerOn then
                    net.Start("ezquadcopter_quadcopter_speaker")
                    net.SendToServer()
                end
            end
        end
    end)

    hook.Add("PlayerEndVoice", "ezquadcopter_speaker_PlayerEndVoice", function(ply)
        -- Sadece ses olayını bitiren oyuncu LocalPlayer ise devam et
        if ply == LocalPlayer() then
            local radioController = ply:GetActiveWeapon()
            -- Oyuncu bir quadcopter kontrolcüsü tutuyor mu ve quadcopter'ı var mı?
            if IsValid(radioController) and (radioController:GetClass() == "ez_quadcopter_fpv_radio_controller" or radioController:GetClass() == "ez_quadcopter_dji_radio_controller") then
                local quadcopter = radioController.quadcopter
                -- Quadcopter geçerli mi, Speaker ekipmanı var mı ve hoparlör açık mı?
                if IsValid(quadcopter) and quadcopter.equipments and quadcopter.equipments["Speaker"] and quadcopter.speakerOn then
                    net.Start("ezquadcopter_quadcopter_speaker")
                    net.SendToServer()
                end
            end
        end
    end)
end