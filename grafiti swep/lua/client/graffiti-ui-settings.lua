function GraffitiSettings()
    if (CLIENT) then
        local Frame = vgui.Create('DFrame')
            Frame:SetSize(300, 450)
            Frame:SetPos(ScrW() / 2 + 470, ScrH() / 2 - 250)
            Frame:SetTitle('Graffiti Settings')
            Frame:SetVisible(true)
            Frame:SetDraggable(true)
            Frame:ShowCloseButton(true)
            Frame:SetPaintShadow(true)
            Frame:MakePopup()

            Frame.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 200))
            end

            Frame.OnClose = function()
                LocalPlayer():SetNWInt('GraffitiSettings', 0)
            end

            if (LocalPlayer():GetNWBool('GraffitiModeSettings') == nil) then
                LocalPlayer():SetNWInt('GraffitiModeSettings', 0)
            end

            DermaClientButton = vgui.Create('DButton', Frame)
                DermaClientButton:SetText('')
                DermaClientButton:SetPos(45, 30)
                DermaClientButton:SetSize(85, 25)
            local DClientLabel = vgui.Create('DLabel', Frame)
                DClientLabel:SetText('CLIENT')
                DClientLabel:SetPos(70, 30)
                DClientLabel:SetSize(85, 25)
                DClientLabel:SetColor(Color(0, 0, 0, 255))

                if (LocalPlayer():GetNWInt('GraffitiModeSettings') == 0) then

                    DermaClientButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 255))
                    end

                    DCheckBoxSounds = vgui.Create('DCheckBox', Frame)
                        DCheckBoxSounds:SetPos(30, 70)
                        if (LocalPlayer():GetNWBool('GraffitiInterfaceSounds') == false) then
                            DCheckBoxSounds:SetChecked(false)
                        elseif (LocalPlayer():GetNWBool('GraffitiInterfaceSounds') == true) then
                            DCheckBoxSounds:SetChecked(true)
                        end
                        DCheckBoxSounds.OnChange = function(panel, value)
                            LocalPlayer():SetNWBool('GraffitiInterfaceSounds', value)
                            file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                        end
                    DLabelSounds = vgui.Create('DLabel', Frame)
                        DLabelSounds:SetPos(50, 65)
                        DLabelSounds:SetSize(200, 25)
                        DLabelSounds:SetColor(Color(255, 255, 255, 255))
                        DLabelSounds:SetText('Allow sounds in the interface')

                    DCheckBoxSkin = vgui.Create('DCheckBox', Frame)
                        DCheckBoxSkin:SetPos(30, 90)
                        if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                            DCheckBoxSkin:SetChecked(false)
                        elseif (LocalPlayer():GetNWBool('GraffitiSkin') == true) then
                            DCheckBoxSkin:SetChecked(true)
                        end
                        DCheckBoxSkin.OnChange = function(panel, value)
                            LocalPlayer():SetNWBool('GraffitiSkin', value)
                            if (value == true) then
                                DCheckBoxSkin_1:SetEnabled(true)
                                DCheckBoxSkin_2:SetEnabled(true)
                                DCheckBoxSkin_3:SetEnabled(true)
                            elseif (value == false) then
                                DCheckBoxSkin_1:SetEnabled(false)
                                DCheckBoxSkin_2:SetEnabled(false)
                                DCheckBoxSkin_3:SetEnabled(false)
                            end
                            file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(value) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                        end
                    DLabelSKin = vgui.Create('DLabel', Frame)
                        DLabelSKin:SetPos(50, 85)
                        DLabelSKin:SetSize(200, 25)
                        DLabelSKin:SetColor(Color(255, 255, 255, 255))
                        DLabelSKin:SetText('Allow skin changing')

                    DCheckBoxSkin_1 = vgui.Create('DCheckBox', Frame)
                        DCheckBoxSkin_1:SetPos(50, 115)
                        if (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 1) then
                            DCheckBoxSkin_1:SetChecked(true)
                        else 
                            DCheckBoxSkin_1:SetChecked(false)
                        end
                        if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                            DCheckBoxSkin_1:SetEnabled(false)
                        end
                        DCheckBoxSkin_1.OnChange = function(panel, value)
                            LocalPlayer():SetNWInt('GraffitiSkinSelected', 1)
                            DCheckBoxSkin_2:SetChecked(false)
                            DCheckBoxSkin_3:SetChecked(false)
                            file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                        end
                    DLabelSKin_1 = vgui.Create('DLabel', Frame)
                        DLabelSKin_1:SetPos(70, 110)
                        DLabelSKin_1:SetSize(200, 25)
                        DLabelSKin_1:SetColor(Color(255, 255, 255, 255))
                        DLabelSKin_1:SetText('The art of classics')

                    DCheckBoxSkin_2 = vgui.Create('DCheckBox', Frame)
                        DCheckBoxSkin_2:SetPos(50, 135)
                        if (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 2) then
                            DCheckBoxSkin_2:SetChecked(true)
                        else 
                            DCheckBoxSkin_2:SetChecked(false)
                        end
                        if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                            DCheckBoxSkin_2:SetEnabled(false)
                        end
                        DCheckBoxSkin_2.OnChange = function(panel, value)
                            LocalPlayer():SetNWInt('GraffitiSkinSelected', 2)
                            DCheckBoxSkin_1:SetChecked(false)
                            DCheckBoxSkin_3:SetChecked(false)
                            file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                        end
                    DLabelSKin_2 = vgui.Create('DLabel', Frame)
                        DLabelSKin_2:SetPos(70, 130)
                        DLabelSKin_2:SetSize(200, 25)
                        DLabelSKin_2:SetColor(Color(255, 255, 255, 255))
                        DLabelSKin_2:SetText('The colorless wolf')

                    DCheckBoxSkin_3 = vgui.Create('DCheckBox', Frame)
                        DCheckBoxSkin_3:SetPos(50, 155)
                        if (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 3) then
                            DCheckBoxSkin_3:SetChecked(true)
                        else 
                            DCheckBoxSkin_3:SetChecked(false)
                        end
                        if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                            DCheckBoxSkin_3:SetEnabled(false)
                        end
                        DCheckBoxSkin_3.OnChange = function(panel, value)
                            LocalPlayer():SetNWInt('GraffitiSkinSelected', 3)
                            DCheckBoxSkin_1:SetChecked(false)
                            DCheckBoxSkin_2:SetChecked(false)
                            file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                        end
                    DLabelSKin_3 = vgui.Create('DLabel', Frame)
                        DLabelSKin_3:SetPos(70, 150)
                        DLabelSKin_3:SetSize(200, 25)
                        DLabelSKin_3:SetColor(Color(255, 255, 255, 255))
                        DLabelSKin_3:SetText('Distorted madness')
                    DLabelNote_1 = vgui.Create('DLabel', Frame)
                        DLabelNote_1:SetPos(25, 175)
                        DLabelNote_1:SetSize(300, 25)
                        DLabelNote_1:SetColor(Color(255, 255, 255, 255))
                        DLabelNote_1:SetText('Note: to change the skin, you need to reinitialize')
                    DLabelNote_2 = vgui.Create('DLabel', Frame)
                        DLabelNote_2:SetPos(55, 190)
                        DLabelNote_2:SetSize(300, 25)
                        DLabelNote_2:SetColor(Color(255, 255, 255, 255))
                        DLabelNote_2:SetText('the weapon (the way to do this - death)')

                elseif (LocalPlayer():GetNWInt('GraffitiModeSettings') == 1) then
                    DermaClientButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(200, 200, 200, 255))
                    end
                end

                DermaClientButton.DoClick = function()
                    DermaClientButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 255))
                    end
                    DermaServerButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(200, 200, 200, 255))
                    end

                    elements = {DCheckBoxAdmins, DLabelAdmins, DCheckBoxCanModify, DLabelCanModify, DCheckBoxCanSonds, DLabelCanSonds, DCheckBoxCanParticle, DLabelCanParticle, DCheckBoxExplosion, DLabelExplosion, DSliderDistance, DLabelDistance, DLabelNote_3, DLabelNote_4}
                    for i=1,14 do
                        elements[i]:Remove()
                    end

                    if (LocalPlayer():GetNWInt('GraffitiModeSettings') == 1) then
                        DCheckBoxSounds = vgui.Create('DCheckBox', Frame)
                            DCheckBoxSounds:SetPos(30, 70)
                            if (LocalPlayer():GetNWBool('GraffitiInterfaceSounds') == false) then
                                DCheckBoxSounds:SetChecked(false)
                            elseif (LocalPlayer():GetNWBool('GraffitiInterfaceSounds') == true) then
                                DCheckBoxSounds:SetChecked(true)
                            end
                            DCheckBoxSounds.OnChange = function(panel, value)
                                LocalPlayer():SetNWBool('GraffitiInterfaceSounds', value)
                                file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWInt('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                            end
                        DLabelSounds = vgui.Create('DLabel', Frame)
                            DLabelSounds:SetPos(50, 65)
                            DLabelSounds:SetSize(200, 25)
                            DLabelSounds:SetColor(Color(255, 255, 255, 255))
                            DLabelSounds:SetText('Allow sounds in the interface')
                        DCheckBoxSkin = vgui.Create('DCheckBox', Frame)
                            DCheckBoxSkin:SetPos(30, 90)
                            if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                                DCheckBoxSkin:SetChecked(false)
                            elseif (LocalPlayer():GetNWBool('GraffitiSkin') == true) then
                                DCheckBoxSkin:SetChecked(true)
                            end
                            DCheckBoxSkin.OnChange = function(panel, value)
                                LocalPlayer():SetNWBool('GraffitiSkin', value)
                                if (value == true) then
                                    DCheckBoxSkin_1:SetEnabled(true)
                                    DCheckBoxSkin_2:SetEnabled(true)
                                    DCheckBoxSkin_3:SetEnabled(true)
                                elseif (value == false) then
                                    DCheckBoxSkin_1:SetEnabled(false)
                                    DCheckBoxSkin_2:SetEnabled(false)
                                    DCheckBoxSkin_3:SetEnabled(false)
                                end
                                file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(value) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                            end
                        DLabelSKin = vgui.Create('DLabel', Frame)
                            DLabelSKin:SetPos(50, 85)
                            DLabelSKin:SetSize(200, 25)
                            DLabelSKin:SetColor(Color(255, 255, 255, 255))
                            DLabelSKin:SetText('Allow skin changing')

                        DCheckBoxSkin_1 = vgui.Create('DCheckBox', Frame)
                            DCheckBoxSkin_1:SetPos(50, 115)
                            if (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 1) then
                                DCheckBoxSkin_1:SetChecked(true)
                            else 
                                DCheckBoxSkin_1:SetChecked(false)
                            end
                            if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                                DCheckBoxSkin_1:SetEnabled(false)
                            end
                            DCheckBoxSkin_1.OnChange = function(panel, value)
                                LocalPlayer():SetNWInt('GraffitiSkinSelected', 1)
                                DCheckBoxSkin_2:SetChecked(false)
                                DCheckBoxSkin_3:SetChecked(false)
                                file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                            end
                        DLabelSKin_1 = vgui.Create('DLabel', Frame)
                            DLabelSKin_1:SetPos(70, 110)
                            DLabelSKin_1:SetSize(200, 25)
                            DLabelSKin_1:SetColor(Color(255, 255, 255, 255))
                            DLabelSKin_1:SetText('The art of classics')

                        DCheckBoxSkin_2 = vgui.Create('DCheckBox', Frame)
                            DCheckBoxSkin_2:SetPos(50, 135)
                            if (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 2) then
                                DCheckBoxSkin_2:SetChecked(true)
                            else 
                                DCheckBoxSkin_2:SetChecked(false)
                            end
                            if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                                DCheckBoxSkin_2:SetEnabled(false)
                            end
                            DCheckBoxSkin_2.OnChange = function(panel, value)
                                LocalPlayer():SetNWInt('GraffitiSkinSelected', 2)
                                DCheckBoxSkin_1:SetChecked(false)
                                DCheckBoxSkin_3:SetChecked(false)
                                file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                            end
                        DLabelSKin_2 = vgui.Create('DLabel', Frame)
                            DLabelSKin_2:SetPos(70, 130)
                            DLabelSKin_2:SetSize(200, 25)
                            DLabelSKin_2:SetColor(Color(255, 255, 255, 255))
                            DLabelSKin_2:SetText('The colorless wolf')

                        DCheckBoxSkin_3 = vgui.Create('DCheckBox', Frame)
                            DCheckBoxSkin_3:SetPos(50, 155)
                            if (tonumber(LocalPlayer():GetNWInt('GraffitiSkinSelected')) == 3) then
                                DCheckBoxSkin_3:SetChecked(true)
                            else 
                                DCheckBoxSkin_3:SetChecked(false)
                            end
                            if (LocalPlayer():GetNWBool('GraffitiSkin') == false) then
                                DCheckBoxSkin_3:SetEnabled(false)
                            end
                            DCheckBoxSkin_3.OnChange = function(panel, value)
                                LocalPlayer():SetNWInt('GraffitiSkinSelected', 3)
                                DCheckBoxSkin_1:SetChecked(false)
                                DCheckBoxSkin_2:SetChecked(false)
                                file.Write('graffiti-swep/graffiti-settings-client.txt', tostring(LocalPlayer():GetNWBool('GraffitiInterfaceSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiSkin')) .. '\n' .. LocalPlayer():GetNWInt('GraffitiSkinSelected'))
                            end
                        DLabelSKin_3 = vgui.Create('DLabel', Frame)
                            DLabelSKin_3:SetPos(70, 150)
                            DLabelSKin_3:SetSize(200, 25)
                            DLabelSKin_3:SetColor(Color(255, 255, 255, 255))
                            DLabelSKin_3:SetText('Distorted madness')
                        DLabelNote_1 = vgui.Create('DLabel', Frame)
                            DLabelNote_1:SetPos(25, 175)
                            DLabelNote_1:SetSize(300, 25)
                            DLabelNote_1:SetColor(Color(255, 255, 255, 255))
                            DLabelNote_1:SetText('Note: to change the skin, you need to reinitialize')
                        DLabelNote_2 = vgui.Create('DLabel', Frame)
                            DLabelNote_2:SetPos(55, 190)
                            DLabelNote_2:SetSize(300, 25)
                            DLabelNote_2:SetColor(Color(255, 255, 255, 255))
                            DLabelNote_2:SetText('the weapon (the way to do this - death)')
                    end
                    LocalPlayer():SetNWInt('GraffitiModeSettings', 0)
                end

            DermaServerButton = vgui.Create('DButton', Frame)
                DermaServerButton:SetText('')
                DermaServerButton:SetPos(165, 30)
                DermaServerButton:SetSize(85, 25)
            local DServerLabel = vgui.Create('DLabel', Frame)
                DServerLabel:SetText('SERVER')
                DServerLabel:SetPos(190, 30)
                DServerLabel:SetSize(85, 25)
                DServerLabel:SetColor(Color(0, 0, 0, 255))

                if (LocalPlayer():GetNWInt('GraffitiModeSettings') == 1) then
                    DermaServerButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 255))
                    end
                    DCheckBoxAdmins = vgui.Create('DCheckBox', Frame)
                        DCheckBoxAdmins:SetPos(30, 70)
                        if (LocalPlayer():IsSuperAdmin() == true) then
                            if (LocalPlayer():GetNWBool('GraffitiAdmins') == false) then
                                DCheckBoxAdmins:SetChecked(false)
                            elseif (LocalPlayer():GetNWBool('GraffitiAdmins') == true) then
                                DCheckBoxAdmins:SetChecked(true)
                            end
                        else
                            DCheckBoxAdmins:SetEnabled(false)
                        end
                        DCheckBoxAdmins.OnChange = function(panel, value)
                            if (LocalPlayer():IsSuperAdmin() == true) then
                                LocalPlayer():SetNWBool('GraffitiAdmins', value)
                                file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                if (value == false) then
                                    RunConsoleCommand('graffiti_admins_only', 0)
                                elseif (value == true) then
                                    RunConsoleCommand('graffiti_admins_only', 1)
                                end
                            end
                        end
                    DLabelAdmins = vgui.Create('DLabel', Frame)
                        DLabelAdmins:SetPos(50, 65)
                        DLabelAdmins:SetSize(200, 25)
                        DLabelAdmins:SetColor(Color(255, 255, 255, 255))
                        DLabelAdmins:SetText('Allow only administrators to use weapon')
                    DCheckBoxCanModify = vgui.Create('DCheckBox', Frame)
                        DCheckBoxCanModify:SetPos(30, 90)
                        if (LocalPlayer():IsSuperAdmin() == true) then
                            if (LocalPlayer():GetNWBool('GraffitiCanModify') == false) then
                                DCheckBoxCanModify:SetChecked(false)
                            elseif (LocalPlayer():GetNWBool('GraffitiCanModify') == true) then
                                DCheckBoxCanModify:SetChecked(true)
                            end
                        else
                            DCheckBoxCanModify:SetEnabled(false)
                        end
                        DCheckBoxCanModify.OnChange = function(panel, value)
                            if (LocalPlayer():IsSuperAdmin()) then
                                LocalPlayer():SetNWBool('GraffitiCanModify', value)
                                file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                if (value == true) then
                                    DCheckBoxCanSonds:SetEnabled(true)
                                    DCheckBoxCanParticle:SetEnabled(true)
                                elseif (value == false) then
                                    DCheckBoxCanSonds:SetEnabled(false)
                                    DCheckBoxCanParticle:SetEnabled(false)
                                end
                            end
                        end
                        DLabelCanModify = vgui.Create('DLabel', Frame)
                            DLabelCanModify:SetPos(50, 85)
                            DLabelCanModify:SetSize(200, 25)
                            DLabelCanModify:SetColor(Color(255, 255, 255, 255))
                            DLabelCanModify:SetText('Allow weapon changes')

                    DCheckBoxCanSonds = vgui.Create('DCheckBox', Frame)
                        DCheckBoxCanSonds:SetPos(50, 115)
                        if (LocalPlayer():IsSuperAdmin() == true) then
                            if (LocalPlayer():GetNWBool('GraffitiCanSounds') == false) then
                                DCheckBoxCanSonds:SetChecked(false)
                            elseif (LocalPlayer():GetNWBool('GraffitiCanSounds') == true) then
                                DCheckBoxCanSonds:SetChecked(true)
                            end
                            if (LocalPlayer():GetNWBool('GraffitiCanModify') == false) then
                                DCheckBoxCanSonds:SetEnabled(false)
                            end
                        else
                            DCheckBoxCanSonds:SetEnabled(false)
                        end
                        DCheckBoxCanSonds.OnChange = function(panel, value)
                            if (LocalPlayer():IsSuperAdmin()) then
                                LocalPlayer():SetNWBool('GraffitiCanSounds', value)
                                file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                if (value == false) then
                                    RunConsoleCommand('graffiti_can_sounds', 0)
                                elseif (value == true) then
                                    RunConsoleCommand('graffiti_can_sounds', 1)
                                end
                            end
                        end
                        DLabelCanSonds = vgui.Create('DLabel', Frame)
                            DLabelCanSonds:SetPos(70, 110)
                            DLabelCanSonds:SetSize(200, 25)
                            DLabelCanSonds:SetColor(Color(255, 255, 255, 255))
                            DLabelCanSonds:SetText('Spraying sounds')
                    DCheckBoxCanParticle = vgui.Create('DCheckBox', Frame)
                        DCheckBoxCanParticle:SetPos(50, 135)
                        if (LocalPlayer():IsSuperAdmin() == true) then
                            if (LocalPlayer():GetNWBool('GraffitiCanParticle') == false) then
                                DCheckBoxCanParticle:SetChecked(false)
                            elseif (LocalPlayer():GetNWBool('GraffitiCanParticle') == true) then
                                DCheckBoxCanParticle:SetChecked(true)
                            end
                            if (LocalPlayer():GetNWBool('GraffitiCanModify') == false) then
                                DCheckBoxCanParticle:SetEnabled(false)
                            end
                        else
                            DCheckBoxCanParticle:SetEnabled(false)
                        end
                        DCheckBoxCanParticle.OnChange = function(panel, value)
                            if (LocalPlayer():IsSuperAdmin()) then
                                LocalPlayer():SetNWBool('GraffitiCanParticle', value)
                                file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                if (value == false) then
                                    RunConsoleCommand('graffiti_can_particle', 0)
                                elseif (value == true) then
                                    RunConsoleCommand('graffiti_can_particle', 1)
                                end
                            end
                        end
                        DLabelCanParticle = vgui.Create('DLabel', Frame)
                            DLabelCanParticle:SetPos(70, 130)
                            DLabelCanParticle:SetSize(200, 25)
                            DLabelCanParticle:SetColor(Color(255, 255, 255, 255))
                            DLabelCanParticle:SetText('Spraying particles')
                    DCheckBoxExplosion = vgui.Create('DCheckBox', Frame)
                        DCheckBoxExplosion:SetPos(30, 165)
                        if (LocalPlayer():IsSuperAdmin() == true) then
                            if (LocalPlayer():GetNWBool('GraffitiExplosion') == false) then
                                DCheckBoxExplosion:SetChecked(false)
                            elseif (LocalPlayer():GetNWBool('GraffitiExplosion') == true) then
                                DCheckBoxExplosion:SetChecked(true)
                            end
                        else
                            DCheckBoxExplosion:SetEnabled(false)
                        end
                        DCheckBoxExplosion.OnChange = function(panel, value)
                            if (LocalPlayer():IsSuperAdmin()) then
                                LocalPlayer():SetNWBool('GraffitiExplosion', value)
                                file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(value))
                                if (value == false) then
                                    RunConsoleCommand('graffiti_explosion', 0)
                                elseif (value == true) then
                                    RunConsoleCommand('graffiti_explosion', 1)
                                end
                            end
                        end
                        DLabelExplosion = vgui.Create('DLabel', Frame)
                            DLabelExplosion:SetPos(50, 160)
                            DLabelExplosion:SetSize(200, 25)
                            DLabelExplosion:SetColor(Color(255, 255, 255, 255))
                            DLabelExplosion:SetText('Explosive spraying')
                    DSliderDistance = vgui.Create('DNumSlider', Frame)
                        DSliderDistance:SetPos(-140, 210)
                        DSliderDistance:SetSize(420, 25)
                        DSliderDistance:SetText('')
                        DSliderDistance:SetMin(140)
                        DSliderDistance:SetMax(9999)
                        DSliderDistance:SetValue(GetConVar('graffiti_max_distance'):GetInt())
                        if (LocalPlayer():IsSuperAdmin() == true) then
                            DSliderDistance:SetValue(140)
                        else
                            DSliderDistance:SetValue(140)
                            DSliderDistance:SetEnabled(false)
                        end
                        DSliderDistance.OnValueChanged = function(panel, value)
                            if (LocalPlayer():IsSuperAdmin()) and (value != GetConVar('graffiti_max_distance'):GetInt()) then
                                RunConsoleCommand('graffiti_max_distance', value)
                            end
                        end
                        DLabelDistance = vgui.Create('DLabel', Frame)
                            DLabelDistance:SetPos(20, 190)
                            DLabelDistance:SetSize(200, 25)
                            DLabelDistance:SetColor(Color(255, 255, 255, 255))
                            DLabelDistance:SetText('Graffiti Max Distance:')
                    DLabelNote_3 = vgui.Create('DLabel', Frame)
                            DLabelNote_3:SetPos(30, 235)
                            DLabelNote_3:SetSize(300, 25)
                            DLabelNote_3:SetColor(Color(255, 255, 255, 255))
                            DLabelNote_3:SetText('Note: Graffiti Max Distance is reset every time')
                    DLabelNote_4 = vgui.Create('DLabel', Frame)
                            DLabelNote_4:SetPos(65, 250)
                            DLabelNote_4:SetSize(300, 25)
                            DLabelNote_4:SetColor(Color(255, 255, 255, 255))
                            DLabelNote_4:SetText('the menu is opened')

                elseif (LocalPlayer():GetNWInt('GraffitiModeSettings') == 0) then
                    DermaServerButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(200, 200, 200, 255))
                    end
                end

                DermaServerButton.DoClick = function()
                    DermaServerButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 255))
                    end
                    DermaClientButton.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(200, 200, 200, 255))
                    end

                    elements = {DCheckBoxSounds, DLabelSounds, DCheckBoxSkin, DLabelSKin, DCheckBoxSkin_1, DLabelSKin_1, DCheckBoxSkin_2, DLabelSKin_2, DCheckBoxSkin_3, DLabelSKin_3, DLabelNote_1, DLabelNote_2}
                    for i=1,12 do
                        elements[i]:Remove()
                    end

                    if (LocalPlayer():GetNWInt('GraffitiModeSettings') == 0) then
                        DCheckBoxAdmins = vgui.Create('DCheckBox', Frame)
                            DCheckBoxAdmins:SetPos(30, 70)
                            if (LocalPlayer():IsSuperAdmin() == true) then
                                if (LocalPlayer():GetNWBool('GraffitiAdmins') == false) then
                                    DCheckBoxAdmins:SetChecked(false)
                                elseif (LocalPlayer():GetNWBool('GraffitiAdmins') == true) then
                                    DCheckBoxAdmins:SetChecked(true)
                                end
                            else
                                DCheckBoxAdmins:SetEnabled(false)
                            end
                            DCheckBoxAdmins.OnChange = function(panel, value)
                                if (LocalPlayer():IsSuperAdmin() == true) then
                                    LocalPlayer():SetNWBool('GraffitiAdmins', value)
                                    file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                    if (value == false) then
                                        RunConsoleCommand('graffiti_admins_only', 0)
                                    elseif (value == true) then
                                        RunConsoleCommand('graffiti_admins_only', 1)
                                    end
                                end
                            end
                        DLabelAdmins = vgui.Create('DLabel', Frame)
                            DLabelAdmins:SetPos(50, 65)
                            DLabelAdmins:SetSize(200, 25)
                            DLabelAdmins:SetColor(Color(255, 255, 255, 255))
                            DLabelAdmins:SetText('Allow only administrators to use weapon')
                        DCheckBoxCanModify = vgui.Create('DCheckBox', Frame)
                            DCheckBoxCanModify:SetPos(30, 90)
                            if (LocalPlayer():IsSuperAdmin() == true) then
                                if (LocalPlayer():GetNWBool('GraffitiCanModify') == false) then
                                    DCheckBoxCanModify:SetChecked(false)
                                elseif (LocalPlayer():GetNWBool('GraffitiCanModify') == true) then
                                    DCheckBoxCanModify:SetChecked(true)
                                end
                            else
                                DCheckBoxCanModify:SetEnabled(false)
                            end
                            DCheckBoxCanModify.OnChange = function(panel, value)
                                if (LocalPlayer():IsSuperAdmin()) then
                                    LocalPlayer():SetNWBool('GraffitiCanModify', value)
                                    file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                    if (value == true) then
                                        DCheckBoxCanSonds:SetEnabled(true)
                                        DCheckBoxCanParticle:SetEnabled(true)
                                    elseif (value == false) then
                                        DCheckBoxCanSonds:SetEnabled(false)
                                        DCheckBoxCanParticle:SetEnabled(false)
                                    end
                                end
                            end
                            DLabelCanModify = vgui.Create('DLabel', Frame)
                                DLabelCanModify:SetPos(50, 85)
                                DLabelCanModify:SetSize(200, 25)
                                DLabelCanModify:SetColor(Color(255, 255, 255, 255))
                                DLabelCanModify:SetText('Allow weapon changes')

                        DCheckBoxCanSonds = vgui.Create('DCheckBox', Frame)
                            DCheckBoxCanSonds:SetPos(50, 115)
                            if (LocalPlayer():IsSuperAdmin() == true) then
                                if (LocalPlayer():GetNWBool('GraffitiCanSounds') == false) then
                                    DCheckBoxCanSonds:SetChecked(false)
                                elseif (LocalPlayer():GetNWBool('GraffitiCanSounds') == true) then
                                    DCheckBoxCanSonds:SetChecked(true)
                                end
                                if (LocalPlayer():GetNWBool('GraffitiCanModify') == false) then
                                    DCheckBoxCanSonds:SetEnabled(false)
                                end
                            else
                                DCheckBoxCanSonds:SetEnabled(false)
                            end
                            DCheckBoxCanSonds.OnChange = function(panel, value)
                                if (LocalPlayer():IsSuperAdmin()) then
                                    LocalPlayer():SetNWBool('GraffitiCanSounds', value)
                                    file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                    if (value == false) then
                                        RunConsoleCommand('graffiti_can_sounds', 0)
                                    elseif (value == true) then
                                        RunConsoleCommand('graffiti_can_sounds', 1)
                                    end
                                end
                            end
                            DLabelCanSonds = vgui.Create('DLabel', Frame)
                                DLabelCanSonds:SetPos(70, 110)
                                DLabelCanSonds:SetSize(200, 25)
                                DLabelCanSonds:SetColor(Color(255, 255, 255, 255))
                                DLabelCanSonds:SetText('Spraying sounds')
                        DCheckBoxCanParticle = vgui.Create('DCheckBox', Frame)
                            DCheckBoxCanParticle:SetPos(50, 135)
                            if (LocalPlayer():IsSuperAdmin() == true) then
                                if (LocalPlayer():GetNWBool('GraffitiCanParticle') == false) then
                                    DCheckBoxCanParticle:SetChecked(false)
                                elseif (LocalPlayer():GetNWBool('GraffitiCanParticle') == true) then
                                    DCheckBoxCanParticle:SetChecked(true)
                                end
                                if (LocalPlayer():GetNWBool('GraffitiCanModify') == false) then
                                    DCheckBoxCanParticle:SetEnabled(false)
                                end
                            else
                                DCheckBoxCanParticle:SetEnabled(false)
                            end
                            DCheckBoxCanParticle.OnChange = function(panel, value)
                                if (LocalPlayer():IsSuperAdmin()) then
                                    LocalPlayer():SetNWBool('GraffitiCanParticle', value)
                                    file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(value) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiExplosion')))
                                    if (value == false) then
                                        RunConsoleCommand('graffiti_can_particle', 0)
                                    elseif (value == true) then
                                        RunConsoleCommand('graffiti_can_particle', 1)
                                    end
                                end
                            end
                            DLabelCanParticle = vgui.Create('DLabel', Frame)
                                DLabelCanParticle:SetPos(70, 130)
                                DLabelCanParticle:SetSize(200, 25)
                                DLabelCanParticle:SetColor(Color(255, 255, 255, 255))
                                DLabelCanParticle:SetText('Spraying particles')
                        DCheckBoxExplosion = vgui.Create('DCheckBox', Frame)
                            DCheckBoxExplosion:SetPos(30, 165)
                            if (LocalPlayer():IsSuperAdmin() == true) then
                                if (LocalPlayer():GetNWBool('GraffitiExplosion') == false) then
                                    DCheckBoxExplosion:SetChecked(false)
                                elseif (LocalPlayer():GetNWBool('GraffitiExplosion') == true) then
                                    DCheckBoxExplosion:SetChecked(true)
                                end
                            else
                                DCheckBoxExplosion:SetEnabled(false)
                            end
                            DCheckBoxExplosion.OnChange = function(panel, value)
                                if (LocalPlayer():IsSuperAdmin()) then
                                    LocalPlayer():SetNWBool('GraffitiExplosion', value)
                                    file.Write('graffiti-swep/graffiti-settings-server.txt', tostring(LocalPlayer():GetNWBool('GraffitiAdmins')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanModify')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanSounds')) .. '\n' .. tostring(LocalPlayer():GetNWBool('GraffitiCanParticle')) .. '\n' .. tostring(value))
                                    if (value == false) then
                                        RunConsoleCommand('graffiti_explosion', 0)
                                    elseif (value == true) then
                                        RunConsoleCommand('graffiti_explosion', 1)
                                    end
                                end
                            end
                            DLabelExplosion = vgui.Create('DLabel', Frame)
                                DLabelExplosion:SetPos(50, 160)
                                DLabelExplosion:SetSize(200, 25)
                                DLabelExplosion:SetColor(Color(255, 255, 255, 255))
                                DLabelExplosion:SetText('Explosive spraying')
                        DSliderDistance = vgui.Create('DNumSlider', Frame)
                            DSliderDistance:SetPos(-140, 210)
                            DSliderDistance:SetSize(420, 25)
                            DSliderDistance:SetText('')
                            DSliderDistance:SetMin(140)
                            DSliderDistance:SetMax(9999)
                            DSliderDistance:SetValue(GetConVar('graffiti_max_distance'):GetInt())
                            if (LocalPlayer():IsSuperAdmin() == true) then
                                DSliderDistance:SetValue(GetConVar('graffiti_max_distance'):GetInt())
                            else
                                DSliderDistance:SetValue(140)
                                DSliderDistance:SetEnabled(false)
                            end
                            DSliderDistance.OnValueChanged = function(panel, value)
                                if (LocalPlayer():IsSuperAdmin()) and (value != GetConVar('graffiti_max_distance'):GetInt()) then
                                    RunConsoleCommand('graffiti_max_distance', value)
                                end
                            end
                            DLabelDistance = vgui.Create('DLabel', Frame)
                                DLabelDistance:SetPos(20, 190)
                                DLabelDistance:SetSize(200, 25)
                                DLabelDistance:SetColor(Color(255, 255, 255, 255))
                                DLabelDistance:SetText('Graffiti Max Distance:')
                        DLabelNote_3 = vgui.Create('DLabel', Frame)
                            DLabelNote_3:SetPos(30, 235)
                            DLabelNote_3:SetSize(300, 25)
                            DLabelNote_3:SetColor(Color(255, 255, 255, 255))
                            DLabelNote_3:SetText('Note: Graffiti Max Distance is reset every time')
                        DLabelNote_4 = vgui.Create('DLabel', Frame)
                            DLabelNote_4:SetPos(65, 250)
                            DLabelNote_4:SetSize(300, 25)
                            DLabelNote_4:SetColor(Color(255, 255, 255, 255))
                            DLabelNote_4:SetText('the menu is opened')
                    end
                    LocalPlayer():SetNWInt('GraffitiModeSettings', 1)
                end

            local DImage = vgui.Create('DImage', Frame)
                DImage:SetPos(135, 30)
                DImage:SetImage('materials/images/graffiti-settings.png')
                DImage:SetSize(25, 25)

            local DCuteLabel = vgui.Create('DLabel', Frame)
                DCuteLabel:SetPos(10, 425)
                DCuteLabel:SetSize(100, 25)
                DCuteLabel:SetColor(Color(120, 120, 120, 255))
                DCuteLabel:SetText('Click me!')
                DCuteLabel:SetMouseInputEnabled(true)
                LocalPlayer():SetNWInt('CuteLabel', 1)
            DCuteLabel.DoClick = function()
                local ply = LocalPlayer()
                ply:SetNWInt('CuteLabel', ply:GetNWInt('CuteLabel') + 1)

                local stage = tonumber(ply:GetNWInt('CuteLabel'))
                if (stage == 2) then
                    DCuteLabel:SetText("you're cute :)")
                    net.Start('SecretChanger')
                elseif (stage == 3) then
                    DCuteLabel:SetText('enough')
                    net.Start('SecretChanger')
                elseif (stage == 4) then
                    DCuteLabel:SetText('stop it')
                    net.Start('SecretChanger')
                elseif (stage == 5) then
                    DCuteLabel:SetText('last warning')
                    net.Start('SecretChanger')
                elseif (stage == 6) then
                    DCuteLabel:SetText('bye')
                    net.Start('CuteChanger')
                end
                net.SendToServer()
            end
    end
end