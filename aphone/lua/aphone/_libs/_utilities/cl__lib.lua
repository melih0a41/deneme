aphone.SpecialNumbers = aphone.SpecialNumbers or {}

function aphone.RegisterNumber(info)
    if not isstring(info.name) or not isfunction(info.func) or not isstring(info.icon) then return end
    info.icon = Material(info.icon, "smooth 1")

    if info.icon and !info.icon:IsError() then
        aphone.SpecialNumbers[info.name] = info

        return true
    end
end

function aphone.playringtone()
    local id
    local l = "Ringtones"

    for k, v in pairs(aphone.Ringtones) do
        if aphone:GetParameters(l, "Ringstone_" .. k, false) then
            id = k
            break
        end
    end

    if !id or !aphone.Ringtones or !aphone.Ringtones[id] then
        print("[APhone] Invalid Ringtone ID, please select another sound in your settings")
        surface.PlaySound("akulla/phone_ringing.mp3")
        return
    end

    local c = aphone.Ringtones[id]
    if !c.is_local then
        sound.PlayURL(c.url, "", function( station, errorID, errorname)
            if ( IsValid( station ) ) then
                station:Play()
            else
                print("[APhone] The URL of the ringtone does not seem valid, the default sound is played.")
                surface.PlaySound("akulla/phone_ringing.mp3")
            end
        end )
    else
        surface.PlaySound(c.url)
    end
end

-- Load Player
net.Receive("aphone_GiveID", function()
    local e = net.ReadEntity()

    if IsValid(e) then
        e.aphone_ID = net.ReadUInt(32)
        e.aphone_number = net.ReadUInt(30)
    end
end)

net.Receive("aphone_OldID", function()
    for i=1, net.ReadUInt(8) do
        local e = net.ReadEntity()
        local id = net.ReadUInt(32)
        local num = net.ReadUInt(30)

        if IsValid(e) then
            e.aphone_ID = id
            e.aphone_number = num
        end
    end
end)

hook.Add("InitPostEntity", "aphone_AskSQL", function()
    net.Start("aphone_AskSQL")
    net.SendToServer()
end)