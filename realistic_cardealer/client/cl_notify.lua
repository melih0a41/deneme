/*
    Addon id: 2b813340-177c-4a18-81fa-1b511607ebec
    Version: v1.7.4 (stable)
*/

RCD.Notify = RCD.Notify or {}

function RCD.Notification(time, msg)
    if RCD.GetSetting("activateNotification", "boolean") then
        RCD.Notify[#RCD.Notify + 1] = {
            ["Message"] = msg,
            ["Time"] = CurTime() + (time or 5),
            ["Material"] = RCD.Materials["notify_bell"], 
        }
    else
        notification.AddLegacy(msg, NOTIFY_GENERIC, time)
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e789974c2fcff9d15e065a40660eccf225eb39ac3a9d59bac27ee150e5ca0132

function RCD.DrawNotification()
    if RCD.Notify and #RCD.Notify > 0 then 
        for k,v in ipairs(RCD.Notify) do 
            surface.SetFont("RCD:Font:13")
            local SizeText = surface.GetTextSize(v.Message)

            if not isnumber(v.RLerp) then v.RLerp = -SizeText end 
            if not isnumber(v.RLerpY) then v.RLerpY = (RCD.ScrH*0.055*k)-RCD.ScrH*0.038 end

            if v.Time > CurTime() then
                v.RLerp = Lerp(FrameTime()*3, v.RLerp, RCD.ScrW*0.02)
            else
                v.RLerp = Lerp(FrameTime()*3, v.RLerp, (-RCD.ScrW*0.25 - SizeText))
                if v.RLerp < (-RCD.ScrW*0.15 - SizeText) then 
                    RCD.Notify[k] = nil 
                    RCD.Notify = table.ClearKeys(RCD.Notify) 
                end
            end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959499
            
            v.RLerpY = Lerp(FrameTime()*8, v.RLerpY, (RCD.ScrH*0.055*k)-RCD.ScrH*0.038)
 
            local posy = v.RLerpY
            local incline = RCD.ScrH*0.055

            local leftPart = {
                {x = v.RLerp, y = posy},
                {x = v.RLerp + incline + SizeText + RCD.ScrH*0.043, y = posy},
                {x = v.RLerp + RCD.ScrH*0.043 + SizeText + RCD.ScrH*0.043, y = posy + RCD.ScrH*0.043},
                {x = v.RLerp, y = posy + RCD.ScrH*0.043},
            }
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb
            
            surface.SetDrawColor(RCD.Colors["black18220"])
            draw.NoTexture()
            surface.DrawPoly(leftPart)

            local rightPart = {
                {x = v.RLerp, y = posy},
                {x = v.RLerp + incline, y = posy},
                {x = v.RLerp + RCD.ScrH*0.043, y = posy + RCD.ScrH*0.043},
                {x = v.RLerp, y = posy + RCD.ScrH*0.043},
            }
            
            surface.SetDrawColor(RCD.Colors["purple"])
            draw.NoTexture()
            surface.DrawPoly(rightPart)

            surface.SetDrawColor(RCD.Colors["white"])
            surface.SetMaterial(v.Material)
            surface.DrawTexturedRect(v.RLerp + RCD.ScrW*0.006, v.RLerpY + RCD.ScrH*0.007, RCD.ScrH*0.027, RCD.ScrH*0.027)

            draw.SimpleText(v.Message, "RCD:Font:13", v.RLerp + RCD.ScrW*0.037, v.RLerpY + RCD.ScrH*0.041/2, RCD.Colors["white"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end 
    end
end

hook.Add("DrawOverlay", "RCD:DrawOverlay:Notify", function()
    if IsValid(RCDMainFrame) then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7766f762a1a986c62b3dbf92b334b377bd995d32f352acbd0ed073bafd97aadb
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198362959506

    RCD.DrawNotification()
end)

net.Receive("RCD:Notification", function()
    local time = net.ReadUInt(3)
    local msg = net.ReadString()
    
    if RCD.GetSetting("activateNotification", "boolean") then
        RCD.Notification(time, msg)
    else
        notification.AddLegacy(msg, NOTIFY_GENERIC, time)
    end
end)
